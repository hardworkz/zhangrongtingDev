//
//  UserModel.h
//  kuangjiaTingWen
//
//  Created by 泡果 on 2017/5/12.
//  Copyright © 2017年 zhimi. All rights reserved.
//

#import <Foundation/Foundation.h>
/*
 {
 "id": "25850",
 "user_nicename": "申国安13404708501",
 "user_login": "tw1493255109522399",
 "sex": "0",
 "signature": null,
 "avatar": "http://wx.qlogo.cn/mmopen/Q3auHgzwzM7qzlU7Irb7G21wWAcPhib3Gq7RoM8DB8EVbGdABfECibRRqD8QYcWgAMWHRoIV5JCADlTlcibgQrXJCavO7MVx2fWv6dGKgqgY8E/0",
 "fan_num": "0",
 "guan_num": "0"
 }
 */
@interface UserModel : NSObject
@property (strong, nonatomic) NSString *ID;
@property (strong, nonatomic) NSString *user_nicename;
@property (strong, nonatomic) NSString *user_login;
@property (strong, nonatomic) NSString *sex;
@property (strong, nonatomic) NSString *signature;
@property (strong, nonatomic) NSString *avatar;
@property (strong, nonatomic) NSString *fan_num;
@property (strong, nonatomic) NSString *guan_num;
@end
