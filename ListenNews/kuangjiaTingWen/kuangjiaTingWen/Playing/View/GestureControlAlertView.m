//
//  GestureControlAlertView.m
//  kuangjiaTingWen
//
//  Created by 泡果 on 16/8/15.
//  Copyright © 2016年 贺楠. All rights reserved.
//

#import "GestureControlAlertView.h"
#import "AppDelegate.h"

@interface GestureControlAlertView ()

@property (strong, nonatomic) UIView *grayView;
@property (strong, nonatomic) UIScrollView *contentView;
@property (strong, nonatomic) UILabel *title;

@end

@implementation GestureControlAlertView


- (instancetype)initWithFrame:(CGRect)frame {
    
    if (self = [super initWithFrame:frame]) {
        
        [self setFrame:CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width, [UIScreen mainScreen].bounds.size.height)];
        [self setBackgroundColor:[UIColor colorWithRed:0.7 green:0.7 blue:0.7 alpha:0.1]];
        [self addSubview:self.grayView];
    }
    
    return self;
}

#pragma mark -- 响应方法

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event{
    UITouch *touch = [touches anyObject];
    CGPoint toucuPoint = [touch locationInView:self.grayView];
    
    if (toucuPoint.x >self.contentView.frame.origin.x && toucuPoint.y > self.contentView.frame.origin.y && toucuPoint.x < self.contentView.frame.size.width +self.contentView.frame.origin.x && toucuPoint.y < self.contentView.frame.size.height +self.contentView.frame.origin.y) {
        
    }
    else{
        [self removeFromSuperview];
    }
    
}

- (void)setAlertViewTitle:(NSString *)title{
    [self.title setText:title];
}

- (UILabel *)title{
    if (_title == nil) {
        _title = [[UILabel alloc]initWithFrame:CGRectMake(20, 150, 240, 120)];
        [_title setFont:gFontMajor17];
        [_title setNumberOfLines:0];
        NSString *df = @"手势控制：只需在手机镜头前，近距离用手晃一晃，就可以切换到下一条哦～如若需要该功能，请到设置中开启。^_^";
        NSMutableAttributedString *attriString =[[NSMutableAttributedString alloc] initWithString:df attributes:@{NSForegroundColorAttributeName: gTextDownload,                                       NSFontAttributeName: gFontMajor17}];
        NSRange range2 = [df rangeOfString:@"如若需要该功能，请到设置中开启"];
        [attriString addAttribute:NSForegroundColorAttributeName value:[UIColor colorWithRed:1.00 green:0.34 blue:0.34 alpha:1.00] range:range2];
        _title.attributedText = attriString;
        [_title setTextAlignment:NSTextAlignmentCenter];
    }
    return _title;
}
- (UIView *)grayView{
    if (_grayView == nil) {
        AppDelegate *appDelegate = (AppDelegate *)[UIApplication sharedApplication].delegate;
        _grayView = [[UIView alloc]initWithFrame:appDelegate.window.frame];
        [_grayView setBackgroundColor:[[UIColor grayColor] colorWithAlphaComponent:0.5]];
        [_grayView addSubview:self.contentView];
    }
    return _grayView;
}

-(UIScrollView *)contentView{
    
    if (_contentView == nil) {
        _contentView = [[UIScrollView alloc]initWithFrame:CGRectMake(0, 0 , 280, 320)];
        //设置居中位置
        AppDelegate *appDelegate = (AppDelegate *)[UIApplication sharedApplication].delegate;
        [_contentView setCenter:appDelegate.window.center];
        [_contentView setBackgroundColor:[UIColor whiteColor]];
        [_contentView.layer setMasksToBounds:YES];
        [_contentView.layer setCornerRadius:5];
        [_contentView.layer setBorderWidth:2.0f];
        [_contentView.layer setBorderColor:[UIColor whiteColor].CGColor];
        _contentView.showsVerticalScrollIndicator = YES;
        UIImageView *imageV = [[UIImageView alloc]initWithFrame:CGRectMake(80, 15, 120, 120)];
        [imageV setImage:[UIImage imageNamed:@"shoushitixing"]];
        [_contentView addSubview:imageV];
        [_contentView addSubview:self.title];
        UIButton *downButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [downButton setFrame:CGRectMake(20, 270, 240, 40)];
        [downButton setBackgroundColor:[UIColor colorWithRed:1.00 green:0.34 blue:0.34 alpha:1.00]];
        [downButton setTitle:@"知道了" forState:UIControlStateNormal];
        [downButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [downButton addTarget:self action:@selector(buttonAciton:) forControlEvents:UIControlEventTouchUpInside];
        [_contentView addSubview:downButton];
    }
    return _contentView;
}

- (void)buttonAciton:(UIButton *)sender {
    if (self.clickKnowBlock ) {
        self.clickKnowBlock();
    }
}
@end
