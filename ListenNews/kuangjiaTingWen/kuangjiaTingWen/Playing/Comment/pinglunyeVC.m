//
//  pinglunyeVC.m
//  reHeardTheNews
//
//  Created by 贺楠 on 16/4/27.
//  Copyright © 2016年 paoguo. All rights reserved.
//

#import "pinglunyeVC.h"
#import "bofangVC.h"
@interface pinglunyeVC ()<UITextViewDelegate>
{
    UITextView *pinglunNeiRongTV;
    UILabel *textVPlaceholderLab;
}
@end

@implementation pinglunyeVC

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = self.isNewsCommentPage ? @"编辑评论" : @"投诉";
    self.navigationController.navigationBar.titleTextAttributes = @{NSForegroundColorAttributeName: [UIColor blackColor],
                                                                    NSFontAttributeName : [UIFont boldSystemFontOfSize:18]};
    UIButton *leftBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [leftBtn setBackgroundImage:[UIImage imageNamed:@"title_ic_back"] forState:UIControlStateNormal];
    leftBtn.bounds = CGRectMake(0, 0, 9, 15);
    leftBtn.accessibilityLabel = @"返回";
    UIBarButtonItem *back = [[UIBarButtonItem alloc]initWithCustomView:leftBtn];
    [leftBtn addTarget:self action:@selector(back) forControlEvents:UIControlEventTouchUpInside];
    self.navigationItem.leftBarButtonItem = back;
    
    self.view.backgroundColor = [UIColor whiteColor];
    
    UIButton *rightBtn = [UIButton buttonWithType:UIButtonTypeCustom];
//    [rightBtn setBackgroundImage:[UIImage imageNamed:@"back"] forState:UIControlStateNormal];
    [rightBtn setTitle:@"提交" forState:UIControlStateNormal];
    [rightBtn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    rightBtn.bounds = CGRectMake(SCREEN_WIDTH - 55, 0, 35, 15);
    UIBarButtonItem *rightBtnItem = [[UIBarButtonItem alloc]initWithCustomView:rightBtn];
    [rightBtn.titleLabel setFont:gFontMain15];
    [rightBtn addTarget:self action:@selector(tijiao) forControlEvents:UIControlEventTouchUpInside];
    self.navigationItem.rightBarButtonItem = rightBtnItem;
    
//    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc]initWithTitle:@"提交" style:UIBarButtonItemStylePlain target:self action:@selector(tijiao)];
    
    pinglunNeiRongTV = [[UITextView alloc]initWithFrame:CGRectMake(5.0 / 375 * IPHONE_W, 69.0 / 667 * IPHONE_H, IPHONE_W - 10.0 / 375 * IPHONE_W, 188.0 / 667 * IPHONE_H)];
   
    pinglunNeiRongTV.layer.borderColor = [UIColor grayColor].CGColor;
    
    pinglunNeiRongTV.layer.borderWidth =1.0;
    
    pinglunNeiRongTV.layer.cornerRadius =5.0;
    pinglunNeiRongTV.scrollEnabled = YES;
    //添加滚动区域
//    pinglunNeiRongTV.contentInset = UIEdgeInsetsMake(-60.0 / 667 * IPHONE_H, 0, 0, 0);
    pinglunNeiRongTV.font = [UIFont systemFontOfSize:17.0f / 375 * IPHONE_W];
//    pinglunNeiRongTF.autoresizingMask = UIViewAutoresizingFlexibleHeight;//自适应高度
    pinglunNeiRongTV.delegate = self;
    
    textVPlaceholderLab = [[UILabel alloc]initWithFrame:CGRectMake(8.0 / 375 * IPHONE_W, -64.0 / 667 * IPHONE_H, 200.0 / 375 * IPHONE_W, 20.0 / 667 * IPHONE_H)];
    textVPlaceholderLab.text = @"请输入内容";
    textVPlaceholderLab.textColor = [UIColor grayColor];
    textVPlaceholderLab.font = [UIFont systemFontOfSize:17.0f / 375 * IPHONE_W];
    textVPlaceholderLab.alpha = 0.5f;
    textVPlaceholderLab.hidden = NO;
    textVPlaceholderLab.backgroundColor = [UIColor whiteColor];
//    [pinglunNeiRongTV addSubview:textVPlaceholderLab];
     [self.view addSubview:pinglunNeiRongTV];
    
    UISwipeGestureRecognizer *rightSwipe = [[UISwipeGestureRecognizer alloc]initWithTarget:self action:@selector(rightSwipeAction)];
    [rightSwipe setDirection:UISwipeGestureRecognizerDirectionRight];
    [self.view addGestureRecognizer:rightSwipe];
    
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self.navigationController setNavigationBarHidden:NO animated:animated];
}

#pragma mark --- 按钮事件
- (void)back{
    [self.navigationController popViewControllerAnimated:YES];
//    [self dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark --- 手势事件
- (void)rightSwipeAction {
    [self.navigationController popViewControllerAnimated:YES];
}


#pragma mark --- textView代理
-(void)textViewDidChange:(UITextView *)textView
{
    //    pinglunNeiRongTV.text =  textView.text;
    if (textView.text.length == 0) {
        textVPlaceholderLab.hidden = NO;
    }else
    {
        textVPlaceholderLab.hidden = YES;
    }
}
-(void)textViewDidBeginEditing:(UITextView *)textView{
    
}
- (void)textViewDidEndEditing:(UITextView *)textView{

}

- (BOOL)textFieldShouldReturn:(UITextField *)textField{
    [textField resignFirstResponder];    //主要是[receiver resignFirstResponder]在哪调用就能把receiver对应的键盘往下收
    return YES;
}
#pragma mark --- 事件
- (void)tijiao{
    //emoji解析上传
    [SVProgressHUD setDefaultMaskType:SVProgressHUDMaskTypeBlack];
    [SVProgressHUD showWithStatus:@"发送中..."];
    
    NSArray *ContentArr = [self stringContainsEmoji:pinglunNeiRongTV.text];
    NSString *str = pinglunNeiRongTV.text;
    for (NSString *emoji in ContentArr) {
        str = [str stringByReplacingOccurrencesOfString:emoji withString:[NSString stringWithFormat:@"[e1]%@[/e1]", [DSE encryptUseDES:emoji]]];
    }
    if (self.isNewsCommentPage) {
        [NetWorkTool postPaoGuoXinWenPingLunWithaccessToken:[DSE encryptUseDES:ExdangqianUser] andto_uid:self.to_uid andpost_id:self.post_id andcomment_id:self.comment_id andpost_table:@"posts" andcontent:str sccess:^(NSDictionary *responseObject) {
            if ([[NSString stringWithFormat:@"%@",responseObject[@"status"]] isEqualToString:@"0"]){
                
                [SVProgressHUD showErrorWithStatus:responseObject[@"msg"]];
                [self performSelector:@selector(SVPDismiss) withObject:nil afterDelay:1.0];
            }
            else{
                ExisPingLunHouFanHui = YES;
                [SVProgressHUD showSuccessWithStatus:@"评论成功"];
                [self performSelector:@selector(SVPDismiss) withObject:nil afterDelay:1.0];
                [[NSNotificationCenter defaultCenter]postNotificationName:@"pinglunchenggong" object:nil];
                [self back];
            }
        } failure:^(NSError *error){
            NSLog(@"error = %@",error);
            [SVProgressHUD dismiss];
        }];
    }
    else{
        [NetWorkTool tousuLinsteningCircleWithaccessToken:AvatarAccessToken to_uid:self.to_uid comment_id:self.comment_id content:str sccess:^(NSDictionary *responseObject) {
            
            if ([responseObject[@"stastus"] integerValue] == 1) {
                [SVProgressHUD showSuccessWithStatus:[NSString stringWithFormat:@"%@",responseObject[@"msg"]]];
                [self performSelector:@selector(SVPDismiss) withObject:nil afterDelay:1.0];
                [self back];
            }
            else{
                [SVProgressHUD dismiss];
            }
            
        } failure:^(NSError *error) {
            //
            [SVProgressHUD dismiss];
        }];
    }
    
}


- (NSArray *)stringContainsEmoji:(NSString *)string {
    
    __block BOOL returnValue    = NO;
    __block NSMutableArray *arr = [NSMutableArray array];
    [string enumerateSubstringsInRange:NSMakeRange(0, [string length])
                               options:NSStringEnumerationByComposedCharacterSequences
                            usingBlock:^(NSString *substring, NSRange substringRange, NSRange enclosingRange, BOOL *stop) {
                                const unichar hs            = [substring characterAtIndex:0];
                                if (0xd800 <= hs && hs <= 0xdbff) {
                                    if (substring.length > 1) {
                                        const unichar ls            = [substring characterAtIndex:1];
                                        const int uc                = ((hs - 0xd800) * 0x400) + (ls - 0xdc00) + 0x10000;
                                        if (0x1d000 <= uc && uc <= 0x1f77f) {
                                            returnValue                 = YES;
                                            [arr addObject:substring];
                                        }
                                    }
                                } else if (substring.length > 1) {
                                    const unichar ls            = [substring characterAtIndex:1];
                                    if (ls == 0x20e3) {
                                        returnValue                 = YES;
                                        [arr addObject:substring];
                                    }
                                } else {
                                    if (0x2100 <= hs && hs <= 0x27ff) {
                                        returnValue                 = YES;
                                        [arr addObject:substring];
                                    } else if (0x2B05 <= hs && hs <= 0x2b07) {
                                        returnValue                 = YES;
                                        [arr addObject:substring];
                                    } else if (0x2934 <= hs && hs <= 0x2935) {
                                        returnValue                 = YES;
                                        [arr addObject:substring];
                                    } else if (0x3297 <= hs && hs <= 0x3299) {
                                        returnValue                 = YES;
                                        [arr addObject:substring];
                                    } else if (hs == 0xa9 || hs == 0xae || hs == 0x303d || hs == 0x3030 || hs == 0x2b55 || hs == 0x2b1c || hs == 0x2b1b || hs == 0x2b50) {
                                        returnValue                 = YES;
                                        [arr addObject:substring];
                                    }
                                }
                            }];
    return arr;
}

- (void)SVPDismiss {
    [SVProgressHUD dismiss];
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
