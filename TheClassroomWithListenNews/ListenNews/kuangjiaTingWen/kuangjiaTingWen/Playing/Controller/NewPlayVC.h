//
//  NewPlayVC.h
//  kuangjiaTingWen
//
//  Created by 泡果 on 2017/7/26.
//  Copyright © 2017年 zhimi. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "OJLAnimationButton.h"

typedef NS_ENUM(NSInteger, PlayType) {
    PlayTypeNone = 0,//未知播放
    PlayTypeNews,//播放新闻
    PlayTypeClass,//播放课堂内容
};
typedef NS_ENUM(NSInteger, RewardViewType) {
    RewardViewTypeNone,//初始赞赏状态
    RewardViewTypeReward,//赞赏按钮选择状态
    RewardViewTypeCustomReward,//自定义赞赏金额输入状态
};
@interface NewPlayVC : UIViewController<OJLAnimationButtonDelegate>

+ (instancetype)shareInstance;

/*
 * 赞赏View状态
 */
@property (nonatomic, assign) RewardViewType rewardType;
#pragma mark - 播放内容
/*
 * 播放状态
 */
@property (nonatomic, assign) PlayType playType;

@property(nonatomic)NSString *post_id;/**<新闻ID*/
@end
