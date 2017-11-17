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
#define NewPlayVC_GESTUER_ALERT @"NewPlayVC_GestureAlert"
#define yitingguoxinwenID @"yitingguoxinwenID"
#define dangqianbofangxinwenID @"dangqianbofangxinwenID"


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
/**
 播放开始时间
 */
@property(assign,nonatomic)CGFloat starDate;
/**
 新闻ID
 */
@property(nonatomic)NSString *post_id;
/**
 已经听过的新闻或者已购买课堂的ID
 */
@property (strong, nonatomic) NSMutableArray *listenedNewsIDArray;
/**
 选中播放对应index的音频
 
 @param index 对应index
 */
- (void)playFromIndex:(NSInteger)index;
/**
 刷新视图界面
 */
- (void)reloadInterface;
/**
 主播详情页面点击列表播放按钮调用
 */
- (void)achorVCDidClickedListPlayBtn;
/**
 设置新闻内容详情frame模型数据
 */
- (void)setFrameModel;
@end
