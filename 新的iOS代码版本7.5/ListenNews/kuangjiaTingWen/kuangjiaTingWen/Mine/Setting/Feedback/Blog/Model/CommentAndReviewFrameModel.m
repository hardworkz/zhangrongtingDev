//
//  CommentAndReviewFrameModel.m
//  kuangjiaTingWen
//
//  Created by 泡果 on 2017/5/15.
//  Copyright © 2017年 zhimi. All rights reserved.
//

#import "CommentAndReviewFrameModel.h"

@implementation CommentAndReviewFrameModel
- (void)setModel:(child_commentModel *)model
{
    _model = model;
    UserModel *to_user = model.to_user;
    UserDetailModel *user = model.user;
    if ([to_user.ID isEqualToString:@""]||to_user.ID == nil) {//计算回复人的名称宽度
        CGSize replyManSize = [user.user_nicename boundingRectWithSize:CGSizeMake(MAXFLOAT, MAXFLOAT) options:NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName:[UIFont systemFontOfSize:15]} context:nil].size;
        _replyManF = CGRectMake(0, 0, replyManSize.width, replyManSize.height);
        //获取空格宽度
        CGSize nbspSize = [@" " boundingRectWithSize:CGSizeMake(MAXFLOAT, MAXFLOAT) options:NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName:[UIFont systemFontOfSize:15]} context:nil].size;
        //计算需要添加的空格数
        int index = (replyManSize.width) / nbspSize.width;
        NSString *nbspStr = [NSString string];
        for (int i = 0; i<index; i++) {
            nbspStr = [nbspStr stringByAppendingString:@" "];
        }
        
        //回复内容
        CGSize contentSize = [[NSString stringWithFormat:@"%@ : %@",nbspStr,model.comment] boundingRectWithSize:CGSizeMake(SCREEN_WIDTH - 80, MAXFLOAT) options:NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName:[UIFont systemFontOfSize:15]} context:nil].size;
        _content = [NSString stringWithFormat:@"%@ : %@",nbspStr,model.comment];
        _contentLabelF = CGRectMake(0, 0, contentSize.width, contentSize.height);
        
    }else{//计算回复人的名称宽度
        CGSize replyManSize = [user.user_nicename == nil?@"匿名用户":user.user_nicename boundingRectWithSize:CGSizeMake(MAXFLOAT, MAXFLOAT) options:NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName:[UIFont systemFontOfSize:15]} context:nil].size;
        _replyManF = CGRectMake(0, 0, replyManSize.width, replyManSize.height);
        //计算回复名词的名称宽度
        CGSize reviewSize = [@"回复" boundingRectWithSize:CGSizeMake(MAXFLOAT, MAXFLOAT) options:NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName:[UIFont systemFontOfSize:15]} context:nil].size;
        _labelF = CGRectMake(CGRectGetMaxX(_replyManF), _replyManF.origin.y, reviewSize.width, reviewSize.height);
        //计算被回复人的名称宽度
        CGSize beReplyManSize = [to_user.user_nicename boundingRectWithSize:CGSizeMake(MAXFLOAT, MAXFLOAT) options:NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName:[UIFont systemFontOfSize:15]} context:nil].size;
        _beReplyManF = CGRectMake(CGRectGetMaxX(_labelF), _replyManF.origin.y, beReplyManSize.width, beReplyManSize.height);
        
        //获取空格宽度
        CGSize nbspSize = [@" " boundingRectWithSize:CGSizeMake(MAXFLOAT, MAXFLOAT) options:NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName:[UIFont systemFontOfSize:15]} context:nil].size;
        //计算需要添加的空格数
        int index = (replyManSize.width + reviewSize.width + beReplyManSize.width) / nbspSize.width;
        NSString *nbspStr = [NSString string];
        for (int i = 0; i<index; i++) {
            nbspStr = [nbspStr stringByAppendingString:@" "];
        }
        
        //回复内容
        CGSize contentSize = [[NSString stringWithFormat:@"%@ : %@",nbspStr,model.comment] boundingRectWithSize:CGSizeMake(SCREEN_WIDTH - 80, MAXFLOAT) options:NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName:[UIFont systemFontOfSize:15]} context:nil].size;
        _content = [NSString stringWithFormat:@"%@ : %@",nbspStr,model.comment];
        _contentLabelF = CGRectMake(0, 0, contentSize.width, contentSize.height);
        
    }
    _cellHeight = _contentLabelF.size.height + 5;
}
@end
