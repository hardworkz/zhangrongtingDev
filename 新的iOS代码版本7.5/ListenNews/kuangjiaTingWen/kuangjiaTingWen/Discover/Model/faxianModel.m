//
//  faxianModel.m
//  kuangjiaTingWen
//
//  Created by 泡果 on 2017/6/16.
//  Copyright © 2017年 zhimi. All rights reserved.
//

#import "faxianModel.h"

@implementation faxianModel
+ (void)load
{
    [faxianModel mj_setupReplacedKeyFromPropertyName:^NSDictionary *{
        return @{@"ID":@"id"};
    }];
}
+ (NSDictionary *)mj_objectClassInArray
{
    return @{@"data":[faxianSubModel class]};
}
@end
