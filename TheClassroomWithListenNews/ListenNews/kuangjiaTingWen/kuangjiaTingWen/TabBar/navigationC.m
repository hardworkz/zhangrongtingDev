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
- (UIStatusBarStyle)preferredStatusBarStyle{
    return UIStatusBarStyleDefault;
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
