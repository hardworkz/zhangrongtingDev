//
//  NewsTableViewCell.h
//  kuangjiaTingWen
//
//  Created by Zhimi on 17/3/21.
//  Copyright © 2017年 zhimi. All rights reserved.
//

#import <UIKit/UIKit.h>

static NSString *const NewsTableViewCellID = @"NewsTableViewCell";

@interface NewsTableViewCell : UITableViewCell

- (void)updateCellWithDataSourceDic:(NSDictionary *)cellDataSourceDic;

@end
