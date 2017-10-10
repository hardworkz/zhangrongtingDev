//
//  UIBarButtonItem+Utility.h
//  zfbuser
//
//  Created by Eric Wang on 15/7/14.
//  Copyright (c) 2015年 Eric. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIBarButtonItem (Utility)

+ (UIBarButtonItem *)barButtonItemWithImage:(UIImage *)image targer:(id)target selector:(SEL)selector;

+ (UIBarButtonItem *)barButtonItemWithTitle:(NSString *)title
                                       font:(UIFont *)font
                                      color:(UIColor *)color
                                     target:(id)target
                                   selector:(SEL)selector;


@end
