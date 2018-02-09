//
//  Post_actor.h
//  kuangjiaTingWen
//
//  Created by Zhimi on 16/9/11.
//  Copyright © 2016年 贺楠. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Post_actor : NSObject

@property (nonatomic, copy) NSString *i_id;
@property (nonatomic, copy) NSString *name;
@property (nonatomic, copy) NSString *i_description;
@property (nonatomic, copy) NSString *images;
@property (nonatomic, copy) NSString *fan_num;
@property (nonatomic, copy) NSString *message_num;
@property (nonatomic, copy) NSString *is_fan;

+ (Post_actor *)post_actorWithDictionary:(NSDictionary *)dic;

@end
