//
//  PersonalUnreadTableViewCell.m
//  kuangjiaTingWen
//
//  Created by Zhimi on 16/12/19.
//  Copyright © 2016年 贺楠. All rights reserved.
//

#import "PersonalUnreadTableViewCell.h"

@interface PersonalUnreadTableViewCell()

@property (weak, nonatomic) IBOutlet UIImageView *headImage;
@property (weak, nonatomic) IBOutlet UILabel *nameLabel;

@property (weak, nonatomic) IBOutlet UIImageView *newsImage;

@end

@implementation PersonalUnreadTableViewCell

- (void)awakeFromNib {
    [super awakeFromNib];
    
    _headImage.layer.cornerRadius = _headImage.frame.size.width / 2;
    _headImage.layer.masksToBounds = YES;
    
}

- (void)updateCellWithUnreadMessageDic:(NSDictionary *)unreadMessage{
    _nameLabel.text = unreadMessage[@"to_user_nicename"] ? unreadMessage[@"to_user_nicename"] : unreadMessage[@"to_user_login"];
    if ([unreadMessage[@"to_avatar"]  rangeOfString:@"http"].location != NSNotFound)
    {
        [_headImage sd_setImageWithURL:[NSURL URLWithString:unreadMessage[@"to_avatar"]] placeholderImage:AvatarPlaceHolderImage];
    }
    else{
        [_headImage sd_setImageWithURL:[NSURL URLWithString:USERPHOTOHTTPSTRING(unreadMessage[@"to_avatar"])] placeholderImage:AvatarPlaceHolderImage];
    }
    
    NSString *imgUrl = [NSString stringWithFormat:@"%@",[unreadMessage[@"smeta"] stringByReplacingOccurrencesOfString:@"\\" withString:@""]];
    NSString *imgUrl1 = [imgUrl stringByReplacingOccurrencesOfString:@"\"" withString:@""];
    NSString *imgUrl2 = [imgUrl1 stringByReplacingOccurrencesOfString:@"thumb:" withString:@""];
    NSString *imgUrl3 = [imgUrl2 stringByReplacingOccurrencesOfString:@"{" withString:@""];
    NSString *imgUrl4 = [imgUrl3 stringByReplacingOccurrencesOfString:@"}" withString:@""];
    if ([imgUrl4  rangeOfString:@"http"].location != NSNotFound){
        imgUrl4 = [imgUrl4 stringByReplacingOccurrencesOfString:@"http" withString:@"https"];
        [_newsImage sd_setImageWithURL:[NSURL URLWithString:imgUrl4] placeholderImage:[UIImage imageNamed:@"thumbnailsdefault"]];
    }
    else{
        NSString *str = USERPHOTOHTTPSTRINGZhuBo(imgUrl4);
        [_newsImage sd_setImageWithURL:[NSURL URLWithString:str] placeholderImage:[UIImage imageNamed:@"thumbnailsdefault"]];
    }
    

}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
