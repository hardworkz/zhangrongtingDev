//
//  RewardListTableViewCell.h
//  kuangjiaTingWen
//
//  Created by Zhimi on 17/1/4.
//  Copyright © 2017年 贺楠. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface RewardListTableViewCell : UITableViewCell

- (void)updateCellValueWithDict:(NSMutableDictionary *)mdic andIndexPathOfRow:(NSInteger )row;

@end
