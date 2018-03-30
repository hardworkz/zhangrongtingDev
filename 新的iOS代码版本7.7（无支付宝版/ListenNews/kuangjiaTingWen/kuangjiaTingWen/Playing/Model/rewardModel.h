//
//  rewardModel.h
//  kuangjiaTingWen
//
//  Created by 泡果 on 2017/6/21.
//  Copyright © 2017年 zhimi. All rights reserved.
//

#import <Foundation/Foundation.h>

/*
 "money": "20.00",
 "date": "1492773941",
 "user_id": "25271",
 "user_login": "tw1492773658644989",
 "user_nicename": "Yui\uff5e",
 "avatar": "58f9ebceed121.jpeg"
 */
@interface rewardModel : NSObject
@property (nonatomic, strong) NSString *money;
@property (nonatomic, strong) NSString *date;
@property (nonatomic, strong) NSString *user_id;
@property (nonatomic, strong) NSString *user_login;
@property (nonatomic, strong) NSString *user_nicename;
@property (nonatomic, strong) NSString *avatar;
@end
