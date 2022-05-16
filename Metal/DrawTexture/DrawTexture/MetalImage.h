//
//  MetalImage.h
//  DrawTexture
//
//  Created by 黄世平 on 2022/5/16.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface MetalImage : NSObject

-(nullable instancetype) initWithTGAFileAtLocation:(nonnull NSURL *)location;

@property (nonatomic, readonly) NSUInteger      width;

@property (nonatomic, readonly) NSUInteger      height;

/**
 *Image data in 32-bits-per-pixel (bpp) BGRA form (which is equivalent to MTLPixelFormatBGRA8Unorm)
 */
@property (nonatomic, readonly, nonnull) NSData *data;

@end


NS_ASSUME_NONNULL_END
