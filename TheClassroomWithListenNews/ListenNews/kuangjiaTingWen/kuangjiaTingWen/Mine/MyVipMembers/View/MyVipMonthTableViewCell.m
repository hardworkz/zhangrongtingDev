//
//  MyVipMonthTableViewCell.m
//  kuangjiaTingWen
//
//  Created by 泡果 on 2017/7/19.
//  Copyright © 2017年 zhimi. All rights reserved.
//

#import "MyVipMonthTableViewCell.h"

@interface MyVipMonthTableViewCell()
{
    UILabel *monthLabel;
    UILabel *priceLabel;
    UIButton *payBtn;
}
@end
@implementation MyVipMonthTableViewCell
+ (NSString *)ID
{
    return @"MyVipMonthTableViewCell";
}
+(MyVipMonthTableViewCell *)cellWithTableView:(UITableView *)tableView
{
    MyVipMonthTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:[MyVipMonthTableViewCell ID]];
    if (cell == nil) {
        cell = [[MyVipMonthTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:[MyVipMonthTableViewCell ID]];
    }
    return cell;
}
- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        
        monthLabel = [[UILabel alloc] init];
        monthLabel.frame = CGRectMake(20, 0, 100, 44);
        monthLabel.font = [UIFont systemFontOfSize:17];
        monthLabel.textColor = [UIColor grayColor];
        [self.contentView addSubview:monthLabel];
        
        payBtn = [[UIButton alloc] init];
        payBtn.frame = CGRectMake(SCREEN_WIDTH - 50 - 20, 10, 50, 44 - 20);
        payBtn.titleLabel.font = [UIFont systemFontOfSize:15];
        [payBtn setTitleColor:[UIColor redColor]];
        payBtn.layer.cornerRadius = (44 - 20)*0.5;
        payBtn.layer.borderWidth = 0.5;
        payBtn.layer.borderColor = [UIColor redColor].CGColor;
        [payBtn addTarget:self action:@selector(payClicked)];
        [self.contentView addSubview:payBtn];
        
        priceLabel = [[UILabel alloc] init];
        priceLabel.frame = CGRectMake(payBtn.x - 150 - 10, 0, 150, 44);
        priceLabel.textAlignment = NSTextAlignmentRight;
        priceLabel.font = [UIFont systemFontOfSize:17];
        priceLabel.textColor = [UIColor blackColor];
        [self.contentView addSubview:priceLabel];
        
        UIView *devider = [[UIView alloc] init];
        devider.backgroundColor = ColorWithRGBA(249, 247, 247, 1);
        devider.frame = CGRectMake(0, 43, SCREEN_WIDTH, 1);
        [self.contentView addSubview:devider];
    }
    return self;
}
- (void)setModel:(MembersDataModel *)model
{
    _model = model;
    monthLabel.text = [NSString stringWithFormat:@"%@个月",model.monthes];
    priceLabel.text = [NSString stringWithFormat:@"¥%@",model.price];
    if ([_is_member isEqualToString:@"1"]) {
        [payBtn setTitle:@"续费"];
    }else{
        [payBtn setTitle:@"购买"];
    }
}
- (void)payClicked
{
    if (self.payBlock) {
        self.payBlock(self);
    }
}
@end
