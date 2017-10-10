//
//  UserDetailModel.m
//  kuangjiaTingWen
//
//  Created by 泡果 on 2017/5/12.
//  Copyright © 2017年 zhimi. All rights reserved.
//

#import "UserDetailModel.h"

@implementation UserDetailModel
+ (void)load
{
    [UserDetailModel mj_setupReplacedKeyFromPropertyName:^NSDictionary *{
        return @{@"ID":@"id"};
    }];
}
@end
