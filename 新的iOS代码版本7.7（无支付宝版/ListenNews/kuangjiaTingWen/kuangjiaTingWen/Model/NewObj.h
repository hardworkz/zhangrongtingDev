//
//  NewObj.h
//  Heard the news
//
//  Created by Pop Web on 15/8/12.
//  Copyright (c) 2015年 泡果网络. All rights reserved.
//

#import <Foundation/Foundation.h>

@class ZhuBoClass;
@class Post_actor;

@interface NewObj : NSObject

@property (nonatomic, strong) NSString *comment_count;
@property (nonatomic, strong) NSString *comment_status;
@property (nonatomic, strong) NSString *i_id;
@property (nonatomic, strong) NSString *object_id;
@property (nonatomic, strong) NSString *istop;
@property (nonatomic, strong) NSString *post_author;
@property (nonatomic, strong) NSString *post_content;
@property (nonatomic, strong) NSString *post_content_filtered;
@property (nonatomic, strong) NSString *post_date;
@property (nonatomic, strong) NSString *post_excerpt;
@property (nonatomic, strong) NSString *post_hits;
@property (nonatomic, strong) NSString *post_keywords;
@property (nonatomic, strong) NSString *post_lai;
@property (nonatomic, strong) NSString *post_like;
@property (nonatomic, strong) NSString *post_mime_type;
@property (nonatomic, strong) NSString *post_modified;
@property (nonatomic, strong) NSString *post_mp;
@property (nonatomic, strong) NSString *post_parent;
@property (nonatomic, strong) NSString *post_status;
@property (nonatomic, strong) NSString *post_time;
@property (nonatomic, strong) NSString *post_title;
@property (nonatomic, strong) NSString *post_type;
@property (nonatomic, strong) NSString *recommended;
@property (nonatomic, strong) NSString *smeta;
@property (nonatomic, strong) NSString *term_id;
@property (nonatomic, strong) NSString *term_name;
@property (nonatomic, strong) NSString *toutiao;
@property (nonatomic, strong) NSString *user_login;
@property (nonatomic, strong) NSString *listeningrate;
@property (nonatomic, strong) NSString *praisenum;
@property (nonatomic, strong) NSString *guolv;
@property (nonatomic, strong) NSString *zhuti;
@property (nonatomic, strong) NSString *zhutitle;
@property (nonatomic, strong) NSString *post_size;
@property (nonatomic, strong) NSString *url;
@property (nonatomic, strong) NSString *post_news;

@property (nonatomic, strong) NSDictionary *post_act;

//是否收听过
@property (nonatomic) BOOL isClick;
@property (nonatomic, copy) NSString *timeInterval;

+ (instancetype)newObjWithDictionary:(NSDictionary*)dic;
//生成html新闻内容
+ (NSArray *)generationHTMLWithNews:(NewObj *)newsItem;

+ (NSArray *)generationHTMLWithNews:(NewObj *)newsItem AndZhuBo:(Post_actor *)zhubo;
//把新闻对象转化为 字典
- (NSDictionary *)getAllPropertiesAndVaules;

@end

