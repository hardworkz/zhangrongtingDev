//
//  cellRightBtn.m
//  kuangjiaTingWen
//
//  Created by 贺楠 on 16/7/8.
//  Copyright © 2016年 贺楠. All rights reserved.
//

#import "cellRightBtn.h"

@implementation cellRightBtn

- (instancetype)initWithImage:(UIImage *)image
{
    if (self = [super init])
    {
        self.layer.masksToBounds = YES;
        self.layer.cornerRadius = 25.0;
        self.backgroundColor = [[UIColor grayColor]colorWithAlphaComponent:0.6f];
        
        UIImageView *imageView = [[UIImageView alloc]initWithFrame:CGRectMake(12.5 / 375 * IPHONE_W, 12.5 / 667 * IPHONE_H, 25.0 / 375 * IPHONE_W, 25.0 / 667 * IPHONE_H)];
        imageView.image = image;
        imageView.contentMode =  UIViewContentModeScaleAspectFit;
        [self addSubview:imageView];
    }
    return self;
}

@end
