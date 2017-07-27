//
//  ZRT_PlayerManager.m
//  kuangjiaTingWen
//
//  Created by 泡果 on 2017/7/25.
//  Copyright © 2017年 zhimi. All rights reserved.
//

#import "ZRT_PlayerManager.h"

#define SONGPLAYSTATUSCHANGE @"SongPlayStatusChange"
#if DEBUG
#define BASE_INFO_FUN(info)    BASE_INFO_LOG([self class],_cmd,info)
#else
#define BASE_INFO_FUN(info)
#endif

static NSString *const kvo_status = @"status";
static NSString *const kvo_loadedTimeRanges = @"loadedTimeRanges";
static NSString *const kvo_playbackBufferEmpty = @"playbackBufferEmpty";
static NSString *const kvo_playbackLikelyToKeepUp = @"playbackLikelyToKeepUp";

@implementation ZRT_PlayerManager
+ (instancetype)manager {
    
    static ZRT_PlayerManager * player;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        player = [[ZRT_PlayerManager alloc]init];
    });
    return player;
}

- (id)init {
    if (self = [super init]) {
        self.songList = [NSMutableArray array];
        self.playRate = 1.0;
    }
    return self;
}
#pragma mark - 播放器
/*
 * 播放器播放状态
 */
- (BOOL)isPlaying {
    if([[UIDevice currentDevice] systemVersion].intValue>=10){
        return self.player.timeControlStatus == AVPlayerTimeControlStatusPlaying;
    }else{
        return self.player.rate==self.playRate;
    }
}
- (void)setPlayRate:(float)playRate
{
    _playRate = playRate;
    self.player.rate = playRate;
}
/*
 * 总时长(秒)
 */
- (void)setPlayDuration:(NSString *)playDuration {
    if (![_playDuration isEqualToString:playDuration] &&
        ![playDuration isEqualToString:@"0"]) {
        _playDuration = playDuration;
//        [[AppDelegate delegate] configNowPlayingCenter];
    }else {
        _playDuration = playDuration;
    }
}
/*
 * 当前播放时间(00:00)
 */
- (NSString *)playTime {
    
    return [self convertStringWithTime:self.playTime.floatValue];
}
/*
 * 总时长(00:00)
 */
- (NSString *)totalTime {
    
    return [self convertStringWithTime:self.totalTime.floatValue];
}

/**
 开始播放
 */
- (void)startPlay
{
    if (self.status == ZRTPlayStatusPause) {
        _status = ZRTPlayStatusPlay;
        SendNotify(SONGPLAYSTATUSCHANGE, nil)
    }
    [self.player play];
}
/*
 * 暂停播放
 */
- (void)pausePlay {
    _status = ZRTPlayStatusPause;
    [self.player pause];
    SendNotify(SONGPLAYSTATUSCHANGE, nil)
}
/*
 * 播放完毕
 */
- (void)endPlay {
    if (self.player == nil) return;
    
    _status = ZRTPlayStatusStop;
    [self.player pause];
    
    //移除监控
    [self removeObserver];
    
    //重置进度
    _progress = 0.f;
    _playDuration = @"0";
    _duration = @"0";
    
    SendNotify(SONGPLAYSTATUSCHANGE, nil)
}
/*
 * 自动播放下一首
 */
- (void)playNext
{
    
    [self endPlay];
    [self loadSongInfoFromFirst:NO];
    [self startPlay];
    
    //如果是最后一首，加载更多歌曲
    if (self.currentSongIndex == self.songList.count - 1)
        
        if (self.loadMoreList) {
            self.loadMoreList(self.currentSongIndex);
        }
}

/**
 切换到上一首
 */
- (void)previousSong
{
    [self endPlay];
    //因为loadsong会将index加1，这里要减2，才是上一首
    self.currentSongIndex -= 2;
    [self loadSongInfoFromFirst:NO];
    [self startPlay];
}

/**
 切换到下一首
 */
- (void)nextSong
{
    [self playNext];
}
#pragma mark - 加载歌曲
/*
 * 加载下一条音乐文件
 * reset: isNew==YES:从头开始
 */
- (void)loadSongInfoFromFirst:(BOOL)isFirst {
    
    //更新当前歌曲位置
    self.currentSongIndex = isFirst ? 0 : self.currentSongIndex + 1;
    //播放index设置
    //上一首<0则回到最后一首
    if (self.currentSongIndex < 0) {
        self.currentSongIndex = self.songList.count - 1;
    }
    //播放到最后一首则回到第一首
    if (self.currentSongIndex >= self.songList.count) {
        self.currentSongIndex = 0;
    }
    //更新当前歌曲信息
    self.currentSong = self.songList[self.currentSongIndex];
    
    //加载URL
    NSURL * url = [NSURL URLWithString:self.currentSong[@"post_mp"]];
    
    //重置播放器
    AVPlayerItem * songItem = [[AVPlayerItem alloc]initWithURL:url];
    if (_player == nil) {
        _player = [[AVPlayer alloc]initWithPlayerItem:songItem];
    }else {
        [_player replaceCurrentItemWithPlayerItem:songItem];
    }
    
    //给当前歌曲添加监控
    [self addObserver];
    
    _status = ZRTPlayStatusLoadSongInfo;
    SendNotify(SONGPLAYSTATUSCHANGE, nil)
}

/**
 选中播放对应index的音乐

 @param index 对应index
 */
- (void)loadSongInfoFromIndex:(NSInteger)index
{
    [self endPlay];
    //更新当前歌曲信息
    self.currentSong = self.songList[index];
    
    //刷新index
    self.currentSongIndex = index;
    
    //加载URL
    NSURL * url = [NSURL URLWithString:self.currentSong[@"post_mp"]];
    
    //重置播放器
    AVPlayerItem * songItem = [[AVPlayerItem alloc]initWithURL:url];
    if (_player == nil) {
        _player = [[AVPlayer alloc]initWithPlayerItem:songItem];
    }else {
        [_player replaceCurrentItemWithPlayerItem:songItem];
    }
    
    //给当前歌曲添加监控
    [self addObserver];
    
    _status = ZRTPlayStatusLoadSongInfo;
    SendNotify(SONGPLAYSTATUSCHANGE, nil)
    
    //开始播放
    [self startPlay];
}
/**
 播放url的音频
 
 @param urlString 音频url字符串
 */
- (void)loadSongInfoWithUrl:(NSString *)urlString
{
    [self endPlay];
    
    //刷新index
    self.currentSongIndex = -1;
    
    //加载URL
    NSURL * url = [NSURL URLWithString:urlString];
    
    //重置播放器
    AVPlayerItem * songItem = [[AVPlayerItem alloc]initWithURL:url];
    if (_player == nil) {
        _player = [[AVPlayer alloc]initWithPlayerItem:songItem];
    }else {
        [_player replaceCurrentItemWithPlayerItem:songItem];
    }
    
    //给当前歌曲添加监控
    [self addObserver];
    
    _status = ZRTPlayStatusLoadSongInfo;
    SendNotify(SONGPLAYSTATUSCHANGE, nil)
    
    //开始播放
    [self startPlay];
}
#pragma mark - KVO
- (void)addObserver
{
    AVPlayerItem * songItem = self.player.currentItem;
    
    //给AVPlayerItem添加播放完成通知
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(playbackFinished:) name:AVPlayerItemDidPlayToEndTimeNotification object:songItem];
    
    //更新播放器进度
    MJWeakSelf
    _timeObserve = [self.player addPeriodicTimeObserverForInterval:CMTimeMake(1.0, 1.0) queue:dispatch_get_main_queue() usingBlock:^(CMTime time) {
        float current = CMTimeGetSeconds(time);
        float total = CMTimeGetSeconds(songItem.duration);
        if (current) {
            _progress = current / total;
            weakSelf.playDuration = [NSString stringWithFormat:@"%.f",current];
            _duration = [NSString stringWithFormat:@"%.2f",total];
        }
        NSTimeInterval timeInterval = [weakSelf availableDuration];//计算缓冲进度
        _bufferProgress = timeInterval/total;//获取缓冲进度值
    }];
    
    //监控状态属性，注意AVPlayer也有一个status属性，通过监控它的status也可以获得播放状态
    [songItem addObserver:self forKeyPath:kvo_status options:NSKeyValueObservingOptionNew context:nil];
    //监控网络加载情况属性
    [songItem addObserver:self forKeyPath:kvo_loadedTimeRanges options:NSKeyValueObservingOptionNew context:nil];
    // seekToTime后，缓冲数据为空，而且有效时间内数据无法补充，播放失败
    [songItem addObserver:self forKeyPath:kvo_playbackBufferEmpty options:NSKeyValueObservingOptionNew context:nil];
    // seekToTime后，可以正常播放，相当于readyToPlay，一般拖动滑竿菊花转，到了这个这个状态菊花隐藏
    [songItem addObserver:self forKeyPath:kvo_playbackLikelyToKeepUp options:NSKeyValueObservingOptionNew context:nil];
}
- (void)removeObserver
{
    AVPlayerItem * songItem = self.player.currentItem;
    
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    
    if (_timeObserve) {
        [self.player removeTimeObserver:_timeObserve];
        _timeObserve = nil;
    }
    
    [songItem removeObserver:self forKeyPath:kvo_status];
    [songItem removeObserver:self forKeyPath:kvo_loadedTimeRanges];
    [songItem removeObserver:self forKeyPath:kvo_playbackBufferEmpty];
    [songItem removeObserver:self forKeyPath:kvo_playbackLikelyToKeepUp];
    
    [self.player replaceCurrentItemWithPlayerItem:nil];
}
/**
 播放完成通知调用方法
 */
- (void)playbackFinished:(NSNotification *)notice
{
    RTLog(@"播放完成");
    //当前播放的是单个音频文件，不是列表
    if (self.currentSongIndex < 0) return;
    
    //播放完毕，回调block,方便外面做处理
    if (self.playDidEnd) {
        self.playDidEnd(self.currentSongIndex);
    }
    //播放列表中的下一条
    [self playNext];
}
/**
 *  通过KVO监控播放器状态
 *
 *  @param keyPath 监控属性
 *  @param object  监视器
 *  @param change  状态改变
 *  @param context 上下文
 */
- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSString *,id> *)change context:(void *)context {
    
    if (!self.player) return;
    
    AVPlayerItem * songItem = object;
    
    if ([keyPath isEqualToString:kvo_status]) {
        
        switch (self.player.status) {
            case AVPlayerStatusUnknown:
                RTLog(@"KVO：未知状态");
                break;
            case AVPlayerStatusReadyToPlay:
                _status = ZRTPlayStatusReadyToPlay;
                RTLog(@"KVO：准备完毕");
                break;
            case AVPlayerStatusFailed:
                RTLog(@"KVO：加载失败");
                break;
            default:
                break;
        }
        SendNotify(SONGPLAYSTATUSCHANGE, nil)
    }
    if ([keyPath isEqualToString:kvo_loadedTimeRanges]) {
        
        NSArray * array = songItem.loadedTimeRanges;
        CMTimeRange timeRange = [array.firstObject CMTimeRangeValue]; //本次缓冲的时间范围
        NSTimeInterval totalBuffer = CMTimeGetSeconds(timeRange.start) + CMTimeGetSeconds(timeRange.duration); //缓冲总长度
        RTLog(@"共缓冲%.2f",totalBuffer);
        
    }else if ([keyPath isEqualToString:kvo_playbackBufferEmpty])
    {
        if (songItem.playbackBufferEmpty) {
            //缓冲区域为空，暂停播放
            [self pausePlay];
            if (self.playRate < 0) {
                XWAlerLoginView *alert = [[XWAlerLoginView alloc] initWithTitle:@"播放异常"];
                [alert show];
            }
        }
    }
    
    else if ([keyPath isEqualToString:kvo_playbackLikelyToKeepUp])
    {
        if (songItem.playbackLikelyToKeepUp)
        {
            //缓存可用，继续播放
            [self startPlay];
        }
    }
}

#pragma mark - 私有方法
//计算缓冲进度
- (NSTimeInterval)availableDuration{
    
    NSArray *loadedTimeRanges = [[self.player currentItem] loadedTimeRanges];
    CMTimeRange timeRange = [loadedTimeRanges.firstObject CMTimeRangeValue];//获取缓冲区域
    float startSeconds = CMTimeGetSeconds(timeRange.start);
    float durationSeconds = CMTimeGetSeconds(timeRange.duration);
    NSTimeInterval result = startSeconds + durationSeconds;//计算缓冲总进度
    return result;
}

/**
 转换秒数为时间格式字符串
 */
- (NSString *)convertStringWithTime:(float)time {
    if (isnan(time)) time = 0.f;
    int min = time / 60.0;
    int sec = time - min * 60;
    NSString * minStr = min > 9 ? [NSString stringWithFormat:@"%d",min] : [NSString stringWithFormat:@"0%d",min];
    NSString * secStr = sec > 9 ? [NSString stringWithFormat:@"%d",sec] : [NSString stringWithFormat:@"0%d",sec];
    NSString * timeStr = [NSString stringWithFormat:@"%@:%@",minStr, secStr];
    return timeStr;
}

@end
