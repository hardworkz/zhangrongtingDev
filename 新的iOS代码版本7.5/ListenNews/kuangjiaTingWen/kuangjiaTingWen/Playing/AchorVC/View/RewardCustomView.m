//
//  RewardCustomView.m
//  kuangjiaTingWen
//
//  Created by Zhimi on 17/3/3.
//  Copyright © 2017年 贺楠. All rights reserved.
//

#import "RewardCustomView.h"
#import "AppDelegate.h"

#import "LoginVC.h"
#import "LoginNavC.h"


@interface RewardCustomView ()

@property (strong, nonatomic) UIView *grayView;
@property (strong, nonatomic) UIScrollView *contentView;


@property (assign, nonatomic) BOOL isCustomRewardCount;
@property (nonatomic, strong) NSMutableArray *buttons;
@property (strong, nonatomic) OJLAnimationButton *finalRewardButton;
@property (assign, nonatomic) float rewardCount;

@property (strong, nonatomic) UITextField *customRewardTextField;

@end

@implementation RewardCustomView

- (instancetype)initWithFrame:(CGRect)frame {
    
    if (self = [super initWithFrame:frame]) {
        
        [self setFrame:CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width, [UIScreen mainScreen].bounds.size.height)];
        [self setBackgroundColor:[UIColor colorWithRed:0.7 green:0.7 blue:0.7 alpha:0.1]];
        [self addSubview:self.grayView];
        self.isCustomRewardCount = NO;
    }
    
    return self;
}


- (void)setSelectItemWithTitleArr:(NSMutableArray *)itemArr{

    //设置居中位置
    AppDelegate *appDelegate = (AppDelegate *)[UIApplication sharedApplication].delegate;
    [self.contentView setCenter:appDelegate.window.center];
    
    UIView *rewardBorderView = [[UIView alloc]initWithFrame:CGRectMake(15, 55, self.contentView.frame.size.width - 30, 100)];
    [rewardBorderView setUserInteractionEnabled:YES];
    [rewardBorderView.layer setBorderWidth:1.0];
    [rewardBorderView.layer setBorderColor:gTextRewardColor.CGColor];
    [rewardBorderView.layer setMasksToBounds:YES];
    [rewardBorderView.layer setCornerRadius:5.0];
    [self.contentView addSubview:rewardBorderView];
    UIImageView *smile = [[UIImageView alloc]initWithFrame:CGRectMake(30, 15, 60, 66.5)];
    [smile setImage:[UIImage imageNamed:@"COIN21"]];
    [self.contentView addSubview:smile];
    
        
    UILabel *tipLabel = [[UILabel alloc]initWithFrame:CGRectMake( 80, 5, 220, 32)];
    [tipLabel setText:self.isCustomRewardCount ? @"请输入自定义金额" : @"您的支持是我们最大的动力~"];
    [tipLabel setTextColor:gTextDownload];
    [tipLabel setFont:gFontMain14];
    [rewardBorderView addSubview:tipLabel];
    
    UIView *selectedView = [[UIView alloc]initWithFrame:CGRectMake(0, 41, rewardBorderView.frame.size.width, 80)];
    [rewardBorderView addSubview:selectedView];
    selectedView.hidden = self.isCustomRewardCount ? YES : NO;
    
    NSMutableArray *items = [NSMutableArray array];
    NSDictionary *dic0 = @{@"title":@"1听币"};
    [items addObject:dic0];
    NSDictionary *dic1 = @{@"title":@"5听币"};
    [items addObject:dic1];
    NSDictionary *dic2 = @{@"title":@"10听币"};
    [items addObject:dic2];
    NSDictionary *dic3 = @{@"title":@"50听币"};
    [items addObject:dic3];
    NSDictionary *dic4 = @{@"title":@"100听币"};
    [items addObject:dic4];
    NSDictionary *dic5 = @{@"title":@"自定义"};
    [items addObject:dic5];
    
    if ([self.buttons count]) {
        [self.buttons removeAllObjects];
    }
    for (int i = 0 ; i < 2 * 3; i ++) {
        CGFloat w = (rewardBorderView.frame.size.width - 240) / 4;
        CGFloat h = (rewardBorderView.frame.size.height - 90)/3;
        UIButton *itemImgBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        [itemImgBtn setFrame:CGRectMake(i % 3 * (w + 80) + w , i / 3 *(30 + h)+ h, 80, 30)];
        [itemImgBtn setTitle:items[i][@"title"] forState:UIControlStateNormal];
        [itemImgBtn setTitleColor:gTextRewardColor forState:UIControlStateNormal];
        [itemImgBtn.layer setBorderWidth:0.5];
        [itemImgBtn.layer setBorderColor:gTextRewardColor.CGColor];
        [itemImgBtn.layer setMasksToBounds:YES];
        [itemImgBtn.layer setCornerRadius:15.0];
        [itemImgBtn.titleLabel setFont:gFontSub11];
        [itemImgBtn setTag:(100 + i)];
        [itemImgBtn addTarget:self action:@selector(selecteRewardCountAction:) forControlEvents:UIControlEventTouchUpInside];
        [self.buttons addObject:itemImgBtn];
        [selectedView addSubview:itemImgBtn];
        if (i == 1) {
            [self selecteRewardCountAction:itemImgBtn];
        }
    }
    
    UIView *customRewardView = [[UIView alloc]initWithFrame:CGRectMake(15, 55, rewardBorderView.frame.size.width - 30, 50)];
    [customRewardView setUserInteractionEnabled:YES];
    [customRewardView.layer setBorderWidth:1.0];
    [customRewardView.layer setBorderColor:gTextRewardColor.CGColor];
    [customRewardView.layer setMasksToBounds:YES];
    [customRewardView.layer setCornerRadius:10.0];
    [rewardBorderView addSubview:customRewardView];
    customRewardView.hidden = self.isCustomRewardCount ? NO : YES;
    UIImageView *tcoin = [[UIImageView alloc]initWithFrame:CGRectMake(15, 13, 22.5, 25.5)];
    [tcoin setImage:[UIImage imageNamed:@"tcoin"]];
    [customRewardView addSubview:tcoin];
    _customRewardTextField = [[UITextField alloc]initWithFrame:CGRectMake(CGRectGetMaxX(tcoin.frame) + 13, 13, customRewardView.frame.size.width - 30 - 13 - 22.5, 25.5)];
    [_customRewardTextField setPlaceholder:@"可输入1-500整数"];
    [_customRewardTextField setFont:gFontSub11];
    [_customRewardTextField setClearButtonMode:UITextFieldViewModeAlways];
    [_customRewardTextField setKeyboardType:UIKeyboardTypeNumberPad];
    [_customRewardTextField setDelegate:self];
    [customRewardView addSubview:_customRewardTextField];
    
    //TODO:自定义打赏
    _finalRewardButton = [OJLAnimationButton buttonWithFrame:CGRectMake(15, CGRectGetMaxY(selectedView.frame), rewardBorderView.frame.size.width - 30, 40)];
    _finalRewardButton.delegate = self;
    [_finalRewardButton.layer setMasksToBounds:YES];
    [_finalRewardButton.layer setCornerRadius:5.0];
    [_finalRewardButton setBackgroundColor:gButtonRewardColor];
    [_finalRewardButton.titleLabel setFont:gFontMajor17];
    [_finalRewardButton setTitle:@"赞赏" forState:UIControlStateNormal];
    [_finalRewardButton addTarget:self action:@selector(finalRewardButtonAciton:) forControlEvents:UIControlEventTouchUpInside];
    [rewardBorderView addSubview:_finalRewardButton];
    
    UIButton *backButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [backButton setFrame:CGRectMake(CGRectGetMaxX(_finalRewardButton.frame) - 38, CGRectGetMaxY(_finalRewardButton.frame) + 5, 30, 15)];
    [backButton.titleLabel setFont:gFontSub11];
    [backButton setTitleColor:gTextColorSub forState:UIControlStateNormal];
    [backButton setTitle:@"返回" forState:UIControlStateNormal];
    [backButton addTarget:self action:@selector(backButtonAction:) forControlEvents:UIControlEventTouchUpInside];
    [rewardBorderView addSubview:backButton];
    
    [rewardBorderView setFrame:CGRectMake(rewardBorderView.frame.origin.x, rewardBorderView.frame.origin.y, rewardBorderView.frame.size.width, CGRectGetMaxY(_finalRewardButton.frame) + 35)];
    [self.contentView setFrame:CGRectMake(self.contentView.frame.origin.x, self.contentView.frame.origin.y, self.contentView.frame.size.width, CGRectGetMaxY(rewardBorderView.frame) + 15)];
}

- (void)selecteRewardCountAction:(UIButton *)sender {
    
    for ( int i = 0 ; i < self.buttons.count; i ++ ) {
        if (i == sender.tag - 100 ) {
            UIButton *allDoneButton = self.buttons[i];
            [allDoneButton setBackgroundColor:gButtonRewardColor];
            [allDoneButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
            continue;
        }
        else{
            UIButton *anotherButton = self.buttons[i];
            [anotherButton setBackgroundColor:[UIColor whiteColor]];
            [anotherButton setTitleColor:gTextRewardColor forState:UIControlStateNormal];
            continue;
        }
    }
    DefineWeakSelf;
    switch (sender.tag - 100) {
        case 0:self.rewardCount = 1;break;
        case 1:self.rewardCount = 5;break;
        case 2:self.rewardCount = 10;break;
        case 3:self.rewardCount = 50;break;
        case 4:self.rewardCount = 100;break;
        case 5:[weakSelf customRewardCount];break;
        default:break;
    }
}

- (void)updateViewWithIsCustomRewardCount:(BOOL)isCustomRewardCount{
    
    self.isCustomRewardCount = isCustomRewardCount;
    for (UIView *view in self.contentView.subviews) {
        [view removeFromSuperview];
    }
    //设置居中位置
    AppDelegate *appDelegate = (AppDelegate *)[UIApplication sharedApplication].delegate;
    [self.contentView setCenter:appDelegate.window.center];
    
    UIView *rewardBorderView = [[UIView alloc]initWithFrame:CGRectMake(15, 55, self.contentView.frame.size.width - 30, 100)];
    [rewardBorderView setUserInteractionEnabled:YES];
    [rewardBorderView.layer setBorderWidth:1.0];
    [rewardBorderView.layer setBorderColor:gTextRewardColor.CGColor];
    [rewardBorderView.layer setMasksToBounds:YES];
    [rewardBorderView.layer setCornerRadius:5.0];
    [self.contentView addSubview:rewardBorderView];
    UIImageView *smile = [[UIImageView alloc]initWithFrame:CGRectMake(30, 15, 60, 66.5)];
    [smile setImage:[UIImage imageNamed:@"COIN21"]];
    [self.contentView addSubview:smile];
    
    
    UILabel *tipLabel = [[UILabel alloc]initWithFrame:CGRectMake( 80, 5, 220, 32)];
    [tipLabel setText:self.isCustomRewardCount ? @"请输入自定义金额" : @"您的支持是我们最大的动力~"];
    [tipLabel setTextColor:gTextDownload];
    [tipLabel setFont:gFontMain14];
    [rewardBorderView addSubview:tipLabel];
    
    UIView *selectedView = [[UIView alloc]initWithFrame:CGRectMake(0, 41, rewardBorderView.frame.size.width, 80)];
    [rewardBorderView addSubview:selectedView];
    selectedView.hidden = self.isCustomRewardCount ? YES : NO;
    
    NSMutableArray *items = [NSMutableArray array];
    NSDictionary *dic0 = @{@"title":@"1听币"};
    [items addObject:dic0];
    NSDictionary *dic1 = @{@"title":@"5听币"};
    [items addObject:dic1];
    NSDictionary *dic2 = @{@"title":@"10听币"};
    [items addObject:dic2];
    NSDictionary *dic3 = @{@"title":@"50听币"};
    [items addObject:dic3];
    NSDictionary *dic4 = @{@"title":@"100听币"};
    [items addObject:dic4];
    NSDictionary *dic5 = @{@"title":@"自定义"};
    [items addObject:dic5];
    
    if ([self.buttons count]) {
        [self.buttons removeAllObjects];
    }
    for (int i = 0 ; i < 2 * 3; i ++) {
        CGFloat w = (rewardBorderView.frame.size.width - 240) / 4;
        CGFloat h = (rewardBorderView.frame.size.height - 90)/3;
        UIButton *itemImgBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        [itemImgBtn setFrame:CGRectMake(i % 3 * (w + 80) + w , i / 3 *(30 + h)+ h, 80, 30)];
        [itemImgBtn setTitle:items[i][@"title"] forState:UIControlStateNormal];
        [itemImgBtn setTitleColor:gTextRewardColor forState:UIControlStateNormal];
        [itemImgBtn.layer setBorderWidth:0.5];
        [itemImgBtn.layer setBorderColor:gTextRewardColor.CGColor];
        [itemImgBtn.layer setMasksToBounds:YES];
        [itemImgBtn.layer setCornerRadius:15.0];
        [itemImgBtn.titleLabel setFont:gFontSub11];
        [itemImgBtn setTag:(100 + i)];
        [itemImgBtn addTarget:self action:@selector(selecteRewardCountAction:) forControlEvents:UIControlEventTouchUpInside];
        [self.buttons addObject:itemImgBtn];
        [selectedView addSubview:itemImgBtn];
        if (i == 1) {
            [self selecteRewardCountAction:itemImgBtn];
        }
    }
    
    UIView *customRewardView = [[UIView alloc]initWithFrame:CGRectMake(15, 55, rewardBorderView.frame.size.width - 30, 50)];
    [customRewardView setUserInteractionEnabled:YES];
    [customRewardView.layer setBorderWidth:1.0];
    [customRewardView.layer setBorderColor:gTextRewardColor.CGColor];
    [customRewardView.layer setMasksToBounds:YES];
    [customRewardView.layer setCornerRadius:10.0];
    [rewardBorderView addSubview:customRewardView];
    customRewardView.hidden = self.isCustomRewardCount ? NO : YES;
    UIImageView *tcoin = [[UIImageView alloc]initWithFrame:CGRectMake(15, 13, 22.5, 25.5)];
    [tcoin setImage:[UIImage imageNamed:@"tcoin"]];
    [customRewardView addSubview:tcoin];
    _customRewardTextField = [[UITextField alloc]initWithFrame:CGRectMake(CGRectGetMaxX(tcoin.frame) + 13, 13, customRewardView.frame.size.width - 30 - 13 - 22.5, 25.5)];
    [_customRewardTextField setPlaceholder:@"可输入1-500整数"];
    [_customRewardTextField setFont:gFontSub11];
    [_customRewardTextField setClearButtonMode:UITextFieldViewModeAlways];
    [_customRewardTextField setKeyboardType:UIKeyboardTypeNumberPad];
    [_customRewardTextField setDelegate:self];
    [customRewardView addSubview:_customRewardTextField];
    
    //TODO:自定义打赏
    _finalRewardButton = [OJLAnimationButton buttonWithFrame:CGRectMake(15, CGRectGetMaxY(selectedView.frame), rewardBorderView.frame.size.width - 30, 40)];
    _finalRewardButton.delegate = self;
    [_finalRewardButton.layer setMasksToBounds:YES];
    [_finalRewardButton.layer setCornerRadius:5.0];
    [_finalRewardButton setBackgroundColor:gButtonRewardColor];
    [_finalRewardButton.titleLabel setFont:gFontMajor17];
    [_finalRewardButton setTitle:@"赞赏" forState:UIControlStateNormal];
    [_finalRewardButton addTarget:self action:@selector(finalRewardButtonAciton:) forControlEvents:UIControlEventTouchUpInside];
    [rewardBorderView addSubview:_finalRewardButton];
    
    UIButton *backButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [backButton setFrame:CGRectMake(CGRectGetMaxX(_finalRewardButton.frame) - 38, CGRectGetMaxY(_finalRewardButton.frame) + 5, 30, 15)];
    [backButton.titleLabel setFont:gFontSub11];
    [backButton setTitleColor:gTextColorSub forState:UIControlStateNormal];
    [backButton setTitle:@"返回" forState:UIControlStateNormal];
    [backButton addTarget:self action:@selector(backButtonAction:) forControlEvents:UIControlEventTouchUpInside];
    [rewardBorderView addSubview:backButton];
    
    [rewardBorderView setFrame:CGRectMake(rewardBorderView.frame.origin.x, rewardBorderView.frame.origin.y, rewardBorderView.frame.size.width, CGRectGetMaxY(_finalRewardButton.frame) + 35)];
    [self.contentView setFrame:CGRectMake(self.contentView.frame.origin.x, self.contentView.frame.origin.y, self.contentView.frame.size.width, CGRectGetMaxY(rewardBorderView.frame) + 15)];
    [self.grayView addSubview:self.contentView];
}

- (void)customRewardCount {
    [self updateViewWithIsCustomRewardCount:YES];
}

- (void)backButtonAction:(UIButton *)sender {
    if (self.isCustomRewardCount) {
        [self updateViewWithIsCustomRewardCount:NO];
    }
    else{
         [self removeFromSuperview];
    }
}

- (void)rewarding{
    
    if (self.rewardBlock) {
        self.rewardBlock(self.rewardCount);
    }
    [self removeFromSuperview];
}

- (void)finalRewardButtonAciton:(OJLAnimationButton *)sender {
    [self endEditing:YES];
    [sender startAnimation];
}



#pragma mark OJLAnimationButtonDelegate

-(void)OJLAnimationButtonDidStartAnimation:(OJLAnimationButton *)OJLAnimationButton{
    NSLog(@"start");
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.8 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [OJLAnimationButton stopAnimation];
    });
}

-(void)OJLAnimationButtonDidFinishAnimation:(OJLAnimationButton *)OJLAnimationButton{
    NSLog(@"stop");
}

-(void)OJLAnimationButtonWillFinishAnimation:(OJLAnimationButton *)OJLAnimationButton{
    [self rewarding];
}


#pragma mark - UITextFieldDelegate

- (BOOL)textFieldShouldEndEditing:(UITextField *)textField{
    self.rewardCount = [textField.text floatValue];
    return YES;
}

- (void)textFieldDidEndEditing:(UITextField *)textField{
    self.rewardCount = [textField.text floatValue];
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
        _contentView = [[UIScrollView alloc]initWithFrame:CGRectMake(10,SCREEN_HEIGHT - 264 , SCREEN_WIDTH - 20, 200)];
        [_contentView setBackgroundColor:[UIColor whiteColor]];
        [_contentView.layer setMasksToBounds:YES];
        [_contentView.layer setCornerRadius:10.0];
        [_contentView.layer setBorderWidth:2.0f];
        [_contentView.layer setBorderColor:[UIColor whiteColor].CGColor];
        _contentView.showsVerticalScrollIndicator = YES;
    }
    return _contentView;
}

- (NSMutableArray *)buttons{
    if (!_buttons)
    {
        _buttons = [NSMutableArray array];
    }
    return _buttons;
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
