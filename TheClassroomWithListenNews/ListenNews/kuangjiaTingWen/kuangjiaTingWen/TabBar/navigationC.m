//
//  navigationC.m
//  kuangjiaTingWen
//
//  Created by 贺楠 on 16/6/3.
//  Copyright © 2016年 贺楠. All rights reserved.
//

#import "navigationC.h"

@interface navigationC ()

@end

@implementation navigationC

- (void)viewDidLoad {
    [super viewDidLoad];
    
//    [self.navigationBar setBackgroundColor:[UIColor whiteColor]];
//    self.navigationBar.tintColor = [UIColor whiteColor];
//    [self.navigationBar setBackgroundImage:[UIImage imageNamed:@"shadow"] forBarMetrics:UIBarMetricsDefault];
    
    //导航栏按钮的标题颜色
    self.navigationBar.tintColor = [UIColor whiteColor];
    //设置一张透明图片遮盖导航栏底下的黑色线条
//    [self.navigationBar setBackgroundImage:[UIImage imageNamed:@"shadow"]
//                                                 forBarPosition:UIBarPositionAny
//                                                     barMetrics:UIBarMetricsDefault];
//    [self.navigationBar setShadowImage:[UIImage new]];
    //3.设置导航栏文字的主题
    self.navigationBar.titleTextAttributes = @{NSForegroundColorAttributeName: [UIColor blackColor],
                                                                    NSFontAttributeName : [UIFont boldSystemFontOfSize:18]};
    //导航栏透明
    [self.navigationController.navigationBar setTranslucent:NO];
    
}
//重写更改状态栏颜色方法，
- (UIStatusBarStyle)preferredStatusBarStyle
{
    return UIStatusBarStyleDefault;
}
- (void)pushViewController:(UIViewController *)viewController animated:(BOOL)animated
{
    if (self.childViewControllers.count > 0) {
        viewController.view.userInteractionEnabled = YES;
        viewController.hidesBottomBarWhenPushed = YES;
    }
    if ([viewController isKindOfClass:[bofangVC class]]) {//判断要push到的控制器是播放器
        bofangVC *playVC = (bofangVC *)viewController;
        UIViewController *VC = self.topViewController;
        //不是点击底部导航栏中心按钮的跳转才做isClass赋值判断
        if (!APPDELEGATE.isTabbarCenterClicked) {
            
            if ([VC isKindOfClass:[zhuboXiangQingVCNewController class]]) {
                zhuboXiangQingVCNewController *zhuboXiangQingVC = (zhuboXiangQingVCNewController *)VC;
                if (zhuboXiangQingVC.isClass) {//是否为课堂已购买详情的控制器
                    playVC.isClass = YES;
                }else{
                    playVC.isClass = NO;
                }
            }else{
                playVC.isClass = NO;
            }
        }
        
    }
    [super pushViewController:viewController animated:animated];
    APPDELEGATE.isTabbarCenterClicked = NO;
}

@end
