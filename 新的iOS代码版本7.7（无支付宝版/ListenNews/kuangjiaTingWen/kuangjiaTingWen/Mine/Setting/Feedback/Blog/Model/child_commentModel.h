//
//  child_commentModel.h
//  kuangjiaTingWen
//
//  Created by 泡果 on 2017/5/12.
//  Copyright © 2017年 zhimi. All rights reserved.
//

#import <Foundation/Foundation.h>

/*
 "id": "185982",
 "post_id": "0",
 "uid": "19132",
 "to_uid": "117",
 "createtime": "2017-04-16 14:06:16",
 "comment": "v",
 "parentid": "185972",
 "praisenum": "0",
 "status": "1",
 "user": {
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
 },
 "to_user": {
 "id": "117",
 "user_nicename": "\u9648\u5955\u8d24",
 "user_login": "tw241080",
 "sex": "1",
 "signature": "\u542c\u95fbCEO\u3002",
 "avatar": "5845323a0972c.jpeg",
 "fan_num": "198",
 "guan_num": "211"
 }
 */
@interface child_commentModel : NSObject
@property (strong, nonatomic) NSString *ID;/**< */
@property (strong, nonatomic) NSString *post_id;/**< */
@property (strong, nonatomic) NSString *uid;/**< */
@property (strong, nonatomic) NSString *to_uid;/**< */
@property (strong, nonatomic) NSString *createtime;/**< */
@property (strong, nonatomic) NSString *comment;/**< */
@property (strong, nonatomic) NSString *parentid;/**< */
@property (strong, nonatomic) NSString *praisenum;/**< */
@property (strong, nonatomic) NSString *status;/**< */
@property (strong, nonatomic) NSString *is_comment;/**<*/
@property (strong, nonatomic) UserDetailModel *user;/**< */
@property (strong, nonatomic) UserModel *to_user;/**< */
@end
