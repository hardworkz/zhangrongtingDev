//
//  NewRegisterController.m
//  kuangjiaTingWen
//
//  Created by 泡果 on 2017/11/6.
//  Copyright © 2017年 zhimi. All rights reserved.
//

#import "NewRegisterController.h"

@interface NewRegisterController ()<UITextFieldDelegate>
{
    UITextField *phoneF;
    UITextField *verifyCodeF;
    Xzb_CountDownButton *verifyCodeBtn;
}
@end

@implementation NewRegisterController
- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self enableAutoBack];
    self.title = @"用户注册";
    self.navigationController.navigationBar.titleTextAttributes = @{NSForegroundColorAttributeName: [UIColor blackColor],
                                                                    NSFontAttributeName : [UIFont boldSystemFontOfSize:18]};
    self.view.backgroundColor = [UIColor whiteColor];
    
    
    UIButton *NextStep = [UIButton buttonWithType:UIButtonTypeCustom];
    NextStep.frame = CGRectMake(50, 235.0 / 667 * IPHONE_H, IPHONE_W - 100, 44.0 / 667 * IPHONE_H);
    NextStep.layer.cornerRadius = (44.0 / 667 * IPHONE_H)*0.5;
    NextStep.backgroundColor = gMainColor;
    [NextStep setTitle:@"下一步" forState:UIControlStateNormal];
    [NextStep addTarget:self action:@selector(NextStep:) forControlEvents:UIControlEventTouchUpInside];
    [NextStep setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [self.view addSubview:NextStep];
    
    UILabel *phoneL = [[UILabel alloc] initWithFrame:CGRectMake(27.5 / 375 * IPHONE_W, 95.0 / 667 * IPHONE_H, 60, 30.0 / 667 * IPHONE_H)];
    phoneL.text = @"账号:";
    [self.view addSubview:phoneL];
    
    phoneF = [[UITextField alloc]initWithFrame:CGRectMake(CGRectGetMaxX(phoneL.frame) + 10, 95.0 / 667 * IPHONE_H, SCREEN_WIDTH - CGRectGetMaxX(phoneL.frame) - 30, 30.0 / 667 * IPHONE_H)];
    phoneF.placeholder = @"请输入手机号码";
    phoneF.font = [UIFont systemFontOfSize:14.0f];
    phoneF.keyboardType = UIKeyboardTypeNumberPad;
    phoneF.clearButtonMode = UITextFieldViewModeWhileEditing;
    [self.view addSubview:phoneF];
    
    RegisterNotify(UITextFieldTextDidChangeNotification, @selector(textDidChange:))
    
    UIView *phoneLine = [[UIView alloc] initWithFrame:CGRectMake(phoneL.x, CGRectGetMaxY(phoneL.frame), phoneL.width + phoneF.width + 10, 0.5)];
    phoneLine.backgroundColor = [UIColor lightGrayColor];
    [self.view addSubview:phoneLine];
    
    
    UILabel *verifyCodeL = [[UILabel alloc] initWithFrame:CGRectMake(27.5 / 375 * IPHONE_W, CGRectGetMaxY(phoneF.frame) + 10, 60, 30.0 / 667 * IPHONE_H)];
    verifyCodeL.text = @"验证码:";
    [self.view addSubview:verifyCodeL];
    
    verifyCodeF = [[UITextField alloc]initWithFrame:CGRectMake(CGRectGetMaxX(verifyCodeL.frame)+ 10, CGRectGetMaxY(phoneF.frame) + 10, 140.0 / 375 * IPHONE_W, 30.0 / 667 * IPHONE_H)];
    verifyCodeF.placeholder = @"请输入验证码";
    verifyCodeF.font = [UIFont systemFontOfSize:14.0f];
    verifyCodeF.keyboardType = UIKeyboardTypeNumberPad;
    verifyCodeF.clearButtonMode = UITextFieldViewModeWhileEditing;
    [self.view addSubview:verifyCodeF];
    
    verifyCodeBtn = [[Xzb_CountDownButton alloc] initWithFrame:CGRectMake(CGRectGetMaxX(verifyCodeF.frame), CGRectGetMaxY(phoneF.frame) + 10, 120.0 / 375 * IPHONE_W, 30.0 / 667 * IPHONE_H)];
    [verifyCodeBtn addTarget:self action:@selector(verifyCodeBtnClicked:)];
    [verifyCodeBtn setTitle:@"获取验证码(60)" forState:UIControlStateNormal];
    [verifyCodeBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [verifyCodeBtn setBackgroundImage:[UIImage imageWithColor:[UIColor lightGrayColor]] forState:UIControlStateDisabled];
    [verifyCodeBtn setBackgroundImage:[UIImage imageWithColor:gMainColor] forState:UIControlStateNormal];
    verifyCodeBtn.titleLabel.font = [UIFont systemFontOfSize:15];
    verifyCodeBtn.index = 60;
    verifyCodeBtn.layer.cornerRadius = 8;
    verifyCodeBtn.clipsToBounds = YES;
    verifyCodeBtn.alpha = 0.0;
    verifyCodeBtn.enabled = NO;
    [self.view addSubview:verifyCodeBtn];
    
    UIView *verifyCodeLine = [[UIView alloc] initWithFrame:CGRectMake(verifyCodeL.x, CGRectGetMaxY(verifyCodeL.frame), verifyCodeL.width + verifyCodeF.width + verifyCodeBtn.width + 10, 0.5)];
    verifyCodeLine.backgroundColor = [UIColor lightGrayColor];
    [self.view addSubview:verifyCodeLine];
}
- (void)textDidChange:(NSNotification *)note
{
    if ([note.object isEqual:phoneF]) {
        if (phoneF.text.length) {
            if (verifyCodeBtn.alpha != 1.0) {
                [UIView animateWithDuration:0.5 animations:^{
                    verifyCodeBtn.alpha = 1.0;
                }];
            }
            if (phoneF.text.length == 11) {
                verifyCodeBtn.enabled = YES;
            }else{
                verifyCodeBtn.enabled = NO;
            }
        }else{
            if (verifyCodeBtn.alpha != 0.0) {
                [UIView animateWithDuration:0.5 animations:^{
                    verifyCodeBtn.alpha = 0.0;
                }];
            }
        }
    }
}
- (void)verifyCodeBtnClicked:(Xzb_CountDownButton *)button
{
    if (phoneF.text.length == 11){
        [button attAction];
        [NetWorkTool postPaoGuoZhuCeYanZhengMaWithphoneFNumber:[DSE encryptUseDES:phoneF.text] anduseType:@"1" sccess:^(NSDictionary *responseObject) {
            if ([responseObject[@"status"] integerValue] == 1) {
                ExyanzhengmaStr = [NSString stringWithFormat:@"%@",responseObject[@"results"]];
                ExZhuCeAccessToken = phoneF.text;
            }
            else{
                [SVProgressHUD showErrorWithStatus:[NSString stringWithFormat:@"%@",responseObject[@"msg"]]];
                [self performSelector:@selector(SVPDismiss) withObject:nil afterDelay:1.0];
            }
        } failure:^(NSError *error) {
            UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"您输入的手机号码格式不正确!" message:nil delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
            [alertView show];
        }];
    }
    else{
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"请输入正确的手机号码" message:nil delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
        [alertView show];
    }
}

- (void)NextStep:(UIButton *)sender
{
    if ([verifyCodeF.text isEqualToString:ExyanzhengmaStr]){
        [self.navigationController pushViewController:[shezhimimaVC new] animated:YES];
    }
    else{
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"验证码输入错误" message:nil delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
        [alertView show];
    }
}

- (void)SVPDismiss {
    [SVProgressHUD dismiss];
}

@end
