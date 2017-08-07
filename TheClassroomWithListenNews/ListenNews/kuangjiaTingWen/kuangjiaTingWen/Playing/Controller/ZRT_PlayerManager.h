//
//  ZRT_PlayerManager.h
//  kuangjiaTingWen
//
//  Created by 泡果 on 2017/7/25.
//  Copyright © 2017年 zhimi. All rights reserved.
//

#import <Foundation/Foundation.h>

#define SONGPLAYSTATUSCHANGE @"SongPlayStatusChange"

typedef NS_ENUM(NSInteger, ChannelType) {
    ChannelTypeChannelNone = 0,//不是频道列表播放
    ChannelTypeHomeChannelOne,//播放首页频道1(快讯)
    ChannelTypeHomeChannelTwo,//播放首页频道2（专栏）
    ChannelTypeHomeChannelClassify,//播放首页6大分类模块
    ChannelTypeSubscriptionChannel,//播放订阅列表
    ChannelTypeDiscoverAnchor,//播放发现模块主播详情新闻列表(课堂详情课程播放列表)
    ChannelTypeDiscoverSearchNewsResult,//播放发现模块搜索新闻列表结果播放
    ChannelTypeMineDownload,//播放我的模块下载列表
    ChannelTypeMineCollection,//播放我的模块收藏列表
    ChannelTypeMineCircleListen,//播放我的模块听友圈点击新闻单条播放
    ChannelTypeMinePersonCenter,//播放我的模块个人主页单条播放
    ChannelTypeMineUnreadMessage,//播放我的模块未读消息页面新闻单条播放
    ChannelTypeClassroomTryList,//播放课堂试听列表播放
};
typedef NS_ENUM(NSInteger, ZRTPlayType) {
    ZRTPlayTypeNews = 0,//播放新闻
    ZRTPlayTypeClassroomTry,//播放课堂试听
    ZRTPlayTypeClassroom,//播放课堂
};
typedef NS_ENUM(NSInteger, ZRTPlayStatus) {
    ZRTPlayStatusNone = 0,//播放界面：未知状态
    ZRTPlayStatusLoadSongInfo,//播放界面：加载信息
    ZRTPlayStatusReadyToPlay,//播放界面：准备播放
    ZRTPlayStatusPlay,//播放界面：继续播放
    ZRTPlayStatusPause,//播放界面：暂停播放
    ZRTPlayStatusStop//播放界面：停止播放
};
@interface ZRT_PlayerManager : NSObject
{
    id _timeObserve; //监控进度
}
/**
 加载更多列表数据
 */
@property (copy, nonatomic) void (^loadMoreList)(NSInteger currentSongIndex);
/**
 播放完成设置界面状态
 */
@property (copy, nonatomic) void (^playDidEndReload)(NSInteger currentSongIndex);
/**
 播放完成回调
 */
@property (copy, nonatomic) void (^playDidEnd)(NSInteger currentSongIndex);
/**
 播放，刷新列表
 */
@property (copy, nonatomic) void (^playReloadList)(NSInteger currentSongIndex);
/**
 刷新缓冲进度
 */
@property (copy, nonatomic) void (^reloadBufferProgress)(float bufferProgress);
/**
 播放监控进度回调
 */
@property (copy, nonatomic) void (^playTimeObserve)(float progress,float currentTime,float totalDuration);
#pragma mark - 播放状态
/*
 * 播放状态
 */
@property (nonatomic, assign, readonly) ZRTPlayStatus status;
#pragma mark - 播放类型
/*
 * 播放类型
 */
@property (nonatomic, assign) ZRTPlayType playType;
#pragma mark - 播放频道列表
/**
 播放频道列表
 */
@property (assign, nonatomic) ChannelType channelType;
#pragma mark - 列表
/*
 * 歌曲列表
 */
@property (nonatomic, strong) NSArray * songList;

/*
 * 当前播放音频数据
 */
@property (nonatomic, strong) NSDictionary * currentSong;
/*
 * 当前播放音频封面图
 */
@property (nonatomic, strong) NSString * currentCoverImage;

/*
 * 当前播放歌曲索引
 */
@property (nonatomic, assign) NSInteger currentSongIndex;

#pragma mark - 播放器
/*
 * 播放器
 */
@property (nonatomic, strong) AVPlayer * player;

/*
 * 播放器播放状态
 */
@property (nonatomic, assign, readonly) BOOL isPlaying;

/*
 * 播放进度
 */
@property (nonatomic, assign, readonly) float progress;

/*
 * 播放速率
 */
@property (nonatomic, assign) float playRate;

/*
 * 缓冲进度 0.0 .. 1.0
 */
@property (nonatomic, assign, readonly) float bufferProgress;

/*
 * 当前播放时间(秒)
 */
@property (nonatomic, assign) float playDuration;

/*
 * 总时长(秒)
 */
@property (nonatomic, assign) float duration;

/*
 * 当前播放时间(00:00)
 */
@property (nonatomic, copy, readonly) NSString * playTime;

/*
 * 总时长(00:00)
 */
@property (nonatomic, copy, readonly) NSString * totalTime;
/*
 * 获取单例
 */
+ (instancetype)manager;
/**
 开始播放
 */
- (void)startPlay;
/*
 * 暂停播放
 */
- (void)pausePlay;
/*
 * 下一条
 */
- (BOOL)nextSong;
/*
 * 上一条
 */
- (BOOL)previousSong;
/**
 选中播放对应index的音频
 
 @param index 对应index
 */
- (void)loadSongInfoFromIndex:(NSInteger)index;
/**
 播放单独url的音频
 
 @param urlString 音频url字符串
 */
- (void)loadSongInfoWithUrl:(NSString *)urlString;
/**
 判断当前的列表标题的颜色（正在播放为主题色，已经播放过为灰色，没有播放过为黑色）

 @param post_id 新闻ID
 @return 返回颜色
 */
- (UIColor *)textColorFormID:(NSString *)post_id;
/**
 已下载新闻id数组

 @return ID数组
 */
- (NSMutableArray *)downloadPostIDArray;
@end
