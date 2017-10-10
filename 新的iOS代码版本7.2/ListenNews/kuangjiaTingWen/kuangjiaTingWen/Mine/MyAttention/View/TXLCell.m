//
//  TXLCell.m
//  Heard the news
//
//  Created by 温仲斌 on 15/12/2.
//  Copyright © 2015年 泡果网络. All rights reserved.
//


#import "TXLCell.h"
#import<MessageUI/MessageUI.h>
#import "CommonCode.h"

#import "UserClass.h"
IBInspectable
@interface TXLCell ()<MFMessageComposeViewControllerDelegate>

@property (nonatomic, strong) UserClass *userC;

@end

@implementation TXLCell

- (void)awakeFromNib {
    // Initialization code
}

- (void)setData:(UserClass *)userObject {
    _userC = userObject;
    _nameL.text = userObject.user_nicename.length ? userObject.user_nicename : userObject.user_phone;
}

- (IBAction)buttonTap:(id)sender {
    
    if (self.inviteFriend) {
        self.inviteFriend(self,_userC.user_phone,_userC.user_nicename);
    }
    
//    [self showMessageView:[NSArray arrayWithObjects:_userC.user_phone,nil]title:@"test"body:[NSString stringWithFormat:@"亲爱的%@,您的好友邀请您加入“《听闻》”app。甜美主播真人录制，实时资讯每日更新，解放双手，轻松闻尽天下事。友情链接：http://www.tingwen.me/", _userC.user_nicename.length ? _userC.user_nicename : _userC.user_phone]];
}

- (void)messageComposeViewController:(MFMessageComposeViewController *)controller didFinishWithResult:(MessageComposeResult)result{
    [controller dismissViewControllerAnimated:YES completion:nil];
    switch(result){
        caseMessageComposeResultSent:
            //信息传送成功
            
            break;
        caseMessageComposeResultFailed:
            //信息传送失败
            break;
        caseMessageComposeResultCancelled:
            //信息被用户取消传送
            break;
        default:
            break;
    }
}

-(void)showMessageView:(NSArray*)phones title:(NSString*)title body:(NSString*)body
{
    if([MFMessageComposeViewController canSendText])
    {
        MFMessageComposeViewController*controller=[[MFMessageComposeViewController alloc]init];
        controller.recipients= phones;
        controller.navigationBar.tintColor=[UIColor redColor];
        controller.body=body;
        controller.messageComposeDelegate=self;
        //TODO:跳转
        
        UIViewController *VC = [UIViewController new];
        for (UIView* next = [self superview]; next; next = next.superview) {
            UIResponder* nextResponder = [next nextResponder];
            if ([nextResponder isKindOfClass:[UIViewController class]]) {
                VC =  (UIViewController*)nextResponder;
            }
        }
        [VC.navigationController presentViewController:controller animated:YES completion:nil];
        [[[[controller viewControllers]lastObject]navigationItem]setTitle:title];//修改短信界面标题
    }
    else
    {
        UIAlertView*alert=[[UIAlertView alloc]initWithTitle:@"提示信息"
                                                   message:@"该设备不支持短信功能"
                                                  delegate:nil
                                         cancelButtonTitle:@"确定"
                                         otherButtonTitles:nil,nil];
        [alert show];
    }
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void)drawRect:(CGRect)rect {
    _button.layer.borderWidth = .5f;
    _button.layer.borderColor = [UIColor colorWithRed:0.0 green:0.0 blue:0.0 alpha:0.38].CGColor;
    _button.layer.cornerRadius = 5;
    _button.layer.borderColor = [UIColor lightGrayColor].CGColor;
    _button.layer.masksToBounds = YES;
}



@end
