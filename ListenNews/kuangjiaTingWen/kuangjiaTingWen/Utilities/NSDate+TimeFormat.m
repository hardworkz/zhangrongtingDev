//
//  NSDate+TimeFormat.m
//  KangShiFu_Elearnning
//
//  Created by Eric Wang on 14/9/2.
//  Copyright (c) 2014年 Lin Yawen. All rights reserved.
//

#import "NSDate+TimeFormat.h"
#import "NSDate+TKCategory.h"


@implementation NSDate (TimeFormat)

- (NSString *)showTimeByTypeA{
//    if (self == nil) {
//        return @"刚刚";
//    }
    NSString *timeString = @"";
    NSDate *currentDate = [NSDate date];
    NSTimeInterval seconds = [currentDate timeIntervalSinceDate:self];
    if (seconds / 60 <= 1) {//一分钟之内
        timeString = @"刚刚";
    }
    else if (seconds / 60 > 1 && seconds / 3600 <= 1){//不到一分钟一小时
        timeString = [NSString stringWithFormat:@"%d 分钟前", (int)seconds / 60];
    }
    else if (seconds / 3600 > 1 && seconds / (3600 * 24) <=1){//一小时到24小时
        timeString = [NSString stringWithFormat:@"%d 小时前", (int)seconds / 3600];
    }
    else if ([self isYesterday]){
//        timeString = @"昨天";
         timeString = [self stringWithFormat:@"昨天 HH:mm"];
    }
    else if ([self isTheDayBeforeYestoday]){
        timeString = @"2天前";
    }
    else if ([self isThreeDaysago]){
        timeString = @"3天前";
    }
    else if ([self isSameYear:currentDate]){
        timeString = [self stringWithFormat:@"MM-dd HH:mm"];
    }
    else{
        timeString = [self stringWithFormat:@"yyyy-MM-dd"];
    }
//    timeString = [self stringWithFormat:@"yyyy-MM-dd"];

    return timeString;
}

+ (NSString *)showTimeByTypeB:(NSDate *)date{
    if (date == nil) {
        return @"刚刚";
    }
    NSString *timeString = @"";
    NSDate *currentDate = [NSDate date];
    NSTimeInterval seconds = [currentDate timeIntervalSinceDate:date];
    if (seconds / 60 <= 1) {//一分钟之内
        timeString = @"刚刚";
    }
    else if (seconds / 60 > 1 && seconds / 3600 <= 1){//一分钟到一小时
        timeString = [NSString stringWithFormat:@"%d 分钟前", (int)seconds / 60];
    }
    else if ([date isToday]){
        timeString = [date stringWithFormat:@"今天 HH:mm"];
    }
    else if ([date isYesterday]){
        timeString = [date stringWithFormat:@"昨天 HH:mm"];
    }
    else if ([date isTheDayBeforeYestoday]){
        timeString = [date stringWithFormat:@"前天 HH:mm"];
    }
    else if ([date isSameYear:[NSDate date]]){
        timeString = [date stringWithFormat:@"MM-dd HH:mm"];
    }
    else{
        timeString = [date stringWithFormat:@"yyyy-MM-dd HH:mm"];
    }
    return timeString;
}

+ (NSString *)showTimeByTypeC:(NSDate *)date{
    
//    return [NSDate showTimeByTypeB:date];

    
    if (date == nil) {
        return @"";
    }
    NSString *timeString = @"";
    if ([date isSameYear:[NSDate date]]){
        timeString = [date stringWithFormat:@"MM-dd HH:mm"];
    }
    else{
        timeString = [date stringWithFormat:@"yyyy-MM-dd HH:mm"];
    }
    return timeString;
}

+ (NSString *)showTimeByTypeD:(NSDate *)date{
    
    //    return [NSDate showTimeByTypeB:date];
    
    
    if (date == nil) {
        return @"";
    }
    NSString *timeString = @"";
    if ([date isSameYear:[NSDate date]]){
        timeString = [date stringWithFormat:@"ddMM月"];
    }
    else{
        timeString = [date stringWithFormat:@"ddMM月"];
    }
    return timeString;
}

-(NSString *)showTimeFormatB
{
    return [NSDate showTimeByTypeB:self];
}

-(NSString *)showTimeFormatD{
    
    return [NSDate showTimeByTypeD:self];
    
}
- (BOOL)isTheDayBeforeYestoday{
    NSDateComponents *comp = [[NSDate date] dateComponentsWithTimeZone:[NSTimeZone defaultTimeZone]];
	comp.day = comp.day - 2;
    NSDate *actualTheDayBeforYestoday = [NSDate dateWithDateComponents:comp];
    return [actualTheDayBeforYestoday isSameDay:self];
}

- (BOOL)isThreeDaysago{
    NSDateComponents *comp = [[NSDate date] dateComponentsWithTimeZone:[NSTimeZone defaultTimeZone]];
    comp.day = comp.day - 3;
    NSDate *actualTheDayBeforYestoday = [NSDate dateWithDateComponents:comp];
    return [actualTheDayBeforYestoday isSameDay:self];
}


+ (NSDate *)dateFromString:(NSString *)dateString {
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
    NSDate * destDate = [dateFormatter dateFromString:dateString];
    return destDate;
}

+ (NSDate *)dateFromString:(NSString *)dateString andDateWithFormat:(NSString *)format{
    if (!format) {
        format = @"yyyy-MM-dd HH:mm";
    };
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:format];
    NSDate * destDate = [dateFormatter dateFromString:dateString];
    return destDate;
}

- (NSString *)stringWithFormat:(NSString *)format{
    if (!format) {
        format = @"yyyy-MM-dd HH:mm";
        //        @"yyyy-MM-dd HH:mm:ss zzz"
    };
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    dateFormatter.timeZone = [NSTimeZone systemTimeZone];
    [dateFormatter setDateFormat:format];
    return [dateFormatter stringFromDate:self];
}

@end
