//
//  PlayCustomRewardTableViewCell.m
//  kuangjiaTingWen
//
//  Created by 泡果 on 2017/7/26.
//  Copyright © 2017年 zhimi. All rights reserved.
//

#import "PlayCustomRewardTableViewCell.h"
#import "OJLAnimationButton.h"

@interface PlayCustomRewardTableViewCell ()<UITextFieldDelegate>
{
    //打赏主容器控件
    UIView *rewardView;
    //打赏状态容器控件
    UIView *rewardBorderView;
    //提示文本1
    UILabel *tipLabel;
    //选择打赏金额按钮view
    UIView *selectedView;
    //自定义文本输入框view
    UIView *customRewardView;
    //返回退出打赏
    UIButton *backButton;
}
@property (strong, nonatomic) UITextField *customRewardTextField;

@end
@implementation PlayCustomRewardTableViewCell
+ (NSString *)ID
{
    return @"PlayCustomRewardTableViewCell";
}
+(PlayCustomRewardTableViewCell *)cellWithTableView:(UITableView *)tableView
{
    PlayCustomRewardTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:[PlayCustomRewardTableViewCell ID]];
    if (cell == nil) {
        cell = [[PlayCustomRewardTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:[PlayCustomRewardTableViewCell ID]];
    }
    return cell;
}
- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        
        UIView *payTopLine = [[UIView alloc]initWithFrame:CGRectMake(0, 0 , IPHONE_W, 5)];
        payTopLine.backgroundColor = [UIColor colorWithRed:0.95 green:0.96 blue:0.98 alpha:1.00];
        payTopLine.alpha = 0.5f;
        [self.contentView addSubview:payTopLine];
        
        //TODO:打赏入口
        rewardView = [[UIView alloc] initWithFrame:CGRectMake(-5, CGRectGetMaxY(payTopLine.frame) ,  SCREEN_WIDTH + 10, 170)];
        
        [rewardView setUserInteractionEnabled:YES];
        [rewardView setBackgroundColor:[UIColor whiteColor]];
        [rewardView.layer setBorderWidth:0.5];
        [rewardView.layer setBorderColor:[UIColor lightGrayColor].CGColor];
        
        UIImageView *smile = [[UIImageView alloc]initWithFrame:CGRectMake(30, 15, 60, 66.5)];
        [smile setImage:[UIImage imageNamed:@"COIN21"]];
        [rewardView addSubview:smile];
        
        rewardBorderView = [[UIView alloc]initWithFrame:CGRectMake(15, 55, SCREEN_WIDTH - 30, 100)];
        [rewardBorderView setUserInteractionEnabled:YES];
        [rewardBorderView.layer setBorderWidth:1.0];
        [rewardBorderView.layer setBorderColor:gTextRewardColor.CGColor];
        [rewardBorderView.layer setMasksToBounds:YES];
        [rewardBorderView.layer setCornerRadius:5.0];
        [rewardView addSubview:rewardBorderView];
        
        tipLabel = [[UILabel alloc]initWithFrame:CGRectMake(80, 5, 220, 32)];
        [tipLabel setText:self.rewardType == RewardViewTypeCustomReward ? @"请输入自定义金额" : @"您的支持是我们最大的动力~"];
        [tipLabel setTextColor:gTextDownload];
        [tipLabel setFont:gFontMain14];
        [rewardBorderView addSubview:tipLabel];
        
        selectedView = [[UIView alloc]initWithFrame:CGRectMake(0, 41, rewardBorderView.frame.size.width, 80)];
        [rewardBorderView addSubview:selectedView];
        selectedView.hidden = self.rewardType == RewardViewTypeCustomReward ? YES : NO;
        NSMutableArray *itemArr = [NSMutableArray array];
        NSDictionary *dic0 = @{@"title":@"1听币"};
        [itemArr addObject:dic0];
        NSDictionary *dic1 = @{@"title":@"5听币"};
        [itemArr addObject:dic1];
        NSDictionary *dic2 = @{@"title":@"10听币"};
        [itemArr addObject:dic2];
        NSDictionary *dic3 = @{@"title":@"50听币"};
        [itemArr addObject:dic3];
        NSDictionary *dic4 = @{@"title":@"100听币"};
        [itemArr addObject:dic4];
        NSDictionary *dic5 = @{@"title":@"自定义"};
        [itemArr addObject:dic5];
        if ([self.buttons count]) {
            [self.buttons removeAllObjects];
        }
        for (int i = 0 ; i < 2 * 3; i ++) {
            CGFloat w = (rewardBorderView.frame.size.width - 240) / 4;
            CGFloat h = (rewardBorderView.frame.size.height - 90)/3;
            
            UIButton *itemImgBtn = [UIButton buttonWithType:UIButtonTypeCustom];
            [itemImgBtn setFrame:CGRectMake(i % 3 * (w + 80) + w , i / 3 *(30 + h)+ h, 80, 30)];
            [itemImgBtn setTitle:itemArr[i][@"title"] forState:UIControlStateNormal];
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
            if (i == (2 * 3 - 1)) {
                if (self.selecteRewardCountAction) {
                    self.selecteRewardCountAction(self.buttons[1],self.buttons);
                }
            }
        }
        
        customRewardView = [[UIView alloc] initWithFrame:CGRectMake(15, 55, rewardBorderView.frame.size.width - 30, 50)];
        [customRewardView setUserInteractionEnabled:YES];
        [customRewardView.layer setBorderWidth:1.0];
        [customRewardView.layer setBorderColor:gTextRewardColor.CGColor];
        [customRewardView.layer setMasksToBounds:YES];
        [customRewardView.layer setCornerRadius:10.0];
        [rewardBorderView addSubview:customRewardView];
        customRewardView.hidden = self.rewardType == RewardViewTypeCustomReward ? NO : YES;
        UIImageView *tcoin = [[UIImageView alloc]initWithFrame:CGRectMake(15, 13, 22.5, 25.5)];
        [tcoin setImage:[UIImage imageNamed:@"tcoin"]];
        [customRewardView addSubview:tcoin];
        
        _customRewardTextField = [[UITextField alloc]initWithFrame:CGRectMake(CGRectGetMaxX(tcoin.frame) + 13, 13, customRewardView.frame.size.width - 30 - 13 - 22.5, 25.5)];
        [_customRewardTextField setPlaceholder:@"可输入1-500整数"];
        [_customRewardTextField setFont:gFontSub11];
        [_customRewardTextField setClearButtonMode:UITextFieldViewModeAlways];
        [_customRewardTextField setKeyboardType:UIKeyboardTypeDecimalPad];
        [_customRewardTextField setDelegate:self];
        [customRewardView addSubview:_customRewardTextField];
        
        //TODO:自定义打赏
        _finalRewardButton = [OJLAnimationButton buttonWithFrame:CGRectMake(15, CGRectGetMaxY(selectedView.frame), rewardBorderView.frame.size.width - 30, 40)];
        _finalRewardButton.delegate = [NewPlayVC shareInstance];
        [_finalRewardButton.layer setMasksToBounds:YES];
        [_finalRewardButton.layer setCornerRadius:5.0];
        [_finalRewardButton setBackgroundColor:gButtonRewardColor];
        [_finalRewardButton.titleLabel setFont:gFontMajor17];
        [_finalRewardButton setTitle:@"赞赏" forState:UIControlStateNormal];
        [_finalRewardButton addTarget:self action:@selector(finalRewardButtonAciton:) forControlEvents:UIControlEventTouchUpInside];
        [rewardBorderView addSubview:_finalRewardButton];
        
        backButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [backButton setFrame:CGRectMake(CGRectGetMaxX(_finalRewardButton.frame) - 38, CGRectGetMaxY(_finalRewardButton.frame) + 5, 30, 15)];
        [backButton.titleLabel setFont:gFontSub11];
        [backButton setTitleColor:gTextColorSub forState:UIControlStateNormal];
        [backButton setTitle:@"返回" forState:UIControlStateNormal];
        [backButton addTarget:self action:@selector(backButtonAction:) forControlEvents:UIControlEventTouchUpInside];
        [rewardBorderView addSubview:backButton];
        
        [rewardBorderView setFrame:CGRectMake(rewardBorderView.frame.origin.x, rewardBorderView.frame.origin.y, rewardBorderView.frame.size.width, CGRectGetMaxY(_finalRewardButton.frame) + 35)];
        //设置view的高度
        [rewardView setFrame:CGRectMake(rewardView.frame.origin.x, rewardView.frame.origin.y, rewardView.frame.size.width, CGRectGetMaxY(rewardBorderView.frame) + 15)];
        
        [self.contentView addSubview:rewardView];
    }
    return self;
}
/**
 设置类型
 */
- (void)setRewardType:(RewardViewType)rewardType
{
    _rewardType = rewardType;
    if (rewardType == RewardViewTypeReward) {//打赏状态，显示选择打赏的值按钮
        selectedView.hidden = NO;
        customRewardView.hidden = YES;
    }else if(rewardType == RewardViewTypeCustomReward){//打赏状态，自定义输入打赏金额
        selectedView.hidden = YES;
        customRewardView.hidden = NO;
    }
}
- (void)selecteRewardCountAction:(UIButton *)item
{
    if (self.selecteRewardCountAction) {
        self.selecteRewardCountAction(item,self.buttons);
    }
}
- (void)finalRewardButtonAciton:(OJLAnimationButton *)sender {
    if (self.finalRewardButtonAciton) {
        self.finalRewardButtonAciton(sender);
    }
}
- (void)backButtonAction:(UIButton *)sender {
    if (self.backButtonAction) {
        self.backButtonAction(sender);
    }
}
- (NSMutableArray *)buttons{
    if (!_buttons)
    {
        _buttons = [NSMutableArray array];
    }
    return _buttons;
}

@end
