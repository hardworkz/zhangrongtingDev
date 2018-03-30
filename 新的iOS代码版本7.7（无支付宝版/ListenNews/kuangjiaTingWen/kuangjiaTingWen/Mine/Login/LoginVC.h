//
//  LoginVC.h
//  reHeardTheNews
//
//  Created by Pop Web on 16/3/18.
//  Copyright © 2016年 paoguo. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface LoginVC : UIViewController

@property (assign, nonatomic)BOOL isSubscription;

@property (assign, nonatomic)BOOL isFormDownload;

/**
 跳转登录界面，提示弹窗登录才能购买
 */
@property (assign, nonatomic)BOOL isTipClassBuy;
/**
 跳转登录界面，提示弹窗登录才能点赞新闻
 */
@property (assign, nonatomic)BOOL isTipNewsZan;
@end
