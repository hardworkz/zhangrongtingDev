//
//  RewardListTableViewCell.m
//  kuangjiaTingWen
//
//  Created by Zhimi on 17/1/4.
//  Copyright © 2017年 贺楠. All rights reserved.
//

#import "RewardListTableViewCell.h"
#import "NSDateFormatter+Category.h"
#import "NSDate+TimeFormat.h"

@interface RewardListTableViewCell ()

@property (strong, nonatomic) UIButton *level;

@property (strong, nonatomic) UIButton *lowlevel;

@property (strong, nonatomic) UIImageView *head;

@property (strong, nonatomic) UIImageView *crown;

@property (strong, nonatomic) UILabel *name;

@property (strong, nonatomic) UILabel *describe;

@property (strong, nonatomic) UILabel *date;

@property (strong, nonatomic) UIButton *tcoinButton;

@property (strong, nonatomic) UIButton *goldCoinButton;


@end

@implementation RewardListTableViewCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier{
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]){
        [self.contentView addSubview:self.level];
        [self.contentView addSubview:self.lowlevel];
        [self.contentView addSubview:self.head];
        [self.contentView addSubview:self.crown];
        [self.contentView addSubview:self.name];
        [self.contentView addSubview:self.describe];
        [self.contentView addSubview:self.date];
        [self.contentView addSubview:self.goldCoinButton];
        [self.contentView addSubview:self.tcoinButton];
    }
    return self;
}

- (UIButton *)level {
    if (!_level) {
        _level = [UIButton buttonWithType:UIButtonTypeCustom];
        [_level setFrame:CGRectMake(12, 31.5, 25, 35)];
        [_level setTitleColor:gTextColorBackground forState:UIControlStateNormal];
    }
    return _level;
}

- (UIButton *)lowlevel {
    if (!_lowlevel) {
        _lowlevel = [UIButton buttonWithType:UIButtonTypeCustom];
        [_lowlevel setFrame:CGRectMake(12, 20, 25, 35)];
        [_lowlevel setTitleColor:gTextColorBackground forState:UIControlStateNormal];
    }
    return _lowlevel;
}

- (UIImageView *)head {
    if (!_head) {
        _head = [[UIImageView alloc]initWithFrame:CGRectMake(CGRectGetMaxX(self.level.frame), 7.5, 60, 60)];
        [_head setImage:AvatarPlaceHolderImage];
        [_head.layer setMasksToBounds:YES];
    }
    return _head;
}

- (UIImageView *)crown {
    if (!_crown) {
        _crown = [[UIImageView alloc]initWithFrame:CGRectMake(self.head.frame.origin.x + self.head.frame.size.width / 2 - 16, 6, 33, 21)];
    }
    return _crown;
}

- (UILabel *)name {
    if (!_name) {
        _name = [[UILabel alloc]initWithFrame:CGRectMake(CGRectGetMaxX(self.head.frame) + 10, self.head.frame.origin.y + 5, 200, 25)];
        [_name setTextColor:gTextDownload];
        [_name setFont:gFontMajor16];
    }
    return _name;
}

- (UILabel *)describe {
    if (!_describe) {
        _describe = [[UILabel alloc]initWithFrame:CGRectMake(self.name.frame.origin.x, CGRectGetMaxY(self.name.frame) + 5, 220, 25)];
        [_describe setTextColor:gTextColorSub];
        [_describe setFont:gFontMain12];
    }
    return _describe;
}

- (UILabel *)date {
    if (!_date) {
        _date = [[UILabel alloc]initWithFrame:CGRectMake(SCREEN_WIDTH - 16 - 70, 14, 70, 20)];
        [_date setTextColor:gTextColorSub];
        [_date setFont:gFontSub11];
        [_date setTextAlignment:NSTextAlignmentCenter];
    }
    return _date;
}

- (UIButton *)tcoinButton{
    if (!_tcoinButton) {
        _tcoinButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [_tcoinButton setFrame:CGRectMake(SCREEN_WIDTH - 16 - 60, CGRectGetMaxY(self.date.frame) + 10, 70, 20)];
        [_tcoinButton setImage:[UIImage imageNamed:@"tcoin1"] forState:UIControlStateNormal];
        [_tcoinButton setTitleColor:gButtonRewardColor forState:UIControlStateNormal];
        [_tcoinButton.titleLabel setFont:gFontMain14];
    }
    return _tcoinButton;
}

- (UIButton *)goldCoinButton{
    if (!_goldCoinButton) {
        _goldCoinButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [_goldCoinButton setFrame:CGRectMake(SCREEN_WIDTH - 16 - 70, CGRectGetMaxY(self.date.frame) + 10, 70, 20)];
        [_goldCoinButton setImage:[UIImage imageNamed:@"goldcoin"] forState:UIControlStateNormal];
        [_goldCoinButton setTitleColor:gButtonRewardColor forState:UIControlStateNormal];
        [_goldCoinButton.titleLabel setFont:gFontMain14];
    }
    return _goldCoinButton;
}

- (void)updateCellValueWithDict:(NSMutableDictionary *)mdic andIndexPathOfRow:(NSInteger )row{
    
    if (row == 0 ){
        [self.level setHidden:NO];
        [self.lowlevel setHidden:YES];
        [self.level setImage:[UIImage imageNamed:@"level1"] forState:UIControlStateNormal];
        [self.crown setImage:[UIImage imageNamed:@"crown1"]];
        [self.head setFrame:CGRectMake(CGRectGetMaxX(self.level.frame), 23, 70, 70)];
        [self.head.layer setCornerRadius:35.0];
        [self.crown setFrame:CGRectMake(self.head.frame.origin.x + self.head.frame.size.width / 2 - 16, 5, 33, 21)];
        [self.name setFrame:CGRectMake(CGRectGetMaxX(self.head.frame) + 10, self.head.frame.origin.y + 5, 200, 25)];
        [self.describe setFrame:CGRectMake(self.name.frame.origin.x, CGRectGetMaxY(self.name.frame) + 5, 220, 25)];
    }
    else if (row == 1){
        [self.level setHidden:NO];
        [self.lowlevel setHidden:YES];
        [self.level setImage:[UIImage imageNamed:@"level2"] forState:UIControlStateNormal];
        [self.crown setImage:[UIImage imageNamed:@"crown2"]];
        [self.head setFrame:CGRectMake(CGRectGetMaxX(self.level.frame), 23, 70, 70)];
        [self.head.layer setCornerRadius:35.0];
        [self.crown setFrame:CGRectMake(self.head.frame.origin.x + self.head.frame.size.width / 2 - 16, 5, 33, 21)];
        [self.name setFrame:CGRectMake(CGRectGetMaxX(self.head.frame) + 10, self.head.frame.origin.y + 5, 200, 25)];
        [self.describe setFrame:CGRectMake(self.name.frame.origin.x, CGRectGetMaxY(self.name.frame) + 5, 220, 25)];
    }
    else if (row == 2){
        [self.level setHidden:NO];
        [self.lowlevel setHidden:YES];
        [self.level setImage:[UIImage imageNamed:@"level3"] forState:UIControlStateNormal];
        [self.crown setImage:[UIImage imageNamed:@"crown3"]];
        [self.head setFrame:CGRectMake(CGRectGetMaxX(self.level.frame), 23, 70, 70)];
        [self.head.layer setCornerRadius:35.0];
        [self.crown setFrame:CGRectMake(self.head.frame.origin.x + self.head.frame.size.width / 2 - 16, 5, 33, 21)];
        [self.name setFrame:CGRectMake(CGRectGetMaxX(self.head.frame) + 10, self.head.frame.origin.y + 5, 200, 25)];
        [self.describe setFrame:CGRectMake(self.name.frame.origin.x, CGRectGetMaxY(self.name.frame) + 5, 220, 25)];

    }
    else{
        [self.level setHidden:YES];
        [self.lowlevel setHidden:NO];
        [self.lowlevel setTitle:[NSString stringWithFormat:@"%ld",(long)row + 1] forState:UIControlStateNormal];
        [self.crown setImage:nil];
        [self.head setFrame:CGRectMake(CGRectGetMaxX(self.level.frame), 7.5, 60, 60)];
        [self.head.layer setCornerRadius:30.0];
        [self.name setFrame:CGRectMake(CGRectGetMaxX(self.head.frame) + 10, self.head.frame.origin.y + 5, 200, 25)];
        [self.describe setFrame:CGRectMake(self.name.frame.origin.x, CGRectGetMaxY(self.name.frame) + 5, 220, 25)];
        
    }
    
    [self.name setText:mdic[@"user_nicename"]];
    if ([mdic[@"user_avatar"]  rangeOfString:@"http"].location != NSNotFound){
        [self.head sd_setImageWithURL:[NSURL URLWithString:mdic[@"user_avatar"]] placeholderImage:AvatarPlaceHolderImage];
    }
    else{
        [self.head sd_setImageWithURL:[NSURL URLWithString:USERPHOTOHTTPSTRING(mdic[@"user_avatar"])] placeholderImage:AvatarPlaceHolderImage];
    }
    [self.describe setText:[mdic[@"message"] length] ? mdic[@"message"] : @"暂无留言"];
    
    //时间戳转时间
    NSDateFormatter* formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"yyyy-MM-dd HH:mm"];
    NSString *timeStr = [self stringWithTime:[(mdic[@"date"])integerValue]];
    NSDate *date = [formatter dateFromString:timeStr];
    [self.date setText:[date showTimeByTypeA]];
    if ([mdic[@"gold"] floatValue] > 0){
        [self.goldCoinButton setHidden:NO];
        [self.goldCoinButton setFrame:CGRectMake(SCREEN_WIDTH - 16 - 70, CGRectGetMaxY(self.date.frame) + 10, 70, 20)];
        if ([mdic[@"listen_money"] floatValue] > 0){
            [self.tcoinButton setHidden:NO];
            [self.tcoinButton setFrame:CGRectMake(SCREEN_WIDTH - 16 - 70 - 50, CGRectGetMaxY(self.date.frame) + 10, 70, 20)];
        }
        else{
            [self.tcoinButton setHidden:YES];
        }
        
    }
    else{
        [self.goldCoinButton setHidden:YES];
        if ([mdic[@"listen_money"] floatValue] > 0){
            [self.tcoinButton setHidden:NO];
            [self.tcoinButton setFrame:CGRectMake(SCREEN_WIDTH - 16 - 70, CGRectGetMaxY(self.date.frame) + 10, 70, 20)];
        }
        else{
            [self.tcoinButton setHidden:YES];
        }
        
    }
    [self.tcoinButton setTitle:[NSString stringWithFormat:@"%@",mdic[@"listen_money"]] forState:UIControlStateNormal];
     [self.goldCoinButton setTitle:[NSString stringWithFormat:@"%@",mdic[@"gold"]] forState:UIControlStateNormal];
    
}

- (NSString *)stringWithTime:(NSTimeInterval)timestamp {
    //设置时间显示格式
    NSDateFormatter *formatter = [[NSDateFormatter alloc]init];
    [formatter setDateStyle:NSDateFormatterMediumStyle];
    [formatter setTimeStyle:NSDateFormatterShortStyle];
    //先设置好dateStyle、timeStyle,再设置格式
    [formatter setDateFormat:@"YYYY-MM-dd HH:mm"];
    NSDate *date = [NSDate dateWithTimeIntervalSince1970:timestamp];
    //将NSDate按格式转化为对应的时间格式字符串
    NSString *timesString = [formatter stringFromDate:date];
    
    return timesString;
}

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
