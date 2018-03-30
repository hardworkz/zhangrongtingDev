//
//  PlayVCZanTableViewCell.m
//  kuangjiaTingWen
//
//  Created by 泡果 on 2018/2/11.
//  Copyright © 2018年 zhimi. All rights reserved.
//

#import "PlayVCZanTableViewCell.h"

@interface PlayVCZanTableViewCell ()
{
    UIButton *zanBtn;
//    UIView *devider;
}
@end
@implementation PlayVCZanTableViewCell
+ (NSString *)ID
{
    return @"PlayVCZanTableViewCell";
}
+(PlayVCZanTableViewCell *)cellWithTableView:(UITableView *)tableView
{
    PlayVCZanTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:[PlayVCZanTableViewCell ID]];
    if (cell == nil) {
        cell = [[PlayVCZanTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:[PlayVCZanTableViewCell ID]];
    }
    return cell;
}
- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        zanBtn = [[UIButton alloc] init];
        zanBtn.frame = CGRectMake((SCREEN_WIDTH - 130)*0.5, 10, 130, 40);
        [zanBtn setImage:@"icon_zan"];
        zanBtn.titleLabel.font = CUSTOM_FONT_TYPE(14.0);
        [zanBtn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        zanBtn.imageView.contentMode = UIViewContentModeCenter;
        zanBtn.imageEdgeInsets = UIEdgeInsetsMake(0, 0, 0, 5);
        zanBtn.titleEdgeInsets = UIEdgeInsetsMake(0, 5, 0, 0);
        zanBtn.layer.cornerRadius = 20;
        zanBtn.layer.borderWidth = 0.5;
        zanBtn.layer.borderColor = [UIColor lightGrayColor].CGColor;
        [zanBtn addTarget:self action:@selector(zanBtnClicked:)];
        [self.contentView addSubview:zanBtn];
        
//        devider = [[UIView alloc] init];
//        devider.backgroundColor = [UIColor lightGrayColor];
//        devider.frame = CGRectMake(0, 59, SCREEN_WIDTH, 1.0);
//        [self.contentView addSubview:devider];
    }
    return self;
}
- (void)setZanNum:(NSString *)zanNum
{
    _zanNum = zanNum;
    [zanBtn setTitle:zanNum];
    
    if ([_user_zan intValue] > 0) {
        [zanBtn setImage:@"icon_zan_red"];
        zanBtn.layer.borderColor = [UIColor redColor].CGColor;
        [zanBtn setTitleColor:[UIColor redColor] forState:UIControlStateNormal];
    }else{
        [zanBtn setImage:@"icon_zan"];
        zanBtn.layer.borderColor = [UIColor lightGrayColor].CGColor;
        [zanBtn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    }
}
- (void)zanBtnClicked:(UIButton *)button
{
    if (self.zanBtnClicked) {
        self.zanBtnClicked(button);
    }
}
@end
