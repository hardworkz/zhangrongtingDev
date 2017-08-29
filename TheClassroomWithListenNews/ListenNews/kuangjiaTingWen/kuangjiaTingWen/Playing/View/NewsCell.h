//
//  NewsCell.h
//  kuangjiaTingWen
//
//  Created by 泡果 on 2017/8/21.
//  Copyright © 2017年 zhimi. All rights reserved.
//

#import <UIKit/UIKit.h>

#define DownloadNewsSuccessNotification @"downloadNewsSuccessNotification"

@interface NewsCell : UITableViewCell
@property (strong, nonatomic) NSDictionary *dataDict;
+(NewsCell *)cellWithTableView:(UITableView *)tableView;
@end
