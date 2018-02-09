//
//  UIImage+CH.m
//  CommunityCourier
//
//  Created by 陈聪豪 on 16/4/18.
//  Copyright © 2016年 diyuanxinxi.com. All rights reserved.
//

#import "UIImage+CH.h"

@implementation UIImage (CH)

/**
 *  防渲染
 */
+(UIImage *)imgRenderingModeWithImgName:(NSString *)ImgStr
{
    UIImage *img = [UIImage imageNamed:ImgStr];
    img = [img imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
    return img;
}


@end
