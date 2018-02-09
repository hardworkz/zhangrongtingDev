//
//  ZhuBoClass.m
//  Heard the news
//
//  Created by 温仲斌 on 15/12/23.
//  Copyright © 2015年 泡果网络. All rights reserved.
//

#import "ZhuBoClass.h"

@implementation ZhuBoClass

- (instancetype)initWithDictionary:(NSDictionary *)dic
{
    self = [super init];
    if (self) {
        [self setValuesForKeysWithDictionary:dic];
    }
    return self;
}

+ (ZhuBoClass *)userClassWithDictionary:(NSDictionary *)dic {
    return [[self alloc] initWithDictionary:dic];
}

-(void)setValue:(id)value forKey:(NSString *)key {
    if ([key isEqualToString:@"post_content"]) {
        NSArray *arr = [value componentsSeparatedByString:@"http:"];
        NSMutableArray *images = [NSMutableArray array];
        [arr enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            if ([obj rangeOfString:@"//admin.tingwen.me/data/"].location != NSNotFound) {
                NSString *suPath = [obj componentsSeparatedByString:@"\" style="][0];
                [images addObject:[NSString stringWithFormat:@"http:%@", suPath]];
                //                NSLog(@"%@", [NSString stringWithFormat:@"http:%@", suPath]);
            }
        }];
        self.imagess = images;
    }
    
    if ([key isEqualToString:@"images"]) {
        if ([value rangeOfString:@"/data/upload"].location == NSNotFound) {
            value = [NSString stringWithFormat:@"/data/upload/%@", value];
        }
    }
    if ([key isEqualToString:@"description"]) {
        self.signature = value;
    }
    
    
    
    if ([key isEqualToString:@"id"]) {
        self.i_id = value;
    }else {
        [super setValue:value forKey:key];
    }
}

- (void)setValue:(id)value forUndefinedKey:(NSString *)key {
    self.guolv = value;
}

@end
