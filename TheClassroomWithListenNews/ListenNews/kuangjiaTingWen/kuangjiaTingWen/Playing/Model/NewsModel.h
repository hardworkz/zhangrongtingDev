//
//  NewsModel.h
//  kuangjiaTingWen
//
//  Created by 泡果 on 2017/5/9.
//  Copyright © 2017年 zhimi. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NewsModel : NSObject
@property(nonatomic)NSString *jiemuID;/**<节目ID*/
@property(nonatomic)NSString *Titlejiemu;/**<节目标题*/
@property(nonatomic)NSString *RiQijiemu;/**<节目日期*/
@property(nonatomic)NSString *post_lai;/**<*/
@property(nonatomic)NSString *ImgStrjiemu;/**<节目图片字符串*/
@property(nonatomic)NSString *ZhengWenjiemu;/**<征文节目*/
@property(nonatomic)NSString *post_news;/**<*/
@property(nonatomic)NSString *praisenum;/**<*/
@property(nonatomic)NSString *post_mp;/**<*/
@property(nonatomic)NSString *post_time;/**<*/
@property(nonatomic)NSString *jiemuName;/**<节目名称*/
@property(nonatomic)NSString *jiemuDescription/**<节目描述*/;
@property(nonatomic)NSString *jiemuImages;/**<节目图片*/
@property(nonatomic)NSString *jiemuFan_num;/**<节目粉丝数*/
@property(nonatomic)NSString *jiemuMessage_num;/**<节目消息数*/
@property(nonatomic)NSString *jiemuIs_fan;/**<是否该节目粉丝*/
@property(nonatomic)NSString *post_keywords;/**<新闻关键词*/
@property(nonatomic)NSString *url;/**<路径*/
@end
