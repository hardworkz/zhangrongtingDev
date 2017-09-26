//
//  NewObj.m
//  Heard the news
//
//  Created by Pop Web on 15/8/12.
//  Copyright (c) 2015年 泡果网络. All rights reserved.
//

#import <objc/runtime.h>

#import "NewObj.h"

#import "CommonCode.h"

//#import "UtilsMacro.h"

#import "SDImageCache.h"

#import "UIImageView+WebCache.h"

#import "WPAttributedStyleAction.h"

#import "NSString+WPAttributedMarkup.h"

#import "ProjiectDownLoadManager.h"

#import "ZhuBoClass.h"
#import "Post_actor.h"

//#import "SQLClass.h"

@implementation NewObj
+ (void)load
{
    [NewObj mj_setupReplacedKeyFromPropertyName:^NSDictionary *{
        return @{@"i_id":@"id"};
    }];
}
+ (instancetype)newObjWithDictionary:(NSDictionary*)dic {
    NewObj *newobg = [[NewObj alloc]init];
    if ([dic  isKindOfClass:[NSDictionary class]]) {
        [newobg setValuesForKeysWithDictionary:dic];
    }
    return newobg;
}

- (void)setValue:(id)value forKey:(NSString *)key {
    if ([key isEqualToString:@"id"]) {
        self.i_id = value;
        return;
    }
    
    if ([key isEqualToString:@"post_mp"]) {
        if ([value rangeOfString:@"//"].location == NSNotFound) {
            self.post_mp = [[ProjiectDownLoadManager defaultProjiectDownLoadManager].userDownLoadPath stringByAppendingPathComponent:value];
            return;
        }
    }
    
    if ([key isEqualToString:@"smeta"]) {
        NSString *str = value;
        NSArray *a = [str componentsSeparatedByString:@","];
        if ([a[0] rangeOfString:@"thumb"].location != NSNotFound) {
            self.smeta = [[[[a[0] stringByReplacingOccurrencesOfString:@"\\" withString:@""] stringByReplacingOccurrencesOfString:@"}" withString:@""] stringByReplacingOccurrencesOfString:@"{\"thumb\":" withString:@""]stringByReplacingOccurrencesOfString:@"\"" withString:@""];
            if ([self.smeta rangeOfString:@"http"].location == NSNotFound) {
                self.smeta = [NSString stringWithFormat:@"%@%@",APPHostAds,self.smeta];
            }
            return;
        }else if([value hasPrefix:@"http://"]){
            
        }else {
            self.smeta = [[ProjiectDownLoadManager defaultProjiectDownLoadManager].userDownLoadPathImage stringByAppendingPathComponent:value];
            return;
        }
    }
    
//    if ([key isEqualToString:@"post_time"]) {
//        self.timeInterval = [NSString stringWithFormat:@"%@", @([self getCurrTime:value])];
//        NSInteger timer = [value integerValue] / 1000;
//        if (timer >= 60) {
//            self.post_time = [NSString stringWithFormat:@"%ld:%ld", timer / 60, timer % 60];
//        }else {
//            self.post_time = [NSString stringWithFormat:@"00:%ld", timer];
//        }
//        return;
//    }
    //    if (DeviceWidth < 350) {
    //        if ([key isEqualToString:@"post_date"]) {
    //            self.post_date = [[value componentsSeparatedByString:@" "]firstObject];
    //
    //            return;
    //        }
    //    }else {
    //        if ([key isEqualToString:@"post_date"]) {
    //            self.post_date = value;
    //
    //            return;
    //        }
    //    }
    
    if ([key isEqualToString:@"post_size"]) {
        if ([value rangeOfString:@"M"].location == NSNotFound) {
            CGFloat size = [value floatValue];
            self.post_size = [NSString stringWithFormat:@"%.2fM", size / (1024 * 1024)];
        }else {
            self.post_size = value;
        }
        return;
    }
    
//    if ([key isEqualToString:@"post_actor"]) {
//        Post_actor *post_actor = [[Post_actor alloc]init];
//        if ([self.post_act  isKindOfClass:[NSDictionary class]]) {
//            [post_actor setValuesForKeysWithDictionary:self.post_act];
//            self.post_act = post_actor;
//        }
//        return ;
//    }
    
    [super setValue:value forKey:key];
}

#pragma mark - 过滤多余的参数
- (void)setValue:(id)value forUndefinedKey:(NSString *)key {
    _guolv = value;
}

#pragma mark - 生成HTML代码
/**
 *  生成iPhone的HTML内容
 *
 *  @param newsItem 要生成的新闻
 *
 */
+ (NSArray *)generationHTMLWithNews:(NewObj *)newsItem {
    
    NSString *htmlSource = Detail_HTML_IPhone;
    
    NSString *fontSize = [[NSUserDefaults standardUserDefaults] objectForKey:@"fontSize"];
    
    CGRect rect;
    
    CGFloat higt;
    //根据设置判断字体大小来生成Html源码
    if ([fontSize isEqualToString:@"小"]) {
        
        htmlSource = [htmlSource stringByAppendingString:@"#newsTitle {font-size:18px;} #postTimeAndLaizi{color:#808080;font-size:13px;} #newsContent {font-size:17px;font-family:arial; text-align:justify; text-justify:inter-ideograph; line-height:1.5;}</style></head><body>"];
        higt = 18;
        rect = [newsItem.post_excerpt boundingRectWithSize:CGSizeMake(SCREEN_WIDTH, 0) options:NSStringDrawingUsesLineFragmentOrigin | NSStringDrawingUsesFontLeading attributes:@{NSFontAttributeName : [UIFont systemFontOfSize:17]} context:nil];
        
    } else if ([fontSize isEqualToString:@"中"]) {
        higt = 20;
        
        htmlSource = [htmlSource stringByAppendingString:@"#newsTitle {font-size:20px;} #postTimeAndLaizi{color:#808080;font-size:15px;} #newsContent {font-size:19px;font-family:arial; text-align:justify; text-justify:inter-ideograph; line-height:1.5;}</style></head><body>"];
        rect = [newsItem.post_excerpt boundingRectWithSize:CGSizeMake(SCREEN_WIDTH, 0) options:NSStringDrawingUsesLineFragmentOrigin | NSStringDrawingUsesFontLeading attributes:@{NSFontAttributeName : [UIFont systemFontOfSize:19]} context:nil];
    } else if ([fontSize isEqualToString:@"大"]) {
        higt = 22;
        
        htmlSource = [htmlSource stringByAppendingString:@"#newsTitle {font-size:22px;} #postTimeAndLaizi{color:#808080;font-size:16px;} #newsContent {font-size:21px;font-family:arial; text-align:justify; text-justify:inter-ideograph; line-height:1.5;}</style></head><body>"];
        rect = [newsItem.post_excerpt boundingRectWithSize:CGSizeMake(SCREEN_WIDTH, 0) options:NSStringDrawingUsesLineFragmentOrigin | NSStringDrawingUsesFontLeading attributes:@{NSFontAttributeName : [UIFont systemFontOfSize:21]} context:nil];
    } else if ([fontSize isEqualToString:@"超大"]) {
        higt = 22;
        
        htmlSource = [htmlSource stringByAppendingString:@"#newsTitle {font-size:22px;} #postTimeAndLaizi{color:#808080;font-size:16px;} #newsContent {font-size:23px;font-family:arial; text-align:justify; text-justify:inter-ideograph; line-height:1.5;}</style></head><body>"];
        rect = [newsItem.post_excerpt boundingRectWithSize:CGSizeMake(SCREEN_WIDTH, 0) options:NSStringDrawingUsesLineFragmentOrigin | NSStringDrawingUsesFontLeading attributes:@{NSFontAttributeName : [UIFont systemFontOfSize:23]} context:nil];
    } else if ([fontSize isEqualToString:@"巨大"]) {
        higt = 22;
        
        htmlSource = [htmlSource stringByAppendingString:@"#newsTitle {font-size:22px;} #postTimeAndLaizi{color:#808080;font-size:16px;} #newsContent {font-size:25px;font-family:arial; text-align:justify; text-justify:inter-ideograph; line-height:1.5;}</style></head><body>"];
        rect = [newsItem.post_excerpt boundingRectWithSize:CGSizeMake(SCREEN_WIDTH, 0) options:NSStringDrawingUsesLineFragmentOrigin | NSStringDrawingUsesFontLeading attributes:@{NSFontAttributeName : [UIFont systemFontOfSize:25]} context:nil];
    } else if ([fontSize isEqualToString:@"巨无霸"]) {
        higt = 22;
        
        htmlSource = [htmlSource stringByAppendingString:@"#newsTitle {font-size:22px;} #postTimeAndLaizi{color:#808080;font-size:16px;} #newsContent {font-size:27px;font-family:arial; text-align:justify; text-justify:inter-ideograph; line-height:1.5;}</style></head><body>"];
        
        rect = [newsItem.post_excerpt boundingRectWithSize:CGSizeMake(SCREEN_WIDTH, 0) options:NSStringDrawingUsesLineFragmentOrigin | NSStringDrawingUsesFontLeading attributes:@{NSFontAttributeName : [UIFont systemFontOfSize:27]} context:nil];
    }
    
    //生成标题
    htmlSource = [htmlSource stringByAppendingFormat:@"<h3><span id = \"newsTitle\">%@</span></h3>", newsItem.post_title];
    
    //    htmlSource = [htmlSource stringByAppendingFormat:@"<h3><div style=\"position: width:100px; height:60px;\"><img  style=\"position:relative;float:left;width:%@px;height:%@px; -moz-border-radius:30px;-webkit-border-radius:30px;border-radius:30px; \"src=\"%@\";><input style=\"position:relative;margin-left:100px;\" type=\"button\" value=\"关注\" onclick=\"WebViewJavascriptBridge.sendMessage('takePhotoTag')\"/><input style=\"position:relative;float:right;\" type=\"button\" value=\"关注\" onclick=\"WebViewJavascriptBridge.sendMessage('takePhotoTag')\"/><span id = \"zhubo\"> </span></div>%@</h3>", @(60),@(60),newsItem.smeta, @""];
    
    
    //生成发表时间和来源
    htmlSource = [htmlSource stringByAppendingFormat:@"<p><span id = \"postTimeAndLaizi\">日期:%@ &nbsp;来自:%@</span></p>", newsItem.post_date, newsItem.post_lai];
    
    //    htmlSource = [htmlSource stringByAppendingFormat:@"<h3><p id = \"zhubo\">                       <div style=\"position: width:%@px; height:60px;\">                                                                        <div style=\"position:relative;float:left; width:60px; height:60px;\">                         <img  style=\"position:width:60px;height:60px; -moz-border-radius:30px;-webkit-border-radius:30px;border-radius:30px; \"src=\"%@\";  onclick=\"WebViewJavascriptBridge.sendMessage('takePhotoTag1')\"/></div>                                                                 <div style=\"position:relative;margin-left:60px; width:100px; height:60px;overflow:hidden;text-overflow:ellipsis;white-space:nowrap;\">                                                                        <div  style=\"position:relative;margin-left:5px; width:100px; height:30px;color:#808080;font-size:15px;\"><nobr style= \"display:block; word-break:keep-all; white-space:nowrap;overflow:hidden;text-overflow:ellipsis;\">小主播啊啊啊啊啊啊啊啊啊啊啊</nobr ></div><div  style=\"position:relative;margin-left:5px; width:100px; height:30px;color:#808080;font-size:13px; display:block; word-break:keep-all; white-space:nowrap;overflow:hidden;text-overflow:ellipsis;\"><nobr >大梦想啊啊啊啊啊啊啊啊啊啊啊</nobr ></div></div>                                                                  <div ><input type=\"button\" value=\"关注\" style=\"color:red;background:white;position:relative; float:right;top:-40px;width:50; height:20px; border:1px solid B3B3B3;\"   onclick=\"WebViewJavascriptBridge.sendMessage('takePhotoTag')\"/></div>                                                                  </div>                                                                       </p></h3>", @(DeviceWidth),newsItem.smeta];
    //    [UIColor whiteColor]
    //生成图片
    //    if (![[[SDImageCache sharedImageCache] defaultCachePathForKey:PHOTOHTTPSTRING(newsItem.smeta)] isEqualToString:[SDImageCache sharedImageCache].diskCachePath]) {
    //                htmlSource = [htmlSource stringByAppendingFormat:@"<img id = \"BigImage\" src=\"%@\" alt=\"\" />", PHOTOHTTPSTRING(newsItem.smeta)];
    //    }
    
    //生成图片
    NSString *imagePath;
    if ([newsItem.smeta rangeOfString:@"userDownLoadPathImage"].location != NSNotFound) {
        imagePath = newsItem.smeta;
    }else {
        imagePath = [[NSBundle mainBundle] pathForResource:@"thumbnailsdefault" ofType:@"png"];
    }
    
    htmlSource = [htmlSource stringByAppendingFormat:@"<img id = \"BigImage\" src=\"file://%@\"style=\"width:%@px;height:%@px;\"alt=\"\" />", imagePath, @(SCREEN_WIDTH), @(SCREEN_WIDTH * 0.5)];
    
    //生成内容
    htmlSource = [[htmlSource stringByAppendingFormat:@"<p id = \"newsContent\">%@</p><br /><br /><br /><br /></html>", newsItem.post_excerpt]stringByReplacingOccurrencesOfString:@"\n" withString:@"<br/>"];
    
    return @[htmlSource, @(rect.size.height + SCREEN_WIDTH / 2)];
}

+ (NSArray *)generationHTMLWithNews:(NewObj *)newsItem AndZhuBo:(Post_actor *)zhubo{
    
    NSString *htmlSource = Detail_HTML_IPhone;
    
    NSString *fontSize = [[NSUserDefaults standardUserDefaults] objectForKey:@"fontSize"];
    
    CGRect rect;
    
    CGFloat higt;
    //根据设置判断字体大小来生成Html源码
    if ([fontSize isEqualToString:@"小"]) {
        
        htmlSource = [htmlSource stringByAppendingString:@"#newsTitle {font-size:18px;} #postTimeAndLaizi{color:#808080;font-size:13px;} #newsContent {font-size:17px;font-family:arial; text-align:justify; text-justify:inter-ideograph; line-height:1.5;}</style></head><body>"];
        higt = 18;
        rect = [newsItem.post_excerpt boundingRectWithSize:CGSizeMake(SCREEN_WIDTH, 0) options:NSStringDrawingUsesLineFragmentOrigin | NSStringDrawingUsesFontLeading attributes:@{NSFontAttributeName : [UIFont systemFontOfSize:17]} context:nil];
        
    } else if ([fontSize isEqualToString:@"中"]) {
        higt = 20;
        
        htmlSource = [htmlSource stringByAppendingString:@"#newsTitle {font-size:20px;} #postTimeAndLaizi{color:#808080;font-size:15px;} #newsContent {font-size:19px;font-family:arial; text-align:justify; text-justify:inter-ideograph; line-height:1.5;}</style></head><body>"];
        rect = [newsItem.post_excerpt boundingRectWithSize:CGSizeMake(SCREEN_WIDTH, 0) options:NSStringDrawingUsesLineFragmentOrigin | NSStringDrawingUsesFontLeading attributes:@{NSFontAttributeName : [UIFont systemFontOfSize:19]} context:nil];
    } else if ([fontSize isEqualToString:@"大"]) {
        higt = 22;
        
        htmlSource = [htmlSource stringByAppendingString:@"#newsTitle {font-size:22px;} #postTimeAndLaizi{color:#808080;font-size:16px;} #newsContent {font-size:21px;font-family:arial; text-align:justify; text-justify:inter-ideograph; line-height:1.5;}</style></head><body>"];
        rect = [newsItem.post_excerpt boundingRectWithSize:CGSizeMake(SCREEN_WIDTH, 0) options:NSStringDrawingUsesLineFragmentOrigin | NSStringDrawingUsesFontLeading attributes:@{NSFontAttributeName : [UIFont systemFontOfSize:21]} context:nil];
    } else if ([fontSize isEqualToString:@"超大"]) {
        higt = 22;
        
        htmlSource = [htmlSource stringByAppendingString:@"#newsTitle {font-size:22px;} #postTimeAndLaizi{color:#808080;font-size:16px;} #newsContent {font-size:23px;font-family:arial; text-align:justify; text-justify:inter-ideograph; line-height:1.5;}</style></head><body>"];
        rect = [newsItem.post_excerpt boundingRectWithSize:CGSizeMake(SCREEN_WIDTH, 0) options:NSStringDrawingUsesLineFragmentOrigin | NSStringDrawingUsesFontLeading attributes:@{NSFontAttributeName : [UIFont systemFontOfSize:23]} context:nil];
    } else if ([fontSize isEqualToString:@"巨大"]) {
        higt = 22;
        
        htmlSource = [htmlSource stringByAppendingString:@"#newsTitle {font-size:22px;} #postTimeAndLaizi{color:#808080;font-size:16px;} #newsContent {font-size:25px;font-family:arial; text-align:justify; text-justify:inter-ideograph; line-height:1.5;}</style></head><body>"];
        rect = [newsItem.post_excerpt boundingRectWithSize:CGSizeMake(SCREEN_WIDTH, 0) options:NSStringDrawingUsesLineFragmentOrigin | NSStringDrawingUsesFontLeading attributes:@{NSFontAttributeName : [UIFont systemFontOfSize:25]} context:nil];
    } else if ([fontSize isEqualToString:@"巨无霸"]) {
        higt = 22;
        
        htmlSource = [htmlSource stringByAppendingString:@"#newsTitle {font-size:22px;} #postTimeAndLaizi{color:#808080;font-size:16px;} #newsContent {font-size:27px;font-family:arial; text-align:justify; text-justify:inter-ideograph; line-height:1.5;}</style></head><body>"];
        
        rect = [newsItem.post_excerpt boundingRectWithSize:CGSizeMake(SCREEN_WIDTH, 0) options:NSStringDrawingUsesLineFragmentOrigin | NSStringDrawingUsesFontLeading attributes:@{NSFontAttributeName : [UIFont systemFontOfSize:27]} context:nil];
    }
    
    //生成标题
    htmlSource = [htmlSource stringByAppendingFormat:@"<h3><span id = \"newsTitle\">%@</span></h3>", newsItem.post_title];
    
    //    htmlSource = [htmlSource stringByAppendingFormat:@"<h3><div style=\"position: width:100px; height:60px;\"><img  style=\"position:relative;float:left;width:%@px;height:%@px; -moz-border-radius:30px;-webkit-border-radius:30px;border-radius:30px; \"src=\"%@\";><input style=\"position:relative;margin-left:100px;\" type=\"button\" value=\"关注\" onclick=\"WebViewJavascriptBridge.sendMessage('takePhotoTag')\"/><input style=\"position:relative;float:right;\" type=\"button\" value=\"关注\" onclick=\"WebViewJavascriptBridge.sendMessage('takePhotoTag')\"/><span id = \"zhubo\"> </span></div>%@</h3>", @(60),@(60),newsItem.smeta, @""];
    
    
    //生成发表时间和来源
    htmlSource = [htmlSource stringByAppendingFormat:@"<p><span id = \"postTimeAndLaizi\">日期:%@ &nbsp;来自:%@</span></p>", newsItem.post_date, newsItem.post_lai];
    
    if (zhubo.images.length) {
        htmlSource = [htmlSource stringByAppendingFormat:@"<h3><p id = \"zhubo\">                       <div style=\"position: width:%@px; height:40px;\">                                                                        <div  style=\"position:relative;float:left; width:40px; height:40px;\">                         <img  style=\"position:-moz-border-radius:20px;-webkit-border-radius:20px;border-radius:20px;width:40px;height:40px;\"src=\"%@\";  onclick=\"WebViewJavascriptBridge.sendMessage('takePhotoTag1')\"/></div>                                                                 <div style=\"position:relative;margin-left:40px; width:200px; height:40px;overflow:hidden;text-overflow:ellipsis;white-space:nowrap;\">                                                                        <div  style=\"position:relative;margin-left:10px; width:200px; height:20px;color:#808080;font-size:15px;\" onclick=\"WebViewJavascriptBridge.sendMessage('takePhotoTag1')\"/><nobr style= \"display:block; word-break:keep-all; white-space:nowrap;overflow:hidden;text-overflow:ellipsis;\">%@</nobr ></div><div  style=\"position:relative;margin-left:10px; width:190px; height:20px;color:#808080;font-size:13px; display:block; word-break:keep-all; white-space:nowrap;overflow:hidden;text-overflow:ellipsis;\"onclick=\"WebViewJavascriptBridge.sendMessage('takePhotoTag1')\"/><nobr >%@</nobr ></div></div>                                                                  <div ><input type=\"button\" id = \"buttonID\" value=\"关注\" style=\"color:red;background-color: transparent;position:relative; float:right;top:-35px;width:50; height:25px; border:1px solid B3B3B3;\"   onclick=\"WebViewJavascriptBridge.sendMessage('takePhotoTag')\"/></div>                                                                  </div>                                                                       </p></h3>", @(SCREEN_WIDTH),USERPHOTOHTTPSTRINGZhuBo(zhubo.images),zhubo.name,zhubo.i_description.length ? zhubo.i_description : @"主播很懒什么也没留下"];
    }else {
        NSString *zhuPath = [[NSBundle mainBundle] pathForResource:@"user-5" ofType:@"png"];
        
        NSURL *imageURL = [NSURL fileURLWithPath:zhuPath];

       htmlSource = [htmlSource stringByAppendingFormat:@"<h3><p id = \"zhubo\">                       <div style=\"position: width:%@px; height:40px;\">                                                                        <div  style=\"position:relative;float:left; width:40px; height:40px;\">                         <img  style=\"position:-moz-border-radius:20px;-webkit-border-radius:20px;border-radius:20px;width:40px;height:40px;\"src=\"%@\";  onclick=\"WebViewJavascriptBridge.sendMessage('takePhotoTag1')\"/></div>                                                                 <div style=\"position:relative;margin-left:40px; width:200px; height:40px;overflow:hidden;text-overflow:ellipsis;white-space:nowrap;\">                                                                        <div  style=\"position:relative;margin-left:10px; width:200px; height:20px;color:#808080;font-size:15px;\"><nobr style= \"display:block; word-break:keep-all; white-space:nowrap;overflow:hidden;text-overflow:ellipsis;\">%@</nobr > </div><div  style=\"position:relative;margin-left:10px; width:190px; height:20px;color:#808080;font-size:13px; display:block; word-break:keep-all; white-space:nowrap;overflow:hidden;text-overflow:ellipsis;\"><nobr >%@</nobr ></div></div>                                                                  <div ><input type=\"button\" id = \"buttonID\" value=\"关注\" style=\"color:red;background-color: transparent;position:relative; float:right;top:-35px;width:50; height:25px; border:1px solid B3B3B3;\"   onclick=\"WebViewJavascriptBridge.sendMessage('takePhotoTag')\"/></div>                                                                  </div>                                                                       </p></h3>", @(SCREEN_WIDTH),imageURL,zhubo.name,zhubo.i_description.length ? zhubo.i_description : @"主播很懒什么也没留下"];
    }

    //生成图片
    NSString *imagePath;
    if ([newsItem.smeta rangeOfString:@"userDownLoadPathImage"].location != NSNotFound) {
        imagePath = newsItem.smeta;
        htmlSource = [htmlSource stringByAppendingFormat:@"<img id = \"BigImage\" src=\"file://%@\"style=\"width:%@px;height:%@px;\"alt=\"\" \"   onclick=\"WebViewJavascriptBridge.sendMessage('takePhotoTag2')\"/>", imagePath, @(SCREEN_WIDTH), @(SCREEN_WIDTH * 0.5)];

    }else {
        imagePath = [[NSBundle mainBundle] pathForResource:@"thumbnailsdefault" ofType:@"png"]; 
//       NSURL *  imageUrl = [NSURL fileURLWithPath:[[NSBundle mainBundle] pathForResource:@"thumbnailsdefault" ofType:@"png"]];
        htmlSource = [htmlSource stringByAppendingFormat:@"<img id = \"BigImage\" src=\"file://%@\"style=\"width:%@px;height:%@px;\"alt=\"\" \"   onclick=\"WebViewJavascriptBridge.sendMessage('takePhotoTag2')\"/>", imagePath, @(SCREEN_WIDTH), @(SCREEN_WIDTH * 0.5)];

    }
    
    //生成内容
    htmlSource = [[htmlSource stringByAppendingFormat:@"<p id = \"newsContent\">%@</p><br /><br /><br /><br /></html>", newsItem.post_excerpt] stringByReplacingOccurrencesOfString:@"\n" withString:@"<br/>"];
    
    return @[htmlSource, @(rect.size.height + SCREEN_WIDTH / 2)];
}

- (NSTimeInterval)getCurrTime:(NSString *)string  {

    NSString *dateStr= string;
    NSDateFormatter *format=[[NSDateFormatter alloc] init];
    [format setDateFormat:@"yyyyMMdd"];
    NSDate *fromdate=[format dateFromString:dateStr];
    NSTimeInterval timeInterval = fromdate.timeIntervalSince1970;
    return timeInterval;
}
/* 获取对象的所有属性的内容 */
- (NSDictionary *)getAllPropertiesAndVaules
{
    NSMutableString *str = [NSMutableString string];
    NSMutableDictionary *dic = [NSMutableDictionary dictionary];
    unsigned int outCount, i;
    objc_property_t *properties = class_copyPropertyList([self class], &outCount);
    for (i = 0; i<outCount; i++)
    {
        objc_property_t property = properties[i];
        const char* char_f = property_getName(property);
        NSString *propertyName = [NSString stringWithUTF8String:char_f];
        id propertyValue = [self valueForKey:(NSString *)propertyName];
        [dic setValue:propertyValue forKey:propertyName];
        
        [str appendString:[NSString stringWithFormat:@"'%@',", propertyValue]];
    }
    free(properties);
    return dic;
}

@end
