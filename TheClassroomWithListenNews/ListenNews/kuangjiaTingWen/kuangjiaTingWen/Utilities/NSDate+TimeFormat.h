//
//  NSDate+TimeFormat.h
//  KangShiFu_Elearnning
//
//  Created by Eric Wang on 14/9/2.
//  Copyright (c) 2014年 Lin Yawen. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSDate (TimeFormat)

/*时间规则
 
 规则A 1分钟内发布的微博，标注为“刚刚”。超过1分钟至60分钟内的微博，标注具体分钟数，例“5分钟前”超过1小时至24小时内的微博，标注具体小时数，例“16小时前”超过1天至2天内的微博，标注为“昨天”超过2天至3天内的微博，标注为“前天”超过3天的微博，若发布时间在今年，根据发布时间进行标注，例   如“01.06”若发布时间超过1年，则还需显示具体月份“2013.04.03”
 */
- (NSString *)showTimeByTypeA;

/*
 规则B 1分钟内发布的微博，标注为“刚刚”。若发布时间在1小时，内则显示XX分钟前；若发布时间超过1小时，则显示具体时间：今天 10:00若发布时间在昨天，则显示：昨天 10:00若发布时间在前天，则显示：前天 10:00若发布时间超过3天并且在今年，则显示：06.01 10:00若发布时间超过今年，则显示：2013.06.01 10:00
 */
//- (NSString *)showTimeByTypeB:(NSDate *)date;

/**
 *  规则C
 *
 *  若发布时间在今年内，则显示具体月日和时间 例如当前年份为2014年， 则显示 08-01 15:47
 *  若发布时间不在今年内，则显示具体年月日和时间 例如显示年份为2012年， 则显示 2012-08-01 15:47
 *
 *  @param date 日期
 *
 *  @return 返回时间规则C的字符串日期
 */
//+ (NSString *)showTimeByTypeC:(NSDate *)date;


-(NSString *)showTimeFormatB;



-(NSString *)showTimeFormatD;

/**
 *  日期是否为前天
 *
 *  @return YES为前天
 */
- (BOOL)isTheDayBeforeYestoday;

/*
 * 字符串日期转换为NSDate
 * 输入的日期字符串形如：@"2014-12-08 13:08:08"
 *
 *  @param dateString 字符串格式日期
 *
 *  @return 返回时间NSDate
 */
+ (NSDate *)dateFromString:(NSString *)dateString;

/*
 * 字符串日期转换为NSDate
 *
 *  @param dateString 字符串格式日期
 *  @param format 时间格式，比如 default @"yyyy-MM-dd HH:mm";
 *
 *  @return 返回时间NSDate
 */
+ (NSDate *)dateFromString:(NSString *)dateString andDateWithFormat:(NSString *)format;

- (NSString *)stringWithFormat:(NSString *)format;

@end
