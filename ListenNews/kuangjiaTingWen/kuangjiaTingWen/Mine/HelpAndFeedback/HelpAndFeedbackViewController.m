//
//  HelpAndFeedbackViewController.m
//  kuangjiaTingWen
//
//  Created by Zhimi on 17/2/7.
//  Copyright © 2017年 贺楠. All rights reserved.
//

#import "HelpAndFeedbackViewController.h"
#import "BlogViewController.h"
#import "HelpCenterViewController.h"

@interface HelpAndFeedbackViewController ()<UITableViewDelegate,UITableViewDataSource>

@property (nonatomic, strong) UITableView *helpTableView;
@property (nonatomic, strong) NSMutableArray *dataSourceArr;

@end

@implementation HelpAndFeedbackViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self setUpData];
    [self setUpView];
}

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    [self.navigationController setNavigationBarHidden:NO animated:YES];
}

- (void)setUpData{
    
    _dataSourceArr = [NSMutableArray arrayWithArray:@[@[@"什么是听币，它有哪些用处?",@"什么是金币，它有哪些用处?",@"如何快速升级?"],@[@"意见反馈"]]];
    
}

- (void)setUpView{
    
    [self setTitle:@"帮助与反馈"];
    [self enableAutoBack];
    [self.view setBackgroundColor:[UIColor whiteColor]];
    [self.view addSubview:self.helpTableView];
    
    UISwipeGestureRecognizer *rightSwipe = [[UISwipeGestureRecognizer alloc]initWithTarget:self action:@selector(back)];
    [rightSwipe setDirection:UISwipeGestureRecognizerDirectionRight];
    [self.helpTableView addGestureRecognizer:rightSwipe];
    
}

- (void)back {
    [self.navigationController popViewControllerAnimated:YES];
}

#pragma mark - UITableViewDelegate

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    return 44.0;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    if (indexPath.section == 0 && indexPath.row == 0 ) {
        self.hidesBottomBarWhenPushed=YES;
        HelpCenterViewController *helpCenter = [HelpCenterViewController new];
        helpCenter.titleStr = [NSString stringWithFormat:@"%@.%@",@(indexPath.row + 1), _dataSourceArr[indexPath.section][indexPath.row]];
        helpCenter.descripeStr = @"·  听币是听闻APP中通过充值得到的流通货币，其与人民币兑换的比例为1：1。\n·  听币目前可以用来赞赏你喜爱的主播或者开通会员。\n·  每消耗一次听币可以获得5点经验值。";
        [self.navigationController pushViewController:helpCenter animated:YES];
        
    }
    else if (indexPath.section == 0 && indexPath.row == 1 ) {
        self.hidesBottomBarWhenPushed=YES;
        HelpCenterViewController *helpCenter = [HelpCenterViewController new];
         helpCenter.titleStr = [NSString stringWithFormat:@"%@.%@",@(indexPath.row + 1), _dataSourceArr[indexPath.section][indexPath.row]];
        helpCenter.descripeStr =  @"·  金币是通过听闻APP中各种日常使用或任务得到的另一种流通货币\n·  金币可以用来投给你喜爱的节目以提高该节目和其主播的排名，使其获得更多的关注\n·  金币可以通过签到，分享APP和分享节目获得。";
        [self.navigationController pushViewController:helpCenter animated:YES];
    }
    else if (indexPath.section == 0 && indexPath.row == 2 ) {
        self.hidesBottomBarWhenPushed=YES;
        HelpCenterViewController *helpCenter = [HelpCenterViewController new];
         helpCenter.titleStr = [NSString stringWithFormat:@"%@.%@",@(indexPath.row + 1), _dataSourceArr[indexPath.section][indexPath.row]];
        helpCenter.descripeStr =  @"·  听闻的等级提升很快的哦~只要每日登陆、签到、多多给主播投币、发表言论以及分享就好啦！\n·  除此之外，充值听币是最快的升级办法。而第一次修改头像和修改昵称会分别增加20经验值。分享APP要是第一次有50经验值的加成呢~赶快试试吧\n·  每消耗一次听币可以获得5点经验值。";
        [self.navigationController pushViewController:helpCenter animated:YES];
    }
    else if (indexPath.section == 1 && indexPath.row == 0 ) {
        self.hidesBottomBarWhenPushed=YES;
        BlogViewController *blogVC = [BlogViewController new];
        blogVC.isFeedbackVC = YES;
        [self.navigationController pushViewController:blogVC animated:YES];
    }
}

#pragma mark - UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    if (section == 0 ) {
        return 3;
    }
    else{
        return 1;
    }
}


- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 2;
}

- (nullable NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section{
    if (section == 0) {
        return @"帮助中心：";
    }
    else{
        return @"反馈：";
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    static NSString *wotouxiangcellIdentify = @"Identify";
    UITableViewCell *cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:wotouxiangcellIdentify];
    if (!cell){
        
        cell = [tableView dequeueReusableCellWithIdentifier:wotouxiangcellIdentify];
    }
    
    cell.textLabel.text = _dataSourceArr[indexPath.section][indexPath.row];
    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    [cell setSelectionStyle:UITableViewCellSelectionStyleNone];
    
    return cell;
}

- (UITableView *)helpTableView{
    if (_helpTableView == nil) {
        _helpTableView = [[UITableView alloc]initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_HEIGHT) style:UITableViewStylePlain];
        [_helpTableView setDelegate:self];
        [_helpTableView setDataSource:self];
        [_helpTableView setBackgroundColor:gSubColor];
        [_helpTableView setSeparatorStyle:UITableViewCellSeparatorStyleNone];
    }
    return _helpTableView;
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
