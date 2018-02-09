//
//  UserDetailModel.h
//  kuangjiaTingWen
//
//  Created by 泡果 on 2017/5/12.
//  Copyright © 2017年 zhimi. All rights reserved.
//

#import <Foundation/Foundation.h>

/*
 {
 "id": "19132",
 "user_login": "tw338238",
 "user_pass": "",
 "user_nicename": "sq201211",
 "user_phone": null,
 "user_email": "",
 "user_url": "",
 "avatar": "http:\/\/q.qlogo.cn\/qqapp\/1101441286\/81FD10815D74E9D11BC2230BEB57C115\/100",
 "post_contents": null,
 "sex": "0",
 "birthday": null,
 "signature": null,
 "last_login_ip": "223.86.107.17",
 "last_login_time": "2017-03-06 22:16:32",
 "create_time": "2017-03-06 22:16:32",
 "user_activation_key": "",
 "comment_count_anchor": "0",
 "user_status": "1",
 "score": "0",
 "user_type": "2"
 }
 */
@interface UserDetailModel : NSObject
@property (strong, nonatomic) NSString *ID;/**< */
@property (strong, nonatomic) NSString *user_login;/**< */
@property (strong, nonatomic) NSString *user_pass;/**< */
@property (strong, nonatomic) NSString *user_nicename;/**< */
@property (strong, nonatomic) NSString *user_phone;/**< */
@property (strong, nonatomic) NSString *user_email;/**< */
@property (strong, nonatomic) NSString *user_url;/**< */
@property (strong, nonatomic) NSString *avatar;/**< */
@property (strong, nonatomic) NSString *post_contents;/**< */
@property (strong, nonatomic) NSString *sex;/**< */
@property (strong, nonatomic) NSString *birthday;/**< */
@property (strong, nonatomic) NSString *signature;/**< */
@property (strong, nonatomic) NSString *last_login_ip;/**<*/
@property (strong, nonatomic) NSString *last_login_time;/**<*/
@property (strong, nonatomic) NSString *create_time;/**<*/
@property (strong, nonatomic) NSString *user_activation_key;/**<*/
@property (strong, nonatomic) NSString *comment_count_anchor;/**<*/
@property (strong, nonatomic) NSString *user_status;/**<*/
@property (strong, nonatomic) NSString *score;/**<*/
@property (strong, nonatomic) NSString *user_type;/**<*/
@property (strong, nonatomic) NSString *is_comment;/**<*/
@property (strong, nonatomic) NSString *fan_num;
@property (strong, nonatomic) NSString *guan_num;
@end
