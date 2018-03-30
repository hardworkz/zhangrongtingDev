//
//  SelectedNewsTypeView.h
//  kuangjiaTingWen
//
//  Created by 泡果 on 16/7/21.
//  Copyright © 2016年 贺楠. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef void (^ClickButtonBlock)(NSString *);

@interface SelectedNewsTypeView : UIView

- (void)setSelectItemWithTitleArr:(NSMutableArray *)itemArr;

@property (copy, nonatomic) ClickButtonBlock selectedTypeBlock;

@end
