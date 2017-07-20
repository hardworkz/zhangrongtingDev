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
    [super pushViewController:viewController animated:animated];
}

@end
