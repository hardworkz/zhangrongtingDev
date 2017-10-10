//
//  Post_actor.m
//  kuangjiaTingWen
//
//  Created by Zhimi on 16/9/11.
//  Copyright © 2016年 贺楠. All rights reserved.
//

#import "Post_actor.h"

@implementation Post_actor

- (instancetype)initWithDictionary:(NSDictionary *)dic{
    self = [super init];
    if (self) {
        [self setValuesForKeysWithDictionary:dic];
    }
    return self;
}


+ (Post_actor *)post_actorWithDictionary:(NSDictionary *)dic{
    return [[self alloc] initWithDictionary:dic];
}

- (void)setValue:(id)value forKey:(NSString *)key {
    if ([key isEqualToString:@"id"]) {
        self.i_id = value;
        return;
    }
    if ([key isEqualToString:@"description"]) {
        self.i_description = value;
        return;
    }
    
    
    [super setValue:value forKey:key];
}

@end
