//
//  UnreadMessageTableViewCell.m
//  kuangjiaTingWen
//
//  Created by Zhimi on 16/11/28.
//  Copyright © 2016年 贺楠. All rights reserved.
//

#import "UnreadMessageTableViewCell.h"

@interface UnreadMessageTableViewCell ()

@property (weak, nonatomic) IBOutlet UIImageView *userHead;
@property (weak, nonatomic) IBOutlet UILabel *userName;
@property (weak, nonatomic) IBOutlet UILabel *unreadMessage;


@end

@implementation UnreadMessageTableViewCell

- (void)awakeFromNib {
    [super awakeFromNib];
   
    _userHead.layer.cornerRadius = _userHead.frame.size.width / 2;
    _userHead.layer.masksToBounds = YES;
}

- (void)updateCellWithUnreadMessageDic:(NSDictionary *)unreadMessage andPageSource:(NSInteger )pageSource{
    
    _userName.text = unreadMessage[@"user"][@"user_nicename"] ? unreadMessage[@"user"][@"user_nicename"] : unreadMessage[@"user"][@"user_login"];
    if ([unreadMessage[@"user"][@"avatar"]  rangeOfString:@"http"].location != NSNotFound)
    {
        [_userHead sd_setImageWithURL:[NSURL URLWithString:unreadMessage[@"user"][@"avatar"]] placeholderImage:AvatarPlaceHolderImage];
    }
    else{
        [_userHead sd_setImageWithURL:[NSURL URLWithString:USERPHOTOHTTPSTRING(unreadMessage[@"user"][@"avatar"])] placeholderImage:AvatarPlaceHolderImage];
    }
    NSString *content = @"";
    switch (pageSource) {
        case 1:{
            //TODO:emoji解密
            content = unreadMessage[@"content"];
            if ([unreadMessage[@"content"] rangeOfString:@"[e1]"].location != NSNotFound && [unreadMessage[@"content"] rangeOfString:@"[/e1]"].location != NSNotFound){
                content = [CommonCode jiemiEmoji:unreadMessage[@"content"]];
            }
            _unreadMessage.text = content;
        }
            break;
        case 2:{
            content = unreadMessage[@"comment"];
            if ([unreadMessage[@"comment"] rangeOfString:@"[e1]"].location != NSNotFound && [unreadMessage[@"comment"] rangeOfString:@"[/e1]"].location != NSNotFound){
                content = [CommonCode jiemiEmoji:unreadMessage[@"comment"]];
            }
            _unreadMessage.text = content;
        }
            break;
        default:
            break;
    }
   
    
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
