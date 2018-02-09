//
//  mineVCHeaderTableViewCell.m
//  kuangjiaTingWen
//
//  Created by 泡果 on 2018/1/2.
//  Copyright © 2018年 zhimi. All rights reserved.
//

#import "mineVCHeaderTableViewCell.h"
#import "PayViewController.h"

@interface mineVCHeaderTableViewCell()
{
    UIView *imgBorderView;
    UIImageView *titleImage;
    UIImageView *ShadowImageView;
    UILabel *lab;
    UILabel *sign;
    UIImageView *vipImgView;
    UIButton *payButton;
    UILabel *TCoin;
}
@end

@implementation mineVCHeaderTableViewCell

+ (NSString *)ID
{
    return @"mineVCHeaderTableViewCell";
}
+(mineVCHeaderTableViewCell *)cellWithTableView:(UITableView *)tableView
{
    mineVCHeaderTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:[mineVCHeaderTableViewCell ID]];
    if (cell == nil) {
        cell = [[mineVCHeaderTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:[mineVCHeaderTableViewCell ID]];
    }
    return cell;
}
- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        
        UIImageView *cellBgView = [[UIImageView alloc]initWithFrame:CGRectMake(0, -20, SCREEN_WIDTH, 240.0 / 667 * IPHONE_H)];
        [cellBgView setUserInteractionEnabled:YES];
        [self.contentView addSubview:cellBgView];
        
        ShadowImageView = [[UIImageView alloc]initWithFrame:CGRectMake(0, -20, SCREEN_WIDTH, 240.0 / 667 * IPHONE_H)];
        [cellBgView setUserInteractionEnabled:YES];
        [self.contentView addSubview:ShadowImageView];
        
        //主背景
        UIImageView *coverView = [UIImageView new];
        [coverView setFrame:CGRectMake(0, -20, SCREEN_WIDTH, 240.0/ 667 * IPHONE_H)];
        [coverView setImage:[UIImage imageNamed:@"me_topbg1"]];
        [self.contentView addSubview:coverView];
        
        //标题
        UILabel *topLab = [[UILabel alloc]initWithFrame:CGRectMake((SCREEN_WIDTH - 44 )/2, IS_IPHONEX?20:0, 44, 44)];
        topLab.textColor = gTextColorMain;
        topLab.font = [UIFont fontWithName:@"Semibold" size:17.0f ];
        topLab.text = @"我";
        topLab.backgroundColor = [UIColor clearColor];
        topLab.textAlignment = NSTextAlignmentCenter;
        [self.contentView addSubview:topLab];
        
        //头像背景
        UIView *imgBorderView = [[UIView alloc]initWithFrame:CGRectMake(IS_IPHONEX?30.0:30.0 / 667 * IPHONE_H, 80.0 / 667 * IPHONE_H, 95.0 / 667 * IPHONE_H, 95.0 / 667 * IPHONE_H)];
        [imgBorderView setBackgroundColor:gImageBorderColor];
        [imgBorderView setUserInteractionEnabled:YES];
        [imgBorderView.layer setMasksToBounds:YES];
        [imgBorderView.layer setCornerRadius:95.0 / 667 * IPHONE_H / 2];
        [self.contentView addSubview:imgBorderView];
        
        //头像
        titleImage = [[UIImageView alloc]initWithFrame:CGRectMake(2.5/ 667 * IPHONE_H, 2.5 / 667 *IPHONE_H, 90.0 / 667 * IPHONE_H, 90.0 / 667 * IPHONE_H)];
        titleImage.image = [UIImage imageWithContentsOfFile:ExTouXiangPath];
        ShadowImageView.image = [UIImage imageWithContentsOfFile:ExTouXiangPath];
        ShadowImageView.contentMode = UIViewContentModeScaleAspectFill;
        ShadowImageView.clipsToBounds = YES;
        
        if (titleImage.image == nil){
            titleImage.image = [UIImage imageNamed:@"right-1"];
        }
        titleImage.layer.cornerRadius = titleImage.frame.size.width / 2;
        titleImage.clipsToBounds = YES;
        titleImage.userInteractionEnabled = YES;
        [titleImage addTapGesWithTarget:self action:@selector(dianjitouxiangshijianAction)];
        [imgBorderView addSubview:titleImage];
        //加边框
        CALayer *layer = [titleImage layer];
        layer.borderColor = [gImageBorderColor CGColor];
        layer.borderWidth = 0.0f;
//        [self.newPersonMessageButton setHidden:YES];
//        [self.contentView addSubview:self.newPersonMessageButton];
        
        //名称
        lab = [[UILabel alloc]initWithFrame:CGRectMake(CGRectGetMaxX(imgBorderView.frame) + 12, imgBorderView.frame.origin.y + 10.0 / 667 * IPHONE_H, SCREEN_WIDTH - 150, 20.0 / 667 * IPHONE_H)];
        lab.font =  CUSTOM_FONT_TYPE(17.0);
        lab.textColor = [UIColor whiteColor];
//        lab.backgroundColor = [UIColor redColor];
        lab.textAlignment = NSTextAlignmentLeft;
        [lab addTapGesWithTarget:self action:@selector(dianjitouxiangshijian)];
        [self.contentView addSubview:lab];
        if ([[CommonCode readFromUserD:@"isLogin"] boolValue] == YES){
            CGSize contentSize = [lab sizeThatFits:CGSizeMake(lab.frame.size.width, MAXFLOAT)];
            lab.frame = CGRectMake(lab.frame.origin.x, lab.frame.origin.y,contentSize.width, lab.frame.size.height);
            
            NSDictionary *userInfoDict = [CommonCode readFromUserD:@"dangqianUserInfo"];
            NSString *isNameNil = userInfoDict[results][@"user_nicename"];
            if (isNameNil.length == 0){
                lab.text = userInfoDict[results][@"user_login"];
            }
            else{
                lab.text = userInfoDict[results][@"user_nicename"];
            }
        }
        
        //vip图标
        vipImgView = [[UIImageView alloc] initWithFrame:CGRectMake(CGRectGetMaxX(lab.frame) + 10, lab.y + 2, 30, 37)];
        vipImgView.hidden = YES;
        vipImgView.contentMode = UIViewContentModeScaleAspectFill;
        vipImgView.userInteractionEnabled = YES;
        [vipImgView addTapGesWithTarget:self action:@selector(vipTapAction)];
        [self.contentView addSubview:vipImgView];
        
        //签名
        sign = [[UILabel alloc]initWithFrame:CGRectMake(CGRectGetMaxX(imgBorderView.frame) + 12, CGRectGetMaxY(lab.frame) + 20, SCREEN_WIDTH - CGRectGetMaxX(imgBorderView.frame) - 30, 20.0 / 667 * IPHONE_H)];
        sign.font =  CUSTOM_FONT_TYPE(13.0);
        sign.textColor = HEXCOLOR(0xf5f5f5);
        sign.numberOfLines = 2;
        sign.textAlignment = NSTextAlignmentLeft;
        [self.contentView addSubview:sign];
        
        //充值按钮
        payButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [payButton setFrame:CGRectMake(lab.frame.origin.x + 5, CGRectGetMaxY(sign.frame) + 10, 80.0 / 375 * SCREEN_WIDTH, 20.0 / 667 * IPHONE_H)];
        [payButton setBackgroundColor:gButtonRewardColor];
        [payButton setTitle:@"充值" forState:UIControlStateNormal];
        [payButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [payButton.titleLabel setFont:gFontMain12];
        [payButton.layer setMasksToBounds:YES];
        [payButton.layer setCornerRadius:8.0];
        [payButton addTarget:self action:@selector(payButtonAction) forControlEvents:UIControlEventTouchUpInside];
        [self.contentView addSubview:payButton];
        
        TCoin = [[UILabel alloc] initWithFrame:CGRectMake(CGRectGetMaxX(payButton.frame)+10, payButton.y, 100, AUTO_HEIGHT(20.0))];
        TCoin.textColor = [UIColor whiteColor];
        TCoin.font = CUSTOM_FONT_TYPE(14.0);
        [self.contentView addSubview:TCoin];
    }
    return self;
}
- (void)payButtonAction
{
    id object = [self nextResponder];
    
    while (![object isKindOfClass:[UINavigationController class]] &&
           object != nil) {
        object = [object nextResponder];
    }
    UINavigationController *navVC = (UINavigationController *)object;
    [navVC pushViewController:[PayViewController new] animated:YES];
}
- (void)setIsIAP:(BOOL)isIAP
{
    _isIAP = isIAP;
    
    titleImage.image = [UIImage imageWithContentsOfFile:ExTouXiangPath];
    ShadowImageView.image = [UIImage imageWithContentsOfFile:ExTouXiangPath];
    if (titleImage.image == nil){
        titleImage.image = [UIImage imageNamed:@"right-1"];
    }
    //是否登录
    if ([[CommonCode readFromUserD:@"isLogin"] boolValue] == YES){
        
        NSDictionary *userInfoDict = [CommonCode readFromUserD:@"dangqianUserInfo"];
        RTLog(@"%@",userInfoDict);
        NSString *isNameNil = userInfoDict[results][@"user_nicename"];
        NSString *isSignatureNil = userInfoDict[results][@"signature"];
        if (isNameNil.length == 0){
            lab.text = userInfoDict[results][@"user_login"];
        }
        else{
            lab.text = userInfoDict[results][@"user_nicename"];
        }
        CGSize contentSize = [lab sizeThatFits:CGSizeMake(lab.frame.size.width, MAXFLOAT)];
        lab.frame = CGRectMake(lab.frame.origin.x, lab.frame.origin.y,contentSize.width, lab.frame.size.height);
        
        if (isSignatureNil.length == 0) {
            sign.text = @"该用户没有什么想说的";
        }else{
            sign.text = isSignatureNil;
        }
        CGSize signContentSize = [sign.text boundingRectWithSize:CGSizeMake(SCREEN_WIDTH - CGRectGetMaxX(imgBorderView.frame) - 30, MAXFLOAT) options:NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName:sign.font} context:nil].size;
        sign.frame = CGRectMake(sign.x, sign.y,signContentSize.width, signContentSize.height);
        
        //判断是否在审核中
        if (isIAP) {
            vipImgView.hidden = YES;
            payButton.hidden = NO;
            TCoin.hidden = NO;
            TCoin.text = [NSString stringWithFormat:@"听币:%@",userInfoDict[results][@"listen_money"]];
        }else{
            payButton.hidden = YES;
            TCoin.hidden = YES;
            if ([userInfoDict[results][member_type] intValue] == 1||[userInfoDict[results][member_type] intValue] == 2) {
                
                vipImgView.frame = CGRectMake(CGRectGetMaxX(lab.frame) + 10, lab.y + 2, 30, 37);
                vipImgView.centerY = lab.centerY;
                vipImgView.hidden = NO;
                if ([userInfoDict[results][member_type] intValue] == 1) {
                    vipImgView.image = [UIImage imageNamed:@"vip"];
                }else{
                    vipImgView.image = [UIImage imageNamed:@"svip"];
                }
            }else{
                vipImgView.hidden = YES;
            }
        }
    }
    else{
        lab.text = nil;
        sign.text = nil;
        vipImgView.hidden = YES;
        payButton.hidden = YES;
        TCoin.hidden = YES;
    }
}
- (void)vipTapAction
{
    if (self.vipTap) {
        self.vipTap();
    }
}
- (void)dianjitouxiangshijianAction
{
    if (self.dianjitouxiangshijian) {
        self.dianjitouxiangshijian();
    }
}
@end
