//
//  PlayDefaultRewardTableViewCell.h
//  kuangjiaTingWen
//
//  Created by 泡果 on 2017/8/1.
//  Copyright © 2017年 zhimi. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface PlayDefaultRewardTableViewCell : UITableViewCell

/**
 查看榜单block
 */
@property (copy, nonatomic) void (^lookupRewardListButton)(UIButton *item);
/**
 点击打赏按钮block
 */
@property (copy, nonatomic) void (^rewardButtonAciton)(UIButton *item);
/**
 赞赏人数据数组
 */
@property (strong, nonatomic) NSArray *rewardArray;

+(PlayDefaultRewardTableViewCell *)cellWithTableView:(UITableView *)tableView;
@end
