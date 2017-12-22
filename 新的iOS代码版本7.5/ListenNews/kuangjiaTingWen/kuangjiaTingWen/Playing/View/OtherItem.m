//
//  OtherItem.m
//  CommunityCourier
//
//  Created by 陈聪豪 on 16/4/19.
//  Copyright © 2016年 diyuanxinxi.com. All rights reserved.
//

#import "OtherItem.h"

// 文字的高度比例
#define kTitleRatio 0.3
#define TitleFont (SCREEN_WIDTH == 320?11:SCREEN_WIDTH == 375? 13: 15)

@implementation OtherItem

- (id)initWithFrame:(CGRect)frame
{
    
    self = [super initWithFrame:frame];
    if (self) {
        // 1.文字居中
        self.titleLabel.textAlignment = NSTextAlignmentCenter;
        
        // 2.文字大小
        self.titleLabel.font = [UIFont systemFontOfSize:TitleFont];
        
        // 3.图片的内容模式
        self.imageView.contentMode = UIViewContentModeCenter;
        
        [self.imageView.layer setMasksToBounds:YES];
        [self.imageView.layer setCornerRadius:(self.frame.size.width / 2)];
        
        // 4.设置选中时的背景
        //        [self setBackgroundImage:[UIImage imageNamed:kDockItemSelectedBG] forState:UIControlStateSelected];
    }
    return self;
}

#pragma mark 覆盖父类在highlighted时的所有操作
//- (void)setHighlighted:(BOOL)highlighted {
//    //    [super setHighlighted:highlighted];
//}

#pragma mark 调整内部ImageView的frame
- (CGRect)imageRectForContentRect:(CGRect)contentRect
{
    CGFloat imageX = 0;
    CGFloat imageY = 0;
    CGFloat imageWidth = contentRect.size.width;
    CGFloat imageHeight = contentRect.size.height * ( 1- kTitleRatio );
    return CGRectMake(imageX, imageY, imageWidth, imageHeight);
}

#pragma mark 调整内部UILabel的frame
- (CGRect)titleRectForContentRect:(CGRect)contentRect
{
    CGFloat titleX = 0;
    CGFloat titleHeight = contentRect.size.height * kTitleRatio;
    CGFloat titleY = contentRect.size.height - titleHeight;
    CGFloat titleWidth = contentRect.size.width;
    return CGRectMake(titleX, titleY, titleWidth, titleHeight);
}


@end
