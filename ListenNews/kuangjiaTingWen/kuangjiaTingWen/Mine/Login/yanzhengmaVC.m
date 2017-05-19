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

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
