//
//  UIViewController+AutoBack.m
//  zfbuser
//
//  Created by Eric Wang on 15/7/8.
//  Copyright (c) 2015年 Eric. All rights reserved.
//

#import "UIViewController+AutoBack.h"

@implementation UIViewController (AutoBack)

- (void)enableAutoBack{
    if ([self isKindOfClass:[UINavigationController class]]) {
        [[self findUIViewController] enableViewControllerAutoBack];
        return;
    };
    if (!self.navigationController)
        return;
    [self enableViewControllerAutoBack];
}

//找到 UIViewcontroller
- (UIViewController *)findUIViewController{
    if ([self isKindOfClass:[UINavigationController class]]) {
        UINavigationController * nav = (UINavigationController *)self;
        return nav.topViewController;
    };
    return self;
}

- (void)enableViewControllerAutoBack{
    SEL action = NULL;
    action = @selector(actionAutoBack:);
    
    UIImage * imgOn = [UIImage imageNamed:@"title_ic_back"];
    UIImage * imgOff = [UIImage imageNamed:@"title_ic_back"];
    
    UIButton * btn = [UIButton buttonWithType:UIButtonTypeCustom];
    CGSize size = CGSizeMake(25, 25);
    CGRect rect = CGRectMake(0, 0, size.width, size.height);
    btn.contentEdgeInsets = UIEdgeInsetsMake(0, -10, 0, 0);
    btn.frame = rect;
    [btn setImage:imgOn forState:UIControlStateNormal];
    [btn setImage:imgOff forState:UIControlStateHighlighted];
    [btn addTarget:self action:action forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem * barItem = [[UIBarButtonItem alloc] initWithCustomView:btn];
    barItem.accessibilityLabel = @"返回";
    self.navigationItem.leftBarButtonItem = barItem;
}

- (void)actionDismiss{
    [self.presentingViewController dismissViewControllerAnimated:YES completion:nil];
}

- (void)actionPop{
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)actionAutoBack:(UIBarButtonItem *)barItem{
    if (self.presentingViewController) {
        NSArray * viewcontrollers = self.navigationController.viewControllers;
        NSInteger idxInStack = [viewcontrollers indexOfObject:self];
        if (idxInStack > 0) {
            [self.navigationController popViewControllerAnimated:YES];
        }else
            [self.presentingViewController dismissViewControllerAnimated:YES completion:nil];
    }else{
        [self.navigationController popViewControllerAnimated:YES];
    };
}

@end
