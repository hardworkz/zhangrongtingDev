//
//  dingyueVC.m
//  kuangjiaTingWen
//
//  Created by 贺楠 on 16/6/3.
//  Copyright © 2016年 贺楠. All rights reserved.
//

#import "dingyueVC.h"
#import "UIImageView+WebCache.h"
#import "MJRefresh.h"
#import "jiemuLieBiaoVC.h"
//#import "UMSocialSnsService.h"
//#import "UMSocialSnsPlatformManager.h"
#import "cellRightBtn.h"
//#import "UMSocial.h"
//#import <WeiboSDK.h>
#import "WXApi.h"
#import <TencentOpenAPI/TencentOAuth.h>
#import "WeiboSDK.h"
#import "XWAlerLoginView.h"
#import "NSDate+TimeFormat.h"
#import "AppDelegate.h"
#import "ProjiectDownLoadManager.h"
#import "WHC_Download.h"
#import "LoginVC.h"
#import "LoginNavC.h"
#import "tianjiaGuanZhuVC.h"

@interface dingyueVC ()<UITableViewDataSource,UITableViewDelegate,UIScrollViewDelegate>
{
    int numberPage;
    NSIndexPath *quanjvIndexPath;
}
@property(strong,nonatomic)UITableView *tableView;
@property(strong,nonatomic)NSMutableArray *infoArr;
@property (strong, nonatomic) NSMutableDictionary *pushNewsInfo;
@property (strong, nonatomic) UIButton *tipBtn;;

@end

@implementation dingyueVC
- (UIButton *)tipBtn
{
    if (_tipBtn == nil) {
        NSMutableAttributedString *str = [[NSMutableAttributedString alloc] initWithString:@"当前为未登录状态，无法获取用户个人数据\n点击前往登录" attributes:@{NSForegroundColorAttributeName:[UIColor lightGrayColor]}];
        [str setAttributes:@{NSForegroundColorAttributeName:gMainColor} range:NSMakeRange(str.length - 6, 6)];
        _tipBtn = [[UIButton alloc] initWithFrame:CGRectMake(0, SCREEN_HEIGHT * 0.5 - 100, SCREEN_WIDTH, 40)];
        [_tipBtn setAttributedTitle:str forState:UIControlStateNormal];
        _tipBtn.titleLabel.textAlignment = NSTextAlignmentCenter;
        _tipBtn.titleLabel.font = gFontMain14;
        _tipBtn.titleLabel.numberOfLines = 0;
        [_tipBtn addTarget:self action:@selector(goToLogin)];
        [_tipBtn setTitleColor:gMainColor forState:UIControlStateNormal];
    }
    return _tipBtn;
}
- (void)viewDidLoad {
    [super viewDidLoad];
    
    numberPage = 1;
    //    self.edgesForExtendedLayout = UIRectEdgeNone;
    self.view.backgroundColor = [UIColor whiteColor];
    self.navigationItem.title = @"我的节目";
    self.navigationController.navigationBar.titleTextAttributes = @{NSForegroundColorAttributeName: [UIColor blackColor],
                                                                    NSFontAttributeName : [UIFont boldSystemFontOfSize:18]};
    if ([[CommonCode readFromUserD:@"wodejiemu"] isKindOfClass:[NSArray class]]){
        self.infoArr = [[NSMutableArray alloc]initWithArray:[CommonCode readFromUserD:@"wodejiemu"]];
        [self.tableView reloadData];
    }
    
    UIButton *bu = [UIButton buttonWithType:UIButtonTypeCustom];
    bu.bounds = CGRectMake(0, 0, 30, 30);
    [bu setBackgroundImage:[UIImage imageNamed:@"add_attention"] forState:UIControlStateNormal];
    bu.accessibilityLabel = @"添加关注";
    [bu addTarget:self action:@selector(addUser) forControlEvents:UIControlEventTouchUpInside];
    
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc]initWithCustomView:bu];
    
    [self.view addSubview:self.tableView];
    
    RegisterNotify(@"loginSccess", @selector(refreshList))
}
- (void)refreshList
{
    [self.tableView.mj_header beginRefreshing];
}
- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self.navigationController setNavigationBarHidden:NO animated:YES];
    if ([[CommonCode readFromUserD:@"isLogin"] boolValue] == NO) {
        [self.tableView.mj_header beginRefreshing];
        APPDELEGATE.isLogin = NO;
    }
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [self.navigationController setNavigationBarHidden:NO animated:YES];
}

#pragma mark - UITableViewDelegate

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.infoArr.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    NewsCell *cell = [NewsCell cellWithTableView:tableView];
    cell.dataDict = self.infoArr[indexPath.row];
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    //设置频道类型
    [ZRT_PlayerManager manager].channelType = ChannelTypeSubscriptionChannel;
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
    //判断是否是点击当前正在播放的新闻，如果是则直接跳转
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
        //调用播放对应Index方法
        [[NewPlayVC shareInstance] playFromIndex:ExcurrentNumber];
        //跳转播放界面
        [self.navigationController.navigationBar setHidden:YES];
        [self.navigationController pushViewController:[NewPlayVC shareInstance] animated:YES];
        [tableView reloadData];
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return IS_IPHONEX?120.0:120.0 / 667 * IPHONE_H;
}

#pragma mark - Utilities

- (void)SVPDismiss {
    [SVProgressHUD dismiss];
}

- (void)rightCellBtnAction:(UIButton *)sender {
    UITableViewCell *cell = (UITableViewCell *)[[sender superview] superview];
    UITableView *tableView = (UITableView *)[[cell superview] superview];
    NSIndexPath *indexPath = [tableView indexPathForCell:cell];
    
    if (quanjvIndexPath != nil)
    {
        if (quanjvIndexPath != indexPath)
        {
            UITableViewCell *yaoguanbiCell = [tableView cellForRowAtIndexPath:quanjvIndexPath];
            //        NSLog(@"%@",yaoguanbiCell.)
            UIButton *yaoguanbiBtn = (UIButton *)[yaoguanbiCell.contentView viewWithTag:quanjvIndexPath.row + 1000];
            yaoguanbiBtn.selected = NO;
            quanjvIndexPath = indexPath;
            [UIView animateWithDuration:0.3f animations:^{
                yaoguanbiCell.frame = CGRectMake(0, yaoguanbiCell.frame.origin.y, yaoguanbiCell.frame.size.width, yaoguanbiCell.frame.size.height);
            }];
            sender.selected = YES;
            [UIView animateWithDuration:0.3f animations:^{
                cell.frame = CGRectMake(-150.0 / 375 * IPHONE_W, cell.frame.origin.y, cell.frame.size.width, cell.frame.size.height);
            }];
        }else
        {
            if (sender.selected == NO)
            {
                sender.selected = YES;
                quanjvIndexPath = indexPath;
                [UIView animateWithDuration:0.3f animations:^{
                    cell.frame = CGRectMake(-150.0 / 375 * IPHONE_W, cell.frame.origin.y, cell.frame.size.width, cell.frame.size.height);
                }];
            }else
            {
                quanjvIndexPath = nil;
                sender.selected = NO;
                [UIView animateWithDuration:0.3f animations:^{
                    cell.frame = CGRectMake(0, cell.frame.origin.y, cell.frame.size.width, cell.frame.size.height);
                }];
            }
        }
    }else
    {
        quanjvIndexPath = indexPath;
        [UIView animateWithDuration:0.3f animations:^{
            cell.frame = CGRectMake(-150.0 / 375 * IPHONE_W, cell.frame.origin.y, cell.frame.size.width, cell.frame.size.height);
        }];
    }
    
}
- (void)dingyuezidongjiazai:(NSNotification *)notification
{
    numberPage ++;
    
    [NetWorkTool getPaoGuoSelfWoDeJieMuWithaccessToken:[DSE encryptUseDES:ExdangqianUser] andPage:[NSString stringWithFormat:@"%d",numberPage] andLimit:@"10" sccess:^(NSDictionary *responseObject) {
        [self.tableView.mj_footer endRefreshing];
        if ([responseObject[@"results"] isKindOfClass:[NSArray class]])
        {
            NSArray *array = responseObject[@"results"];
            [self.infoArr addObjectsFromArray:array];
            [CommonCode writeToUserD:self.infoArr andKey:@"zhuyeliebiao"];
            [[NSNotificationCenter defaultCenter] postNotificationName:@"dingyuejiazaichenggong" object:nil];
            
            if (array.count < 10) {
                [self.tableView.mj_footer endRefreshingWithNoMoreData];
            }
        }
        [self.tableView reloadData];
    } failure:^(NSError *error) {
        NSLog(@"error = %@",error);
        [self.tableView.mj_footer endRefreshing];
    }];
}
- (void)addUser {
    if ([[CommonCode readFromUserD:@"isLogin"] boolValue] == YES)
    {
        jiemuLieBiaoVC *nextVC = [[jiemuLieBiaoVC alloc]init];
        if (![self.infoArr isKindOfClass:[NSArray class]]){
            nextVC.lastInfoArr = [NSMutableArray array];
        }
        else{
            nextVC.lastInfoArr = [NSMutableArray arrayWithArray:self.infoArr];
        }
        self.hidesBottomBarWhenPushed=YES;
        [self.navigationController pushViewController:nextVC animated:YES];
        self.hidesBottomBarWhenPushed=NO;
    }else{
        XWAlerLoginView *alert = [[XWAlerLoginView alloc] initWithTitle:@"请先前往登录"];
        [alert show];
    }
}
- (void)refreshData{
    if ([[CommonCode readFromUserD:@"isLogin"] boolValue] == YES){
        numberPage = 1;
        DefineWeakSelf;
        [NetWorkTool getPaoGuoSelfWoDeJieMuWithaccessToken:[DSE encryptUseDES:ExdangqianUser] andPage:@"1" andLimit:@"10" sccess:^(NSDictionary *responseObject) {
            if ([responseObject[@"results"] isKindOfClass:[NSArray class]]){
                [self.infoArr removeAllObjects];
                NSArray *array = responseObject[@"results"];
                [self.infoArr addObjectsFromArray:array];
                
                if ([ZRT_PlayerManager manager].channelType == ChannelTypeSubscriptionChannel) {
                    [ZRT_PlayerManager manager].songList = self.infoArr;
                }
                [CommonCode writeToUserD:self.infoArr andKey:@"wodejiemu"];
                [self.tipBtn removeFromSuperview];
            }
            else{
                [weakSelf followFirst];
                [self.infoArr removeAllObjects];
            }
            [self.tableView reloadData];
            [self.tableView.mj_header endRefreshing];
            [self.tableView.mj_footer endRefreshing];
        } failure:^(NSError *error) {
            NSLog(@"error = %@",error);
            [self.tableView.mj_header endRefreshing];
        }];
    }else{//清空数据，设置空数据提醒
        [self.infoArr removeAllObjects];
        [self.tableView reloadData];
        [self.tableView.mj_header endRefreshing];
        [self.tableView.mj_footer endRefreshing];
        [self.tableView addSubview:self.tipBtn];
    }
}
//弹出登录页面
- (void)goToLogin
{
    if ([[CommonCode readFromUserD:@"isLogin"] boolValue] == NO){
        LoginVC *loginFriVC = [LoginVC new];
        loginFriVC.isSubscription = YES;
        LoginNavC *loginNavC = [[LoginNavC alloc]initWithRootViewController:loginFriVC];
        [loginNavC.navigationBar setBackgroundColor:[UIColor whiteColor]];
        loginNavC.navigationBar.tintColor = [UIColor blackColor];
        [self presentViewController:loginNavC animated:YES completion:nil];
    }
}
- (void)shanglajiazai
{
    if ([[CommonCode readFromUserD:@"isLogin"] boolValue] == YES)
    {
        numberPage++;
        [NetWorkTool getPaoGuoSelfWoDeJieMuWithaccessToken:[DSE encryptUseDES:ExdangqianUser] andPage:[NSString stringWithFormat:@"%d",numberPage] andLimit:@"10" sccess:^(NSDictionary *responseObject) {
            [self.tableView.mj_footer endRefreshing];
            if ([responseObject[@"results"] isKindOfClass:[NSArray class]])
            {
                NSArray *array = responseObject[@"results"];
                [self.infoArr addObjectsFromArray:array];
                if ([ZRT_PlayerManager manager].channelType == ChannelTypeSubscriptionChannel) {
                    [ZRT_PlayerManager manager].songList = self.infoArr;
                }
                if (array.count < 10) {
                    [self.tableView.mj_footer endRefreshingWithNoMoreData];
                }
            }
            [self.tableView reloadData];
        } failure:^(NSError *error) {
            NSLog(@"error = %@",error);
            [self.tableView.mj_footer endRefreshing];
        }];
    }else{
        
    }
}

- (void)followFirst {
    
    UIAlertController *qingshuruyonghuming = [UIAlertController alertControllerWithTitle:@"温馨提示\n 您还没订阅节目，现在就去关注～" message:nil preferredStyle:UIAlertControllerStyleAlert];
    qingshuruyonghuming.accessibilityLabel = @"温馨提示\n 您还没订阅节目，现在就去关注～";
    [qingshuruyonghuming addAction:[UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
    }]];
    [qingshuruyonghuming addAction:[UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        //        [self addUser];
        //TODO:跳到发现
        [[NSNotificationCenter defaultCenter] postNotificationName:@"dingyueSkipTofaxianVC" object:nil];
        
    }]];
    
    [self presentViewController:qingshuruyonghuming animated:YES completion:nil];
}
#pragma mark --- 懒加载
- (UITableView *)tableView
{
    if (!_tableView)
    {
        _tableView = [[UITableView alloc]initWithFrame:CGRectMake(0, 0, IPHONE_W, IPHONE_H - 64) style:UITableViewStylePlain];
        _tableView.delegate = self;
        _tableView.dataSource = self;
        [_tableView setSeparatorStyle:UITableViewCellSeparatorStyleNone];
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

- (NSMutableDictionary *)pushNewsInfo {
    if (!_pushNewsInfo) {
        _pushNewsInfo = [NSMutableDictionary new];
    }
    return _pushNewsInfo;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
@end
