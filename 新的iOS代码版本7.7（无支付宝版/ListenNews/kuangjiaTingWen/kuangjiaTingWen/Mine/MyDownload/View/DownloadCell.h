//
//  DownloadCell.h
//  Heard the news
//
//  Created by Pop Web on 15/8/13.
//  Copyright (c) 2015年 泡果网络. All rights reserved.
//

#import <UIKit/UIKit.h>

@class WHC_Download;

@interface DownloadCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UILabel *labelName;
@property (weak, nonatomic) IBOutlet UIProgressView *progress;
@property (weak, nonatomic) IBOutlet UILabel *downloadDta;
@property (weak, nonatomic) IBOutlet UILabel *labelSezi;
@property (weak, nonatomic) IBOutlet UIButton *button;

@property (weak, nonatomic) IBOutlet UIImageView *ImageNew;

- (void)displayCell:(WHC_Download *)object;

@end
