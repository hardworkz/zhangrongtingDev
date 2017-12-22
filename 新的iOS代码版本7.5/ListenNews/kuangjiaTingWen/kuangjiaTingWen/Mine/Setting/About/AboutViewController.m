//
//  AboutViewController.m
//  listenNews
//
//  Created by Pop Web on 14-5-14.
//  Copyright (c) 2014年 黄旺鑫. All rights reserved.
//

#import "AboutViewController.h"
//#import "UtilsMacro.h"

@interface AboutViewController ()
@property (weak, nonatomic) IBOutlet UILabel *labelOne;

@property (weak, nonatomic) IBOutlet UILabel *labelTwo;
@property (weak, nonatomic) IBOutlet UILabel *banBenLabel;

@property (weak, nonatomic) IBOutlet UILabel *labelThree;
@end

@implementation AboutViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    self.title = @"关于听闻";
    [self enableAutoBack];
//    self.automaticallyAdjustsScrollViewInsets = NO;
//    self.extendedLayoutIncludesOpaqueBars = NO;
//    [self.view setBackgroundColor:[UIColor whiteColor]];

    self.labelOne.preferredMaxLayoutWidth = IPHONE_W - 80;
    self.labelTwo.preferredMaxLayoutWidth = IPHONE_W - 80;
    self.labelThree.preferredMaxLayoutWidth = IPHONE_W - 80;
    self.labelThree.text = @"开发团队：泡果网络 \n合作邮箱：popwcn@163.com \n商务洽谈：QQ242111144 \n听闻QQ群：262732230";
    
    UIButton *bs = [UIButton buttonWithType:UIButtonTypeCustom];
    [bs setImage:[UIImage imageNamed:@"back"] forState:UIControlStateNormal];
    bs.accessibilityLabel = @"返回";
    bs.bounds = CGRectMake(0, 0, 9, 15);
    UIBarButtonItem *back = [[UIBarButtonItem alloc]initWithCustomView:bs];
    [bs addTarget:self action:@selector(popViewController) forControlEvents:UIControlEventTouchUpInside];
    self.navigationItem.leftBarButtonItem = back;
    _banBenLabel.text = [NSString stringWithFormat:@"%@ 正式版", [[[NSBundle mainBundle] infoDictionary] valueForKey:@"CFBundleShortVersionString"]];
    UISwipeGestureRecognizer *backG = [[UISwipeGestureRecognizer alloc]initWithTarget:self action:@selector(back)];
    [backG setDirection:UISwipeGestureRecognizerDirectionRight];
    [self.view addGestureRecognizer:backG];
    
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    self.hidesBottomBarWhenPushed = YES;
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - 返回首页
- (void)popViewController {
    
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)back{
    
    [self.navigationController popViewControllerAnimated:YES];
}

@end
