//
//  FeedBackAndListenFriendModel.h
//  kuangjiaTingWen
//
//  Created by 泡果 on 2017/5/12.
//  Copyright © 2017年 zhimi. All rights reserved.
//

#import <Foundation/Foundation.h>

/*
 {
 "id": "186069",
 "post_id": "0",
 "uid": "25850",
 "to_uid": "0",
 "createtime": "2017-04-28 10:45:49",
 "comment": "",
 "parentid": "0",
 "praisenum": "0",
 "status": "1",
 "timages": "data/upload/feedback/5902acdb1e61a.jpg",
 "mp3_url": "http://admin.tingwen.me/data/upload/tingyouquan/5902acd6e5b20.aac",
 "play_time": "8",
 "user": {
 "id": "25850",
 "user_nicename": "申国安13404708501",
 "user_login": "tw1493255109522399",
 "sex": "0",
 "signature": null,
 "avatar": "http://wx.qlogo.cn/mmopen/Q3auHgzwzM7qzlU7Irb7G21wWAcPhib3Gq7RoM8DB8EVbGdABfECibRRqD8QYcWgAMWHRoIV5JCADlTlcibgQrXJCavO7MVx2fWv6dGKgqgY8E/0",
 "fan_num": "0",
 "guan_num": "0"
 },
 "post": {
 "simpleImage": null
 },
 "zan": 0,
 "child_comment": null
 }
 */
@class UserModel;
@interface FeedBackAndListenFriendModel : NSObject
@property (strong, nonatomic) NSString *ID;/**<列表ID*/
@property (strong, nonatomic) NSString *post_id;/**<*/
@property (strong, nonatomic) NSString *uid;/**<*/
@property (strong, nonatomic) NSString *to_uid;/**<*/
@property (strong, nonatomic) NSString *createtime;/**<*/
@property (strong, nonatomic) NSString *create_time;/**<*/
@property (strong, nonatomic) NSString *comment;/**<*/
@property (strong, nonatomic) NSString *content;/**<*/
@property (strong, nonatomic) NSString *parentid;/**<*/
@property (strong, nonatomic) NSString *praisenum;/**<*/
@property (strong, nonatomic) NSString *status;/**<*/
@property (strong, nonatomic) NSString *timages;/**<*/
@property (strong, nonatomic) NSString *images;/**<*/
@property (strong, nonatomic) NSString *mp3_url;/**<*/
@property (strong, nonatomic) NSString *play_time;/**<*/
@property (strong, nonatomic) NSString *zan;/**<*/
@property (strong, nonatomic) NSString *is_zan;/**<*/
@property (strong, nonatomic) NSString *zan_num;/**<*/
@property (assign, nonatomic,readonly) CGSize oneImageSize;
@property (strong, nonatomic) NSMutableArray *child_comment;/**<*/
@property (strong, nonatomic) NewObj *post;/**<*/
@property (strong, nonatomic) UserModel *user;/**<用户模型*/

@property (assign, nonatomic)BOOL isFeedbackVC;
@end
