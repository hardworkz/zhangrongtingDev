//
//  newsActModel.m
//  kuangjiaTingWen
//
//  Created by 泡果 on 2017/6/21.
//  Copyright © 2017年 zhimi. All rights reserved.
//

#import "newsActModel.h"

@implementation newsActModel
+ (void)load
{
    [PlayVCCommentModel mj_setupReplacedKeyFromPropertyName:^NSDictionary *{
        return @{@"act_id":@"id",@"Description":@"description"};
    }];
}
@end
