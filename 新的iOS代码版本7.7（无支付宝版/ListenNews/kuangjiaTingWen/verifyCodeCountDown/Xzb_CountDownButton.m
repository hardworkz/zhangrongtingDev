//
//  Xzb_CountDownButton.m
//  xzb
//
//  Created by 张荣廷 on 16/9/8.
//  Copyright © 2016年 xuwk. All rights reserved.
//

#import "Xzb_CountDownButton.h"

@interface Xzb_CountDownButton ()
@property (nonatomic , strong) NSTimer *timer;
@end
@implementation Xzb_CountDownButton
- (void)attAction
{
    _index = 60;
    //启动定时器
    NSTimer *testTimer = [NSTimer scheduledTimerWithTimeInterval:1.0
                                                          target:self
                                                        selector:@selector(timeAction:)
                                                        userInfo:nil
                                                         repeats:YES];
    [testTimer fire];//
    [[NSRunLoop currentRunLoop] addTimer:testTimer forMode:NSDefaultRunLoopMode];
    self.timer = testTimer;
}
//每隔1秒 调用一次
- (void)timeAction:(NSTimer *)timer
{
    _index--;
//    NSLog(@"_index = %ld",(long)_index);
    NSString *again_str = [NSString stringWithFormat:@"获取中(%ld)",(long)_index];
    [self setTitle:again_str forState:UIControlStateNormal];
    self.enabled = NO;
    if (_index <= 0) {
        //invalidate  终止定时器
        [self setTitle:@"重发验证码" forState:UIControlStateNormal];
        self.enabled = YES;
        [timer invalidate];
        timer = nil;
    }else{
        dispatch_async(dispatch_get_main_queue(), ^{
            [self setTitle:[NSString stringWithFormat:@"获取中(%ld)",(long)_index] forState:UIControlStateNormal];
        });
        
    }
}

@end
