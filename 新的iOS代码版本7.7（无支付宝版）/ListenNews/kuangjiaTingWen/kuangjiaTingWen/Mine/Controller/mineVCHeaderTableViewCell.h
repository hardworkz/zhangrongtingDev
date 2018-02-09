//
//  mineVCHeaderTableViewCell.h
//  kuangjiaTingWen
//
//  Created by 泡果 on 2018/1/2.
//  Copyright © 2018年 zhimi. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface mineVCHeaderTableViewCell : UITableViewCell
+(mineVCHeaderTableViewCell *)cellWithTableView:(UITableView *)tableView;
@property (assign, nonatomic) BOOL isIAP;

@property (copy, nonatomic) void (^vipTap)();
@property (copy, nonatomic) void (^dianjitouxiangshijian)();
@end
