//
//  MetalRender.m
//  DrawTexture
//
//  Created by 黄世平 on 2022/5/16.
//

#import "MetalRender.h"

@import simd;
@import MetalKit;

#import "MetalImage.h"
#import "MetalShaderTypes.h"

@implementation MetalRender {
    /**
     *GPU设备
     */
    id<MTLDevice> device_;
    /**
     *渲染管线状态
     */
    id<MTLRenderPipelineState> pipeline_state;

    /**
     *命令队列
     */
    id<MTLCommandQueue> command_queue;

    /**
     *纹理对象
     */
    id<MTLTexture> texture_;

    /**
     *顶点数组
     */
    id<MTLBuffer> vertices_;

    /**
     *顶点个数
     */
    NSUInteger num_vertices;

    
    vector_uint2 viewport_size;
}

- (id<MTLTexture>)loadTextureUsingMetalImage: (NSURL *) url {
    
    MetalImage * image = [[MetalImage alloc] initWithTGAFileAtLocation:url];
    
    NSAssert(image, @"Failed to create the image from %@", url.absoluteString);

    /**
     *纹理基础信息描述
     */
    MTLTextureDescriptor *textureDescriptor = [[MTLTextureDescriptor alloc] init];
    
    /** Indicate that each pixel has a blue, green, red, and alpha channel, where each channel is
     * an 8-bit unsigned normalized value (i.e. 0 maps to 0.0 and 255 maps to 1.0)
     */
    textureDescriptor.pixelFormat = MTLPixelFormatBGRA8Unorm;
    
    /**
     *Set the pixel dimensions of the texture
     */
    textureDescriptor.width = image.width;
    textureDescriptor.height = image.height;
    
    // Create the texture from the device by using the descriptor
    id<MTLTexture> texture = [device_ newTextureWithDescriptor:textureDescriptor];
    
    // Calculate the number of bytes per row in the image.
    NSUInteger bytesPerRow = 4 * image.width;
    
    MTLRegion region = {
        { 0, 0, 0 },                   // MTLOrigin
        {image.width, image.height, 1} // MTLSize
    };
    
    // Copy the bytes from the data object into the texture
    [texture replaceRegion:region
                mipmapLevel:0
                  withBytes:image.data.bytes
                bytesPerRow:bytesPerRow];
    return texture;
}

- (nonnull instancetype)initWithMetalKitView:(nonnull MTKView *)mtkView
{
    self = [super init];
    if(self)
    {
        device_ = mtkView.device;

        NSURL *imageFileLocation = [[NSBundle mainBundle] URLForResource:@"Image"
                                                           withExtension:@"tga"];
        
        texture_ = [self loadTextureUsingMetalImage: imageFileLocation];

        /**
         *Set up a simple MTLBuffer with vertices which include texture coordinates
         */
        static const Vertex quadVertices[] =
        {
            // Pixel positions, Texture coordinates
            { {  250,  -250 },  { 1.f, 1.f } },
            { { -250,  -250 },  { 0.f, 1.f } },
            { { -250,   250 },  { 0.f, 0.f } },

            { {  250,  -250 },  { 1.f, 1.f } },
            { { -250,   250 },  { 0.f, 0.f } },
            { {  250,   250 },  { 1.f, 0.f } },
        };

        /**
         *创建顶点缓冲区，并初始化
         */
        vertices_ = [device_ newBufferWithBytes:quadVertices
                                         length:sizeof(quadVertices)
                                        options:MTLResourceStorageModeShared];

        /**
         *计算顶点个数
         */
        num_vertices = sizeof(quadVertices) / sizeof(Vertex);

        /**
         *======================创建渲染管线Begin===========================
         */

        /**
         *加载顶点着色器和片源着色器
         */
        id<MTLLibrary> defaultLibrary = [device_ newDefaultLibrary];
        id<MTLFunction> vertexFunction = [defaultLibrary newFunctionWithName:@"vertexShader"];
        id<MTLFunction> fragmentFunction = [defaultLibrary newFunctionWithName:@"samplingShader"];

        /**
         *渲染管线描述符
         */
        MTLRenderPipelineDescriptor *pipelineStateDescriptor = [[MTLRenderPipelineDescriptor alloc] init];
        pipelineStateDescriptor.label = @"Texturing Pipeline";
        pipelineStateDescriptor.vertexFunction = vertexFunction;
        pipelineStateDescriptor.fragmentFunction = fragmentFunction;
        pipelineStateDescriptor.colorAttachments[0].pixelFormat = mtkView.colorPixelFormat;

        NSError *error = NULL;
        pipeline_state = [device_ newRenderPipelineStateWithDescriptor:pipelineStateDescriptor
                                                                 error:&error];
        
        /**
         *=========================创建渲染管线End===========================
         */

        NSAssert(pipeline_state, @"Failed to create pipeline state: %@", error);

        command_queue = [device_ newCommandQueue];
    }

    return self;
}

- (void)mtkView:(nonnull MTKView *)view drawableSizeWillChange:(CGSize)size
{

    viewport_size.x = size.width;
    viewport_size.y = size.height;
}

- (void)drawInMTKView:(nonnull MTKView *)view
{
    /**
     *为RenderPass 创建一个CommandBuffer
     */
    id<MTLCommandBuffer> commandBuffer = [command_queue commandBuffer];
    commandBuffer.label = @"MyCommand";

    // Obtain a renderPassDescriptor generated from the view's drawable textures
    MTLRenderPassDescriptor *renderPassDescriptor = view.currentRenderPassDescriptor;

    if(renderPassDescriptor != nil)
    {
        /**
         *绘制编码
         */
        id<MTLRenderCommandEncoder> renderEncoder =
        [commandBuffer renderCommandEncoderWithDescriptor:renderPassDescriptor];
        renderEncoder.label = @"MyRenderEncoder";

        [renderEncoder setViewport:(MTLViewport){0.0, 0.0, viewport_size.x, viewport_size.y, -1.0, 1.0 }];
        
        /**
         *绘制编码设置渲染管线
         */
        [renderEncoder setRenderPipelineState:pipeline_state];

        [renderEncoder setVertexBuffer:vertices_
                                offset:0
                              atIndex:VertexInputIndexVertices];

        [renderEncoder setVertexBytes:&viewport_size
                               length:sizeof(viewport_size)
                              atIndex:VertexInputIndexViewportSize];

        [renderEncoder setFragmentTexture:texture_
                                  atIndex:AAPLTextureIndexBaseColor];

        /**
         *提交绘制命令
         */
        [renderEncoder drawPrimitives:MTLPrimitiveTypeTriangle
                          vertexStart:0
                          vertexCount:num_vertices];
        
        /**
         *结束当前编码
         */
        [renderEncoder endEncoding];

        [commandBuffer presentDrawable:view.currentDrawable];
    }

    /**
     *提交绘制指令buffer
     */
    [commandBuffer commit];
}

@end

