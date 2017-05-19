//
//  XWAlerLoginView.m
//  XWAlerView
//
//  Created by 温仲斌 on 16/1/6.
//  Copyright © 2016年 温仲斌. All rights reserved.
//

#import "XWAlerLoginView.h"

@implementation XWAlerLoginView

- (instancetype)initWithTitle:(NSString *)string {
    if (self = [super init]) {
        
        CGRect rect = [string boundingRectWithSize:CGSizeMake(0, 30) options:NSStringDrawingUsesFontLeading | NSStringDrawingUsesDeviceMetrics attributes:@{NSFontAttributeName : [UIFont systemFontOfSize:15]} context:nil];
        self.backgroundColor = [UIColor colorWithWhite:0.000 alpha:0.513];
        
        self.bounds = CGRectMake(0, 0, CGRectGetWidth(rect) + 20, 30);
        CATextLayer *textLayer = [CATextLayer layer];
        textLayer.bounds = CGRectMake(0, 0, CGRectGetWidth(rect) + 20, 20);
        textLayer.foregroundColor = [UIColor whiteColor].CGColor;
        textLayer.string = string;
        textLayer.contentsScale = [UIScreen mainScreen].scale;
        textLayer.alignmentMode = kCAAlignmentCenter;
        textLayer.fontSize = 15;
        textLayer.position = CGPointMake((rect.size.width + 20) / 2, 15);
        textLayer.backgroundColor = [UIColor clearColor].CGColor;
        self.center = CGPointMake(CGRectGetWidth([UIScreen mainScreen].bounds) / 2, CGRectGetHeight([UIScreen mainScreen].bounds) + 20);
        self.alpha = 0;
        self.layer.cornerRadius = 5;
        self.layer.masksToBounds = YES;
        [self.layer addSublayer:textLayer];
        
    }
    return self;
}

- (void)show {
    UIWindow *window = [UIApplication sharedApplication].windows.lastObject;
    for (UIView *v  in window.subviews) {
        if ([v isKindOfClass:[self class]]) {
            return;
        }
    }
    [window addSubview:self];
    [UIView animateWithDuration:.5 delay:0 usingSpringWithDamping:0.55 initialSpringVelocity:1 / 0.55 options:0 animations:^{
        self.transform = CGAffineTransformMakeTranslation(0, -100);
        self.alpha = 1;
    } completion:^(BOOL finished) {
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [self dissmiss];
        });
    }];
}

- (void)dissmiss {
    [UIView animateWithDuration:.5 delay:0 usingSpringWithDamping:0.55 initialSpringVelocity:1 / 0.55 options:0 animations:^{
        self.transform = CGAffineTransformIdentity;;
        self.alpha = 0;
    } completion:^(BOOL finished) {
        [self removeFromSuperview];
    }];
}

@end
