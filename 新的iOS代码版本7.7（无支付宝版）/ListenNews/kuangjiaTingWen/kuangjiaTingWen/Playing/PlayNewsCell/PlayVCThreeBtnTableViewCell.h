//
//  PlayVCThreeBtnTableViewCell.h
//  kuangjiaTingWen
//
//  Created by 泡果 on 2017/7/26.
//  Copyright © 2017年 zhimi. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface PlayVCThreeBtnTableViewCell : UITableViewCell

@property (strong, nonatomic) UILabel *appreciateNum;//投金币数
@property (strong, nonatomic) UILabel *commentNum;//评论数

@property (copy, nonatomic) void (^selectedItem)(UIButton *item);

+(PlayVCThreeBtnTableViewCell *)cellWithTableView:(UITableView *)tableView;
@end
