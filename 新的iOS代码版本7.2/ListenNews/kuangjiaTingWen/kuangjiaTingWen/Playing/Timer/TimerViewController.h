//
//  TimerViewController.h
//  Heard the news
//
//  Created by Pop Web on 15/8/17.
//  Copyright (c) 2015年 泡果网络. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol TimerViewControllerDelegate <NSObject>

- (void)timerString:(NSString *)str;

@end

@interface TimerViewController : UITableViewController

@property (nonatomic, strong) UILabel *la;
@property (nonatomic, strong) UISwitch *sw;
@property (nonatomic, assign) id<TimerViewControllerDelegate>delegate;
@property (nonatomic, strong) NSTimer *timer;
@property (nonatomic)BOOL isSheZhi;
+ (instancetype)defaultTimerViewController;
- (void)timerLable;

@end
