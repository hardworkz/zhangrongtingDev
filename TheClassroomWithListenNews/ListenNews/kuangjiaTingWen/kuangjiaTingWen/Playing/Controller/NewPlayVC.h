//
//  NewPlayVC.h
//  kuangjiaTingWen
//
//  Created by 泡果 on 2017/7/26.
//  Copyright © 2017年 zhimi. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "OJLAnimationButton.h"

//上一次播放的记录
#define NewPlayVC_THELASTNEWSDATA @"NewPlayVC_TheLastNewsData"
#define NewPlayVC_PLAYLIST @"NewPlayVC_PlayList"
#define NewPlayVC_PLAY_INDEX @"NewPlayVC_CurrentPlayIndex"
#define NewPlayVC_PLAY_CHANNEL @"NewPlayVC_PlayChannel"

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

/**
 标题字体大小
 */
@property(assign,nonatomic)CGFloat titleFontSize;
/**
 日期字体大小
 */
@property(assign,nonatomic)CGFloat dateFont;
@property(nonatomic)NSString *post_id;/**<新闻ID*/
/**
 选中播放对应index的音频
 
 @param index 对应index
 */
- (void)playFromIndex:(NSInteger)index;
/**
 刷新视图界面
 */
- (void)reloadInterface;

@end
