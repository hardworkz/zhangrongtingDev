//
//  MyVipSectionTableViewCell.m
//  kuangjiaTingWen
//
//  Created by 泡果 on 2017/7/19.
//  Copyright © 2017年 zhimi. All rights reserved.
//

#import "MyVipSectionTableViewCell.h"

@interface MyVipSectionTableViewCell()
{
    UILabel *titleLabel;
}
@end

@implementation MyVipSectionTableViewCell
+ (NSString *)ID
{
    return @"MyVipSectionTableViewCell";
}
+(MyVipSectionTableViewCell *)cellWithTableView:(UITableView *)tableView
{
    MyVipSectionTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:[MyVipSectionTableViewCell ID]];
    if (cell == nil) {
        cell = [[MyVipSectionTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:[MyVipSectionTableViewCell ID]];
    }
    return cell;
}
- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        self.backgroundColor = ColorWithRGBA(249, 247, 247, 1);
        
        titleLabel = [[UILabel alloc] init];
        titleLabel.backgroundColor = ColorWithRGBA(249, 247, 247, 1);
        titleLabel.frame = CGRectMake(10, 0, SCREEN_WIDTH, 30);
        titleLabel.font = [UIFont systemFontOfSize:15];
        titleLabel.textColor = [UIColor lightGrayColor];
        [self.contentView addSubview:titleLabel];
        
    }
    return self;
}
- (void)setContent:(NSString *)content
{
    _content = content;
    titleLabel.text = content;
}
@end
