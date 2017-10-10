//
//  CommentAndReviewTableViewCell.m
//  kuangjiaTingWen
//
//  Created by 泡果 on 2017/5/15.
//  Copyright © 2017年 zhimi. All rights reserved.
//

#import "CommentAndReviewTableViewCell.h"

@interface CommentAndReviewTableViewCell ()
@property (weak, nonatomic) UIButton *reviewer;
@property (weak, nonatomic) UIButton *commenter;
@property (weak, nonatomic) UILabel *review;
@property (weak, nonatomic) UILabel *content;
@end
@implementation CommentAndReviewTableViewCell
+ (NSString *)ID
{
    return @"CommentAndReviewTableViewCell";
}
+(CommentAndReviewTableViewCell *)cellWithTableView:(UITableView *)tableView
{
    CommentAndReviewTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:[CommentAndReviewTableViewCell ID]];
    if (cell == nil) {
        cell = [[CommentAndReviewTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:[CommentAndReviewTableViewCell ID]];
    }
    return cell;
}
- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        self.backgroundColor = [UIColor clearColor];
        
        UIButton *reviewer = [[UIButton alloc] init];
        [reviewer setTitleColor:gMainColor forState:UIControlStateNormal];
        [reviewer addTarget:self action:@selector(name_clicked:) forControlEvents:UIControlEventTouchUpInside];
        reviewer.titleLabel.font = gFontMain15;
        [self.contentView addSubview:reviewer];
        self.reviewer = reviewer;
        
        UILabel *review = [[UILabel alloc] init];
        review.text = @"回复";
        review.font = gFontMain14;
        [self.contentView addSubview:review];
        self.review = review;
        
        UIButton *commenter = [[UIButton alloc] init];
        [commenter setTitleColor:gMainColor forState:UIControlStateNormal];
        [commenter addTarget:self action:@selector(name_clicked:) forControlEvents:UIControlEventTouchUpInside];
        commenter.titleLabel.font = gFontMain15;
        [self.contentView addSubview:commenter];
        self.commenter = commenter;
        
        UILabel *content = [[UILabel alloc] init];
        content.numberOfLines = 0;
        content.font = gFontMain15;
        [self.contentView addSubview:content];
        self.content = content;
    }
    return self;
}
- (void)setFrameModel:(CommentAndReviewFrameModel *)frameModel
{
    _frameModel = frameModel;
    
    if ([frameModel.model.to_user.user_nicename isEqualToString:@""]||frameModel.model.to_user.user_nicename == nil) {
        self.commenter.hidden = YES;
        self.review.hidden = YES;
        self.reviewer.frame = frameModel.replyManF;
        self.content.frame = frameModel.contentLabelF;
        self.content.text = frameModel.content;
        [self.reviewer setTitle:frameModel.model.user.user_nicename forState:UIControlStateNormal];
    }else
    {
        self.commenter.hidden = NO;
        self.review.hidden = NO;
        self.reviewer.frame = frameModel.replyManF;
        self.review.frame = frameModel.labelF;
        self.commenter.frame = frameModel.beReplyManF;
        self.content.frame = frameModel.contentLabelF;
        self.content.text = frameModel.content;
        [self.reviewer setTitle:frameModel.model.user.user_nicename forState:UIControlStateNormal];
        [self.commenter setTitle:frameModel.model.to_user.user_nicename forState:UIControlStateNormal];
        self.review.text = @"回复";
    }
}
- (void)name_clicked:(UIButton *)button
{
    id object = [self nextResponder];
    
    while (![object isKindOfClass:[UIViewController class]] &&
           object != nil) {
        object = [object nextResponder];
    }
    child_commentModel *model = _frameModel.model;
    
    gerenzhuyeVC *gerenzhuye = [gerenzhuyeVC new];
    gerenzhuye.isNewsComment = NO;
    
    if ([button isEqual:self.reviewer]) {//回复人
        if ([_frameModel.model.user.user_login isEqualToString:ExdangqianUser] && [[CommonCode readFromUserD:@"isLogin"]boolValue] == YES) {
            gerenzhuye.isMypersonalPage = YES;
        }
        else{
            gerenzhuye.isMypersonalPage = NO;
        }
        gerenzhuye.user_nicename = model.user.user_nicename;
        gerenzhuye.sex = model.user.sex;
        gerenzhuye.signature = model.user.signature;
        gerenzhuye.user_login = model.user.user_login;
        gerenzhuye.avatar = model.user.avatar;
        gerenzhuye.fan_num = model.user.fan_num;
        gerenzhuye.guan_num = model.user.guan_num;
        gerenzhuye.user_id = model.user.ID;
    }else//评论人
    {
        if ([_frameModel.model.to_user.user_login isEqualToString:ExdangqianUser] && [[CommonCode readFromUserD:@"isLogin"]boolValue] == YES) {
            gerenzhuye.isMypersonalPage = YES;
        }
        else{
            gerenzhuye.isMypersonalPage = NO;
        }
        gerenzhuye.user_nicename = model.to_user.user_nicename;
        gerenzhuye.sex = model.to_user.sex;
        gerenzhuye.signature = model.to_user.signature;
        gerenzhuye.user_login = model.to_user.user_login;
        gerenzhuye.avatar = model.to_user.avatar;
        gerenzhuye.fan_num = model.to_user.fan_num;
        gerenzhuye.guan_num = model.to_user.guan_num;
        gerenzhuye.user_id = model.to_user.ID;
    }
    //跳转个人主页
    UINavigationController *vc = (UINavigationController *)object;
    gerenzhuye.hidesBottomBarWhenPushed=YES;
    [vc.navigationController pushViewController:gerenzhuye animated:YES];
    gerenzhuye.hidesBottomBarWhenPushed=YES;
}
@end
