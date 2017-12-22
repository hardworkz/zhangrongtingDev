//
//  DeleteCommentAlertView.h
//  kuangjiaTingWen
//
//  Created by 泡果 on 2017/5/22.
//  Copyright © 2017年 zhimi. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CustomAlertView : UIView
@property (nonatomic , weak) UIButton *cover;/**<遮盖*/

@property (assign, nonatomic) CGFloat alertDuration;/**<弹框时间*/
@property (assign, nonatomic) CGFloat alertHeight;/**<弹框高度*/
@property (assign, nonatomic) CGFloat coverAlpha;/**<遮盖最大透明度*/

- (instancetype)initWithCustomView:(UIView *)view;/**<自定义遮盖控件*/
- (void)show;/**<弹出*/
- (void)coverClick;/**<点击遮盖*/
@end
