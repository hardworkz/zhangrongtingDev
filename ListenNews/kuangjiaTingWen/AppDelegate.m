//
//  AppDelegate.m
//  kuangjiaTingWen
//
//  Created by 贺楠 on 16/6/3.
//  Copyright © 2016年 贺楠. All rights reserved.
//

#import "AppDelegate.h"
#import "bofangVC.h"
#import <UMSocialCore/UMSocialCore.h>
//#import "UMSocialWechatHandler.h"
#import "UMSocialSinaHandler.h"
#import "guanggaoVC.h"
#import "WeiboSDK.h"
#import "LoginVC.h"
#include <TencentOpenAPI/QQApiInterface.h>
#import <TencentOpenAPI/QQApiInterfaceObject.h>
#import <TencentOpenAPI/TencentOAuthObject.h>
#import <TencentOpenAPI/TencentOAuth.h>
#import <TencentOpenAPI/TencentApiInterface.h>
#import <TencentOpenAPI/TencentMessageObject.h>
#import "MiPushSDK.h"
#import "WXApi.h"
#import "TimerViewController.h"
#import <AlipaySDK/AlipaySDK.h>
#import "UMMobClick/MobClick.h"
#import "TabBarController.h"
#import "SVProgressHUD.h"

@interface AppDelegate ()<WeiboSDKDelegate,WXApiDelegate,QQApiInterfaceDelegate,MiPushSDKDelegate,UNUserNotificationCenterDelegate>

@end

@implementation AppDelegate
+ (AppDelegate *)delegate {
    return (AppDelegate *)[UIApplication sharedApplication].delegate;
}
#pragma mark - network
- (void)setNetworkStatus:(NetworkStatus)networkStatus {
    if (_networkStatus != networkStatus) {
        _networkStatus = networkStatus;
        SendNotify(NETWORKSTATUSCHANGE, nil)
    }else {
        _networkStatus = networkStatus;
    }
}

//-(BOOL)application:(UIApplication *)application willFinishLaunchingWithOptions:(NSDictionary *)launchOptions{
//    
//     NSDictionary *userInfo = launchOptions[UIApplicationLaunchOptionsRemoteNotificationKey];
//    
//}


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    
    self.window = [[UIWindow alloc] initWithFrame:[UIScreen mainScreen].bounds];
    self.window.backgroundColor = [UIColor whiteColor];
    self.window.rootViewController = [[TabBarController alloc] init];
    
    [self.window makeKeyAndVisible];
    
    //监听网络变化
    [[SuNetworkMonitor monitor] startMonitorNetwork];
    
    //友盟统计
    NSString *version = [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleShortVersionString"];
    [MobClick setAppVersion:version];
    
    UMConfigInstance.appKey = @"537ea0ea56240bc90704eae0";
    UMConfigInstance.channelId = @"App Store";
    
    [MobClick startWithConfigure:UMConfigInstance];
    
    UIView *view = [bofangVC shareInstance].view;
    view.frame = CGRectMake(0, IPHONE_H, IPHONE_W, IPHONE_H);
    //    [self.window addSubview:view];
    
    [[UIApplication sharedApplication] beginReceivingRemoteControlEvents];
    
    UIDevice* device = [UIDevice currentDevice];
    if ([device respondsToSelector:@selector(isMultitaskingSupported)]) {
        if(device.multitaskingSupported) {
            NSLog(@"background supported");
            
            AVAudioSession *audioSession = [AVAudioSession sharedInstance];
            NSError *aError = nil;
            [audioSession setCategory:AVAudioSessionCategoryPlayback error:&aError];
            if(aError){
                NSLog(@"set Category error:%@", [aError description]);
            }
            aError = nil;
            [audioSession setActive:YES error:&aError];
            if(aError){
                NSLog(@"active Category error:%@", [aError description]);
            }
//            audioSession.delegate = [bofangVC shareInstance];//这个在后面会讲到
        }
    }
    
    ExIsKaiShiBoFang = NO;
    if ([[CommonCode readFromUserD:@"isWhatLogin"] isEqualToString:@"QQ"]){
        ExdangqianUser = [CommonCode readFromUserD:@"user_login"];
    }
    else if ([[CommonCode readFromUserD:@"isWhatLogin"] isEqualToString:@"ShouJi"]){
        ExdangqianUser = [CommonCode readFromUserD:@"dangqianUser"];
    }
    else if ([[CommonCode readFromUserD:@"isWhatLogin"] isEqualToString:@"WeiBo"]){
        ExdangqianUser = [CommonCode readFromUserD:@"user_login"];
    }
    else if ([[CommonCode readFromUserD:@"isWhatLogin"] isEqualToString:@"weixin"]){
        ExdangqianUser = [CommonCode readFromUserD:@"user_login"];
    }
    ExTouXiangPath = [[NSHomeDirectory() stringByAppendingPathComponent:@"Documents"] stringByAppendingPathComponent:@"userAvatar.png"];
    ExdangqianUserUid = [CommonCode readFromUserD:@"dangqianUserUid"];
    
    //启动时获取已登录用户的信息、未读消息
    if ([[CommonCode readFromUserD:@"isLogin"]boolValue] == YES) {
        
        //获取个人经验值，听币，金币,签到情况以及个人信息，粉丝数，关注数
        [NetWorkTool getMyuserinfoWithaccessToken:AvatarAccessToken user_id:ExdangqianUserUid  sccess:^(NSDictionary *responseObject) {
            if ([responseObject[@"msg"] isEqualToString:@"获取成功!"]) {
                if ([[CommonCode readFromUserD:@"isWhatLogin"] isEqualToString:@"QQ"]){
                    ExdangqianUser = responseObject[@"results"][@"user_login"];
                }
                else if ([[CommonCode readFromUserD:@"isWhatLogin"] isEqualToString:@"ShouJi"]){
                    ExdangqianUser = responseObject[@"results"][@"user_phone"];
                }
                else if ([[CommonCode readFromUserD:@"isWhatLogin"] isEqualToString:@"WeiBo"]){
                    ExdangqianUser = responseObject[@"results"][@"user_login"];
                }
                else if ([[CommonCode readFromUserD:@"isWhatLogin"] isEqualToString:@"weixin"]){
                    ExdangqianUser = responseObject[@"results"][@"user_login"];
                }
                [CommonCode writeToUserD:[NSString stringWithFormat:@"%@",ExdangqianUser] andKey:@"dangqianUser"];
                [CommonCode writeToUserD:responseObject[@"results"][@"id"] andKey:@"dangqianUserUid"];
                [CommonCode writeToUserD:@(YES) andKey:@"isLogin"];
                [CommonCode writeToUserD:responseObject andKey:@"dangqianUserInfo"];
                //拿到图片
                UIImage *userAvatar = [UIImage imageWithData:[NSData dataWithContentsOfURL:[NSURL URLWithString:USERPHOTOHTTPSTRING(responseObject[@"results"][@"avatar"])]]];
                NSString *path_sandox = NSHomeDirectory();
                //设置一个图片的存储路径
                NSString *avatarPath = [path_sandox stringByAppendingString:@"/Documents/userAvatar.png"];
                //把图片直接保存到指定的路径（同时应该把图片的路径imagePath存起来，下次就可以直接用来取）
                [UIImagePNGRepresentation(userAvatar) writeToFile:avatarPath atomically:YES];
            }
        } failure:^(NSError *error) {
            NSLog(@"%@",error);
        }];
        
        if ([CommonCode readFromUserD:FEEDBACKYMESSAGEREAD] == nil) {
            [CommonCode writeToUserD:@"NO" andKey:FEEDBACKYMESSAGEREAD];
        }
        if ([CommonCode readFromUserD:TINGYOUQUANMESSAGEREAD] == nil) {
            [CommonCode writeToUserD:@"NO" andKey:TINGYOUQUANMESSAGEREAD];
        }
        
        
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

        //获取未读消息数
        dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
        dispatch_group_t group = dispatch_group_create();
        
        dispatch_group_enter(group);
        dispatch_group_async(group, queue, ^{
            [NetWorkTool getFeedbackForMeWithaccessToken:AvatarAccessToken sccess:^(NSDictionary *responseObject) {
                dispatch_group_leave(group);
                if ([responseObject[@"status"] integerValue] == 1) {
                    if ([responseObject[@"results"] isKindOfClass:[NSArray class]]){
                        [CommonCode writeToUserD:responseObject[@"results"] andKey:FEEDBACKFORMEDATAKEY];
                    }
                    else{
                        [CommonCode writeToUserD:nil andKey:FEEDBACKFORMEDATAKEY];
                    }
                }
            } failure:^(NSError *error) {
                dispatch_group_leave(group);
            }];
        });
        dispatch_group_enter(group);
        dispatch_group_async(group, queue, ^{
            [NetWorkTool getNewPromptForMeWithaccessToken:AvatarAccessToken andpage:@"1" andlimit:@"100" sccess:^(NSDictionary *responseObject) {
                dispatch_group_leave(group);
                if ([responseObject[@"status"] integerValue] == 1) {
                    if ([responseObject[@"results"] isKindOfClass:[NSArray class]]){
                        [CommonCode writeToUserD:responseObject[@"results"] andKey:NEWPROMPTFORMEDATAKEY];
                    }
                    else{
                        [CommonCode writeToUserD:nil andKey:NEWPROMPTFORMEDATAKEY];
                    }
                }
            } failure:^(NSError *error) {
                dispatch_group_leave(group);
            }];
        });
        dispatch_group_enter(group);
        dispatch_group_async(group, queue, ^{
            [NetWorkTool getAddcriticismNumWithaccessToken:AvatarAccessToken andpage:@"1" andlimit:@"100" anddate:nil sccess:^(NSDictionary *responseObject) {
                dispatch_group_leave(group);
                if ([responseObject[@"status"] integerValue] == 1) {
                    if ([responseObject[@"results"] isKindOfClass:[NSArray class]]){
                        [CommonCode writeToUserD:responseObject[@"results"] andKey:ADDCRITICISMNUMDATAKEY];
                    }
                    else{
                        [CommonCode writeToUserD:nil andKey:ADDCRITICISMNUMDATAKEY];
                    }
                }
                
            } failure:^(NSError *error) {
                dispatch_group_leave(group);
            }];
        });
        dispatch_group_notify(group, dispatch_get_main_queue(), ^{
            //设置 我 的未读消息
            [[NSNotificationCenter defaultCenter] postNotificationName:@"setMyunreadMessageTips" object:nil];
        });
        
    }
    
    [CommonCode writeToUserD:nil andKey:@"dangqianbofangxinwenID"];
    [CommonCode writeToUserD:nil andKey:@"dangqianbofangxinwen"];
    
    
    [CommonCode writeToUserD:@"NO" andKey:@"isPlayingVC"];
    [CommonCode writeToUserD:@"YES" andKey:@"isPlayingGray"];
    [CommonCode writeToUserD:@"NO" andKey:TINGYOUQUANBOFANGWANBI];
    //手势控制
    [[NSUserDefaults standardUserDefaults] setBool:NO forKey:@"shoushi"];
    //手势提醒
    [[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"shoushitixing"];
    
    //注册QQ
    [[TencentOAuth alloc] initWithAppId:kAppId_QQ andDelegate:self];
    //注册微信
    [WXApi registerApp:KweChatappID];
    
    //设置新浪微博
    [WeiboSDK enableDebugMode:YES];
    [WeiboSDK registerApp:KweiBoappkey];
    
    
    //设置app的友盟appKey
    //打开调试日志
//    [[UMSocialManager defaultManager] openLog:YES];
//    //设置友盟appkey
//    [[UMSocialManager defaultManager] setUmSocialAppkey:KuMappKey];
    //设置微信的appKey和appSecret
//    [[UMSocialManager defaultManager] setPlaform:UMSocialPlatformType_WechatSession appKey:KweChatappID appSecret:KweChatappSecret redirectURL:@"http://mobile.umeng.com/social"];
//    //设置分享到QQ互联的appKey和appSecret
//    // U-Share SDK为了兼容大部分平台命名，统一用appKey和appSecret进行参数设置，而QQ平台仅需将appID作为U-Share的appKey参数传进即可。
//    [[UMSocialManager defaultManager] setPlaform:UMSocialPlatformType_QQ appKey:kAppId_QQ  appSecret:nil redirectURL:@"http://mobile.umeng.com/social"];
//    //设置新浪的appKey和appSecret
//    [[UMSocialManager defaultManager] setPlaform:UMSocialPlatformType_Sina appKey:KweiBoappkey  appSecret:KweiBoappSecret redirectURL:KweiBoUrl];
    
    
    //小米推送
    [self setMIPush];
    
    //注册远程通知
//    if ([[UIDevice currentDevice].systemVersion floatValue] < 8.0)
//    {
//        UIRemoteNotificationType type = UIRemoteNotificationTypeAlert | UIRemoteNotificationTypeBadge | UIRemoteNotificationTypeSound;
//        
//        [application registerForRemoteNotificationTypes:type];
//    }
//    else
//    {
//        UIUserNotificationType type = UIUserNotificationTypeAlert | UIUserNotificationTypeBadge | UIUserNotificationTypeSound;
//        
//        UIUserNotificationSettings *setting = [UIUserNotificationSettings settingsForTypes:type categories:nil];
//        
//        [application registerUserNotificationSettings:setting];
//        
//    }
    
    //推送唤醒APP的
    NSDictionary *userInfo = launchOptions[UIApplicationLaunchOptionsRemoteNotificationKey];
    if (userInfo) {
        NSString *newsID  = userInfo[@"id"];
        [[NSUserDefaults standardUserDefaults] setValue:newsID forKey:@"pushNews"];
//        [[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"isPush"];
        [[NSUserDefaults standardUserDefaults] synchronize];
        //跳转到通知的新闻详情
        [[NSNotificationCenter defaultCenter] postNotificationName:@"pushNewsDetail" object:newsID];
    }
    
    [[UIApplication sharedApplication]cancelAllLocalNotifications];
    
    [NSThread sleepForTimeInterval:2.0f];//设置启动页面时间
    
    [[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"sevaDownload"];
    [[NSUserDefaults standardUserDefaults]synchronize];
    
    //自动处理键盘事件的第三方库
    IQKeyboardManager *manager = [IQKeyboardManager sharedManager];
    manager.enable = YES;//控制整个功能是否启用
    manager.shouldResignOnTouchOutside = YES;//控制点击背景是否收起键盘
    manager.shouldToolbarUsesTextFieldTintColor = YES;//控制键盘上的工具条文字颜色是否用户自定义
    manager.enableAutoToolbar = NO;//控制是否显示键盘上的工具条
    [manager setKeyboardDistanceFromTextField:0];
    
    NSError* error;
    [[AVAudioSession sharedInstance] setCategory:AVAudioSessionCategoryPlayback error:&error];

    return YES;
}


- (BOOL)application:(UIApplication *)application openURL:(NSURL *)url sourceApplication:(NSString *)sourceApplication annotation:(id)annotation{
    
    if ([url.host isEqualToString:@"safepay"]) {
        // 支付跳转支付宝钱包进行支付，处理支付结果
        [[AlipaySDK defaultService] processOrderWithPaymentResult:url standbyCallback:^(NSDictionary *resultDic) {
            NSLog(@"result = %@",resultDic);
            if (APPDELEGATE.isReward) {
                [[NSNotificationCenter defaultCenter] postNotificationName:@"AliPayResults" object:resultDic];
            }
            else{
                [[NSNotificationCenter defaultCenter] postNotificationName:@"RechargeAliPayResults" object:resultDic];
            }
            
        }];
        
        // 授权跳转支付宝钱包进行支付，处理支付结果
        [[AlipaySDK defaultService] processAuth_V2Result:url standbyCallback:^(NSDictionary *resultDic) {
            // 解析 auth code
            NSString *result = resultDic[@"result"];
            NSString *authCode = nil;
            if (result.length>0) {
                NSArray *resultArr = [result componentsSeparatedByString:@"&"];
                for (NSString *subResult in resultArr) {
                    if (subResult.length > 10 && [subResult hasPrefix:@"auth_code="]) {
                        authCode = [subResult substringFromIndex:10];
                        break;
                    }
                }
            }
            NSLog(@"授权结果 authCode = %@", authCode?:@"");
        }];
        return YES;
    }
    NSString *string = [url absoluteString];
    //处理通过URL启动听闻
    if ([string hasPrefix:@"tingwen"]) {
        return YES;
    }
    else if ([string hasPrefix:@"tencent"] || [string hasPrefix:@"QQ"]) {
        return [QQApiInterface handleOpenURL:url delegate:self];
//        return [TencentOAuth HandleOpenURL:url];

    }
    else if ([string hasPrefix:@"wx"]){
        return [WXApi handleOpenURL:url delegate:self];
    }
    else {
        return [WeiboSDK handleOpenURL:url delegate:self];
    }

}
- (BOOL)application:(UIApplication *)application handleOpenURL:(NSURL *)url{
    
    if ([url.host isEqualToString:@"safepay"]) {
        // 支付跳转支付宝钱包进行支付，处理支付结果
        [[AlipaySDK defaultService] processOrderWithPaymentResult:url standbyCallback:^(NSDictionary *resultDic) {
            if (APPDELEGATE.isReward) {
                [[NSNotificationCenter defaultCenter] postNotificationName:@"AliPayResults" object:resultDic];
            }
            else{
                [[NSNotificationCenter defaultCenter] postNotificationName:@"RechargeAliPayResults" object:resultDic];
            }
            
        }];
        
        // 授权跳转支付宝钱包进行支付，处理支付结果
        [[AlipaySDK defaultService] processAuth_V2Result:url standbyCallback:^(NSDictionary *resultDic) {
            NSLog(@"result = %@",resultDic);
            // 解析 auth code
            NSString *result = resultDic[@"result"];
            NSString *authCode = nil;
            if (result.length>0) {
                NSArray *resultArr = [result componentsSeparatedByString:@"&"];
                for (NSString *subResult in resultArr) {
                    if (subResult.length > 10 && [subResult hasPrefix:@"auth_code="]) {
                        authCode = [subResult substringFromIndex:10];
                        break;
                    }
                }
            }
            NSLog(@"授权结果 authCode = %@", authCode?:@"");
        }];
        return YES;
    }
    NSString *string  = [url absoluteString];
    //处理通过URL启动听闻
    if ([string hasPrefix:@"tingwen"]) {
        return YES;
    }
    else if ([string hasPrefix:@"tencent"] | [string hasPrefix:@"QQ"]) {
        
        return [QQApiInterface handleOpenURL:url delegate:self];
    }
    else if([string hasPrefix:@"wx"]){
        return [WXApi handleOpenURL:url delegate:self];
    }
    else{
        return [WeiboSDK handleOpenURL:url delegate:self];
    }
    

}

//#define __IPHONE_10_0    100000
//#if __IPHONE_OS_VERSION_MAX_ALLOWED > 100000

// NOTE: 9.0以后使用新API接口
- (BOOL)application:(UIApplication *)app openURL:(NSURL *)url options:(NSDictionary<UIApplicationOpenURLOptionsKey, id> *)options
{
    BOOL result = [[UMSocialManager defaultManager] handleOpenURL:url];
    if (!result) {
        // 其他如支付等SDK的回调
        if ([url.host isEqualToString:@"safepay"]) {
            // 支付跳转支付宝钱包进行支付，处理支付结果
            [[AlipaySDK defaultService] processOrderWithPaymentResult:url standbyCallback:^(NSDictionary *resultDic) {
                if (APPDELEGATE.isReward) {
                    [[NSNotificationCenter defaultCenter] postNotificationName:@"AliPayResults" object:resultDic];
                }
                else{
                    [[NSNotificationCenter defaultCenter] postNotificationName:@"RechargeAliPayResults" object:resultDic];
                }
                
            }];
            
            // 授权跳转支付宝钱包进行支付，处理支付结果
            [[AlipaySDK defaultService] processAuth_V2Result:url standbyCallback:^(NSDictionary *resultDic) {
                NSLog(@"result = %@",resultDic);
                // 解析 auth code
                NSString *result = resultDic[@"result"];
                NSString *authCode = nil;
                if (result.length>0) {
                    NSArray *resultArr = [result componentsSeparatedByString:@"&"];
                    for (NSString *subResult in resultArr) {
                        if (subResult.length > 10 && [subResult hasPrefix:@"auth_code="]) {
                            authCode = [subResult substringFromIndex:10];
                            break;
                        }
                    }
                }
                NSLog(@"授权结果 authCode = %@", authCode?:@"");
            }];
            return YES;
        }
        NSString *string  = [url absoluteString];
        //处理通过URL启动听闻
        if ([string hasPrefix:@"tingwen"]) {
            return YES;
        }
        else if ([string hasPrefix:@"tencent"] | [string hasPrefix:@"QQ"]) {
            return [TencentOAuth HandleOpenURL:url];
//            return [QQApiInterface handleOpenURL:url delegate:self];
        }
        else if([string hasPrefix:@"wx"]){
            return [WXApi handleOpenURL:url delegate:self];
        }
        else{
            return [WeiboSDK handleOpenURL:url delegate:self];
        }
    }
    return result;
}

- (void)applicationWillResignActive:(UIApplication *)application {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
    
    [UIApplication sharedApplication].applicationIconBadgeNumber = 0;
    
    //MBAudioPlayer是我为播放器写的单例，这段就是当音乐还在播放状态的时候，给后台权限，不在播放状态的时候，收回后台权限
    if ([bofangVC shareInstance].isPlay) {
        //有音乐播放时，才给后台权限，不做流氓应用。
        [[UIApplication sharedApplication] beginReceivingRemoteControlEvents];
        [self becomeFirstResponder];
        
        [[bofangVC shareInstance] configNowPlayingInfoCenter];
    }
    else
    {
        [[UIApplication sharedApplication] endReceivingRemoteControlEvents];
        [self resignFirstResponder];
    }
}


- (BOOL)canBecomeFirstResponder{
    return YES;
}

- (void)applicationWillEnterForeground:(UIApplication *)application {
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
    if ([bofangVC shareInstance].isPlay) {
        [[NSNotificationCenter defaultCenter] postNotificationName:@"startAnimate" object:nil];
    }
    else{
        [[NSNotificationCenter defaultCenter] postNotificationName:@"stopAnimate" object:nil];
    }
    
    [UIApplication sharedApplication].applicationIconBadgeNumber = 0;
    if ([[CommonCode readFromUserD:@"isWhatLogin"] isEqualToString:@"QQ"]){
        ExdangqianUser = [CommonCode readFromUserD:@"user_login"];
    }
    else if ([[CommonCode readFromUserD:@"isWhatLogin"] isEqualToString:@"ShouJi"]){
        ExdangqianUser = [CommonCode readFromUserD:@"dangqianUser"];
    }
    else if ([[CommonCode readFromUserD:@"isWhatLogin"] isEqualToString:@"WeiBo"]){
        ExdangqianUser = [CommonCode readFromUserD:@"user_login"];
    }
    else if ([[CommonCode readFromUserD:@"isWhatLogin"] isEqualToString:@"weixin"]){
        ExdangqianUser = [CommonCode readFromUserD:@"user_login"];
    }
    
    NSLog(@"%@",ExdangqianUser);
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application {
    
    NSInteger count = (NSInteger)[CommonCode readFromUserD:@"topNameArr.count"];
    
    NSArray *arr = [NSArray arrayWithArray:[CommonCode readFromUserD:@"topNameArr"]];
    
    for (int i = 0; i < count; i ++ )
    {
        if (arr.count>=count) {
            [CommonCode writeToUserD:@"1" andKey:[NSString stringWithFormat:@"page%@",arr[i][@"type"]]];//数组越界需要解决，导致崩溃
        }
    }
    
    [CommonCode writeToUserD:nil andKey:@"dangqianbofangxinwenID"];
    [CommonCode writeToUserD:nil andKey:@"dangqianbofangxinwen"];

}

- (void)applicationDidEnterBackground:(UIApplication *)application {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    
    
    UIApplication*   app = [UIApplication sharedApplication];
    
    __block  UIBackgroundTaskIdentifier bgTask;
    
    bgTask  = [app beginBackgroundTaskWithExpirationHandler:^{
        [app endBackgroundTask:bgTask];
        bgTask  = UIBackgroundTaskInvalid;
        dispatch_async(dispatch_get_main_queue(), ^{
            
            if (bgTask != UIBackgroundTaskInvalid){
                
                bgTask = UIBackgroundTaskInvalid;
                
            }
            
        });
        
    }];
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        
        dispatch_async(dispatch_get_main_queue(), ^{
            
            if (bgTask != UIBackgroundTaskInvalid){
                
                bgTask = UIBackgroundTaskInvalid;
                
            }
            [app endBackgroundTask:bgTask];
            bgTask   = UIBackgroundTaskInvalid;
            
            if ([TimerViewController defaultTimerViewController].sw.on) {
                [[TimerViewController defaultTimerViewController].timer fire];
            }
        });
        
    });
}

- (void)remoteControlReceivedWithEvent:(UIEvent *)event {
    //后台播放控制事件， 在此处设置对应的控制器进行相应
    [[bofangVC shareInstance ] remoteControlReceivedWithEvent:event];
}

//
//#pragma mark -QQApiInterfaceDelegate
///**
// 处理来至QQ的请求
// */
//- (void)onReq:(QQBaseReq *)req{
//    
//}
//
///**
// 处理来至QQ的响应
// */
//- (void)onResp:(QQBaseResp *)resp{
//    
//}


#pragma mark - WXApiDelegate
/*! @brief 收到一个来自微信的请求，第三方应用程序处理完后调用sendResp向微信发送结果
 *
 * 收到一个来自微信的请求，异步处理完成后必须调用sendResp发送处理结果给微信。
 * 可能收到的请求有GetMessageFromWXReq、ShowMessageFromWXReq等。
 * @param req 具体请求内容，是自动释放的
 */
-(void)onReq:(BaseReq*)req{
    NSLog(@"%@",req);
}

/*! @brief 发送一个sendReq后，收到微信的回应
 *
 * 收到一个来自微信的处理结果。调用一次sendReq后会收到onResp。
 * 可能收到的处理结果有SendMessageToWXResp、SendAuthResp等。
 * @param resp具体的回应内容，是自动释放的
 */
-(void)onResp:(BaseResp*)resp{
    NSLog(@"%d",resp.errCode);
    // SendMessageToQQResp应答帮助类
    if ([resp.class isSubclassOfClass: [SendMessageToQQResp class]]) {  //QQ分享回应
        if (_qqDelegate) {
            if ([_qqDelegate respondsToSelector:@selector(shareSuccssWithQQCode:)]) {
                SendMessageToQQResp *msg = (SendMessageToQQResp *)resp;
                NSLog(@"%@",resp);
//                NSLog(@"code %@  errorDescription %@  infoType %@",resp.result,resp.errorDescription,resp.extendInfo);
                [_qqDelegate shareSuccssWithQQCode:[msg.result integerValue]];
            }
        }
    }
    else if ([resp isKindOfClass:[PayResp class]]){
        PayResp*response=(PayResp*)resp;
        switch(response.errCode){
            case WXSuccess:{
                //服务器端查询支付通知或查询API返回的结果再提示成功
                NSLog(@"支付成功");
                
                //注册微信
                [WXApi registerApp:KweChatappID];
            }
                break;
            default:{
                //注册微信
                [WXApi registerApp:KweChatappID];
            
                NSLog(@"支付失败，retcode=%d",resp.errCode);
            }
                break;
        }
        if (APPDELEGATE.isReward) {
             [[NSNotificationCenter defaultCenter] postNotificationName:@"WechatPayResults" object:@(resp.errCode)];
        }
        else{
            [[NSNotificationCenter defaultCenter] postNotificationName:@"RechargeWechatPayResults" object:@(resp.errCode)];
        }
        
    }
    else if ([resp isKindOfClass:[SendAuthResp class]]){
        
        SendAuthResp *response = (SendAuthResp*)resp;
        if (response.errCode == 0) {
            //微信授权成功
            if (self.wechatGetLoginCode) {
                self.wechatGetLoginCode(response.code);
            }
        }
        
        
    }
}

#pragma mark - WeiboSDKDelegate

- (void)didReceiveWeiboRequest:(WBBaseRequest *)request{
    
    if ([request isKindOfClass:WBProvideMessageForWeiboRequest.class]) {
        // view *controller = [[ProvideMessageForWeiboViewController alloc] init];
        // [self.viewController presentModalViewController:controller animated:YES];      NSLog(@"logs is sina");
    }
}

- (void)didReceiveWeiboResponse:(WBBaseResponse *)response {
    if (response.userInfo) {
        if (self.weibologinSuccess) {
            self.weibologinSuccess(response.userInfo);
        }
//        return;
    }
    if ([response isKindOfClass:WBSendMessageToWeiboResponse.class]) {
//        switch (response.statusCode) {
//                
//            case WeiboSDKResponseStatusCodeSuccess: {//成功
                //                NSArray *a = [SQLClass selectListName:kUserLsit withClass:[UserClass class]];
                //
                //                UserClass *user = [a lastObject];
                //                NSString *acc = [DES encryptUseDES:user.user_login];
                //                //                [JDStatusBarNotification showWithStatus:@"分享微博成功" dismissAfter:1.f];
                //                XWAlerLoginView *xw = [[XWAlerLoginView alloc]initWithTitle:@"分享微博成功"];
                //                [xw show];
                //                [NetworkingMangater netwokingPost:@"shareLog" andParameters:@{@"accessToken" : acc, @"object_id" : shareObj.i_id} success:^(id obj) {
                //
                //                }];
//            }
//        }
        
    }
    else if([response isKindOfClass:WBAuthorizeResponse.class])
    {
        if ((int)response.statusCode == 0)
        {
            NSDictionary *dic = @{@"userID":[(WBAuthorizeResponse *)response userID], @"accessToken" :[(WBAuthorizeResponse *)response accessToken]};
            NSLog(@"weibo_dic = %@",dic);
        }
    }
    
}


#pragma mark - MiPushSDKDelegate

- (void)setMIPush {
    [MiPushSDK registerMiPush:self type:UIUserNotificationTypeAlert|UIUserNotificationTypeBadge|UIUserNotificationTypeSound connect:YES];
}

/**
 *  请求成功调用
 *
 */
- (void)miPushRequestSuccWithSelector:(NSString *)selector data:(NSDictionary *)data {
    //设置小米推送的客户端别名
//    [MiPushSDK setAlias:@"15280855339"];
    if ([selector isEqualToString:@"bindDeviceToken:"]) {
        NSLog(@"regid = %@",data[@"regid"]);
    }
}

/**
 *  请求失败调用
 *
 */
- (void)miPushRequestErrWithSelector:(NSString *)selector error:(int)error data:(NSDictionary *)data {
    
}
/**
 *  接收推送数据
 *
 */
- (void)miPushReceiveNotification:(NSDictionary *)data
{
    
}
#pragma mark - UIApplicationDelegate 推送相关

-(void)application:(UIApplication *)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken {
    // 注册APNS成功, 注册deviceToken
    [MiPushSDK bindDeviceToken:deviceToken];
}

- (void)application:(UIApplication *)application didFailToRegisterForRemoteNotificationsWithError:(NSError *)error {
    // 注册APNS失败.
    // 自行处理.
    NSLog(@"error: %@", [error localizedDescription]);
}

- (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo {
    //小米统计客户端 通过push开启app行为
    NSString *messageId  = [userInfo objectForKey:@"_id_"];
    [MiPushSDK openAppNotify:messageId];
    //获取新闻id
    NSString *newsID  = userInfo[@"id"];
    [[NSUserDefaults standardUserDefaults] setValue:newsID forKey:@"pushNews"];
    [[NSUserDefaults standardUserDefaults] synchronize];
    //当程序启动的时候，不执行跳转
    if (application.applicationState == UIApplicationStateActive) {
        return;
    }
    
    //跳转到通知的新闻详情
    [[NSNotificationCenter defaultCenter] postNotificationName:@"pushNewsDetail" object:newsID];
}
// 点击通知进入应用iOS7+
- (void)application:(UIApplication *)application
didReceiveRemoteNotification:(NSDictionary *)userInfo
fetchCompletionHandler:(void (^)(UIBackgroundFetchResult))completionHandler{
    //小米统计客户端 通过push开启app行为
    NSString *messageId  = [userInfo objectForKey:@"_id_"];
    [MiPushSDK openAppNotify:messageId];
    //获取新闻id
    NSString *newsID  = userInfo[@"id"];
    [[NSUserDefaults standardUserDefaults] setValue:newsID forKey:@"pushNews"];
    [[NSUserDefaults standardUserDefaults] synchronize];
    //当程序启动的时候，不执行跳转
    if (application.applicationState == UIApplicationStateActive) {
        return;
    }
    
    //跳转到通知的新闻详情
    [[NSNotificationCenter defaultCenter] postNotificationName:@"pushNewsDetail" object:newsID];
}
// 点击通知进入应用iOS10+
- (void)userNotificationCenter:(UNUserNotificationCenter *)center didReceiveNotificationResponse:(UNNotificationResponse *)response withCompletionHandler:(void (^)())completionHandler {
    NSDictionary * userInfo = response.notification.request.content.userInfo;
    if([response.notification.request.trigger isKindOfClass:[UNPushNotificationTrigger class]]) {
        //小米统计客户端 通过push开启app行为
        NSString *messageId  = [userInfo objectForKey:@"_id_"];
        [MiPushSDK openAppNotify:messageId];
        //获取新闻id
        NSString *newsID  = userInfo[@"id"];
        [[NSUserDefaults standardUserDefaults] setValue:newsID forKey:@"pushNews"];
        [[NSUserDefaults standardUserDefaults] synchronize];
        //当程序启动的时候，不执行跳转
        if ([UIApplication sharedApplication].applicationState == UIApplicationStateActive) {
            return;
        }
        
        //跳转到通知的新闻详情
        [[NSNotificationCenter defaultCenter] postNotificationName:@"pushNewsDetail" object:newsID];
    }
    completionHandler();
}
#pragma mark - 获取未读消息相关

- (void)getUserFriendShareNum {
    [NetWorkTool getAddcriticismNumWithaccessToken:AvatarAccessToken andpage:@"1" andlimit:@"100" anddate:nil sccess:^(NSDictionary *responseObject) {
        if ([responseObject[@"status"] integerValue] == 1) {
            if ([responseObject[@"results"] isKindOfClass:[NSArray class]]){
                [CommonCode writeToUserD:responseObject[@"results"] andKey:ADDCRITICISMNUMDATAKEY];
            }
            else{
                [CommonCode writeToUserD:nil andKey:ADDCRITICISMNUMDATAKEY];
            }
        }
        
    } failure:^(NSError *error) {
        //
    }];
}

- (void)getFeedbackForMe {
    [NetWorkTool getFeedbackForMeWithaccessToken:AvatarAccessToken sccess:^(NSDictionary *responseObject) {
        if ([responseObject[@"status"] integerValue] == 1) {
            if ([responseObject[@"results"] isKindOfClass:[NSArray class]]){
                [CommonCode writeToUserD:responseObject[@"results"] andKey:FEEDBACKFORMEDATAKEY];
            }
            else{
                [CommonCode writeToUserD:nil andKey:FEEDBACKFORMEDATAKEY];
            }
        }
    } failure:^(NSError *error) {
        //
    }];
}

- (void)getNewPromptForMe {
    [NetWorkTool getNewPromptForMeWithaccessToken:AvatarAccessToken andpage:@"1" andlimit:@"100" sccess:^(NSDictionary *responseObject) {
        if ([responseObject[@"status"] integerValue] == 1) {
            if ([responseObject[@"results"] isKindOfClass:[NSArray class]]){
                [CommonCode writeToUserD:responseObject[@"results"] andKey:NEWPROMPTFORMEDATAKEY];
            }
            else{
                [CommonCode writeToUserD:nil andKey:NEWPROMPTFORMEDATAKEY];
            }
        }
    } failure:^(NSError *error) {
        //
    }];
}

@end
