//
//  SelectedNewsTypeView.m
//  kuangjiaTingWen
//
//  Created by 泡果 on 16/7/21.
//  Copyright © 2016年 贺楠. All rights reserved.
//

#import "SelectedNewsTypeView.h"
#import "AppDelegate.h"

@interface SelectedNewsTypeView ()

@property (strong, nonatomic) UIView *grayView;
@property (strong, nonatomic) UIScrollView *contentView;
@property (nonatomic, strong) NSMutableArray *buttons;
@property (nonatomic, strong) NSMutableArray *itemTitleArr;

@end

@implementation SelectedNewsTypeView


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

- (void)setSelectItemWithTitleArr:(NSMutableArray *)itemArr {
    
    _itemTitleArr = itemArr;
    [self.contentView setContentSize:CGSizeMake(200, itemArr.count * 40 + 3)];
    //设置居中位置
    AppDelegate *appDelegate = (AppDelegate *)[UIApplication sharedApplication].delegate;
    [_contentView setCenter:appDelegate.window.center];
    
    for (int i = 0 ; i < [itemArr count]; i ++) {
        UIButton *item = [UIButton buttonWithType:UIButtonTypeCustom];
        [item setFrame:CGRectMake(0, 40 * i, self.contentView.frame.size.width, 40)];
        [item setTitle:itemArr[i] forState:UIControlStateNormal];
        item.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;
        item.titleEdgeInsets = UIEdgeInsetsMake(0, 70, 0, 0);
        [item setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        [item setTitleColor:[UIColor blackColor] forState:UIControlStateSelected];
        [item setSelected:NO];
        [item setTag:(10 + i)];
        [item addTarget:self action:@selector(selecteItemTitleAction:) forControlEvents:UIControlEventTouchUpInside];
        UIView *line = [[UIView alloc]initWithFrame:CGRectMake(0, 39, self.contentView.frame.size.width, 1)];
        [line setBackgroundColor:gSubColor];
        [item addSubview:line];
        [self.contentView addSubview:item];
        UIButton *selecteButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [selecteButton setFrame:CGRectMake(self.contentView.frame.size.width - 40, item.frame.origin.y + 10, 20, 20)];
        selecteButton.selected = NO;
        [selecteButton setBackgroundImage:[UIImage imageNamed:@"unselect"] forState:UIControlStateNormal];
        [selecteButton setBackgroundImage:[UIImage imageNamed:@"selected"] forState:UIControlStateSelected];
        [selecteButton setTag:(20 + i)];
        [selecteButton addTarget:self action:@selector(selecteItemAction:) forControlEvents:UIControlEventTouchUpInside];
        [self.contentView addSubview:selecteButton];
        [self.buttons addObject:selecteButton];
    }
}

- (void)selecteItemAction:(UIButton *)sender {
    if (sender.selected) {
        sender.selected = NO;
    }
    else{
        sender.selected = YES;
    }
}

- (void)selecteItemTitleAction:(UIButton *)sender{
    if (sender.selected) {
        sender.selected = NO;
        UIButton *btn = (UIButton *)[self viewWithTag:(sender.tag + 10)];
        btn.selected = NO;
    }
    else{
        sender.selected = YES;
        UIButton *btn = (UIButton *)[self viewWithTag:(sender.tag + 10)];
        btn.selected = YES;
    }
}

- (void)cancelAction:(UIButton *)sender{
     [self removeFromSuperview];
}

- (void)sureAction:(UIButton *)sender{
    
    NSString *selectedStr = @"";
    for (UIButton *btn in self.buttons) {
        if (btn.selected) {
            selectedStr = [NSString stringWithFormat:@"%@%@,",selectedStr,_itemTitleArr[btn.tag - 20]];
        }
    }
    if (self.selectedTypeBlock) {
        self.selectedTypeBlock(selectedStr);
    }
    [self removeFromSuperview];
}

- (UIView *)grayView{
    if (_grayView == nil) {
        AppDelegate *appDelegate = (AppDelegate *)[UIApplication sharedApplication].delegate;
        _grayView = [[UIView alloc]initWithFrame:appDelegate.window.frame];
        [_grayView setBackgroundColor:[[UIColor grayColor] colorWithAlphaComponent:0.6]];
        [_grayView addSubview:self.contentView];
        UIButton *cancel = [UIButton buttonWithType:UIButtonTypeCustom];
        [cancel setFrame:CGRectMake(self.contentView.origin.x, CGRectGetMaxY(self.contentView.frame) - 3, self.contentView.frame.size.width / 2, 40)];
        [cancel setTitle:@"取消" forState:UIControlStateNormal];
        [cancel setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        [cancel setBackgroundColor:[UIColor whiteColor]];
        [cancel addTarget:self action:@selector(cancelAction:) forControlEvents:UIControlEventTouchUpInside];
        [_grayView addSubview:cancel];
        UIButton *sure = [UIButton buttonWithType:UIButtonTypeCustom];
        [sure setFrame:CGRectMake(CGRectGetMaxX(cancel.frame), CGRectGetMaxY(self.contentView.frame) - 3, self.contentView.frame.size.width / 2, 40)];
        [sure setTitle:@"确定" forState:UIControlStateNormal];
        [sure setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        [sure setBackgroundColor:[UIColor whiteColor]];
        [sure addTarget:self action:@selector(sureAction:) forControlEvents:UIControlEventTouchUpInside];
        [_grayView addSubview:sure];
        UIView *line = [[UIView alloc]initWithFrame:CGRectMake(self.contentView.origin.x, CGRectGetMaxY(self.contentView.frame) - 3, self.contentView.frame.size.width, 1)];
        [line setBackgroundColor:gSubColor];
        [_grayView addSubview:line];
    }
    return _grayView;
}
-(UIScrollView *)contentView{
    
    if (_contentView == nil) {
        _contentView = [[UIScrollView alloc]initWithFrame:CGRectMake(0, 0 , 200, 300)];
        [_contentView setScrollEnabled:YES];
        //设置居中位置
        AppDelegate *appDelegate = (AppDelegate *)[UIApplication sharedApplication].delegate;
        [_contentView setCenter:appDelegate.window.center];
        [_contentView setBackgroundColor:[UIColor whiteColor]];
//        [_contentView.layer setMasksToBounds:YES];
//        [_contentView.layer setCornerRadius:5];
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

@end
