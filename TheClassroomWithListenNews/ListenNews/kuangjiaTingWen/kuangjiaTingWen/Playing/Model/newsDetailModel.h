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
@property (nonatomic, strong) NSString *post_id;/**<新闻ID*/
@property (nonatomic, strong) NSString *post_news;/**<新闻节目ID */
@property (nonatomic, strong) NSString *post_title;/**<新闻标题 */
@property (nonatomic, strong) NSString *post_lai;/**<新闻来源 */
@property (nonatomic, strong) NSString *post_mp;/**<新闻音频url */
@property (nonatomic, strong) NSString *post_time;/**<新闻音频总时间（ps:秒数，要除1000） */
@property (nonatomic, strong) NSString *post_size;/**<音频大小 */
@property (nonatomic, strong) NSString *post_excerpt;/**<新闻内容摘要 */
@property (nonatomic, strong) NSString *post_modified;/**<新闻发布日期 */
@property (nonatomic, strong) NSString *comment_count;/**<新闻评论数 */
@property (nonatomic, strong) NSString *smeta;/**<新闻封面图片 */
@property (nonatomic, strong) NSString *gold;/**<被打赏的金币总额 */
@property (nonatomic, strong) NSString *is_collection;/**<是否收藏 */
@property (nonatomic, strong) NSString *reward_num;/**<打赏数 */
@property (nonatomic, strong) NSString *url;/**<原文url */
@property (nonatomic, strong) newsActModel *act;/**<主播数据模型 */
@property (nonatomic, strong) NSArray *reward;/**<打赏数据 */
@end
