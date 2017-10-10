//
//  ShareView.m
//  kuangjiaTingWen
//
//  Created by Zhimi on 16/12/23.
//  Copyright © 2016年 贺楠. All rights reserved.
//

#import "ShareView.h"
#import "AppDelegate.h"

@interface ShareView()

@property (strong, nonatomic) UIView *grayView;
@property (strong, nonatomic) UIScrollView *contentView;
@property (strong, nonatomic) UILabel *title;
@property (strong, nonatomic) UIButton *cancelButton;

@end

@implementation ShareView


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
    
    for (int i = 0 ; i < 2 * 3; i ++) {
        CGFloat w = (self.contentView.frame.size.width - 120) / 4;
        CGFloat h = (self.contentView.frame.size.height - 80)/3;
        UIButton *itemImgBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        [itemImgBtn setFrame:CGRectMake(i % 3 * (w + 40) + w , i / 3 *(40 + h)+ h, 40, 40)];
        [itemImgBtn setImage:[UIImage imageNamed:itemArr[i][@"image"]] forState:UIControlStateNormal];
        [itemImgBtn setTag:(10 + i)];
        [itemImgBtn addTarget:self action:@selector(selecteItemAction:) forControlEvents:UIControlEventTouchUpInside];
        [self.contentView addSubview:itemImgBtn];
        
        UIButton *itemBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        [itemBtn setFrame:CGRectMake(itemImgBtn.frame.origin.x - 10, itemImgBtn.frame.origin.y + itemImgBtn.frame.size.height, 60, 30)];
        [itemBtn setTitle:itemArr[i][@"title"] forState:UIControlStateNormal];
        [itemBtn setTitleColor:gTextDownload forState:UIControlStateNormal];
        [itemBtn.titleLabel setFont:gFontSub11];
        
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

- (void)cancelButtonAction:(UIButton *)sender {
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
        [_grayView addSubview:self.cancelButton];
    }
    return _grayView;
}

-(UIScrollView *)contentView{
    
    if (_contentView == nil) {
        _contentView = [[UIScrollView alloc]initWithFrame:CGRectMake(10,SCREEN_HEIGHT - 264 , SCREEN_WIDTH - 20, 200)];
        [_contentView setBackgroundColor:[UIColor whiteColor]];
        [_contentView.layer setMasksToBounds:YES];
        [_contentView.layer setCornerRadius:10.0];
        [_contentView.layer setBorderWidth:2.0f];
        [_contentView.layer setBorderColor:[UIColor whiteColor].CGColor];
        _contentView.showsVerticalScrollIndicator = YES;
//        [_contentView addSubview:self.title];
    }
    return _contentView;
}

- (UIButton *)cancelButton{
    if (_cancelButton == nil) {
        _cancelButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [_cancelButton setFrame:CGRectMake(10, SCREEN_HEIGHT - 54, SCREEN_WIDTH - 20, 44)];
        [_cancelButton setTitle:@"取消" forState:UIControlStateNormal];
        [_cancelButton setTitleColor:gMainColor forState:UIControlStateNormal];
        [_cancelButton setBackgroundColor:[UIColor whiteColor]];
        [_cancelButton.layer setMasksToBounds:YES];
        [_cancelButton.layer setCornerRadius:10.0];
        [_cancelButton addTarget:self action:@selector(cancelButtonAction:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _cancelButton;
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
