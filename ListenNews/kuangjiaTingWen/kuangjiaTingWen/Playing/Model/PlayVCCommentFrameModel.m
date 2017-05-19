//
//  PlayVCCommentFrameModel.m
//  kuangjiaTingWen
//
//  Created by 泡果 on 2017/5/17.
//  Copyright © 2017年 zhimi. All rights reserved.
//

#import "PlayVCCommentFrameModel.h"

@implementation PlayVCCommentFrameModel
- (void)setModel:(PlayVCCommentModel *)model
{
    _model = model;
    _pinglunImgF = CGRectMake(5.0 / 375 * IPHONE_W, 8.0 / 667 * IPHONE_H, 50.0 / 667 * IPHONE_H, 50.0 / 667 * IPHONE_H);
    
    _pinglunTitleF = CGRectMake(CGRectGetMaxX(_pinglunImgF) + 8.0 / 375 * IPHONE_W, 10.0 / 667 * IPHONE_H, 200.0 / 375 * IPHONE_W, 20.0 / 667 * IPHONE_H);
    
    _pinglunshijianF = CGRectMake(CGRectGetMaxX(_pinglunImgF) + 8.0 / 375 * IPHONE_W, CGRectGetMaxY(_pinglunTitleF) + 5.0 / 667 * IPHONE_H, 200.0 / 375 * IPHONE_W, 20.0 / 667 * IPHONE_H);
    if ([model.to_user_login length]) {//判断是否是回复内容
        CGSize pinglunLabSize = [@"回复" boundingRectWithSize:CGSizeMake(MAXFLOAT, MAXFLOAT) options:NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName:[UIFont systemFontOfSize:16.0f]} context:nil].size;
        _pinglunLabF = CGRectMake(CGRectGetMaxX(_pinglunImgF) - 3.0 / 375 * IPHONE_W, CGRectGetMaxY(_pinglunshijianF) + 10.0 / 667 * IPHONE_H, pinglunLabSize.width, pinglunLabSize.height);
        
        NSString *name = [model.to_user_nicename length]?model.to_user_nicename:model.to_user_login;
        CGSize commenterSize = [[NSString stringWithFormat:@"@%@",name] boundingRectWithSize:CGSizeMake(MAXFLOAT, MAXFLOAT) options:NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName:[UIFont systemFontOfSize:16.0f]} context:nil].size;
        _commenterF = CGRectMake(CGRectGetMaxX(_pinglunLabF), CGRectGetMaxY(_pinglunshijianF) + 10.0 / 667 * IPHONE_H,commenterSize.width, commenterSize.height);
        
        //获取空格宽度
        CGSize nbspSize = [@" " boundingRectWithSize:CGSizeMake(MAXFLOAT, MAXFLOAT) options:NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName:[UIFont systemFontOfSize:16]} context:nil].size;
        //计算需要添加的空格数
        int index = (pinglunLabSize.width + commenterSize.width) / nbspSize.width;
        NSString *nbspStr = [NSString string];
        for (int i = 0; i<index; i++) {
            nbspStr = [nbspStr stringByAppendingString:@" "];
        }
        
        CGSize contentSize = [[NSString stringWithFormat:@"%@ : %@",nbspStr,model.content] boundingRectWithSize:CGSizeMake(SCREEN_WIDTH - _pinglunLabF.origin.x, MAXFLOAT) options:NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName:[UIFont systemFontOfSize:16.0f]} context:nil].size;
        
        _content = [NSString stringWithFormat:@"%@ : %@",nbspStr,model.content];
        _contentF = CGRectMake(CGRectGetMaxX(_pinglunImgF) - 3.0 / 375 * IPHONE_W, CGRectGetMaxY(_pinglunshijianF) + 10.0 / 667 * IPHONE_H,contentSize.width, contentSize.height);
    }
    else{
        CGSize contentSize = [model.content boundingRectWithSize:CGSizeMake(SCREEN_WIDTH - _pinglunLabF.origin.x, MAXFLOAT) options:NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName:[UIFont systemFontOfSize:16.0f]} context:nil].size;
        
        _content = model.content;
        _contentF = CGRectMake(CGRectGetMaxX(_pinglunImgF) - 3.0 / 375 * IPHONE_W, CGRectGetMaxY(_pinglunshijianF) + 10.0 / 667 * IPHONE_H,contentSize.width, contentSize.height);
    }
    _cellHeight = CGRectGetMaxY(_contentF) + 10;
}
@end
