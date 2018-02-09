//
//  BYGraphicsView.m
//  DrawGraph
//
//  Created by 华图－林必里 on 17/1/18.
//  Copyright © 2017年 huatu. All rights reserved.
//



#import "BYGraphicsView.h"

//枚举图形类别
typedef enum : NSUInteger {
    BYGraphicsViewTypeEllipse = 0,//椭圆
    BYGraphicsViewTypeLowerRightArc,//右下角带圆弧
    BYGraphicsViewTypeBottomArc,//底部圆弧
    BYGraphicsViewTypeTopTriangle,//顶部三角形
    BYGraphicsViewTypeBottomTriangle,//底部三角形
} BYGraphicsViewType;


@implementation BYGraphicsView
{
    BYGraphicsViewType _currentGraphicsViewType;//当前要绘制的图形类别
    float _cornerRadius;//圆弧的半径
    float _triangleWidth;//三角形的宽度
    float _triangleHeight;//三角形的高度
    float _triangleOffsetX;//三角形相对图形X轴的偏移量
    UIImage *_bgImage;//背景图片
    UIColor *_bgColor;//背景颜色
}


// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.

- (void)drawRect:(CGRect)rect {
    
    switch (_currentGraphicsViewType) {
            
        case BYGraphicsViewTypeEllipse:
            //绘制椭圆
            [self drawViewToEllipse];
            break;
            
        case BYGraphicsViewTypeLowerRightArc:
            //绘制右下角为圆角
            [self drawViewToLowerRightArc];
            break;
            
        case BYGraphicsViewTypeBottomArc:
            //绘制底边为圆弧
            [self drawViewToBottomArc];
            break;
            
        case BYGraphicsViewTypeTopTriangle:
            //绘制顶部三角形
            [self drawViewToTopTriangle];
            break;
            
        case BYGraphicsViewTypeBottomTriangle:
            //绘制底部三角形
            [self drawViewToBottomTriangle];
            break;
            
        default:
            break;
    }
    
}


#pragma mark - 绘图区

//绘制椭圆
- (void)drawViewToEllipse {
    
    //当前视图的size
    CGSize currentSize = self.frame.size;
    
    //获取图形上下文
    CGContextRef ctx=UIGraphicsGetCurrentContext();
    
    //如果没有指定背景图片
    if (_bgImage == nil) {
        
        //设置填充颜色
        CGContextSetFillColorWithColor(ctx, _bgColor.CGColor);
        //        //设置线条颜色
        //        CGContextSetStrokeColorWithColor(ctx, _bgColor.CGColor);
        //        //设置线条宽度
        //        CGContextSetLineWidth(ctx, 1);
    }
    
    // 绘制圆方法(其实所绘制的圆为所绘制用的Rect的矩形的内切圆，当宽度等于高度时，即为正圆)
    CGContextAddEllipseInRect(ctx, CGRectMake(0, 0, currentSize.width, currentSize.height));
    
    //形成闭合路径
    CGContextClosePath(ctx);
    
    //如果没有指定背景图片
    if (_bgImage == nil) {
        //绘制图形（路径）
        CGContextDrawPath(ctx, kCGPathFill);
        
    }else{
        //注意：裁切范围（也就是指定剪切的方法一定要在绘制范围之前进行调用）
        CGContextClip(ctx);
        [_bgImage drawInRect:CGRectMake(0, 0, self.frame.size.width, self.frame.size.height)];
    }
}

//绘制右下角为圆角
- (void)drawViewToLowerRightArc {
    
    //当前视图的size
    CGSize currentSize = self.frame.size;
    
    //获取图形上下文
    CGContextRef ctx=UIGraphicsGetCurrentContext();
    
    //如果没有指定背景图片
    if (_bgImage == nil) {
        
        //设置填充颜色
        CGContextSetFillColorWithColor(ctx, _bgColor.CGColor);
        //        //设置线条颜色
        //        CGContextSetStrokeColorWithColor(ctx, _bgColor.CGColor);
        //        //设置线条宽度
        //        CGContextSetLineWidth(ctx, 1);
    }
    
    //指定当前的起始点
    CGContextMoveToPoint(ctx, 0, 0);
    //指定点1，将从起点到点1形成一条线
    CGContextAddLineToPoint(ctx, currentSize.width, 0);
    //指定点2，将从点1到点2形成一条线
    CGContextAddLineToPoint(ctx, currentSize.width, currentSize.height - _cornerRadius);
    
    //更改当前的起始点
    CGContextMoveToPoint(ctx, 0, 0);
    //指定点3，将从起点到点3形成一条线
    CGContextAddLineToPoint(ctx, 0, currentSize.height);
    //指定点4，将从点3到点4形成一条线
    CGContextAddLineToPoint(ctx, currentSize.width - _cornerRadius, currentSize.height);
    
    //绘制二次贝塞尔曲线，控制点为矩形的右下角点坐标，当前最后一次指定的点将要连接的目标点
    CGContextAddQuadCurveToPoint(ctx, currentSize.width, currentSize.height, currentSize.width, currentSize.height - _cornerRadius);
    
    //形成闭合路径
    CGContextClosePath(ctx);
    
    //如果没有指定背景图片
    if (_bgImage == nil) {
        //绘制图形（路径）
        CGContextDrawPath(ctx, kCGPathFill);
        
    }else{
        //注意：裁切范围（也就是指定剪切的方法一定要在绘制范围之前进行调用）
        CGContextClip(ctx);
        [_bgImage drawInRect:CGRectMake(0, 0, self.frame.size.width, self.frame.size.height)];
    }
}

//绘制底边为圆弧
- (void)drawViewToBottomArc {
    
    //当前视图的size
    CGSize currentSize = self.frame.size;
    
    //获取图形上下文
    CGContextRef ctx=UIGraphicsGetCurrentContext();
    
    //如果没有指定背景图片
    if (_bgImage == nil) {
        
        //设置填充颜色
        CGContextSetFillColorWithColor(ctx, _bgColor.CGColor);
        //        //设置线条颜色
        //        CGContextSetStrokeColorWithColor(ctx, _bgColor.CGColor);
        //        //设置线条宽度
        //        CGContextSetLineWidth(ctx, 1);
    }
    
    //指定当前的起始点
    CGContextMoveToPoint(ctx, 0, 0);
    //指定点1，将从起点到点1形成一条线
    CGContextAddLineToPoint(ctx, currentSize.width, 0);
    //指定点2，将从点1到点2形成一条线
    CGContextAddLineToPoint(ctx, currentSize.width, currentSize.height - _cornerRadius);
    
    //更改当前的起始点
    CGContextMoveToPoint(ctx, 0, 0);
    //指定点3，将从起点到点3形成一条线
    CGContextAddLineToPoint(ctx, 0, currentSize.height - _cornerRadius);
    
    //绘制二次贝塞尔曲线，控制点为矩形的底边中点坐标，当前最后一次指定的点将要连接的目标点
    CGContextAddQuadCurveToPoint(ctx, currentSize.width/2, currentSize.height, currentSize.width, currentSize.height - _cornerRadius);
    
    //形成闭合路径
    CGContextClosePath(ctx);
    
    //如果没有指定背景图片
    if (_bgImage == nil) {
        //绘制图形（路径）
        CGContextDrawPath(ctx, kCGPathFill);
        
    }else{
        //注意：裁切范围（也就是指定剪切的方法一定要在绘制范围之前进行调用）
        CGContextClip(ctx);
        [_bgImage drawInRect:CGRectMake(0, 0, self.frame.size.width, self.frame.size.height)];
    }
}

//绘制顶部三角形
- (void)drawViewToTopTriangle {
    
    //当前视图的size
    CGSize currentSize = self.frame.size;
    
    //获取图形上下文
    CGContextRef ctx=UIGraphicsGetCurrentContext();
    
    //如果没有指定背景图片
    if (_bgImage == nil) {
        
        //设置填充颜色
        CGContextSetFillColorWithColor(ctx, _bgColor.CGColor);
        //        //设置线条颜色
        //        CGContextSetStrokeColorWithColor(ctx, _bgColor.CGColor);
        //        //设置线条宽度
        //        CGContextSetLineWidth(ctx, 1);
    }
    
    //指定当前的起始点
    CGContextMoveToPoint(ctx, 0, _triangleHeight);
    //指定三角形的左边点
    CGContextAddLineToPoint(ctx, _triangleOffsetX, _triangleHeight);
    //指定三角形的尖点（高点）
    CGContextAddLineToPoint(ctx, _triangleOffsetX + _triangleWidth/2, 0);
    //指定三角形的右边点
    CGContextAddLineToPoint(ctx, _triangleOffsetX + _triangleWidth, _triangleHeight);
    
    CGContextAddLineToPoint(ctx, currentSize.width, _triangleHeight);
    
    CGContextAddLineToPoint(ctx, currentSize.width, currentSize.height);

    CGContextAddLineToPoint(ctx, 0, currentSize.height);
    
    //形成闭合路径
    CGContextClosePath(ctx);
    
    //如果没有指定背景图片
    if (_bgImage == nil) {
        //绘制图形（路径）
        CGContextDrawPath(ctx, kCGPathFill);
        
    }else{
        //注意：裁切范围（也就是指定剪切的方法一定要在绘制范围之前进行调用）
        CGContextClip(ctx);
        [_bgImage drawInRect:CGRectMake(0, 0, self.frame.size.width, self.frame.size.height)];
    }
}

//绘制底部三角形
- (void)drawViewToBottomTriangle {
    
    //当前视图的size
    CGSize currentSize = self.frame.size;
    
    //获取图形上下文
    CGContextRef ctx=UIGraphicsGetCurrentContext();
    
    //如果没有指定背景图片
    if (_bgImage == nil) {
        
        //设置填充颜色
        CGContextSetFillColorWithColor(ctx, _bgColor.CGColor);
        //        //设置线条颜色
        //        CGContextSetStrokeColorWithColor(ctx, _bgColor.CGColor);
        //        //设置线条宽度
        //        CGContextSetLineWidth(ctx, 1);
    }
    
    //指定当前的起始点
    CGContextMoveToPoint(ctx, 0, 0);
    //指定点1，将从起点到点1形成一条线
    CGContextAddLineToPoint(ctx, currentSize.width, 0);
    //指定点2，将从点1到点2形成一条线
    CGContextAddLineToPoint(ctx, currentSize.width, currentSize.height - _triangleHeight);
    //指定三角形的右边点
    CGContextAddLineToPoint(ctx, _triangleOffsetX + _triangleWidth, currentSize.height - _triangleHeight);
    //指定三角形的尖点（高点）
    CGContextAddLineToPoint(ctx, _triangleOffsetX + _triangleWidth/2, currentSize.height);
    //指定三角形的左边点
    CGContextAddLineToPoint(ctx, _triangleOffsetX, currentSize.height - _triangleHeight);
    
    CGContextAddLineToPoint(ctx, 0, currentSize.height - _triangleHeight);
    
    //形成闭合路径
    CGContextClosePath(ctx);
    
    //如果没有指定背景图片
    if (_bgImage == nil) {
        //绘制图形（路径）
        CGContextDrawPath(ctx, kCGPathFill);
        
    }else{
        //注意：裁切范围（也就是指定剪切的方法一定要在绘制范围之前进行调用）
        CGContextClip(ctx);
        [_bgImage drawInRect:CGRectMake(0, 0, self.frame.size.width, self.frame.size.height)];
    }
}


#pragma mark - 设置方法区

//设置当前视图为椭圆，以及背景图片，背景色
- (void)setViewToEllipseWithBackgroundImage:(UIImage *)bgImage backgroundColor:(UIColor *)bgColor {
    
    _currentGraphicsViewType = BYGraphicsViewTypeEllipse;
    _bgImage = bgImage;
    _bgColor = bgColor;
    
    //重绘视图
    [self setNeedsDisplay];
}

//设置右下角的圆角半径，以及背景图片，背景色
- (void)setViewToLowerRightArcWithCornerRadius:(float)cornerRadius backgroundImage:(UIImage *)bgImage backgroundColor:(UIColor *)bgColor {
   
    _currentGraphicsViewType = BYGraphicsViewTypeLowerRightArc;
    _cornerRadius = cornerRadius;
    _bgImage = bgImage;
    _bgColor = bgColor;
    
    //重绘视图
    [self setNeedsDisplay];
}

//设置底部（左下角 = 右下角）的圆角半径，以及背景图片，背景色
- (void)setViewToBottomArcWithCornerRadius:(float)cornerRadius backgroundImage:(UIImage *)bgImage backgroundColor:(UIColor *)bgColor {
    
    _currentGraphicsViewType = BYGraphicsViewTypeBottomArc;
    _cornerRadius = cornerRadius;
    _bgImage = bgImage;
    _bgColor = bgColor;
    
    //重绘视图
    [self setNeedsDisplay];
}

//设置顶部三角形的宽度、高度、相对图形X轴的偏移量，以及背景图片，背景色
- (void)setViewToTopTriangleWithWidth:(float)triangleWidth height:(float)triangleHeight offsetX:(float)triangleOffsetX backgroundImage:(UIImage *)bgImage backgroundColor:(UIColor *)bgColor {
    
    _currentGraphicsViewType = BYGraphicsViewTypeTopTriangle;
    _triangleWidth = triangleWidth;
    _triangleHeight = triangleHeight;
    _triangleOffsetX = triangleOffsetX;
    _bgImage = bgImage;
    _bgColor = bgColor;
    
    //重绘视图
    [self setNeedsDisplay];
}

//设置底部三角形的宽度、高度、相对图形X轴的偏移量，以及背景图片，背景色
- (void)setViewToBottomTriangleWithWidth:(float)triangleWidth height:(float)triangleHeight offsetX:(float)triangleOffsetX backgroundImage:(UIImage *)bgImage backgroundColor:(UIColor *)bgColor {
    
    _currentGraphicsViewType = BYGraphicsViewTypeBottomTriangle;
    _triangleWidth = triangleWidth;
    _triangleHeight = triangleHeight;
    _triangleOffsetX = triangleOffsetX;
    _bgImage = bgImage;
    _bgColor = bgColor;
    
    //重绘视图
    [self setNeedsDisplay];
}







@end
