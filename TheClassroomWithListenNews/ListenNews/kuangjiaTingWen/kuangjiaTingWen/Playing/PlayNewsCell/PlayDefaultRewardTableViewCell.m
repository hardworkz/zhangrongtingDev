//
//  PlayDefaultRewardTableViewCell.m
//  kuangjiaTingWen
//
//  Created by 泡果 on 2017/8/1.
//  Copyright © 2017年 zhimi. All rights reserved.
//

#import "PlayDefaultRewardTableViewCell.h"
#import "MenuItemV.h"

@interface PlayDefaultRewardTableViewCell ()
{
    //打赏主容器控件
    UIView *rewardView;
    //初始状态容器控件
    UIView *rewardBorderViewNormal;
    //提示文本1
    UILabel *tipLabel;
    //选择打赏金额按钮view
    UIView *selectedView;
    //自定义文本输入框view
    UIView *customRewardView;
    //返回退出打赏
    UIButton *backButton;
    
    //提示文本2
    UILabel *tipsLabel;
    //赞赏按钮
    UIButton *rewardButton;
    //分割线
    UIView *midleLine;
    //打赏人头像容器
    MenuItemV *paidView;
    //超过5人显示提示
    UILabel *paidLabel;
    //跳转打赏列表按钮
    UIButton *rewardListButton;
    //无人打赏时的提示
    UILabel *noPayLabel;
}
@end
@implementation PlayDefaultRewardTableViewCell
+ (NSString *)ID
{
    return @"PlayDefaultRewardTableViewCell";
}
+(PlayDefaultRewardTableViewCell *)cellWithTableView:(UITableView *)tableView
{
    PlayDefaultRewardTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:[PlayDefaultRewardTableViewCell ID]];
    if (cell == nil) {
        cell = [[PlayDefaultRewardTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:[PlayDefaultRewardTableViewCell ID]];
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
        
        //初始状态控件容器
        rewardBorderViewNormal = [[UIView alloc]initWithFrame:CGRectMake(15, 55, SCREEN_WIDTH - 30, 100)];
        [rewardBorderViewNormal setUserInteractionEnabled:YES];
        [rewardBorderViewNormal.layer setBorderWidth:1.0];
        [rewardBorderViewNormal.layer setBorderColor:gTextRewardColor.CGColor];
        [rewardBorderViewNormal.layer setMasksToBounds:YES];
        [rewardBorderViewNormal.layer setCornerRadius:5.0];
        [rewardView addSubview:rewardBorderViewNormal];
        
        tipsLabel = [[UILabel alloc]initWithFrame:CGRectMake( 80, 5, 170, 32)];
        [tipsLabel setText:@"千山万水总是情，\n支持一下行不行~"];
        [tipsLabel setNumberOfLines:0];
        [tipsLabel setTextColor:gTextDownload];
        [tipsLabel setFont:gFontSub11];
        [rewardBorderViewNormal addSubview:tipsLabel];
        
        rewardButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [rewardButton setFrame:CGRectMake(CGRectGetMaxX(rewardBorderViewNormal.frame) - 90, 10, 60, 30)];
        [rewardButton.layer setMasksToBounds:YES];
        [rewardButton.layer setCornerRadius:5.0];
        [rewardButton setBackgroundColor:gButtonRewardColor];
        [rewardButton.titleLabel setFont:gFontMain12];
        [rewardButton setTitle:@"赞赏" forState:UIControlStateNormal];
        [rewardButton addTarget:self action:@selector(rewardButtonAciton:) forControlEvents:UIControlEventTouchUpInside];
        [rewardBorderViewNormal addSubview:rewardButton];
        
        //分割线
        midleLine = [[UIView alloc]initWithFrame:CGRectMake(0, rewardBorderViewNormal.frame.size.height / 2, rewardBorderViewNormal.frame.size.width, 0.5)];
        midleLine.backgroundColor = [UIColor lightGrayColor];
        midleLine.alpha = 0.5f;
        [rewardBorderViewNormal addSubview:midleLine];
        
        paidLabel = [[UILabel alloc]initWithFrame:CGRectMake(CGRectGetMaxX(paidView.frame) - 20,CGRectGetMaxY(midleLine.frame) + 10, 60, 32)];
        [paidLabel setTextAlignment:NSTextAlignmentCenter];
        [paidLabel setTextColor:UIColorFromHex(666666)];
        [paidLabel setFont:gFontSub11];
        [rewardBorderViewNormal addSubview:paidLabel];
        
        rewardListButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [rewardListButton setFrame:CGRectMake(CGRectGetMaxX(rewardBorderViewNormal.frame) - 90, CGRectGetMaxY(midleLine.frame) + 10, 60, 30)];
        [rewardListButton.layer setMasksToBounds:YES];
        [rewardListButton.layer setCornerRadius:5.0];
        [rewardListButton.layer setBorderColor:gTextRewardColor.CGColor];
        [rewardListButton.layer setBorderWidth:0.5];
        [rewardListButton.titleLabel setFont:gFontMain12];
        [rewardListButton setTitleColor:gButtonRewardColor forState:UIControlStateNormal];
        [rewardListButton setTitle:@"查看榜单" forState:UIControlStateNormal];
        [rewardListButton addTarget:self action:@selector(lookupRewardListButton:) forControlEvents:UIControlEventTouchUpInside];
        [rewardBorderViewNormal addSubview:rewardListButton];
        
        noPayLabel = [[UILabel alloc]initWithFrame:CGRectMake( 0,rewardBorderViewNormal.frame.size.height / 2 + 10, rewardBorderViewNormal.frame.size.width, 32)];
        [noPayLabel setText:@"还没有人赞过呢，快来当第一~"];
        [noPayLabel setTextAlignment:NSTextAlignmentCenter];
        [noPayLabel setTextColor:UIColorFromHex(666666)];
        [noPayLabel setFont:gFontSub11];
        [rewardBorderViewNormal addSubview:noPayLabel];
        
        rewardBorderViewNormal.height = CGRectGetMaxY(noPayLabel.frame) + 10;
        [rewardView setFrame:CGRectMake(rewardView.frame.origin.x, rewardView.frame.origin.y, rewardView.frame.size.width, CGRectGetMaxY(rewardBorderViewNormal.frame) + 20)];
        
        [self.contentView addSubview:rewardView];

    }
    return self;
}
- (void)setRewardArray:(NSArray *)rewardArray
{
    _rewardArray = rewardArray;
    if (rewardArray.count == 0) {
        noPayLabel.hidden = NO;
        paidView.hidden = YES;
        paidLabel.hidden = YES;
    }else{
        noPayLabel.hidden = YES;
        paidView.hidden = NO;
        paidLabel.hidden = NO;
        //设置点击人数头像和名称的View
        NSMutableArray *titleArr = [NSMutableArray new];
        NSMutableArray *imageArr = [NSMutableArray new];
        NSInteger num = (self.rewardArray.count > 5) ? 5 : self.rewardArray.count;
        for (int i = 0 ; i < num; i ++) {
            rewardModel *reward = self.rewardArray[i];
            [titleArr addObject:reward.money];
            [imageArr addObject:reward.avatar];
        }
        [paidView removeFromSuperview];
        
        paidView = [[MenuItemV alloc] initWithFrame:CGRectMake(15, CGRectGetMaxY(midleLine.frame),32 * AdaptiveScale_W * [titleArr count] + 20,36) andTitleArr:titleArr andImgArr:imageArr andLineNum:[titleArr count]];
        [rewardBorderViewNormal insertSubview:paidView belowSubview:paidLabel];
        //设置点击人数
        [paidLabel setText:[NSString stringWithFormat:@"等%lu人赞过",(unsigned long)[self.rewardArray count]]];
        paidLabel.frame = CGRectMake(CGRectGetMaxX(paidView.frame) - 20,CGRectGetMaxY(midleLine.frame) + 10, 60, 32);
    }
}
- (void)rewardButtonAciton:(UIButton *)sender {
    if (self.rewardButtonAciton) {
        self.rewardButtonAciton(sender);
    }
}
- (void)lookupRewardListButton:(UIButton *)sender {
    
    if (self.lookupRewardListButton) {
        self.lookupRewardListButton(sender);
    }
}
@end
