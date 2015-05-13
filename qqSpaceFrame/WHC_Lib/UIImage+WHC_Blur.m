//
//  UIImage+WHC_Blur.m
//  UIImage+WHC_Blur
//
//  Created by 吴海超 on 15/4/12.
//  Copyright (c) 2015年 UIImage+WHC_Blur. All rights reserved.
//

#import "UIImage+WHC_Blur.h"

@implementation UIImage (WHC_Blur)
- (UIImage *)blurredImage:(CGFloat)blurAmount{
    return [self publicHandleBluredImage:blurAmount tintColor:nil];
}


- (UIImage *)blurredImage:(CGFloat)blurAmount tintColor:(UIColor*)tintColor{
    return [self publicHandleBluredImage:blurAmount tintColor:tintColor];
}

- (UIImage *)publicHandleBluredImage:(CGFloat)blurAmount tintColor:(UIColor*)tintColor{
    if (blurAmount < 0.0 || blurAmount > 1.0) {
        blurAmount = 0.5;
    }
    
    int boxSize = (int)(blurAmount * 40);
    boxSize = boxSize - (boxSize % 2) + 1;
    
    CGImageRef img = self.CGImage;
    
    vImage_Buffer inBuffer, outBuffer;
    vImage_Error error;
    
    void *pixelBuffer;
    
    //读取图像数据
    CGDataProviderRef inProvider = CGImageGetDataProvider(img);
    CFDataRef inBitmapData = CGDataProviderCopyData(inProvider);
    
    //获取图像宽高
    inBuffer.width = CGImageGetWidth(img);
    inBuffer.height = CGImageGetHeight(img);
    inBuffer.rowBytes = CGImageGetBytesPerRow(img);
    
    inBuffer.data = (void*)CFDataGetBytePtr(inBitmapData);
    
    pixelBuffer = malloc(CGImageGetBytesPerRow(img) * CGImageGetHeight(img));
    
    outBuffer.data = pixelBuffer;
    outBuffer.width = CGImageGetWidth(img);
    outBuffer.height = CGImageGetHeight(img);
    outBuffer.rowBytes = CGImageGetBytesPerRow(img);
    
    //高斯模糊变换处理
    error = vImageBoxConvolve_ARGB8888(&inBuffer, &outBuffer, NULL, 0, 0, boxSize, boxSize, NULL, kvImageEdgeExtend);
    
    if (!error) {
        error = vImageBoxConvolve_ARGB8888(&outBuffer, &inBuffer, NULL, 0, 0, boxSize, boxSize, NULL, kvImageEdgeExtend);
        
        if (!error) {
            error = vImageBoxConvolve_ARGB8888(&inBuffer, &outBuffer, NULL, 0, 0, boxSize, boxSize, NULL, kvImageEdgeExtend);
        }
    }
    
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
    
    //创建高斯模糊图像上下文
    CGContextRef ctx = CGBitmapContextCreate(outBuffer.data,
                                             outBuffer.width,
                                             outBuffer.height,
                                             8,
                                             outBuffer.rowBytes,
                                             colorSpace,
                                             (CGBitmapInfo)kCGImageAlphaPremultipliedLast);
    
    //填充色
    if(tintColor && ctx){
        CGRect  imageRect = {CGPointZero , self.size};
        CGContextSaveGState(ctx);
        CGContextSetFillColorWithColor(ctx, tintColor.CGColor);
        CGContextFillRect(ctx, imageRect);
        CGContextRestoreGState(ctx);
    }
    
    CGImageRef imageRef = CGBitmapContextCreateImage (ctx);
    
    UIImage *returnImage = [UIImage imageWithCGImage:imageRef];
    
    //释放资源
    free(pixelBuffer);
    CFRelease(inBitmapData);
    
    CGColorSpaceRelease(colorSpace);
    CGImageRelease(imageRef);
    CGContextRelease(ctx);
    
    return returnImage;
    
}

+ (UIImage *)imageColor:(UIColor*)color rect:(CGRect)rect{
    
    UIGraphicsBeginImageContext(rect.size);
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    CGContextSetFillColorWithColor(context, [color CGColor]);
    CGContextFillRect(context, rect);
    
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return image;
}

+ (UIImage *)imageColor:(UIColor *)color{
    return [UIImage imageColor:color rect:CGRectMake(0.0, 0.0, 1.0, 1.0)];
}
@end
