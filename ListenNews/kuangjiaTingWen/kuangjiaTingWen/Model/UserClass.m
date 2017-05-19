//
//  UserClass.m
//  Heard the news
//
//  Created by Pop Web on 15/8/26.
//  Copyright (c) 2015年 泡果网络. All rights reserved.
//

#import "UserClass.h"

#import <objc/runtime.h>

@implementation UserClass

- (instancetype)initWithDictionary:(NSDictionary *)dic
{
    self = [super init];
    if (self) {
        [self setValuesForKeysWithDictionary:dic];
    }
    return self;
}

+ (UserClass *)userClassWithDictionary:(NSDictionary *)dic {
    return [[UserClass alloc] initWithDictionary:dic];
}

- (void)setValue:(id)value forKey:(NSString *)key  {
    if ([key isEqualToString:@"id"]) {
        self.i_id = value;
        return;
    }
    if ([key isEqualToString:@"signature"]) {
        if ([value isEqualToString:@"(null)"]) {
            value = @"没有简介";
        }
    }

    [super setValue:value forKey:key];

}

- (void)setValue:(id)value forUndefinedKey:(NSString *)key {
    self.guolv = value;
}

- (NSString *)description
{
    return [NSString stringWithFormat:@"%@", self.user_nicename];
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
