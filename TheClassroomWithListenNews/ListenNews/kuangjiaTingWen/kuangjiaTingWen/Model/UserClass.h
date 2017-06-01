//
//  UserClass.h
//  Heard the news
//
//  Created by Pop Web on 15/8/26.
//  Copyright (c) 2015年 泡果网络. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface UserClass : NSObject

@property (nonatomic, copy) NSString *avatar;
@property (nonatomic, copy) NSString *birthday;
@property (nonatomic, copy) NSString *create_time;
@property (nonatomic, copy) NSString *i_id;
@property (nonatomic, copy) NSString *uid;
@property (nonatomic, copy) NSString *last_login_ip;
@property (nonatomic, copy) NSString *last_login_time;
@property (nonatomic, copy) NSString *sex;
@property (nonatomic, copy) NSString *signature;
@property (nonatomic, copy) NSString *user_activation_key;
@property (nonatomic, copy) NSString *user_email;
@property (nonatomic, copy) NSString *user_login;
@property (nonatomic, copy) NSString *user_nicename;
@property (nonatomic, copy) NSString *user_phone;
@property (nonatomic, copy) NSString *user_status;
@property (nonatomic, copy) NSString *user_type;
@property (nonatomic, copy) NSString *user_url;
@property (nonatomic, copy) NSString *guolv;
@property (nonatomic, copy) NSString *friend_id;

@property (strong, nonatomic)NSString *fan_num;
@property (strong, nonatomic)NSString *guan_num;

@property (nonatomic, copy) NSString *isSanF;

+ (UserClass *)userClassWithDictionary:(NSDictionary *)dic;
/* 获取对象的所有属性的内容 */
- (NSDictionary *)getAllPropertiesAndVaules;
@end
