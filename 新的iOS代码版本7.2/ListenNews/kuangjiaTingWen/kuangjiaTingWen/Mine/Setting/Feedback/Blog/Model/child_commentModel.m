//
//  child_commentModel.m
//  kuangjiaTingWen
//
//  Created by 泡果 on 2017/5/12.
//  Copyright © 2017年 zhimi. All rights reserved.
//

#import "child_commentModel.h"

@implementation child_commentModel
+ (void)load
{
    [child_commentModel mj_setupReplacedKeyFromPropertyName:^NSDictionary *{
        return @{@"ID":@"id"};
    }];
}
- (NSString *)comment
{
    if ([_comment rangeOfString:@"[e1]"].location != NSNotFound && [_comment rangeOfString:@"[/e1]"].location != NSNotFound){
        
        _comment = [CommonCode jiemiEmoji:_comment];
    }
    return _comment;
}
@end
