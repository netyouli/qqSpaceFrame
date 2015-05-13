//
//  WHC_SlideBlurNavigationController.m
//  qqSpaceFrame
//
//  Created by 吴海超 on 15/5/13.
//  Copyright (c) 2015年 吴海超. All rights reserved.
//

#import "WHC_SlideBlurNavigationController.h"
#import "WHC_BlurImageView.h"
@interface WHC_SlideBlurNavigationController ()<UINavigationControllerDelegate,UIGestureRecognizerDelegate>{
    UIPanGestureRecognizer           *   _panGesture;
    UITapGestureRecognizer           *   _tapGesture;
    WHC_BlurImageView                *   _blurView;                          //高斯模糊层
    BOOL                                 _isOpenMenu;                        //菜单是否已经全部打开
    UIView                           *   _topView;                           //顶部视图
    CGFloat                              _currentBlurLevel;                  //当前高斯模糊强度
}

@end

static WHC_SlideBlurNavigationController * whc_SideBlurNavigation;

@implementation WHC_SlideBlurNavigationController

+ (instancetype)sharedInstance{
    UIViewController  * rootVC = [[NSClassFromString(KWHC_SideBlur_Menu_N_Main_VC_Name) alloc]init];
    return [WHC_SlideBlurNavigationController sharedInstanceWithMainVC:rootVC];
}

+ (instancetype)sharedInstanceWithMainVC:(UIViewController*)mainVC{
    static dispatch_once_t predicate;
    dispatch_once(&predicate, ^{
        whc_SideBlurNavigation = [[WHC_SlideBlurNavigationController alloc]initWithRootViewController:mainVC];
        whc_SideBlurNavigation.delegate = whc_SideBlurNavigation;
    });
    return whc_SideBlurNavigation;
}

#pragma mark - initMothed
- (instancetype)initWithRootViewController:(UIViewController *)rootViewController{
    self = [super initWithRootViewController:rootViewController];
    if(self != nil){
        [self registPanGesture:YES];
    }
    return self;
}

- (instancetype)initWithCoder:(NSCoder *)aDecoder{
    self = [super initWithCoder:aDecoder];
    if(self != nil){
        [self registPanGesture:YES];
    }
    return self;
}

- (instancetype)init{
    self = [super init];
    if(self != nil){
        [self registPanGesture:YES];
    }
    return self;
}
#pragma mark - gestureMothed
- (void)registPanGesture:(BOOL)b{
    if(b){
        if(_panGesture == nil){
            _panGesture = [[UIPanGestureRecognizer alloc]initWithTarget:self action:@selector(handlePanGesture:)];
            _panGesture.delegate = self;
            [self.view addGestureRecognizer:_panGesture];
        }
    }else{
        if(_panGesture != nil){
            [self.view removeGestureRecognizer:_panGesture];
            _panGesture = nil;
        }
    }
}

- (void)enableTapGesture:(BOOL)enable{
    if(enable){
        if(_tapGesture == nil){
            _tapGesture = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(handleTapGesture:)];
            [self.view addGestureRecognizer:_tapGesture];
        }
    }else{
        if(_tapGesture != nil){
            [self.view removeGestureRecognizer:_tapGesture];
            _tapGesture = nil;
        }
    }
}

- (BOOL)showLeftMenu{
    if([self.topViewController respondsToSelector:@selector(whcSlideBlurNavigationControllerShouldShowLeftMenu)] &&
       [(UIViewController<WHC_SlideBlurNavigationControlerDelegate>*)self.topViewController whcSlideBlurNavigationControllerShouldShowLeftMenu]){
        return YES;
    }
    return NO;
}

- (UIImage *) snapshootView:(UIView *)view{
    UIGraphicsBeginImageContextWithOptions(view.bounds.size, view.opaque, 0.0);
    CGContextRef  ctx = UIGraphicsGetCurrentContext();
    [view.window.layer renderInContext:ctx];
    UIImage * image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return image;
}

- (void)handleTapGesture:(UITapGestureRecognizer*)tapGesture{
    [self closeSideMenu:YES];
}

- (void)handlePanGesture:(UIPanGestureRecognizer*)panGesture{
    NSParameterAssert(_leftMenuVC);
    UIView  * menuView = _leftMenuVC.view;
    switch (panGesture.state) {
        case UIGestureRecognizerStateBegan:{
            if(![self.view.window.subviews containsObject:_leftMenuVC.view]){
                CGRect  menuRC = {-(CGRectGetWidth([UIScreen mainScreen].bounds) - KWHC_SlideBlur_Right_Margin), 0 , _leftMenuVC.view.bounds.size};
                menuRC.size.width = -CGRectGetMinX(menuRC);
                _leftMenuVC.view.frame = menuRC;
                [self.view.window addSubview:_leftMenuVC.view];
            }
            UIViewController  * topVC = self.topViewController;
            if(!_blurView){
                _blurView = [[WHC_BlurImageView alloc]initWithFrame:topVC.view.bounds];
            }
            [self.view.window insertSubview:_blurView belowSubview:_leftMenuVC.view];
            _blurView.image = nil;
            _blurView.image = [self snapshootView:topVC.view];
        }
            break;
        case UIGestureRecognizerStateChanged:{
            CGFloat   menuWidth = CGRectGetWidth(menuView.bounds);
            CGFloat   currentX = [panGesture translationInView:panGesture.view].x;
            CGAffineTransform    transform = menuView.transform;
            menuView.transform = CGAffineTransformTranslate(transform, currentX, transform.ty);
            transform = menuView.transform;
            if(transform.tx > menuWidth){
                transform.tx = menuWidth;
                menuView.transform = transform;
            }
            if(transform.tx < 0.0){
                transform.tx = 0.0;
                menuView.transform = transform;
            }
            _currentBlurLevel = [_blurView blurLinerChange:transform.tx / menuWidth blurFactor:KWHC_SlideBlur_Menu_Blur_Factor];
            [panGesture setTranslation:CGPointZero inView:panGesture.view];
        }
            break;
        case UIGestureRecognizerStateCancelled:
        case UIGestureRecognizerStateEnded:{
            CGAffineTransform    transform = menuView.transform;
            CGFloat              menuWidth = CGRectGetWidth(menuView.bounds);
            if(!_isOpenMenu){
                if(transform.tx / menuWidth > kWHC_SlideBlur_Show_Factor){
                    // can open menu
                    [self closeSideMenu:NO];
                }else{
                    // not can open menu
                    [self closeSideMenu:YES];
                }
            }else{
                if(transform.tx / menuWidth < kWHC_SlideBlur_Show_Factor * 2.0 - 0.1){
                    [self closeSideMenu:YES];
                }else{
                    [self closeSideMenu:NO];
                }
            }
        }
            break;
        default:
            break;
    }
}

- (void)closeSideMenu:(BOOL)isClose{
    UIView              *menuView = _leftMenuVC.view;
    CGFloat              menuWidth = CGRectGetWidth(menuView.bounds);
    CGAffineTransform    transform = menuView.transform;
    _isOpenMenu = !isClose;
    
    if(isClose){
        [_blurView loadImageFrameSetWithCount:KWHC_SlideBlur_Menu_Blur_Farme_Count blurLevel:_currentBlurLevel currentBlurLevel:0.0];
        [_blurView reverseStartAnimationWithDuring:KWHC_SlideBlur_Menu_N_During];
        [self enableTapGesture:NO];
        transform.tx = 0.0;
    }else{
        [_blurView loadImageFrameSetWithCount:KWHC_SlideBlur_Menu_Blur_Farme_Count blurLevel:KWHC_SlideBlur_Menu_Blur_Factor currentBlurLevel:_currentBlurLevel];
        [_blurView startAnimatingWithDuring:KWHC_SlideBlur_Menu_N_During];
        [self enableTapGesture:YES];
        transform.tx = menuWidth;
    }
    [UIView animateWithDuration:KWHC_SlideBlur_Menu_N_During delay:0.0 options:UIViewAnimationOptionCurveEaseOut animations:^{
        menuView.transform = transform;
    } completion:^(BOOL finished) {
        if(isClose){
            [_blurView removeFromSuperview];
        }
    }];
}

#pragma mark - overloadMothed
- (void)pushViewController:(UIViewController *)viewController animated:(BOOL)animated{
    _topView = self.topViewController.view;
    _topView.userInteractionEnabled = NO;
    [super pushViewController:viewController animated:animated];
}

#pragma mark - UINavigationControllerDelegate
- (void)navigationController:(UINavigationController *)navigationController willShowViewController:(UIViewController *)viewController animated:(BOOL)animated{
    if(_isOpenMenu){
        [self closeSideMenu:YES];
    }
}
- (void)navigationController:(UINavigationController *)navigationController didShowViewController:(UIViewController *)viewController animated:(BOOL)animated{
    if(_topView != nil){
        _topView.userInteractionEnabled = YES;
    }
}

#pragma mark - UIGestureRecognizerDelegate
- (BOOL)gestureRecognizerShouldBegin:(UIGestureRecognizer *)gestureRecognizer{
    return [self showLeftMenu];
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
