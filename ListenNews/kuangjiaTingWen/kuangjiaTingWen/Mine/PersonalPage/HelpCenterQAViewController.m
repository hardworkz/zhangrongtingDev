//
//  HelpCenterQAViewController.m
//  kuangjiaTingWen
//
//  Created by Zhimi on 17/2/9.
//  Copyright © 2017年 贺楠. All rights reserved.
//

#import "HelpCenterQAViewController.h"

@interface HelpCenterQAViewController ()

@property (strong, nonatomic) UILabel *titleLabel;
@property (strong, nonatomic) UILabel *descpripeLabel;

@property (strong, nonatomic) UILabel *titleLabel1;
@property (strong, nonatomic) UILabel *descpripeLabel1;

@property (strong, nonatomic) UILabel *titleLabel2;
@property (strong, nonatomic) UILabel *descpripeLabel2;

@property (strong, nonatomic) UIScrollView *bgSroView;

@end

@implementation HelpCenterQAViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self setUpView];
    [self setUpData];
}

- (void)setUpData{
    NSString *titleStr = @"1.什么是听币，它有哪些用处？";
    NSString *descpStr = @"·  听币是听闻APP中通过充值得到的流通货币，其与人民币兑换的比例为1：1。\n·  听币目前可以用来赞赏你喜爱的主播或者开通会员。\n·  每消耗一次听币可以获得5点经验值。";
    [self.titleLabel setText:titleStr];
    [self.descpripeLabel setText:descpStr];
    CGFloat titleHight = [self computeTextHeightWithString:descpStr andWidth:(SCREEN_WIDTH-40) andFontSize:[UIFont systemFontOfSize:14]];
    [self.descpripeLabel setFrame:CGRectMake(20, CGRectGetMaxY(self.titleLabel.frame) + 15 , SCREEN_WIDTH - 40, titleHight)];
    NSString *title1Str = @"2.什么是金币，它有哪些用处？";
    NSString *descp1Str =  @"·  金币是通过听闻APP中各种日常使用或任务得到的另一种流通货币\n·  金币可以用来投给你喜爱的节目以提高该节目和其主播的排名，使其获得更多的关注\n·  金币可以通过签到，分享APP和分享节目获得。";
    [self.titleLabel1 setText:title1Str];
    [self.descpripeLabel1 setText:descp1Str];
     CGFloat titleHight1 = [self computeTextHeightWithString:descp1Str andWidth:(SCREEN_WIDTH-40) andFontSize:[UIFont systemFontOfSize:14]];
    [self.titleLabel1 setFrame:CGRectMake(0, CGRectGetMaxY(self.descpripeLabel.frame) + 15, SCREEN_WIDTH, 30)];
    [self.descpripeLabel1 setFrame:CGRectMake(20, CGRectGetMaxY(self.titleLabel1.frame) + 15 , SCREEN_WIDTH - 40, titleHight1)];
    NSString *title2Str = @"3.如何快速升级？";
    NSString *descp2Str =  @"·  听闻的等级提升很快的哦~只要每日登陆、签到、多多给主播投币、发表言论以及分享就好啦！\n·  除此之外，充值听币是最快的升级办法。而第一次修改头像和修改昵称会分别增加20经验值。分享APP要是第一次有50经验值的加成呢~赶快试试吧\n·  每消耗一次听币可以获得5点经验值。";
    [self.titleLabel2 setText:title2Str];
    [self.descpripeLabel2 setText:descp2Str];
    CGFloat titleHight2 = [self computeTextHeightWithString:descp2Str andWidth:(SCREEN_WIDTH-40) andFontSize:[UIFont systemFontOfSize:14]];
    [self.titleLabel2 setFrame:CGRectMake(0, CGRectGetMaxY(self.descpripeLabel1.frame) + 15, SCREEN_WIDTH, 30)];
    [self.descpripeLabel2 setFrame:CGRectMake(20, CGRectGetMaxY(self.titleLabel2.frame) + 15 , SCREEN_WIDTH - 40, titleHight2)];
    [_bgSroView setContentSize:CGSizeMake(SCREEN_WIDTH, CGRectGetMaxY(self.descpripeLabel2.frame) + 64)];
    
}

- (void)setUpView{
    
    [self setTitle:@"帮助中心"];
    [self enableAutoBack];
    self.extendedLayoutIncludesOpaqueBars = YES;
    [self.view setBackgroundColor:[UIColor whiteColor]];
    
   
    
    _bgSroView = [[UIScrollView alloc]initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_HEIGHT)];
    [_bgSroView setContentSize:CGSizeMake(SCREEN_WIDTH, SCREEN_HEIGHT)];
    [_bgSroView setScrollEnabled:YES];
    [_bgSroView setShowsVerticalScrollIndicator:YES];
    [self.view addSubview:_bgSroView];
    
    UIImageView *topBgView = [[UIImageView alloc]initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, 80.0)];
    [topBgView setImage:[UIImage imageNamed:@"helpCenter_bg"]];
    [_bgSroView addSubview:topBgView];
    
    UIImageView *topTitleView = [[UIImageView alloc]initWithFrame:CGRectMake((SCREEN_WIDTH - 72) / 2, 20, 72, 40.0)];
    [topTitleView setImage:[UIImage imageNamed:@"helpCenter_title"]];
    [topBgView addSubview:topTitleView];
    
    [_bgSroView addSubview:self.titleLabel];
    [_bgSroView addSubview:self.descpripeLabel];
    [_bgSroView addSubview:self.titleLabel1];
    [_bgSroView addSubview:self.descpripeLabel1];
    [_bgSroView addSubview:self.titleLabel2];
    [_bgSroView addSubview:self.descpripeLabel2];
    
    UISwipeGestureRecognizer *rightSwipe = [[UISwipeGestureRecognizer alloc]initWithTarget:self action:@selector(back)];
    [rightSwipe setDirection:UISwipeGestureRecognizerDirectionRight];
    [self.view addGestureRecognizer:rightSwipe];
    
}

- (void)back {
    [self.navigationController popViewControllerAnimated:YES];
}

/**
 *  计算文本高度
 *
 *  @param string   要计算的文本
 *  @param width    单行文本的宽度
 *  @param fontSize 文本的字体size
 *
 *  @return 返回文本高度
 */
- (CGFloat)computeTextHeightWithString:(NSString *)string andWidth:(CGFloat)width andFontSize:(UIFont *)fontSize{
    
    CGRect rect  = [string boundingRectWithSize:CGSizeMake(width, 10000)
                                        options: NSStringDrawingUsesFontLeading |NSStringDrawingUsesLineFragmentOrigin
                                     attributes:@{NSFontAttributeName:fontSize}
                                        context:nil];
    return ceil(rect.size.height);
}

- (UILabel *)titleLabel{
    if (!_titleLabel) {
        _titleLabel = [[UILabel alloc]initWithFrame:CGRectMake(0, 80 +15, SCREEN_WIDTH, 30)];
        [_titleLabel setFont:gFontMajor17];
        [_titleLabel setTextColor:gTextDownload];
        [_titleLabel setTextAlignment:NSTextAlignmentCenter];
    }
    return _titleLabel;
}

- (UILabel *)descpripeLabel{
    if (!_descpripeLabel) {
        _descpripeLabel = [[UILabel alloc]initWithFrame:CGRectMake(20, 80 + 15 + 45 , SCREEN_WIDTH - 40, 200)];
        [_descpripeLabel setFont:gFontMain14];
        [_descpripeLabel setTextColor:gTextColorBackground];
        [_descpripeLabel setTextAlignment:NSTextAlignmentLeft];
        [_descpripeLabel setNumberOfLines:0];
    }
    return _descpripeLabel;
}
- (UILabel *)titleLabel1{
    if (!_titleLabel1) {
        _titleLabel1 = [[UILabel alloc]initWithFrame:CGRectMake(0, 80 +15, SCREEN_WIDTH, 30)];
        [_titleLabel1 setFont:gFontMajor17];
        [_titleLabel1 setTextColor:gTextDownload];
        [_titleLabel1 setTextAlignment:NSTextAlignmentCenter];
    }
    return _titleLabel1;
}

- (UILabel *)descpripeLabel1{
    if (!_descpripeLabel1) {
        _descpripeLabel1 = [[UILabel alloc]initWithFrame:CGRectMake(20, 80 + 15 + 45 , SCREEN_WIDTH - 40, 200)];
        [_descpripeLabel1 setFont:gFontMain14];
        [_descpripeLabel1 setTextColor:gTextColorBackground];
        [_descpripeLabel1 setTextAlignment:NSTextAlignmentLeft];
        [_descpripeLabel1 setNumberOfLines:0];
    }
    return _descpripeLabel1;
}
- (UILabel *)titleLabel2{
    if (!_titleLabel2) {
        _titleLabel2 = [[UILabel alloc]initWithFrame:CGRectMake(0, 80 +15, SCREEN_WIDTH, 30)];
        [_titleLabel2 setFont:gFontMajor17];
        [_titleLabel2 setTextColor:gTextDownload];
        [_titleLabel2 setTextAlignment:NSTextAlignmentCenter];
    }
    return _titleLabel2;
}

- (UILabel *)descpripeLabel2{
    if (!_descpripeLabel2) {
        _descpripeLabel2 = [[UILabel alloc]initWithFrame:CGRectMake(20, 80 + 15 + 45 , SCREEN_WIDTH - 40, 200)];
        [_descpripeLabel2 setFont:gFontMain14];
        [_descpripeLabel2 setTextColor:gTextColorBackground];
        [_descpripeLabel2 setTextAlignment:NSTextAlignmentLeft];
        [_descpripeLabel2 setNumberOfLines:0];
    }
    return _descpripeLabel2;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
