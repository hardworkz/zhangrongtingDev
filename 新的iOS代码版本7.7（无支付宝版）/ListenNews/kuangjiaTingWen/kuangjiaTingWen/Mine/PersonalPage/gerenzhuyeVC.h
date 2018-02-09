//
//  gerenzhuyeVC.h
//  reHeardTheNews
//
//  Created by Pop Web on 16/3/18.
//  Copyright © 2016年 paoguo. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface gerenzhuyeVC : UIViewController

@property (assign, nonatomic)BOOL isMypersonalPage;
@property (assign, nonatomic)BOOL isNewsComment;
@property (assign, nonatomic)BOOL isComefromRewardlist;
@property (strong, nonatomic)NSString *user_id;
@property (strong, nonatomic)NSString *user_nicename;
@property (strong, nonatomic)NSString *user_login;
@property (strong, nonatomic)NSString *sex;
@property (strong, nonatomic)NSString *signature;
@property (strong, nonatomic)NSString *avatar;
@property (strong, nonatomic)NSString *fan_num;
@property (strong, nonatomic)NSString *guan_num;

@end
