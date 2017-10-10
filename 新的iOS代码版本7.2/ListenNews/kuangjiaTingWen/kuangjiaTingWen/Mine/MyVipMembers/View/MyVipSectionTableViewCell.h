//
//  MyVipSectionTableViewCell.h
//  kuangjiaTingWen
//
//  Created by 泡果 on 2017/7/19.
//  Copyright © 2017年 zhimi. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface MyVipSectionTableViewCell : UITableViewCell
@property (strong, nonatomic) NSString *content;
+(MyVipSectionTableViewCell *)cellWithTableView:(UITableView *)tableView;

@end
