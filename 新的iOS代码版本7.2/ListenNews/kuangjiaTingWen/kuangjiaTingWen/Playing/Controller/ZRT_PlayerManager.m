//
//  ZRT_PlayerManager.m
//  kuangjiaTingWen
//
//  Created by 泡果 on 2017/7/25.
//  Copyright © 2017年 zhimi. All rights reserved.
//

#import "ZRT_PlayerManager.h"

#if DEBUG
#define BASE_INFO_FUN(info)    BASE_INFO_LOG([self class],_cmd,info)
#else
#define BASE_INFO_FUN(info)
#endif

static NSString *const kvo_status = @"status";
static NSString *const kvo_loadedTimeRanges = @"loadedTimeRanges";
static NSString *const kvo_playbackBufferEmpty = @"playbackBufferEmpty";
static NSString *const kvo_playbackLikelyToKeepUp = @"playbackLikelyToKeepUp";

@interface ZRT_PlayerManager ()
//播放属性
@property (nonatomic, strong) AVPlayerItem           *playerItem;
@end
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
        if ([[CommonCode readFromUserD:NewPlayVC_PLAYLIST] isKindOfClass:[NSArray class]]) {
            self.songList = [CommonCode readFromUserD:NewPlayVC_PLAYLIST];
        }else{
            self.songList = [NSMutableArray array];
        }
        self.playRate = 1.0;
        //获取限制播放状态
        [self limitPlayStatusWithAdd:NO];
    }
    return self;
}
- (BOOL)limitPlayStatusWithAdd:(BOOL)isAdd{
    //判断是否是播放新闻，记录次数限制
    BOOL isStopPlay = NO;
    if ([[CommonCode readFromUserD:@"isLogin"] boolValue] == YES) {
        NSDictionary *userInfoDict = [CommonCode readFromUserD:@"dangqianUserInfo"];
        if ([userInfoDict[results][member_type] intValue] == 0) {
            int limitTime = [[CommonCode readFromUserD:limit_time] intValue];
            int limitNum = [[CommonCode readFromUserD:limit_num] intValue];
            RTLog(@"limitTime--:%d  is_stop---:%d",limitTime,[userInfoDict[results][is_stop] intValue]);
            if (limitTime >= limitNum||[userInfoDict[results][is_stop] intValue] == 1) {
                switch (self.playType) {
                    case ZRTPlayTypeNews:
                        isStopPlay = YES;
                        [NetWorkTool sendLimitDataWithaccessToken:AvatarAccessToken sccess:^(NSDictionary *responseObject) {
                            if ([responseObject[status] intValue] == 1) {
                                [[NSNotificationCenter defaultCenter] postNotificationName:@"updateUserInfo" object:nil];
                            }
                        } failure:^(NSError *error) {
                            
                        }];
                        break;
                    case ZRTPlayTypeDownload:
                        isStopPlay = NO;
                        break;
                    case ZRTPlayTypeClassroom:
                        isStopPlay = NO;
                        break;
                        
                    default:
                        isStopPlay = NO;
                        break;
                }
            }else{
                isStopPlay = NO;
                if (isAdd) {
                    [CommonCode writeToUserD:[NSString stringWithFormat:@"%d",limitTime + 1] andKey:limit_time];
                }
            }
        }else
        {
            isStopPlay = NO;
        }
    }else{
        int limitTime = [[CommonCode readFromUserD:limit_time] intValue];
        int limitNum = [[CommonCode readFromUserD:limit_num] intValue];
        RTLog(@"limitTime--:%d",limitTime);
        if (limitTime >= limitNum) {
            switch (self.playType) {
                case ZRTPlayTypeNews:
                    isStopPlay = YES;
                    break;
                case ZRTPlayTypeDownload:
                    isStopPlay = NO;
                    break;
                case ZRTPlayTypeClassroom:
                    isStopPlay = NO;
                    break;
                default:
                    isStopPlay = NO;
                    break;
            }
        }else{
            isStopPlay = NO;
            if (isAdd) {
                [CommonCode writeToUserD:[NSString stringWithFormat:@"%d",limitTime + 1] andKey:limit_time];
            }
        }
    }
    return isStopPlay;
}
- (NSMutableArray *)downloadPostIDArray
{
    NSMutableArray *downloadArray = [NSMutableArray array];
    ProjiectDownLoadManager *manager = [ProjiectDownLoadManager defaultProjiectDownLoadManager];
    NSArray *arr = [manager downloadAllNewObjArrar];
    __weak __typeof(downloadArray) weakDownloadArray = downloadArray;
    [arr enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        @autoreleasepool {
            NewObj *nObj = [NewObj newObjWithDictionary:obj];
            DownloadDataModel *model = [DownloadDataModel new];
            model.post_id = nObj.i_id;
            model.post_mp = nObj.post_mp;
            [weakDownloadArray addObject:model];
        }
    }];
    return downloadArray;
}
- (NSMutableArray *)downloadingPostIDArray
{
    NSMutableArray *downloadingArray = [NSMutableArray array];
    ProjiectDownLoadManager *manager = [ProjiectDownLoadManager defaultProjiectDownLoadManager];
    NSArray *arr = [manager sevaDownloadArray];
    RTLog(@"%@",arr[0]);
    __weak __typeof(downloadingArray) weakDownloadArray = downloadingArray;
    [arr enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        @autoreleasepool {
            NewObj *nObj = [NewObj newObjWithDictionary:obj];
            [weakDownloadArray addObject:nObj.i_id];
        }
    }];
    return downloadingArray;
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

/**
 拦截set方法保存当前播放新闻列表数据

 @param songList 当前新闻播放列表
 */
- (void)setSongList:(NSArray *)songList
{
    _songList = songList;
    
    [CommonCode writeToUserD:songList andKey:NewPlayVC_PLAYLIST];
}
/**
 拦截set方法保存当前播放新闻数据

 @param currentSong 当前播放新闻
 */
- (void)setCurrentSong:(NSDictionary *)currentSong
{
    _currentSong = currentSong;
    
    [CommonCode writeToUserD:currentSong andKey:NewPlayVC_THELASTNEWSDATA];
}

/**
 当前播放index
 */
- (void)setCurrentSongIndex:(NSInteger)currentSongIndex
{
    _currentSongIndex = currentSongIndex;
    
    [CommonCode writeToUserD:@(currentSongIndex) andKey:NewPlayVC_PLAY_INDEX];
}
- (void)setChannelType:(ChannelType)channelType
{
    _channelType = channelType;
    
    [CommonCode writeToUserD:@(channelType) andKey:NewPlayVC_PLAY_CHANNEL];
}
/**
 播放速率
 */
- (void)setPlayRate:(float)playRate
{
    _playRate = playRate;
    self.player.rate = playRate;
}
/*
 * 总时长(秒)
 */
- (void)setPlayDuration:(float)playDuration {
    _playDuration = playDuration;
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
 *  根据playerItem，来添加移除观察者
 *
 *  @param playerItem playerItem
 */
- (void)setPlayerItem:(AVPlayerItem *)playerItem
{
    if (_playerItem == playerItem) {return;}
    
    if (_playerItem) {
        [[NSNotificationCenter defaultCenter] removeObserver:self name:AVPlayerItemDidPlayToEndTimeNotification object:_playerItem];
        [_playerItem removeObserver:self forKeyPath:kvo_status];
        [_playerItem removeObserver:self forKeyPath:kvo_loadedTimeRanges];
        [_playerItem removeObserver:self forKeyPath:kvo_playbackBufferEmpty];
        [_playerItem removeObserver:self forKeyPath:kvo_playbackLikelyToKeepUp];
    }
    _playerItem = playerItem;
    if (playerItem) {
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(playbackFinished:) name:AVPlayerItemDidPlayToEndTimeNotification object:playerItem];
        [playerItem addObserver:self forKeyPath:kvo_status options:NSKeyValueObservingOptionNew context:nil];
        [playerItem addObserver:self forKeyPath:kvo_loadedTimeRanges options:NSKeyValueObservingOptionNew context:nil];
        // 缓冲区空了，需要等待数据
        [playerItem addObserver:self forKeyPath:kvo_playbackBufferEmpty options:NSKeyValueObservingOptionNew context:nil];
        // 缓冲区有足够数据可以播放了
        [playerItem addObserver:self forKeyPath:kvo_playbackLikelyToKeepUp options:NSKeyValueObservingOptionNew context:nil];
    }
}
/**
 开始播放
 */
- (void)startPlay
{
//    if (self.playType == ZRTPlayTypeNews) {
//        if (![[ZRT_PlayerManager manager] limitPlayStatusWithAdd:NO]) {
//            _status = ZRTPlayStatusPlay;
//            SendNotify(SONGPLAYSTATUSCHANGE, nil)
//            [self.player play];
//        }
//    }else{
//        _status = ZRTPlayStatusPlay;
//        SendNotify(SONGPLAYSTATUSCHANGE, nil)
//        [self.player play];
//    }
    switch (_playType) {
        case ZRTPlayTypeNews:
            if ([self post_mpWithDownloadNewsID:self.currentSong[@"id"]] != nil) {
                _status = ZRTPlayStatusPlay;
                SendNotify(SONGPLAYSTATUSCHANGE, nil)
                [self.player play];
            }else{
                if (![[ZRT_PlayerManager manager] limitPlayStatusWithAdd:NO]) {
                    _status = ZRTPlayStatusPlay;
                    SendNotify(SONGPLAYSTATUSCHANGE, nil)
                    [self.player play];
                }
            }
            break;
        case ZRTPlayTypeDownload:
            _status = ZRTPlayStatusPlay;
            SendNotify(SONGPLAYSTATUSCHANGE, nil)
            [self.player play];
            break;
        case ZRTPlayTypeClassroom:
            _status = ZRTPlayStatusPlay;
            SendNotify(SONGPLAYSTATUSCHANGE, nil)
            [self.player play];
            break;
        case ZRTPlayTypeClassroomTry:
            _status = ZRTPlayStatusPlay;
            SendNotify(SONGPLAYSTATUSCHANGE, nil)
            [self.player play];
            break;
            
        default:
            _status = ZRTPlayStatusPlay;
            SendNotify(SONGPLAYSTATUSCHANGE, nil)
            [self.player play];
            break;
    }
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
    _playDuration = 0.f;
    _duration = 0.f;
    
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
}

/**
 切换到上一首
 */
- (BOOL)previousSong
{
    if (self.currentSongIndex == 0){
        XWAlerLoginView *alert = [XWAlerLoginView alertWithTitle:@"这已经是第一条了"];
        [alert show];
        return YES;
    }

    [self endPlay];
    //因为loadsong会将index加1，这里要减2，才是上一首
    self.currentSongIndex -= 2;
    [self loadSongInfoFromFirst:NO];
    [self startPlay];
    return NO;
}

/**
 切换到下一首
 */
- (BOOL)nextSong
{
    //如果是最后一首，先暂停播放下一首
    if (self.currentSongIndex == self.songList.count - 1){
        if (self.loadMoreList) {
            self.loadMoreList(self.currentSongIndex);
        }else{
            XWAlerLoginView *alert = [XWAlerLoginView alertWithTitle:@"这已经是最后一条了"];
            [alert show];
        }
        return YES;
    }
    
    [self playNext];
    return NO;
}
#pragma mark - 加载歌曲
/*
 * 加载下一条音乐文件
 * reset: isNew==YES:从头开始
 */
- (void)loadSongInfoFromFirst:(BOOL)isFirst {
    
    //更新当前歌曲位置
    self.currentSongIndex = isFirst ? 0 : self.currentSongIndex + 1;
    
    //回调列表，刷新界面
    if (self.playReloadList) {
        switch (self.playType) {
            case ZRTPlayTypeNews:
                self.playReloadList(self.currentSongIndex);
                
                break;
            case ZRTPlayTypeClassroom:
                self.playReloadList(self.currentSongIndex);
                
                break;
            case ZRTPlayTypeDownload:
                self.playReloadList(self.currentSongIndex);
                
                break;
                
            default:
                break;
        }
    }
    //播放index设置
    //上一首<0则回到最后一首
//    if (self.currentSongIndex < 0) {
//        self.currentSongIndex = self.songList.count - 1;
//    }
//    //播放到最后一首则回到第一首
//    if (self.currentSongIndex >= self.songList.count) {
//        self.currentSongIndex = 0;
//    }
    //更新当前歌曲信息
    self.currentSong = self.songList[self.currentSongIndex];
    
    //刷新封面图片
    switch (self.playType) {
        case ZRTPlayTypeNews:
            self.currentCoverImage = NEWSSEMTPHOTOURL(self.currentSong[@"smeta"]);
            break;
        case ZRTPlayTypeClassroom:
            self.currentCoverImage = NEWSSEMTPHOTOURL(self.currentSong[@"smeta"]);
            break;
        case ZRTPlayTypeClassroomTry:
            self.currentCoverImage = NEWSSEMTPHOTOURL(self.currentSong[@"smeta"]);
            break;
            
        default:
            break;
    }
    
    //获取播放器播放对象
    if ([self post_mpWithDownloadNewsID:self.currentSong[@"id"]] != nil) {
        self.playerItem = [[AVPlayerItem alloc] initWithURL:[NSURL fileURLWithPath:[self post_mpWithDownloadNewsID:self.currentSong[@"id"]]]];
    }else{
        self.playerItem = [[AVPlayerItem alloc] initWithURL:[NSURL URLWithString:self.currentSong[@"post_mp"]]];
    }
    
    // 每次都重新创建Player，替换replaceCurrentItemWithPlayerItem:，该方法阻塞线程
    self.player = [AVPlayer playerWithPlayerItem:self.playerItem];
    
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
    
    //回调列表，刷新界面
    if (self.playReloadList) {
        switch (self.playType) {
            case ZRTPlayTypeNews:
                self.playReloadList(self.currentSongIndex);
                break;
            case ZRTPlayTypeClassroom:
                self.playReloadList(self.currentSongIndex);
                break;
            default:
                break;
        }
    }
    
    switch (self.playType) {
        case ZRTPlayTypeNews:
            //刷新封面图片
            self.currentCoverImage = NEWSSEMTPHOTOURL(self.currentSong[@"smeta"]);
            
            //判断该新闻ID是否已经离线下载了
            //获取播放器播放对象
            RTLog(@"post_mp:%@",self.currentSong[@"post_mp"]);
            if ([self post_mpWithDownloadNewsID:self.currentSong[@"id"]] != nil) {
                self.playerItem = [[AVPlayerItem alloc] initWithURL:[NSURL fileURLWithPath:[self post_mpWithDownloadNewsID:self.currentSong[@"id"]]]];
            }else{
                self.playerItem = [[AVPlayerItem alloc] initWithURL:[NSURL URLWithString:self.currentSong[@"post_mp"]]];
            }
            break;
        case ZRTPlayTypeDownload:
            //刷新封面图片
            self.currentCoverImage = NEWSSEMTPHOTOURL(self.currentSong[@"smeta"]);
            
            RTLog(@"post_mp:%@",self.currentSong[@"post_mp"]);
            self.playerItem = [[AVPlayerItem alloc] initWithURL:[NSURL fileURLWithPath:self.currentSong[@"post_mp"]]];
            break;
        case ZRTPlayTypeClassroom:
            //刷新封面图片
            self.currentCoverImage = NEWSSEMTPHOTOURL(self.currentSong[@"smeta"]);
            
            //获取播放器播放对象
            if ([self post_mpWithDownloadNewsID:self.currentSong[@"id"]] != nil) {
                self.playerItem = [[AVPlayerItem alloc] initWithURL:[NSURL fileURLWithPath:[self post_mpWithDownloadNewsID:self.currentSong[@"id"]]]];
            }else{
                self.playerItem = [[AVPlayerItem alloc] initWithURL:[NSURL URLWithString:self.currentSong[@"post_mp"]]];
            }
            break;
        case ZRTPlayTypeClassroomTry:
            //设置图片
            if ([NEWSSEMTPHOTOURL(self.currentSong[@"smeta"]) rangeOfString:@"userDownLoadPathImage"].location != NSNotFound) {
                self.currentCoverImage = NEWSSEMTPHOTOURL(self.currentSong[@"smeta"]);
            }
            else if ([NEWSSEMTPHOTOURL(self.currentSong[@"smeta"]) rangeOfString:@"http"].location != NSNotFound)
            {
                self.currentCoverImage = NEWSSEMTPHOTOURL(self.currentSong[@"smeta"]);
            }
            else{
                self.currentCoverImage = USERPHOTOHTTPSTRINGZhuBo(NEWSSEMTPHOTOURL(self.currentSong[@"smeta"]));
            }
            self.playerItem = [[AVPlayerItem alloc] initWithURL:[NSURL URLWithString:self.currentSong[@"s_mpurl"]]];
            break;
        default:
            
            break;
    }
    
    // 每次都重新创建Player，替换replaceCurrentItemWithPlayerItem:，该方法阻塞线程
    self.player = [AVPlayer playerWithPlayerItem:self.playerItem];
    
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
    
    //加载playerItem
    NSURL * url = [NSURL URLWithString:urlString];
    self.playerItem = [[AVPlayerItem alloc]initWithURL:url];
    
    //重置播放器
    // 每次都重新创建Player，替换replaceCurrentItemWithPlayerItem:该方法阻塞线程
    self.player = [AVPlayer playerWithPlayerItem:self.playerItem];
    
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
    AVPlayerItem *songItem = self.player.currentItem;
    //更新播放器进度
    MJWeakSelf
    _timeObserve = [self.player addPeriodicTimeObserverForInterval:CMTimeMake(1.0, self.playRate) queue:dispatch_get_main_queue() usingBlock:^(CMTime time)
    {
        float currentTime = CMTimeGetSeconds(time);
        float total = CMTimeGetSeconds(songItem.duration);
        
        //判断是否是NaN如果是则返回
        if (isnan(total)) {
            return;
        }
        if (currentTime) {
            _progress = currentTime / total;
            _playDuration = currentTime;
            _duration = total;
        }
        if (weakSelf.playTimeObserve) {
            weakSelf.playTimeObserve(weakSelf.progress,currentTime,total);
        }
    }];
}
- (void)removeObserver
{
    if (_timeObserve) {
        [self.player removeTimeObserver:_timeObserve];
        _timeObserve = nil;
    }
    
    [self.player replaceCurrentItemWithPlayerItem:nil];
}
/**
 播放完成通知调用方法
 */
- (void)playbackFinished:(NSNotification *)notice
{
    RTLog(@"播放完成");
    if (self.playDidEndReload) {
        self.playDidEndReload(self.currentSongIndex);
    }
    //当前播放的是单个音频文件，不是列表
    if (self.currentSongIndex < 0) return;
    
    //如果是最后一首，先暂停播放下一首
    if (self.currentSongIndex == self.songList.count - 1){
        
        [self endPlay];
        
        if (self.loadMoreList) {
            self.loadMoreList(self.currentSongIndex);
        }else{
            XWAlerLoginView *alert = [XWAlerLoginView alertWithTitle:@"这已经是最后一条了"];
            [alert show];
        }
        return;
    }
    //播放列表中的下一条
    [self playNext];
    
    //播放完毕，回调block,方便外面做处理
    if (self.playDidEnd) {
        self.playDidEnd(self.currentSongIndex);
    }
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
//                [self startPlay];
                [APPDELEGATE configNowPlayingCenter];
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
        NSTimeInterval totalBufferDuration = CMTimeGetSeconds(timeRange.start) + CMTimeGetSeconds(timeRange.duration); //缓冲总长度
        NSTimeInterval totalDuration = CMTimeGetSeconds(songItem.duration);
        if (totalDuration<=0 || isinf(totalDuration)) return;
        self.duration = totalDuration;
        RTLog(@"共缓冲:%.2f秒",totalBufferDuration);
        if (self.reloadBufferProgress) {
            self.reloadBufferProgress(totalBufferDuration/totalDuration);
        }
        
    }else if ([keyPath isEqualToString:kvo_playbackBufferEmpty])
    {
//        if (songItem.playbackBufferEmpty) {
//            //缓冲区域为空，暂停播放
//            [self pausePlay];
//            if (self.playRate < 0) {
//                XWAlerLoginView *alert = [[XWAlerLoginView alloc] initWithTitle:@"播放异常"];
//                [alert show];
//            }
//        }
    }
    
    else if ([keyPath isEqualToString:kvo_playbackLikelyToKeepUp])
    {
//        if (songItem.playbackLikelyToKeepUp)
//        {
//            //缓存可用，继续播放
//            [self startPlay];
//        }
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
- (NSString *)convertStringWithTime:(float)time
{
    if (isnan(time)) time = 0.f;
    int min = time / 60.0;
    int sec = time - min * 60;
    NSString * minStr = min > 9 ? [NSString stringWithFormat:@"%d",min] : [NSString stringWithFormat:@"0%d",min];
    NSString * secStr = sec > 9 ? [NSString stringWithFormat:@"%d",sec] : [NSString stringWithFormat:@"0%d",sec];
    NSString * timeStr = [NSString stringWithFormat:@"%@:%@",minStr, secStr];
    return timeStr;
}
/**
 判断当前的列表标题的颜色（正在播放为主题色，已经播放过为灰色，没有播放过为黑色）
 
 @param post_id 新闻ID
 @return 返回颜色
 */
- (UIColor *)textColorFormID:(NSString *)post_id
{
    UIColor *returnColor = [UIColor blackColor];
    if ([[NewPlayVC shareInstance].listenedNewsIDArray isKindOfClass:[NSArray class]]){
        NSArray *yitingguoArr = [NSArray arrayWithArray:[NewPlayVC shareInstance].listenedNewsIDArray];
        for (int i = 0; i < yitingguoArr.count; i ++){
            if ([post_id isEqualToString:yitingguoArr[i]]){
                if ([[CommonCode readFromUserD:dangqianbofangxinwenID] isEqualToString:post_id]){
                    returnColor = gMainColor;
                    break;
                }
                else{
                    returnColor = [[UIColor grayColor]colorWithAlphaComponent:0.7f];
                    break;
                }
            }
            else{
                returnColor = nTextColorMain;
            }
        }
    }
    return returnColor;
}

/**
 是否是已下载过的id

 @param post_id 新闻ID
 @return 下载过的新闻ID
 */
- (NSString *)post_mpWithDownloadNewsID:(NSString *)post_id
{
    NSString *post_mp = nil;
    NSMutableArray *postIDArray = [self downloadPostIDArray];
    for (DownloadDataModel *model in postIDArray) {
        if ([model.post_id isEqualToString:post_id]) {
            post_mp = model.post_mp;
            break;
        }
    }
    return post_mp;
}

/**
 判断是否该音频路径是否下载成功

 @param post_mp 音频网络路径
 @return 返回YES下载成功,返回NO未下载成功
 */
//- (BOOL)isDownloadingWithPost_mp:(NSString *)post_mp
//{
//    BOOL isDownloading = NO;
//    //判断是否下载完成
////    for (NSMutableDictionary *d in [[ProjiectDownLoadManager defaultProjiectDownLoadManager] downloadAllNewObjArrar]) {
////        if ([d[@"post_mp"] rangeOfString:[post_mp stringByReplacingOccurrencesOfString:@"/" withString:@""]].location != NSNotFound) {
////            RTLog(@"存在");
////            isDownloading = YES;
////        }
////    }
//    //判断是否是正在下载中的音频文件
//    NSString * fielName = nil;
//    NSURL *post_mp_url = [NSURL URLWithString:post_mp];
//    if(post_mp_url){
//        NSString * format = [self fileFormat:post_mp_url.absoluteString];
//        if([format isEqualToString:[NSString stringWithFormat:@".%@",[[post_mp componentsSeparatedByString:@"."] lastObject]]]){
//            fielName = post_mp;
//        }else{
//            fielName = [NSString stringWithFormat:@"%@%@",post_mp,format];
//        }
//    }
//    for (WHC_Download * tempDownload in [ProjiectDownLoadManager defaultProjiectDownLoadManager].downLoadQueue.operations) {
//        if ([fielName isEqualToString:tempDownload.saveFileName]){
//            //下载文件中存在该路径，下载完成
//            isDownloading = YES;
//            break;
//        }
//    }
//    return isDownloading;
//}

/**
 获取要下载的文件格式
 */
//- (NSString *)fileFormat:(NSString *)downloadUrl{
//    NSArray  * strArr = [downloadUrl componentsSeparatedByString:@"."];
//    if(strArr && strArr.count > 0){
//        NSString *s = [NSString stringWithFormat:@".%@",strArr.lastObject];
//        return s;
//    }else{
//        return nil;
//    }
//}
@end
