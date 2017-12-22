//
//  NSString+Check.h
//  Demo
//
//  Created by Eric Wang on 15/7/5.
//  Copyright (c) 2015年 Eric. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSString (Check)

/**
 *  是否为有效的Email地址
 *
 *  @return 是否有效
 */
- (BOOL)isValidEmail;

/**
 *  是否为有效的手机号码
 *
 *  @return 是否有效
 */
- (BOOL)isValidPhone;

/**
 *  发布房源是否是有效的楼层信息
 */
- (BOOL)isValidFloor;

/**
 *  是否为空字符串
 *
 *  @return 是否为空
 */
- (BOOL)isEmpty;

-(BOOL)isChinese;

/**
 *  是否为字母或数字且由6-20位组成
 *
 *  @return 是否有效
 */
-(BOOL)isLetterOrNum;

//是否为字母或中文
-(BOOL)isLetterOrChinese;

- (NSString *)trimWhitespace;

- (NSUInteger)numberOfLines;

@end
