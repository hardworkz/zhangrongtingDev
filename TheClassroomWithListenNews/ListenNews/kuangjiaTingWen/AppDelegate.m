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
#import "GDTTrack.h"
#import "AvoidCrash.h"

@interface AppDelegate ()<WeiboSDKDelegate,WXApiDelegate,QQApiInterfaceDelegate,MiPushSDKDelegate,UNUserNotificationCenterDelegate>
{
    //后台播放任务Id
    UIBackgroundTaskIdentifier _bgTaskId;
    NSTimer *timer;
}
@end

@implementation AppDelegate

@synthesize splash = _splash;

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
- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    
    self.window = [[UIWindow alloc] initWithFrame:[UIScreen mainScreen].bounds];
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        //开屏广告初始化并展示代码
        GDTSplashAd *splashAd;
        if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone)
        {
            splashAd = [[GDTSplashAd alloc] initWithAppkey:GDTAppKey placementId:GDTPlacementId];
            splashAd.delegate = self;//设置代理1ez
            //针对不同设备尺寸设置不同的默认图片，拉取广告等待时间会展示该默认图片。
            //        if ([[UIScreen mainScreen] bounds].size.height >= 568.0f) {
            //            splashAd.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"LaunchImage-1-568h"]];
            //        } else {
            //            splashAd.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"LaunchImage-1"]];
            //        }
            //跳过按钮位置
            //        splashAd.skipButtonCenter = CGPointMake(0, 0);
            //设置开屏拉取时长限制，若超时则不再展示广告
            splashAd.fetchDelay = 3;
            //［可选］拉取并展示全屏开屏广告
            //[splashAd loadAdAndShowInWindow:self.window];
            //设置开屏底部自定义LogoView，展示半屏开屏广告
            _bottomView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, [[UIScreen mainScreen] bounds].size.width, 100)];
            UIImageView *logo = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"flash_slogen"]];
            [_bottomView addSubview:logo];
            logo.center = _bottomView.center;
            _bottomView.backgroundColor = [UIColor whiteColor];
            self.splash = splashAd;
        }
        /* 使用GCD返回主线程 进行UI层面的赋值 */
        
        dispatch_async(dispatch_get_main_queue(), ^{
            //添加开屏广告空间到窗口
            [self.splash loadAdAndShowInWindow:self.window withBottomView:_bottomView];
        });
    });
    
    
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
    
    
    [[UIApplication sharedApplication] beginReceivingRemoteControlEvents];
    
    //判断当前系统是否支持多任务处理
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
        }
    }
    
    ExIsKaiShiBoFang = NO;
    RTLog(@"%@",[CommonCode readFromUserD:@"isWhatLogin"]);
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
    
    //初始化播放器和播放控制器
    [ZRT_PlayerManager manager];
    [NewPlayVC shareInstance].view.backgroundColor = [UIColor whiteColor];
    
    //获取缓存的课堂ID，判断当前ID是否有值，没有值则不跳转课堂试听页面
    Exact_id = [CommonCode readFromUserD:@"Exact_id"];
    
    //获取app版本
    [self getAppVersion];
    //获取VIP限制
    [self getVipLimitData];
    //启动时获取已登录用户的信息、未读消息
    [self getUserLoginInfoWithLoginStatus:[[CommonCode readFromUserD:@"isLogin"] boolValue]];
    
    [CommonCode writeToUserD:nil andKey:@"dangqianbofangxinwenID"];
    [CommonCode writeToUserD:nil andKey:@"dangqianbofangxinwen"];
    
    
    [CommonCode writeToUserD:@"NO" andKey:@"isPlayingVC"];
    [CommonCode writeToUserD:@"YES" andKey:@"isPlayingGray"];
    [CommonCode writeToUserD:@"NO" andKey:TINGYOUQUANBOFANGWANBI];
    //手势控制
    [[NSUserDefaults standardUserDefaults] setBool:NO forKey:@"shoushi"];
    
    //注册QQ
    [[TencentOAuth alloc] initWithAppId:kAppId_QQ andDelegate:self];
    //注册微信
    [WXApi registerApp:KweChatappID];
    
    //设置新浪微博
    [WeiboSDK enableDebugMode:YES];
    [WeiboSDK registerApp:KweiBoappkey];
    
    //小米推送
    [self setMIPush];
    
    
    //推送唤醒APP的
    NSDictionary *userInfo = launchOptions[UIApplicationLaunchOptionsRemoteNotificationKey];
    if (userInfo) {
        NSString *newsID  = userInfo[@"id"];
        [[NSUserDefaults standardUserDefaults] setValue:newsID forKey:@"pushNews"];
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
    
    [self avoidCrash];

    return YES;
}
- (void)avoidCrash
{
    //全局启动崩溃预防
    [AvoidCrash becomeEffective];
    //监听崩溃的信息通知
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(dealwithCrashMessage:) name:AvoidCrashNotification object:nil];
}
- (void)dealwithCrashMessage:(NSNotification *)note {
    //注意:所有的信息都在userInfo中
    //你可以在这里收集相应的崩溃信息进行相应的处理(比如传到自己服务器)
    NSLog(@"%@",note.userInfo);
}

/**
 获取每日免费收听数以及当前系统时间
 */
- (void)getVipLimitData
{
    [NetWorkTool get_VipLimitDataWithSccess:^(NSDictionary *responseObject) {
        RTLog(@"%@",responseObject);
        if ([responseObject[status] intValue] == 1) {
            [NetWorkTool isNewDayWithServer_date:responseObject[results][@"date"]];
            [CommonCode writeToUserD:responseObject[results][@"num"] andKey:limit_num];
        }
    } failure:^(NSError *error) {
        
    }];
}
- (void)getAppVersion
{
    //请求是否为内购的接口
    [NetWorkTool getAppVersionSccess:^(NSDictionary *responseObject) {
        RTLog(@"%@",responseObject);
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

/**
 获取用户数据

 @param isLogin 是否已经登录
 */
- (void)getUserLoginInfoWithLoginStatus:(BOOL)isLogin
{
    if (isLogin) {
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
}
- (BOOL)application:(UIApplication *)application openURL:(NSURL *)url sourceApplication:(NSString *)sourceApplication annotation:(id)annotation{
    
    if ([url.host isEqualToString:@"safepay"]) {
        // 支付跳转支付宝钱包进行支付，处理支付结果
        [[AlipaySDK defaultService] processOrderWithPaymentResult:url standbyCallback:^(NSDictionary *resultDic) {
            NSLog(@"result = %@",resultDic);
            switch (_payType) {
                case PayTypeClassPay:
                    [[NSNotificationCenter defaultCenter] postNotificationName:AliPayResultsClass object:resultDic];
                    break;
                case PayTypeReward:
                    [[NSNotificationCenter defaultCenter] postNotificationName:AliPayResultsReward object:resultDic];
                    break;
                case PayTypeRecharge:
                    [[NSNotificationCenter defaultCenter] postNotificationName:AliPayResultsRecharge object:resultDic];
                    break;
                case PayTypeMembers:
                    [[NSNotificationCenter defaultCenter] postNotificationName:AliPayResultsMembers object:resultDic];
                    break;
                    
                default:
                    break;
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
            switch (_payType) {
                case PayTypeClassPay:
                    [[NSNotificationCenter defaultCenter] postNotificationName:AliPayResultsClass object:resultDic];
                    break;
                case PayTypeReward:
                    [[NSNotificationCenter defaultCenter] postNotificationName:AliPayResultsReward object:resultDic];
                    break;
                case PayTypeRecharge:
                    [[NSNotificationCenter defaultCenter] postNotificationName:AliPayResultsRecharge object:resultDic];
                    break;
                case PayTypeMembers:
                    [[NSNotificationCenter defaultCenter] postNotificationName:AliPayResultsMembers object:resultDic];
                    break;
                    
                default:
                    break;
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
                switch (_payType) {
                    case PayTypeClassPay:
                        [[NSNotificationCenter defaultCenter] postNotificationName:AliPayResultsClass object:resultDic];
                        break;
                    case PayTypeReward:
                        [[NSNotificationCenter defaultCenter] postNotificationName:AliPayResultsReward object:resultDic];
                        break;
                    case PayTypeRecharge:
                        [[NSNotificationCenter defaultCenter] postNotificationName:AliPayResultsRecharge object:resultDic];
                        break;
                    case PayTypeMembers:
                        [[NSNotificationCenter defaultCenter] postNotificationName:AliPayResultsMembers object:resultDic];
                        break;
                        
                    default:
                        break;
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
    
    
    [UIApplication sharedApplication].applicationIconBadgeNumber = 0;
    
    //MBAudioPlayer是我为播放器写的单例，这段就是当音乐还在播放状态的时候，给后台权限，不在播放状态的时候，收回后台权限
    //获取开始线控权限
    [[UIApplication sharedApplication] beginReceivingRemoteControlEvents];
    //成为第一响应者才能获取线控权限
    [self becomeFirstResponder];
}
//是否成为第一响应者
- (BOOL)canBecomeFirstResponder{
    return YES;
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
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
    [GDTTrack activateApp];
}

- (void)applicationWillTerminate:(UIApplication *)application {
    
    //应用退出时保存已听过新闻ID
    [CommonCode writeToUserD:[NewPlayVC shareInstance].listenedNewsIDArray andKey:yitingguoxinwenID];
    //清空当前本地缓存的播放新闻，播放新闻ID
    [CommonCode writeToUserD:nil andKey:@"dangqianbofangxinwenID"];
    [CommonCode writeToUserD:nil andKey:@"dangqianbofangxinwen"];
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    
    [[UIApplication sharedApplication] beginReceivingRemoteControlEvents];
    [self becomeFirstResponder];
    
    //应用退出时保存已听过新闻ID
    [CommonCode writeToUserD:[NewPlayVC shareInstance].listenedNewsIDArray andKey:yitingguoxinwenID];
    
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
            
            if (_bgTaskId != UIBackgroundTaskInvalid){
                
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
#pragma mark - NowPlayingCenter & Remote Control
- (void)configNowPlayingCenter
{
    if ([ZRT_PlayerManager manager].playType != ZRTPlayTypeClassroomTry) {
        if([[SDWebImageManager sharedManager] cachedImageExistsForURL:[NSURL URLWithString:[ZRT_PlayerManager manager].currentCoverImage]]){
            UIImage* img = [[SDWebImageManager sharedManager].imageCache imageFromMemoryCacheForKey:[[SDWebImageManager sharedManager] cacheKeyForURL:[NSURL URLWithString:[ZRT_PlayerManager manager].currentCoverImage]]];
            
            if(!img)
                img = [[SDWebImageManager sharedManager].imageCache imageFromDiskCacheForKey:[[SDWebImageManager sharedManager] cacheKeyForURL:[NSURL URLWithString:[ZRT_PlayerManager manager].currentCoverImage]]];
            NSMutableDictionary * playingCenterInfo = [NSMutableDictionary dictionary];
            [playingCenterInfo setObject:[ZRT_PlayerManager manager].currentSong[@"post_title"]?[ZRT_PlayerManager manager].currentSong[@"post_title"]:@"" forKey:MPMediaItemPropertyTitle];
            [playingCenterInfo setObject:[ZRT_PlayerManager manager].currentSong[@"post_act"][@"name"]?[ZRT_PlayerManager manager].currentSong[@"post_act"][@"name"]:@"" forKey:MPMediaItemPropertyArtist];
            [playingCenterInfo setObject:@(1) forKey:MPNowPlayingInfoPropertyPlaybackRate];
            [playingCenterInfo setObject:@([ZRT_PlayerManager manager].duration) forKey:MPMediaItemPropertyPlaybackDuration];
            MPMediaItemArtwork * artwork = [[MPMediaItemArtwork alloc] initWithImage:img?img:[UIImage imageNamed:@"thumbnailsdefault"]];
            [playingCenterInfo setObject:artwork forKey:MPMediaItemPropertyArtwork];
            [[MPNowPlayingInfoCenter defaultCenter] setNowPlayingInfo:playingCenterInfo];
            
        }else{
            [[SDWebImageManager sharedManager] downloadImageWithURL:[NSURL URLWithString:[ZRT_PlayerManager manager].currentCoverImage] options:SDWebImageRetryFailed|SDWebImageLowPriority progress:nil completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, BOOL finished, NSURL *imageURL) {
                if (image) {
                    NSMutableDictionary * playingCenterInfo = [NSMutableDictionary dictionary];
                    [playingCenterInfo setObject:[ZRT_PlayerManager manager].currentSong[@"post_title"]?[ZRT_PlayerManager manager].currentSong[@"post_title"]:@"" forKey:MPMediaItemPropertyTitle];
                    [playingCenterInfo setObject:[ZRT_PlayerManager manager].currentSong[@"post_act"][@"name"]?[ZRT_PlayerManager manager].currentSong[@"post_act"][@"name"]:@"" forKey:MPMediaItemPropertyArtist];
                    [playingCenterInfo setObject:@(1) forKey:MPNowPlayingInfoPropertyPlaybackRate];
                    [playingCenterInfo setObject:@([ZRT_PlayerManager manager].duration) forKey:MPMediaItemPropertyPlaybackDuration];
                    MPMediaItemArtwork * artwork = [[MPMediaItemArtwork alloc] initWithImage:image?image:[UIImage imageNamed:@"thumbnailsdefault"]];
                    [playingCenterInfo setObject:artwork forKey:MPMediaItemPropertyArtwork];
                    [[MPNowPlayingInfoCenter defaultCenter] setNowPlayingInfo:playingCenterInfo];
                }
            }];
        }
    }else{
        if([[SDWebImageManager sharedManager] cachedImageExistsForURL:[NSURL URLWithString:[ZRT_PlayerManager manager].currentCoverImage]]){
            UIImage* img = [[SDWebImageManager sharedManager].imageCache imageFromMemoryCacheForKey:[[SDWebImageManager sharedManager] cacheKeyForURL:[NSURL URLWithString:[ZRT_PlayerManager manager].currentCoverImage]]];
            
            if(!img)
                img = [[SDWebImageManager sharedManager].imageCache imageFromDiskCacheForKey:[[SDWebImageManager sharedManager] cacheKeyForURL:[NSURL URLWithString:[ZRT_PlayerManager manager].currentCoverImage]]];
            NSMutableDictionary * playingCenterInfo = [NSMutableDictionary dictionary];
            [playingCenterInfo setObject:[ZRT_PlayerManager manager].currentSong[@"s_title"]?[ZRT_PlayerManager manager].currentSong[@"s_title"]:@"" forKey:MPMediaItemPropertyTitle];
            [playingCenterInfo setObject:[ZRT_PlayerManager manager].currentSong[@"name"]?[ZRT_PlayerManager manager].currentSong[@"name"]:@"" forKey:MPMediaItemPropertyArtist];            [playingCenterInfo setObject:@(1) forKey:MPNowPlayingInfoPropertyPlaybackRate];
            [playingCenterInfo setObject:@([ZRT_PlayerManager manager].duration) forKey:MPMediaItemPropertyPlaybackDuration];
            MPMediaItemArtwork * artwork = [[MPMediaItemArtwork alloc] initWithImage:img?img:[UIImage imageNamed:@"thumbnailsdefault"]];
            [playingCenterInfo setObject:artwork forKey:MPMediaItemPropertyArtwork];
            [[MPNowPlayingInfoCenter defaultCenter] setNowPlayingInfo:playingCenterInfo];
            
        }else{
            [[SDWebImageManager sharedManager] downloadImageWithURL:[NSURL URLWithString:[ZRT_PlayerManager manager].currentCoverImage] options:SDWebImageRetryFailed|SDWebImageLowPriority progress:nil completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, BOOL finished, NSURL *imageURL) {
                if (image) {
                    NSMutableDictionary * playingCenterInfo = [NSMutableDictionary dictionary];
                    [playingCenterInfo setObject:[ZRT_PlayerManager manager].currentSong[@"s_title"]?[ZRT_PlayerManager manager].currentSong[@"s_title"]:@"" forKey:MPMediaItemPropertyTitle];
                    [playingCenterInfo setObject:[ZRT_PlayerManager manager].currentSong[@"name"]?[ZRT_PlayerManager manager].currentSong[@"name"]:@"" forKey:MPMediaItemPropertyArtist];
                    [playingCenterInfo setObject:@(1) forKey:MPNowPlayingInfoPropertyPlaybackRate];
                    [playingCenterInfo setObject:@([ZRT_PlayerManager manager].duration) forKey:MPMediaItemPropertyPlaybackDuration];
                    MPMediaItemArtwork * artwork = [[MPMediaItemArtwork alloc] initWithImage:image?image:[UIImage imageNamed:@"thumbnailsdefault"]];
                    [playingCenterInfo setObject:artwork forKey:MPMediaItemPropertyArtwork];
                    [[MPNowPlayingInfoCenter defaultCenter] setNowPlayingInfo:playingCenterInfo];
                }
            }];
        }
    }
}
- (void)remoteControlReceivedWithEvent:(UIEvent *)event {
    //后台播放控制事件， 在此处设置对应的控制器进行相应
    [[NewPlayVC shareInstance] remoteControlReceivedWithEvent:event];
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
        switch (_payType) {
            case PayTypeClassPay:
                //通知支付结果
                [[NSNotificationCenter defaultCenter] postNotificationName:WechatPayResultsClass object:@(resp.errCode)];
                break;
            case PayTypeReward:
                [[NSNotificationCenter defaultCenter] postNotificationName:WechatPayResultsReward object:@(resp.errCode)];
                break;
            case PayTypeRecharge:
                [[NSNotificationCenter defaultCenter] postNotificationName:WechatPayResultsRecharge object:@(resp.errCode)];
                break;
            case PayTypeMembers:
                [[NSNotificationCenter defaultCenter] postNotificationName:WechatPayResultsMembers object:@(resp.errCode)];
                break;
                
            default:
                break;
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
#pragma mark - 广告代理
/**
 广告位展示代理方法
 */
-(void)splashAdSuccessPresentScreen:(GDTSplashAd *)splashAd
{
    NSLog(@"%s",__FUNCTION__);
}

-(void)splashAdFailToPresent:(GDTSplashAd *)splashAd withError:(NSError *)error
{
    NSLog(@"%s%@",__FUNCTION__,error);
}
-(void)splashAdApplicationWillEnterBackground:(GDTSplashAd *)splashAd
{
    NSLog(@"%s",__FUNCTION__);
}
-(void)splashAdClicked:(GDTSplashAd *)splashAd
{
    NSLog(@"%s",__FUNCTION__);
}

- (void)splashAdWillClosed:(GDTSplashAd *)splashAd
{
    NSLog(@"%s",__FUNCTION__);
}
-(void)splashAdClosed:(GDTSplashAd *)splashAd
{
    NSLog(@"%s",__FUNCTION__);
    _splash = nil;
}
-(void)splashAdWillPresentFullScreenModal:(GDTSplashAd *)splashAd
{
    NSLog(@"%s",__FUNCTION__);
}
-(void)splashAdDidDismissFullScreenModal:(GDTSplashAd *)splashAd
{
    NSLog(@"%s",__FUNCTION__);
}
@end
