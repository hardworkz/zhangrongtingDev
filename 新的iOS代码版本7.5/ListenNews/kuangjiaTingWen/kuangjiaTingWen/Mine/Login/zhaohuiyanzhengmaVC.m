//
//  zhaohuiyanzhengmaVC.m
//  reHeardTheNews
//
//  Created by 贺楠 on 16/5/26.
//  Copyright © 2016年 paoguo. All rights reserved.
//

#import "zhaohuiyanzhengmaVC.h"

@interface zhaohuiyanzhengmaVC ()
{
    UITextField *phoneF;
}
@end

@implementation zhaohuiyanzhengmaVC

- (void)viewDidLoad {
    [super viewDidLoad];
    [self enableAutoBack];
    self.title = @"验证码";
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
    
    //    UIButton *agreeBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    //    agreeBtn.frame = CGRectMake(117.0 / 375 * IPHONE_W, 147.0 / 667 * IPHONE_H, 15.0 / 375 * IPHONE_W, 15.0 / 667 * IPHONE_H);
    //    [agreeBtn setBackgroundImage:[UIImage imageNamed:@"agreement_agree_btn"] forState:UIControlStateNormal];
    //    [agreeBtn addTarget:self action:@selector(agreeAction:) forControlEvents:UIControlEventTouchUpInside];
    //    [self.view addSubview:agreeBtn];
    //    agreeBtn.contentMode = UIViewContentModeScaleToFill;
    //
    //    UILabel *agreeLab = [[UILabel alloc]initWithFrame:CGRectMake(131.0 / 375 * IPHONE_W, 144.0 / 667 * IPHONE_H, 42.0 / 375 * IPHONE_W, 21.0 / 667 * IPHONE_H)];
    //    agreeLab.text = @"同意";
    //    agreeLab.textColor = [UIColor blackColor];
    //    agreeLab.font = [UIFont systemFontOfSize:13.0f];
    //    agreeLab.textAlignment = NSTextAlignmentCenter;
    //    [self.view addSubview:agreeLab];
    //
    //    UIButton *xieyiBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    //    xieyiBtn.frame = CGRectMake(165.0 / 375 * IPHONE_W, 147.0 / 667 * IPHONE_H, 108.0, 16.0 / 667 * IPHONE_H);
    //    [xieyiBtn setTitle:@"《听闻用户协议》" forState:UIControlStateNormal];
    //    [xieyiBtn addTarget:self action:@selector(xieyiBtnAction:) forControlEvents:UIControlEventTouchUpInside];
    //    [xieyiBtn setTitleColor:ColorWithRGBA(0, 122, 255, 1) forState:UIControlStateNormal];
    //    xieyiBtn.titleLabel.font = [UIFont systemFontOfSize:13.0f];
    //    [self.view addSubview:xieyiBtn];

}
- (void)NextStep:(UIButton *)sender
{
    if ([phoneF.text isEqualToString:ExyanzhengmaStr])
    {
     [NetWorkTool postPaoGuoZhaoHuiMiMaGetSuiJiMiMaWithaccessToken:[DSE encryptUseDES:ExZhuCeAccessToken] andvcode:ExyanzhengmaStr sccess:^(NSDictionary *responseObject) {
         UIAlertController *qingdengru = [UIAlertController alertControllerWithTitle:@"随机密码已用短信方式发送到您手机" message:nil preferredStyle:UIAlertControllerStyleAlert];
         [qingdengru addAction:[UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
              [self.navigationController popToRootViewControllerAnimated:YES];
         }]];
         
         [self presentViewController:qingdengru animated:YES completion:^{
         }];
     } failure:^(NSError *error) {
         NSLog(@"error = %@",error);
     }];
       
    }else
    {
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"验证码输入错误" message:nil delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
        [alertView show];
    }
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
