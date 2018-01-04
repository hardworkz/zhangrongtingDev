//
//  BezierCurveView.m
//  BezierCurveLineDemo
//
//  Created by mac on 16/7/20.
//  Copyright © 2016年 xiayuanquan. All rights reserved.
//


#import "BezierCurveView.h"

static CGRect myFrame;

@interface BezierCurveView ()

@end

@implementation BezierCurveView

//初始化画布
+(instancetype)initWithFrame:(CGRect)frame{
    
    BezierCurveView *bezierCurveView = [[BezierCurveView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH , 60)];
    bezierCurveView.frame = frame;
    
    //背景视图
    UIView *backView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, frame.size.width, frame.size.height)];
//    backView.backgroundColor = XYQColor(255, 229, 239);
    [bezierCurveView addSubview:backView];
    
    myFrame = frame;
    return bezierCurveView;
}

/**
 *  画坐标轴
 */
-(void)drawXYLine:(NSMutableArray *)x_names
{
    UIBezierPath *path = [UIBezierPath bezierPath];
    
    //1.Y轴、X轴的直线
    [path moveToPoint:CGPointMake(MARGIN, CGRectGetHeight(myFrame)-MARGIN)];
    [path addLineToPoint:CGPointMake(MARGIN, MARGIN)];
    
    [path moveToPoint:CGPointMake(MARGIN, CGRectGetHeight(myFrame)-MARGIN)];
    [path addLineToPoint:CGPointMake(MARGIN+CGRectGetWidth(myFrame)-2*MARGIN, CGRectGetHeight(myFrame)-MARGIN)];
    
    //2.添加箭头
    [path moveToPoint:CGPointMake(MARGIN, MARGIN)];
    [path addLineToPoint:CGPointMake(MARGIN-5, MARGIN+5)];
    [path moveToPoint:CGPointMake(MARGIN, MARGIN)];
    [path addLineToPoint:CGPointMake(MARGIN+5, MARGIN+5)];
    
    [path moveToPoint:CGPointMake(MARGIN+CGRectGetWidth(myFrame)-2*MARGIN, CGRectGetHeight(myFrame)-MARGIN)];
    [path addLineToPoint:CGPointMake(MARGIN+CGRectGetWidth(myFrame)-2*MARGIN-5, CGRectGetHeight(myFrame)-MARGIN-5)];
    [path moveToPoint:CGPointMake(MARGIN+CGRectGetWidth(myFrame)-2*MARGIN, CGRectGetHeight(myFrame)-MARGIN)];
    [path addLineToPoint:CGPointMake(MARGIN+CGRectGetWidth(myFrame)-2*MARGIN-5, CGRectGetHeight(myFrame)-MARGIN+5)];

    //3.添加索引格
    //X轴
//    for (int i=0; i<x_names.count; i++) {
//        CGFloat X = MARGIN + MARGIN*(i);
//        CGPoint point = CGPointMake(X,CGRectGetHeight(myFrame)-20);
//        [path moveToPoint:point];
//        [path addLineToPoint:CGPointMake(point.x, point.y-3)];
//    }
    //Y轴（实际长度为200,此处比例缩小一倍使用）
//    for (int i=0; i<11; i++) {
//        CGFloat Y = CGRectGetHeight(myFrame)-MARGIN-Y_EVERY_MARGIN*i;
//        CGPoint point = CGPointMake(MARGIN,Y);
//        [path moveToPoint:point];
//        [path addLineToPoint:CGPointMake(point.x+3, point.y)];
//    }
    
    //4.添加索引格文字
    //X轴
    for (int i=0; i<x_names.count; i++) {
        CGFloat X = 10 + MARGIN*i;
        UILabel *textLabel = [[UILabel alloc] initWithFrame:CGRectMake(X, IS_IPHONEX?CGRectGetHeight(myFrame)- 2 *MARGIN - 10:CGRectGetHeight(myFrame)- MARGIN - 10, MARGIN, 20)];
        textLabel.text = x_names[i];
        textLabel.font = [UIFont systemFontOfSize:10];
        textLabel.textAlignment = NSTextAlignmentCenter;
        textLabel.textColor = [UIColor grayColor];
        [self addSubview:textLabel];
    }
    //Y轴
//    for (int i=0; i<11; i++) {
//        CGFloat Y = CGRectGetHeight(myFrame)-MARGIN-Y_EVERY_MARGIN*i;
//        UILabel *textLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, Y-5, MARGIN, 10)];
//        textLabel.text = [NSString stringWithFormat:@"%d",10*i];
//        textLabel.font = [UIFont systemFontOfSize:10];
//        textLabel.textAlignment = NSTextAlignmentCenter;
//        textLabel.textColor = [UIColor redColor];
//        [self addSubview:textLabel];
//    }

    //5.渲染路径
//    CAShapeLayer *shapeLayer = [CAShapeLayer layer];
//    shapeLayer.path = path.CGPath;
//    shapeLayer.strokeColor = [UIColor clearColor].CGColor;
//    shapeLayer.fillColor = [UIColor clearColor].CGColor;
//    shapeLayer.borderWidth = 2.0;
//    [self.subviews[0].layer addSublayer:shapeLayer];
}
/**
 *  画折线图
 */
-(void)drawLineChartViewWithX_Value_Names:(NSMutableArray *)x_names TargetValues:(NSMutableArray *)targetValues LineType:(LineType) lineType{
    
    //1.画坐标轴
    [self drawXYLine:x_names];
    
    //2.获取目标最大值,方便进行比例缩放
    CGFloat maxValue = 0;
    for (int i=0; i<targetValues.count; i++) {
        if ([targetValues[i] floatValue] >= maxValue) {
            maxValue = [targetValues[i] floatValue];
        }
    }
    
    //3.获取目标值点坐标
    NSMutableArray *allPoints = [NSMutableArray array];
    for (int i=0; i<targetValues.count; i++) {
        CGFloat X = MARGIN + MARGIN*(i) - 15;
        CGFloat Y = 0;
        if (maxValue > BEZIER_H) {
            if (IS_IPHONEX) {
                Y = CGRectGetHeight(myFrame)- 20 - 2*MARGIN-([targetValues[i] floatValue]/maxValue*BEZIER_H);
            }else{
                Y = CGRectGetHeight(myFrame)- 20 - MARGIN-([targetValues[i] floatValue]/maxValue*BEZIER_H);
            }
        }else{
            if (IS_IPHONEX) {
                Y = CGRectGetHeight(myFrame)- 20 - 2*MARGIN-[targetValues[i] floatValue];
            }else{
                Y = CGRectGetHeight(myFrame)- 20 - MARGIN-[targetValues[i] floatValue];
            }
        }
        CGPoint point = CGPointMake(X,Y);
        UIBezierPath *path = [UIBezierPath bezierPathWithRoundedRect:CGRectMake(point.x-2.5, point.y-2.5, 5, 5) cornerRadius:5];
        CAShapeLayer *layer = [CAShapeLayer layer];
        layer.strokeColor = gMainColor.CGColor;
        layer.fillColor = [UIColor whiteColor].CGColor;
        layer.path = path.CGPath;
        layer.lineWidth = 2.0;
        [self.subviews[0].layer addSublayer:layer];
        [allPoints addObject:[NSValue valueWithCGPoint:point]];
    }

    //3.坐标连线
    UIBezierPath *path = [UIBezierPath bezierPath];
    [path moveToPoint:[allPoints[0] CGPointValue]];
    CGPoint PrePonit;
    switch (lineType) {
        case LineType_Straight: //直线
            for (int i =1; i<allPoints.count; i++) {
                CGPoint point = [allPoints[i] CGPointValue];
                [path addLineToPoint:point];
            }
            break;
        case LineType_Curve:   //曲线
            for (int i =0; i<allPoints.count; i++) {
                if (i==0) {
                    PrePonit = [allPoints[0] CGPointValue];
                }else{
                    CGPoint NowPoint = [allPoints[i] CGPointValue];
                    [path addCurveToPoint:NowPoint controlPoint1:CGPointMake((PrePonit.x+NowPoint.x)/2, PrePonit.y) controlPoint2:CGPointMake((PrePonit.x+NowPoint.x)/2, NowPoint.y)]; //三次曲线
                    PrePonit = NowPoint;
                }
            }
            break;
    }
    //曲线图
    CAShapeLayer *shapeLayer = [CAShapeLayer layer];
    shapeLayer.path = path.CGPath;
    shapeLayer.strokeColor = gMainColor.CGColor;
    shapeLayer.fillColor = [UIColor clearColor].CGColor;
    shapeLayer.borderWidth = 2.0;
    shapeLayer.lineWidth = 2.0;
    [self.subviews[0].layer insertSublayer:shapeLayer atIndex:0];
    
    //设置闭合区域填充渐变色
    [path addLineToPoint:CGPointMake(MARGIN + MARGIN*(6) - 15,CGRectGetHeight(myFrame)- 20 - MARGIN)];
    [path addLineToPoint:CGPointMake(MARGIN + MARGIN*(0) - 15,CGRectGetHeight(myFrame)- 20 - MARGIN)];
    
    //添加区域颜色填充
    CAShapeLayer *changeColorShapeLayer = [CAShapeLayer layer];
    changeColorShapeLayer.path = path.CGPath;
    changeColorShapeLayer.strokeColor = [UIColor clearColor].CGColor;
    changeColorShapeLayer.fillColor = gMainColorRGB.CGColor;
    changeColorShapeLayer.borderWidth = 2.0;
    changeColorShapeLayer.lineWidth = 0.5;
    [self.subviews[0].layer insertSublayer:changeColorShapeLayer atIndex:0];
    
    //设置渐变属性
    CALayer *layer = [CALayer layer];
    CAGradientLayer *gradientLayer = [CAGradientLayer layer];
    gradientLayer.colors = @[(__bridge id)gMainColorRGB.CGColor, (__bridge id)[UIColor clearColor].CGColor];
    gradientLayer.locations = @[@0.0, @1.0];
    gradientLayer.startPoint = CGPointMake(0, 0);
    gradientLayer.endPoint = CGPointMake(0, 1.0);
    gradientLayer.frame = CGRectMake(MARGIN + MARGIN*(0) - 15,IS_IPHONEX? CGRectGetHeight(myFrame)- 20 - 2*MARGIN - BEZIER_H:CGRectGetHeight(myFrame)- 20 - MARGIN - BEZIER_H, 0, BEZIER_H);
    [layer addSublayer:gradientLayer];
    [layer setMask:changeColorShapeLayer];
    [self.subviews[0].layer addSublayer:layer];
    
    //曲线动画
    CABasicAnimation *animation = [CABasicAnimation animationWithKeyPath:@"strokeEnd"];
    animation.duration = 3.0f;
    animation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
    animation.fromValue = @(0.0);
    animation.toValue = @(1.0);
    [shapeLayer addAnimation:animation forKey:@"path"];
    
    //图层动画
    CABasicAnimation *anmi1 = [CABasicAnimation animation];
    anmi1.keyPath = @"bounds";
    anmi1.duration = 3.0f;
    anmi1.toValue = [NSValue valueWithCGRect:CGRectMake(MARGIN + MARGIN*(0) - 15,IS_IPHONEX? CGRectGetHeight(myFrame)- 20 - 2*MARGIN - BEZIER_H:CGRectGetHeight(myFrame)- 20 - MARGIN - BEZIER_H, MARGIN*(6) * 2, BEZIER_H)];
    anmi1.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
    anmi1.fillMode = kCAFillModeForwards;
    anmi1.autoreverses = NO;
    anmi1.removedOnCompletion = NO;
    [gradientLayer addAnimation:anmi1 forKey:@"bounds"];
    
    //4.添加目标值文字
    for (int i =0; i<allPoints.count; i++) {
        UILabel *label = [[UILabel alloc] init];
        label.textColor = gMainColor;
        label.textAlignment = NSTextAlignmentCenter;
        label.font = [UIFont systemFontOfSize:10];
        [self.subviews[0] addSubview:label];
        
        if (i==0) {
            CGPoint NowPoint = [allPoints[0] CGPointValue];
            label.text = [NSString stringWithFormat:@"%d分",[targetValues[i] intValue]];
            label.frame = CGRectMake(NowPoint.x-MARGIN/2, NowPoint.y-25, MARGIN, 20);
            PrePonit = NowPoint;
        }else{
            CGPoint NowPoint = [allPoints[i] CGPointValue];
//            if (NowPoint.y<=PrePonit.y) {  //文字置于点上方
                label.frame = CGRectMake(NowPoint.x-MARGIN/2, NowPoint.y-25, MARGIN, 20);
//            }else{ //文字置于点下方
//                label.frame = CGRectMake(NowPoint.x-MARGIN/2, NowPoint.y, MARGIN, 20);
//            }
            label.text = [NSString stringWithFormat:@"%d分",[targetValues[i] intValue]];
            PrePonit = NowPoint;
        }
    }
}

/**
 *  画柱状图
 */
-(void)drawBarChartViewWithX_Value_Names:(NSMutableArray *)x_names TargetValues:(NSMutableArray *)targetValues{
    
    //1.画坐标轴
    [self drawXYLine:x_names];
    
    //2.每一个目标值点坐标
    for (int i=0; i<targetValues.count; i++) {
        CGFloat doubleValue = 2*[targetValues[i] floatValue]; //目标值放大两倍
        CGFloat X = MARGIN + MARGIN*(i+1)+5;
        CGFloat Y = CGRectGetHeight(myFrame)-MARGIN-doubleValue;
        UIBezierPath *path = [UIBezierPath bezierPathWithRect:CGRectMake(X-MARGIN/2, Y, MARGIN-10, doubleValue)];
        CAShapeLayer *shapeLayer = [CAShapeLayer layer];
        shapeLayer.path = path.CGPath;
        shapeLayer.strokeColor = [UIColor clearColor].CGColor;
        shapeLayer.fillColor = XYQRandomColor.CGColor;
        shapeLayer.borderWidth = 2.0;
        [self.subviews[0].layer addSublayer:shapeLayer];
        
        //3.添加文字
        UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(X-MARGIN/2, Y-20, MARGIN-10, 20)];
        label.text = [NSString stringWithFormat:@"%.0lf",(CGRectGetHeight(myFrame)-Y-MARGIN)/2];
        label.textColor = [UIColor purpleColor];
        label.textAlignment = NSTextAlignmentCenter;
        label.font = [UIFont systemFontOfSize:10];
        [self.subviews[0] addSubview:label];
    }
}


/**
 *  画饼状图
 */
-(void)drawPieChartViewWithX_Value_Names:(NSMutableArray *)x_names TargetValues:(NSMutableArray *)targetValues{
    
    //设置圆点
    CGPoint point = CGPointMake(self.frame.size.width/2,self.frame.size.height/2);
    CGFloat startAngle = 0;
    CGFloat endAngle ;
    CGFloat radius = 100;
    
    //计算总数
    __block CGFloat allValue = 0;
    [targetValues enumerateObjectsUsingBlock:^(NSNumber *targetNumber, NSUInteger idx, BOOL * _Nonnull stop) {
        allValue += [targetNumber floatValue];
    }];
    
    //画图
    for (int i =0; i<targetValues.count; i++) {
        
        CGFloat targetValue = [targetValues[i] floatValue];
        endAngle = startAngle + targetValue/allValue*2*M_PI;

        //bezierPath形成闭合的扇形路径
        UIBezierPath *bezierPath = [UIBezierPath bezierPathWithArcCenter:point
                                                                   radius:radius
                                                               startAngle:startAngle                                                                 endAngle:endAngle
                                                                clockwise:YES];
        [bezierPath addLineToPoint:point];
        [bezierPath closePath];
        
        
        //添加文字
        CGFloat X = point.x + 120*cos(startAngle+(endAngle-startAngle)/2) - 10;
        CGFloat Y = point.y + 110*sin(startAngle+(endAngle-startAngle)/2) - 10;
        UILabel *label = [[UILabel alloc]initWithFrame:CGRectMake(X, Y, 30, 20)];
        label.text = x_names[i];
        label.font = [UIFont systemFontOfSize:11];
        label.textColor = XYQColor(13, 195, 176);
        [self.subviews[0] addSubview:label];
        
        
        //渲染
        CAShapeLayer *shapeLayer=[CAShapeLayer layer];
        shapeLayer.lineWidth = 1;
        shapeLayer.fillColor = XYQRandomColor.CGColor;
        shapeLayer.path = bezierPath.CGPath;
        [self.layer addSublayer:shapeLayer];
        
        startAngle = endAngle;
    }
}
@end
