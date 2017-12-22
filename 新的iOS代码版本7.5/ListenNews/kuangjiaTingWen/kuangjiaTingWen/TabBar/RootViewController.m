//
//  RootViewController.m
//  kuangjiaTingWen
//
//  Created by 泡果 on 2017/7/3.
//  Copyright © 2017年 zhimi. All rights reserved.
//

#import "RootViewController.h"

@interface RootViewController ()

@end

@implementation RootViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    UIButton *leftBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [leftBtn setBackgroundImage:[UIImage imageNamed:@"back"] forState:UIControlStateNormal];
    leftBtn.accessibilityLabel = @"返回";
    leftBtn.bounds = CGRectMake(0, 0, 9, 15);
    UIBarButtonItem *back = [[UIBarButtonItem alloc]initWithCustomView:leftBtn];
    [leftBtn addTarget:self action:@selector(back) forControlEvents:UIControlEventTouchUpInside];
    self.navigationItem.leftBarButtonItem = back;
}
- (void)back {
    [self.navigationController popViewControllerAnimated:YES];
}
@end
