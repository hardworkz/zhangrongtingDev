//
//  ZRT_PlayerManager.h
//  kuangjiaTingWen
//
//  Created by 泡果 on 2017/7/25.
//  Copyright © 2017年 zhimi. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef NS_ENUM(NSInteger, ZRTPlayStatus) {
    ZRTPlayStatusNone,//播放界面：未知状态
    ZRTPlayStatusLoadSongInfo,//播放界面：加载信息
    ZRTPlayStatusReadyToPlay,//播放界面：准备播放
    ZRTPlayStatusPlay,//播放界面：继续播放
    ZRTPlayStatusPause,//播放界面：暂停播放
    ZRTPlayStatusStop//播放界面：停止播放
};
@interface ZRT_PlayerManager : NSObject{
    
    id _timeObserve; //监控进度
}

@property (copy, nonatomic) void (^loadMoreList)(NSInteger currentSongIndex);
#pragma mark - 状态
/*
 * 播放状态
 */
@property (nonatomic, assign, readonly) ZRTPlayStatus status;
#pragma mark - 列表
/*
 * 歌曲列表
 */
@property (nonatomic, strong) NSMutableArray * songList;

/*
 * 当前播放歌曲
 */
@property (nonatomic, strong) NSDictionary * currentSong;

/*
 * 当前播放歌曲索引
 */
@property (nonatomic, assign) NSInteger currentSongIndex;

#pragma mark - 播放器
/*
 * 播放器
 */
@property (nonatomic, strong, readonly) AVPlayer * player;

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
@property (nonatomic, copy, readonly) NSString * playDuration;

/*
 * 总时长(秒)
 */
@property (nonatomic, copy, readonly) NSString * duration;

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
 * 切歌
 */
- (void)nextSong;
/*
 * ban歌
 */
- (void)previousSong;
/**
 选中播放对应index的音频
 
 @param index 对应index
 */
- (void)loadSongInfoFromIndex:(NSInteger)index;
/**
 播放url的音频
 
 @param urlString 音频url字符串
 */
- (void)loadSongInfoWithUrl:(NSString *)urlString;
@end
