//
//  FeedBackAndListenFriendModel.h
//  kuangjiaTingWen
//
//  Created by 泡果 on 2017/5/12.
//  Copyright © 2017年 zhimi. All rights reserved.
//

#import "FeedBackAndListenFriendModel.m"

//1张图片的最大宽度
#define OneImageMaxWidht 200
//1张图片的最大高度
#define OneImageMaxHeight 200
@implementation FeedBackAndListenFriendModel
+ (void)load
{
    [FeedBackAndListenFriendModel mj_setupReplacedKeyFromPropertyName:^NSDictionary *{
        return @{@"ID":@"id"};
    }];
}
+ (NSDictionary *)mj_objectClassInArray
{
    return @{@"child_comment":[child_commentModel class]};
}
- (NSString *)comment
{
    if ([_comment rangeOfString:@"[e1]"].location != NSNotFound && [_comment rangeOfString:@"[/e1]"].location != NSNotFound){
        
        _comment = [CommonCode jiemiEmoji:_comment];
    }
    return _comment;
}
- (NSString *)content
{
    
    if ([_content rangeOfString:@"[e1]"].location != NSNotFound && [_content rangeOfString:@"[/e1]"].location != NSNotFound){
        
        _content = [CommonCode jiemiEmoji:_content];
    }
    return _content;
}
@end
