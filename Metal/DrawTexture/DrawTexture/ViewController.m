//
//  ViewController.m
//  DrawTexture
//
//  Created by 黄世平 on 2022/5/16.
//

#import "ViewController.h"
#import "MetalRender.h"

@interface ViewController ()

@end

@implementation ViewController
{
    MTKView *view_;
    MetalRender *renderer_;
}

- (void)viewDidLoad
{
    [super viewDidLoad];

    view_ = (MTKView *)self.view;
    
    view_.device = MTLCreateSystemDefaultDevice();
    
    NSAssert(view_.device, @"Metal is not supported on this device");
    
    renderer_ = [[MetalRender alloc] initWithMetalKitView:view_];
    
    NSAssert(renderer_, @"Renderer failed initialization");

    // Initialize the renderer with the view size
    [renderer_ mtkView:view_ drawableSizeWillChange:view_.drawableSize];

    view_.delegate = renderer_;
}

@end
