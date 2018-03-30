//
//  UIBarButtonItem+Utility.m
//  zfbuser
//
//  Created by Eric Wang on 15/7/14.
//  Copyright (c) 2015年 Eric. All rights reserved.
//

#import "UIBarButtonItem+Utility.h"

@implementation UIBarButtonItem (Utility)

+ (UIBarButtonItem *)barButtonItemWithImage:(UIImage *)image targer:(id)target selector:(SEL)selector{
    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
    [button setImage:image forState:UIControlStateNormal];
    [button addTarget:target action:selector forControlEvents:UIControlEventTouchUpInside];
    [button sizeToFit];
    UIBarButtonItem *item = [[UIBarButtonItem alloc] initWithCustomView:button];
    return item;
}

+ (UIBarButtonItem *)barButtonItemWithTitle:(NSString *)title
                                       font:(UIFont *)font
                                      color:(UIColor *)color
                                     target:(id)target
                                   selector:(SEL)selector{
    UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
    [btn setTitleColor:color forState:UIControlStateNormal];
    [btn setTitle:title forState:UIControlStateNormal];
    [btn addTarget:target action:selector forControlEvents:UIControlEventTouchUpInside];
    btn.titleLabel.font = font;
    [btn sizeToFit];
    UIBarButtonItem *item = [[UIBarButtonItem alloc] initWithCustomView:btn];
    return item;
}


@end
