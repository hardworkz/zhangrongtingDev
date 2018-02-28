//
//  LearingInvitationCardController.m
//  kuangjiaTingWen
//
//  Created by 泡果 on 2018/2/8.
//  Copyright © 2018年 zhimi. All rights reserved.
//

#import "LearingInvitationCardController.h"

@interface LearingInvitationCardController ()

@end

@implementation LearingInvitationCardController
- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self.navigationController setNavigationBarHidden:NO animated:YES];
}
- (void)back {
    [self.navigationController popViewControllerAnimated:YES];
}
- (void)shareClicked{
    
}
- (void)viewDidLoad {
    [super viewDidLoad];
    
    UIButton *backImage = [UIButton buttonWithType:UIButtonTypeCustom];
    [backImage setFrame:CGRectMake(0, 0, 44, 30)];
    backImage.contentEdgeInsets = UIEdgeInsetsMake(0, 0, 0, 20);
    [backImage setImage:[UIImage imageNamed:@"back"] forState:UIControlStateNormal];
    [backImage addTarget:self action:@selector(back) forControlEvents:UIControlEventTouchUpInside];
    
    UIBarButtonItem *backItem = [[UIBarButtonItem alloc] initWithCustomView:backImage];
    self.navigationItem.leftBarButtonItem = backItem;
    
    UIButton *shareImage = [UIButton buttonWithType:UIButtonTypeCustom];
    [shareImage setFrame:CGRectMake(0, 0, 44, 30)];
    shareImage.contentEdgeInsets = UIEdgeInsetsMake(0, 20, 0, 0);
    [shareImage setImage:[UIImage imageNamed:@"title_ic_share"] forState:UIControlStateNormal];
    [shareImage addTarget:self action:@selector(shareClicked) forControlEvents:UIControlEventTouchUpInside];
    
    UIBarButtonItem *shareItem = [[UIBarButtonItem alloc] initWithCustomView:shareImage];
    self.navigationItem.rightBarButtonItem = shareItem;
    
    [self setupView];
}

- (void)setupView
{
    UIImageView *bgImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0,IS_IPHONEX?IPHONEX_TOP_H:64, SCREEN_WIDTH,IS_IPHONEX? SCREEN_HEIGHT - IPHONEX_TOP_H:SCREEN_HEIGHT - 64)];
    bgImageView.image = [UIImage imageNamed:@"icon_learing_invitation_card"];
    [self.view addSubview:bgImageView];
    
    UIImageView *headBgImageView = [[UIImageView alloc] initWithFrame:CGRectMake((SCREEN_WIDTH - 80)/2,AUTO_HEIGHT(150.0), 80,80.0/462*411)];
    headBgImageView.image = [UIImage imageNamed:@"icon_wreath"];
    [bgImageView addSubview:headBgImageView];
    
    UIImageView *headImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0,0,55,55)];
    headImageView.centerX = 40;
    headImageView.centerY = 40.0/462*411 - 5;
    headImageView.contentMode = UIViewContentModeScaleAspectFill;
    headImageView.clipsToBounds = YES;
    headImageView.layer.cornerRadius = 27.5;
//    headImageView.center = headBgImageView.center;
    headImageView.image = [UIImage imageWithContentsOfFile:ExTouXiangPath];
    [headBgImageView addSubview:headImageView];
    
    UILabel *nameLabel = [[UILabel alloc] init];
    nameLabel.textAlignment = NSTextAlignmentCenter;
    nameLabel.font = [UIFont boldSystemFontOfSize:15.0];
    [bgImageView addSubview:nameLabel];
    
    UILabel *textLabel = [[UILabel alloc] init];
    textLabel.textAlignment = NSTextAlignmentCenter;
    textLabel.font = CUSTOM_FONT_TYPE(15.0);
    textLabel.text = @"邀请您一起学习";
    [bgImageView addSubview:textLabel];
    
    UIView *classView = [[UIView alloc] init];
    classView.backgroundColor = [UIColor whiteColor];
    classView.layer.cornerRadius = 10;
    classView.layer.borderColor = [UIColor lightGrayColor].CGColor;
    classView.layer.borderWidth = 1.0;
    [bgImageView addSubview:classView];
    if (IS_IPAD) {
        classView.frame = CGRectMake(10, CGRectGetMaxY(textLabel.frame), SCREEN_WIDTH - 20, 105.0 / 375 *IPHONE_W + 30);
    }else{
        classView.frame = CGRectMake(10, CGRectGetMaxY(textLabel.frame), SCREEN_WIDTH - 20, 105.0 / 375 *IPHONE_W + 30);
    }
    //图片
    UIImageView *imgLeft = [[UIImageView alloc]init];
    [imgLeft.layer setMasksToBounds:YES];
    [imgLeft.layer setCornerRadius:5.0];
    
    [classView addSubview:imgLeft];
    imgLeft.contentMode = UIViewContentModeScaleAspectFill;
    imgLeft.clipsToBounds = YES;
    
    //标题
    UILabel *titleLab = [[UILabel alloc]init];
    titleLab.textColor = [UIColor blackColor];
    titleLab.textAlignment = NSTextAlignmentLeft;
    titleLab.numberOfLines = 0;
    titleLab.font = [UIFont boldSystemFontOfSize:16.0f];
    [classView addSubview:titleLab];
    
    //简介
    UILabel *describe = [[UILabel alloc]init];
    describe.textColor = gTextColorSub;
    describe.numberOfLines = 0;
    describe.textAlignment = NSTextAlignmentLeft;
    describe.font = [UIFont fontWithName:@"PingFangSC-Semibold" size:14.0];
    [classView addSubview:describe];
    
    if (IS_IPAD) {
        imgLeft.frame = CGRectMake(15.0, 15, 105.0 / 375 * IPHONE_W, 105.0 / 375 *IPHONE_W);
    }else{
        imgLeft.frame = CGRectMake(15.0, 15, 105.0 / 375 * IPHONE_W, 105.0 / 375 *IPHONE_W);
    }
    CGSize titleSize = [@"sdfasfasfas" boundingRectWithSize:CGSizeMake(SCREEN_WIDTH - CGRectGetMaxX(imgLeft.frame) - 70.0 / 375 * IPHONE_W, MAXFLOAT) options:NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName:CUSTOM_FONT_TYPE(16.0)} context:nil].size;
    titleLab.frame = CGRectMake(CGRectGetMaxX(imgLeft.frame) + 5.0 / 375 * IPHONE_W, imgLeft.y,  SCREEN_WIDTH - CGRectGetMaxX(imgLeft.frame) - 70.0 / 375 * IPHONE_W, titleSize.height);
    
    CGSize describeSize = [@"adfadsfas" boundingRectWithSize:CGSizeMake(SCREEN_WIDTH - CGRectGetMaxX(imgLeft.frame) - 20.0 / 375 * IPHONE_W, MAXFLOAT) options:NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName:CUSTOM_FONT_TYPE(14.0)} context:nil].size;
    describe.frame = CGRectMake(titleLab.x, CGRectGetMaxY(imgLeft.frame) - (describeSize.height), SCREEN_WIDTH - CGRectGetMaxX(imgLeft.frame) - 20.0 / 375 * IPHONE_W, describeSize.height);
    
    //二维码
    UIImageView *rqCodeImageView = [[UIImageView alloc] initWithFrame:CGRectMake(SCREEN_WIDTH - 150,CGRectGetMaxY(classView.frame) + 50, 100,100)];
    rqCodeImageView.image = [UIImage imageNamed:@"icon_fingerprint"];
    [bgImageView addSubview:rqCodeImageView];
}
@end
