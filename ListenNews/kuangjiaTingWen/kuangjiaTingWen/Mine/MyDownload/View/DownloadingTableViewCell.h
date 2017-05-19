//
//  DownloadingTableViewCell.h
//  kuangjiaTingWen
//
//  Created by 泡果 on 16/7/25.
//  Copyright © 2016年 贺楠. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef void (^ShowDeleteBlock)();

@interface DownloadingTableViewCell : UITableViewCell

@property (strong, nonatomic) UIProgressView *progressView;
@property (strong, nonatomic) UILabel *progressLabel;
@property (strong, nonatomic) UIButton *statusButton;

- (void)updateCellValueWithDict:(NSMutableDictionary *)mdic;

@property (copy,nonatomic) ShowDeleteBlock deleteDownloadingNew;

@end
