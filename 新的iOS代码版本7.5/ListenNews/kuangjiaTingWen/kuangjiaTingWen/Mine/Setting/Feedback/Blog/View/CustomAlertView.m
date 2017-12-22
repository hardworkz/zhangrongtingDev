//
//  DeleteCommentAlertView.m
//  kuangjiaTingWen
//
//  Created by 泡果 on 2017/5/22.
//  Copyright © 2017年 zhimi. All rights reserved.
//

#import "CustomAlertView.h"
@implementation CustomAlertView
-(UIView *)topView
{
    return [[[UIApplication sharedApplication] delegate] window];
}
- (void)show
{
    self.frame = CGRectMake(0, SCREEN_HEIGHT, SCREEN_WIDTH, _alertHeight);
    [[self topView] addSubview:self];
    //添加遮盖
    UIButton *cover = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_HEIGHT)];
    
    cover.backgroundColor = [UIColor blackColor];
    cover.alpha = 0;
    [cover addTarget:self action:@selector(coverClick) forControlEvents:UIControlEventTouchUpInside];
    [[self topView] insertSubview:cover belowSubview:self];
    self.cover = cover;
    
    [UIView animateWithDuration:_alertDuration animations:^{
        cover.alpha = _coverAlpha;
        self.frame = CGRectMake(0, SCREEN_HEIGHT - _alertHeight, SCREEN_WIDTH, _alertHeight);
    }];
}
- (void)coverClick
{
    [UIView animateWithDuration:_alertDuration animations:^{
        self.frame = CGRectMake(0, SCREEN_HEIGHT, SCREEN_WIDTH, _alertHeight);
        self.cover.alpha = 0;
    } completion:^(BOOL finished) {
        [self.cover removeFromSuperview];
        [self removeFromSuperview];
    }];
}
- (instancetype)initWithCustomView:(UIView *)view
{
    if (self = [super init]) {
        [self addSubview:view];
    }
    return self;
}
@end
