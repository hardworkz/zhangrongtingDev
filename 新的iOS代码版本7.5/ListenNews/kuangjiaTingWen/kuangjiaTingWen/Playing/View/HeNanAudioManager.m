//
//  HeNanAudioManager.m
//  kuangjiaTingWen
//
//  Created by 贺楠 on 16/6/13.
//  Copyright © 2016年 贺楠. All rights reserved.
//

#import "HeNanAudioManager.h"

@interface HeNanAudioManager ()
@property(strong,nonatomic)NSMutableDictionary *musicPlayers;
@property(strong,nonatomic)NSMutableDictionary *soundIDs;
@end
static HeNanAudioManager *_instance = nil;
@implementation HeNanAudioManager

+ (void)initialize
{
    //音频会话
    AVAudioSession *session = [AVAudioSession sharedInstance];
    //设置会话类型（播放类型、播放模式，会自动停止其他音乐的播放）
    [session setCategory:AVAudioSessionCategoryPlayback error:nil];
    //激活会话
    [session setActive:YES error:nil];
}
+ (instancetype)defaultManager
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _instance = [[self alloc]init];
    });
    return _instance;
}
- (instancetype)init
{
    __block HeNanAudioManager *temp = self;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        if ((temp = [super init]) != nil)
        {
            _musicPlayers = [NSMutableDictionary dictionary];
            _soundIDs = [NSMutableDictionary dictionary];
        }
    });
    self = temp;
    return self;
}
+ (instancetype)allocWithZone:(struct _NSZone *)zone
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _instance = [super allocWithZone:zone];
    });
    return _instance;
}

//播放音乐
- (AVAudioPlayer *)playingMusic:(NSString *)filename
{
    if (filename == nil || filename.length == 0)
    {
        return nil;
    }
    AVAudioPlayer *player = self.musicPlayers[filename];    //先查询对象是否缓存了
    if (!player)
    {
        NSURL *url = [[NSBundle mainBundle]URLForResource:filename withExtension:nil];
        if (!url)
        {
            return nil;
        }
        player = [[AVAudioPlayer alloc]initWithContentsOfURL:url error:nil];
        if (![player prepareToPlay])
        {
            return nil;
        }
        self.musicPlayers[filename] = player;       //对象是最新创建的，那么对它进行一次缓存
    }
    if (![player isPlaying])         //如果没有正在播放，那么开始播放，如果正在播放，那么不需要改变什么
    {
        [player play];
    }
    return player;
}
//暂停音乐
- (void)pauseMusic:(NSString *)filename
{
    if (filename == nil || filename.length == 0)
    {
        return;
    }
    AVAudioPlayer *player = self.musicPlayers[filename];
    if ([player isPlaying])
    {
        [player pause];
    }
}
//停止音乐
- (void)stopMusic:(NSString *)filename
{
    if (filename == nil || filename.length == 0)
    {
        return;
    }
    AVAudioPlayer *player = self.musicPlayers[filename];
    [player stop];
    [self.musicPlayers removeObjectForKey:filename];
}
//播放音效
- (void)playSound:(NSString *)filename
{
    if (!filename)
    {
        return;
    }
    //取出对应的音效ID
    SystemSoundID soundID = (int)[self.soundIDs[filename] unsignedLongValue];
    if (!soundID)
    {
        NSURL *url = [[NSBundle mainBundle]URLForResource:filename withExtension:nil];
        if (!url)
        {
            return;
        }
        AudioServicesCreateSystemSoundID((__bridge CFURLRef)(url),&soundID);
        self.soundIDs[filename] = @(soundID);
    }
    //播放
    AudioServicesPlaySystemSound(soundID);
}
//摧毁音效
- (void)disposeSound:(NSString *)filename
{
    if (!filename)
    {
        return;
    }
    SystemSoundID soundID = (int)[self.soundIDs[filename] unsignedLongValue];
    if (soundID)
    {
        AudioServicesDisposeSystemSoundID(soundID);
        [self.soundIDs removeObjectForKey:filename];        //音效被摧毁，那么对应的对象应该从缓存中去除
    }
}
@end
