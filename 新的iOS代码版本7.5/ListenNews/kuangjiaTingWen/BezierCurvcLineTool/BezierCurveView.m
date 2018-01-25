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
//@property (assign, nonatomic) CGFloat margin;// 坐标轴与画布间距
//@property (assign, nonatomic) CGFloat y_(SCREEN_WIDTH - 60)/6;// y轴每一个值的间隔数
//@property (assign, nonatomic) CGFloat (SCREEN_WIDTH == 320?60:100);// 图表的高度
@end

@implementation BezierCurveView
//- (CGFloat)margin
//{
//    return (SCREEN_WIDTH - 60)/6;
//}
//初始化画布
+ (instancetype)initWithFrame:(CGRect)frame
{
    BezierCurveView *bezierCurveView = [[BezierCurveView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH , 60)];
    bezierCurveView.frame = frame;
//    bezierCurveView.backgroundColor = [UIColor redColor];
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
    [path moveToPoint:CGPointMake((SCREEN_WIDTH - 60)/6, CGRectGetHeight(myFrame)-(SCREEN_WIDTH - 60)/6)];
    [path addLineToPoint:CGPointMake((SCREEN_WIDTH - 60)/6, (SCREEN_WIDTH - 60)/6)];
    
    [path moveToPoint:CGPointMake((SCREEN_WIDTH - 60)/6, CGRectGetHeight(myFrame)-(SCREEN_WIDTH - 60)/6)];
    [path addLineToPoint:CGPointMake((SCREEN_WIDTH - 60)/6+CGRectGetWidth(myFrame)-2*(SCREEN_WIDTH - 60)/6, CGRectGetHeight(myFrame)-(SCREEN_WIDTH - 60)/6)];
    
    //2.添加箭头
    [path moveToPoint:CGPointMake((SCREEN_WIDTH - 60)/6, (SCREEN_WIDTH - 60)/6)];
    [path addLineToPoint:CGPointMake((SCREEN_WIDTH - 60)/6-5, (SCREEN_WIDTH - 60)/6+5)];
    [path moveToPoint:CGPointMake((SCREEN_WIDTH - 60)/6, (SCREEN_WIDTH - 60)/6)];
    [path addLineToPoint:CGPointMake((SCREEN_WIDTH - 60)/6+5, (SCREEN_WIDTH - 60)/6+5)];
    
    [path moveToPoint:CGPointMake((SCREEN_WIDTH - 60)/6+CGRectGetWidth(myFrame)-2*(SCREEN_WIDTH - 60)/6, CGRectGetHeight(myFrame)-(SCREEN_WIDTH - 60)/6)];
    [path addLineToPoint:CGPointMake((SCREEN_WIDTH - 60)/6+CGRectGetWidth(myFrame)-2*(SCREEN_WIDTH - 60)/6-5, CGRectGetHeight(myFrame)-(SCREEN_WIDTH - 60)/6-5)];
    [path moveToPoint:CGPointMake((SCREEN_WIDTH - 60)/6+CGRectGetWidth(myFrame)-2*(SCREEN_WIDTH - 60)/6, CGRectGetHeight(myFrame)-(SCREEN_WIDTH - 60)/6)];
    [path addLineToPoint:CGPointMake((SCREEN_WIDTH - 60)/6+CGRectGetWidth(myFrame)-2*(SCREEN_WIDTH - 60)/6-5, CGRectGetHeight(myFrame)-(SCREEN_WIDTH - 60)/6+5)];

    //3.添加索引格
    //X轴
//    for (int i=0; i<x_names.count; i++) {
//        CGFloat X = (SCREEN_WIDTH - 60)/6 + (SCREEN_WIDTH - 60)/6*(i);
//        CGPoint point = CGPointMake(X,CGRectGetHeight(myFrame)-20);
//        [path moveToPoint:point];
//        [path addLineToPoint:CGPointMake(point.x, point.y-3)];
//    }
    //Y轴（实际长度为200,此处比例缩小一倍使用）
//    for (int i=0; i<11; i++) {
//        CGFloat Y = CGRectGetHeight(myFrame)-(SCREEN_WIDTH - 60)/6-Y_EVERY_(SCREEN_WIDTH - 60)/6*i;
//        CGPoint point = CGPointMake((SCREEN_WIDTH - 60)/6,Y);
//        [path moveToPoint:point];
//        [path addLineToPoint:CGPointMake(point.x+3, point.y)];
//    }
    
    //4.添加索引格文字
    //X轴
    for (int i=0; i<x_names.count; i++) {
        CGFloat X = 5 + (SCREEN_WIDTH - 60)/6*i;
        UILabel *textLabel = [[UILabel alloc] initWithFrame:CGRectMake(X, IS_IPHONEX?CGRectGetHeight(myFrame)- 2 *(SCREEN_WIDTH - 60)/6 - 10:CGRectGetHeight(myFrame)- (SCREEN_WIDTH - 60)/6 - 10, (SCREEN_WIDTH - 60)/6, 20)];
        textLabel.text = x_names[i];
//        textLabel.backgroundColor = [UIColor blueColor];
        textLabel.font = [UIFont systemFontOfSize:10];
        textLabel.textAlignment = NSTextAlignmentCenter;
        textLabel.textColor = [UIColor grayColor];
        [self addSubview:textLabel];
    }
    //Y轴
//    for (int i=0; i<11; i++) {
//        CGFloat Y = CGRectGetHeight(myFrame)-(SCREEN_WIDTH - 60)/6-Y_EVERY_(SCREEN_WIDTH - 60)/6*i;
//        UILabel *textLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, Y-5, (SCREEN_WIDTH - 60)/6, 10)];
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
        CGFloat X = 30 + (SCREEN_WIDTH - 60)/6*(i) ;
        CGFloat Y = 0;
        if (maxValue > 60) {
            if (IS_IPHONEX) {
                Y = CGRectGetHeight(myFrame)- 20 - 2*(SCREEN_WIDTH - 60)/6-([targetValues[i] floatValue]/maxValue*(SCREEN_WIDTH == 320?60:100));
            }else{
                Y = CGRectGetHeight(myFrame)- 20 - (SCREEN_WIDTH - 60)/6-([targetValues[i] floatValue]/maxValue*(SCREEN_WIDTH == 320?60:100));
            }
        }else{
            if (IS_IPHONEX) {
                Y = CGRectGetHeight(myFrame)- 20 - 2*(SCREEN_WIDTH - 60)/6-[targetValues[i] floatValue];
            }else{
                Y = CGRectGetHeight(myFrame)- 20 - (SCREEN_WIDTH - 60)/6-[targetValues[i] floatValue];
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
    [path addLineToPoint:CGPointMake(30 + (SCREEN_WIDTH - 60)/6*(6),CGRectGetHeight(myFrame)- 20 - (SCREEN_WIDTH - 60)/6)];
    [path addLineToPoint:CGPointMake(30 + (SCREEN_WIDTH - 60)/6*(0),CGRectGetHeight(myFrame)- 20 - (SCREEN_WIDTH - 60)/6)];
    
    //添加区域颜色填充
    CAShapeLayer *changeColorShapeLayer = [CAShapeLayer layer];
    changeColorShapeLayer.path = path.CGPath;
    changeColorShapeLayer.strokeColor = [UIColor redColor].CGColor;
    changeColorShapeLayer.fillColor = gMainColorRGB.CGColor;
    changeColorShapeLayer.borderWidth = 2.0;
    changeColorShapeLayer.lineWidth = 1;
    [self.subviews[0].layer insertSublayer:changeColorShapeLayer atIndex:0];
    
    //设置渐变属性
    CALayer *layer = [CALayer layer];
    CAGradientLayer *gradientLayer = [CAGradientLayer layer];
    gradientLayer.colors = @[(__bridge id)gMainColorRGB.CGColor, (__bridge id)[UIColor clearColor].CGColor];
    gradientLayer.locations = @[@0.0, @1.0];
    gradientLayer.startPoint = CGPointMake(0, 0);
    gradientLayer.endPoint = CGPointMake(0, 1.0);
    gradientLayer.frame = CGRectMake(30,IS_IPHONEX? CGRectGetHeight(myFrame)- 20 - 2*(SCREEN_WIDTH - 60)/6 - (SCREEN_WIDTH == 320?60:100):CGRectGetHeight(myFrame)- 20 - (SCREEN_WIDTH - 60)/6 - (SCREEN_WIDTH == 320?60:100), 0, (SCREEN_WIDTH == 320?60:100));
    [layer addSublayer:gradientLayer];
    [layer setMask:changeColorShapeLayer];
    [self.subviews[0].layer addSublayer:layer];
    
    //曲线动画
    CABasicAnimation *animation = [CABasicAnimation animationWithKeyPath:@"strokeEnd"];
    animation.duration = 2.0f;
    animation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionLinear];
    animation.fromValue = @(0.0);
    animation.toValue = @(1.0);
    [shapeLayer addAnimation:animation forKey:@"path"];
    
    //图层动画
    CABasicAnimation *anmi1 = [CABasicAnimation animation];
    anmi1.keyPath = @"bounds";
    anmi1.duration = 2.0f;
    anmi1.toValue = [NSValue valueWithCGRect:CGRectMake((SCREEN_WIDTH - 60)/6 + (SCREEN_WIDTH - 60)/6*(0) - 15,IS_IPHONEX? CGRectGetHeight(myFrame)- 20 - 2*(SCREEN_WIDTH - 60)/6 - (SCREEN_WIDTH == 320?60:100):CGRectGetHeight(myFrame)- 20 - (SCREEN_WIDTH - 60)/6 - (SCREEN_WIDTH == 320?60:100), (SCREEN_WIDTH - 60)/6*(6) * 2, (SCREEN_WIDTH == 320?60:100))];
    anmi1.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionLinear];
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
            label.frame = CGRectMake(NowPoint.x-(SCREEN_WIDTH - 60)/6/2, NowPoint.y-25, (SCREEN_WIDTH - 60)/6, 20);
            PrePonit = NowPoint;
        }else{
            CGPoint NowPoint = [allPoints[i] CGPointValue];
//            if (NowPoint.y<=PrePonit.y) {  //文字置于点上方
                label.frame = CGRectMake(NowPoint.x-(SCREEN_WIDTH - 60)/6/2, NowPoint.y-25, (SCREEN_WIDTH - 60)/6, 20);
//            }else{ //文字置于点下方
//                label.frame = CGRectMake(NowPoint.x-(SCREEN_WIDTH - 60)/6/2, NowPoint.y, (SCREEN_WIDTH - 60)/6, 20);
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
        CGFloat X = (SCREEN_WIDTH - 60)/6 + (SCREEN_WIDTH - 60)/6*(i+1)+5;
        CGFloat Y = CGRectGetHeight(myFrame)-(SCREEN_WIDTH - 60)/6-doubleValue;
        UIBezierPath *path = [UIBezierPath bezierPathWithRect:CGRectMake(X-(SCREEN_WIDTH - 60)/6/2, Y, (SCREEN_WIDTH - 60)/6-10, doubleValue)];
        CAShapeLayer *shapeLayer = [CAShapeLayer layer];
        shapeLayer.path = path.CGPath;
        shapeLayer.strokeColor = [UIColor clearColor].CGColor;
        shapeLayer.fillColor = XYQRandomColor.CGColor;
        shapeLayer.borderWidth = 2.0;
        [self.subviews[0].layer addSublayer:shapeLayer];
        
        //3.添加文字
        UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(X-(SCREEN_WIDTH - 60)/6/2, Y-20, (SCREEN_WIDTH - 60)/6-10, 20)];
        label.text = [NSString stringWithFormat:@"%.0lf",(CGRectGetHeight(myFrame)-Y-(SCREEN_WIDTH - 60)/6)/2];
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
