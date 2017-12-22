//
//  LoginNavC.m
//  reHeardTheNews
//
//  Created by Pop Web on 16/3/18.
//  Copyright © 2016年 paoguo. All rights reserved.
//

#import "LoginNavC.h"

@interface LoginNavC ()

@end

@implementation LoginNavC

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

//重写更改状态栏颜色方法，此为返回白色
- (UIStatusBarStyle)preferredStatusBarStyle
{
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
