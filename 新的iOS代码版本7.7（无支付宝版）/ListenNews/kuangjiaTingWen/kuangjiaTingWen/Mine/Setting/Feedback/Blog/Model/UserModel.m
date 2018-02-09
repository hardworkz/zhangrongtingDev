//
//  UserModel.m
//  kuangjiaTingWen
//
//  Created by 泡果 on 2017/5/12.
//  Copyright © 2017年 zhimi. All rights reserved.
//

#import "UserModel.h"


@implementation UserModel
+ (void)load
{
    [UserModel mj_setupReplacedKeyFromPropertyName:^NSDictionary *{
        return @{@"ID":@"id"};
    }];
}
- (NSString *)avatar
{
    return NEWSSEMTPHOTOURL(_avatar);
}
@end
