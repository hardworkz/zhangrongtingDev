//
//  zhuboxiangqingBtn.m
//  kuangjiaTingWen
//
//  Created by 贺楠 on 16/7/6.
//  Copyright © 2016年 贺楠. All rights reserved.
//

#import "zhuboxiangqingBtn.h"

@implementation zhuboxiangqingBtn


- (CGRect)imageRectForContentRect:(CGRect)contentRect
{
    if (self.isClass) {
        if (SCREEN_WIDTH >= 375) {
            if (IS_IPHONEX) {
                return CGRectMake(15, (62.0 - 25)*0.5, 25, 25);
            }else{
                return CGRectMake(35, (62.0 / 667 * SCREEN_HEIGHT - 25)*0.5, 25, 25);
            }
        }else{
            return CGRectMake(30, (62.0 / 667 * SCREEN_HEIGHT - 20)*0.5, 20, 20);
        }
    }else{
        if (SCREEN_WIDTH >= 375) {
            if (IS_IPHONEX) {
                return CGRectMake(15, (62.0 - 25)*0.5, 25, 25);
            }else{
                return CGRectMake(10, (62.0 / 667 * SCREEN_HEIGHT - 25)*0.5, 25, 25);
            }
        }else{
            return CGRectMake(5, (62.0 / 667 * SCREEN_HEIGHT - 20)*0.5, 20, 20);
        }
    }
}
@end
