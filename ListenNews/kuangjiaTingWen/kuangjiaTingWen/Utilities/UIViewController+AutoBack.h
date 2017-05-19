//
//  UIViewController+AutoBack.h
//  zfbuser
//
//  Created by Eric Wang on 15/7/8.
//  Copyright (c) 2015年 Eric. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIViewController (AutoBack)

/**
 *  自动添加导航栏返回按钮及自动判断返回方法
 */
- (void)enableAutoBack;

/**
 *  自动返回方法，当需要在返回的时候处理其他事务时需要重写此方法
 *
 *  @param barItem 按钮
 */
- (void)actionAutoBack:(UIBarButtonItem *)barItem;

@end
