//
//  shezhimimaVC.m
//  reHeardTheNews
//
//  Created by 贺楠 on 16/5/23.
//  Copyright © 2016年 paoguo. All rights reserved.
//

#import "shezhimimaVC.h"

@interface shezhimimaVC ()
{
    UITextField *shezhimimaF;
    UITextField *querenmimaF;
    UITextField *user_niceNameF;
}
@end

@implementation shezhimimaVC

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"设置密码";
    [self enableAutoBack];
    self.navigationController.navigationBar.titleTextAttributes = @{NSForegroundColorAttributeName: [UIColor blackColor],
                                                                    NSFontAttributeName : [UIFont boldSystemFontOfSize:18]};
    self.view.backgroundColor = [UIColor whiteColor];
    
    UIButton *NextStep = [UIButton buttonWithType:UIButtonTypeCustom];
    NextStep.frame = CGRectMake(0, 230.0 / 667 * IPHONE_H, IPHONE_W, 44.0 / 667 * IPHONE_H);
    NextStep.backgroundColor = gMainColor;
    [NextStep setTitle:@"确定" forState:UIControlStateNormal];
    [NextStep setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [NextStep addTarget:self action:@selector(NextStep:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:NextStep];
    
    shezhimimaF = [[UITextField alloc]initWithFrame:CGRectMake(27.5 / 375 * IPHONE_W, 95.0 / 667 * IPHONE_H, 320.0 / 375 * IPHONE_W, 30.0 / 667 * IPHONE_H)];
    shezhimimaF.placeholder = @"请设置密码";
    shezhimimaF.font = [UIFont systemFontOfSize:14.0f];
    shezhimimaF.textAlignment = NSTextAlignmentCenter;
    shezhimimaF.keyboardType = UIKeyboardTypeNumberPad;
    shezhimimaF.clearButtonMode = UITextFieldViewModeWhileEditing;
    [self.view addSubview:shezhimimaF];
    UIView *line = [[UIView alloc]initWithFrame:CGRectMake(IPHONE_W / 2 - 160.0 / 375 * IPHONE_W, 124.0 / 667 * IPHONE_H, 320.0 / 375 * IPHONE_W, 1)];
    line.backgroundColor = gMainColor;
    [self.view addSubview:line];

    querenmimaF = [[UITextField alloc]initWithFrame:CGRectMake(27.5 / 375 * IPHONE_W, 140.0 / 667 * IPHONE_H, 320.0 / 375 * IPHONE_W, 30.0 / 667 * IPHONE_H)];
    querenmimaF.placeholder = @"请确认密码";
    querenmimaF.font = [UIFont systemFontOfSize:14.0f];
    querenmimaF.textAlignment = NSTextAlignmentCenter;
    querenmimaF.keyboardType = UIKeyboardTypeNumberPad;
    querenmimaF.clearButtonMode = UITextFieldViewModeWhileEditing;
    [self.view addSubview:querenmimaF];
    UIView *line1 = [[UIView alloc]initWithFrame:CGRectMake(IPHONE_W / 2 - 160.0 / 375 * IPHONE_W, 174.0 / 667 * IPHONE_H, 320.0 / 375 * IPHONE_W, 1)];
    line1.backgroundColor = gMainColor;
    [self.view addSubview:line1];
    
    user_niceNameF = [[UITextField alloc]initWithFrame:CGRectMake(27.5 / 375 * IPHONE_W, 185.0 / 667 * IPHONE_H, 320.0 / 375 * IPHONE_W, 30.0 / 667 * IPHONE_H)];
    user_niceNameF.placeholder = @"请设置昵称";
    user_niceNameF.font = [UIFont systemFontOfSize:14.0f];
    user_niceNameF.textAlignment = NSTextAlignmentCenter;
    user_niceNameF.keyboardType = UIKeyboardTypeDefault;
    user_niceNameF.clearButtonMode = UITextFieldViewModeWhileEditing;
    [self.view addSubview:user_niceNameF];
    UIView *line2 = [[UIView alloc]initWithFrame:CGRectMake(IPHONE_W / 2 - 160.0 / 375 * IPHONE_W, 214.0 / 667 * IPHONE_H, 320.0 / 375 * IPHONE_W, 1)];
    line2.backgroundColor = gMainColor;
    [self.view addSubview:line2];
    
}

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    self.hidesBottomBarWhenPushed = YES;
}

- (void)NextStep:(UIButton *)sender{
    if (shezhimimaF.text.length >= 6){
        if ([shezhimimaF.text isEqualToString:querenmimaF.text]){
            [NetWorkTool postPaoGuoZhuCeWithZhuCeAccessToken:[DSE encryptUseDES:ExZhuCeAccessToken] andpassword:[DSE encryptUseDES:shezhimimaF.text]  anduser_nicename:user_niceNameF.text andvcode:ExyanzhengmaStr sccess:^(NSDictionary *responseObject) {
                if ([responseObject[@"status"] integerValue] == 1){
                    UIAlertController *qingdengru = [UIAlertController alertControllerWithTitle:@"注册成功" message:nil preferredStyle:UIAlertControllerStyleAlert];
                    [qingdengru addAction:[UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
                        [self.navigationController dismissViewControllerAnimated:YES completion:nil];
                    }]];
                    [self presentViewController:qingdengru animated:YES completion:^{
                    }];
                }
                else if ([responseObject[@"status"] integerValue] == 0){
                    UIAlertController *qingdengru = [UIAlertController alertControllerWithTitle:responseObject[@"msg"] message:nil preferredStyle:UIAlertControllerStyleAlert];
                    [qingdengru addAction:[UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
//                        [self.navigationController dismissViewControllerAnimated:YES completion:nil];
                    }]];
                    
                    [self presentViewController:qingdengru animated:YES completion:^{
                    }];
                }
            } failure:^(NSError *error) {
                UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"注册失败" message:nil delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
                [alertView show];
            }];
        }
        else{
            UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"两次输入密码不一致" message:nil delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
            [alertView show];
        }
    }
    else{
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"密码不能少于6位" message:nil delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
        [alertView show];
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
@end
