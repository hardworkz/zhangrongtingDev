//
//  LoginVC.m
//  reHeardTheNews
//
//  Created by Pop Web on 16/3/18.
//  Copyright © 2016年 paoguo. All rights reserved.
//

#import "LoginVC.h"
#import "zhuceVC.h"
#import "forgetVC.h"
#import "WeiboSDK.h"
#import <TencentOpenAPI/TencentOAuth.h>
#import "AppDelegate.h"
#import <UMSocialCore/UMSocialCore.h>
//#import "UMSocialWechatHandler.h"
#import "AFNetworking.h"

@interface LoginVC ()<TencentSessionDelegate,WXApiDelegate>
{
    UITextField *userTF;
    UITextField *passWTF;
    TencentOAuth *tencentOAuth;
    NSArray *permissions;
    
    
    NSString *name;
    NSString *head;
    int type;
    NSString *openid;
    NSString *access_token;
    NSDate *expires_in;
    
}
@end

@implementation LoginVC
- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    APPDELEGATE.isLogin = YES;
}
- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"账号登录";
    self.navigationController.navigationBar.titleTextAttributes = @{NSForegroundColorAttributeName: [UIColor blackColor],
                                                                    NSFontAttributeName : [UIFont boldSystemFontOfSize:18]};
    UIButton *leftBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [leftBtn setBackgroundImage:[UIImage imageNamed:@"back"] forState:UIControlStateNormal];
    leftBtn.accessibilityLabel = @"返回";
    leftBtn.bounds = CGRectMake(0, 0, 9, 15);
    UIBarButtonItem *back = [[UIBarButtonItem alloc]initWithCustomView:leftBtn];
    [leftBtn addTarget:self action:@selector(back) forControlEvents:UIControlEventTouchUpInside];
    self.navigationItem.leftBarButtonItem = back;
    
    self.view.backgroundColor = [UIColor whiteColor];
    
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc]initWithTitle:@"注册" style:UIBarButtonItemStylePlain target:self action:@selector(zhuce:)];
    
    
    UIView *textFBgV = [[UIView alloc]initWithFrame:CGRectMake(15.0 / 375 * IPHONE_W, 82.0 / 667 * IPHONE_H, IPHONE_W - 30.0 / 375 * IPHONE_W, 92.0 / 667 * IPHONE_H)];
    textFBgV.backgroundColor = [UIColor whiteColor];
    textFBgV.layer.borderWidth = 0.5f;
    textFBgV.layer.borderColor = [UIColor lightGrayColor].CGColor;
    textFBgV.layer.cornerRadius = 5.0;
    [self.view addSubview:textFBgV];
    
    UIButton *LoginBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    LoginBtn.frame = CGRectMake(45.0 / 375 * IPHONE_W, textFBgV.frame.origin.y + textFBgV.frame.size.height + 7, IPHONE_W - 90.0 / 375 * IPHONE_W, 32.0 / 667 * IPHONE_H);
    [self.view addSubview:LoginBtn];
    [LoginBtn setBackgroundColor:gMainColor];
    [LoginBtn setTitle:@"登录" forState:UIControlStateNormal];
    [LoginBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [LoginBtn addTarget:self action:@selector(loginBtnAction:) forControlEvents:UIControlEventTouchUpInside];
    LoginBtn.layer.cornerRadius = 5.0;
    
    UIImageView *userAndPassWordBgImgV = [[UIImageView alloc]initWithFrame:CGRectMake(0, 0, 46.0 / 375 * IPHONE_W, textFBgV.frame.size.height)];
    userAndPassWordBgImgV.image = [UIImage imageNamed:@"deng-6"];
    [textFBgV addSubview:userAndPassWordBgImgV];
    
    UIImageView *userBgV = [[UIImageView alloc]initWithFrame:CGRectMake(12.0 / 375 * IPHONE_W, 12.0 / 667 * IPHONE_H, 20, 26)];
    userBgV.image = [UIImage imageNamed:@"deng-3"];
    userBgV.contentMode = UIViewContentModeScaleAspectFit;
    [userAndPassWordBgImgV addSubview:userBgV];
    
    UIImageView *passWBgV = [[UIImageView alloc]initWithFrame:CGRectMake(12.0 / 375 * IPHONE_W, 53.0 / 667 * IPHONE_H, 20, 26)];
    passWBgV.image = [UIImage imageNamed:@"deng-4"];
    passWBgV.contentMode = UIViewContentModeScaleAspectFit;
    [userAndPassWordBgImgV addSubview:passWBgV];
    
    userTF = [[UITextField alloc]initWithFrame:CGRectMake(56.0 / 375 * IPHONE_W, 10.0 / 667 * IPHONE_H, 250.0 / 375 * IPHONE_W, 30.0 / 667 * IPHONE_H)];
    userTF.placeholder = @"手机号码";
    userTF.clearButtonMode = UITextFieldViewModeWhileEditing;
    userTF.autocorrectionType = UITextAutocorrectionTypeNo;
    userTF.autocapitalizationType = UITextAutocapitalizationTypeNone;
    [textFBgV addSubview:userTF];
    
    passWTF = [[UITextField alloc]initWithFrame:CGRectMake(56.0 / 375 * IPHONE_W, 55.0 / 667 * IPHONE_H, 250.0 / 375 * IPHONE_W, 30.0 / 667 * IPHONE_H)];
    passWTF.placeholder = @"密码";
    passWTF.clearButtonMode = UITextFieldViewModeWhileEditing;
    passWTF.secureTextEntry = YES;
    passWTF.autocorrectionType = UITextAutocorrectionTypeNo;
    passWTF.clearsOnBeginEditing = YES;
    [textFBgV addSubview:passWTF];
    
    UIView *textFLine = [[UIView alloc]initWithFrame:CGRectMake(45.0 / 375 * IPHONE_W, 45.5 / 667 * IPHONE_H,  IPHONE_W - 75.0 / 375 * IPHONE_W, 1.0)];
    textFLine.backgroundColor = [UIColor lightGrayColor];
    textFLine.alpha = 0.5f;
    [textFBgV addSubview:textFLine];
    
    UIButton *forgetPassW = [UIButton buttonWithType:UIButtonTypeCustom];
    forgetPassW.frame = CGRectMake(260.0 / 375 * IPHONE_W, LoginBtn.frame.origin.y + LoginBtn.frame.size.height + 15.0 / 667 * IPHONE_H, 90.0 / 375 * IPHONE_W, 20.0 / 667 * IPHONE_H);
    forgetPassW.titleLabel.font = [UIFont systemFontOfSize:14.0f];
    [self.view addSubview:forgetPassW];
    [forgetPassW setTitle:@"忘记密码？" forState:UIControlStateNormal];
    [forgetPassW setTitleColor:gMainColor forState:UIControlStateNormal];
    [forgetPassW addTarget:self action:@selector(forgetPassWAction:) forControlEvents:UIControlEventTouchUpInside];
    
    UIView *downLine = [[UIView alloc]initWithFrame:CGRectMake(0, 426.0 / 667 * IPHONE_H, IPHONE_W, 1)];
    downLine.backgroundColor = [UIColor whiteColor];
    [self.view addSubview:downLine];
    
    UILabel *downLab = [[UILabel alloc]initWithFrame:CGRectMake(0, downLine.frame.origin.y + 25.0 / 667 * IPHONE_H, IPHONE_W, 20.0 / 667 * IPHONE_H)];
    downLab.text = @"还可以选择以下登录方式";
    downLab.textColor = UIColorFromHex(0x999999);
    downLab.textAlignment = NSTextAlignmentCenter;
    downLab.font = [UIFont systemFontOfSize:13.0f];
    [self.view addSubview:downLab];
    
    
    //wechat
    UIButton *weChatBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    weChatBtn.frame = CGRectMake(64.0 / 375 * IPHONE_W,  downLine.frame.origin.y + 70.0 / 667 * IPHONE_H, 40.0 / 375 * IPHONE_W, 40.0 / 375 * IPHONE_W);
    [weChatBtn setBackgroundImage:[UIImage imageNamed:@"wechat"] forState:UIControlStateNormal];
    weChatBtn.accessibilityLabel = @"微信登录";
    [weChatBtn addTarget:self action:@selector(weChatBtnAction:) forControlEvents:UIControlEventTouchUpInside];
    
    UILabel *weChatLab = [[UILabel alloc]initWithFrame:CGRectMake(weChatBtn.frame.origin.x - 20.0 / 375 * SCREEN_WIDTH,weChatBtn.frame.origin.y + weChatBtn.frame.size.height + 8.0 / 667 * IPHONE_H, 80.0 / 375 * IPHONE_W, 20.0 / 667 * IPHONE_H)];
    weChatLab.text = @"微信登录";
    weChatLab.textColor = UIColorFromHex(0x999999);
    weChatLab.textAlignment = NSTextAlignmentCenter;
    weChatLab.font = [UIFont systemFontOfSize:13.0f];
    
    //QQ
    UIButton *QQBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    QQBtn.frame = CGRectMake(167.0 / 375 * IPHONE_W, downLine.frame.origin.y + 70.0 / 667 * IPHONE_H, 40.0 / 375 * IPHONE_W, 40.0 / 375 * IPHONE_W);
    [QQBtn setBackgroundImage:[UIImage imageNamed:@"qq"] forState:UIControlStateNormal];
    QQBtn.accessibilityLabel = @"QQ登录";
    [QQBtn addTarget:self action:@selector(QQBtnAction:) forControlEvents:UIControlEventTouchUpInside];
    
    UILabel *qqLab = [[UILabel alloc]initWithFrame:CGRectMake(QQBtn.frame.origin.x - 20.0 / 375 * SCREEN_WIDTH,  QQBtn.frame.origin.y + QQBtn.frame.size.height + 8.0 / 667 * IPHONE_H, 80.0 / 375 * IPHONE_W, 20.0 / 667 * IPHONE_H)];
    qqLab.text = @"QQ登录";
    qqLab.textColor = UIColorFromHex(0x999999);
    qqLab.textAlignment = NSTextAlignmentCenter;
    qqLab.font = [UIFont systemFontOfSize:13.0f];
    
    //Sina
    UIButton *weiBoBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    weiBoBtn.frame = CGRectMake(SCREEN_WIDTH - 104.0 / 375 * IPHONE_W,  downLine.frame.origin.y + 70.0 / 667 * IPHONE_H, 40.0 / 375 * IPHONE_W, 40.0 / 375 * IPHONE_W);
    [weiBoBtn setBackgroundImage:[UIImage imageNamed:@"sina"] forState:UIControlStateNormal];
    weiBoBtn.accessibilityLabel = @"微博登录";
    [weiBoBtn addTarget:self action:@selector(weiBoBtnAction:) forControlEvents:UIControlEventTouchUpInside];
    
    
    UILabel *weiboLab = [[UILabel alloc]initWithFrame:CGRectMake(weiBoBtn.frame.origin.x - 20.0 / 375 * SCREEN_WIDTH,  weiBoBtn.frame.origin.y + weiBoBtn.frame.size.height + 8.0 / 667 * IPHONE_H, 80.0 / 375 * IPHONE_W, 20.0 / 667 * IPHONE_H)];
    weiboLab.text = @"微博登录";
    weiboLab.textColor = UIColorFromHex(0x999999);
    [weiboLab setTextAlignment:NSTextAlignmentCenter];
    weiboLab.font = [UIFont systemFontOfSize:13.0f];
    
    
    if (![WXApi isWXAppInstalled]){
        //App Store规定未安装微信时隐藏微信登录按钮
        [QQBtn setFrame:CGRectMake(98.0 / 375 * IPHONE_W, downLine.frame.origin.y + 70.0 / 667 * IPHONE_H, 40.0 / 375 * IPHONE_W, 40.0 / 375 * IPHONE_W)];
        [qqLab setFrame:CGRectMake(QQBtn.frame.origin.x - 20.0 / 375 * SCREEN_WIDTH,  QQBtn.frame.origin.y + QQBtn.frame.size.height + 8.0 / 667 * IPHONE_H, 80.0 / 375 * IPHONE_W, 20.0 / 667 * IPHONE_H)];
        [weiBoBtn setFrame:CGRectMake(SCREEN_WIDTH - 137.0 / 375 * IPHONE_W,  downLine.frame.origin.y + 70.0 / 667 * IPHONE_H, 40.0 / 375 * IPHONE_W, 40.0 / 375 * IPHONE_W)];
        [weiboLab setFrame:CGRectMake(weiBoBtn.frame.origin.x - 20.0 / 375 * SCREEN_WIDTH,  weiBoBtn.frame.origin.y + weiBoBtn.frame.size.height + 8.0 / 667 * IPHONE_H, 80.0 / 375 * IPHONE_W, 20.0 / 667 * IPHONE_H)];
        [self.view addSubview:QQBtn];
        [self.view addSubview:qqLab];
        [self.view addSubview:weiBoBtn];
        [self.view addSubview:weiboLab];
    }
    else{
        [weChatBtn setFrame:CGRectMake(64.0 / 375 * IPHONE_W,  downLine.frame.origin.y + 70.0 / 667 * IPHONE_H, 40.0 / 375 * IPHONE_W, 40.0 / 375 * IPHONE_W)];
        [weChatLab setFrame:CGRectMake(weChatBtn.frame.origin.x - 20.0 / 375 * SCREEN_WIDTH,weChatBtn.frame.origin.y + weChatBtn.frame.size.height + 8.0 / 667 * IPHONE_H, 80.0 / 375 * IPHONE_W, 20.0 / 667 * IPHONE_H)];
        [QQBtn setFrame:CGRectMake(167.0 / 375 * IPHONE_W, downLine.frame.origin.y + 70.0 / 667 * IPHONE_H, 40.0 / 375 * IPHONE_W, 40.0 / 375 * IPHONE_W)];
        [qqLab setFrame:CGRectMake(QQBtn.frame.origin.x - 20.0 / 375 * SCREEN_WIDTH,  QQBtn.frame.origin.y + QQBtn.frame.size.height + 8.0 / 667 * IPHONE_H, 80.0 / 375 * IPHONE_W, 20.0 / 667 * IPHONE_H)];
        [weiBoBtn setFrame:CGRectMake(SCREEN_WIDTH - 104.0 / 375 * IPHONE_W,  downLine.frame.origin.y + 70.0 / 667 * IPHONE_H, 40.0 / 375 * IPHONE_W, 40.0 / 375 * IPHONE_W)];
        [weiboLab setFrame:CGRectMake(weiBoBtn.frame.origin.x - 20.0 / 375 * SCREEN_WIDTH,  weiBoBtn.frame.origin.y + weiBoBtn.frame.size.height + 8.0 / 667 * IPHONE_H, 80.0 / 375 * IPHONE_W, 20.0 / 667 * IPHONE_H)];
        [self.view addSubview:weChatBtn];
        [self.view addSubview:weChatLab];
        [self.view addSubview:QQBtn];
        [self.view addSubview:qqLab];
        [self.view addSubview:weiBoBtn];
        [self.view addSubview:weiboLab];
    }
    
    
//    UIView *downLeftLine =[[UIView alloc]initWithFrame:CGRectMake(IPHONE_W / 2 - 60.0 / 375 * IPHONE_W, weiBoBtn.frame.origin.y + weiBoBtn.frame.size.height / 2, 40.0 / 375 * IPHONE_W, 1)];
//    downLeftLine.backgroundColor = gMainColor;
//    [self.view addSubview:downLeftLine];
//    
//    UIView *downRightLine =[[UIView alloc]initWithFrame:CGRectMake(IPHONE_W / 2 + 20.0 / 375 * IPHONE_W, weiBoBtn.frame.origin.y + weiBoBtn.frame.size.height / 2, 40.0 / 375 * IPHONE_W, 1)];
//    downRightLine.backgroundColor = gMainColor;
//    [self.view addSubview:downRightLine];
//    
//    UILabel *ORLab = [[UILabel alloc]initWithFrame:CGRectMake(IPHONE_W / 2 - 10.0 / 375 * IPHONE_W, weiBoBtn.frame.origin.y + weiBoBtn.frame.size.height / 2 - 15.0 / 667 * IPHONE_H, 30.0 / 375 * IPHONE_W, 30.0 / 667 * IPHONE_H)];
//    ORLab.textColor = gMainColor;
//    ORLab.text = @"OR";
//    ORLab.font = [UIFont systemFontOfSize:15.0f];
//    [self.view addSubview:ORLab];
    
    UISwipeGestureRecognizer *rightSwipe = [[UISwipeGestureRecognizer alloc]initWithTarget:self action:@selector(rightSwipeAction)];
    [rightSwipe setDirection:UISwipeGestureRecognizerDirectionRight];
    [self.view addGestureRecognizer:rightSwipe];
    
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    self.hidesBottomBarWhenPushed = YES;
    AppDelegate *appDelegate = (AppDelegate *)[UIApplication sharedApplication].delegate;
    DefineWeakSelf;
    appDelegate.weibologinSuccess = ^ (NSDictionary *userInfo){
        [weakSelf SSOWeiboLoginUserInfo:userInfo];
    };
    appDelegate.wechatGetLoginCode = ^ (NSString *code) {
        [weakSelf WechatSSOSuccessWithCode:code];
    };
}

#pragma mark - TencentSessionDelegate
//登陆完成调用
- (void)tencentDidLogin {
    
    if (tencentOAuth.accessToken && 0 != [tencentOAuth.accessToken length])
    {
        //  记录登录用户的OpenID、Token以及过期时间
//        tokenLable.text =tencentOAuth.accessToken;
        NSLog(@"tencentOAuth.accessToken = %@",tencentOAuth.accessToken);
        openid = tencentOAuth.openId;
        access_token = tencentOAuth.accessToken;
        expires_in = tencentOAuth.expirationDate;
    }
    else
    {
//        tokenLable.text =@"登录不成功没有获取accesstoken";
        NSLog(@"登录不成功没有获取accesstoken");
    }
    [tencentOAuth getUserInfo];
}

//非网络错误导致登录失败：
-(void)tencentDidNotLogin:(BOOL)cancelled{
    NSLog(@"tencentDidNotLogin");
    if (cancelled){
        NSLog(@"用户取消登录");
    }
    else{
        NSLog(@"登录失败");
    }
}
// 网络错误导致登录失败：
-(void)tencentDidNotNetWork{
    NSLog(@"无网络连接，请设置网络");
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

//以上方法基本上就实现了登陆，下来我们得考虑登陆成功之后如何获取用户信息
//其实方法很简单我们在登陆成功的方法里面调用

//然后系统会调用一个方法（我们需要提前实现）
-(void)getUserInfoResponse:(APIResponse *)response{

    name = response.jsonResponse[@"nickname"];
    if ([response.jsonResponse[@"figureurl_qq_2"] isEqualToString:@""]){
        head = response.jsonResponse[@"figureurl_qq_1"];
    }
    else{
        head = response.jsonResponse[@"figureurl_qq_2"];
    }
    type = 1;
    [NetWorkTool postPaoGuoDiSanFangDengLuJieKouwithname:name
                                                 andhead:head
                                                 andtype:type
                                               andopenid:openid
                                         andaccess_token:access_token
                                           andexpires_in:expires_in
                                                  sccess:^(NSDictionary *responseObject) {
        ExdangqianUser = responseObject[@"results"][@"user_login"];
        [CommonCode writeToUserD:[NSString stringWithFormat:@"%@",ExdangqianUser] andKey:@"dangqianUser"];
        [CommonCode writeToUserD:responseObject[@"results"][@"id"] andKey:@"dangqianUserUid"];
        [self dismissViewControllerAnimated:YES completion:nil];
        [CommonCode writeToUserD:@(YES) andKey:@"isLogin"];
        [CommonCode writeToUserD:responseObject andKey:@"dangqianUserInfo"];
        //    //拿到图片
//        UIImage *userAvatar = [UIImage imageWithData:[NSData dataWithContentsOfURL:[NSURL URLWithString:head]]];
       UIImage *userAvatar = [UIImage imageWithData:[NSData dataWithContentsOfURL:[NSURL URLWithString:USERPHOTOHTTPSTRING(responseObject[@"results"][@"avatar"])]]];
        NSString *path_sandox = NSHomeDirectory();
        //设置一个图片的存储路径
        NSString *avatarPath = [path_sandox stringByAppendingString:@"/Documents/userAvatar.png"];
        //把图片直接保存到指定的路径（同时应该把图片的路径imagePath存起来，下次就可以直接用来取）
        [UIImagePNGRepresentation(userAvatar) writeToFile:avatarPath atomically:YES];
        [[NSNotificationCenter defaultCenter] postNotificationName:@"loginSccess" object:responseObject];
        [CommonCode writeToUserD:@"QQ" andKey:@"isWhatLogin"];
        ExdangqianUser = responseObject[@"results"][@"user_login"];
        [CommonCode writeToUserD:ExdangqianUser andKey:@"user_login"];
        
//                                                       [self performSelector:@selector(updateUserInfo) withObject:nil afterDelay:1.0];
    } failure:^(NSError *error) {
        NSLog(@"error = %@",error);
    }];
    
    [self getIAPInfomation];

}

#pragma mark - Utilities
- (void)rightSwipeAction{
    
    if (self.isSubscription) {
        [[NSNotificationCenter defaultCenter] postNotificationName:@"dingyueSkipToshouyeVC" object:nil];
    }
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)QQBtnAction:(UIButton *)sender{
    
    tencentOAuth = [[TencentOAuth alloc]initWithAppId:kAppId_QQ andDelegate:self];
    permissions = [NSArray arrayWithObjects:
                   kOPEN_PERMISSION_GET_USER_INFO,
                   kOPEN_PERMISSION_GET_SIMPLE_USER_INFO,
                   kOPEN_PERMISSION_ADD_SHARE,
                   nil];
    [tencentOAuth authorize:permissions inSafari:NO];
}

- (void)weiBoBtnAction:(UIButton *)sender{
    
    WBAuthorizeRequest *request = [WBAuthorizeRequest request];
    request.redirectURI = KweiBoUrl;
    request.scope = @"all";
    request.userInfo = @{@"SSO_From": @"SendMessageToWeiboViewController",
                         @"Other_Info_1": [NSNumber numberWithInt:123],
                         @"Other_Info_2": @[@"obj1", @"obj2"],
                         @"Other_Info_3": @{@"key1": @"obj1", @"key2": @"obj2"}};
    [WeiboSDK sendRequest:request];

}

- (void)SSOWeiboLoginUserInfo:(NSDictionary *)userinfo {
    
    if (![[NSUserDefaults standardUserDefaults] boolForKey:@"isLogin"]) {
        
        [NetWorkTool netwokingGET:nil andParameters:userinfo success:^(id obj) {
            name = obj[@"name"];
            head = obj[@"avatar_hd"];
            // 1.avatar_hd 2.avatar_large 3.profile_image_url
            type = 2;
            openid = userinfo[@"uid"];
            access_token = userinfo[@"access_token"];
            expires_in = userinfo[@"expires_in"];
            
            [CommonCode writeToUserD:access_token andKey:@"wbtoken"];
            
            [NetWorkTool postPaoGuoDiSanFangDengLuJieKouwithname:name
                                                         andhead:head
                                                         andtype:type
                                                       andopenid:openid
                                                 andaccess_token:access_token
                                                   andexpires_in:expires_in
                                                          sccess:^(NSDictionary *responseObject) {
                        
                ExdangqianUser = responseObject[@"results"][@"user_login"];
                [CommonCode writeToUserD:[NSString stringWithFormat:@"%@",ExdangqianUser] andKey:@"dangqianUser"];
                [CommonCode writeToUserD:responseObject[@"results"][@"id"] andKey:@"dangqianUserUid"];
                [self dismissViewControllerAnimated:YES completion:nil];
                [CommonCode writeToUserD:@(YES) andKey:@"isLogin"];
                [CommonCode writeToUserD:responseObject andKey:@"dangqianUserInfo"];
                //拿到图片
                                                              //拿到图片
              UIImage *userAvatar = [UIImage imageWithData:[NSData dataWithContentsOfURL:[NSURL URLWithString:USERPHOTOHTTPSTRING(responseObject[@"results"][@"avatar"])]]];
                                                              
                NSString *path_sandox = NSHomeDirectory();
                //设置一个图片的存储路径
                NSString *avatarPath = [path_sandox stringByAppendingString:@"/Documents/userAvatar.png"];
                //把图片直接保存到指定的路径（同时应该把图片的路径imagePath存起来，下次就可以直接用来取）
                [UIImagePNGRepresentation(userAvatar) writeToFile:avatarPath atomically:YES];
                [[NSNotificationCenter defaultCenter] postNotificationName:@"loginSccess" object:responseObject];
                [CommonCode writeToUserD:@"Weibo" andKey:@"isWhatLogin"];
                ExdangqianUser = responseObject[@"results"][@"user_login"];
                [CommonCode writeToUserD:ExdangqianUser andKey:@"user_login"];
                                                              [self dismissViewControllerAnimated:YES completion:nil];
            } failure:^(NSError *error) {
                NSLog(@"error = %@",error);
            }];
        }];
        [self getIAPInfomation];
    }
}

- (void)weChatBtnAction:(UIButton *)sender{
    
    //注册微信
    [WXApi registerApp:KweChatLoginAppID];
    
    if (![WXApi isWXAppInstalled]){
        UIAlertView *al = [[UIAlertView alloc]initWithTitle:@"提示" message:@"请安装微信" delegate:nil cancelButtonTitle:@"知道了" otherButtonTitles: nil];
        [al show];
        return;
    }
    //构造SendAuthReq结构体
    SendAuthReq* req = [[SendAuthReq alloc] init];
    req.scope = @"snsapi_userinfo";
    req.state = @"1234567890";//瞎填就行，据说用于防攻击
    
    //第三方向微信终端发送一个SendAuthReq消息结构
    if ([WXApi sendReq:req]) {
        NSLog(@"微信发送请求成功");
    }
    else{
        NSLog(@"微信发送请求失败");
    }
}

- (void)WechatSSOSuccessWithCode:(NSString *)code{
    
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    manager.requestSerializer.timeoutInterval = 40;
    manager.responseSerializer.acceptableContentTypes = [NSSet setWithObjects:@"text/plain",nil];
    [manager GET:[NSString stringWithFormat:@"https://api.weixin.qq.com/sns/oauth2/access_token?appid=%@&secret=%@&code=%@&grant_type=authorization_code",KweChatLoginAppID ,KweChatLoginAppSecret,code] parameters:nil success:^(NSURLSessionDataTask *task, NSDictionary *responseObject1) {
        //得到accesstoken
        [manager GET:[NSString stringWithFormat:@"https://api.weixin.qq.com/sns/userinfo?access_token=%@&openid=%@",responseObject1[@"access_token"],responseObject1[@"openid"]] parameters:nil success:^(NSURLSessionDataTask *task, id responseObject) {
            //得到用户信息
            NSLog(@"%@",responseObject);
            [self oauthLoginWithName:responseObject[@"nickname"]
                                head:responseObject[@"headimgurl"]
                                type:3
                              openid:responseObject[@"unionid"]
                        access_token:responseObject1[@"access_token"]
                          expires_in:responseObject1[@"expires_in"]
                         isWhatLogin:@"weixin"];
            
            
        } failure:^(NSURLSessionDataTask *task, NSError *error) {
            NSLog(@"用户信息获取失败");
        }];
        
    } failure:^(NSURLSessionDataTask *task, NSError *error) {
        //网络监听
        //[[NetworkingMangater sharedManager] networkingState];
        NSLog(@"accesstoken获取失败");
    }];
    
}

//第三方登录接口
- (void)oauthLoginWithName:(NSString *)userName
                      head:(NSString *)userHhead
                      type:(int)LoginType
                    openid:(NSString *)userOpenid
              access_token:(NSString *)userAccess_token
                expires_in:(NSDate *)userExpires_in
               isWhatLogin:(NSString *)isWhatLogin{
    
    [NetWorkTool postPaoGuoDiSanFangDengLuJieKouwithname:userName andhead:userHhead andtype:LoginType andopenid:userOpenid andaccess_token:userAccess_token andexpires_in:userExpires_in sccess:^(NSDictionary *responseObject) {
        ExdangqianUser = responseObject[@"results"][@"user_login"];
        [CommonCode writeToUserD:[NSString stringWithFormat:@"%@",ExdangqianUser] andKey:@"dangqianUser"];
        [CommonCode writeToUserD:responseObject[@"results"][@"id"] andKey:@"dangqianUserUid"];
        [self dismissViewControllerAnimated:YES completion:nil];
        [CommonCode writeToUserD:@(YES) andKey:@"isLogin"];
        [CommonCode writeToUserD:responseObject andKey:@"dangqianUserInfo"];
        //拿到图片
        UIImage *userAvatar = [UIImage imageWithData:[NSData dataWithContentsOfURL:[NSURL URLWithString:responseObject[@"results"][@"avatar"]]]];
        NSString *path_sandox = NSHomeDirectory();
        //设置一个图片的存储路径
        NSString *avatarPath = [path_sandox stringByAppendingString:@"/Documents/userAvatar.png"];
        //把图片直接保存到指定的路径（同时应该把图片的路径imagePath存起来，下次就可以直接用来取）
        [UIImagePNGRepresentation(userAvatar) writeToFile:avatarPath atomically:YES];
        [[NSNotificationCenter defaultCenter] postNotificationName:@"loginSccess" object:responseObject];
        [CommonCode writeToUserD:isWhatLogin andKey:@"isWhatLogin"];
        ExdangqianUser = responseObject[@"results"][@"user_login"];
        [CommonCode writeToUserD:ExdangqianUser andKey:@"user_login"];
        [self dismissViewControllerAnimated:YES completion:nil];
        [self getIAPInfomation];
        [[NSNotificationCenter defaultCenter] postNotificationName:@"updateUserInfo" object:nil];
        
    } failure:^(NSError *error) {
        //
    }];
    
}

- (void)forgetPassWAction:(UIButton *)sender {
    [self.navigationController pushViewController:[forgetVC new] animated:YES];
}

- (void)loginBtnAction:(UIButton *)sender{
    NSLog(@"登录");
    
    if (userTF.text.length == 0){
        UIAlertController *qingshuruyonghuming = [UIAlertController alertControllerWithTitle:@"请输入用户名" message:nil preferredStyle:UIAlertControllerStyleAlert];
        [qingshuruyonghuming addAction:[UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        }]];
        [self presentViewController:qingshuruyonghuming animated:YES completion:nil];
    }
    else{
        if (passWTF.text.length == 0){
            UIAlertController *qingshurumima = [UIAlertController alertControllerWithTitle:@"请输入密码" message:nil preferredStyle:UIAlertControllerStyleAlert];
            [qingshurumima addAction:[UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            }]];
            [self presentViewController:qingshurumima animated:YES completion:nil];
        }
        else{
            [NetWorkTool getPaoGuoUserInfoWithUserName:[DSE encryptUseDES:userTF.text] andPassWord:[DSE encryptUseDES:passWTF.text] sccess:^(NSDictionary *responseObject) {
                if ([responseObject[@"msg"] isEqualToString:@"用户名不存在!"])
                {
                    UIAlertController *mimacuowu = [UIAlertController alertControllerWithTitle:@"用户名不存在！" message:nil preferredStyle:UIAlertControllerStyleAlert];
                    [mimacuowu addAction:[UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
                    }]];
                    [self presentViewController:mimacuowu animated:YES completion:nil];
                }else
                {
                    if ([responseObject[@"msg"] isEqualToString:@"密码错误!"])
                    {
                        UIAlertController *mimacuowu = [UIAlertController alertControllerWithTitle:@"密码错误！" message:nil preferredStyle:UIAlertControllerStyleAlert];
                        [mimacuowu addAction:[UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
                        }]];
                        [self presentViewController:mimacuowu animated:YES completion:nil];
                    }
                    else{
                        ExdangqianUser = responseObject[@"results"][@"user_phone"];
                        [CommonCode writeToUserD:[NSString stringWithFormat:@"%@",ExdangqianUser] andKey:@"dangqianUser"];
                        [CommonCode writeToUserD:responseObject[@"results"][@"id"] andKey:@"dangqianUserUid"];
                        [self dismissViewControllerAnimated:YES completion:nil];
                        [CommonCode writeToUserD:@(YES) andKey:@"isLogin"];
                        [CommonCode writeToUserD:responseObject andKey:@"dangqianUserInfo"];
                        //    //拿到图片
                        UIImage *userAvatar = [UIImage imageWithData:[NSData dataWithContentsOfURL:[NSURL URLWithString:USERPHOTOHTTPSTRING(responseObject[@"results"][@"avatar"])]]];
                        NSString *path_sandox = NSHomeDirectory();
                        //设置一个图片的存储路径
                        NSString *avatarPath = [path_sandox stringByAppendingString:@"/Documents/userAvatar.png"];
                        //把图片直接保存到指定的路径（同时应该把图片的路径imagePath存起来，下次就可以直接用来取）
                        [UIImagePNGRepresentation(userAvatar) writeToFile:avatarPath atomically:YES];
                        [[NSNotificationCenter defaultCenter] postNotificationName:@"loginSccess" object:responseObject];
                        [CommonCode writeToUserD:@"ShouJi" andKey:@"isWhatLogin"];
                    }
                }
            } failure:^(NSError *error) {
                NSLog(@"error = %@",error);
            }];
            [self getIAPInfomation];
        }
    }
}

- (void)zhuce:(UIBarButtonItem *)sender{

    [self.navigationController pushViewController:[zhuceVC new] animated:YES];
}

- (void)back{
    
    if (self.isSubscription) {
        [[NSNotificationCenter defaultCenter] postNotificationName:@"dingyueSkipToshouyeVC" object:nil];
    }
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)updateUserInfo{
    [[NSNotificationCenter defaultCenter] postNotificationName:@"updateUserInfo" object:nil];
}

- (void)getIAPInfomation{
    //请求是否为内购的接口
    [NetWorkTool getAppVersionSccess:^(NSDictionary *responseObject) {
        NSLog(@"%@",responseObject);
        //听闻电台
        if ([APPBUNDLEIDENTIFIER isEqualToString:@"com.popwcn.ListenNewsExploreVersion"]) {
            //当前版本号与提交审核时后台配置的一样说明正在审核
            if ([responseObject[@"results"][@"exploreVersion"] isEqualToString:APPVERSION]) {
                [CommonCode writeToUserD:@(YES) andKey:@"isIAP"];
            }
            else{
                [CommonCode writeToUserD:@(NO) andKey:@"isIAP"];
            }
        }
        //听闻FM
        else{
            if ([responseObject[@"results"][@"listenNews"] isEqualToString:APPVERSION]) {
                [CommonCode writeToUserD:@(YES) andKey:@"isIAP"];
            }
            else{
                [CommonCode writeToUserD:@(NO) andKey:@"isIAP"];
            }
        }
        
    } failure:^(NSError *error) {
        //
        [CommonCode writeToUserD:nil andKey:@"isIAP"];
    }];
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter]removeObserver:self];
}

@end
