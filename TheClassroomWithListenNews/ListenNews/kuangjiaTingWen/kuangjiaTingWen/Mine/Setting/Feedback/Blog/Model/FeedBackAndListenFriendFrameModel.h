//
//  FeedBackAndListenFriendFrameModel.h
//  kuangjiaTingWen
//
//  Created by 泡果 on 2017/5/12.
//  Copyright © 2017年 zhimi. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface FeedBackAndListenFriendFrameModel : NSObject
@property (strong,  nonatomic) FeedBackAndListenFriendModel *model;

@property (assign, nonatomic)BOOL isFeedbackVC;

@property (assign,  nonatomic,readonly) CGRect headerImageF;
@property (assign,  nonatomic,readonly) CGRect creat_timeLabelF;
@property (assign,  nonatomic,readonly) CGRect contentF;
@property (assign,  nonatomic,readonly) CGRect contentNewsViewF;
@property (assign,  nonatomic,readonly) CGRect newsImageF;
@property (assign,  nonatomic,readonly) CGRect newsTitleF;
@property (assign,  nonatomic,readonly) CGRect voiceViewF;
@property (assign,  nonatomic,readonly) CGRect voiceButtonF;
@property (assign,  nonatomic,readonly) CGRect voiceTimeLabelF;
@property (assign,  nonatomic,readonly) CGRect deleteBtnF;
@property (assign,  nonatomic,readonly) CGRect commentBtnF;
@property (assign,  nonatomic,readonly) CGRect praiseButtonF;
@property (assign,  nonatomic,readonly) CGRect commentBgViewF;
@property (assign,  nonatomic,readonly) CGRect favImageF;
@property (assign,  nonatomic,readonly) CGRect favLabelF;
@property (assign,  nonatomic,readonly) CGRect nameLabeF;
@property (assign,  nonatomic,readonly) CGRect commentLabelF;
@property (assign,  nonatomic) CGRect photosImageViewF;
@property (assign,  nonatomic,readonly) CGRect tableViewF;
@property (assign,  nonatomic,readonly) CGRect deviderF;
@property (assign,  nonatomic,readonly) CGFloat cellHeight;
@end
