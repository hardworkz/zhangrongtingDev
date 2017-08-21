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
        //
        detailLabel = [[UILabel alloc] init];
        detailLabel.numberOfLines = 0;
        detailLabel.frame = CGRectMake(CGRectGetMaxX(userHeadImageView.frame) + 10, CGRectGetMaxY(nameLabel.frame) + 5, SCREEN_WIDTH - 100, 35);
        detailLabel.font = [UIFont systemFontOfSize:14];
        detailLabel.textColor = [UIColor lightGrayColor];
        [self.contentView addSubview:detailLabel];
    }
    return self;
}
- (void)setUser:(NSDictionary *)user
{
    _user = user;
    
    nameLabel.text = user[@"user_nicename"];
    
    if ([_is_member isEqualToString:@"1"]) {
        NSMutableAttributedString *attriStr = [[NSMutableAttributedString alloc] initWithString:[NSString stringWithFormat:@"您已是会员，有效期至%@，新购买的会员将在此日期后自动生效",_end_date]];
        [attriStr addAttribute:NSForegroundColorAttributeName value:gMainColor range:NSMakeRange(10,_end_date.length)];
        detailLabel.attributedText = attriStr;
    }else{
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
