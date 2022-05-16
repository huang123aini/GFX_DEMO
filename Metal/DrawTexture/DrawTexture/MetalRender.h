//
//  MetalRender.h
//  DrawTexture
//
//  Created by 黄世平 on 2022/5/16.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@import MetalKit;

@interface MetalRender: NSObject<MTKViewDelegate>

- (nonnull instancetype)initWithMetalKitView:(nonnull MTKView *)mtkView;

@end

NS_ASSUME_NONNULL_END
