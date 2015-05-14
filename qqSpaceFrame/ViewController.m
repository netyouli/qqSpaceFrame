//
//  ViewController.m
//  qqSpaceFrame
//
//  Created by 吴海超 on 15/5/12.
//  Copyright (c) 2015年 吴海超. All rights reserved.
//

/*
 *  qq:712641411
 *  gitHub:https://github.com/netyouli
 *  csdn:http://blog.csdn.net/windwhc/article/category/3117381
 */

#import "ViewController.h"
#import "WHC_BlurImageView.h"
#import "UIImage+WHC_Blur.h"
#define kWHC_MARGIN     (100.0)         //左侧边距
#define kWHC_BLUR_FRAME_COUNT (30)      //高斯模糊帧数
#define kWHC_SHOW_NUM   (0.5)           //显示系数
#define kWHC_ANIMATION_DURING (0.25)    //动画周期
@interface ViewController (){
    
    WHC_BlurImageView  *      _backImageView;
    WHC_BlurImageView  *      _slideImageView;
    WHC_BlurImageView  *      _overBackImageView;
    UIPanGestureRecognizer   * _panGesture;
    
    CGPoint                    _startPoint;
    CGFloat                    _showLeftWidth;
    BOOL                       _isClick;
    BOOL                       _isOpen;
}

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"全部动态";
    CGRect    bgRC = {CGPointZero , CGRectGetWidth(self.view.bounds) , CGRectGetHeight(self.view.bounds)};
    _backImageView = [[WHC_BlurImageView alloc]initWithFrame:bgRC];
    _backImageView.image = [UIImage imageNamed:@"qqSpace.png"];
    [self.view addSubview:_backImageView];
    [_backImageView loadImageFrameSetWithCount:kWHC_BLUR_FRAME_COUNT blurLevel:kWHC_SHOW_NUM currentBlurLevel:0.0];
    UITapGestureRecognizer  * tapGesture = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(handleTapGesture:)];
    [self.view addGestureRecognizer:tapGesture];
    // Do any additional setup after loading the view, typically from a nib.
}

- (BOOL)whcSlideBlurNavigationControllerShouldShowLeftMenu{
    return YES;
}

- (void)handleTapGesture:(UITapGestureRecognizer*)tapGesture{
    _isClick = !_isClick;
    if(_isClick){
        [_backImageView startAnimatingWithDuring:1.0];
    }else{
        [_backImageView reverseStartAnimationWithDuring:1.0];
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
