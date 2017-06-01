//
//  ZhuBoClass.h
//  Heard the news
//
//  Created by 温仲斌 on 15/12/23.
//  Copyright © 2015年 泡果网络. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ZhuBoClass : NSObject

@property (nonatomic, copy) NSString *avatar;
@property (nonatomic, copy) NSString *uid;
@property (nonatomic, copy) NSString *friend_id;

@property (nonatomic, copy) NSString *birthday;
@property (nonatomic, copy) NSString *comment_count_anchor;
@property (nonatomic, copy) NSString *create_time;
@property (nonatomic, copy) NSString *i_id;
@property (nonatomic, copy) NSString *name;
@property (nonatomic, copy) NSString *last_login_ip;
@property (nonatomic, copy) NSString *last_login_time;
@property (nonatomic, strong) NSArray *imagess;
@property (nonatomic, strong) NSString *images;
@property (nonatomic, copy) NSString *sex;
@property (nonatomic, copy) NSString *signature;
@property (nonatomic, copy) NSString *user_activation_key;
@property (nonatomic, copy) NSString *user_email;
@property (nonatomic, copy) NSString *user_login;
@property (nonatomic, copy) NSString *user_nicename;
@property (nonatomic, copy) NSString *user_pass;
@property (nonatomic, copy) NSString *user_phone;
@property (nonatomic, copy) NSString *user_status;
@property (nonatomic, copy) NSString *user_type;
@property (nonatomic, copy) NSString *user_url;
@property (nonatomic, copy) NSString *guolv;
@property (nonatomic, copy) NSString *listorder;
@property (nonatomic, copy) NSString *score;
@property (nonatomic) BOOL isHaoYou;

+ (ZhuBoClass *)userClassWithDictionary:(NSDictionary *)dic;

@end
