//
//  RewardCustomView.h
//  kuangjiaTingWen
//
//  Created by Zhimi on 17/3/3.
//  Copyright © 2017年 贺楠. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "OJLAnimationButton.h"

typedef void (^ConfirmButtonBlock)(float );

@interface RewardCustomView : UIView

- (void)setSelectItemWithTitleArr:(NSMutableArray *)itemArr;


@property (copy, nonatomic) ConfirmButtonBlock rewardBlock;

@end
