//
//  BatchDownloadTableTableViewController.h
//  kuangjiaTingWen
//
//  Created by 泡果 on 16/7/21.
//  Copyright © 2016年 贺楠. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface BatchDownloadTableTableViewController : UITableViewController

@property (strong, nonatomic) NSString *headTitleStr;

@property (strong, nonatomic) NSMutableArray *newsListArr;

// 0 ：我的下载   1 ：节目相关新闻下载
@property (strong, nonatomic) NSString *downloadSource;

@property (strong, nonatomic) NSString *programID;

@end
