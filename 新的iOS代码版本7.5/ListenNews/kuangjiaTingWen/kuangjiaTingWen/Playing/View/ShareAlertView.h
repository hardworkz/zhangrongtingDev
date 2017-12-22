//
//  ShareAlertView.h
//  kuangjiaTingWen
//
//  Created by 泡果 on 16/8/11.
//  Copyright © 2016年 贺楠. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef void (^ClickButtonBlock)(NSInteger );

@interface ShareAlertView : UIView

- (void)setShareTitle:(NSString *)title;

- (void)setSelectItemWithTitleArr:(NSMutableArray *)itemArr;

@property (copy, nonatomic) ClickButtonBlock selectedTypeBlock;

@end
