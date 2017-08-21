//
//  PlayVCCommentTableViewCell.m
//  kuangjiaTingWen
//
//  Created by 泡果 on 2017/5/17.
//  Copyright © 2017年 zhimi. All rights reserved.
//

#import "PlayVCCommentTableViewCell.h"

@interface PlayVCCommentTableViewCell ()
{
    UIImageView *pinglunImg;
    UILabel *pinglunTitle;
    UILabel *pinglunshijian;
    UILabel *pinglunLab;
    UIButton *commenter;
    UILabel *content;
    PinglundianzanCustomBtn *PingLundianzanBtn;
    UILabel *PingLundianzanNumLab;
    UIView *devider;
}

@end
@implementation PlayVCCommentTableViewCell
+ (NSString *)ID
{
    return @"PlayVCCommentTableViewCell";
}
+(PlayVCCommentTableViewCell *)cellWithTableView:(UITableView *)tableView
{
    PlayVCCommentTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:[PlayVCCommentTableViewCell ID]];
    if (cell == nil) {
        cell = [[PlayVCCommentTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:[PlayVCCommentTableViewCell ID]];
    }
    return cell;
}
- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        pinglunImg = [[UIImageView alloc]init];
        pinglunImg.userInteractionEnabled = YES;
        UITapGestureRecognizer *TapG = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(clickPinglunImgHead:)];
        [pinglunImg addGestureRecognizer:TapG];
        pinglunImg.contentMode = UIViewContentModeScaleAspectFill;
        pinglunImg.layer.masksToBounds = YES;
        pinglunImg.layer.cornerRadius = 25.0 / 667 * IPHONE_H;
        [self.contentView addSubview:pinglunImg];

        pinglunTitle = [[UILabel alloc]init];
        pinglunTitle.textAlignment = NSTextAlignmentLeft;
        pinglunTitle.textColor = [UIColor blackColor];
        pinglunTitle.font = [UIFont systemFontOfSize:16.0f];
        [self.contentView addSubview:pinglunTitle];
        
        pinglunshijian = [[UILabel alloc]init];
        pinglunshijian.textAlignment = NSTextAlignmentLeft;
        pinglunshijian.textColor = [UIColor grayColor];
        pinglunshijian.font = [UIFont systemFontOfSize:13.0f];
        [self.contentView addSubview:pinglunshijian];
        
        pinglunLab = [[UILabel alloc]init];
        pinglunLab.text = @"回复";
        pinglunLab.textColor = [UIColor blackColor];
        pinglunLab.font = [UIFont systemFontOfSize:16.0f];
        pinglunLab.textAlignment = NSTextAlignmentLeft;
        pinglunLab.numberOfLines = 0;
        [self.contentView addSubview:pinglunLab];
        
        commenter = [[UIButton alloc] init];
        [commenter setTitleColor:gMainColor forState:UIControlStateNormal];
        [commenter addTarget:self action:@selector(name_clicked:) forControlEvents:UIControlEventTouchUpInside];
        commenter.titleLabel.font = [UIFont systemFontOfSize:16.0f];
        [self.contentView addSubview:commenter];
        
        content = [[UILabel alloc]init];
        content.textColor = [UIColor blackColor];
        content.font = [UIFont systemFontOfSize:16.0f];
        content.textAlignment = NSTextAlignmentLeft;
        content.numberOfLines = 0;
        [self.contentView addSubview:content];
        //点赞按钮
        PingLundianzanBtn = [PinglundianzanCustomBtn buttonWithType:UIButtonTypeCustom];
        [self.contentView addSubview:PingLundianzanBtn];
        [PingLundianzanBtn setImage:[UIImage imageNamed:@"pinglun-yizan"] forState:UIControlStateSelected];
        [PingLundianzanBtn setImage:[UIImage imageNamed:@"pinglun-10"] forState:UIControlStateNormal];
        [PingLundianzanBtn addTarget:self action:@selector(pinglundianzanAction:) forControlEvents:UIControlEventTouchUpInside];
        
        //点赞label
        PingLundianzanNumLab = [[UILabel alloc]init];
        PingLundianzanNumLab.textAlignment = NSTextAlignmentCenter;
        PingLundianzanNumLab.font = [UIFont systemFontOfSize:16.0f / 375 * IPHONE_W];
        [self.contentView addSubview:PingLundianzanNumLab];
        PingLundianzanBtn.PingLundianzanNumLab = PingLundianzanNumLab;
        
        devider = [[UIView alloc] init];
        devider.backgroundColor = [UIColor lightGrayColor];
        [self.contentView addSubview:devider];
    }
    return self;
}
- (void)setFrameModel:(PlayVCCommentFrameModel *)frameModel
{
    _frameModel = frameModel;
    pinglunImg.frame = frameModel.pinglunImgF;
    pinglunTitle.frame = frameModel.pinglunTitleF;
    pinglunshijian.frame = frameModel.pinglunshijianF;
    content.frame = frameModel.contentF;
    devider.frame = frameModel.deviderF;
    //设置头像
    if ([frameModel.model.avatar  rangeOfString:@"http"].location != NSNotFound){
        [pinglunImg sd_setImageWithURL:[NSURL URLWithString:frameModel.model.avatar] placeholderImage:[UIImage imageNamed:@"right-1"]];
    }
    else{
        [pinglunImg sd_setImageWithURL:[NSURL URLWithString:USERPHOTOHTTPSTRING(frameModel.model.avatar)] placeholderImage:[UIImage imageNamed:@"right-1"]];
    }
    pinglunTitle.text = frameModel.model.full_name;
    pinglunshijian.text = frameModel.model.createtime;
    if ([frameModel.model.to_user_login length]) {
        pinglunLab.frame = frameModel.pinglunLabF;
        commenter.frame = frameModel.commenterF;
        content.text = frameModel.content;
        NSString *name = [frameModel.model.to_user_nicename length]?frameModel.model.to_user_nicename:frameModel.model.to_user_login;
        [commenter setTitle:[NSString stringWithFormat:@"@%@",name] forState:UIControlStateNormal];
        pinglunLab.hidden = NO;
        commenter.hidden = NO;
    }else
    {
        pinglunLab.hidden = YES;
        commenter.hidden = YES;
        content.text = frameModel.content;
    }
    //点赞按钮和赞人数
    if (!self.hideZanBtn) {
        PingLundianzanBtn.hidden = NO;
        PingLundianzanNumLab.hidden = NO;
        PingLundianzanBtn.frame = frameModel.pingLundianzanBtnF;
        PingLundianzanNumLab.frame = frameModel.pingLundianzanNumLabF;
        PingLundianzanNumLab.text = frameModel.model.praisenum;
        if ([[NSString stringWithFormat:@"%@",frameModel.model.praiseFlag] isEqualToString:@"1"]){
            PingLundianzanBtn.selected = NO;
            PingLundianzanNumLab.textColor = [UIColor grayColor];
            PingLundianzanNumLab.alpha = 0.7f;
        }
        else if([[NSString stringWithFormat:@"%@",frameModel.model.praiseFlag] isEqualToString:@"2"]){
            PingLundianzanBtn.selected = YES;
            PingLundianzanNumLab.textColor = ColorWithRGBA(0, 159, 240, 1);
            PingLundianzanNumLab.alpha = 1.0f;
        }
        else {
            PingLundianzanBtn.selected = NO;
            PingLundianzanNumLab.textColor = [UIColor grayColor];
            PingLundianzanNumLab.alpha = 0.7f;
        }
    }else{
        PingLundianzanBtn.hidden = YES;
        PingLundianzanNumLab.hidden = YES;
    }
}
- (void)pinglundianzanAction:(UIButton *)sender
{
    PinglundianzanCustomBtn *pinglundianzanBtn = (PinglundianzanCustomBtn *)sender;
    UILabel *dianzanNumlab = pinglundianzanBtn.PingLundianzanNumLab;
    switch (_commentCellType) {
        case CommentCellTypeNewsDetail:{
            if ([[CommonCode readFromUserD:@"isLogin"]boolValue] == YES) {
                sender.enabled = NO;
                if (sender.selected == YES){
                    [NetWorkTool addAndCancelPraiseWithaccessToken:[DSE encryptUseDES:ExdangqianUser] comments_id:_frameModel.model.playCommentID sccess:^(NSDictionary *responseObject) {
                        sender.enabled = YES;
                        if ([responseObject[msg] isEqualToString:@"取消成功!"]) {
                            //设置点赞按钮状态
                            dianzanNumlab.text = [NSString stringWithFormat:@"%d",[dianzanNumlab.text intValue] - 1];
                            dianzanNumlab.textColor = [UIColor grayColor];
                            dianzanNumlab.alpha = 0.7f;
                            sender.selected = NO;
                            //设置模型数据状态
                            _frameModel.model.praisenum = dianzanNumlab.text;
                            _frameModel.model.praiseFlag = @"2";
                        }
                    } failure:^(NSError *error) {
                        sender.enabled = YES;
                        NSLog(@"error = %@",error);
                    }];
                }
                else{
                    [NetWorkTool addAndCancelPraiseWithaccessToken:[DSE encryptUseDES:ExdangqianUser] comments_id:_frameModel.model.playCommentID sccess:^(NSDictionary *responseObject) {
                        sender.enabled = YES;
                        if ([responseObject[msg] isEqualToString:@"点赞成功!"]) {
                            //设置点赞按钮状态
                            dianzanNumlab.text = [NSString stringWithFormat:@"%d",[dianzanNumlab.text intValue] + 1];
                            dianzanNumlab.textColor = ColorWithRGBA(0, 159, 240, 1);
                            dianzanNumlab.alpha = 1.0f;
                            sender.selected = YES;
                            //设置模型数据状态
                            _frameModel.model.praisenum = dianzanNumlab.text;
                            _frameModel.model.praiseFlag = @"2";
                        }
                    } failure:^(NSError *error) {
                        sender.enabled = YES;
                        NSLog(@"error = %@",error);
                    }];
                }
                
            }else{
                [self loginFirst];
            }
        }
            
            break;
        case CommentCellTypeClassroom:
            if (self.zanClicked) {
                self.zanClicked(pinglundianzanBtn, self.frameModel);
            }
            break;
        case CommentCellTypeAchorCommentList:
            if (self.achorVCZanClicked) {
                self.achorVCZanClicked(pinglundianzanBtn, self.frameModel);
            }
            break;
            
        default:
            break;
    }
}
- (void)loginFirst {
    id object = [self nextResponder];
    
    while (![object isKindOfClass:[UIViewController class]] &&
           object != nil) {
        object = [object nextResponder];
    }
    UINavigationController *vc = (UINavigationController *)object;

    UIAlertController *qingshuruyonghuming = [UIAlertController alertControllerWithTitle:@"温馨提示" message:@"您还没登录，请先登录后操作" preferredStyle:UIAlertControllerStyleAlert];
    [qingshuruyonghuming addAction:[UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
    }]];
    [qingshuruyonghuming addAction:[UIAlertAction actionWithTitle:@"登录" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        LoginVC *loginFriVC = [LoginVC new];
        LoginNavC *loginNavC = [[LoginNavC alloc]initWithRootViewController:loginFriVC];
        [loginNavC.navigationBar setBackgroundColor:[UIColor whiteColor]];
        //        [loginNavC.navigationBar setBackgroundImage:[UIImage imageNamed:@"mian-1"] forBarMetrics:UIBarMetricsDefault];
        loginNavC.navigationBar.tintColor = [UIColor blackColor];
        [vc presentViewController:loginNavC animated:YES completion:nil];
    }]];
    
    [vc presentViewController:qingshuruyonghuming animated:YES completion:nil];
}
//点击@评论人名称跳转用户主页
- (void)name_clicked:(UIButton *)button
{
    id object = [self nextResponder];
    
    while (![object isKindOfClass:[UIViewController class]] &&
           object != nil) {
        object = [object nextResponder];
    }
    gerenzhuyeVC *gerenzhuye = [gerenzhuyeVC new];
    if ([_frameModel.model.to_user_login isEqualToString:ExdangqianUser] && [[CommonCode readFromUserD:@"isLogin"]boolValue] == YES) {
        gerenzhuye.isMypersonalPage = YES;
    }
    else{
        gerenzhuye.isMypersonalPage = NO;
    }
    gerenzhuye.isNewsComment = YES;
    gerenzhuye.user_nicename = _frameModel.model.to_user_login;
    gerenzhuye.sex = _frameModel.model.to_sex;
    gerenzhuye.signature = _frameModel.model.to_signature;
    gerenzhuye.user_login = _frameModel.model.to_user_login;
    gerenzhuye.avatar = _frameModel.model.to_avatar;
    gerenzhuye.user_id = _frameModel.model.to_uid;
    
    //跳转个人主页
    UINavigationController *vc = (UINavigationController *)object;
    gerenzhuye.hidesBottomBarWhenPushed=YES;
    [vc.navigationController pushViewController:gerenzhuye animated:YES];
    gerenzhuye.hidesBottomBarWhenPushed=YES;
}
//点击头像跳转个人主页
- (void)clickPinglunImgHead:(UIGestureRecognizer *)gesture
{
    id object = [self nextResponder];
    
    while (![object isKindOfClass:[UIViewController class]] &&
           object != nil) {
        object = [object nextResponder];
    }
    gerenzhuyeVC *gerenzhuye = [gerenzhuyeVC new];
    if ([_frameModel.model.user_login isEqualToString:ExdangqianUser] && [[CommonCode readFromUserD:@"isLogin"]boolValue] == YES) {
        gerenzhuye.isMypersonalPage = YES;
    }
    else{
        gerenzhuye.isMypersonalPage = NO;
    }
    gerenzhuye.isNewsComment = YES;
    gerenzhuye.user_nicename = _frameModel.model.user_login;
    gerenzhuye.sex = _frameModel.model.sex;
    gerenzhuye.signature = _frameModel.model.signature;
    gerenzhuye.user_login = _frameModel.model.user_login;
    gerenzhuye.avatar = _frameModel.model.avatar;
    gerenzhuye.user_id = _frameModel.model.uid;
    
    //跳转个人主页
    UINavigationController *vc = (UINavigationController *)object;
    gerenzhuye.hidesBottomBarWhenPushed=YES;
    [vc.navigationController pushViewController:gerenzhuye animated:YES];
    gerenzhuye.hidesBottomBarWhenPushed=YES;
}
@end
