//
//  bofangBtn.m
//  reHeardTheNews
//
//  Created by 贺楠 on 16/4/14.
//  Copyright © 2016年 paoguo. All rights reserved.
//

#import "bofangBtn.h"

@implementation bofangBtn

- (instancetype)initWithImage:(UIImage *)image andTitle:(NSString *)title
{
    if (self = [super init])
    {
        UIImageView *imageView = [[UIImageView alloc]initWithFrame:CGRectMake(55.0 / 320 * IPHONE_W, 10.0 / 568 * IPHONE_H, 18.0 / 320 * IPHONE_W, 18.0 / 568 * IPHONE_H)];
        imageView.image = image;
        imageView.contentMode =  UIViewContentModeScaleAspectFit;
        imageView.tag = 1;
        [self addSubview:imageView];
        
        UILabel *lab = [[UILabel alloc]initWithFrame:CGRectMake(CGRectGetMaxX(imageView.frame) + 5.0 / 320 * IPHONE_W, 10.0 / 568 * IPHONE_H, 50.0 / 320 * IPHONE_W, 20.0 / 568 * IPHONE_H)];
        lab.text = title;
        lab.textColor = [UIColor blackColor];
        lab.font =[UIFont fontWithName:@"Courier" size:16.0 ];
        lab.textAlignment = NSTextAlignmentLeft;
        lab.tag = 2;
        [self addSubview:lab];
    }
    return self;
}

@end
