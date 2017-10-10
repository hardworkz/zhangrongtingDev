//
//  newsDetailModel.m
//  kuangjiaTingWen
//
//  Created by 泡果 on 2017/6/21.
//  Copyright © 2017年 zhimi. All rights reserved.
//

#import "newsDetailModel.h"

@implementation newsDetailModel
+ (NSDictionary *)mj_objectClassInArray
{
    return @{@"reward":[rewardModel class]};
}
@end
