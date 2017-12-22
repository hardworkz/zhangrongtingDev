//
//  HelpCenterViewController.m
//  kuangjiaTingWen
//
//  Created by Zhimi on 17/2/7.
//  Copyright © 2017年 贺楠. All rights reserved.
//

#import "HelpCenterViewController.h"

@interface HelpCenterViewController ()

@property (strong, nonatomic) UILabel *titleLabel;
@property (strong, nonatomic) UILabel *descpripeLabel;

@end

@implementation HelpCenterViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self setUpData];
    [self setUpView];
    
}

- (void)setUpData{
    [self.titleLabel setText:self.titleStr];
    [self.descpripeLabel setText:self.descripeStr];
    
    CGFloat titleHight = [self computeTextHeightWithString:self.descripeStr andWidth:(SCREEN_WIDTH-40) andFontSize:[UIFont systemFontOfSize:14]];
    [self.descpripeLabel setFrame:CGRectMake(20, CGRectGetMaxY(self.titleLabel.frame) + 15 , SCREEN_WIDTH - 40, titleHight)];
}

- (void)setUpView{
    
    [self setTitle:@"帮助中心"];
    [self enableAutoBack];
    self.extendedLayoutIncludesOpaqueBars = YES;
    [self.view setBackgroundColor:[UIColor whiteColor]];
    
    UIImageView *topBgView = [[UIImageView alloc]initWithFrame:CGRectMake(0, 64, SCREEN_WIDTH, 80.0)];
    [topBgView setImage:[UIImage imageNamed:@"helpCenter_bg"]];
    [self.view addSubview:topBgView];
    
    UIImageView *topTitleView = [[UIImageView alloc]initWithFrame:CGRectMake((SCREEN_WIDTH - 72) / 2, 20, 72, 40.0)];
    [topTitleView setImage:[UIImage imageNamed:@"helpCenter_title"]];
    [topBgView addSubview:topTitleView];
    
    [self.view addSubview:self.titleLabel];
    [self.view addSubview:self.descpripeLabel];
    
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
        _titleLabel = [[UILabel alloc]initWithFrame:CGRectMake(0, 64 + 80 +15, SCREEN_WIDTH, 30)];
        [_titleLabel setFont:gFontMajor17];
        [_titleLabel setTextColor:gTextDownload];
        [_titleLabel setTextAlignment:NSTextAlignmentCenter];
    }
    return _titleLabel;
}

- (UILabel *)descpripeLabel{
    if (!_descpripeLabel) {
        _descpripeLabel = [[UILabel alloc]initWithFrame:CGRectMake(20, 64 + 80 + 15 + 45 , SCREEN_WIDTH - 40, 200)];
        [_descpripeLabel setFont:gFontMain14];
        [_descpripeLabel setTextColor:gTextColorBackground];
        [_descpripeLabel setTextAlignment:NSTextAlignmentLeft];
        [_descpripeLabel setNumberOfLines:0];
    }
    return _descpripeLabel;
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
