//
//  bofangVC.h
//  kuangjiaTingWen
//
//  Created by 贺楠 on 16/6/3.
//  Copyright © 2016年 贺楠. All rights reserved.
//

#import <UIKit/UIKit.h>

@class NewsModel;
@interface bofangVC : UIViewController

+ (instancetype)shareInstance;

@property(strong,nonatomic)NewsModel *newsModel;

@property(assign,nonatomic)CGFloat titleFontSize;
@property(assign,nonatomic)UIFont *dateFont;

@property(strong,nonatomic)UITableView *tableView;
@property(strong,nonatomic)UILabel *yinpinzongTime;
@property (strong, nonatomic) UIButton *centerBtn;

@property(nonatomic)NSString *zidongjiazaiPinDaoID;
@property(nonatomic)NSInteger zidongjiazaiTableTag;

@property(nonatomic)BOOL iszhuboxiangqing;
@property(nonatomic)BOOL isMyCollectionVC;/**<从我的收藏进入*/
@property(nonatomic)BOOL isPlay;
@property (assign, nonatomic) BOOL isPushNews;
@property (assign, nonatomic) BOOL isFirst;

- (NSString *)convertStringWithTime:(float)time;/**<计算音频总时间*/
- (void)configNowPlayingInfoCenter;
- (void)doPlay:(UIButton *)sender;
- (void)doplay2;
- (void)scrollToTop;
@end
