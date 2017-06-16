//
//  faxianSubModel.m
//  kuangjiaTingWen
//
//  Created by 泡果 on 2017/6/16.
//  Copyright © 2017年 zhimi. All rights reserved.
//

#import "faxianSubModel.h"

@implementation faxianSubModel
+ (void)load
{
    [faxianSubModel mj_setupReplacedKeyFromPropertyName:^NSDictionary *{
        return @{@"ID":@"id",@"Description":@"description"};
    }];
}
@end
