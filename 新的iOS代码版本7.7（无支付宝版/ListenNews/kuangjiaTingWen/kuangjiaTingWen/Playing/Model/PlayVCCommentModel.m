//
//  PlayVCCommentModel.m
//  kuangjiaTingWen
//
//  Created by 泡果 on 2017/5/17.
//  Copyright © 2017年 zhimi. All rights reserved.
//

#import "PlayVCCommentModel.h"

@implementation PlayVCCommentModel
+ (void)load
{
    [PlayVCCommentModel mj_setupReplacedKeyFromPropertyName:^NSDictionary *{
        return @{@"playCommentID":@"id"};
    }];
}
- (NSString *)content
{
    
    if ([_content rangeOfString:@"[e1]"].location != NSNotFound && [_content rangeOfString:@"[/e1]"].location != NSNotFound){
        
        _content = [CommonCode jiemiEmoji:_content];
    }
    return _content;
}
@end
