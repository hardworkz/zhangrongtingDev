//
//  PayOnlineViewController.h
//  kuangjiaTingWen
//
//  Created by Zhimi on 17/1/3.
//  Copyright © 2017年 贺楠. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface PayOnlineViewController : UIViewController

@property (assign, nonatomic) float rewardCount;

@property (strong, nonatomic) NSString *uid;

@property (strong, nonatomic) NSString *post_id;
/**
 主播ID
 */
@property (strong, nonatomic) NSString *act_id;

@property (assign, nonatomic) double balanceCount;

@property (strong, nonatomic) NSMutableDictionary *myPersonalInfoDict;

@property (assign, nonatomic) BOOL isPayClass;

//微信支付
- (void)WechatPay;
//支付宝
- (void)AliPayWithSubject:(NSString *)subject body:(NSString *)body;
@end
