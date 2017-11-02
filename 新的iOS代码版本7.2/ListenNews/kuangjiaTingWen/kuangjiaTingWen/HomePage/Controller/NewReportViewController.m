//
//  NewReportViewController.m
//  kuangjiaTingWen
//
//  Created by Zhimi on 16/9/19.
//  Copyright © 2016年 贺楠. All rights reserved.
//

#import "NewReportViewController.h"
#import "MJRefresh.h"
#import "NSDate+TimeFormat.h"
#import "ProjiectDownLoadManager.h"
#import "WHC_Download.h"

@interface NewReportViewController ()<UITableViewDataSource,UITableViewDelegate,UIScrollViewDelegate>
{
    int numberPage;
    NSIndexPath *quanjvIndexPath;
}
@property(strong,nonatomic)UITableView *tableView;
@property(strong,nonatomic)NSMutableArray *infoArr;

@end

@implementation NewReportViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setupData];
    [self setupView];
    
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self.navigationController setNavigationBarHidden:NO];
    self.hidesBottomBarWhenPushed = YES;
}

- (void)setupData {
    [self enableAutoBack];
}

- (void)setupView {
    numberPage = 1;
    self.edgesForExtendedLayout = UIRectEdgeNone;
    self.view.backgroundColor = [UIColor whiteColor];
    self.title = (self.NewsTpye != nil) ? self.NewsTpye : @"新闻播报";
    self.navigationController.navigationBar.titleTextAttributes = @{NSForegroundColorAttributeName: [UIColor blackColor],
                                                                    NSFontAttributeName : [UIFont boldSystemFontOfSize:18]};
    UIButton *leftBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [leftBtn setBackgroundImage:[UIImage imageNamed:@"title_ic_back"] forState:UIControlStateNormal];
    leftBtn.bounds = CGRectMake(0, 0, 9, 15);
    leftBtn.accessibilityLabel = @"返回";
    UIBarButtonItem *back = [[UIBarButtonItem alloc]initWithCustomView:leftBtn];
    [leftBtn addTarget:self action:@selector(back) forControlEvents:UIControlEventTouchUpInside];
    self.navigationItem.leftBarButtonItem = back;
    
    UISwipeGestureRecognizer *rightSwipe = [[UISwipeGestureRecognizer alloc]initWithTarget:self action:@selector(back)];
    [rightSwipe setDirection:UISwipeGestureRecognizerDirectionRight];
    [self.tableView addGestureRecognizer:rightSwipe];
    [self.view addSubview:self.tableView];
    
    [self.tableView.mj_header beginRefreshing];
    self.tableView.mj_header.automaticallyChangeAlpha = YES;
    //通知
    //播放下一条自动加载更多新闻信息通知
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(gaibianyanse:) name:@"gaibianyanse" object:nil];
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(dianjihougaibianyanse:) name:@"dianjihougaibiangezhongyanse" object:nil];
}

- (void)dianjihougaibianyanse:(NSNotification *)notification {
    [self.tableView reloadData];
}

- (void)gaibianyanse:(NSNotification *)notification {
    [self.tableView reloadData];
}

- (void)back {
    
    [self.navigationController popViewControllerAnimated:YES];
}

#pragma mark - UITableViewDelegate

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.infoArr.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    NewsCell *cell = [NewsCell cellWithTableView:tableView];
    if ([self.infoArr count]) {
        cell.dataDict = self.infoArr[indexPath.row];
    }
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    //设置播放器播放内容类型
    [ZRT_PlayerManager manager].playType = ZRTPlayTypeNews;
    //设置播放器播放完成自动加载更多block
    DefineWeakSelf;
    [ZRT_PlayerManager manager].loadMoreList = ^(NSInteger currentSongIndex) {
        [weakSelf shanglajiazai];
    };
    //播放内容切换后刷新对应的播放列表
    [ZRT_PlayerManager manager].playReloadList = ^(NSInteger currentSongIndex) {
        [weakSelf.tableView reloadData];
    };
    //设置播放界面打赏view的状态
    [NewPlayVC shareInstance].rewardType = RewardViewTypeNone;
    if ([[CommonCode readFromUserD:@"dangqianbofangxinwenID"] isEqualToString:self.infoArr[indexPath.row][@"id"]]){
        
        //设置播放器播放数组
        [ZRT_PlayerManager manager].songList = self.infoArr;
//        [[NewPlayVC shareInstance] reloadInterface];
        [self.navigationController.navigationBar setHidden:YES];
        [self.navigationController pushViewController:[NewPlayVC shareInstance] animated:YES];
    }
    else{
        //设置播放器播放数组
        [ZRT_PlayerManager manager].songList = self.infoArr;
        //设置新闻ID
        [NewPlayVC shareInstance].post_id = self.infoArr[indexPath.row][@"id"];
        //保存当前播放新闻Index
        ExcurrentNumber = (int)indexPath.row;
        //播放频道
        [ZRT_PlayerManager manager].channelType = ChannelTypeHomeChannelClassify;
        //调用播放对应Index方法
        [[NewPlayVC shareInstance] playFromIndex:ExcurrentNumber];
        //跳转播放界面
        [self.navigationController.navigationBar setHidden:YES];
        [self.navigationController pushViewController:[NewPlayVC shareInstance] animated:YES];
        [self.tableView reloadData];
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 120.0 / 667 * SCREEN_HEIGHT;
}

#pragma mark - Utilities

- (void)SVPDismiss {
    [SVProgressHUD dismiss];
}

- (void)refreshData
{
    numberPage = 1;
    NSLog(@"下拉刷新");
    
    DefineWeakSelf;
    [NetWorkTool postPaoGuoFenLeiZhuBoBoBaoXinWenWithterm_id:self.term_id andpage:@"1" andlimit:@"10" andaccessToken:AvatarAccessToken sccess:^(NSDictionary *responseObject) {
        if ([responseObject[results] isKindOfClass:[NSArray class]]){
            [weakSelf.infoArr removeAllObjects];
            [weakSelf.infoArr addObjectsFromArray:responseObject[results]];
        }
        [weakSelf.tableView reloadData];
        [weakSelf.tableView.mj_header endRefreshing];
    } failure:^(NSError *error) {
        NSLog(@"error = %@",error);
        [weakSelf.tableView.mj_header endRefreshing];
    }];
}

- (void)shanglajiazai
{
    numberPage++;
    DefineWeakSelf;
    [NetWorkTool postPaoGuoFenLeiZhuBoBoBaoXinWenWithterm_id:self.term_id andpage:[NSString stringWithFormat:@"%d",numberPage] andlimit:@"10" andaccessToken:AvatarAccessToken sccess:^(NSDictionary *responseObject) {
        [weakSelf.tableView.mj_footer endRefreshing];
        if ([responseObject[results] isKindOfClass:[NSArray class]]){
            NSArray *array = responseObject[results];
            [weakSelf.infoArr addObjectsFromArray:array];
            
            if ([ZRT_PlayerManager manager].channelType == ChannelTypeHomeChannelClassify) {
                [ZRT_PlayerManager manager].songList = weakSelf.infoArr;
            }
            if (array.count < 10) {
                [weakSelf.tableView.mj_footer endRefreshingWithNoMoreData];
            }
        }
        [weakSelf.tableView reloadData];
    } failure:^(NSError *error) {
        NSLog(@"error = %@",error);
        [weakSelf.tableView.mj_footer endRefreshing];
    }];
}

#pragma mark --- 懒加载
- (UITableView *)tableView
{
    if (!_tableView)
    {
        _tableView = [[UITableView alloc]initWithFrame:CGRectMake(0, 0, IPHONE_W, IPHONE_H - 64) style:UITableViewStylePlain];
        _tableView.delegate = self;
        _tableView.dataSource = self;
        _tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
        _tableView.tableFooterView = [UIView new];
        _tableView.mj_header = [MJRefreshNormalHeader headerWithRefreshingBlock:^{
            [self refreshData];
        }];
        _tableView.mj_footer = [MJRefreshAutoStateFooter footerWithRefreshingBlock:^{
            [self shanglajiazai];
        }];
        _tableView.userInteractionEnabled = YES;
    }
    return _tableView;
}

- (NSMutableArray *)infoArr
{
    if (!_infoArr)
    {
        _infoArr = [NSMutableArray array];
    }
    return _infoArr;
}
@end
