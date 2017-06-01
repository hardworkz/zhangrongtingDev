//
//  GestureControlAlertView.h
//  kuangjiaTingWen
//
//  Created by 泡果 on 16/8/15.
//  Copyright © 2016年 贺楠. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef void (^ClickNowButtonBlock)();

@interface GestureControlAlertView : UIView

- (void)setAlertViewTitle:(NSString *)title;

@property (copy, nonatomic) ClickNowButtonBlock clickKnowBlock;

@end
