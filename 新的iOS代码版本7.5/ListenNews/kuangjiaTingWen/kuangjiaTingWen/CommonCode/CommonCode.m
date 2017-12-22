//
//  CommonCode.m
//  reHeardTheNews
//
//  Created by Pop Web on 16/3/15.
//  Copyright © 2016年 paoguo. All rights reserved.
//

#import "CommonCode.h"

@implementation CommonCode

/**
 *  绘制纯色图片
 *
 *  @param color 颜色对象
 *  @param size  图片大小
 *
 *  @return 纯色图片
 */
+ (UIImage *)imageWithColor:(UIColor *)color size:(CGSize)size {
    
    CGRect rect = CGRectMake(0, 0, size.width, size.height);
    UIGraphicsBeginImageContext(rect.size);
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    CGContextSetFillColorWithColor(context, [color CGColor]);
    CGContextFillRect(context, rect);
    
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return image;
}
/**
 *  字数统计
 *
 *  @param string 要统计的字符串
 *
 *  @return 返回字数
 */
+ (int)countWord:(NSString *)string {
    int i,n=(int)[string length],l=0,a=0,b=0;
    unichar c;
    for(i=0;i<n;i++){
        c=[string characterAtIndex:i];
        if(isblank(c)){
            b++;
        }else if(isascii(c)){
            a++;
        }else{
            l++;
        }
    }
    if(a==0 && l==0) return 0;
    return l+(int)ceilf((float)(a+b)/2.0);
}
+ (void)writeToUserD:(id)obj andKey:(NSString *)key
{
    NSUserDefaults *userD = [NSUserDefaults standardUserDefaults];
    [userD setObject:obj forKey:key];
    [userD synchronize];
}
+ (id)readFromUserD:(NSString *)key
{
    NSUserDefaults *userD = [NSUserDefaults standardUserDefaults];
    return [userD objectForKey:key];
}

+ (void)deleteFromUserD:(NSString *)key
{
    NSUserDefaults *userD = [NSUserDefaults standardUserDefaults];
    [userD removeObjectForKey:key];
    [userD synchronize];
}

//+ (void)writeToShaHe:(id)obj andName:(NSString *)name
//{
//    //    //获取总的沙盒路径
//    //    NSLog(@"%@",NSHomeDirectory());
//    //    //获取 document 路径
//    NSDictionary *dict = [[NSDictionary alloc]init];
//    NSArray *arr1 = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
//    NSString *docPath = arr1[0];
//    //拼接完整文件路径
//    NSString *filePath = [docPath stringByAppendingPathComponent:@"ibokan.txt"];
//    //创建一个文件管理类
//    NSFileManager *fileM = [NSFileManager defaultManager];
//    //判断是否存在该文件
//    BOOL isExist = [fileM fileExistsAtPath:filePath];
//    if (!isExist)
//    {
//        //如果不存在，则创建一个
//        [fileM createFileAtPath:filePath contents:nil attributes:nil];
//    }else
//    {
//        //如果存在，就写入数据
////        [dict setValue:obj forKey:name];
//        NSMutableArray *arr = [NSMutableArray new];
//        [arr addObject:dict];
//        [arr writeToFile:filePath atomically:YES];
//    }
//}

+ (NSString *)filePath:(NSString *)fileName
{
    NSArray *arr1 = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *docPath = arr1[0];
    //拼接完整文件路径
    NSString *filePath = [docPath stringByAppendingPathComponent:fileName];
    return filePath;
}

//+ (NSString *)readFromShaHe:(NSString *)name
//{
//    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
//    NSString *docPath = paths[0];
//    NSString *filePath = [docPath stringByAppendingString:name];
//    return filePath;
//}

//+ (void)OpenSql:(NSString *)sqlName
//{
//    //1.获取数据库对象
//    NSString *SqlPath = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES)[0];
//    SqlPath = [SqlPath stringByAppendingPathComponent:sqlName];
//    FMDatabase *Database = [FMDatabase databaseWithPath:SqlPath];//1.1初始化数据库
//    
//    //2.打开数据库
//    BOOL isOpenSql = [Database open];
//    if (isOpenSql)
//    {
//        NSLog(@"数据库成功打开");
//    }
//}

//+ (void)setDataBaseHaoYouDongTaiTableToSql
//{
//    //1.获取数据库对象
//    NSString *SqlPath = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES)[0];
//    SqlPath = [SqlPath stringByAppendingPathComponent:@"TingWen.sqlite"];
//    FMDatabase *Database = [FMDatabase databaseWithPath:SqlPath];//1.1初始化数据库
//    
//    //2.打开数据库
//    BOOL isOpenSql = [Database open];
//    if (isOpenSql)
//    {
//        NSLog(@"数据库成功打开");
//    }
//    
//    //3.创建表
//    NSString *selfTableName = [NSString stringWithFormat:dataBaseHaoYouDongTaiTable(@"HaoYouDongTai", @"userId", @"User_Name", @"User_Img", @"Share_Time", @"Share_Info", @"News_Title", @"News_Size", @"News_Time", @"News_ID", @"News_Img")];
//    
//    BOOL isCrete1 = [Database executeUpdate:selfTableName];
//    if (isCrete1)
//    {
//        NSLog(@"创建表成功");
//    }
//    
//}
//
//+ (void)insertDataToHaoYouDongTaiSqlandUser_Name:(NSString *)User_Name andUser_Img:(UIImage *)User_Img
//                      andShare_Time:(NSString *)Share_Time andShare_Info:(NSString *)Share_Info
//                      andNews_Title:(NSString *)News_Title
//                       andNews_Size:(NSString *)News_Size andNews_Time:(NSString *)News_Time
//                         andNews_ID:(NSString *)News_ID andNews_Img:(NSString *)News_Img
//{
//    //1.获取数据库对象
//    NSString *SqlPath = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES)[0];
//    SqlPath = [SqlPath stringByAppendingPathComponent:@"HaoYouDongTai"];
//    FMDatabase *Database = [FMDatabase databaseWithPath:SqlPath];//1.1初始化数据库
//    
//    //2.打开数据库
//    BOOL isOpenSql = [Database open];
//    if (isOpenSql)
//    {
//        NSLog(@"数据库成功打开");
//    }
//    
//    //3.创建表
//    
//}

/**
 *  获取当前系统版本
 *  如果直接调用读取系统的方法， 可能出现一些问题
 *
 */
+ (NSString *)getCurrentSystemVersion {
    
    //静态全局变量  用来存系统版本，以便反复读取
    static NSString *currentVersion = nil;
    
    if (!currentVersion) {
        currentVersion = [User_Defaults objectForKey:@"currentSystemVersion"];
    }
    
    //当NSUserDefaults中没有值时，获取系统的版本并存进去
    if (!currentVersion) {
        currentVersion = [[UIDevice currentDevice] systemVersion];
        
        [User_Defaults setObject:currentVersion forKey:@"currentSystemVersion"];
        [User_Defaults synchronize];
    }
    
    return currentVersion;
}

/**
 *  区分IOS6以上的版本
 *
 *  @return 大于IOS6返回真
 */
+ (BOOL)greaterThanIOS6 {
    
    NSString *reqSysVer = @"7";
    NSString *currSysVer = [self getCurrentSystemVersion];
    if ([currSysVer compare:reqSysVer options:NSNumericSearch] != NSOrderedAscending) {
        return YES;
    }
    
    return NO;
}

/**
 *  判断是IOS8
 *
 */
+ (BOOL)isIOS8 {
    
    NSString *reqSysVer = @"8";
    NSString *currSysVer = [self getCurrentSystemVersion];
    if ([currSysVer compare:reqSysVer options:NSNumericSearch] != NSOrderedAscending) {
        return YES;
    }
    
    return NO;
}

/**
 *  判断是IOS9
 *
 */
+ (BOOL)isIOS9 {
    
    NSString *reqSysVer = @"9";
    NSString *currSysVer = [self getCurrentSystemVersion];
    if ([currSysVer compare:reqSysVer options:NSNumericSearch] != NSOrderedAscending) {
        return YES;
    }
    
    return NO;
}

+ (NSString *)stringContainsEmoji:(NSString *)string {
    
    __block BOOL returnValue    = NO;
    __block NSMutableArray *arr = [NSMutableArray array];
    [string enumerateSubstringsInRange:NSMakeRange(0, [string length])
                               options:NSStringEnumerationByComposedCharacterSequences
                            usingBlock:^(NSString *substring, NSRange substringRange, NSRange enclosingRange, BOOL *stop) {
                                const unichar hs            = [substring characterAtIndex:0];
                                if (0xd800 <= hs && hs <= 0xdbff) {
                                    if (substring.length > 1) {
                                        const unichar ls            = [substring characterAtIndex:1];
                                        const int uc                = ((hs - 0xd800) * 0x400) + (ls - 0xdc00) + 0x10000;
                                        if (0x1d000 <= uc && uc <= 0x1f77f) {
                                            returnValue                 = YES;
                                            [arr addObject:substring];
                                        }
                                    }
                                } else if (substring.length > 1) {
                                    const unichar ls            = [substring characterAtIndex:1];
                                    if (ls == 0x20e3) {
                                        returnValue                 = YES;
                                        [arr addObject:substring];
                                    }
                                } else {
                                    if (0x2100 <= hs && hs <= 0x27ff) {
                                        returnValue                 = YES;
                                        [arr addObject:substring];
                                    } else if (0x2B05 <= hs && hs <= 0x2b07) {
                                        returnValue                 = YES;
                                        [arr addObject:substring];
                                    } else if (0x2934 <= hs && hs <= 0x2935) {
                                        returnValue                 = YES;
                                        [arr addObject:substring];
                                    } else if (0x3297 <= hs && hs <= 0x3299) {
                                        returnValue                 = YES;
                                        [arr addObject:substring];
                                    } else if (hs == 0xa9 || hs == 0xae || hs == 0x303d || hs == 0x3030 || hs == 0x2b55 || hs == 0x2b1c || hs == 0x2b1b || hs == 0x2b50) {
                                        returnValue                 = YES;
                                        [arr addObject:substring];
                                    }
                                }
                            }];
    
    NSString *str = string;
    for (NSString *emoji in arr) {
        str = [str stringByReplacingOccurrencesOfString:emoji withString:[NSString stringWithFormat:@"[e1]%@[/e1]", [DSE encryptUseDES:emoji]]];
    }
    
    return str;
}

//针对含有Emoji表情的字符串进行解密
+ (NSString *)jiemiEmoji:(NSString *)emojiLabStr{
    NSArray *ejArray = [emojiLabStr componentsSeparatedByString:@"[e1]"];
    
    NSMutableArray *jieshou = [NSMutableArray array];
    
    for (NSString *str in ejArray)
    {
        
        NSArray *jieshouArr = [str componentsSeparatedByString:@"[/e1]"];
        [jieshou addObjectsFromArray:jieshouArr];
    }
    
    NSMutableArray *zuizhongArr = [NSMutableArray array];
    
    for (NSString *str in jieshou)
    {
        
        if ([DSE decryptUseDES:str].length)
        {
            [zuizhongArr addObject:[DSE decryptUseDES:str]];
        }else
        {
            [zuizhongArr addObject:str];
        }
        
    }
    NSString *zuizhongStr = [[NSString alloc]init];
    for (NSString *str in zuizhongArr)
    {
        zuizhongStr = [NSString stringWithFormat:@"%@%@",zuizhongStr,str];
    }
    return zuizhongStr;
    
}

+ (NSString *)desContner:(NSString *)string {
    NSMutableString *contentString = [NSMutableString string];
    
    if ([string  componentsSeparatedByString:@"[e1]"].count > 1) {
        NSArray *ejArray = [string  componentsSeparatedByString:@"[e1]"];
        [ejArray enumerateObjectsUsingBlock:^(id obj1, NSUInteger idx, BOOL *stop) {
            
            NSMutableString *suS = [NSMutableString string];
            if ([obj1  rangeOfString:@"[/e1]"].location != NSNotFound) {
                NSRange range = [obj1  rangeOfString:@"[/e1]"];
                NSString *rangeString = [obj1 substringToIndex:range.location];
                [suS appendString:[obj1 stringByReplacingOccurrencesOfString:[NSString stringWithFormat:@"%@[/e1]", rangeString] withString:@""]];
                obj1 = [DSE decryptUseDES:rangeString];
                
            }
            [contentString appendString:obj1];
            if (suS) {
                [contentString appendString:suS];
                suS = nil;
            }
        }];
    }else {
        [contentString appendString:string];
    }
    return contentString;
}

@end
