//
//  TradingRecordTableViewCell.h
//  kuangjiaTingWen
//
//  Created by Zhimi on 17/2/17.
//  Copyright © 2017年 贺楠. All rights reserved.
//

#import <UIKit/UIKit.h>

static NSString *const TradingRecordTableViewCellID = @"TradingRecordCell";


@interface TradingRecordTableViewCell : UITableViewCell

- (void)updateCellWithDataDic:(NSDictionary *)DataDic andPageSource:(NSInteger )pageSource;

@end
