//
//  ShareAlertView.m
//  kuangjiaTingWen
//
//  Created by 泡果 on 16/8/11.
//  Copyright © 2016年 贺楠. All rights reserved.
//

#import "ShareAlertView.h"
#import "AppDelegate.h"

@interface ShareAlertView ()

@property (strong, nonatomic) UIView *grayView;
@property (strong, nonatomic) UIScrollView *contentView;
@property (strong, nonatomic) UILabel *title;

@end

@implementation ShareAlertView

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

- (void)setShareTitle:(NSString *)title{
    [self.title setText:title];
}

- (void)setSelectItemWithTitleArr:(NSMutableArray *)itemArr {
    
    //设置居中位置
    AppDelegate *appDelegate = (AppDelegate *)[UIApplication sharedApplication].delegate;
    [self.contentView setCenter:appDelegate.window.center];
    
    for (int i = 0 ; i < [itemArr count]; i ++) {
        NSInteger itemCount = [itemArr count];
        UIButton *itemImgBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        [itemImgBtn setFrame:CGRectMake(self.contentView.frame.size.width / itemCount * i + (self.contentView.frame.size.width / itemCount - 40) / 2, 30, 40, 40)];
        [itemImgBtn setImage:[UIImage imageNamed:itemArr[i][@"image"]] forState:UIControlStateNormal];
//        [itemImgBtn setImageEdgeInsets:UIEdgeInsetsMake(0, 20, 10, 20)];
        [itemImgBtn setTag:(10 + i)];
        [itemImgBtn addTarget:self action:@selector(selecteItemAction:) forControlEvents:UIControlEventTouchUpInside];
        [self.contentView addSubview:itemImgBtn];
        UIButton *itemBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        [itemBtn setFrame:CGRectMake(self.contentView.frame.size.width / itemCount * i, 70, self.contentView.frame.size.width / itemCount, 30)];
        [itemBtn setTitle:itemArr[i][@"title"] forState:UIControlStateNormal];
        [itemBtn setTitleColor:gTextDownload forState:UIControlStateNormal];
        [itemBtn.titleLabel setFont:gFontMain14];
        
        [itemBtn setTag:(10 + i)];
        [itemBtn addTarget:self action:@selector(selecteItemAction:) forControlEvents:UIControlEventTouchUpInside];
        [self.contentView addSubview:itemBtn];
    }
}

- (void)selecteItemAction:(UIButton *)sender {
    
    if (self.selectedTypeBlock) {
        self.selectedTypeBlock(sender.tag - 10);
    }
    [self removeFromSuperview];
}

- (UILabel *)title{
    if (_title == nil) {
        _title = [[UILabel alloc]initWithFrame:CGRectMake(0, 0, 300, 30)];
        [_title setTextColor:gTextColorSub];
        [_title setFont:gFontMain15];
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
        _contentView = [[UIScrollView alloc]initWithFrame:CGRectMake(0, 0 , 300, 110)];
        //设置居中位置
        AppDelegate *appDelegate = (AppDelegate *)[UIApplication sharedApplication].delegate;
        [_contentView setCenter:appDelegate.window.center];
        [_contentView setBackgroundColor:[UIColor whiteColor]];
        [_contentView.layer setMasksToBounds:YES];
        [_contentView.layer setCornerRadius:5];
        [_contentView.layer setBorderWidth:2.0f];
        [_contentView.layer setBorderColor:[UIColor whiteColor].CGColor];
        _contentView.showsVerticalScrollIndicator = YES;
        [_contentView addSubview:self.title];
        
    }
    return _contentView;
}





/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
