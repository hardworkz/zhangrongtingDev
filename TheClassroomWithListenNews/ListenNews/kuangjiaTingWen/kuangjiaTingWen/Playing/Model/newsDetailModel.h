//
//  newsDetailModel.h
//  kuangjiaTingWen
//
//  Created by 泡果 on 2017/6/21.
//  Copyright © 2017年 zhimi. All rights reserved.
//

#import <Foundation/Foundation.h>

/*
 "post_id": "73360",
 "post_news": "155",
 "post_title": "\u3010\u542c\u95fb\u64ad\u62a5\u3011\u8c37\u6b4c\u5ba3\u5e036\u670830\u65e5\u505c\u6b62\u5bf9\u5b89\u53532.1\u53ca\u66f4\u65e9\u7248\u672c\u7cfb\u7edf\u5e94\u7528\u652f\u6301",
 "post_lai": "\u542c\u95fb",
 "post_mp": "http:\/\/admin.tingwen.me\/data\/upload\/mp3\/5949e475b77da.mp3",
 "post_time": "179000",
 "post_size": "2151485",
 "post_excerpt": "",
 "post_modified": "2017-06-21 11:02:18",
 "comment_count": "0",
 "smeta": "{\"thumb\":\"http:\\\/\\\/admin.tingwen.me\\\/Uploads\\\/2017-06-21\\\/crop_5949e3eb4490f.jpg\"}",
 "gold": "0",
 "is_collection": 0,
 */
@class newsActModel;
@interface newsDetailModel : NSObject
@property (nonatomic, strong) NSString *post_id;
@property (nonatomic, strong) NSString *post_news;
@property (nonatomic, strong) NSString *post_title;
@property (nonatomic, strong) NSString *post_lai;
@property (nonatomic, strong) NSString *post_mp;
@property (nonatomic, strong) NSString *post_time;
@property (nonatomic, strong) NSString *post_size;
@property (nonatomic, strong) NSString *post_excerpt;
@property (nonatomic, strong) NSString *post_modified;
@property (nonatomic, strong) NSString *comment_count;
@property (nonatomic, strong) NSString *smeta;
@property (nonatomic, strong) NSString *gold;
@property (nonatomic, strong) NSString *is_collection;
@property (nonatomic, strong) NSString *reward_num;
@property (nonatomic, strong) newsActModel *act;
@property (nonatomic, strong) NSArray *reward;
@end
