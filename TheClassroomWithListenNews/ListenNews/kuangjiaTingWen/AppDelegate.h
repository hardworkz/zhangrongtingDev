//
//  AppDelegate.h
//  kuangjiaTingWen
//
//  Created by 贺楠 on 16/6/3.
//  Copyright © 2016年 贺楠. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Reachability.h"

typedef void (^SkipToPlayingVCBlock)(NSString *) ;
typedef void (^WeibodidReceiveResponse)(NSDictionary *);
typedef void (^WechatdidReceiveCode)(NSString *);

@protocol QQShareDelegate <NSObject>

-(void)shareSuccssWithQQCode:(NSInteger)code;

@end

@interface AppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;

@property (assign, nonatomic) BOOL isReward;//打赏 ? 充值
@property (assign, nonatomic) BOOL isClassPay;//购买课堂

@property (copy, nonatomic) SkipToPlayingVCBlock shouyeSkipToPlayingVC;
@property (copy, nonatomic) SkipToPlayingVCBlock dingyueSkipToPlayingVC;
@property (copy, nonatomic) SkipToPlayingVCBlock faxianSkipToPlayingVC;
@property (copy, nonatomic) SkipToPlayingVCBlock woSkipToPlayingVC;

@property (copy, nonatomic) WeibodidReceiveResponse weibologinSuccess;
@property (copy, nonatomic) WechatdidReceiveCode wechatGetLoginCode;

@property (weak  , nonatomic) id<QQShareDelegate> qqDelegate;
/*
 * 网络状态
 */
@property (nonatomic, assign) NetworkStatus networkStatus;
/*
 * 获取app代理
 */
+ (AppDelegate *)delegate;

@end

