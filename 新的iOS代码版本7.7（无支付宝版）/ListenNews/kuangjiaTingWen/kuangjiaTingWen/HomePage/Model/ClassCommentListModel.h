//
//  ClassCommentListModel.h
//  kuangjiaTingWen
//
//  Created by 泡果 on 2017/6/2.
//  Copyright © 2017年 zhimi. All rights reserved.
//

#import <Foundation/Foundation.h>

/*
 "id": "753",
 "post_table": "act",
 "post_id": "247",
 "url": "index.php?g=&amp;m=article&amp;a=index&amp;id=247",
 "uid": "26994",
 "to_uid": "0",
 "full_name": "\u5f20\u671d\u658c13689554203",
 "email": "",
 "createtime": "2017-05-11 09:01:23",
 "content": "\u58f0\u97f3\u5f88\u68d2\uff01\u80cc\u666f\u97f3\u4e50\u4e5f\u4e0d\u9519\uff0c\u73b0\u5728\u5f00\u59cb\u542c\u4eceA\u5230A+",
 "type": "1",
 "parentid": "0",
 "path": null,
 "praisenum": "0",
 "status": "1",
 "avatar": "http:\/\/wx.qlogo.cn\/mmopen\/ajNVdqHZLLA8IVvzzE7lOoAFsgic7UQRcT1CAyV2Hvx6xvnXRicgRZka3E0gjD1y0O6SJA0k7MWn32JoG6o9NMdQ\/0",
 "user_login": "tw1494066555682067",
 "user_nicename": "\u5f20\u671d\u658c13689554203",
 "sex": "0",
 "signature": null,
 "to_avatar": null,
 "to_user_login": null,
 "to_user_nicename": null,
 "to_sex": null,
 "to_signature": null,
 "emoji": "\u58f0\u97f3\u5f88\u68d2\uff01\u80cc\u666f\u97f3\u4e50\u4e5f\u4e0d\u9519\uff0c\u73b0\u5728\u5f00\u59cb\u542c\u4eceA\u5230A+",
 "praiseFlag": 1
 */
@interface ClassCommentListModel : NSObject
@property (strong, nonatomic) NSString *ID;/**< */
@property (strong, nonatomic) NSString *post_table;/**< */
@property (strong, nonatomic) NSString *post_id;/**< */
@property (strong, nonatomic) NSString *url;/**< */
@property (strong, nonatomic) NSString *uid;/**< */
@property (strong, nonatomic) NSString *to_uid;/**< */
@property (strong, nonatomic) NSString *full_name;/**< */
@property (strong, nonatomic) NSString *email;/**< */
@property (strong, nonatomic) NSString *createtime;/**< */
@property (strong, nonatomic) NSString *content;/**< */
@property (strong, nonatomic) NSString *type;/**< */
@property (strong, nonatomic) NSString *parentid;/**< */
@property (strong, nonatomic) NSString *path;/**< */
@property (strong, nonatomic) NSString *praisenum;/**< */
@property (strong, nonatomic) NSString *status;/**< */
@property (strong, nonatomic) NSString *avatar;/**< */
@property (strong, nonatomic) NSString *user_login;/**< */
@property (strong, nonatomic) NSString *user_nicename;/**< */
@property (strong, nonatomic) NSString *sex;/**< */
@property (strong, nonatomic) NSString *signature;/**< */
@property (strong, nonatomic) NSString *to_avatar;/**< */
@property (strong, nonatomic) NSString *to_user_login;/**< */
@property (strong, nonatomic) NSString *to_user_nicename;/**< */
@property (strong, nonatomic) NSString *to_sex;/**< */
@property (strong, nonatomic) NSString *to_signature;/**< */
@property (strong, nonatomic) NSString *emoji;/**< */
@property (strong, nonatomic) NSString *praiseFlag;/**< */
@end
