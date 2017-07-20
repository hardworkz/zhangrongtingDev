//
//  MyUserVipTableViewCell.h
//  kuangjiaTingWen
//
//  Created by 泡果 on 2017/7/19.
//  Copyright © 2017年 zhimi. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface MyUserVipTableViewCell : UITableViewCell
@property (strong, nonatomic) NSString *end_date;
@property (strong, nonatomic) NSString *is_member;
@property (strong, nonatomic) NSDictionary *user;
+(MyUserVipTableViewCell *)cellWithTableView:(UITableView *)tableView;
@end
