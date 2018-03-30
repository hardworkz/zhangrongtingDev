//
//  CommonCode.h
//  reHeardTheNews
//
//  Created by Pop Web on 16/3/15.
//  Copyright © 2016年 paoguo. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

///NSUserDefaults实例
#define User_Defaults [NSUserDefaults standardUserDefaults]

@interface CommonCode : NSObject

/**
 *  绘制纯色图片
 *
 *  @param color 颜色对象
 *  @param size  图片大小
 *
 *  @return 纯色图片
 */
+ (UIImage *)imageWithColor:(UIColor *)color size:(CGSize)size;
//用户第一次访问该app会做一个缓存标记
+ (void)writeToUserD:(id)obj andKey:(NSString *)key;//写入标记方法
+ (id)readFromUserD:(NSString *)key;//读标记方法
+ (void)deleteFromUserD:(NSString *)key;//删除所有标记
//+ (void)writeToShaHe:(id)obj andName:(NSString *)name;//向沙盒中写入数据
//+ (NSString *)readFromShaHe:(NSString *)name;//读取沙盒中的数据
+ (NSString *)filePath:(NSString *)fileName;//沙盒中file的地址
//+ (void)OpenSql:(NSString *)sqlName;//打开数据库
//+ (void)setDataBaseHaoYouDongTaiTableToSql;//创建好友动态表

/**
 *  字数统计
 *
 *  @param string 要统计的字符串
 *
 *  @return 返回字数
 */
+ (int)countWord:(NSString *)string;
+ (NSString *)desContner:(NSString *)string;

/**
 *  @brief 获取当前系统版本
 *
 */
+ (NSString *)getCurrentSystemVersion;

/**
 *  @brief 区分IOS6以上的版本
 *
 *  @return 大于IOS6返回真
 */
+ (BOOL)greaterThanIOS6;

/**
 *  @brief 判断是IOS8
 *
 */
+ (BOOL)isIOS8;

/**
 *  @brief 判断是IOS9
 *
 */
+ (BOOL)isIOS9;

/**
 *  Emoji解析上传
 *
 *  @param string 要解析的str
 *
 *  @return 解析后的str
 */
+ (NSString *)stringContainsEmoji:(NSString *)string;

/**
 *  针对含有Emoji表情的字符串进行解密
 *
 *  @param emojiLabStr 要解密的str
 *
 *  @return 解密结果
 */
+ (NSString *)jiemiEmoji:(NSString *)emojiLabStr;

@end
