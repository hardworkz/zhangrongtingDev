//
//  ClassModel.m
//  kuangjiaTingWen
//
//  Created by 泡果 on 2017/6/2.
//  Copyright © 2017年 zhimi. All rights reserved.
//

#import "ClassModel.h"

@implementation ClassModel
+ (void)load
{
    [ClassModel mj_setupReplacedKeyFromPropertyName:^NSDictionary *{
        return @{@"ID":@"id"};
    }];
}
+ (NSDictionary *)mj_objectClassInArray
{
    return @{@"shiting":[ClassAuditionListModel class],@"comments":[ClassCommentListModel class]};
}
- (NSMutableArray *)imagesArray
{
    NSMutableArray *urls = [NSMutableArray new];
    if (![_images isEqualToString:@""]){
        NSArray *array = [_images componentsSeparatedByString:@","];
        for (int i = 0 ; i < array.count ; i ++ ) {
            [urls addObject:array[i]];
        }
    }
    return urls;
}
@end
