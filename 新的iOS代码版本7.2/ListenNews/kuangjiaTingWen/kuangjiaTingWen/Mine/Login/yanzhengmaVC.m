//
//  yanzhengmaVC.m
//  reHeardTheNews
//
//  Created by 贺楠 on 16/5/23.
//  Copyright © 2016年 paoguo. All rights reserved.
//

#import "yanzhengmaVC.h"
#import "shezhimimaVC.h"
@interface yanzhengmaVC ()
{
    UITextField *phoneF;
}
@end

@implementation yanzhengmaVC

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"验证码";
    [self enableAutoBack];
    self.navigationController.navigationBar.titleTextAttributes = @{NSForegroundColorAttributeName: [UIColor blackColor],
                                                                    NSFontAttributeName : [UIFont boldSystemFontOfSize:18]};
    self.view.backgroundColor = [UIColor whiteColor];
    UIView *line = [[UIView alloc]initWithFrame:CGRectMake(IPHONE_W / 2 - 160.0 / 375 * IPHONE_W, 124.0 / 667 * IPHONE_H, 320.0 / 375 * IPHONE_W, 1)];
    line.backgroundColor = gMainColor;
    [self.view addSubview:line];
    
    UIButton *NextStep = [UIButton buttonWithType:UIButtonTypeCustom];
    NextStep.frame = CGRectMake(0, 185.0 / 667 * IPHONE_H, IPHONE_W, 44.0 / 667 * IPHONE_H);
    NextStep.backgroundColor = gMainColor;
    [NextStep setTitle:@"下一步" forState:UIControlStateNormal];
    [NextStep setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [NextStep addTarget:self action:@selector(NextStep:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:NextStep];
    
    phoneF = [[UITextField alloc]initWithFrame:CGRectMake(27.5 / 375 * IPHONE_W, 95.0 / 667 * IPHONE_H, 320.0 / 375 * IPHONE_W, 30.0 / 667 * IPHONE_H)];
    phoneF.placeholder = @"验证码";
    phoneF.font = [UIFont systemFontOfSize:14.0f];
    phoneF.textAlignment = NSTextAlignmentCenter;
    phoneF.keyboardType = UIKeyboardTypeNumberPad;
    phoneF.clearButtonMode = UITextFieldViewModeWhileEditing;
    [self.view addSubview:phoneF];
    
}

- (void)NextStep:(UIButton *)sender{
    if ([phoneF.text isEqualToString:ExyanzhengmaStr]){
        [self.navigationController pushViewController:[shezhimimaVC new] animated:YES];

    }
    else{
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"验证码输入错误" message:nil delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
        [alertView show];
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
