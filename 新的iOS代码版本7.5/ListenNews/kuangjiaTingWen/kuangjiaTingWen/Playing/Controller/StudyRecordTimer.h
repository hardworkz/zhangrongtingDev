//
//  StudyRecordTimer.h
//  kuangjiaTingWen
//
//  Created by 泡果 on 2018/1/8.
//  Copyright © 2018年 zhimi. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface StudyRecordTimer : NSObject

/**
 计时秒数
 */
@property (nonatomic,assign) int timeCount;
/**
 计时秒数
 */
@property (strong, nonatomic) NSString *strTime;
/**
 *  开始计时
 */
- (void)startCount;
/**
 *  暂停计时
 */
- (void)pauseCount;
/**
 *  结束计时
 */
- (void)endToCountTime;

/**
 计时器是否创建并开始计时
 */
@property (nonatomic) BOOL isCreat;
@property (nonatomic) BOOL isPause;
@end
