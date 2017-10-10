//
//  BYGraphicsView.h
//  DrawGraph
//
//  Created by 华图－林必里 on 17/1/18.
//  Copyright © 2017年 huatu. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface BYGraphicsView : UIView


//设置当前视图为椭圆，以及背景图片，背景色
- (void)setViewToEllipseWithBackgroundImage:(UIImage *)bgImage backgroundColor:(UIColor *)bgColor;

//设置右下角的圆角半径，以及背景图片，背景色
- (void)setViewToLowerRightArcWithCornerRadius:(float)cornerRadius backgroundImage:(UIImage *)bgImage backgroundColor:(UIColor *)bgColor;

//设置底部（左下角 = 右下角）的圆角半径，以及背景图片，背景色
- (void)setViewToBottomArcWithCornerRadius:(float)cornerRadius backgroundImage:(UIImage *)bgImage backgroundColor:(UIColor *)bgColor;

//设置顶部三角形的宽度、高度、相对图形X轴的偏移量，以及背景图片，背景色
- (void)setViewToTopTriangleWithWidth:(float)triangleWidth height:(float)triangleHeight offsetX:(float)triangleOffsetX backgroundImage:(UIImage *)bgImage backgroundColor:(UIColor *)bgColor;

//设置底部三角形的宽度、高度、相对图形X轴的偏移量，以及背景图片，背景色
- (void)setViewToBottomTriangleWithWidth:(float)triangleWidth height:(float)triangleHeight offsetX:(float)triangleOffsetX backgroundImage:(UIImage *)bgImage backgroundColor:(UIColor *)bgColor;


@end
