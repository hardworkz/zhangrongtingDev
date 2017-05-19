//
//  bofangVC.h
//  kuangjiaTingWen
//
//  Created by 贺楠 on 16/6/3.
//  Copyright © 2016年 贺楠. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface bofangVC : UIViewController
+ (instancetype)shareInstance;

@property(strong,nonatomic)NewsModel *newsModel;

@property(assign,nonatomic)CGFloat titleFontSize;
@property(assign,nonatomic)UIFont *dateFont;

@property(strong,nonatomic)UITableView *tableView;
@property(strong,nonatomic)UILabel *yinpinzongTime;

@property(nonatomic)NSString *zidongjiazaiPinDaoID;
@property(nonatomic)NSInteger zidongjiazaiTableTag;

@property(nonatomic)BOOL iszhuboxiangqing;
@property(nonatomic)BOOL isPlay;
@property (assign, nonatomic) BOOL isPushNews;
@property (assign, nonatomic) BOOL isFirst;


- (void)configNowPlayingInfoCenter;
- (void)doplay2;
@end
