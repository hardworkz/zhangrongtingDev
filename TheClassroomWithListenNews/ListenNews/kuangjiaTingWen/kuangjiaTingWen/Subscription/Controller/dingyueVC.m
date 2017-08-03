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
#import "bofangVC.h"
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
    DefineWeakSelf;
    APPDELEGATE.dingyueSkipToPlayingVC = ^(NSString *pushNewsID){
        
        if (ExIsClassVCPlay && Exact_id != nil) {
            NSMutableDictionary *dict = [CommonCode readFromUserD:@"is_free_data"];
            ClassViewController *vc = [ClassViewController shareInstance];
            vc.jiemuDescription = dict[@"jiemuDescription"];
            vc.jiemuFan_num = dict[@"jiemuFan_num"];
            vc.jiemuID = dict[@"jiemuID"];
            vc.jiemuImages = dict[@"jiemuImages"];
            vc.jiemuIs_fan = dict[@"jiemuIs_fan"];
            vc.jiemuMessage_num = dict[@"jiemuMessage_num"];
            vc.jiemuName = dict[@"jiemuName"];
            vc.act_id = Exact_id;
            vc.listVC = self;
            [weakSelf.navigationController.navigationBar setHidden:YES];
            [weakSelf.navigationController pushViewController:vc animated:YES];
            return;
        }
        if ([pushNewsID isEqualToString:@"NO"]) {
            //上一次听过的新闻
            if ([ZRT_PlayerManager manager].currentSong) {
                [self.navigationController pushViewController:[NewPlayVC shareInstance] animated:YES];
            }
            else{
                //跳转上一次播放的新闻
                [self skipToLastNews];
            }
        }
        else{
            NSString *pushNewsID = [[NSUserDefaults standardUserDefaults]valueForKey:@"pushNews"];
            if ([[CommonCode readFromUserD:@"dangqianbofangxinwenID"] isEqualToString:pushNewsID]){
                if (![self.navigationController.topViewController isKindOfClass:[NewPlayVC class]]) {
                    [self.navigationController pushViewController:[NewPlayVC shareInstance] animated:YES];
                    if (![ZRT_PlayerManager manager].isPlaying) {
                        [[ZRT_PlayerManager manager] startPlay];
                    }
                }
                if (![ZRT_PlayerManager manager].isPlaying) {
                    [[ZRT_PlayerManager manager] startPlay];
                }
            }
            else{
                [weakSelf getPushNewsDetail];
            }
        }
    };
    
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
    
    //通知
    //播放下一条自动加载更多新闻信息通知
//    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(dingyuezidongjiazai:) name:@"dingyuebofangRightyaojiazaishujv" object:nil];
//    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(gaibianyanse:) name:@"gaibianyanse" object:nil];
//    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(dianjihougaibianyanse:) name:@"dianjihougaibiangezhongyanse" object:nil];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self.navigationController setNavigationBarHidden:NO animated:YES];
    if (APPDELEGATE.isLogin) {
        [self.tableView.mj_header beginRefreshing];
        APPDELEGATE.isLogin = NO;
    }
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [self.navigationController setNavigationBarHidden:NO animated:YES];
}


//- (void)dianjihougaibianyanse:(NSNotification *)notification {
//    [self.tableView reloadData];
//}
//
//- (void)gaibianyanse:(NSNotification *)notification {
//    [self.tableView reloadData];
//}

#pragma mark - UITableViewDelegate

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.infoArr.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *wodeJieMuIdentify = @"wodeJieMuIdentify";
    UITableViewCell *cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:wodeJieMuIdentify];
    if (!cell)
    {
        cell = [tableView dequeueReusableCellWithIdentifier:wodeJieMuIdentify];
    }
    
    UIImageView *imgV = [[UIImageView alloc]initWithFrame:CGRectMake(SCREEN_WIDTH - 125.0 / 375 * IPHONE_W, 19, 105.0 / 375 * IPHONE_W,   84.72 / 375 *IPHONE_W)];
    if (IS_IPAD) {
        [imgV setFrame:CGRectMake(SCREEN_WIDTH - 125.0 / 375 * IPHONE_W, 19, 105.0 / 375 * IPHONE_W, 70.0 / 375 *IPHONE_W)];
    }
    if ([NEWSSEMTPHOTOURL(self.infoArr[indexPath.row][@"smeta"])  rangeOfString:@"http"].location != NSNotFound){
        [imgV sd_setImageWithURL:[NSURL URLWithString:NEWSSEMTPHOTOURL(self.infoArr[indexPath.row][@"smeta"])] placeholderImage:[UIImage imageNamed:@"thumbnailsdefault"]];
    }else
    {
        NSString *str = USERPHOTOHTTPSTRINGZhuBo(NEWSSEMTPHOTOURL(self.infoArr[indexPath.row][@"smeta"]));
        [imgV sd_setImageWithURL:[NSURL URLWithString:str] placeholderImage:[UIImage imageNamed:@"thumbnailsdefault"]];
    }
    imgV.contentMode = UIViewContentModeScaleAspectFill;
    imgV.clipsToBounds = YES;
    
    [cell.contentView addSubview:imgV];
    
    UILabel *titleLab = [[UILabel alloc]initWithFrame:CGRectMake(20.0 / 375 * IPHONE_W, 16.0 / 667 * IPHONE_H , SCREEN_WIDTH - 155.0 / 375 * IPHONE_W, 21.0 / 667 *IPHONE_H)];
    titleLab.text = self.infoArr[indexPath.row][@"post_title"];
    titleLab.textColor = [[ZRT_PlayerManager manager] textColorFormID:self.infoArr[indexPath.row][@"id"]];
    titleLab.textAlignment = NSTextAlignmentLeft;
    titleLab.font = [UIFont boldSystemFontOfSize:17.0f];
    [cell.contentView addSubview:titleLab];
    [titleLab setNumberOfLines:3];
    titleLab.lineBreakMode = NSLineBreakByWordWrapping;
    CGSize size = [titleLab sizeThatFits:CGSizeMake(titleLab.frame.size.width, MAXFLOAT)];
    titleLab.frame = CGRectMake(titleLab.frame.origin.x, titleLab.frame.origin.y, titleLab.frame.size.width, size.height);
    
    if (IS_IPAD) {
        //正文
        UILabel *detailNews = [[UILabel alloc]initWithFrame:CGRectMake(20.0 / 375 * IPHONE_W, titleLab.frame.origin.y + titleLab.frame.size.height + 20.0 / 667 * SCREEN_HEIGHT, titleLab.frame.size.width, 21.0 / 667 *IPHONE_H)];
        detailNews.text = self.infoArr[indexPath.row][@"post_excerpt"];
        detailNews.textColor = gTextColorSub;
        detailNews.font = [UIFont systemFontOfSize:15.0f];
        [cell.contentView addSubview:detailNews];
    }
    //日期
    UILabel *riqiLab = [[UILabel alloc]initWithFrame:CGRectMake(20.0 / 375 * IPHONE_W, 86.0 / 667 *IPHONE_H, 135.0 / 375 * IPHONE_W, 21.0 / 667 *IPHONE_H)];
    NSDate *date = [NSDate dateFromString:self.infoArr[indexPath.row][@"post_modified"]];
    riqiLab.text = [date showTimeByTypeA];
    riqiLab.textColor = gTextColorSub;
    riqiLab.font = [UIFont systemFontOfSize:13.0f ];
    [cell.contentView addSubview:riqiLab];
    //大小
    UILabel *dataLab = [[UILabel alloc]initWithFrame:CGRectMake(SCREEN_WIDTH - 213.0 / 375 * IPHONE_W, 86.0 / 667 *IPHONE_H, 45.0 / 375 * IPHONE_W, 21.0 / 667 *IPHONE_H)];
    dataLab.text = [NSString stringWithFormat:@"%.1lf%@",[self.infoArr[indexPath.row][@"post_size"] intValue] / 1024.0 / 1024.0,@"M"];
    dataLab.textColor = gTextColorSub;
    dataLab.font = [UIFont systemFontOfSize:13.0f ];
    dataLab.textAlignment = NSTextAlignmentCenter;
    [cell.contentView addSubview:dataLab];
    //下载
    UIButton *download = [UIButton buttonWithType:UIButtonTypeCustom];
    [download setFrame:CGRectMake(CGRectGetMaxX(dataLab.frame), 86.0 / 667 *IPHONE_H, 30.0 / 667 *IPHONE_H, 30.0 / 667 *IPHONE_H)];
    [download setImage:[UIImage imageNamed:@"download_grey"] forState:UIControlStateNormal];
    [download setImageEdgeInsets:UIEdgeInsetsMake(0, 0, 10, 10)];
    [download setTag:(indexPath.row + 100)];
    [download addTarget:self action:@selector(downloadNewsAction:) forControlEvents:UIControlEventTouchUpInside];
    [cell.contentView addSubview:download];
    
    UIView *line = [[UIView alloc]initWithFrame:CGRectMake(20.0 / 375 * SCREEN_WIDTH, 119.0 / 667 * SCREEN_HEIGHT, SCREEN_WIDTH - 40.0 / 375 * SCREEN_WIDTH, 0.5)];
    [line setBackgroundColor:nMineNameColor];
    [cell.contentView addSubview:line];
    
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    
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
        [[NewPlayVC shareInstance] reloadInterface];
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
    return 120.0 / 667 * IPHONE_H;
}

#pragma mark - Utilities

- (void)downloadNewsAction:(UIButton *)sender {
    
    [SVProgressHUD showInfoWithStatus:@"开始下载"];
    [self performSelector:@selector(SVPDismiss) withObject:nil afterDelay:1.0];
    NSMutableDictionary *dic = self.infoArr[sender.tag - 100];
    dispatch_async(dispatch_get_main_queue(), ^{
        ProjiectDownLoadManager *manager = [ProjiectDownLoadManager defaultProjiectDownLoadManager];
        [manager insertSevaDownLoadArray:dic];
        
        WHC_Download *op = [[WHC_Download alloc]initStartDownloadWithURL:[NSURL URLWithString:dic[@"post_mp"]] savePath:manager.userDownLoadPath savefileName:[dic[@"post_mp"] stringByReplacingOccurrencesOfString:@"/" withString:@""] withObj:dic delegate:nil];
        [manager.downLoadQueue addOperation:op];
    });
}

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
/**
 根据推送ID获取新闻详情数据
 */
- (void)getPushNewsDetail{
    DefineWeakSelf;
    [NetWorkTool getpostinfoWithpost_id:[[NSUserDefaults standardUserDefaults]valueForKey:@"pushNews"] andpage:nil andlimit:nil sccess:^(NSDictionary *responseObject) {
        if ([responseObject[@"status"] integerValue] == 1) {
            weakSelf.pushNewsInfo = [responseObject[@"results"] mutableCopy];
            [NetWorkTool getAllActInfoListWithAccessToken:nil ac_id:weakSelf.pushNewsInfo[@"post_news"] keyword:nil andPage:nil andLimit:nil sccess:^(NSDictionary *responseObject) {
                if ([responseObject[@"status"] integerValue] == 1){
                    [weakSelf.pushNewsInfo setObject:[responseObject[@"results"] firstObject] forKey:@"post_act"];
                    [weakSelf presentPushNews];
                }
                else{
                    [SVProgressHUD showErrorWithStatus:responseObject[@"msg"]];
                }
            } failure:^(NSError *error) {
                //
                [SVProgressHUD showErrorWithStatus:@"网络请求失败"];
            }];
        }
        else{
            [SVProgressHUD showErrorWithStatus:responseObject[@"msg"]];
        }
        
    } failure:^(NSError *error) {
        [SVProgressHUD showErrorWithStatus:@"网络请求失败"];
        NSLog(@"%@",error);
    }];
}

/**
 通知消息点击跳转新闻详情界面播放
 */
- (void)presentPushNews
{
    [ZRT_PlayerManager manager].songList = @[self.pushNewsInfo];
    [ZRT_PlayerManager manager].currentSong = self.pushNewsInfo;
    //设置播放器播放内容类型
    [ZRT_PlayerManager manager].playType = ZRTPlayTypeNews;
    [NewPlayVC shareInstance].rewardType = RewardViewTypeNone;
    [ZRT_PlayerManager manager].channelType = ChannelTypeChannelNone;
    [[NewPlayVC shareInstance] playFromIndex:0];
    [self.navigationController.navigationBar setHidden:YES];
    [self.navigationController pushViewController:[NewPlayVC shareInstance] animated:YES];
}
/**
 点击中心按钮跳转上一次记录新闻详情界面播放
 */
- (void)skipToLastNews
{
    [ZRT_PlayerManager manager].songList = [CommonCode readFromUserD:NewPlayVC_PLAYLIST];
    [ZRT_PlayerManager manager].currentSong = [CommonCode readFromUserD:NewPlayVC_THELASTNEWSDATA];
    //设置播放器播放内容类型
    [ZRT_PlayerManager manager].playType = ZRTPlayTypeNews;
    [NewPlayVC shareInstance].rewardType = RewardViewTypeNone;
    [ZRT_PlayerManager manager].channelType = [[CommonCode readFromUserD:NewPlayVC_PLAY_CHANNEL] intValue];
    [[NewPlayVC shareInstance] playFromIndex:[[CommonCode readFromUserD:NewPlayVC_PLAY_INDEX] integerValue]];
    [self.navigationController.navigationBar setHidden:YES];
    [self.navigationController pushViewController:[NewPlayVC shareInstance] animated:YES];
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
