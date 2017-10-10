//
//  HeNanAudioManager.h
//  kuangjiaTingWen
//
//  Created by 贺楠 on 16/6/13.
//  Copyright © 2016年 贺楠. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AVFoundation/AVFoundation.h>
@interface HeNanAudioManager : NSObject
+ (instancetype)defaultManager;
///播放音乐
- (AVAudioPlayer *)playingMusic:(NSString *)filename;
///暂停播放
- (void)pauseMusic:(NSString *)filename;
///停止播放
- (void)stopMusic:(NSString *)filename;
@end
