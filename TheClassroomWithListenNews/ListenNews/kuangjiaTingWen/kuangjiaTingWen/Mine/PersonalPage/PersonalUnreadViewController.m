//
//  PersonalUnreadViewController.m
//  kuangjiaTingWen
//
//  Created by Zhimi on 16/12/19.
//  Copyright © 2016年 贺楠. All rights reserved.
//

#import "PersonalUnreadViewController.h"
#import "PersonalUnreadTableViewCell.h"
#import "UnreadDetailViewController.h"

@interface PersonalUnreadViewController ()<UITableViewDelegate,UITableViewDataSource>

@property (strong, nonatomic) UITableView *unreadTableview;
@property (strong, nonatomic) NSMutableArray *unreadArray;

@end

@implementation PersonalUnreadViewController

- (void)viewDidLoad{
    [super viewDidLoad];
    [self setupData];
    [self setupView];
}

- (void)setupData{
    [self.unreadTableview registerNib:[UINib nibWithNibName:PersonalUnreadTableViewCellID bundle:nil] forCellReuseIdentifier:PersonalUnreadTableViewCellID];
    self.unreadArray = [NSMutableArray array];
    self.unreadArray = [[CommonCode readFromUserD:ADDCRITICISMNUMDATAKEY] mutableCopy];
    [self.unreadTableview reloadData];
    //获取系统当前的时间戳
    NSDate *date = [NSDate dateWithTimeIntervalSinceNow:0];
    NSTimeInterval time =[date timeIntervalSince1970];
    NSString *timeString = [NSString stringWithFormat:@"%f", time];
    [CommonCode writeToUserD:[ NSString stringWithFormat:@"%lld",[timeString longLongValue] ]andKey:PERSONALLASTREAD];
    
}

- (void)setupView{
    [self enableAutoBack];
    self.title = @"消息";
    self.navigationController.navigationBar.titleTextAttributes = @{NSForegroundColorAttributeName: [UIColor blackColor],
                                                                    NSFontAttributeName : [UIFont boldSystemFontOfSize:18]};
    UIButton *leftBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [leftBtn setBackgroundImage:[UIImage imageNamed:@"back"] forState:UIControlStateNormal];
    leftBtn.bounds = CGRectMake(0, 0, 9, 15);
    UIBarButtonItem *back = [[UIBarButtonItem alloc]initWithCustomView:leftBtn];
    [leftBtn addTarget:self action:@selector(back) forControlEvents:UIControlEventTouchUpInside];
    self.navigationItem.leftBarButtonItem = back;
    
    self.view.backgroundColor = [UIColor whiteColor];
    [self.view addSubview:self.unreadTableview];
//    self.unreadTableview.separatorStyle = UITableViewCellSeparatorStyleNone;
    
    UISwipeGestureRecognizer *rightSwipe = [[UISwipeGestureRecognizer alloc]initWithTarget:self action:@selector(back)];
    [rightSwipe setDirection:UISwipeGestureRecognizerDirectionRight];
    [self.unreadTableview addGestureRecognizer:rightSwipe];
    
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    self.hidesBottomBarWhenPushed = YES;
    [self.navigationController setNavigationBarHidden:NO animated:YES];
}

#pragma mark - UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return [self.unreadArray count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    PersonalUnreadTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:PersonalUnreadTableViewCellID];
    [cell updateCellWithUnreadMessageDic:self.unreadArray[indexPath.row] ];
    [cell setSelectionStyle:UITableViewCellSelectionStyleNone];
    return cell;
}

#pragma mark - UITableViewDelegate

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 66.0;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    
    //TODO:未读消息
    self.hidesBottomBarWhenPushed=YES;
    UnreadDetailViewController *unreadVC = [UnreadDetailViewController new];
    
    unreadVC.parentid =  self.unreadArray[indexPath.row][@"parentid"];
    unreadVC.path =  self.unreadArray[indexPath.row][@"path"];
    unreadVC.pageSource = 1;
    [self.navigationController pushViewController:unreadVC animated:YES];
    self.hidesBottomBarWhenPushed=NO;
}

- (void)back {
    [self.navigationController popViewControllerAnimated:YES];
}

#pragma mark - Getter

- (UITableView *)unreadTableview {
    if (!_unreadTableview) {
        _unreadTableview = [[UITableView alloc]initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_HEIGHT) style:UITableViewStylePlain];
        [_unreadTableview setDelegate:self];
        [_unreadTableview setDataSource:self];
        _unreadTableview.tableFooterView =  [UIView new];
    }
    return  _unreadTableview;
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
