//
//  WHC_SlideBlurNavigationController.h
//  qqSpaceFrame
//
//  Created by 吴海超 on 15/5/13.
//  Copyright (c) 2015年 吴海超. All rights reserved.
//

/*
 *  qq:712641411
 *  gitHub:https://github.com/netyouli
 *  csdn:http://blog.csdn.net/windwhc/article/category/3117381
 */

#import <UIKit/UIKit.h>

#define kWHC_SlideBlur_Show_Factor            (0.5)              //能够显示菜单的系数
#define KWHC_SlideBlur_Right_Margin           (100.0)            //菜单右边距
#define KWHC_SlideBlur_Menu_N_During          (0.15)             //动画周期
#define KWHC_SlideBlur_Menu_Blur_Factor       (0.18)             //高斯模糊强度（0.0-1.0）
#define KWHC_SlideBlur_Menu_Blur_Farme_Count  (10)               //进行动画高斯模糊帧数
#define KWHC_SideBlur_Menu_N_Main_VC_Name (@"ViewController")    //主视图类名称

//WHC_SlideBlurNavigationControlerDelegate  协议主要是控制当前控制器是否支持拉开菜单
@protocol WHC_SlideBlurNavigationControlerDelegate <NSObject>
@optional
- (BOOL)whcSlideBlurNavigationControllerShouldShowLeftMenu;                  //return YES 表示能够拉开左菜单 否则不能
@end

@interface WHC_SlideBlurNavigationController : UINavigationController


@property (nonatomic, strong) UIViewController         * leftMenuVC;      //左菜单
@property (nonatomic, assign) BOOL                       touchBorder;     //是否从边缘拉开菜单


+ (instancetype)sharedInstance;
+ (instancetype)sharedInstanceWithMainVC:(UIViewController*)mainVC;
@end
