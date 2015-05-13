//
//  WHC_BlurImageView.m
//  WHC_BlurImageView
//
//  Created by 吴海超 on 15/5/12.
//  Copyright (c) 2015年 Delve. All rights reserved.
//

#import "WHC_BlurImageView.h"
#import "UIImage+WHC_Blur.h"

#define kWHC_DEFAULT_FRAME_COUNT (20)              //默认20帧
#define kWHC_MIN_FRAME_COUNT     (10)              //最少帧不少于10帧
#define kWHC_DEFAULT_ANIMATION_DRUING (0.25)       //默认动画周期
#define kWHC_IMAGE_COMPRESSION_QUALITY (0.001)     //图片压缩质量系数(低质量)
#define kWHC_DEFAULT_BLUR_LEVEL   (0.5f)           //默认高斯模糊级别

@interface WHC_BlurImageView (){
    
    NSMutableArray                       * _imageFrameArr;            //图片帧数组
    NSMutableArray                       * _reverseImageFrameArr;     //反转图片帧数组
    UIImage                              * _originalImage;            //原始图片
    CGFloat                                _blurLevel;                //高斯模糊级别（0.0 - 1.0）
    
}

@end

@implementation WHC_BlurImageView
#pragma mark - initMethod -
- (instancetype)initWithFrame:(CGRect)frame{
    self = [super initWithFrame:frame];
    if(self){
        [self initLayout];
    }
    return self;
}

- (instancetype)initWithCoder:(NSCoder *)aDecoder{
    self = [super initWithCoder:aDecoder];
    if(self){
        [self initLayout];
    }
    return self;
}

- (instancetype)initWithImage:(UIImage *)image{
    self = [super initWithImage:image];
    if(self){
        [self initLayout];
    }
    return self;
}

- (instancetype)initWithImage:(UIImage *)image highlightedImage:(UIImage *)highlightedImage{
    self = [super initWithImage:image highlightedImage:highlightedImage];
    if(self){
        [self initLayout];
    }
    return self;
}

#pragma mark - loadXib -
- (void)awakeFromNib{
    [self initLayout];
}

#pragma mark - initUI -
- (void)initLayout{
    self.backgroundColor = [UIColor clearColor];
    self.animationDuration = kWHC_DEFAULT_ANIMATION_DRUING;
    self.animationRepeatCount = 1;
    _imageFrameArr = [NSMutableArray new];
    _reverseImageFrameArr = [NSMutableArray new];
    _originalImage = self.image;
}

- (UIImage *)lowQualityOriginalImage{
    if(_originalImage == nil){
        _originalImage = self.image;
    }
    UIImage  * image = [UIImage imageWithData:UIImageJPEGRepresentation(_originalImage, kWHC_IMAGE_COMPRESSION_QUALITY)];
    return image;
}

- (void)loadImageFrameSetWithCount:(NSInteger)count blurLevel:(CGFloat)blurLevel currentBlurLevel:(CGFloat)currentBlurLevel fillBlurColor:(UIColor*)fillBlurColor{
    [_imageFrameArr removeAllObjects];
    [_reverseImageFrameArr removeAllObjects];
    count = (count < kWHC_MIN_FRAME_COUNT ? kWHC_MIN_FRAME_COUNT : count);
    _blurLevel = ((blurLevel < 0.0f || blurLevel > 1.0f) ? kWHC_DEFAULT_BLUR_LEVEL : blurLevel);
    CGFloat animationBlurLevel = _blurLevel - currentBlurLevel;
    fillBlurColor = (fillBlurColor ? fillBlurColor : [UIColor clearColor]);
    UIImage  * compressionOriginalImage = [self lowQualityOriginalImage];
    for (NSInteger i = 0; i < count; i++) {
        UIImage  * blurImage = [compressionOriginalImage blurredImage:(i / (CGFloat)count) * animationBlurLevel + currentBlurLevel tintColor:[fillBlurColor colorWithAlphaComponent:(i / (CGFloat)count) * CGColorGetAlpha(fillBlurColor.CGColor)]];
        if(blurImage){
            [_imageFrameArr addObject:blurImage];
            [_reverseImageFrameArr insertObject:blurImage atIndex:0];
        }
    }
}

- (void)loadImageFrameSetWithCount:(NSInteger)count blurLevel:(CGFloat)blurLevel currentBlurLevel:(CGFloat)currentBlurLevel{
    [self loadImageFrameSetWithCount:count blurLevel:blurLevel currentBlurLevel:currentBlurLevel fillBlurColor:nil];
}

- (void)startAnimatingWithDuring:(CGFloat)during{
    if(during <= 0){
        during = kWHC_DEFAULT_ANIMATION_DRUING;
    }
    self.animationDuration = during;
    self.animationImages = _imageFrameArr;
    self.image = [_imageFrameArr lastObject];
    [self startAnimating];
}

- (void)reverseStartAnimationWithDuring:(CGFloat)during{
    if(during <= 0){
        during = kWHC_DEFAULT_ANIMATION_DRUING;
    }
    self.animationDuration = during;
    self.animationImages = _reverseImageFrameArr;
    self.image = _originalImage;
    [self startAnimating];
}


- (CGFloat)blurLinerChange:(CGFloat)blurRate blurFactor:(CGFloat)blurFactor{
    if(_originalImage == nil){
        _originalImage = self.image;
    }
    UIImage  * lowImage = [self lowQualityOriginalImage];
    self.image = nil;
    self.image = [lowImage blurredImage:blurRate * blurFactor];
    return blurRate * blurFactor;
}

@end
