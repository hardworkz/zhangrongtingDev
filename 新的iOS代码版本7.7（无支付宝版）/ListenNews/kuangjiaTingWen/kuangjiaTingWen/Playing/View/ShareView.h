//
//  ShareView.h
//  kuangjiaTingWen
//
//  Created by Zhimi on 16/12/23.
//  Copyright © 2016年 贺楠. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef void (^ClickButtonBlock)(NSInteger );

@interface ShareView : UIView

- (void)setShareTitle:(NSString *)title;

- (void)setSelectItemWithTitleArr:(NSMutableArray *)itemArr;

@property (copy, nonatomic) ClickButtonBlock selectedTypeBlock;

@end
