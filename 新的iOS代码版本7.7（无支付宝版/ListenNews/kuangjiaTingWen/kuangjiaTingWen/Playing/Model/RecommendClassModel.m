//
//  RecommendClassModel.m
//  kuangjiaTingWen
//
//  Created by 泡果 on 2018/3/2.
//  Copyright © 2018年 zhimi. All rights reserved.
//

#import "RecommendClassModel.h"

@implementation RecommendClassModel
+ (void)load
{
    [PlayVCCommentModel mj_setupReplacedKeyFromPropertyName:^NSDictionary *{
        return @{@"ID":@"id",@"Description":@"description"};
    }];
}
@end
