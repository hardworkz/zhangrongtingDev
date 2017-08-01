//
//  PlayCustomRewardTableViewCell.h
//  kuangjiaTingWen
//
//  Created by 泡果 on 2017/7/26.
//  Copyright © 2017年 zhimi. All rights reserved.
//

#import <UIKit/UIKit.h>

@class OJLAnimationButton;
@interface PlayCustomRewardTableViewCell : UITableViewCell
/*
 * 赞赏View状态
 */
@property (nonatomic, assign) RewardViewType rewardType;
/**
 赞赏按钮数组
 */
@property (nonatomic, strong) NSMutableArray *buttons;

/**
 打赏动画按钮
 */
@property (strong, nonatomic) OJLAnimationButton *finalRewardButton;
/**
 选中打赏金币值按钮回调
 */
@property (copy, nonatomic) void (^selecteRewardCountAction)(UIButton *item,NSArray *buttons);
/**
 自定义赞赏
 */
@property (copy, nonatomic) void (^finalRewardButtonAciton)(OJLAnimationButton *item);
/**
 返回赞赏
 */
@property (copy, nonatomic) void (^backButtonAction)(UIButton *item);

+(PlayCustomRewardTableViewCell *)cellWithTableView:(UITableView *)tableView;
@end
