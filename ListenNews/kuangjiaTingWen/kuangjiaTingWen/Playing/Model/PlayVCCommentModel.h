//
//  PlayVCCommentModel.h
//  kuangjiaTingWen
//
//  Created by 泡果 on 2017/5/17.
//  Copyright © 2017年 zhimi. All rights reserved.
//

#import <Foundation/Foundation.h>

/*
 "id": "186145",
 "post_table": "posts",
 "post_id": "71111",
 "url": "index.php?g=&amp;m=article&amp;a=index&amp;id=71111",
 "uid": "26779",
 "to_uid": "26779",
 "full_name": "heihei",
 "email": "",
 "createtime": "2017-05-17 14:16:02",
 "content": "666",
 "type": "1",
 "parentid": "186144",
 "path": "0-186144-186145",
 "praisenum": "0",
 "status": "1",
 "timages": "",
 "mp3_url": "",
 "play_time": "0",
 "avatar": "59127a436af41.jpeg",
 "user_login": "tw1493951584274536",
 "user_nicename": "heihei",
 "sex": "2",
 "signature": "\u8be5\u7528\u6237\u6ca1\u6709\u4ec0\u4e48\u60f3\u8bf4\u7684",
 "to_avatar": "59127a436af41.jpeg",
 "to_user_login": "tw1493951584274536",
 "to_user_nicename": "heihei",
 "to_sex": "2",
 "to_signature": "\u8be5\u7528\u6237\u6ca1\u6709\u4ec0\u4e48\u60f3\u8bf4\u7684",
 "emoji": "666",
 "praiseFlag": 1
 */
@interface PlayVCCommentModel : NSObject
@property(nonatomic)NSString *playCommentID; /**< */
@property(nonatomic)NSString *post_table; /**< */
@property(nonatomic)NSString *post_id; /**< */
@property(nonatomic)NSString *url; /**< */
@property(nonatomic)NSString *uid; /**< */
@property(nonatomic)NSString *to_uid; /**< */
@property(nonatomic)NSString *full_name; /**< */
@property(nonatomic)NSString *email; /**< */
@property(nonatomic)NSString *createtime; /**< */
@property(nonatomic)NSString *content; /**< */
@property(nonatomic)NSString *type; /**< */
@property(nonatomic)NSString *parentid; /**< */
@property(nonatomic)NSString *path; /**< */
@property(nonatomic)NSString *praisenum; /**< */
@property(nonatomic)NSString *status; /**< */
@property(nonatomic)NSString *timages; /**< */
@property(nonatomic)NSString *mp3_url; /**< */
@property(nonatomic)NSString *play_time; /**< */
@property(nonatomic)NSString *avatar; /**< */
@property(nonatomic)NSString *user_login; /**< */
@property(nonatomic)NSString *user_nicename; /**< */
@property(nonatomic)NSString *sex; /**< */
@property(nonatomic)NSString *signature; /**< */
@property(nonatomic)NSString *to_avatar; /**< */
@property(nonatomic)NSString *to_user_login; /**< */
@property(nonatomic)NSString *to_user_nicename; /**< */
@property(nonatomic)NSString *to_sex; /**< */
@property(nonatomic)NSString *to_signature; /**< */
@property(nonatomic)NSString *emoji; /**< */
@property(nonatomic)NSString *praiseFlag; /**< */
@end
