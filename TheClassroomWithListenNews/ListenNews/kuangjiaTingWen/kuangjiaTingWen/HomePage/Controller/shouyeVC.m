//
//  shouyeVC.m
//  kuangjiaTingWen
//
//  Created by 贺楠 on 16/6/3.
//  Copyright © 2016年 贺楠. All rights reserved.
//

#import "shouyeVC.h"
//#import "ZZIConView.h"
#import "UIImageView+WebCache.h"
#import "MJRefresh.h"
#import "bofangVC.h"
//#import "UMSocialSnsService.h"
//#import "UMSocialSnsPlatformManager.h"
#import "paixuColleCtionViewCell.h"
#import "TBCircleScrollView.h"
#import "lunboxiangqingVC.h"
#import "cellRightBtn.h"
#import "guanggaoVC.h"
#import "WXApi.h"
#import <TencentOpenAPI/TencentOAuth.h>
#import "WeiboSDK.h"
#import "XWAlerLoginView.h"
#import "NSDate+TimeFormat.h"
#import "AppDelegate.h"
#import "VoteViewController.h"
#import "ProjiectDownLoadManager.h"
#import "WHC_Download.h"
#import "faxianGengDuoVC.h"
#import "NewReportViewController.h"
#import "CitySelectedViewController.h"
#import "AppDelegate.h"
#import "UIView+tap.h"

#define NUM_OF_COLUMN 4 // 4列图标
@interface shouyeVC ()<UITableViewDataSource,UITableViewDelegate,UIScrollViewDelegate,UICollectionViewDataSource,UICollectionViewDelegate,UICollectionViewDelegateFlowLayout>
{
    //6.21_1
    NSMutableArray *topNameArr;
    NSIndexPath *DangqianIndexPath;
    UIView *qiehuanlanmuView;
    UIView *qiehuanbeijingView;
    NSMutableArray *TouListArr;   //主体新闻数组.
    UIScrollView *scroll;
    
    UIImageView *jiahao;
    BOOL isJiaHaoZheng;
    NSString *xuyaoJiaZaidePinDaoID;
    NSInteger xuyaoJiaZaidePinDaoTag;
    NSIndexPath *quanjvIndexPath;
    
    NSMutableArray *topCollectionArr;
    NSMutableArray *downCollectionArr;
    UIView *shanchuBgV;
    UIView *tianjiaBgV;
    
    NSMutableArray *tableViewArr;
    
    UITableView *dangqianTableView;
    
    NSString *dangqianxuyaoJiaZaiDeTableViewType;
    UITableView *dangqianbofangTable;
}

@property(strong,nonatomic)UITableView *topTableView;
@property (nonatomic) NSMutableArray *iconViewArray; // 存放图标对象iconView
//排序cellectionV
@property(strong,nonatomic)UICollectionView *topCollectionV;
@property(strong,nonatomic)UICollectionView *downCollectionV;

@property (strong, nonatomic) NSArray *tableViewDataArr;
@property (strong, nonatomic) NSMutableDictionary *pushNewsInfo;
@property (strong, nonatomic) NSMutableArray *slideADResult;
@property (strong, nonatomic) NSMutableArray *ztADResult;

@end

@implementation shouyeVC

- (void)viewDidLoad {
    [super viewDidLoad];
    
    //这里是启动app时广告  
    [self getStartAD];
//    DefineWeakSelf;
//    APPDELEGATE.shouyeSkipToPlayingVC = ^ (NSString *pushNewsID){
//        if ([pushNewsID isEqualToString:@"NO"]) {
//            //上一次听过的新闻
//            if (ExIsKaiShiBoFang) {
//                self.hidesBottomBarWhenPushed = YES;
//                [self.navigationController pushViewController:[bofangVC shareInstance] animated:YES];
//                self.hidesBottomBarWhenPushed = NO;
//            }
//            else{
//                //跳转上一次播放的新闻
//                [self skipToLastNews];
//            }
//        }
//        else{
//            NSString *pushNewsID = [[NSUserDefaults standardUserDefaults]valueForKey:@"pushNews"];
//            [[NSUserDefaults standardUserDefaults] synchronize];
//            if ([[CommonCode readFromUserD:@"dangqianbofangxinwenID"] isEqualToString:pushNewsID]){
//                NSString *isPlayingVC = [CommonCode readFromUserD:@"isPlayingVC"];
//                if ([isPlayingVC isEqualToString:@"YES"]) {
//                    
//                }
//                else{
//                    self.hidesBottomBarWhenPushed = YES;
//                    [self.navigationController.navigationBar setHidden:YES];
//                    [self.navigationController pushViewController:[bofangVC shareInstance] animated:YES];
//                    self.hidesBottomBarWhenPushed = NO;
//                }
//                if ([bofangVC shareInstance].isPlay) {
//                    
//                }
//                else{
//                    [[bofangVC shareInstance] doplay2];
//                }
//            }
//            else{
//               [weakSelf getPushNewsDetail];
//            }
//            
//        }
//    };
    
    dangqianTableView = nil;
    
    isJiaHaoZheng = YES;
    
    self.iconViewArray = [NSMutableArray array];
    
    tableViewArr = [NSMutableArray array];
    UIView *view = [[UIView alloc]initWithFrame:CGRectMake((SCREEN_WIDTH - 54) / 2, 35, 54, 25)];
    view.backgroundColor = [UIColor whiteColor];
    view.userInteractionEnabled = YES;
    UIImageView *logo = [[UIImageView alloc]initWithFrame:CGRectMake(0, 0, 54, 25)];
    [logo setImage:[UIImage imageNamed:@"home_logo"]];
    [view addSubview:logo];
    self.view.backgroundColor = [UIColor whiteColor];
    self.navigationItem.titleView = view;
    self.navigationController.navigationBarHidden=NO;
    //设置一张透明图片遮盖导航栏底下的黑色线条
    [self.navigationController.navigationBar setBackgroundImage:[UIImage imageNamed:@"shadow"]
                       forBarPosition:UIBarPositionAny
                           barMetrics:UIBarMetricsDefault];
    [self.navigationController.navigationBar setShadowImage:[UIImage new]];
    
    Exterm_id = @"1";
    if ([[CommonCode readFromUserD:@"topNameArr"] isKindOfClass:[NSArray class]]){
        topNameArr = [NSMutableArray arrayWithArray:[CommonCode readFromUserD:@"topNameArr"]];
    }
    else{
        
        [NetWorkTool getPaoGuoFenLeiLieBiaoWithWhateverSomething:@"q" sccess:^(NSDictionary *responseObject) {
            NSLog(@"%@",responseObject[@"results"]);
            if ([responseObject[@"results"] isKindOfClass:[NSArray class]]) {
                
                NSArray *ternList = responseObject[@"results"];
                [CommonCode writeToUserD:ternList andKey:@"commonListArr"];
                
                topNameArr = [NSMutableArray new];
                for (int i = 0 ; i < ternList.count; i++) {
                    //
                    NSMutableDictionary *dic = [NSMutableDictionary new];
                    [dic setObject:ternList[i][@"type"] forKey:@"type"];
                    [dic setObject:ternList[i][@"numberkey"] forKey:@"numberkey"];
                    [dic setObject:[NSString stringWithFormat:@"%d",i] forKey:@"weizhi"];
                    [dic setObject:ternList[i][@"parent"] forKey:@"parent"];
                    [topNameArr addObject:dic];
                }
                tableViewArr = [NSMutableArray array];
                [CommonCode writeToUserD:topNameArr andKey:@"topNameArr"];
                [CommonCode writeToUserD:@(topNameArr.count) andKey:@"topNameArr.count"];
                [self setUpView];
            }
            else{
                topNameArr = [NSMutableArray arrayWithArray:
                              @[[NSMutableDictionary dictionaryWithDictionary:@{@"type":@"头条",@"numberkey":@"1",@"weizhi":@"0",@"parent":@"0"}],
                                [NSMutableDictionary dictionaryWithDictionary:@{@"type":@"时政",@"numberkey":@"14",@"weizhi":@"1",@"parent":@"0"}],
                                [NSMutableDictionary dictionaryWithDictionary:@{@"type":@"国际",@"numberkey":@"8",@"weizhi":@"2",@"parent":@"0"}],
                                [NSMutableDictionary dictionaryWithDictionary:@{@"type":@"文娱",@"numberkey":@"4",@"weizhi":@"3",@"parent":@"0"}],
                                [NSMutableDictionary dictionaryWithDictionary:@{@"type":@"干货",@"numberkey":@"18",@"weizhi":@"4",@"parent":@"0"}],
                                [NSMutableDictionary dictionaryWithDictionary:@{@"type":@"财经",@"numberkey":@"6",@"weizhi":@"5",@"parent":@"0"}],
                                [NSMutableDictionary dictionaryWithDictionary:@{@"type":@"科技",@"numberkey":@"7",@"weizhi":@"6",@"parent":@"0"}]
                                ]];
                tableViewArr = [NSMutableArray array];
                [CommonCode writeToUserD:topNameArr andKey:@"topNameArr"];
                [CommonCode writeToUserD:@(topNameArr.count) andKey:@"topNameArr.count"];
                [self setUpView];
            }
        } failure:^(NSError *error) {
            topNameArr = [NSMutableArray arrayWithArray:
                          @[[NSMutableDictionary dictionaryWithDictionary:@{@"type":@"头条",@"numberkey":@"1",@"weizhi":@"0",@"parent":@"0"}],
                            [NSMutableDictionary dictionaryWithDictionary:@{@"type":@"时政",@"numberkey":@"14",@"weizhi":@"1",@"parent":@"0"}],
                            [NSMutableDictionary dictionaryWithDictionary:@{@"type":@"国际",@"numberkey":@"8",@"weizhi":@"2",@"parent":@"0"}],
                            [NSMutableDictionary dictionaryWithDictionary:@{@"type":@"文娱",@"numberkey":@"4",@"weizhi":@"3",@"parent":@"0"}],
                            [NSMutableDictionary dictionaryWithDictionary:@{@"type":@"干货",@"numberkey":@"18",@"weizhi":@"4",@"parent":@"0"}],
                            [NSMutableDictionary dictionaryWithDictionary:@{@"type":@"财经",@"numberkey":@"6",@"weizhi":@"5",@"parent":@"0"}],
                            [NSMutableDictionary dictionaryWithDictionary:@{@"type":@"科技",@"numberkey":@"7",@"weizhi":@"6",@"parent":@"0"}]
                            ]];
            tableViewArr = [NSMutableArray array];
            [CommonCode writeToUserD:topNameArr andKey:@"topNameArr"];
            [CommonCode writeToUserD:@(topNameArr.count) andKey:@"topNameArr.count"];
            [self setUpView];
        }];
    }
    if (topNameArr == nil) {
        topNameArr = [NSMutableArray arrayWithArray:
                      @[[NSMutableDictionary dictionaryWithDictionary:@{@"type":@"头条",@"numberkey":@"1",@"weizhi":@"0",@"parent":@"0"}],
                        [NSMutableDictionary dictionaryWithDictionary:@{@"type":@"时政",@"numberkey":@"14",@"weizhi":@"1",@"parent":@"0"}],
                        [NSMutableDictionary dictionaryWithDictionary:@{@"type":@"国际",@"numberkey":@"8",@"weizhi":@"2",@"parent":@"0"}],
                        [NSMutableDictionary dictionaryWithDictionary:@{@"type":@"文娱",@"numberkey":@"4",@"weizhi":@"3",@"parent":@"0"}],
                        [NSMutableDictionary dictionaryWithDictionary:@{@"type":@"干货",@"numberkey":@"18",@"weizhi":@"4",@"parent":@"0"}],
                        [NSMutableDictionary dictionaryWithDictionary:@{@"type":@"财经",@"numberkey":@"6",@"weizhi":@"5",@"parent":@"0"}],
                        [NSMutableDictionary dictionaryWithDictionary:@{@"type":@"科技",@"numberkey":@"7",@"weizhi":@"6",@"parent":@"0"}]
                        ]];
    }

    [CommonCode writeToUserD:topNameArr andKey:@"topNameArr"];
    [CommonCode writeToUserD:@(topNameArr.count) andKey:@"topNameArr.count"];
    
//    [NetWorkTool getPaoGuoFenLeiLieBiaoWithWhateverSomething:@"q" sccess:^(NSDictionary *responseObject) {
//        if ([responseObject[@"results"] isKindOfClass:[NSArray class]])
//        {
//            NSMutableArray *commonListArr = [NSMutableArray arrayWithArray:responseObject[@"results"]];
//            [CommonCode writeToUserD:commonListArr andKey:@"commonListArr"];
//        }
//    } failure:^(NSError *error) {
//        NSLog(@"error = %@",error);
//    }];
    
    [self setUpView];
    
    //通知
    //播放下一条自动加载更多新闻信息通知
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(zidongjiazai:) name:@"bofangRightyaojiazaishujv" object:nil];
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(lunboxiangqingVCAction:) name:@"lunboxiangqingVCAction" object:nil];
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(gaibianyanse:) name:@"gaibianyanse" object:nil];
     [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(selectedLocalCity:) name:@"selectedCity" object:nil];
    
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self.navigationController setNavigationBarHidden:NO animated:YES];
    [self.navigationController.navigationBar setTranslucent:YES];
}

- (void)setUpView{
    
    //TODO:判断之前的app版本频道管理缓存的数据
    NSArray *toparr;
    if ([[CommonCode readFromUserD:@"topCollectionArr"] isKindOfClass:[NSArray class]]){
        BOOL isUpdate = [[CommonCode readFromUserD:@"updateTopCollectionArr"]boolValue];
        if (isUpdate) {
           toparr = [NSArray arrayWithArray:[CommonCode readFromUserD:@"topCollectionArr"]];
        }
        else{
            [CommonCode writeToUserD:@(YES) andKey:@"updateTopCollectionArr"];
            toparr = [NSArray array];
        }
    }
    else{
        toparr = [NSArray array];
    }
    if (toparr.count == 0){
        topCollectionArr = [NSMutableArray arrayWithArray:topNameArr];
        [self.topCollectionV reloadData];
    }
    else{
        topCollectionArr = [NSMutableArray arrayWithArray:[CommonCode readFromUserD:@"topCollectionArr"]];
        [self.topCollectionV reloadData];
    }
    NSArray *downarr;
    if ([[CommonCode readFromUserD:@"downCollectionArr"] isKindOfClass:[NSArray class]]){
        BOOL isUpdate = [[CommonCode readFromUserD:@"updateDownCollectionArr"]boolValue];
        if (isUpdate) {
            downarr = [NSArray arrayWithArray:[CommonCode readFromUserD:@"downCollectionArr"]];
        }
        else{
            [CommonCode writeToUserD:@(YES) andKey:@"updateDownCollectionArr"];
            downarr = [NSArray array];
        }
    }
    else{
        downarr = [NSArray array];
    }
    if (downarr.count == 0){
        downCollectionArr = [NSMutableArray array];
        [self.downCollectionV reloadData];
    }
    else{
        downCollectionArr = [NSMutableArray arrayWithArray:[CommonCode readFromUserD:@"downCollectionArr"]];
        [self.downCollectionV reloadData];
    }
    [scroll removeFromSuperview];
    scroll = [[UIScrollView alloc]initWithFrame:CGRectMake(0, 64 + 44, IPHONE_W, IPHONE_H - 64 - 44)];
    scroll.delegate = self;
    scroll.pagingEnabled = YES;
    scroll.scrollsToTop = NO;
    scroll.bounces = NO;
    scroll.contentSize = CGSizeMake(IPHONE_W*topCollectionArr.count, IPHONE_H - 49 - 64);
    scroll.tag = -1;
    tableViewArr = [NSMutableArray array];
    
    for (int i=0; i<topNameArr.count; i++) {
        UITableView *tableView = [[UITableView alloc]initWithFrame:CGRectMake(IPHONE_W * [topNameArr[i][@"weizhi"] intValue], 0, IPHONE_W, IPHONE_H - 49 - 64 - 44) style:UITableViewStylePlain];
        tableView.delegate = self;
        tableView.dataSource = self;
        [tableView setSeparatorStyle:UITableViewCellSeparatorStyleNone];
        tableView.tag = i + 10;
        if (i != 0){
            tableView.scrollsToTop = NO;
        }
        [scroll addSubview:tableView];
        
        tableView.mj_header = [MJRefreshNormalHeader headerWithRefreshingBlock:^{
            topNameArr = [[CommonCode readFromUserD:@"topNameArr"]mutableCopy];
            [self refreshData:topNameArr[i][@"numberkey"] andPinDaoName:topNameArr[i][@"type"] andTableView:tableView];
        }];
        tableView.mj_footer = [MJRefreshAutoStateFooter footerWithRefreshingBlock:^{
            topNameArr = [[CommonCode readFromUserD:@"topNameArr"]mutableCopy];
            [self shanglajiazai:topNameArr[i][@"numberkey"] andtableView:tableView andTableName:topNameArr[i][@"type"]];
        }];
        [CommonCode writeToUserD:[NSString stringWithFormat:@"1"] andKey:[NSString stringWithFormat:@"page%@",topNameArr[i][@"type"]]];
        if (i == 0 ) {
            [tableView.mj_header beginRefreshing];
            dangqianbofangTable = tableView;
        }
        tableView.tableFooterView = [UIView new];
        [tableViewArr addObject:tableView];
    }
    [self.view addSubview:scroll];
    
    self.automaticallyAdjustsScrollViewInsets = NO;
    [self.view addSubview:self.topTableView];
    [self.topTableView reloadData];
    
    
    UIButton *moreProgrem = [UIButton buttonWithType:UIButtonTypeCustom];
    [moreProgrem setFrame:CGRectMake(IPHONE_W - 45.0, 64.0 , 35.0, 44)];
    [moreProgrem setBackgroundColor:[UIColor clearColor]];
    if (IS_IPAD){
        jiahao = [[UIImageView alloc]initWithFrame:CGRectMake(1, 0, 28.0 , 32.0)];
    }
    else{
        jiahao = [[UIImageView alloc]initWithFrame:CGRectMake(1, 0, 28.0 , 32.0)];
    }
    moreProgrem.accessibilityLabel = @"更多频道";
    jiahao.image = [UIImage imageNamed:@"home_rollingbar_more_pressed"];
    jiahao.contentMode = UIViewContentModeScaleAspectFit;
    [moreProgrem addTarget:self action:@selector(jiahaoBtnAction:) forControlEvents:UIControlEventTouchUpInside];
    
    DangqianIndexPath = [NSIndexPath indexPathForRow:0 inSection:0];
    [self shezhipaixujiemian];
    [self.view addSubview:moreProgrem];
    [moreProgrem addSubview:jiahao];

}

- (NSMutableArray *)ztADResult {
    if (!_ztADResult) {
        _ztADResult = [NSMutableArray new];
    }
    return _ztADResult;
}

- (NSMutableArray *)slideADResult {
    if (!_slideADResult) {
        _slideADResult = [NSMutableArray new];
    }
    return _slideADResult;
}

#pragma mark - NSNotificationAction
- (void)gaibianyanse:(NSNotification *)notification{
    
    [dangqianbofangTable reloadData];
}
//轮播图监听方法
- (void)lunboxiangqingVCAction:(NSNotification *)notification{
    
    if ([notification.object firstObject][@"slide_url"] != nil) {
        NSString *URLString = [notification.object firstObject][@"slide_url"];
        //调用系统浏览器
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:URLString]];
    }
    else{
        lunboxiangqingVC *lunboVC = [lunboxiangqingVC new];
        if ([notification.object isKindOfClass:[NSArray class]]){
            lunboVC.infoArr = [NSArray arrayWithArray:notification.object];
            if ([lunboVC.infoArr count] > 1) {
                self.hidesBottomBarWhenPushed=YES;
                [self.navigationController pushViewController:lunboVC animated:YES];
                self.hidesBottomBarWhenPushed=NO;
            }
            else{
                if ([[CommonCode readFromUserD:@"dangqianbofangxinwenID"] isEqualToString:[lunboVC.infoArr firstObject][@"id"]]){
                    self.hidesBottomBarWhenPushed = YES;
                    [self.navigationController.navigationBar setHidden:YES];
                    [self.navigationController pushViewController:[bofangVC shareInstance ] animated:YES];
                    self.hidesBottomBarWhenPushed = NO;
                }
                else{
                    [bofangVC shareInstance].newsModel.jiemuID = [lunboVC.infoArr firstObject][@"id"];
                    [bofangVC shareInstance].newsModel.Titlejiemu = [lunboVC.infoArr firstObject][@"post_title"];
                    [bofangVC shareInstance].newsModel.RiQijiemu = [lunboVC.infoArr firstObject][@"post_date"];
                    [bofangVC shareInstance].newsModel.ImgStrjiemu = [lunboVC.infoArr firstObject][@"smeta"];
                    [bofangVC shareInstance].newsModel.post_lai = [lunboVC.infoArr firstObject][@"post_lai"];
                    [bofangVC shareInstance].newsModel.post_news = [lunboVC.infoArr firstObject][@"post_act"][@"id"];
                    [bofangVC shareInstance].newsModel.jiemuName = [lunboVC.infoArr firstObject][@"post_act"][@"name"];
                    [bofangVC shareInstance].newsModel.jiemuDescription = [lunboVC.infoArr firstObject][@"post_act"][@"description"];
                    [bofangVC shareInstance].newsModel.jiemuImages = [lunboVC.infoArr firstObject][@"post_act"][@"images"];
                    [bofangVC shareInstance].newsModel.jiemuFan_num = [lunboVC.infoArr firstObject][@"post_act"][@"fan_num"];
                    [bofangVC shareInstance].newsModel.jiemuMessage_num = [lunboVC.infoArr firstObject][@"post_act"][@"message_num"];
                    [bofangVC shareInstance].newsModel.jiemuIs_fan = [lunboVC.infoArr firstObject][@"post_act"][@"is_fan"];
                    [bofangVC shareInstance].newsModel.post_mp = [lunboVC.infoArr firstObject][@"post_mp"];
                    [bofangVC shareInstance].newsModel.post_time = [lunboVC.infoArr firstObject][@"post_time"];
                    [bofangVC shareInstance].yinpinzongTime.text = [[bofangVC shareInstance] convertStringWithTime:[[lunboVC.infoArr firstObject][@"post_time"] intValue] / 1000];
                    
                    ExcurrentNumber = 0;
                    [bofangVC shareInstance].newsModel.ImgStrjiemu = [lunboVC.infoArr firstObject][@"smeta"];
                    [bofangVC shareInstance].newsModel.ZhengWenjiemu = [lunboVC.infoArr firstObject][@"post_excerpt"];
                    [bofangVC shareInstance].newsModel.praisenum = [lunboVC.infoArr firstObject][@"praisenum"];
                    [bofangVC shareInstance].newsModel.url = [lunboVC.infoArr firstObject][@"url"];
                    [bofangVC shareInstance].newsModel.post_keywords = [lunboVC.infoArr firstObject][@"post_keywords"];
                    [bofangVC shareInstance].newsModel.url = [lunboVC.infoArr firstObject][@"url"];
                    [bofangVC shareInstance].iszhuboxiangqing = NO;
                    [[bofangVC shareInstance].tableView reloadData];
                    
                    [Explayer replaceCurrentItemWithPlayerItem:[[AVPlayerItem alloc]initWithURL:[NSURL URLWithString:[lunboVC.infoArr firstObject][@"post_mp"]]]];
                    ExisRigester = YES;
                    ExIsKaiShiBoFang = YES;
                    ExwhichBoFangYeMianStr = @"shouyebofang";
                    self.hidesBottomBarWhenPushed = YES;
                    [self.navigationController.navigationBar setHidden:YES];
                    [self.navigationController pushViewController:[bofangVC shareInstance ] animated:YES];
                    self.hidesBottomBarWhenPushed = NO;
                    [[NSNotificationCenter defaultCenter] postNotificationName:@"yuanpanzhuan" object:nil];
                    [[NSNotificationCenter defaultCenter] postNotificationName:@"qiehuanxinwen" object:nil];
                    [CommonCode writeToUserD:[lunboVC.infoArr firstObject][@"id"] andKey:@"dangqianbofangxinwenID"];
                }
            }
        }
        else{
            lunboVC.infoArr = [NSArray array];
            self.hidesBottomBarWhenPushed=YES;
            [self.navigationController pushViewController:lunboVC animated:YES];
            self.hidesBottomBarWhenPushed=NO;
        }
        [[NSNotificationCenter defaultCenter] postNotificationName:@"gaibianyanse" object:nil];
        [[NSNotificationCenter defaultCenter] postNotificationName:@"dianjihougaibiangezhongyanse" object:nil];
    }
}

- (void)zidongjiazai:(NSNotification *)notification{
    NSString *page = [CommonCode readFromUserD:dangqianxuyaoJiaZaiDeTableViewType];
    int pageNumber = [page intValue];
    pageNumber ++;
    [CommonCode writeToUserD:[NSString stringWithFormat:@"%d",pageNumber] andKey:dangqianxuyaoJiaZaiDeTableViewType];
    if ([xuyaoJiaZaidePinDaoID isEqualToString:@"-1"]){
        NSString *accessToken;
        if (ExdangqianUser.length == 0 || ExdangqianUser == nil)
        {
            accessToken = nil;
        }else
        {
            accessToken = [DSE encryptUseDES:ExdangqianUser];
        }
        [NetWorkTool getTuiJianWithKeyWords:nil andaccessToken:accessToken andpage:[NSString stringWithFormat:@"%d",pageNumber] andlimit:@"15" sccess:^(NSDictionary *responseObject) {
            if ([responseObject[@"results"] isKindOfClass:[NSArray class]])
            {
                NSString *type = [dangqianxuyaoJiaZaiDeTableViewType stringByReplacingOccurrencesOfString:@"page" withString:@""];
                if ([[CommonCode readFromUserD:[NSString stringWithFormat:@"zhuyeliebiao%@",type]] isKindOfClass:[NSArray class]])
                {
                    NSMutableArray *arr = [[NSMutableArray alloc]initWithArray:[CommonCode readFromUserD:[NSString stringWithFormat:@"zhuyeliebiao%@",type]]];
                    [arr addObjectsFromArray:responseObject[@"results"]];
                    [CommonCode writeToUserD:arr andKey:[NSString stringWithFormat:@"zhuyeliebiao%@",type]];
                    [CommonCode writeToUserD:arr andKey:@"zhuyeliebiao"];
                    [[NSNotificationCenter defaultCenter] postNotificationName:@"jiazaichenggong" object:nil];
                }
            }
            UITableView *tableV = (UITableView *)[scroll viewWithTag:xuyaoJiaZaidePinDaoTag];
            [tableV reloadData];
            [tableV.mj_footer endRefreshing];
        } failure:^(NSError *error) {
            NSLog(@"error = %@",error);
        }];
    }
    else if([xuyaoJiaZaidePinDaoID isEqualToString:@"1"]){
        NSString *accessToken;
        if (ExdangqianUser.length == 0 || ExdangqianUser == nil){
            accessToken = nil;
        }
        else{
            accessToken = [DSE encryptUseDES:ExdangqianUser];
        }
        [NetWorkTool getTouTiaoListWithaccessToken:accessToken andPage:[NSString stringWithFormat:@"%d",pageNumber] andLimit:@"15" sccess:^(NSDictionary *responseObject) {
            if ([responseObject[@"results"] isKindOfClass:[NSArray class]])
            {
                NSString *type = [dangqianxuyaoJiaZaiDeTableViewType stringByReplacingOccurrencesOfString:@"page" withString:@""];
                if ([[CommonCode readFromUserD:[NSString stringWithFormat:@"zhuyeliebiao%@",type]] isKindOfClass:[NSArray class]])
                {
                    NSMutableArray *arr = [[NSMutableArray alloc]initWithArray:[CommonCode readFromUserD:[NSString stringWithFormat:@"zhuyeliebiao%@",type]]];
                    [arr addObjectsFromArray:responseObject[@"results"]];
                    [CommonCode writeToUserD:arr andKey:[NSString stringWithFormat:@"zhuyeliebiao%@",type]];
                    [CommonCode writeToUserD:arr andKey:@"zhuyeliebiao"];
                    [[NSNotificationCenter defaultCenter] postNotificationName:@"jiazaichenggong" object:nil];
                }
            }
            UITableView *tableV = (UITableView *)[scroll viewWithTag:xuyaoJiaZaidePinDaoTag];
            [tableV reloadData];
            [tableV.mj_footer endRefreshing];
        } failure:^(NSError *error) {
            NSLog(@"error = %@",error);
        }];
    }
    else{
        NSString *accessToken;
        if (ExdangqianUser.length == 0 || ExdangqianUser == nil){
            accessToken = nil;
        }
        else{
            accessToken = [DSE encryptUseDES:ExdangqianUser];
        }
        [NetWorkTool getNewsListWithaccessToken:accessToken andID:xuyaoJiaZaidePinDaoID andpage:[NSString stringWithFormat:@"%d",pageNumber] andlimit:@"15" sccess:^(NSDictionary *responseObject) {
            if ([responseObject[@"results"] isKindOfClass:[NSArray class]]){
                NSString *type = [dangqianxuyaoJiaZaiDeTableViewType stringByReplacingOccurrencesOfString:@"page" withString:@""];
                if ([[CommonCode readFromUserD:[NSString stringWithFormat:@"zhuyeliebiao%@",type]] isKindOfClass:[NSArray class]]){
                    NSMutableArray *arr = [[NSMutableArray alloc]initWithArray:[CommonCode readFromUserD:[NSString stringWithFormat:@"zhuyeliebiao%@",type]]];
                    [arr addObjectsFromArray:responseObject[@"results"]];
                    [CommonCode writeToUserD:arr andKey:[NSString stringWithFormat:@"zhuyeliebiao%@",type]];
                    [CommonCode writeToUserD:arr andKey:@"zhuyeliebiao"];
                    [[NSNotificationCenter defaultCenter] postNotificationName:@"jiazaichenggong" object:nil];
                }
            }
            UITableView *tableV = (UITableView *)[scroll viewWithTag:xuyaoJiaZaidePinDaoTag];
            [tableV reloadData];
            [tableV.mj_footer endRefreshing];
        } failure:^(NSError *error) {
            NSLog(@"error = %@",error);
            
        }];
    }
}

- (void)selectedLocalCity:(NSNotification *)notification {
    
    int index = 0;
    NSString *cityType = notification.object[@"type"];
    NSString *numberkey = notification.object[@"numberkey"];
    NSString *parent = notification.object[@"parent"];
    NSMutableArray *topNameTempArr = [[CommonCode readFromUserD:@"topNameArr"] mutableCopy];
    
    for (int i = 0 ; i < [topNameTempArr count]; i ++) {
        if ([topNameTempArr[i][@"numberkey"] isEqualToString:@"19"] || ![topNameTempArr[i][@"parent"] isEqualToString:@"0"]) {
            
            NSMutableDictionary *mdic = [NSMutableDictionary dictionaryWithDictionary:topNameTempArr[i]];
            [mdic setValue:cityType forKey:@"type"];
            [mdic setValue:numberkey forKey:@"numberkey"];
            [mdic setValue:parent forKey:@"parent"];
            [topNameTempArr replaceObjectAtIndex:i withObject:mdic];
            index = i;
            break;
        }
    }
    [CommonCode writeToUserD:topNameTempArr andKey:@"topNameArr"];
    
    NSMutableArray *topCollectionArrTempArr = [[CommonCode readFromUserD:@"topCollectionArr"] mutableCopy];
    if (topCollectionArrTempArr == nil) {
        topCollectionArrTempArr = [topNameTempArr mutableCopy];
    }
    else{
        for (int i = 0 ; i < [topCollectionArrTempArr count]; i ++) {
            if ([topCollectionArrTempArr[i][@"numberkey"] isEqualToString:@"19"] || ![topCollectionArrTempArr[i][@"parent"] isEqualToString:@"0"]) {
                
                NSMutableDictionary *mdic = [NSMutableDictionary dictionaryWithDictionary:topCollectionArrTempArr[i]];
                [mdic setValue:cityType forKey:@"type"];
                [mdic setValue:numberkey forKey:@"numberkey"];
                [mdic setValue:parent forKey:@"parent"];
                [topCollectionArrTempArr replaceObjectAtIndex:i withObject:mdic];
                index = i;
                break;
            }
        }
    }
    
    [CommonCode writeToUserD:topCollectionArrTempArr andKey:@"topCollectionArr"];
    topCollectionArr = [NSMutableArray arrayWithArray:[CommonCode readFromUserD:@"topCollectionArr"]];
    
    [self.topCollectionV reloadData];
    [self.topTableView reloadData];
    UITableView *tableView = (UITableView *)tableViewArr[index];
    Exterm_id = numberkey;
    [tableView.mj_header beginRefreshing];
//    [self refreshData:Exterm_id andPinDaoName:cityType andTableView:tableView];
    
}


- (void)dealloc{
    
}

#pragma mark - Utilities

- (void)getStartAD{
    [NetWorkTool getIntoAppGuangGaoPage:@"1" andLimit:@"15" sccess:^(NSDictionary *responseObject) {
        if ([responseObject[@"results"] isKindOfClass:[NSArray class]]){
            
            if (TARGETED_DEVICE_IS_IPHONE_480 && [[responseObject[@"results"] firstObject][@"status"] isEqualToString:@"1"]){
                [self openLaunchAD];
            }
            else if (TARGETED_DEVICE_IS_IPHONE_568 &&  [responseObject[@"results"][1] [@"status"] isEqualToString:@"1"]){
                [self openLaunchAD];
            }
            else if (TARGETED_DEVICE_IS_IPHONE_667 &&  [responseObject[@"results"][2] [@"status"] isEqualToString:@"1"]){
                [self openLaunchAD];
            }
            else if (TARGETED_DEVICE_IS_IPHONE_736 &&  [responseObject[@"results"][3] [@"status"] isEqualToString:@"1"]){
                [self openLaunchAD];
            }
            else if (TARGETED_DEVICE_IS_IPAD &&  [responseObject[@"results"][3] [@"status"] isEqualToString:@"1"]){
                [self openLaunchAD];
            }
            
        }
       
    }failure:^(NSError *error)
     {
         NSLog(@"%@",error);
        
     }];
}

- (void)openLaunchAD{
    guanggaoVC *guangao = [guanggaoVC new];
    self.hidesBottomBarWhenPushed = YES;
    [self.navigationController pushViewController:guangao animated:NO];
    self.hidesBottomBarWhenPushed = NO;
}


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



- (void)presentPushNews{
    [bofangVC shareInstance].newsModel.jiemuID = self.pushNewsInfo[@"post_id"];
    [bofangVC shareInstance].newsModel.Titlejiemu = self.pushNewsInfo[@"post_title"];
    [bofangVC shareInstance].newsModel.RiQijiemu = self.pushNewsInfo[@"post_date"] == nil?self.pushNewsInfo[@"post_modified"]:self.pushNewsInfo[@"post_date"];
    [bofangVC shareInstance].newsModel.ImgStrjiemu = self.pushNewsInfo[@"smeta"];
    [bofangVC shareInstance].newsModel.post_lai = self.pushNewsInfo[@"post_lai"];
    [bofangVC shareInstance].newsModel.post_news = self.pushNewsInfo[@"post_act"][@"id"];
    [bofangVC shareInstance].newsModel.jiemuName = self.pushNewsInfo[@"post_act"][@"name"];
    [bofangVC shareInstance].newsModel.jiemuDescription = self.pushNewsInfo[@"post_act"][@"description"];
    [bofangVC shareInstance].newsModel.jiemuImages = self.pushNewsInfo[@"post_act"][@"images"];
    [bofangVC shareInstance].newsModel.jiemuFan_num = self.pushNewsInfo[@"post_act"][@"fan_num"];
    [bofangVC shareInstance].newsModel.jiemuMessage_num = self.pushNewsInfo[@"post_act"][@"message_num"];
    [bofangVC shareInstance].newsModel.jiemuIs_fan = self.pushNewsInfo[@"post_act"][@"is_fan"];
    [bofangVC shareInstance].newsModel.post_mp = self.pushNewsInfo[@"post_mp"];
    [bofangVC shareInstance].newsModel.post_time = self.pushNewsInfo[@"post_time"];
    [bofangVC shareInstance].newsModel.post_keywords = self.pushNewsInfo[@"post_keywords"];
    [bofangVC shareInstance].newsModel.url = self.pushNewsInfo[@"url"];
    [bofangVC shareInstance].iszhuboxiangqing = NO;
    //        dangqianbofangTable = tableView;
    [bofangVC shareInstance].yinpinzongTime.text = [[bofangVC shareInstance] convertStringWithTime:[self.pushNewsInfo[@"post_time"] intValue] / 1000];
    
    //        ExcurrentNumber = (int)indexPath.row;
    [bofangVC shareInstance].newsModel.ImgStrjiemu = self.pushNewsInfo[@"smeta"];
    [bofangVC shareInstance].newsModel.ZhengWenjiemu = self.pushNewsInfo[@"post_excerpt"];
    [bofangVC shareInstance].newsModel.praisenum = self.pushNewsInfo[@"praisenum"];
    //[[bofangVC shareInstance].newsModel.tableView reloadData];
    [Explayer replaceCurrentItemWithPlayerItem:[[AVPlayerItem alloc]initWithURL:[NSURL URLWithString:self.pushNewsInfo[@"post_mp"]]]];
    ExisRigester = YES;
    ExIsKaiShiBoFang = YES;
    ExwhichBoFangYeMianStr = @"shouyebofang";
    
    NSString *isPlayingVC = [CommonCode readFromUserD:@"isPlayingVC"];
    if ([isPlayingVC isEqualToString:@"YES"]) {
        NSString *isPlayingGray = [CommonCode readFromUserD:@"isPlayingGray"];
        if ([isPlayingGray isEqualToString:@"NO"]) {
            [[bofangVC shareInstance].tableView reloadData];
        }
        else{
            [bofangVC shareInstance].isPushNews = YES;
            self.hidesBottomBarWhenPushed = YES;
            [self.navigationController.navigationBar setHidden:YES];
            [self.navigationController pushViewController:[bofangVC shareInstance] animated:YES];
            self.hidesBottomBarWhenPushed = NO;
            
        }
        if ([bofangVC shareInstance].isPlay) {
            
        }
        else{
            [[bofangVC shareInstance] doplay2];
        }
    }
    else{
        
        [bofangVC shareInstance].isPushNews = YES;
        self.hidesBottomBarWhenPushed = YES;
        [self.navigationController.navigationBar setHidden:YES];
        [self.navigationController pushViewController:[bofangVC shareInstance] animated:YES];
        self.hidesBottomBarWhenPushed = NO;
        if ([bofangVC shareInstance].isPlay) {
            
        }
        else{
            [[bofangVC shareInstance] doplay2];
        }
    }
    
    [[NSNotificationCenter defaultCenter] postNotificationName:@"yuanpanzhuan" object:nil];
    [[NSNotificationCenter defaultCenter] postNotificationName:@"qiehuanxinwen" object:nil];
    //        [CommonCode writeToUserD:arr andKey:@"zhuyeliebiao"];
    [CommonCode writeToUserD:self.pushNewsInfo[@"post_id"] andKey:@"dangqianbofangxinwenID"];
    
    if ([[CommonCode readFromUserD:@"yitingguoxinwenID"] isKindOfClass:[NSArray class]]){
        NSMutableArray *yitingguoArr = [NSMutableArray arrayWithArray:[CommonCode readFromUserD:@"yitingguoxinwenID"]];
#warning bug self.pushNewsInfo 中没有id键值对
        [yitingguoArr addObject:self.pushNewsInfo[@"post_id"]];
        [CommonCode writeToUserD:yitingguoArr andKey:@"yitingguoxinwenID"];
    }
    else{
        NSMutableArray *yitingguoArr = [NSMutableArray array];
        [yitingguoArr addObject:self.pushNewsInfo[@"post_id"]];
        [CommonCode writeToUserD:yitingguoArr andKey:@"yitingguoxinwenID"];
    }
    
    [[NSNotificationCenter defaultCenter] postNotificationName:@"dianjihougaibiangezhongyanse" object:nil];
    
}

- (void)skipToLastNews{
    NSMutableDictionary *dic = [CommonCode readFromUserD:THELASTNEWSDATA];
    [bofangVC shareInstance].newsModel.jiemuID = dic[@"jiemuID"];
    [bofangVC shareInstance].newsModel.Titlejiemu = dic[@"Titlejiemu"];
    [bofangVC shareInstance].newsModel.RiQijiemu = dic[@"RiQijiemu"];
    [bofangVC shareInstance].newsModel.ImgStrjiemu = dic[@"ImgStrjiemu"];
    [bofangVC shareInstance].newsModel.post_lai = dic[@"post_lai"];
    [bofangVC shareInstance].newsModel.post_news = dic[@"post_news"];
    [bofangVC shareInstance].newsModel.jiemuName = dic[@"jiemuName"];
    [bofangVC shareInstance].newsModel.jiemuDescription = dic[@"jiemuDescription"];
    [bofangVC shareInstance].newsModel.jiemuImages = dic[@"jiemuImages"];
    [bofangVC shareInstance].newsModel.jiemuFan_num = dic[@"jiemuFan_num"];
    [bofangVC shareInstance].newsModel.jiemuMessage_num = dic[@"jiemuMessage_num"];
    [bofangVC shareInstance].newsModel.jiemuIs_fan = dic[@"jiemuIs_fan"];
    [bofangVC shareInstance].newsModel.post_mp = dic[@"post_mp"];
    [bofangVC shareInstance].newsModel.post_time = dic[@"post_time"];
    [bofangVC shareInstance].newsModel.post_keywords = dic[@"post_keywords"];
    [bofangVC shareInstance].newsModel.url = dic[@"url"];
    [bofangVC shareInstance].iszhuboxiangqing = NO;
    [bofangVC shareInstance].yinpinzongTime.text = [[bofangVC shareInstance] convertStringWithTime:[dic[@"post_time"] intValue] / 1000];
    [bofangVC shareInstance].newsModel.ImgStrjiemu = dic[@"ImgStrjiemu"];
    [bofangVC shareInstance].newsModel.ZhengWenjiemu = dic[@"ZhengWenjiemu"];
    [bofangVC shareInstance].newsModel.praisenum = dic[@"praisenum"];
    [Explayer replaceCurrentItemWithPlayerItem:[[AVPlayerItem alloc]initWithURL:[NSURL URLWithString:dic[@"post_mp"]]]];
    ExisRigester = YES;
    ExIsKaiShiBoFang = YES;
    ExwhichBoFangYeMianStr = @"shouyebofang";
    NSString *isPlayingVC = [CommonCode readFromUserD:@"isPlayingVC"];
    if ([isPlayingVC isEqualToString:@"YES"]) {
        NSString *isPlayingGray = [CommonCode readFromUserD:@"isPlayingGray"];
        if ([isPlayingGray isEqualToString:@"NO"]) {
            [[bofangVC shareInstance].tableView reloadData];
        }
        else{
            [bofangVC shareInstance].isPushNews = YES;
            self.hidesBottomBarWhenPushed = YES;
            [self.navigationController.navigationBar setHidden:YES];
            [self.navigationController pushViewController:[bofangVC shareInstance] animated:YES];
            self.hidesBottomBarWhenPushed = NO;
            
        }
        if ([bofangVC shareInstance].isPlay) {
            
        }
        else{
            [[bofangVC shareInstance] doplay2];
        }
    }
    else{
        
        [bofangVC shareInstance].isPushNews = YES;
        self.hidesBottomBarWhenPushed = YES;
        [self.navigationController.navigationBar setHidden:YES];
        [self.navigationController pushViewController:[bofangVC shareInstance] animated:YES];
        self.hidesBottomBarWhenPushed = NO;
        if ([bofangVC shareInstance].isPlay) {
            
        }
        else{
            [[bofangVC shareInstance] doplay2];
        }
    }
    [[NSNotificationCenter defaultCenter] postNotificationName:@"yuanpanzhuan" object:nil];
    [[NSNotificationCenter defaultCenter] postNotificationName:@"qiehuanxinwen" object:nil];
    [CommonCode writeToUserD:dic[@"jiemuID"] andKey:@"dangqianbofangxinwenID"];
    
    if ([[CommonCode readFromUserD:@"yitingguoxinwenID"] isKindOfClass:[NSArray class]]){
        NSMutableArray *yitingguoArr = [NSMutableArray arrayWithArray:[CommonCode readFromUserD:@"yitingguoxinwenID"]];
        [yitingguoArr addObject:dic[@"jiemuID"]];
        [CommonCode writeToUserD:yitingguoArr andKey:@"yitingguoxinwenID"];
    }
    else{
        NSMutableArray *yitingguoArr = [NSMutableArray array];
        [yitingguoArr addObject:dic[@"jiemuID"]];
        [CommonCode writeToUserD:yitingguoArr andKey:@"yitingguoxinwenID"];
    }
    
    [[NSNotificationCenter defaultCenter] postNotificationName:@"dianjihougaibiangezhongyanse" object:nil];
}


- (void)shanglajiazai:(NSString *)pindaoID andtableView:(UITableView *)tableView andTableName:(NSString *)tableName{
    NSString *page = [CommonCode readFromUserD:[NSString stringWithFormat:@"page%@",topNameArr[[tableViewArr indexOfObject:tableView]][@"type"]]];;
    int pageNumber = [page intValue];
    pageNumber ++;
    
    if ([pindaoID isEqualToString:@"-1"]){
        NSString *accessToken;
        if (ExdangqianUser.length == 0 || ExdangqianUser == nil)
        {
            accessToken = nil;
        }else
        {
            accessToken = [DSE encryptUseDES:ExdangqianUser];
        }
        [NetWorkTool getTuiJianWithKeyWords:nil andaccessToken:accessToken andpage:[NSString stringWithFormat:@"%d",pageNumber] andlimit:@"15" sccess:^(NSDictionary *responseObject) {
            if ([responseObject[@"results"] isKindOfClass:[NSArray class]]){
                if ([[CommonCode readFromUserD:[NSString stringWithFormat:@"zhuyeliebiao%@",tableName]] isKindOfClass:[NSArray class]]){
                    NSMutableArray *arr = [[NSMutableArray alloc]initWithArray:[CommonCode readFromUserD:[NSString stringWithFormat:@"zhuyeliebiao%@",tableName]]];
                    NSRange range = {NSNotFound, NSNotFound};
                    for (int i = 0 ; i < [arr count]; i ++) {
                        if ([arr[i][@"id"] isEqualToString:[responseObject[@"results"] firstObject][@"id"] ]) {
                            range = NSMakeRange(i, [arr count] - i);
                            break;
                        }
                    }
                    if (range.location < [arr count]) {
                        [arr removeObjectsInRange:range];
                    }
                    [arr addObjectsFromArray:responseObject[@"results"]];
                    [CommonCode writeToUserD:arr andKey:[NSString stringWithFormat:@"zhuyeliebiao%@",tableName]];
                    
                    [CommonCode writeToUserD:TouListArr andKey:@"zhuyeliebiao"];
                }
            }
            [tableView reloadData];
            [tableView.mj_footer endRefreshing];
            NSString *insertPage = [NSString stringWithFormat:@"%d",pageNumber];
            [CommonCode writeToUserD:insertPage andKey:[NSString stringWithFormat:@"page%@",topNameArr[[tableViewArr indexOfObject:tableView]][@"type"]]];
        } failure:^(NSError *error) {
            NSLog(@"error = %@",error);
            [tableView.mj_footer endRefreshing];
        }];
    }
    else if([pindaoID isEqualToString:@"1"]){
        NSString *accessToken;
        if (ExdangqianUser.length == 0 || ExdangqianUser == nil){
            accessToken = nil;
        }
        else{
            accessToken = [DSE encryptUseDES:ExdangqianUser];
        }
        [NetWorkTool getTouTiaoListWithaccessToken:accessToken andPage:[NSString stringWithFormat:@"%d",pageNumber] andLimit:@"15" sccess:^(NSDictionary *responseObject) {
            if ([responseObject[@"results"] isKindOfClass:[NSArray class]]){
                if ([[CommonCode readFromUserD:[NSString stringWithFormat:@"zhuyeliebiao%@",tableName]] isKindOfClass:[NSArray class]]){
                    NSMutableArray *arr = [[NSMutableArray alloc]initWithArray:[CommonCode readFromUserD:[NSString stringWithFormat:@"zhuyeliebiao%@",tableName]]];
                    //删掉该page在上拉时新增的重复数据
                    NSRange range = {NSNotFound, NSNotFound};
                    for (int i = 0 ; i < [arr count]; i ++) {
                        if ([arr[i][@"id"] isEqualToString:[responseObject[@"results"] firstObject][@"id"] ]) {
                            range = NSMakeRange(i, [arr count] - i);
                            break;
                        }
                    }
                    if (range.location < [arr count]) {
                        [arr removeObjectsInRange:range];
                    }
                    [arr addObjectsFromArray:responseObject[@"results"]];
                    [CommonCode writeToUserD:arr andKey:[NSString stringWithFormat:@"zhuyeliebiao%@",tableName]];
                    [CommonCode writeToUserD:TouListArr andKey:@"zhuyeliebiao"];
                }
            }
            [tableView reloadData];
            [tableView.mj_footer endRefreshing];
            NSString *insertPage = [NSString stringWithFormat:@"%d",pageNumber];
            [CommonCode writeToUserD:insertPage andKey:[NSString stringWithFormat:@"page%@",topNameArr[[tableViewArr indexOfObject:tableView]][@"type"]]];
        } failure:^(NSError *error) {
            NSLog(@"error = %@",error);
            [tableView.mj_footer endRefreshing];
        }];
    }
    else{
        NSString *accessToken;
        if (ExdangqianUser.length == 0 || ExdangqianUser == nil)
        {
            accessToken = nil;
        }else
        {
            accessToken = [DSE encryptUseDES:ExdangqianUser];
        }
        [NetWorkTool getNewsListWithaccessToken:accessToken andID:pindaoID andpage:[NSString stringWithFormat:@"%d",pageNumber] andlimit:@"15" sccess:^(NSDictionary *responseObject) {
            if ([responseObject[@"results"] isKindOfClass:[NSArray class]]){
                if ([[CommonCode readFromUserD:[NSString stringWithFormat:@"zhuyeliebiao%@",tableName]] isKindOfClass:[NSArray class]]){
                    NSMutableArray *arr = [[NSMutableArray alloc]initWithArray:[CommonCode readFromUserD:[NSString stringWithFormat:@"zhuyeliebiao%@",tableName]]];
                    NSRange range = {NSNotFound, NSNotFound};
                    for (int i = 0 ; i < [arr count]; i ++) {
                        if ([arr[i][@"id"] isEqualToString:[responseObject[@"results"] firstObject][@"id"] ]) {
                            range = NSMakeRange(i, [arr count] - i);
                            break;
                        }
                    }
                    if (range.location < [arr count]) {
                        [arr removeObjectsInRange:range];
                    }
                    [arr addObjectsFromArray:responseObject[@"results"]];
                    [CommonCode writeToUserD:arr andKey:[NSString stringWithFormat:@"zhuyeliebiao%@",tableName]];
                    
                    [CommonCode writeToUserD:TouListArr andKey:@"zhuyeliebiao"];
                }
            }
           
            NSString *insertPage = [NSString stringWithFormat:@"%d",pageNumber];
            [CommonCode writeToUserD:insertPage andKey:[NSString stringWithFormat:@"page%@",topNameArr[[tableViewArr indexOfObject:tableView]][@"type"]]];
            [tableView reloadData];
            [tableView.mj_footer endRefreshing];
            
        } failure:^(NSError *error) {
            NSLog(@"error = %@",error);
            [tableView.mj_footer endRefreshing];
        }];
    }
    
}

- (void)rightCellBtnAction:(UIButton *)sender{
    UITableViewCell *cell = (UITableViewCell *)[[sender superview] superview];
    UITableView *tableView = (UITableView *)[[cell superview] superview];
    NSIndexPath *indexPath = [tableView indexPathForCell:cell];
    
    if (quanjvIndexPath != indexPath)
    {
        if (quanjvIndexPath)
        {
            UITableViewCell *yaoguanbiCell = [tableView cellForRowAtIndexPath:quanjvIndexPath];
            UIButton *yaoguanbiBtn = (UIButton *)[yaoguanbiCell.contentView viewWithTag:quanjvIndexPath.row + 1000];
            yaoguanbiBtn.selected = NO;
            [UIView animateWithDuration:0.3f animations:^{
                yaoguanbiCell.frame = CGRectMake(0, yaoguanbiCell.frame.origin.y, yaoguanbiCell.frame.size.width, yaoguanbiCell.frame.size.height);
            }];
            quanjvIndexPath = nil;
        }
    }
    if (sender.selected == NO)
    {
        sender.selected = YES;
        quanjvIndexPath = indexPath;
        [UIView animateWithDuration:0.3f animations:^{
            cell.frame = CGRectMake(-150.0 / 375 * IPHONE_W, cell.frame.origin.y, cell.frame.size.width, cell.frame.size.height);
        }];
        dangqianTableView = tableView;
    }else
    {
        quanjvIndexPath = nil;
        sender.selected = NO;
        [UIView animateWithDuration:0.3f animations:^{
            cell.frame = CGRectMake(0, cell.frame.origin.y, cell.frame.size.width, cell.frame.size.height);
        }];
        dangqianTableView = nil;
    }
}
- (void)jiahaoBtnAction:(UIButton *)sender{
    if (isJiaHaoZheng == YES){
        sender.accessibilityLabel = @"返回";
        qiehuanbeijingView.frame = CGRectMake(0, 64, IPHONE_W, IPHONE_H);
        qiehuanlanmuView.hidden = NO;
        qiehuanbeijingView.hidden = NO;
        isJiaHaoZheng = NO;
        [UIView animateWithDuration:0.5f animations:^{
            qiehuanlanmuView.alpha = 1.0f;
            qiehuanbeijingView.alpha = 0.97f;
            jiahao.transform = CGAffineTransformMakeRotation(M_PI / 4);
            jiahao.image = [UIImage imageNamed:@"home_rollingbar_more_pressed1"];
        }];
    }
    else{
        sender.accessibilityLabel = @"更多频道";
        [self.topTableView reloadData];
        isJiaHaoZheng = YES;
        [UIView animateWithDuration:0.5f animations:^{
            qiehuanlanmuView.alpha = 0.0f;
            qiehuanbeijingView.alpha = 0.0f;
            jiahao.transform = CGAffineTransformMakeRotation(0);
            jiahao.image = [UIImage imageNamed:@"home_rollingbar_more_pressed"];
        } completion:^(BOOL finished) {
            qiehuanlanmuView.hidden = YES;
            qiehuanbeijingView.hidden = YES;
            qiehuanbeijingView.frame = CGRectMake(0, 0, IPHONE_W, 0);
        }];
    }
}

//- (void)downloadNewsAction:(UIButton *)sender {
//    
//    [SVProgressHUD showInfoWithStatus:@"开始下载"];
//    [self performSelector:@selector(SVPDismiss) withObject:nil afterDelay:1.0];
//    //TODO:下载单条新闻
//    NSMutableDictionary *dic = self.tableViewDataArr[sender.tag - 100];
//    dispatch_async(dispatch_get_main_queue(), ^{
//        ProjiectDownLoadManager *manager = [ProjiectDownLoadManager defaultProjiectDownLoadManager];
//        [manager insertSevaDownLoadArray:dic];
//        
//        WHC_Download *op = [[WHC_Download alloc]initStartDownloadWithURL:[NSURL URLWithString:dic[@"post_mp"]] savePath:manager.userDownLoadPath savefileName:[dic[@"post_mp"] stringByReplacingOccurrencesOfString:@"/" withString:@""] withObj:dic delegate:nil];
//        [manager.downLoadQueue addOperation:op];
//    });
//}

- (void)SVPDismiss {
    [SVProgressHUD dismiss];
}

- (void)newreportAction:(UIButton *)sender {
    
    NewReportViewController *newreportVC = [[NewReportViewController alloc]init];
    newreportVC.term_id = Exterm_id;
    newreportVC.NewsTpye = nil;
    self.hidesBottomBarWhenPushed=YES;
    [self.navigationController pushViewController:newreportVC animated:YES];
    self.hidesBottomBarWhenPushed=NO;
}

- (void)moreProgramAction:(UIButton *)sender {
    faxianGengDuoVC *moreProgramVC = [[faxianGengDuoVC alloc]init];
    moreProgramVC.term_id = Exterm_id;
    self.hidesBottomBarWhenPushed=YES;
    [self.navigationController pushViewController:moreProgramVC animated:YES];
    self.hidesBottomBarWhenPushed=NO;
}

- (void)selectedCity:(UIButton *)sender {
    CitySelectedViewController *citylistVC = [[CitySelectedViewController alloc]init];
    self.hidesBottomBarWhenPushed=YES;
    [self.navigationController pushViewController:citylistVC animated:YES];
    self.hidesBottomBarWhenPushed=NO;
    
}

#pragma mark - UICollectionViewDelegate

//- (UICollectionReusableView *)collectionView:(UICollectionView *)collectionView viewForSupplementaryElementOfKind:(NSString *)kind atIndexPath:(NSIndexPath *)indexPath{
//
//
//    UICollectionReusableView *CollectionHeaderview =  [collectionView dequeueReusableSupplementaryViewOfKind :UICollectionElementKindSectionHeader   withReuseIdentifier:@"topHeaderIdentifier"   forIndexPath:indexPath];
//
//    UILabel *lab = [[UILabel alloc]initWithFrame:CGRectMake(0, 0, IPHONE_W, 30)];
//    lab.text = @"点击删除频道";
//    [CollectionHeaderview addSubview:lab];
//
//    return CollectionHeaderview;
//}

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return 1;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    if (collectionView.tag == 1)
    {
        return topCollectionArr.count;
    }
    else{
        return downCollectionArr.count;
    }
    
}
- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    //重用cell
    paixuColleCtionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"paixuColleCtionViewCell" forIndexPath:indexPath];
    //赋值
    if (collectionView.tag == 1){
        if (indexPath.row == 0)
        {
            cell.lab.backgroundColor = ColorWithRGBA(207, 207, 207, 1);
        }else
        {
            cell.lab.backgroundColor = [UIColor whiteColor];
        }
        cell.lab.text = topCollectionArr[indexPath.row][@"type"];
    }else
    {
        cell.lab.text = downCollectionArr[indexPath.row][@"type"];
    }
    
    cell.contentView.backgroundColor = [UIColor whiteColor];
    
    return cell;
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    return CGSizeMake(105.0 / 375 * IPHONE_W, 30.0 / 667 * IPHONE_H);
}

//定义每个Section 的 margin
-(UIEdgeInsets)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout insetForSectionAtIndex:(NSInteger)section {
    return UIEdgeInsetsMake(10.0 / 667 * IPHONE_H, 10.0 / 375 * IPHONE_W, 10.0 / 667 * IPHONE_H, 10.0 / 375 * IPHONE_W);//分别为上、左、下、右
}


- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    if (collectionView.tag == 1){
        if (indexPath.row != 0){
            downCollectionArr = [[NSMutableArray alloc]initWithArray:downCollectionArr];
            topCollectionArr = [[NSMutableArray alloc]initWithArray:topCollectionArr];
            [downCollectionArr insertObject:topCollectionArr[indexPath.row] atIndex:0];
            [topCollectionArr removeObjectAtIndex:indexPath.row];
            topNameArr = [[NSMutableArray alloc]initWithArray:topNameArr];
            tableViewArr = [[NSMutableArray alloc]initWithArray:tableViewArr];
            for (NSInteger i = indexPath.row; i < topNameArr.count - 1; i ++ ){
                
                [topNameArr exchangeObjectAtIndex:i withObjectAtIndex:i + 1];
                [tableViewArr exchangeObjectAtIndex:i withObjectAtIndex:i + 1];
            }
            NSArray *changArr = [NSArray arrayWithArray:topNameArr];
            for (NSMutableDictionary *dic in changArr){
                NSMutableDictionary *mdic = [NSMutableDictionary dictionaryWithDictionary:dic];
                [mdic setValue:[NSString stringWithFormat:@"%lu",(unsigned long)[topNameArr indexOfObject:dic]] forKey:@"weizhi"];
                [topNameArr replaceObjectAtIndex:[topNameArr indexOfObject:dic] withObject:mdic];
                
            }
            for (int i = 0; i < topNameArr.count; i ++ )
            {
                
                UITableView *tableView = (UITableView *)tableViewArr[i];
                tableView.frame = CGRectMake([topNameArr[i][@"weizhi"] intValue] * IPHONE_W, tableView.frame.origin.y, tableView.frame.size.width, tableView.frame.size.height);
                
                [tableView removeFromSuperview];
                [scroll addSubview:tableView];
                tableView.mj_header = [MJRefreshNormalHeader headerWithRefreshingBlock:^{
                    [self refreshData:topNameArr[i][@"numberkey"] andPinDaoName:topNameArr[i][@"type"] andTableView:tableView];
                }];
                tableView.mj_footer = [MJRefreshAutoStateFooter footerWithRefreshingBlock:^{
                    [self shanglajiazai:topNameArr[i][@"numberkey"] andtableView:tableView andTableName:topNameArr[i][@"type"]];
                }];
            }
            if (topCollectionArr.count == 0)
            {
                [UIView animateWithDuration:0.3 animations:^{
                    self.topCollectionV.frame = CGRectMake(self.topCollectionV.frame.origin.x, self.topCollectionV.frame.origin.y, self.topCollectionV.frame.size.width, 0);
                    tianjiaBgV.frame = CGRectMake(0, CGRectGetMaxY(self.topCollectionV.frame), IPHONE_W, tianjiaBgV.frame.size.height);
                    self.downCollectionV.frame = CGRectMake(0, CGRectGetMaxY(tianjiaBgV.frame), self.downCollectionV.frame.size.width, ((downCollectionArr.count - 1) / 3) * 50.0 / 667 * IPHONE_H + 80.0 / 667 * IPHONE_H);
                }];
            }else
            {
                [UIView animateWithDuration:0.3 animations:^{
                    self.topCollectionV.frame = CGRectMake(self.topCollectionV.frame.origin.x, self.topCollectionV.frame.origin.y, self.topCollectionV.frame.size.width, ((topCollectionArr.count - 1) / 3) * 50.0 / 667 * IPHONE_H + 80.0 / 667 * IPHONE_H);
                    tianjiaBgV.frame = CGRectMake(0, CGRectGetMaxY(self.topCollectionV.frame), IPHONE_W, tianjiaBgV.frame.size.height);
                    self.downCollectionV.frame = CGRectMake(0, CGRectGetMaxY(tianjiaBgV.frame), self.downCollectionV.frame.size.width, ((downCollectionArr.count - 1) / 3) * 50.0 / 667 * IPHONE_H + 80.0 / 667 * IPHONE_H);
                }];
            }
            [self.topCollectionV reloadData];
            [self.downCollectionV reloadData];
        }
        [CommonCode writeToUserD:topNameArr andKey:@"topNameArr"];
        [CommonCode writeToUserD:topCollectionArr andKey:@"topCollectionArr"];
        [CommonCode writeToUserD:downCollectionArr andKey:@"downCollectionArr"];
        scroll.contentSize = CGSizeMake(IPHONE_W * topCollectionArr.count, IPHONE_H - 49 - 60.0 / 667 * IPHONE_H);
        
    }
    else{
        topNameArr = [[NSMutableArray alloc]initWithArray:topNameArr];
        tableViewArr = [[NSMutableArray alloc]initWithArray:tableViewArr];
        topCollectionArr = [[NSMutableArray alloc]initWithArray:topCollectionArr];
        downCollectionArr = [[NSMutableArray alloc]initWithArray:downCollectionArr];
        for (NSInteger i = (topNameArr.count - (indexPath.row + 1)); i > 1; i -- ){
            
            [topNameArr exchangeObjectAtIndex:i withObjectAtIndex:i-1];
            [tableViewArr exchangeObjectAtIndex:i withObjectAtIndex:i-1];
        }
        [topCollectionArr insertObject:downCollectionArr[indexPath.row] atIndex:1];
        [downCollectionArr removeObjectAtIndex:indexPath.row];
        NSArray *changArr = [NSArray arrayWithArray:topNameArr];
        for (NSMutableDictionary *dic in changArr){
            NSMutableDictionary *mdic = [NSMutableDictionary dictionaryWithDictionary:dic];
            [mdic setValue:[NSString stringWithFormat:@"%lu",(unsigned long)[changArr indexOfObject:dic]] forKey:@"weizhi"];
            [topNameArr replaceObjectAtIndex:[topNameArr indexOfObject:dic] withObject:mdic];
        }
        for (int i = 0; i < topNameArr.count; i ++ ){
            UITableView *tableView = (UITableView *)tableViewArr[i];
            tableView.frame = CGRectMake([topNameArr[i][@"weizhi"] intValue] *IPHONE_W, tableView.frame.origin.y, tableView.frame.size.width, tableView.frame.size.height);
            [tableView removeFromSuperview];
            [scroll addSubview:tableView];
            tableView.mj_header = [MJRefreshNormalHeader headerWithRefreshingBlock:^{
                [self refreshData:topNameArr[i][@"numberkey"] andPinDaoName:topNameArr[i][@"type"] andTableView:tableView];
            }];
            tableView.mj_footer = [MJRefreshAutoStateFooter footerWithRefreshingBlock:^{
                [self shanglajiazai:topNameArr[i][@"numberkey"] andtableView:tableView andTableName:topNameArr[i][@"type"]];
            }];
        }
        
        if (downCollectionArr.count == 0)
        {
            [UIView animateWithDuration:0.3 animations:^{
                self.topCollectionV.frame = CGRectMake(self.topCollectionV.frame.origin.x, self.topCollectionV.frame.origin.y, self.topCollectionV.frame.size.width, ((topCollectionArr.count - 1) / 3) * 50.0 / 667 * IPHONE_H + 80.0 / 667 * IPHONE_H);
                tianjiaBgV.frame = CGRectMake(0, CGRectGetMaxY(self.topCollectionV.frame), IPHONE_W, tianjiaBgV.frame.size.height);
                self.downCollectionV.frame = CGRectMake(0, CGRectGetMaxY(tianjiaBgV.frame), self.downCollectionV.frame.size.width, 0);
            }];
        }
        else{
            if (topCollectionArr.count == 0){
                [UIView animateWithDuration:0.3 animations:^{
                    self.topCollectionV.frame = CGRectMake(self.topCollectionV.frame.origin.x, self.topCollectionV.frame.origin.y, self.topCollectionV.frame.size.width, 0);
                    tianjiaBgV.frame = CGRectMake(0, CGRectGetMaxY(self.topCollectionV.frame), IPHONE_W, tianjiaBgV.frame.size.height);
                    self.downCollectionV.frame = CGRectMake(0, CGRectGetMaxY(tianjiaBgV.frame), self.downCollectionV.frame.size.width, ((downCollectionArr.count - 1) / 3) * 50.0 / 667 * IPHONE_H + 80.0 / 667 * IPHONE_H);
                }];
            }
            else{
                [UIView animateWithDuration:0.3 animations:^{
                    self.topCollectionV.frame = CGRectMake(self.topCollectionV.frame.origin.x, self.topCollectionV.frame.origin.y, self.topCollectionV.frame.size.width, ((topCollectionArr.count - 1) / 3) * 50.0 / 667 * IPHONE_H + 80.0 / 667 * IPHONE_H);
                    tianjiaBgV.frame = CGRectMake(0, CGRectGetMaxY(self.topCollectionV.frame), IPHONE_W, tianjiaBgV.frame.size.height);
                    self.downCollectionV.frame = CGRectMake(0, CGRectGetMaxY(tianjiaBgV.frame), self.downCollectionV.frame.size.width, ((downCollectionArr.count - 1) / 3 + 1) * 60.0 / 667 * IPHONE_H);
                }];
            }
            
        }
        [self.topCollectionV reloadData];
        [self.downCollectionV reloadData];
        [CommonCode writeToUserD:topCollectionArr andKey:@"topCollectionArr"];
        [CommonCode writeToUserD:downCollectionArr andKey:@"downCollectionArr"];
        [CommonCode writeToUserD:topNameArr andKey:@"topNameArr"];
        scroll.contentSize = CGSizeMake(IPHONE_W * topCollectionArr.count, IPHONE_H - 49 - 80.0 / 667 * IPHONE_H);
    }
    
    UICollectionViewCell *cell = [collectionView cellForItemAtIndexPath:indexPath];
    [cell setBackgroundColor:[UIColor greenColor]];
}

- (void)collectionView:(UICollectionView *)collectionView didDeselectItemAtIndexPath:(NSIndexPath *)indexPath {
    UICollectionViewCell *cell = [collectionView cellForItemAtIndexPath:indexPath];
    [cell setBackgroundColor:[UIColor redColor]];
}

#pragma mark - UITableViewDelegate
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    topNameArr = [CommonCode readFromUserD:@"topNameArr"];
    if (tableView.tag == 1){
        return topCollectionArr.count;
    }
    else{
        NSArray *arr;
        if (tableViewArr.count != topNameArr.count){
            arr = [[NSArray alloc]init];
        }
        else{
            if ([tableViewArr indexOfObject:tableView] > topNameArr.count) {
                if ([[CommonCode readFromUserD:[NSString stringWithFormat:@"zhuyeliebiao%@",[topNameArr firstObject][@"type"]]] isKindOfClass:[NSArray class]]){
                    arr = [NSArray arrayWithArray:[CommonCode readFromUserD:[NSString stringWithFormat:@"zhuyeliebiao%@",[topNameArr firstObject][@"type"]]]];
                }
                else{
                    arr = [[NSArray alloc]init];
                }
            }
            else{
                if ([[CommonCode readFromUserD:[NSString stringWithFormat:@"zhuyeliebiao%@",topNameArr[[tableViewArr indexOfObject:tableView]][@"type"]]] isKindOfClass:[NSArray class]]){
                    arr = [NSArray arrayWithArray:[CommonCode readFromUserD:[NSString stringWithFormat:@"zhuyeliebiao%@",topNameArr[[tableViewArr indexOfObject:tableView]][@"type"]]]];
                }
                else{
                    arr = [[NSArray alloc]init];
                }
            }
            
        }
        return arr.count;
    }
    
}
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    if (tableView == self.topTableView){
        return (IPHONE_W - 70.0) / 5;
    }
    else{
        if (indexPath.row == 0) {
            NSString *pindaoID;
            NSString *parent;
            if ([tableViewArr indexOfObject:tableView] > topNameArr.count) {
                pindaoID = [topNameArr firstObject][@"numberkey"];
                parent = [topNameArr firstObject][@"parent"];
            }
            else{
                pindaoID = topNameArr[[tableViewArr indexOfObject:tableView]][@"numberkey"];
                parent = topNameArr[[tableViewArr indexOfObject:tableView]][@"parent"];
            }
            
           
            if (parent == nil) {
                parent = @"0";
            }
            //本地
            if (![parent isEqualToString:@"0"] || [pindaoID isEqualToString:@"19"]){
                //120 + 30 + 20
                return  175.0 / 667 * IPHONE_H;
            }
            //时政、社会、娱乐、体育、财经、科技、国际、奇闻、
            else if ([pindaoID isEqualToString:@"14"] || [pindaoID isEqualToString:@"10"] || [pindaoID isEqualToString:@"4"] || [pindaoID isEqualToString:@"5"] || [pindaoID isEqualToString:@"6"] || [pindaoID isEqualToString:@"7"] || [pindaoID isEqualToString:@"8"] || [pindaoID isEqualToString:@"3"]) {
                return 150.0 / 667 * IPHONE_H;
            }
            else{
               return 120.0 / 667 * IPHONE_H;
            }
        }
        else{
            return 120.0 / 667 * IPHONE_H;
        }
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    if (tableView.tag == 1){
        static NSString *topTableViewCellIdentify = @"topTableViewCellIdentify";
        UITableViewCell *cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:topTableViewCellIdentify];
        if (!cell){
            cell = [tableView dequeueReusableCellWithIdentifier:topTableViewCellIdentify];
        }
        UILabel *numLab = [[UILabel alloc]initWithFrame:CGRectMake(0, 0, IPHONE_W / 6, 35.0)];
        numLab.text = topCollectionArr[indexPath.row][@"type"];
        numLab.textColor = nTextColorMain;
        numLab.backgroundColor = [UIColor whiteColor];
        
        
        UIView *downLine = [[UIView alloc]initWithFrame:CGRectMake(IPHONE_W / 12 - 7, 35, 14, 3)];
        [downLine setBackgroundColor:nMainColor];
        [cell.contentView addSubview:downLine];
        downLine.hidden = YES;
        if (indexPath == DangqianIndexPath){
            if (IS_IPAD) {
                numLab.font = [UIFont systemFontOfSize:20.0f];
            }
            else{
                numLab.font = [UIFont systemFontOfSize:18.0f];
            }
            numLab.textColor = nTextColorMain;
            downLine.hidden = NO;
        }
        else{
            if (IS_IPAD) {
                numLab.font = [UIFont systemFontOfSize:18.0f];
            }
            else{
                numLab.font = [UIFont systemFontOfSize:16.0f];
            }
            numLab.textColor = nTextColorSub;
            downLine.hidden = YES;
        }
        numLab.textAlignment = NSTextAlignmentCenter;
        numLab.tag = 1;
        [cell.contentView addSubview:numLab];
        [cell.contentView addSubview:downLine];
        
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        cell.contentView.transform = CGAffineTransformMakeRotation(M_PI / 2);
        cell.contentView.backgroundColor = [UIColor whiteColor];
        return cell;
    }
    else{
        //TODO:新闻播报、更多新闻
        NSArray *arr = [NSArray arrayWithArray:[CommonCode readFromUserD:[NSString stringWithFormat:@"zhuyeliebiao%@",topNameArr[[tableViewArr indexOfObject:tableView]][@"type"]]]];
        self.tableViewDataArr = arr;
        
        static NSString *identify = @"identify";
        UITableViewCell *cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identify];
        if (!cell){
            cell = [tableView dequeueReusableCellWithIdentifier:identify];
        }
        
        NSString *pindaoID = topNameArr[[tableViewArr indexOfObject:tableView]][@"numberkey"];
        NSString *parent = topNameArr[[tableViewArr indexOfObject:tableView]][@"parent"];
        if (parent == nil) {
            parent = @"0";
        }

        CGFloat offsetY = 0;
        //新闻播报
        UIButton *newReport = [UIButton buttonWithType:UIButtonTypeCustom];
        [newReport setFrame:CGRectMake(20.0 / 375 * IPHONE_W, 10, 60, 24)];
        [newReport setTitleColor:[UIColor grayColor] forState:UIControlStateNormal];
        [newReport setTitle:@"新闻播报" forState:UIControlStateNormal];
        [newReport.layer setBorderWidth:1.0f];
        [newReport.titleLabel setFont:gFontMain12];
        [newReport.layer setBorderColor:[UIColor lightGrayColor].CGColor];
        [newReport.layer setMasksToBounds:YES];
        [newReport.layer setCornerRadius:5.0f];
        [newReport addTarget:self action:@selector(newreportAction:) forControlEvents:UIControlEventTouchUpInside];
        //更多节目
        UIButton *moreProgram = [UIButton buttonWithType:UIButtonTypeCustom];
        [moreProgram setFrame:CGRectMake(90.0 / 375 * IPHONE_W, 10, 60, 24)];
        [moreProgram setTitleColor:[UIColor grayColor] forState:UIControlStateNormal];
        [moreProgram setTitle:@"更多节目" forState:UIControlStateNormal];
        [moreProgram.layer setBorderWidth:1.0f];
        [moreProgram.titleLabel setFont:gFontMain12];
        [moreProgram.layer setBorderColor:[UIColor lightGrayColor].CGColor];
        [moreProgram.layer setMasksToBounds:YES];
        [moreProgram.layer setCornerRadius:5.0f];
        [moreProgram addTarget:self action:@selector(moreProgramAction:) forControlEvents:UIControlEventTouchUpInside];
        
        //本地
        if (indexPath.row == 0 && ([pindaoID isEqualToString:@"19"] || ![parent isEqualToString:@"0"])){
            offsetY = 50;
            
            UIButton *selectedCity = [UIButton buttonWithType:UIButtonTypeCustom];
            [selectedCity setFrame:CGRectMake((SCREEN_WIDTH - 80) / 2, 10, 80, 16)];
            [selectedCity setBackgroundImage:[UIImage imageNamed:@"changecity"] forState:UIControlStateNormal];
            selectedCity.accessibilityLabel = @"切换城市";
            [selectedCity setImageEdgeInsets:UIEdgeInsetsMake(10, 0, 5, 0)];

            [selectedCity addTarget:self action:@selector(selectedCity:) forControlEvents:UIControlEventTouchUpInside];
            
            [newReport setFrame:CGRectMake(20, 30, 60, 24)];
            [moreProgram setFrame:CGRectMake(90, 30, 60, 24)];
            [cell.contentView addSubview:selectedCity];
            [cell.contentView addSubview:newReport];
            [cell.contentView addSubview:moreProgram];
        }
        else if (indexPath.row == 0 && ([pindaoID isEqualToString:@"14"] || [pindaoID isEqualToString:@"10"] || [pindaoID isEqualToString:@"4"] || [pindaoID isEqualToString:@"5"] || [pindaoID isEqualToString:@"6"] || [pindaoID isEqualToString:@"7"] || [pindaoID isEqualToString:@"8"] || [pindaoID isEqualToString:@"3"])) {
            offsetY = 30;
            
            [newReport setFrame:CGRectMake(20, 10, 60, 24)];
            [moreProgram setFrame:CGRectMake(90, 10, 60, 24)];
            [cell.contentView addSubview:newReport];
            [cell.contentView addSubview:moreProgram];
        }
        else{
            offsetY = 0;
        }
        
        //图片
        UIImageView *imgLeft = [[UIImageView alloc]initWithFrame:CGRectMake(SCREEN_WIDTH - 125.0 / 375 * IPHONE_W, 19 + offsetY, 105.0 / 375 * IPHONE_W,   84.72 / 375 *IPHONE_W)];
        if (IS_IPAD) {
            [imgLeft setFrame:CGRectMake(SCREEN_WIDTH - 125.0 / 375 * IPHONE_W, 19 + offsetY, 105.0 / 375 * IPHONE_W, 70.0 / 375 *IPHONE_W)];
        }

        if ([NEWSSEMTPHOTOURL(arr[indexPath.row][@"smeta"])  rangeOfString:@"http"].location != NSNotFound){
            [imgLeft sd_setImageWithURL:[NSURL URLWithString:NEWSSEMTPHOTOURL(arr[indexPath.row][@"smeta"])]];
            //placeholderImage:[UIImage imageNamed:@"thumbnailsdefault"]
        }
        else{
            NSString *str = USERPHOTOHTTPSTRINGZhuBo(NEWSSEMTPHOTOURL(arr[indexPath.row][@"smeta"]));
            [imgLeft sd_setImageWithURL:[NSURL URLWithString:str]];
            //placeholderImage:[UIImage imageNamed:@"thumbnailsdefault"]
        }
        [cell.contentView addSubview:imgLeft];
        imgLeft.contentMode = UIViewContentModeScaleAspectFill;
        imgLeft.clipsToBounds = YES;
        
        //标题
        UILabel *titleLab = [[UILabel alloc]initWithFrame:CGRectMake(20.0 / 375 * IPHONE_W, 16.0 / 667 * IPHONE_H + offsetY,  SCREEN_WIDTH - 155.0 / 375 * IPHONE_W, 21.0 / 667 *IPHONE_H)];
        titleLab.text = arr[indexPath.row][@"post_title"];
        titleLab.textColor = [UIColor blackColor];
        if ([[CommonCode readFromUserD:@"yitingguoxinwenID"] isKindOfClass:[NSArray class]]){
            NSArray *yitingguoArr = [NSArray arrayWithArray:[CommonCode readFromUserD:@"yitingguoxinwenID"]];
            for (int i = 0; i < yitingguoArr.count - 1; i ++ ){
                if ([arr[indexPath.row][@"id"] isEqualToString:yitingguoArr[i]]){
                    if ([[CommonCode readFromUserD:@"dangqianbofangxinwenID"] isEqualToString:arr[indexPath.row][@"id"]]){
                        titleLab.textColor = gMainColor;
                        break;
                    }
                    else{
                        titleLab.textColor = [[UIColor grayColor]colorWithAlphaComponent:0.7f];
                        break;
                    }
                }
                else{
                    titleLab.textColor = nTextColorMain;
                }
            }
        }
        if ([[CommonCode readFromUserD:@"dangqianbofangxinwenID"] isEqualToString:arr[indexPath.row][@"id"]]){
            titleLab.textColor = gMainColor;
        }
        //
        //        }
        titleLab.textAlignment = NSTextAlignmentLeft;
        titleLab.font = [UIFont boldSystemFontOfSize:17.0f ];
        [cell.contentView addSubview:titleLab];
        [titleLab setNumberOfLines:3];
        titleLab.lineBreakMode = NSLineBreakByWordWrapping;
        CGSize size = [titleLab sizeThatFits:CGSizeMake(titleLab.frame.size.width, MAXFLOAT)];
        titleLab.frame = CGRectMake(titleLab.frame.origin.x, titleLab.frame.origin.y, titleLab.frame.size.width, size.height);
        if (IS_IPAD) {
            //正文
            UILabel *detailNews = [[UILabel alloc]initWithFrame:CGRectMake(20.0 / 375 * IPHONE_W, titleLab.frame.origin.y + titleLab.frame.size.height + 20.0 / 667 * SCREEN_HEIGHT, titleLab.frame.size.width, 21.0 / 667 *IPHONE_H)];
            detailNews.text = arr[indexPath.row][@"post_excerpt"];
            detailNews.textColor = gTextColorSub;
            detailNews.font = [UIFont systemFontOfSize:15.0f];
            [cell.contentView addSubview:detailNews];
        }
        
        //日期
        UILabel *riqiLab = [[UILabel alloc]initWithFrame:CGRectMake(20.0 / 375 * IPHONE_W, 86.0 / 667 *IPHONE_H + offsetY, 135.0 / 375 * IPHONE_W, 21.0 / 667 *IPHONE_H)];
        NSDate *date = [NSDate dateFromString:arr[indexPath.row][@"post_modified"]];
        riqiLab.text = [date showTimeByTypeA];
        riqiLab.textColor = nSubColor;
        riqiLab.font = [UIFont systemFontOfSize:13.0f];
        [cell.contentView addSubview:riqiLab];
        //大小
        UILabel *dataLab = [[UILabel alloc]initWithFrame:CGRectMake(SCREEN_WIDTH - 213.0 / 375 * IPHONE_W, 86.0 / 667 *IPHONE_H + offsetY, 45.0 / 375 * IPHONE_W, 21.0 / 667 *IPHONE_H)];
        dataLab.text = [NSString stringWithFormat:@"%.1lf%@",[arr[indexPath.row][@"post_size"] intValue] / 1024.0 / 1024.0,@"M"];
        dataLab.textColor = nSubColor;
        dataLab.font = [UIFont systemFontOfSize:13.0f];
        dataLab.textAlignment = NSTextAlignmentCenter;
        [cell.contentView addSubview:dataLab];
        //下载
        UIButton *download = [UIButton buttonWithType:UIButtonTypeCustom];
        [download setFrame:CGRectMake(CGRectGetMaxX(dataLab.frame), 86.0 / 667 *IPHONE_H + offsetY, 30.0 / 667 *IPHONE_H, 30.0 / 667 *IPHONE_H)];
        [download setImage:[UIImage imageNamed:@"download_grey"] forState:UIControlStateNormal];
        [download setImageEdgeInsets:UIEdgeInsetsMake(0, 0, 10, 10)];
        [download setTag:(indexPath.row + 100)];
        [download addTarget:self action:@selector(downloadNewsAction:) forControlEvents:UIControlEventTouchUpInside];
        download.accessibilityLabel = @"下载";
        [cell.contentView addSubview:download];
        
        UIView *line = [[UIView alloc]initWithFrame:CGRectMake(20.0 / 375 * SCREEN_WIDTH, CGRectGetMaxY(dataLab.frame) + 12.0 / 667 * SCREEN_HEIGHT, SCREEN_WIDTH - 40.0 / 375 * SCREEN_WIDTH, 0.5)];
        [line setBackgroundColor:nMineNameColor];
        [cell.contentView addSubview:line];
        
        
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        
        return cell;
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    if (tableView.tag == 1){
        UITableView *yesTopTab = (UITableView *)[tableViewArr objectAtIndex:indexPath.row];
        for (UITableView *NoTopTab in tableViewArr){
            if (NoTopTab == yesTopTab){
                NoTopTab.scrollsToTop = YES;
            }
            else{
                NoTopTab.scrollsToTop = NO;
            }
        }
        if (dangqianTableView){
            UITableView *yaoguanbiTableView = dangqianTableView;
            if (quanjvIndexPath != indexPath){
                if (quanjvIndexPath){
                    UITableViewCell *yaoguanbiCell = [yaoguanbiTableView cellForRowAtIndexPath:quanjvIndexPath];
                    UIButton *yaoguanbiBtn = (UIButton *)[yaoguanbiCell.contentView viewWithTag:quanjvIndexPath.row + 1000];
                    yaoguanbiBtn.selected = NO;
                    [UIView animateWithDuration:0.3f animations:^{
                        yaoguanbiCell.frame = CGRectMake(0, yaoguanbiCell.frame.origin.y, yaoguanbiCell.frame.size.width, yaoguanbiCell.frame.size.height);
                    }];
                    quanjvIndexPath = nil;
                    dangqianTableView = nil;
                }
            }
        }
        
        UIScrollView *scrollV = (UIScrollView *)[self.view viewWithTag:-1];
        [scrollV scrollRectToVisible:CGRectMake(indexPath.row * scrollV.frame.size.width, 0.0, scrollV.frame.size.width,scrollV.frame.size.height) animated:NO];
        
        [tableView scrollToRowAtIndexPath:indexPath atScrollPosition:UITableViewScrollPositionMiddle animated:YES];
        DangqianIndexPath = indexPath;
        Exterm_id = topCollectionArr[indexPath.row][@"numberkey"];
//        UITableView *tableView = (UITableView *)tableViewArr[indexPath.row];
        
        //只在第一次滚到到的时候自动刷新
        NSMutableArray *isFirstLoad = [[CommonCode readFromUserD:@"isFirstLoad"] mutableCopy];
        BOOL isFirstloading = NO;
        if (isFirstLoad == nil) {
            isFirstLoad = [NSMutableArray array];
            [isFirstLoad addObject:Exterm_id];
            [CommonCode writeToUserD:isFirstLoad andKey:@"isFirstLoad"];
            [yesTopTab.mj_header beginRefreshing];
        }
        else{
            for (int i = 0; i < [isFirstLoad count]; i ++) {
                if ([isFirstLoad[i] isEqualToString:Exterm_id]) {
                    isFirstloading = NO;
                    break;
                }
                else{
                    isFirstloading = YES;
                    continue;
                }
                
            }
            if (isFirstloading) {
                [isFirstLoad addObject:Exterm_id];
                [CommonCode writeToUserD:isFirstLoad andKey:@"isFirstLoad"];
                [yesTopTab.mj_header beginRefreshing];
            }
        }
        
        
        [tableView reloadData];
    }
    else{
        if (quanjvIndexPath){
            UITableViewCell *yaoguanbiCell = [tableView cellForRowAtIndexPath:quanjvIndexPath];
            UIButton *yaoguanbiBtn = (UIButton *)[yaoguanbiCell.contentView viewWithTag:quanjvIndexPath.row + 1000];
            yaoguanbiBtn.selected = NO;
            [UIView animateWithDuration:0.3f animations:^{
                yaoguanbiCell.frame = CGRectMake(0, yaoguanbiCell.frame.origin.y, yaoguanbiCell.frame.size.width, yaoguanbiCell.frame.size.height);
            }];
            quanjvIndexPath = nil;
        }
        
        NSArray *arr = [NSArray arrayWithArray:[CommonCode readFromUserD:[NSString stringWithFormat:@"zhuyeliebiao%@",topNameArr[[tableViewArr indexOfObject:tableView]][@"type"]]]];
        if ([[CommonCode readFromUserD:@"dangqianbofangxinwenID"] isEqualToString:arr[indexPath.row][@"id"]]){
            self.hidesBottomBarWhenPushed = YES;
            [self.navigationController.navigationBar setHidden:YES];
            [self.navigationController pushViewController:[bofangVC shareInstance] animated:YES];
            self.hidesBottomBarWhenPushed = NO;
            if ([bofangVC shareInstance].isPlay) {
                
            }
            else{
                [[bofangVC shareInstance] doplay2];
            }
        }
        else{
            dangqianxuyaoJiaZaiDeTableViewType = [NSString stringWithFormat:@"page%@",topNameArr[[tableViewArr indexOfObject:tableView]][@"type"]];
            xuyaoJiaZaidePinDaoID = topNameArr[[tableViewArr indexOfObject:tableView]][@"numberkey"];
            xuyaoJiaZaidePinDaoTag = tableView.tag;
            [bofangVC shareInstance].newsModel.jiemuID = arr[indexPath.row][@"id"];
            [bofangVC shareInstance].newsModel.Titlejiemu = arr[indexPath.row][@"post_title"];
            RTLog(@"%@",[bofangVC shareInstance].newsModel.Titlejiemu);
            [bofangVC shareInstance].newsModel.RiQijiemu = arr[indexPath.row][@"post_date"];
            [bofangVC shareInstance].newsModel.ImgStrjiemu = arr[indexPath.row][@"smeta"];
            [bofangVC shareInstance].newsModel.post_lai = arr[indexPath.row][@"post_lai"];
            [bofangVC shareInstance].newsModel.post_news = arr[indexPath.row][@"post_act"][@"id"];
            [bofangVC shareInstance].newsModel.jiemuName = arr[indexPath.row][@"post_act"][@"name"];
            [bofangVC shareInstance].newsModel.jiemuDescription = arr[indexPath.row][@"post_act"][@"description"];
            [bofangVC shareInstance].newsModel.jiemuImages = arr[indexPath.row][@"post_act"][@"images"];
            [bofangVC shareInstance].newsModel.jiemuFan_num = arr[indexPath.row][@"post_act"][@"fan_num"];
            [bofangVC shareInstance].newsModel.jiemuMessage_num = arr[indexPath.row][@"post_act"][@"message_num"];
            [bofangVC shareInstance].newsModel.jiemuIs_fan = arr[indexPath.row][@"post_act"][@"is_fan"];
            [bofangVC shareInstance].newsModel.post_mp = arr[indexPath.row][@"post_mp"];
            [bofangVC shareInstance].newsModel.post_time = arr[indexPath.row][@"post_time"];
            [bofangVC shareInstance].newsModel.post_keywords = arr[indexPath.row][@"post_keywords"];
            [bofangVC shareInstance].newsModel.url = arr[indexPath.row][@"url"];
            [bofangVC shareInstance].iszhuboxiangqing = NO;
            dangqianbofangTable = tableView;
            [bofangVC shareInstance].yinpinzongTime.text = [[bofangVC shareInstance] convertStringWithTime:[arr[indexPath.row][@"post_time"] intValue] / 1000];
            ExcurrentNumber = (int)indexPath.row;
            [bofangVC shareInstance].newsModel.ImgStrjiemu = arr[indexPath.row][@"smeta"];
            [bofangVC shareInstance].newsModel.ZhengWenjiemu = arr[indexPath.row][@"post_excerpt"];
            [bofangVC shareInstance].newsModel.praisenum = arr[indexPath.row][@"praisenum"];
            [bofangVC shareInstance].newsModel.post_keywords = arr[indexPath.row][@"post_keywords"];
            [bofangVC shareInstance].newsModel.url = arr[indexPath.row][@"url"];
            [[bofangVC shareInstance].tableView reloadData];
            [Explayer replaceCurrentItemWithPlayerItem:[[AVPlayerItem alloc]initWithURL:[NSURL URLWithString:arr[indexPath.row][@"post_mp"]]]];
            if ([bofangVC shareInstance].isPlay || ExIsKaiShiBoFang == NO) {
                
            }
            else{
                [[bofangVC shareInstance] doplay2];
            }
            
            ExisRigester = YES;
            ExIsKaiShiBoFang = YES;

            ExwhichBoFangYeMianStr = @"shouyebofang";
            self.hidesBottomBarWhenPushed = YES;
            [self.navigationController.navigationBar setHidden:YES];
            [self.navigationController pushViewController:[bofangVC shareInstance ] animated:YES];
            self.hidesBottomBarWhenPushed = NO;
            [[NSNotificationCenter defaultCenter] postNotificationName:@"yuanpanzhuan" object:nil];
            [[NSNotificationCenter defaultCenter] postNotificationName:@"qiehuanxinwen" object:nil];
            [CommonCode writeToUserD:arr andKey:@"zhuyeliebiao"];
            [CommonCode writeToUserD:arr[indexPath.row][@"id"] andKey:@"dangqianbofangxinwenID"];
            
            if ([[CommonCode readFromUserD:@"yitingguoxinwenID"] isKindOfClass:[NSArray class]])
            {
                NSMutableArray *yitingguoArr = [NSMutableArray arrayWithArray:[CommonCode readFromUserD:@"yitingguoxinwenID"]];
                [yitingguoArr addObject:arr[indexPath.row][@"id"]];
                [CommonCode writeToUserD:yitingguoArr andKey:@"yitingguoxinwenID"];
            }
            else{
                NSMutableArray *yitingguoArr = [NSMutableArray array];
                [yitingguoArr addObject:arr[indexPath.row][@"id"]];
                [CommonCode writeToUserD:yitingguoArr andKey:@"yitingguoxinwenID"];
            }
            
            [tableView reloadData];
            [[NSNotificationCenter defaultCenter] postNotificationName:@"dianjihougaibiangezhongyanse" object:nil];
        }
    }
}
#pragma mark -- 轮播图代理
//- (void)cycleScrollView:(TBCircleScrollView *)cycleScrollView didSelectImageView:(NSInteger)index{
//    NSLog(@"index = %@",index);
//}


#pragma mark - UIScrollViewDelegate
//一旦滚动就一直调用 直到停止
- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView{
    
    if (scrollView.tag == -1){
        CGPoint point = scrollView.contentOffset;
        
        UITableView *tableV1 = (UITableView *)[self.view viewWithTag:1];
        NSIndexPath *indexPath = [NSIndexPath indexPathForRow:(point.x / IPHONE_W) inSection:0];
        [tableV1 scrollToRowAtIndexPath:indexPath atScrollPosition:UITableViewScrollPositionMiddle animated:YES];
        DangqianIndexPath = indexPath;
        UITableView *yesTopTab = (UITableView *)[tableViewArr objectAtIndex:indexPath.row];
        
        for (UITableView *NoTopTab in tableViewArr){
            if (NoTopTab == yesTopTab){
                NoTopTab.scrollsToTop = YES;
            }
            else{
                NoTopTab.scrollsToTop = NO;
            }
        }
        
        [tableV1 reloadData];
        //        ZZIConView *iconV = (ZZIConView *)self.iconViewArray[indexPath.row];
        //        Exterm_id = iconV.numberKey;
        Exterm_id = topCollectionArr[indexPath.row][@"numberkey"];
        //只在第一次滚到到的时候自动刷新
        NSMutableArray *isFirstLoad = [[CommonCode readFromUserD:@"isFirstLoad"] mutableCopy];
        BOOL isFirstloading = NO;
        if (isFirstLoad == nil) {
            isFirstLoad = [NSMutableArray array];
            [isFirstLoad addObject:Exterm_id];
            [CommonCode writeToUserD:isFirstLoad andKey:@"isFirstLoad"];
            [yesTopTab.mj_header beginRefreshing];
        }
        else{
            for (int i = 0; i < [isFirstLoad count]; i ++) {
                if ([isFirstLoad[i] isEqualToString:Exterm_id]) {
                    isFirstloading = NO;
                    break;
                }
                else{
                    isFirstloading = YES;
                    continue;
                }
                
            }
            if (isFirstloading) {
                [isFirstLoad addObject:Exterm_id];
                [CommonCode writeToUserD:isFirstLoad andKey:@"isFirstLoad"];
                [yesTopTab.mj_header beginRefreshing];
            }
        }
        
        if (!dangqianTableView){
            UITableView *yaoguanbiTableView = dangqianTableView;
            if (quanjvIndexPath != indexPath)
            {
                if (quanjvIndexPath)
                {
                    UITableViewCell *yaoguanbiCell = [yaoguanbiTableView cellForRowAtIndexPath:quanjvIndexPath];
                    UIButton *yaoguanbiBtn = (UIButton *)[yaoguanbiCell.contentView viewWithTag:quanjvIndexPath.row + 1000];
                    yaoguanbiBtn.selected = NO;
                    [UIView animateWithDuration:0.3f animations:^{
                        yaoguanbiCell.frame = CGRectMake(0, yaoguanbiCell.frame.origin.y, yaoguanbiCell.frame.size.width, yaoguanbiCell.frame.size.height);
                    }];
                    quanjvIndexPath = nil;
                    dangqianTableView = nil;
                }
            }
        }
    }
}

#pragma mark --- 所有和排序界面相关
- (void)shezhipaixujiemian {
    qiehuanlanmuView = [[UIView alloc]initWithFrame:CGRectMake(0, 26.0, IPHONE_W, 37.0 / 667 * IPHONE_H)];
    qiehuanlanmuView.backgroundColor = [UIColor whiteColor];
    qiehuanlanmuView.hidden = YES;
    qiehuanlanmuView.alpha = 0.0f;
//    self.navigationController.navigationItem.titleView = qiehuanlanmuView;
//    [self.view addSubview:qiehuanlanmuView];
    
    UILabel *lab = [[UILabel alloc]initWithFrame:CGRectMake(0.0 / 375 * IPHONE_W, 2.0 / 667 * IPHONE_H, IPHONE_W, 30.0 / 667 * IPHONE_H)];
    lab.text = @"频道管理";
    lab.textAlignment = NSTextAlignmentCenter;
    lab.textColor = [UIColor blackColor];
    lab.font = [UIFont boldSystemFontOfSize:17.0f];
    //    lab.alpha = 0.7f;
//    lab.backgroundColor = ColorWithRGBA(0,159,240,1);
    [qiehuanlanmuView addSubview:lab];
    
    //    UILabel *changanLab = [[UILabel alloc]initWithFrame:CGRectMake(200.0 / 375 * IPHONE_W, 12.0 / 667 * IPHONE_H, 130.0 / 375 * IPHONE_W, 22.0 / 667 * IPHONE_H)];
    //    changanLab.text = @"长按可重新排序";
    //    changanLab.textAlignment = NSTextAlignmentRight;
    //    changanLab.textColor = [UIColor whiteColor];
    //    changanLab.font = [UIFont systemFontOfSize:15.0f];
    ////    changanLab.alpha = 0.7f;
    //    changanLab.backgroundColor = ColorWithRGBA(0,159,240,1);
    //    [qiehuanlanmuView addSubview:changanLab];
    
    qiehuanbeijingView = [[UIView alloc]initWithFrame:CGRectMake(0, 62.0 / 667 * IPHONE_H, IPHONE_W, IPHONE_H)];
    qiehuanbeijingView.hidden = YES;
    qiehuanbeijingView.alpha = 0.0f;
    qiehuanbeijingView.backgroundColor = [UIColor whiteColor];
    
    shanchuBgV = [[UIView alloc]initWithFrame:CGRectMake(0, 0, IPHONE_W, 30.0 / 667 * IPHONE_H)];
    shanchuBgV.backgroundColor = ColorWithRGBA(207, 207, 207, 1);
    [qiehuanbeijingView addSubview:shanchuBgV];
    UILabel *shanchulab = [[UILabel alloc]initWithFrame:CGRectMake(20, 0, IPHONE_W - 20, 30.0 / 667 * IPHONE_H)];
    shanchulab.text = @"我的频道";
    [shanchuBgV addSubview:shanchulab];
    shanchulab.font = [UIFont systemFontOfSize:13.0f];
    shanchulab.backgroundColor = [UIColor clearColor];
    shanchulab.textAlignment = NSTextAlignmentLeft;
    
    tianjiaBgV = [[UIView alloc]initWithFrame:CGRectMake(0 , CGRectGetMaxY(self.topCollectionV.frame), IPHONE_W, 30.0 / 667 * IPHONE_H)];
    tianjiaBgV.backgroundColor = ColorWithRGBA(207, 207, 207, 1);
    [qiehuanbeijingView addSubview:tianjiaBgV];
    UILabel *tianjialab = [[UILabel alloc]initWithFrame:CGRectMake(20, 0, IPHONE_W - 20, 30.0 / 667 * IPHONE_H)];
    tianjialab.text = @"添加频道";
    [tianjiaBgV addSubview:tianjialab];
    tianjialab.font = [UIFont systemFontOfSize:13.0f];
    tianjialab.backgroundColor = [UIColor clearColor];
    tianjialab.textAlignment = NSTextAlignmentLeft;
    
    //    for (int i = 0; i < topNameArr.count; i ++ )
    //    {
    //
    ////        ZZIConView *iconView = [[ZZIConView alloc]initWithColor:[UIColor grayColor] andtext:topNameArr[i][@"type"] andnumberKey:topNameArr[i][@"numberkey"]];
    ////        iconView.delegate = self;
    ////        [iconView addTarget:self action:@selector(iconViewClick:) forControlEvents:UIControlEventTouchUpInside];
    ////        [qiehuanbeijingView addSubview:iconView];
    ////        [self.iconViewArray addObject:iconView];
    //
    //    }
    //    [self layoutIconViews];
    [self.view addSubview:qiehuanbeijingView];
    [qiehuanbeijingView addSubview:self.topCollectionV];
    [qiehuanbeijingView addSubview:self.downCollectionV];
}

//- (void)iconViewClick:(ZZIConView *)iconView {
//    NSLog(@"%@", iconView.textLabel.text);
//}
//- (void)layoutIconViews {
//    /**
//     拖动小视图时，如果这个小视图和其他小视图相交了，要重新排版
//     */
////    [self layoutIconViewsWithShakingIconView:nil];
//}
// 程序刚开始，或手指头拖动小视图时都需要排版，而当拖动一个小视图和其他小视图有交集时，要知道哪个小视图在摇动
////- (void)layoutIconViewsWithShakingIconView:(ZZIConView *)shakingIconView {
//    float xMargin = 30; // 两侧（距边界）水平间距
//    float yMargin = 30; // （距边界）顶部间距
//
//    // 图标（水平方向）之间的间距
//    float xPadding = (self.view.frame.size.width - 2*xMargin - NUM_OF_COLUMN*kZZIconViewLength)/(NUM_OF_COLUMN-1);
//    float yPadding = 50;
//
//    for (int i = 0; i < self.iconViewArray.count; i++) {
//        ZZIConView *iconView = [self.iconViewArray objectAtIndex:i];
//        if (shakingIconView && iconView == shakingIconView) {
//            continue; // 不对晃动的iconView本身排版 （晃动的iconView正在用户的拖动中）
//        }
//        float originX = xMargin + (i%NUM_OF_COLUMN)*(kZZIconViewLength+xPadding);
//        float originY = yMargin + (i/NUM_OF_COLUMN)*(kZZIconViewLength+yPadding);
//        CGRect frame = iconView.frame;
//        frame.origin.x = originX;
//        frame.origin.y = originY;
//        iconView.frame = frame;
//    }
//}
//// 当shakingIconView不等于nil时，说明在移动过程中
//// 如果shakingIconView传过来是nil, 说明手指头已经不处于移动状态了
//- (void)layoutIconViewsWithShakingIconView:(ZZIConView *)shakingIconView animation:(BOOL)animation {
//    if (shakingIconView) { // 移动过程中
//        if (animation) {
//            [UIView animateWithDuration:0.4 animations:^{
//                [self layoutIconViewsWithShakingIconView:shakingIconView]; // 排版加入动画中
//            } completion:nil];
//        } else {
//            [self layoutIconViewsWithShakingIconView:shakingIconView];
//        }
//    } else { // 不处于移动状态
//        if (animation) {
//            [UIView animateWithDuration:0.4 animations:^{
//                [self layoutIconViewsWithShakingIconView:nil];
//            } completion:nil];
//        } else {
//            [self layoutIconViewsWithShakingIconView:nil];
//        }
//    }
//}

//#pragma mark - <ZZIConViewDelegate>
//// 移动
//- (void)iconViewMove:(ZZIConView *)shakingView {
//    if (shakingView) {
//        // 查看晃动的视图和其他视图有没有交集，如果相交的话，交换这两个视图的位置，并且排版
//        // 实现方法：判断shakingView矩形和数组_iconViewArray中的每一个对象frame是否有重叠（有交集），改变这两个对象在数组_iconViewArray中的位置，排版
//        for (int i = 0; i < self.iconViewArray.count; i++) {
//            ZZIConView *iconView = (ZZIConView*)[self.iconViewArray objectAtIndex:i];
//            if (iconView != shakingView) {
//                // 判断是否重叠s
//                if (CGRectIntersectsRect(shakingView.frame, iconView.frame)) {
//                    // 交换这两个对象在数组self.iconViewArray中的位置
//                    [self.iconViewArray exchangeObjectAtIndex:[self.iconViewArray indexOfObject:shakingView] withObjectAtIndex:[self.iconViewArray indexOfObject:iconView]];
//
//                    // 排版（因为排版根据数组内容来排版的）
//                    [self layoutIconViewsWithShakingIconView:shakingView animation:YES];
//                }
//            }
//        }
//    }
//}

//// 停止
//- (void)iconViewStopMove:(ZZIConView *)shakingView {
//    [self layoutIconViewsWithShakingIconView:nil animation:YES];
//}
#pragma mark - getter

- (NSArray *)tableViewDataArr{
    if (!_tableViewDataArr) {
        _tableViewDataArr = [NSArray new];
    }
    return _tableViewDataArr;
}

- (UICollectionView *)topCollectionV{
    if (!_topCollectionV){
        UICollectionViewFlowLayout *flowLayout = [[UICollectionViewFlowLayout alloc]init];
        flowLayout.itemSize = CGSizeMake(105.0 / 375 * IPHONE_W, 40.0 / 667 * IPHONE_H);
        flowLayout.minimumLineSpacing = 20.0 / 375 * IPHONE_W;
        flowLayout.minimumInteritemSpacing = 10.0 / 667 * IPHONE_H;
        flowLayout.sectionInset = UIEdgeInsetsMake(10.0 / 667 * IPHONE_H, 10.0 / 375 * IPHONE_W, 10.0 / 667 * IPHONE_H, 10.0 / 375 * IPHONE_W);
        _topCollectionV = [[UICollectionView alloc]initWithFrame:CGRectMake(0, 30.0 / 667 * IPHONE_H, IPHONE_W, ((topCollectionArr.count - 1) / 3) * 50.0 / 667 * IPHONE_H + 80.0 / 667 * IPHONE_H) collectionViewLayout:flowLayout];
        _topCollectionV.scrollsToTop = NO;
        _topCollectionV.backgroundColor = [UIColor whiteColor];
        [_topCollectionV registerClass:[paixuColleCtionViewCell class] forCellWithReuseIdentifier:@"paixuColleCtionViewCell"];
        _topCollectionV.delegate = self;
        _topCollectionV.dataSource = self;
        _topCollectionV.tag = 1;
    }
    return _topCollectionV;
}

- (UICollectionView *)downCollectionV{
    if (!_downCollectionV){
        UICollectionViewFlowLayout *flowLayout = [[UICollectionViewFlowLayout alloc]init];
        flowLayout.itemSize = CGSizeMake(105.0 / 375 * IPHONE_W, 40.0 / 667 * IPHONE_H);
        flowLayout.minimumLineSpacing = 20.0 / 375 * IPHONE_W;
        flowLayout.minimumInteritemSpacing = 10.0 / 667 * IPHONE_H;
        flowLayout.sectionInset = UIEdgeInsetsMake(10.0 / 667 * IPHONE_H, 10.0 / 375 * IPHONE_W, 10.0 / 667 * IPHONE_H, 10.0 / 375 * IPHONE_W);
        _downCollectionV.scrollsToTop = NO;
        if (downCollectionArr.count == 0)
        {
            _downCollectionV = [[UICollectionView alloc]initWithFrame:CGRectMake(0, CGRectGetMaxY(self.topCollectionV.frame) + 30.0 / 667 * IPHONE_H, IPHONE_W, 0) collectionViewLayout:flowLayout];
        }else
        {
            _downCollectionV = [[UICollectionView alloc]initWithFrame:CGRectMake(0, CGRectGetMaxY(self.topCollectionV.frame) + 30.0 / 667 * IPHONE_H, IPHONE_W, ((downCollectionArr.count - 1) / 3) * 50.0 / 667 * IPHONE_H + 80.0 / 667 * IPHONE_H) collectionViewLayout:flowLayout];
        }
        
        
        _downCollectionV.backgroundColor = [UIColor whiteColor];
        [_downCollectionV registerClass:[paixuColleCtionViewCell class] forCellWithReuseIdentifier:@"paixuColleCtionViewCell"];
        _downCollectionV.delegate = self;
        _downCollectionV.dataSource = self;
        _downCollectionV.tag = 2;
    }
    return _downCollectionV;
}

- (UITableView *)topTableView{
    if (!_topTableView){
        _topTableView = [[UITableView alloc]initWithFrame:CGRectMake(156.0, - 72.0, 44.0, IPHONE_W - 60.0) style:UITableViewStylePlain];
        if (IS_IPAD) {
            
            [_topTableView setFrame:CGRectMake(352.0, - 268.0, 44.0, IPHONE_W - 60.0)];
        }
        else if (TARGETED_DEVICE_IS_IPHONE_736){
            [_topTableView setFrame:CGRectMake(176.0, - 92.0, 44.0, IPHONE_W - 60.0)];
        }
        else if (TARGETED_DEVICE_IS_IPHONE_667){
            [_topTableView setFrame:CGRectMake(156.0, - 72.0, 44.0, IPHONE_W - 60.0)];
        }
        else if (TARGETED_DEVICE_IS_IPHONE_568){
            [_topTableView setFrame:CGRectMake(128.0, - 44.0, 44.0, IPHONE_W - 60.0)];
        }
        
        // x y w h >  x, y, ,
        
        _topTableView.delegate = self;
        _topTableView.dataSource = self;
        _topTableView.scrollsToTop = NO;
        _topTableView.transform = CGAffineTransformMakeRotation(-M_PI_2);
        _topTableView.showsVerticalScrollIndicator = NO;
        _topTableView.tag = 1;
        _topTableView.backgroundColor = [UIColor whiteColor];
        _topTableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    }
    return _topTableView;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (UIStatusBarStyle)preferredStatusBarStyle{
    return UIStatusBarStyleLightContent;
}

- (NSMutableDictionary *)pushNewsInfo {
    if (!_pushNewsInfo) {
        _pushNewsInfo = [NSMutableDictionary new];
    }
    return _pushNewsInfo;
}
#pragma  mark - 下拉刷新数据
- (void)refreshData:(NSString *)pindaoID andPinDaoName:(NSString *)pindaoName andTableView:(UITableView *)tableView{
    
    pindaoID = Exterm_id;
    //推荐
    if ([pindaoID isEqualToString:@"-1"]){
        NSString *accessToken;
        if (ExdangqianUser.length == 0 || ExdangqianUser == nil){
            accessToken = nil;
        }
        else{
            accessToken = [DSE encryptUseDES:ExdangqianUser];
        }
        [NetWorkTool getTuiJianWithKeyWords:nil andaccessToken:accessToken andpage:@"1" andlimit:@"15" sccess:^(NSDictionary *responseObject) {
            if ([responseObject[@"results"] isKindOfClass:[NSArray class]])
            {
                TouListArr = [[NSMutableArray alloc]initWithArray:responseObject[@"results"]];
                [CommonCode writeToUserD:TouListArr andKey:[NSString stringWithFormat:@"zhuyeliebiao%@",pindaoName]];
                [CommonCode writeToUserD:TouListArr andKey:@"zhuyeliebiao"];
            }
            ExnumberPage = 1;
            //            UITableView *tableV = (UITableView *)[scroll viewWithTag:tableTag];
            [tableView reloadData];
            [tableView.mj_header endRefreshing];
            [CommonCode writeToUserD:[NSString stringWithFormat:@"1"] andKey:[NSString stringWithFormat:@"page%@",topNameArr[[tableViewArr indexOfObject:tableView]][@"type"]]];
        } failure:^(NSError *error) {
            NSLog(@"error = %@",error);
            [tableView.mj_header endRefreshing];
        }];
    }
    //头条
    else if ([pindaoID isEqualToString:@"1"]){
        NSString *accessToken;
        if (ExdangqianUser.length == 0 || ExdangqianUser == nil){
            accessToken = nil;
        }
        else{
            accessToken = [DSE encryptUseDES:ExdangqianUser];
        }
        [NetWorkTool getTouTiaoListWithaccessToken:accessToken andPage:@"1" andLimit:@"15" sccess:^(NSDictionary *responseObject) {
            if ([responseObject[@"results"] isKindOfClass:[NSArray class]]){
                TouListArr = [[NSMutableArray alloc]initWithArray:responseObject[@"results"]];
                [CommonCode writeToUserD:TouListArr andKey:[NSString stringWithFormat:@"zhuyeliebiao%@",pindaoName]];
                [CommonCode writeToUserD:TouListArr andKey:@"zhuyeliebiao"];
            }
            ExnumberPage = 1;
            [tableView reloadData];
            [tableView.mj_header endRefreshing];
            if ([tableViewArr indexOfObject:tableView] > topNameArr.count) {
                 [CommonCode writeToUserD:[NSString stringWithFormat:@"1"] andKey:[NSString stringWithFormat:@"page%@",[topNameArr firstObject][@"type"]]];
            }
            else{
                 [CommonCode writeToUserD:[NSString stringWithFormat:@"1"] andKey:[NSString stringWithFormat:@"page%@",topNameArr[[tableViewArr indexOfObject:tableView]][@"type"]]];
            }
           
        } failure:^(NSError *error) {
            NSLog(@"error = %@",error);
            [tableView.mj_header endRefreshing];
        }];
    }
    else{
        
        NSString *accessToken;
        if (ExdangqianUser.length == 0 || ExdangqianUser == nil){
            accessToken = nil;
        }
        else{
            accessToken = [DSE encryptUseDES:ExdangqianUser];
        }
        [NetWorkTool getNewsListWithaccessToken:accessToken andID:pindaoID andpage:@"1" andlimit:@"15" sccess:^(NSDictionary *responseObject) {
            
            if ([responseObject[@"results"] isKindOfClass:[NSArray class]]){
                TouListArr = [[NSMutableArray alloc]initWithArray:responseObject[@"results"]];
                [CommonCode writeToUserD:TouListArr andKey:[NSString stringWithFormat:@"zhuyeliebiao%@",pindaoName]];
                [CommonCode writeToUserD:TouListArr andKey:@"zhuyeliebiao"];
            }
            else{
                if ([pindaoID isEqualToString:@"19"]) {
                    CitySelectedViewController *citylistVC = [[CitySelectedViewController alloc]init];
                    self.hidesBottomBarWhenPushed=YES;
                    [self.navigationController pushViewController:citylistVC animated:YES];
                    self.hidesBottomBarWhenPushed=NO;
                }
            }
            ExnumberPage = 1;
            [CommonCode writeToUserD:[NSString stringWithFormat:@"1"] andKey:[NSString stringWithFormat:@"page%@",topNameArr[[tableViewArr indexOfObject:tableView]][@"type"]]];
            [tableView reloadData];
            [tableView.mj_header endRefreshing];
        } failure:^(NSError *error) {
            NSLog(@"error = %@",error);
            [tableView.mj_header endRefreshing];
        }];
    }
    
    //推荐栏目不用请求
    if (![pindaoID isEqualToString:@"-1"]){
        [self.ztADResult removeAllObjects];
        NSString *term_id = pindaoID;
        NSString *keyword = @"";
        if ([pindaoName isEqualToString:@"头条"]){
            term_id = nil;
            keyword = @"头条";
        }
        else{
            term_id = pindaoID;
            keyword = nil;
        }
        dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
        dispatch_group_t group = dispatch_group_create();
        dispatch_group_enter(group);
        dispatch_group_async(group, queue, ^{
            [NetWorkTool getSlideListWithcat_idname:pindaoID sccess:^(NSDictionary *responseObject) {
                if ([responseObject[@"results"] isKindOfClass:[NSArray class]]){
                    
                    self.slideADResult = responseObject[@"results"];
                }
                else{
                    self.slideADResult = [NSMutableArray array];
                }
                dispatch_group_leave(group);
                
            } failure:^(NSError *error) {
                NSLog(@"%@",error);
                dispatch_group_leave(group);
            }];
        });
        dispatch_group_enter(group);
        dispatch_group_async(group, queue, ^{
            //            _ztADResult = [NSMutableArray new];
            [NetWorkTool getPaoGuoPinDaoHuanDengPianXinXiWithterm_id:term_id andkeyword:keyword sccess:^(NSDictionary *responseObject) {
                if ([responseObject[@"results"] isKindOfClass:[NSArray class]]){
                    NSArray *arr = [NSArray arrayWithArray:responseObject[@"results"]];
                    NSMutableArray *mArr = [[NSMutableArray alloc]init];
                    NSString *str;
                    for (NSDictionary *dic in arr){
                        if (mArr.count == 0){
                            [mArr addObject:dic[@"zhutitle"]];
                            str = [NSString stringWithFormat:@"%@,",arr[0][@"zhutitle"]];
                        }
                        else{
                            for (int i = 0; i < mArr.count; i ++ ){
                                if ([str rangeOfString:dic[@"zhutitle"]].location == NSNotFound){
                                    [mArr addObject:dic[@"zhutitle"]];
                                    str = [NSString stringWithFormat:@"%@,%@",str,dic[@"zhutitle"]];
                                }
                            }
                        }
                    }
                    [self.ztADResult removeAllObjects];
                    for (NSString *str in mArr){
                        NSMutableArray *cArr = [[NSMutableArray alloc]init];
                        for (int i = 0; i < arr.count; i ++ ){
                            if ([str isEqualToString:arr[i][@"zhutitle"]]){
                                [cArr addObject:arr[i]];
                            }
                        }
                        [self.ztADResult addObject:cArr];
                    }
                }
                else{
                    self.ztADResult = [NSMutableArray array];
                }
                dispatch_group_leave(group);
            } failure:^(NSError *error) {
                dispatch_group_leave(group);
            }];
        });
        
        dispatch_group_notify(group, dispatch_get_main_queue(), ^{
            
            if ([self.ztADResult count]) {
                if ([self.slideADResult count]) {
                    [self.ztADResult addObject:self.slideADResult];
                }
            }
            else{
                //                _ztADResult = [NSMutableArray new];
                [self.ztADResult removeAllObjects];
                if([self.slideADResult count]){
                    [self.ztADResult addObject:self.slideADResult];
                }
            }
            //TODO:设置轮播图
            if ([self.ztADResult count]){
                TBCircleScrollView *tbScView = [[TBCircleScrollView alloc]initWithFrame:CGRectMake(20.0 / 375 * IPHONE_W, 0, IPHONE_W - 40.0 / 375 * IPHONE_W, 162.0 / 667 * SCREEN_HEIGHT) andArr:self.ztADResult];
                tbScView.scrollView.scrollsToTop = NO;
                tbScView.biaozhiStr = pindaoName;
                NSMutableArray *imgArr = [[NSMutableArray alloc]init];
                if ([self.slideADResult count]) {
                    for (int i = 0; i < self.ztADResult.count - self.slideADResult.count; i ++ ){
                        [imgArr addObject:NEWSSEMTPHOTOURL(self.ztADResult[i][0][@"smeta"])];
                    }
                    tbScView.ztADCount = [imgArr count];
                    for (int i = 0 ; i < [self.slideADResult count]; i ++) {
                        [imgArr addObject:USERPOTOAD(self.slideADResult[i][@"slide_pic"]]) ;
                    }
                }
                else{
                     for (int i = 0; i < self.ztADResult.count; i ++ ){
                                 [imgArr addObject:NEWSSEMTPHOTOURL(self.ztADResult[i][0][@"smeta"])];
                             }
                             tbScView.ztADCount = [imgArr count];
                             
                         }
                         tbScView.imageArray = [NSArray arrayWithArray:imgArr];
                         tableView.tableHeaderView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, 162.0 / 667 * SCREEN_HEIGHT)];
                         [tableView.tableHeaderView addSubview:tbScView];
                    }
                         
        });
                         
   }
}
                         
//- (NSArray *)ADResult {
//    if (!_ADResult) {
//        _ADResult = [NSArray new];
//    }
//    return _ADResult;
//}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
// Get the new view controller using [segue destinationViewController].
// Pass the selected object to the new view controller.
}
*/

@end
