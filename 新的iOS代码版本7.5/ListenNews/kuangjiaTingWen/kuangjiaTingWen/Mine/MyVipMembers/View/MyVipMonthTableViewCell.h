//
//  MyVipMonthTableViewCell.h
//  kuangjiaTingWen
//
//  Created by 泡果 on 2017/7/19.
//  Copyright © 2017年 zhimi. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface MyVipMonthTableViewCell : UITableViewCell
@property (strong, nonatomic) NSString *is_member;
@property (strong, nonatomic) MembersDataModel *model;
+(MyVipMonthTableViewCell *)cellWithTableView:(UITableView *)tableView;

@property (copy, nonatomic) void (^payBlock)(MyVipMonthTableViewCell *cell);
@end
