//
//  StudyRecordTimer.m
//  kuangjiaTingWen
//
//  Created by 泡果 on 2018/1/8.
//  Copyright © 2018年 zhimi. All rights reserved.
//

#import "StudyRecordTimer.h"

@interface StudyRecordTimer()
{
    dispatch_source_t timer;
}
@property (strong, nonatomic) NSString *status;
@end
@implementation StudyRecordTimer
+ (instancetype)manager {
    
    static StudyRecordTimer * timer;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        timer = [[StudyRecordTimer alloc]init];
    });
    return timer;
}
- (instancetype)init
{
    if (self == [super init]) {
        _timeCount = 0;
        _status = @"开始";
        [self createToCountTime];
        _isPause = YES;
        //播放器状态改变
        RegisterNotify(SONGPLAYSTATUSCHANGE, @selector(playStatusChange:))
    }
    return self;
}
/**
 *  创建定时器计时或者暂停继续开始计时
 */
- (void)createToCountTime
{
    //创建定时器
    dispatch_queue_t globalQueue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    timer = dispatch_source_create(DISPATCH_SOURCE_TYPE_TIMER, 0, 0, globalQueue);
    //每秒执行一次
    dispatch_source_set_timer(timer, dispatch_walltime(NULL, 0), 1.0*NSEC_PER_SEC, 0);
    dispatch_source_set_event_handler(timer, ^{
        //当前学习记录时间
        _strTime = [NSString stringWithFormat:@"%.2d",_timeCount];
        RTLog(@"学习记录秒数:%@",_strTime);
        _timeCount ++;
    });
}
/**
 *  开始计时
 */
- (void)startCount
{
    if (self.isPause) {
        dispatch_resume(timer);
        _isPause = NO;
        _status = @"暂停";
    }
}
/**
 *  暂停计时
 */
- (void)pauseCount
{
    if (!self.isPause) {
        dispatch_suspend(timer);
        _isPause = YES;
        _status = @"继续";
        [[ZRT_PlayerManager manager] uploadClassPlayHistoryData];
    }
}
/**
 *  结束定时器前，一定要先将suspend 的dispatch 先resume ，再cancel---
 *  结束计时
 */
- (void)endToCountTime
{
    if (_isCreat){
        if (_isPause == YES) {
            dispatch_resume(timer);
        }
        dispatch_source_cancel(timer);
        _isCreat = NO;
        _status = @"开始";
        _timeCount = 0;
    }
}
- (void)playStatusChange:(NSNotification *)note
{
    switch ([ZRT_PlayerManager manager].status) {
        case ZRTPlayStatusPlay:
                [self startCount];
            break;
        case ZRTPlayStatusPause:
                [self pauseCount];
            break;
        case ZRTPlayStatusStop:
                [self pauseCount];
            break;
        case ZRTPlayStatusReadyToPlay:
                [self pauseCount];
            break;
        default:
            break;
    }
}
@end
