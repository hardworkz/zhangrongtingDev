//
//  zhuboxiangqingBtn.m
//  kuangjiaTingWen
//
//  Created by 贺楠 on 16/7/6.
//  Copyright © 2016年 贺楠. All rights reserved.
//

#import "zhuboxiangqingBtn.h"

@implementation zhuboxiangqingBtn


//- (instancetype)initWithImage:(UIImage *)image andTitle:(NSString *)title{
//    if (self = [super init]){
//        UIImageView *imageView = [[UIImageView alloc]initWithFrame:CGRectMake(8.0 / 375 * IPHONE_W, 20.0 / 667 * IPHONE_H, 22.0 / 375 * IPHONE_W, 22.0 / 667 * IPHONE_H)];
//        imageView.image = image;
//        imageView.contentMode =  UIViewContentModeScaleAspectFit;
//        imageView.tag = 1;
//        [self addSubview:imageView];
//        
//        UILabel *lab = [[UILabel alloc]initWithFrame:CGRectMake(CGRectGetMaxX(imageView.frame), imageView.frame.origin.y, 45.0 / 375 * IPHONE_W, 20.0 / 667 * IPHONE_H)];
//        lab.text = title;
//        lab.textColor = nTextColorSub;
//        lab.font =[UIFont fontWithName:@"Regular" size:10.0f ];
//        [lab setFont:gFontSub11];
//        lab.textAlignment = NSTextAlignmentCenter;
//        lab.tag = 2;
//        [self addSubview:lab];
//    }
//    return self;
//}
//
//- (void)ChangeBlueToBlack:(UIImage *)image{
//    UIImageView *imgV = (UIImageView *)[self viewWithTag:1];
//    UILabel *lab = (UILabel *)[self viewWithTag:2];
//    imgV.image = image;
//    lab.textColor = nTextColorSub;
//    lab.font =[UIFont fontWithName:@"Regular" size:10.0f ];
//    [lab setFont:gFontSub11];
//}
//
//- (void)ChangeBlackToBlue:(UIImage *)image{
//    UIImageView *imgV = (UIImageView *)[self viewWithTag:1];
//    UILabel *lab = (UILabel *)[self viewWithTag:2];
//    imgV.image = image;
//    lab.textColor = nMainColor;
//    lab.font =[UIFont fontWithName:@"Semibold" size:10.0f ];
//    [lab setFont:gFontSub11];
//}
- (CGRect)imageRectForContentRect:(CGRect)contentRect
{
    if (self.isClass) {
        if (SCREEN_WIDTH >= 375) {
            return CGRectMake(35, (62.0 / 667 * SCREEN_HEIGHT - 25)*0.5, 25, 25);
        }else{
            return CGRectMake(30, (62.0 / 667 * SCREEN_HEIGHT - 20)*0.5, 20, 20);
        }
    }else{
        if (SCREEN_WIDTH >= 375) {
            return CGRectMake(10, (62.0 / 667 * SCREEN_HEIGHT - 25)*0.5, 25, 25);
        }else{
            return CGRectMake(5, (62.0 / 667 * SCREEN_HEIGHT - 20)*0.5, 20, 20);
        }
    }
}
@end
