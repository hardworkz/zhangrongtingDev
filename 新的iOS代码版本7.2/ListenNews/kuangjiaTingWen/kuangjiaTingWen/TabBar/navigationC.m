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
    //判断栈中是否存在NewPlayVC控制器，如果存在，则pop，否则崩溃
    BOOL isExist = NO;
    NSMutableArray *marr = [[NSMutableArray alloc] initWithArray:self.childViewControllers];
    for (UIViewController *vc in marr) {
        if ([vc isKindOfClass:[NewPlayVC class]]) {
            isExist = YES;
            break;
        }
    }
    if (isExist) {//判断当前栈中是否存在NewPlayVC
        if ([viewController isKindOfClass:[NewPlayVC class]]) {//判断当前栈顶控制器是否是NewPlayVC，不是则pop
            if (![self.topViewController isKindOfClass:[NewPlayVC class]]) {
                [super popViewControllerAnimated:YES];
            }
        }else{
            [super pushViewController:viewController animated:animated];
        }
    }else{
        [super pushViewController:viewController animated:animated];
    }
    
    if (IS_IPHONEX) {
        // 修改tabBra的frame ,防止导航栏在push时候移动
        CGRect frame = self.tabBarController.tabBar.frame;
        frame.origin.y = [UIScreen mainScreen].bounds.size.height - frame.size.height;
        self.tabBarController.tabBar.frame = frame;
    }
    
}

@end
