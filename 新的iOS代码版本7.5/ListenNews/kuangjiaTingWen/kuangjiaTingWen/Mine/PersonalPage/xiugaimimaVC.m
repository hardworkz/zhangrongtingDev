//
//  xiugaimimaVC.m
//  reHeardTheNews
//
//  Created by 贺楠 on 16/5/26.
//  Copyright © 2016年 paoguo. All rights reserved.
//

#import "xiugaimimaVC.h"

@interface xiugaimimaVC ()
{
    UITextField *jiumimaF;
    UITextField *xinmimaF;
    UITextField *querenmimaF;
}
@end

@implementation xiugaimimaVC

- (void)viewDidLoad {
    [super viewDidLoad];
    [self enableAutoBack];
    self.view.backgroundColor = [UIColor whiteColor];
    
    jiumimaF = [[UITextField alloc]initWithFrame:CGRectMake(27.5 / 375 * IPHONE_W, 70.0 / 667 * IPHONE_H, 320.0 / 375 * IPHONE_W, 30.0 / 667 * IPHONE_H)];
    jiumimaF.placeholder = @"旧密码";
    jiumimaF.font = [UIFont systemFontOfSize:14.0f];
    jiumimaF.textAlignment = NSTextAlignmentCenter;
//    jiumimaF.keyboardType = UIKeyboardTypeNumberPad;
    jiumimaF.clearButtonMode = UITextFieldViewModeWhileEditing;
    [self.view addSubview:jiumimaF];
    
    xinmimaF = [[UITextField alloc]initWithFrame:CGRectMake(27.5 / 375 * IPHONE_W, CGRectGetMaxY(jiumimaF.frame) + 40.0 / 667 * IPHONE_H, 320.0 / 375 * IPHONE_W, 30.0 / 667 * IPHONE_H)];
    xinmimaF.placeholder = @"新密码";
    xinmimaF.font = [UIFont systemFontOfSize:14.0f];
    xinmimaF.textAlignment = NSTextAlignmentCenter;
//    xinmimaF.keyboardType = UIKeyboardTypeNumberPad;
    xinmimaF.clearButtonMode = UITextFieldViewModeWhileEditing;
    [self.view addSubview:xinmimaF];
    
    querenmimaF = [[UITextField alloc]initWithFrame:CGRectMake(27.5 / 375 * IPHONE_W, CGRectGetMaxY(xinmimaF.frame) + 40.0 / 667 * IPHONE_H, 320.0 / 375 * IPHONE_W, 30.0 / 667 * IPHONE_H)];
    querenmimaF.placeholder = @"确认密码";
    querenmimaF.font = [UIFont systemFontOfSize:14.0f];
    querenmimaF.textAlignment = NSTextAlignmentCenter;
//    querenmimaF.keyboardType = UIKeyboardTypeNumberPad;
    querenmimaF.clearButtonMode = UITextFieldViewModeWhileEditing;
    [self.view addSubview:querenmimaF];
    
    
    UIButton *NextStep = [UIButton buttonWithType:UIButtonTypeCustom];
    NextStep.frame = CGRectMake(0, CGRectGetMaxY(querenmimaF.frame) + 40.0 / 667 * IPHONE_H, IPHONE_W, 44.0 / 667 * IPHONE_H);
    NextStep.backgroundColor = gMainColor;
    [NextStep setTitle:@"完成" forState:UIControlStateNormal];
    [NextStep setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [NextStep addTarget:self action:@selector(nextstepAction:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:NextStep];
    
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    self.hidesBottomBarWhenPushed = YES;
}

- (void)nextstepAction:(UIButton *)sender
{
    if (![querenmimaF.text isEqualToString:xinmimaF.text])
    {
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"两次输入的密码不相同" message:nil delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
        [alertView show];
    }else if (xinmimaF.text.length < 6)
    {
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"请输入6位以上密码" message:nil delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
        [alertView show];
    }else
    {
        [NetWorkTool getPaoGuoUserInfoWithUserName:[DSE encryptUseDES:ExdangqianUser] andPassWord:[DSE encryptUseDES:jiumimaF.text] sccess:^(NSDictionary *responseObject) {
            if ([[NSString stringWithFormat:@"%@",responseObject[@"status"]] isEqualToString:@"0"])
            {
                UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"请输入正确原密码" message:nil delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
                [alertView show];
            }else
            {
                [NetWorkTool postPaoGuoXiuGaiMiMaWithaccessToken:[DSE encryptUseDES:ExdangqianUser] andopassword:[DSE encryptUseDES:jiumimaF.text] andpassword:[DSE encryptUseDES:xinmimaF.text] sccess:^(NSDictionary *responseObject) {
                    if([[NSString stringWithFormat:@"%@",responseObject[@"status"]] isEqualToString:@"1"])
                    {
                        UIAlertController *qingdengru = [UIAlertController alertControllerWithTitle:@"修改成功" message:nil preferredStyle:UIAlertControllerStyleAlert];
                        [qingdengru addAction:[UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
                            [self.navigationController popToRootViewControllerAnimated:YES];
                        }]];
                        
                        [self presentViewController:qingdengru animated:YES completion:^{
                        }];
                    }else
                    {
                        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"修改失败" message:nil delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
                        [alertView show];
                    }
                } failure:^(NSError *error) {
                    NSLog(@"error = %@",error);
                }];

            }
        } failure:^(NSError *error)
        {
            NSLog(@"error = %@",error);
        }];
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
