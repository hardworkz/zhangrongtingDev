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
/**
 赞赏人数据数组
 */
@property (strong, nonatomic) NSArray *rewardArray;
/*
 * 赞赏View状态
 */
@property (nonatomic, assign) RewardViewType rewardType;
/**
 赞赏按钮数组
 */
@property (nonatomic, strong) NSMutableArray *buttons;

/**
 选中打赏金币值按钮回调
 */
@property (copy, nonatomic) void (^selecteRewardCountAction)(UIButton *item,NSArray *buttons);
/**
 自定义赞赏
 */
@property (copy, nonatomic) void (^finalRewardButtonAciton)(UIButton *item);
/**
 查看榜单block
 */
@property (copy, nonatomic) void (^lookupRewardListButton)(UIButton *item);
/**
 点击打赏按钮block
 */
@property (copy, nonatomic) void (^rewardButtonAciton)(UIButton *item);
/**
 返回赞赏
 */
@property (copy, nonatomic) void (^backButtonAction)(UIButton *item);
/**
 赞赏按钮动画完成调用
 */
@property (copy, nonatomic) void (^animationFinish)(OJLAnimationButton *item);

+(PlayCustomRewardTableViewCell *)cellWithTableView:(UITableView *)tableView;
@end
