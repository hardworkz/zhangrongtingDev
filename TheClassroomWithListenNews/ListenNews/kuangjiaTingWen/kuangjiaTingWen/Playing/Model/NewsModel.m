//
//  NewsModel.m
//  kuangjiaTingWen
//
//  Created by 泡果 on 2017/5/9.
//  Copyright © 2017年 zhimi. All rights reserved.
//

#import "NewsModel.h"

@implementation NewsModel
- (NSString *)jiemuID
{
    return _jiemuID == nil?@"":_jiemuID;
}
- (NSString *)Titlejiemu
{
    return _Titlejiemu == nil?@"":_Titlejiemu;
}
- (NSString *)RiQijiemu
{
    return _RiQijiemu == nil?@"":_RiQijiemu;
}
- (NSString *)post_lai
{
    return _post_lai == nil?@"":_post_lai;
}
- (NSString *)ImgStrjiemu
{
    NSString *imgUrl = [NSString stringWithFormat:@"%@",[_ImgStrjiemu stringByReplacingOccurrencesOfString:@"\\" withString:@""]];
    NSString *imgUrl1 = [imgUrl stringByReplacingOccurrencesOfString:@"\"" withString:@""];
    NSString *imgUrl2 = [imgUrl1 stringByReplacingOccurrencesOfString:@"thumb:" withString:@""];
    NSString *imgUrl3 = [imgUrl2 stringByReplacingOccurrencesOfString:@"{" withString:@""];
    NSString *imgUrl4 = [imgUrl3 stringByReplacingOccurrencesOfString:@"}" withString:@""];
    return _ImgStrjiemu == nil?@"":imgUrl4;
}
- (NSString *)ZhengWenjiemu
{
    return _ZhengWenjiemu == nil?@"":_ZhengWenjiemu;
}
- (NSString *)post_news
{
    return _post_news == nil?@"":_post_news;
}
- (NSString *)praisenum
{
    return _praisenum == nil?@"":_praisenum;
}
- (NSString *)post_mp
{
    return _post_mp == nil?@"":_post_mp;
}
- (NSString *)post_time
{
    return _post_time == nil?@"":_post_time;
}
- (NSString *)jiemuName
{
    return _jiemuName == nil?@"":_jiemuName;
}
- (NSString *)jiemuDescription
{
    return _jiemuDescription == nil?@"":_jiemuDescription;
}
- (NSString *)jiemuImages
{
    return _jiemuImages == nil?@"":_jiemuImages;
}
- (NSString *)jiemuFan_num
{
    return _jiemuFan_num == nil?@"":_jiemuFan_num;
}
- (NSString *)jiemuMessage_num
{
    return _jiemuMessage_num == nil?@"":_jiemuMessage_num;
}
- (NSString *)jiemuIs_fan
{
    return _jiemuIs_fan == nil?@"":_jiemuIs_fan;
}
- (NSString *)post_keywords
{
    return _post_keywords == nil?@"":_post_keywords;
}
- (NSString *)url
{
    return _url == nil?@"":_url;
}
@end
