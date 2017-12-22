//
//  DownloadNewCell.h
//  Heard the news
//
//  Created by Pop Web on 15/10/29.
//  Copyright © 2015年 泡果网络. All rights reserved.
//

#import <UIKit/UIKit.h>

@class NewObj;

@interface DownloadNewCell : UITableViewCell

@property (nonatomic, strong) NewObj *obj;

- (void)setNewData:(NewObj *)newobj;
- (void)setNewDataZhuBo:(NewObj *)newobj;

@end
