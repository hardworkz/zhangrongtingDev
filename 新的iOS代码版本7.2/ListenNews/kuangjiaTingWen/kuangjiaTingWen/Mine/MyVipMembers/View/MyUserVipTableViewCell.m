//
//  MyUserVipTableViewCell.m
//  kuangjiaTingWen
//
//  Created by 泡果 on 2017/7/19.
//  Copyright © 2017年 zhimi. All rights reserved.
//

#import "MyUserVipTableViewCell.h"

@interface MyUserVipTableViewCell ()
{
    UIImageView *userHeadImageView;
    UILabel *nameLabel;
    UIImageView *vipImgView;
    UILabel *detailLabel;
}
@end
@implementation MyUserVipTableViewCell
+ (NSString *)ID
{
    return @"MyUserVipTableViewCell";
}
+(MyUserVipTableViewCell *)cellWithTableView:(UITableView *)tableView
{
    MyUserVipTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:[MyUserVipTableViewCell ID]];
    if (cell == nil) {
        cell = [[MyUserVipTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:[MyUserVipTableViewCell ID]];
    }
    return cell;
}
- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        
        userHeadImageView = [[UIImageView alloc] init];
        userHeadImageView.frame = CGRectMake(20, 15, 60, 60);
        userHeadImageView.layer.cornerRadius = 30;
        userHeadImageView.clipsToBounds = YES;
        userHeadImageView.contentMode = UIViewContentModeScaleAspectFill;
        [self.contentView addSubview:userHeadImageView];
        
        nameLabel = [[UILabel alloc] init];
        nameLabel.frame = CGRectMake(CGRectGetMaxX(userHeadImageView.frame) + 10, 15, SCREEN_WIDTH - 100, 20);
        nameLabel.font = [UIFont boldSystemFontOfSize:17];
        nameLabel.textColor = [UIColor blackColor];
        [self.contentView addSubview:nameLabel];
        
        vipImgView = [[UIImageView alloc] init];
        vipImgView.hidden = YES;
        vipImgView.contentMode = UIViewContentModeScaleAspectFill;
        [self.contentView addSubview:vipImgView];
        
        //vip说明
        detailLabel = [[UILabel alloc] init];
        detailLabel.numberOfLines = 0;
        detailLabel.frame = CGRectMake(CGRectGetMaxX(userHeadImageView.frame) + 10, CGRectGetMaxY(nameLabel.frame) + 5, SCREEN_WIDTH - 100,IPHONE_W == 320?40:35);
        detailLabel.font = [UIFont systemFontOfSize:IPHONE_W == 320 ?12:14];
        detailLabel.textColor = [UIColor lightGrayColor];
        [self.contentView addSubview:detailLabel];
    }
    return self;
}
- (void)setUser:(NSDictionary *)user
{
    _user = user;
    
    nameLabel.text = user[@"user_nicename"];
    nameLabel.width = [nameLabel.text boundingRectWithSize:CGSizeMake(MAXFLOAT, MAXFLOAT) options:NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName:nameLabel.font} context:nil].size.width;
    
    if ([_is_member isEqualToString:@"1"]||[_is_member isEqualToString:@"2"]) {
        NSMutableAttributedString *attriStr = [[NSMutableAttributedString alloc] initWithString:[NSString stringWithFormat:@"您已是会员，有效期至%@，新购买的会员将在此日期后自动生效",_end_date]];
        [attriStr addAttribute:NSForegroundColorAttributeName value:gMainColor range:NSMakeRange(10,_end_date.length)];
        detailLabel.attributedText = attriStr;
        
        vipImgView.frame = CGRectMake(CGRectGetMaxX(nameLabel.frame) + 5, nameLabel.y + 2, 30, 30);
        vipImgView.centerY = nameLabel.centerY;
        vipImgView.hidden = NO;
        if ([_is_member isEqualToString:@"1"]) {
            vipImgView.image = [UIImage imageNamed:@"vip"];
        }else{
            vipImgView.image = [UIImage imageNamed:@"svip"];
        }
    }else{
        vipImgView.hidden = YES;
        detailLabel.text = @"您还不是会员，开通会员后可收听更多资讯";
    }
    
    //头像url处理
    if ([NEWSSEMTPHOTOURL(user[@"avatar"])  rangeOfString:@"http"].location != NSNotFound){
        [userHeadImageView sd_setImageWithURL:[NSURL URLWithString:NEWSSEMTPHOTOURL(user[@"avatar"])] placeholderImage:AvatarPlaceHolderImage];
    }
    else{
        NSString *str = USERPHOTOHTTPSTRING(NEWSSEMTPHOTOURL(user[@"avatar"]));
        [userHeadImageView sd_setImageWithURL:[NSURL URLWithString:str] placeholderImage:AvatarPlaceHolderImage];
    }
}
@end
