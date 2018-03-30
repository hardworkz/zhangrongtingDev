//
//  FeedBackAndListenFriendFrameModel.m
//  kuangjiaTingWen
//
//  Created by 泡果 on 2017/5/12.
//  Copyright © 2017年 zhimi. All rights reserved.
//

#import "FeedBackAndListenFriendFrameModel.h"

@interface FeedBackAndListenFriendFrameModel ()
@property (strong, nonatomic) MultiImageView *photoImageView;
@property (assign, nonatomic) CGFloat tableHeight;
@end
@implementation FeedBackAndListenFriendFrameModel
- (instancetype)init
{
    if (self = [super init]) {
        //图片内容view
        _photoImageView = [[MultiImageView alloc] init];
        _photoImageView.contentMode = UIViewContentModeScaleToFill;
    }
    return self;
}
//转换为frame模型
- (NSMutableArray *)frameModelWithDataModel:(NSArray *)array
{
    NSMutableArray *frameArray = [NSMutableArray array];
    for (child_commentModel *model in array) {
        CommentAndReviewFrameModel *frameModel = [[CommentAndReviewFrameModel alloc] init];
        frameModel.model = model;
        [frameArray addObject:frameModel];
        _tableHeight += frameModel.cellHeight;
    }
    return frameArray;
}
- (void)setModel:(FeedBackAndListenFriendModel *)model
{
    _model = model;
    //用户头像
    _headerImageF = CGRectMake(10, 10, 46, 46);
    //用户昵称
    CGSize nameSize = [[model.user.user_nicename isEqualToString:@""] ? model.user.user_login :model.user.user_nicename boundingRectWithSize:CGSizeMake(MAXFLOAT, MAXFLOAT) options:NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName:CUSTOM_FONT_TYPE(16.0)} context:nil].size;
    _nameLabeF = CGRectMake(CGRectGetMaxX(_headerImageF) + 14, 10, nameSize.width, 25);
    //发布时间
    _creat_timeLabelF = CGRectMake(SCREEN_WIDTH - 27 - 100, 17, 100, 18);
    //发布内容
    CGSize contentSize = [model.comment boundingRectWithSize:CGSizeMake(SCREEN_WIDTH - _nameLabeF.origin.x - 10, MAXFLOAT) options:NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName:CUSTOM_FONT_TYPE(16.0)} context:nil].size;
    _contentF = CGRectMake(_nameLabeF.origin.x, CGRectGetMaxY(_nameLabeF) + 10, contentSize.width, contentSize.height);
    //发布图片
    //处理图片
    NSMutableArray *urls = [NSMutableArray new];
    if (self.isFeedbackVC) {
        if (![model.images isEqualToString:@""]){
            NSArray *array = [model.images componentsSeparatedByString:@","];
            for (int i = 0 ; i < array.count ; i ++ ) {
                [urls addObject:[NSURL URLWithString:[NSString stringWithFormat:@"%@%@",APPHost,array[i]]]];
            }
        }
    }
    else{
        if (![model.timages isEqualToString:@""]){
            NSArray *array = [model.timages componentsSeparatedByString:@","];
            for (int i = 0 ; i < array.count ; i ++ ) {
                [urls addObject:[NSURL URLWithString:[NSString stringWithFormat:@"%@%@",APPHost,array[i]]]];
            }
        }
    }
    NSArray *photos = urls;
    CGSize size;
    size = [_photoImageView sizeForContent:photos];
    
    //判断是意见反馈还是听友圈，意见反馈没有语音和评论新闻链接跳转view
    if (self.isFeedbackVC) {
        
        _photosImageViewF = CGRectMake(_nameLabeF.origin.x, CGRectGetMaxY(_contentF) + 5, size.width, size.height);
        if ([photos count] == 0) {//判断是否有图片
            _deleteBtnF = CGRectMake(_nameLabeF.origin.x, CGRectGetMaxY(_contentF) + 8, 40, 18);
        }else
        {
            _deleteBtnF = CGRectMake(_nameLabeF.origin.x, CGRectGetMaxY(_photosImageViewF) + 8, 40, 18);
        }
    }else{//听友圈
        if (![model.post_id isEqualToString:@"0"]) {//新闻评论，无语音
            //转发新闻
            _contentNewsViewF = CGRectMake(_nameLabeF.origin.x, CGRectGetMaxY(_contentF) + 10, SCREEN_WIDTH - _nameLabeF.origin.x - 10, 68);
            _photosImageViewF = CGRectMake(_nameLabeF.origin.x, CGRectGetMaxY(_contentNewsViewF) + 5, size.width, size.height);
            if ([photos count] == 0) {//判断是否有图片
                _deleteBtnF = CGRectMake(_nameLabeF.origin.x, CGRectGetMaxY(_contentNewsViewF) + 8, 40, 18);
            }else
            {
                _deleteBtnF = CGRectMake(_nameLabeF.origin.x, CGRectGetMaxY(_photosImageViewF) + 8, 40, 18);
            }
        }else{//语音，无新闻评论
            if ([model.mp3_url isEmpty]) {//判断是否有语音信息,无语音信息
                _voiceViewF = CGRectMake(_nameLabeF.origin.x, CGRectGetMaxY(_contentNewsViewF), SCREEN_WIDTH - _nameLabeF.origin.x - 10, 0);
                _photosImageViewF = CGRectMake(_nameLabeF.origin.x, CGRectGetMaxY(_contentF) + 5, size.width, size.height);
                
                if ([photos count] == 0) {//判断是否有图片
                    _deleteBtnF = CGRectMake(_nameLabeF.origin.x, CGRectGetMaxY(_contentF) + 8, 40, 18);
                }else
                {
                    _deleteBtnF = CGRectMake(_nameLabeF.origin.x, CGRectGetMaxY(_photosImageViewF) + 8, 40, 18);
                }
            }
            else{//有语音信息
                if ([model.comment isEqualToString:@""]) {
                    _voiceViewF = CGRectMake(_nameLabeF.origin.x, CGRectGetMaxY(_nameLabeF) + 10, SCREEN_WIDTH - _nameLabeF.origin.x - 10, 40);
                }else
                {
                    _voiceViewF = CGRectMake(_nameLabeF.origin.x, CGRectGetMaxY(_contentF) + 5, SCREEN_WIDTH - _nameLabeF.origin.x - 10, 40);
                }
                _photosImageViewF = CGRectMake(_nameLabeF.origin.x, CGRectGetMaxY(_voiceViewF) + 5, size.width, size.height);
                
                if ([photos count] == 0) {//判断是否有图片
                    _deleteBtnF = CGRectMake(_nameLabeF.origin.x, CGRectGetMaxY(_voiceViewF) + 8, 40, 18);
                }else
                {
                    _deleteBtnF = CGRectMake(_nameLabeF.origin.x, CGRectGetMaxY(_photosImageViewF) + 8, 40, 18);
                }
            }
            
        }
    }

    //转发新闻内容模块
    _newsImageF = CGRectMake(10, 10, 48, 48);
    _newsTitleF = CGRectMake(CGRectGetMaxX(_newsImageF) + 10, 10, _contentNewsViewF.size.width - 68, 48);
    //语音按钮模块
    float voiceWidth = 80.0f;
    if ([model.play_time integerValue] < 30) {
        voiceWidth = ([model.play_time integerValue] - 1 ) * 4.0 + 100.0;
    }
    else{
        voiceWidth = 200.0f;
    }
    _voiceButtonF = CGRectMake(0, 0, voiceWidth, 40);
    _voiceTimeLabelF = CGRectMake(CGRectGetMaxX(_voiceButtonF) + 5, 15, 50, 10);
    
    //删除，点赞，评论按钮
//    _deleteBtnF = CGRectMake(_nameLabeF.origin.x, CGRectGetMaxY(_photosImageViewF) + 8, 40, 18);
    _commentBtnF = CGRectMake(SCREEN_WIDTH - 42 - 5, _deleteBtnF.origin.y - 3, 42, 33);
    _praiseButtonF = CGRectMake(_commentBtnF.origin.x - 42 - 5, _commentBtnF.origin.y, 42, 33);
    
    //评论回复区背景
    [self frameModelWithDataModel:model.child_comment];
    
    _commentBgViewF = CGRectMake(_nameLabeF.origin.x, CGRectGetMaxY(_commentBtnF), SCREEN_WIDTH - _nameLabeF.origin.x - 10, _tableHeight + 22);
    _favImageF = CGRectMake(5, 5, 12, 12);
    _favLabelF = CGRectMake(22, 5, SCREEN_WIDTH - _nameLabeF.origin.x - 10 - 22, 12);
    _tableViewF = CGRectMake(5, 25, _commentBgViewF.size.width, _tableHeight);
    _deviderF = CGRectMake(10, CGRectGetMaxY(_commentBgViewF) + 5, SCREEN_WIDTH - 20, 0.5);
    _cellHeight = CGRectGetMaxY(_deviderF);
}
@end
