//
//  WHC_BlurImageView.h
//  WHC_BlurImageView
//
//  Created by 吴海超 on 15/5/12.
//  Copyright (c) 2015年 Delve. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface WHC_BlurImageView : UIImageView

@property (nonatomic , assign)NSInteger     imageFrameCount;          //总图片帧数
- (void)loadImageFrameSetWithCount:(NSInteger)count blurLevel:(CGFloat)blurLevel currentBlurLevel:(CGFloat)currentBlurLevel fillBlurColor:(UIColor*)fillBlurColor;
- (void)loadImageFrameSetWithCount:(NSInteger)count blurLevel:(CGFloat)blurLevel currentBlurLevel:(CGFloat)currentBlurLevel;
- (void)startAnimatingWithDuring:(CGFloat)during;
- (void)reverseStartAnimationWithDuring:(CGFloat)during;
- (CGFloat)blurLinerChange:(CGFloat)blurRate blurFactor:(CGFloat)blurFactor;
@end
