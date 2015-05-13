//
//  UIImage+WHC_Blur.h
//  UIImage+WHC_Blur
//
//  Created by 吴海超 on 15/4/12.
//  Copyright (c) 2015年 UIImage+WHC_Blur. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Accelerate/Accelerate.h>
@interface UIImage (WHC_Blur)
/*
 blurAmount = 0.0 - 1.0
*/
- (UIImage*)blurredImage:(CGFloat)blurAmount;

/*
 blurAmount = 0.0 - 1.0
 tintColor 填充色
 */
- (UIImage *)blurredImage:(CGFloat)blurAmount tintColor:(UIColor*)tintColor;

+ (UIImage *)imageColor:(UIColor*)color rect:(CGRect)rect;

+ (UIImage *)imageColor:(UIColor *)color;
@end
