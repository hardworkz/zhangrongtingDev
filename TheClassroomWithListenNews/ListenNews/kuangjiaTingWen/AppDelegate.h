//
//  AppDelegate.h
//  kuangjiaTingWen
//
//  Created by 贺楠 on 16/6/3.
//  Copyright © 2016年 贺楠. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Reachability.h"
#import "GDTSplashAd.h"


typedef NS_ENUM(NSUInteger, PayType) {
    PayTypeReward = 0,//打赏支付
    PayTypeClassPay,//课程购买支付
    PayTypeMembers,//会员购买支付
    PayTypeRecharge,//充值
    PayTypeTingCoinPay,//听币支付
    PayTypeNone,//无支付
};

typedef void (^SkipToPlayingVCBlock)(NSString *) ;
typedef void (^WeibodidReceiveResponse)(NSDictionary *);
typedef void (^WechatdidReceiveCode)(NSString *);

@protocol QQShareDelegate <NSObject>

-(void)shareSuccssWithQQCode:(NSInteger)code;

@end

@interface AppDelegate : UIResponder <UIApplicationDelegate,GDTSplashAdDelegate>

@property (strong, nonatomic) UIWindow *window;

/**
 无声播放器
 */
@property (strong, nonatomic) AVAudioPlayer *noSoundPlayer;
/**
 支付类型
 */
@property (nonatomic,assign) PayType payType;

@property (assign, nonatomic) BOOL isTabbarCenterClicked;//是否点击底部导航栏中心按钮跳转播放器

@property (assign, nonatomic) BOOL isLogin;//是否登录

@property (copy, nonatomic) WeibodidReceiveResponse weibologinSuccess;
@property (copy, nonatomic) WechatdidReceiveCode wechatGetLoginCode;

@property (weak  , nonatomic) id<QQShareDelegate> qqDelegate;
/*
 * 网络状态
 */
@property (nonatomic, assign) NetworkStatus networkStatus;

/**
 启动页广告展示对象，底部view
 */
@property (retain, nonatomic) GDTSplashAd *splash;
@property (retain, nonatomic) UIView *bottomView;
/*
 * 获取app代理
 */
+ (AppDelegate *)delegate;
/**
 锁屏界面播放数据设置
 */
- (void)configNowPlayingCenter;
@end

