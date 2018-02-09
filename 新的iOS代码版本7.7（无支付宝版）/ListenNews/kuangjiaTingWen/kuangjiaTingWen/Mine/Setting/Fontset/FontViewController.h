//
//  FontViewController.h
//  Heard the news
//
//  Created by Pop Web on 15/8/13.
//  Copyright (c) 2015年 泡果网络. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface FontViewController : UITableViewController
@property(nonatomic)BOOL isSheZhi;

@property (strong, nonatomic)NSString *fontSizeStr;

@property (copy, nonatomic) void (^ didFinishSetFont)(FontViewController *controller);

@end
