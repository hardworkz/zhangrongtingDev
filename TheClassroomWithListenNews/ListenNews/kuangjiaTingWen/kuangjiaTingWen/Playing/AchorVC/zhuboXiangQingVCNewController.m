//
//  zhuboXiangQingVCNewController.m
//  kuangjiaTingWen
//
//  Created by 泡果 on 2017/6/16.
//  Copyright © 2017年 zhimi. All rights reserved.
//

#import "zhuboXiangQingVCNewController.h"
#import "UIImageView+WebCache.h"
#import "MJRefresh.h"
#import "zhuboxiangqingBtn.h"
#import "LoginNavC.h"
#import "LoginVC.h"
#import "bofangVC.h"
#import "ShareAlertView.h"
#import "AppDelegate.h"
#import "UIImage+compress.h"
#import "BatchDownloadTableTableViewController.h"
#import "NSDate+TimeFormat.h"
#import "UIView+tap.h"
#import "gerenzhuyeVC.h"
#import "RewardListTableViewCell.h"
#import "RewardCustomView.h"
#import "PayOnlineViewController.h"
#import "UIActionSheet+MKBlockAdditions.h"
#import "pinglunyeVC.h"
#import "TTTAttributedLabel.h"
#import "PinglundianzanCustomBtn.h"

@interface zhuboXiangQingVCNewController ()<UIScrollViewDelegate,UITableViewDataSource,UITableViewDelegate,TTTAttributedLabelDelegate,UITextFieldDelegate>
{
    BOOL isGuanZhu;
    UIScrollView *ZhuscrollView;
    UIScrollView *TwoScrollV;
    UIImageView *headerView;
    UIView *downHeaderV;
    NSInteger lastBtnTag;
    UIView *CenterView;
    UILabel *PingLundianzanNumLab;
    
    NSMutableArray *xinwenArr;
    NSMutableArray *fansArr;
    NSMutableArray *liuyanArr;
    NSMutableArray *imageArr;
    
    
    int xinwenPageNumber;
    int fansPageNumber;
    int liuyanPageNumber;
    
    UITextField *pinglunTextF;
    UIView *pinglunBgView;
    UITableView *pinglunhoushuaxinTableView;
    UITableView *fansWallTableView;
    UITableView *xinwenshuaxinTableView;
    UITableView *ImageTableView;
    
    NSInteger selectedSwitchIndex;/**<选中按钮*/
    NSInteger touchCount;
}

@property (weak, nonatomic) CustomPageView *pagingView;

@property (strong,nonatomic)UIButton *selectBtn;

@property (weak, nonatomic) UIScrollView *scrollView;
@property (weak, nonatomic) UIImageView *lastImageView;
@property (nonatomic)CGRect originalFrame;

@property (strong, nonatomic) NSMutableArray *rewardListArray;
@property (strong, nonatomic)UILabel *myRanking;
@property (assign, nonatomic) NSInteger myRank;
@property (assign, nonatomic) BOOL isOnRank;
@property (assign, nonatomic) BOOL isRewardLoginBack;
@property (strong, nonatomic) RewardCustomView *rewardView;
@property (assign, nonatomic) BOOL isReplyComment;
@property (assign, nonatomic) BOOL isTapPlayBtn;/**<第一次点击节目列表中的播放按钮，用来让页面第一次点击列表按钮，颜色状态能发生改变*/
@property (strong, nonatomic) NSString *replyTouid;
@property (strong, nonatomic) NSString *replyCommentid;

@property (strong, nonatomic) UILabel *tipLabel;
@end

@implementation zhuboXiangQingVCNewController
- (NSString *)post_content
{
    return _post_content?_post_content:@"";
}
- (NSString *)imageUrlSubStringWithStr:(NSString *)string
{
    NSRange range;
    
    range = [string rangeOfString:@" title="];
    
    if (range.location != NSNotFound) {
        
        NSLog(@"found at location = %lu, length = %lu",(unsigned long)range.location,(unsigned long)range.length);
        NSString *imageUrl = [string substringWithRange:NSMakeRange(13, range.location - 14)];
        return imageUrl;
        
    }else{
        
        NSLog(@"Not Found");
        return @"";
        
    }
}
- (void)viewDidLoad {
    [super viewDidLoad];
    touchCount = 0;
    [self.navigationController setNavigationBarHidden:YES animated:YES];
//    self.edgesForExtendedLayout = UIRectEdgeNone;
//    self.automaticallyAdjustsScrollViewInsets = NO;
//    self.extendedLayoutIncludesOpaqueBars = NO;
    [self setTitle:@"详情"];
    self.view.backgroundColor = [UIColor whiteColor];
    _isRewardLoginBack = NO;
    _isReplyComment = NO;
    
    if ([[NSString stringWithFormat:@"%@",self.jiemuIs_fan] isEqualToString:@"0"]){
        isGuanZhu = NO;
    }
    else{
        isGuanZhu = YES;
    }
    
    xinwenPageNumber = 1;
    fansPageNumber = 1;
    liuyanPageNumber = 1;
    
    [self addHeaderView];
    
    NSMutableArray *buttonArray = [NSMutableArray array];
    for (int i = 0; i < 5; i ++ ){
        zhuboxiangqingBtn *btn = [[zhuboxiangqingBtn alloc] init];
        if (SCREEN_WIDTH >= 375) {
            btn.titleEdgeInsets = UIEdgeInsetsMake(10, 10, 0, 0);
        }
        btn.backgroundColor = [UIColor whiteColor];
        if (i == 0){
            [btn setImage:@"BmentButton1"];
            [btn setSelectedImage:@"mentButton1"];
            [btn setTitleColor:gTextColorSub];
            [btn setSelectedTitleColor:nMainColor];
            btn.titleLabel.font = gFontSub11;
            [btn setTitle:@"节目"];
            selectedSwitchIndex = 0;
            btn.accessibilityLabel = @"节目";
            btn.selected = YES;
        }
        else if (i == 1){
            [btn setImage:@"BmentButton2"];
            [btn setSelectedImage:@"mentButton2"];
            [btn setTitleColor:gTextColorSub];
            [btn setSelectedTitleColor:nMainColor];
            btn.titleLabel.font = gFontSub11;
            [btn setTitle:@"粉丝榜"];
            btn.accessibilityLabel = @"粉丝榜";
        }
        else if (i == 2){
            [btn setImage:@"BmentButton3"];
            [btn setSelectedImage:@"mentButton3"];
            [btn setTitleColor:gTextColorSub];
            [btn setSelectedTitleColor:nMainColor];
            btn.titleLabel.font = gFontSub11;
            [btn setTitle:@"留言"];
            btn.accessibilityLabel = @"留言";
        }
        else if (i == 3){
            [btn setImage:@"BmentButton4"];
            [btn setSelectedImage:@"mentButton4"];
            [btn setTitleColor:gTextColorSub];
            [btn setSelectedTitleColor:nMainColor];
            btn.titleLabel.font = gFontSub11;
            [btn setTitle:@"图片"];
            btn.accessibilityLabel = @"图片";
        }
        else{
            [btn setImage:@"BmentButton5"];
            [btn setSelectedImage:@"mentButton5"];
            [btn setTitleColor:gTextColorSub];
            [btn setSelectedTitleColor:nMainColor];
            btn.titleLabel.font = gFontSub11;
            [btn setTitle:@"下载"];
            btn.accessibilityLabel = @"下载";
        }
        btn.frame = CGRectMake((75.0 / 375 * SCREEN_WIDTH) * i, 0, 75.0 / 375 * SCREEN_WIDTH, 52.0 / 667 * SCREEN_HEIGHT);
        [buttonArray addObject:btn];
    }
    
    //分页tableView
    for (int i = 0; i < 4; i ++ ){
        UITableView *tableView = [[UITableView alloc]initWithFrame:CGRectMake(IPHONE_W * i, 0, IPHONE_W , IPHONE_H - 20/ 667 * SCREEN_HEIGHT) style:UITableViewStyleGrouped];
        tableView.backgroundColor = [UIColor whiteColor];
        
        if (i == 0){
            xinwenshuaxinTableView = tableView;
        }
        else if (i == 1){
            tableView = [[UITableView alloc]initWithFrame:CGRectMake(IPHONE_W * i + 1, 0, IPHONE_W , IPHONE_H - 20.0/ 667 * SCREEN_HEIGHT) style:UITableViewStyleGrouped];
            tableView.backgroundColor = [UIColor whiteColor];
            fansWallTableView = tableView;
            tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
        }
        else if (i == 2){
            tableView.frame = CGRectMake(IPHONE_W * i + 2, 0, IPHONE_W, IPHONE_H - 20.0 / 667 * SCREEN_HEIGHT);
            pinglunhoushuaxinTableView = tableView;
        }else if (i == 3){
            tableView.frame = CGRectMake(IPHONE_W * i + 2, 0, IPHONE_W, IPHONE_H - 20.0 / 667 * SCREEN_HEIGHT);
            tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
            ImageTableView = tableView;
        }
//        tableView.bounces = NO;
        tableView.delegate = self;
        tableView.dataSource = self;
        tableView.tag = 3 + i; // 3：节目 4：粉丝榜 5：留言
        tableView.scrollsToTop = NO;
        tableView.tableFooterView = [UIView new];
        if (i == 0){
            tableView.mj_footer = [MJRefreshAutoNormalFooter footerWithRefreshingBlock:^{
                [self xinwenshanglajiazai:tableView];
            }];
            [tableView.mj_header beginRefreshing];
        }
        else if (i == 1){
            [tableView.mj_header beginRefreshing];
        }
        else if (i == 2){
            tableView.mj_footer = [MJRefreshAutoNormalFooter footerWithRefreshingBlock:^{
                [self liuyanshanglajiazai:tableView];
            }];
            [tableView.mj_header beginRefreshing];
        }
    }
    UIView *picView = [[UIView alloc]initWithFrame:CGRectMake(IPHONE_W * 3, 0, IPHONE_W, IPHONE_H - 50.0 / 667 * SCREEN_HEIGHT - 50.0 / 667 * IPHONE_H)];
    [picView setBackgroundColor:[UIColor whiteColor]];
    
    //详情页移动导航栏主框架
    
    CustomPageView *pagingView = [CustomPageView pagingViewWithHeaderView:headerView headerHeight:273.0 / 667 * SCREEN_HEIGHT segmentButtons:buttonArray segmentHeight:52.0 / 667 * SCREEN_HEIGHT contentViews:@[xinwenshuaxinTableView, fansWallTableView, pinglunhoushuaxinTableView,ImageTableView]];
    self.pagingView = pagingView;
    pagingView.pagingViewSwitchBlock = ^(NSInteger switchIndex) {
        RTLog(@"switchIndex---%ld",switchIndex);
        switch (switchIndex) {
            case 0:
                if (selectedSwitchIndex == switchIndex) {
//                    XWAlerLoginView *xw = [[XWAlerLoginView alloc] initWithTitle:@"刷新成功"];
//                    [xw show];
                    [self xinwenRefresh:xinwenshuaxinTableView];
                }else{
                    if (xinwenArr.count == 0) {
                        [self xinwenRefresh:xinwenshuaxinTableView];
                    }
                }
                break;
            case 1:
                if (selectedSwitchIndex == switchIndex) {
//                    XWAlerLoginView *xw = [[XWAlerLoginView alloc] initWithTitle:@"刷新成功"];
//                    [xw show];
                    [self fansRefresh:fansWallTableView];
                }else{
                    if (_rewardListArray.count == 0) {
                        [self fansRefresh:fansWallTableView];
                    }
                }
                break;
            case 2:
                if (selectedSwitchIndex == switchIndex) {
//                    XWAlerLoginView *xw = [[XWAlerLoginView alloc] initWithTitle:@"刷新成功"];
//                    [xw show];
                    [self liuyanRefresh:pinglunhoushuaxinTableView];
                }else{
                    if (liuyanArr.count == 0) {
                        [self liuyanRefresh:pinglunhoushuaxinTableView];
                    }
                }
                break;
            default:
                break;
        }
        
        if (switchIndex != 2 && switchIndex != 4) {//切换到粉丝列表
            if (self.isbofangye == YES) {
                [UIView animateWithDuration:0.3f animations:^{
                    pinglunBgView.frame = CGRectMake(pinglunBgView.frame.origin.x, IPHONE_H, pinglunBgView.frame.size.width, pinglunBgView.frame.size.height);
                }];
            }
            else{
                [UIView animateWithDuration:0.3f animations:^{
                    pinglunBgView.frame = CGRectMake(pinglunBgView.frame.origin.x, IPHONE_H, pinglunBgView.frame.size.width, pinglunBgView.frame.size.height);
                }];
            }
        }else if (switchIndex == 2) {//切换到留言列表
            [self.view endEditing:YES];
            _isReplyComment = NO;
            pinglunTextF.placeholder = @"输入评论";
            if (self.isbofangye == YES){
                [UIView animateWithDuration:0.3f animations:^{
                    pinglunBgView.frame = CGRectMake(pinglunBgView.frame.origin.x, IPHONE_H - pinglunBgView.frame.size.height, pinglunBgView.frame.size.width, pinglunBgView.frame.size.height);
                }];
            }
            else{
                [UIView animateWithDuration:0.3f animations:^{
                    pinglunBgView.frame = CGRectMake(pinglunBgView.frame.origin.x, IPHONE_H - pinglunBgView.frame.size.height, pinglunBgView.frame.size.width, pinglunBgView.frame.size.height);
                }];
            }
        }else if (switchIndex == 4) {//点击下载跳转
            self.hidesBottomBarWhenPushed=YES;
            [self.navigationController setNavigationBarHidden:NO animated:YES];
            BatchDownloadTableTableViewController *vc = [BatchDownloadTableTableViewController new];
            vc.downloadSource = @"1";
            vc.programID = self.jiemuID;
            vc.headTitleStr = [NSString stringWithFormat:@"【%@】节目批量下载",self.jiemuName ];
            [self.navigationController pushViewController:vc animated:YES];
            self.hidesBottomBarWhenPushed=YES;
        }
        if (switchIndex != 4) {
            selectedSwitchIndex = switchIndex;
        }
    };
    pagingView.clickEventViewsBlock = ^(UIView *eventView) {
        RTLog(@"%@",eventView.class);
        if ([eventView isKindOfClass:[UIButton class]]) {
            UIButton *button = (UIButton *)eventView;
            if ([button.accessibilityLabel isEqualToString:@"返回"]) {
                [self backAction:button];
            }else if ([button.accessibilityLabel isEqualToString:@"节目分享"]){
                [self shareAction:button];
            }else if ([button.accessibilityLabel isEqualToString:@"关注按钮"]){
                [self guanzhuBtnAction:button];
            }
            
        }else if ([eventView isKindOfClass:[UIImageView class]]){
            UIImageView *imageView = (UIImageView *)eventView;
            if ([imageView.accessibilityLabel isEqualToString:@"主播头像"]) {
                [self showHeadImageViewWithImageView:imageView];
            }
        }
        
    };
    [self.view addSubview:pagingView];
    
    if (self.isbofangye == YES){
        [self bofangyepinglunkuang];
    }
    else{
        [self pinglunkuang];
    }
    
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(gaibianyanse:) name:@"gaibianyanse" object:nil];
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(zhuboxiangqingbofangJiaZai:) name:@"zhuboxiangqingbofang" object:nil];
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(back) name:@"isBackfromPersonalPage" object:nil];
    
    UISwipeGestureRecognizer *rightSwipe = [[UISwipeGestureRecognizer alloc]initWithTarget:self action:@selector(back)];
    [rightSwipe setDirection:UISwipeGestureRecognizerDirectionRight];
    [self.view addGestureRecognizer:rightSwipe];
    UISwipeGestureRecognizer *back = [[UISwipeGestureRecognizer alloc]initWithTarget:self action:@selector(back)];
    [headerView addGestureRecognizer:back];
    [pagingView addGestureRecognizer:back];
    
}
- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
//    self.navBarBgAlpha = @"0.0";
    
    IQKeyboardManager *manager = [IQKeyboardManager sharedManager];
    manager.enable = YES;
    manager.shouldResignOnTouchOutside = YES;
    manager.shouldToolbarUsesTextFieldTintColor = NO;
    manager.enableAutoToolbar = NO;
    
    [self.navigationController setNavigationBarHidden:YES animated:YES];
    self.hidesBottomBarWhenPushed = YES;
    if (_isRewardLoginBack) {
        _isRewardLoginBack = NO;
        [self rewardAlert];
    }
    
    [self xinwenRefresh:xinwenshuaxinTableView];
    [self fansRefresh:fansWallTableView];
    [self liuyanRefresh:pinglunhoushuaxinTableView];
    //主播图片数据转换截取
    NSMutableArray *imageUrlArray = [NSMutableArray arrayWithArray:@[[self imageUrlSubStringWithStr:self.post_content]]];
    if ([[self imageUrlSubStringWithStr:self.post_content] isEqualToString:@""]) {
        [imageUrlArray removeAllObjects];
    }
    [self imageArrayWithImageData:(NSMutableArray *)imageUrlArray];
    
    if (selectedSwitchIndex != 4) {
        [self.pagingView pagingViewDidSelectedIndex:selectedSwitchIndex];
    }
    
    if (![bofangVC shareInstance].isPlay) {
        [[NSNotificationCenter defaultCenter] postNotificationName:@"stopAnimate" object:nil];
    }else {
        [[NSNotificationCenter defaultCenter] postNotificationName:@"startAnimate" object:nil];
    }
}

- (void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    
//    self.navBarBgAlpha = @"1.0";
    [self.navigationController setNavigationBarHidden:NO animated:YES];
    
    if (![bofangVC shareInstance].isPlay) {
        [[NSNotificationCenter defaultCenter] postNotificationName:@"stopAnimate" object:nil];
    }else {
        [[NSNotificationCenter defaultCenter] postNotificationName:@"startAnimate" object:nil];
    }
}

#pragma mark --- 评论框UI
- (void)pinglunkuang{
    pinglunBgView = [[UIView alloc]initWithFrame:CGRectMake(0, IPHONE_H, IPHONE_W, 50.0 / 667 * IPHONE_H)];
    [self.view addSubview:pinglunBgView];
    pinglunBgView.backgroundColor = [UIColor whiteColor];
    
    UIImageView *imgV = [[UIImageView alloc]initWithFrame:CGRectMake(5.0 / 375 * IPHONE_W, 10.0 / 667 * IPHONE_H, 24.0 / 375 * IPHONE_W, 24.0 / 667 * IPHONE_H)];
    imgV.image = [UIImage imageNamed:@"iconfont_shuru"];
    [pinglunBgView addSubview:imgV];
    imgV.backgroundColor = [UIColor whiteColor];
    
    pinglunTextF = [[UITextField alloc]initWithFrame:CGRectMake(CGRectGetMaxX(imgV.frame) + 3.0 / 375 * IPHONE_W, 10.0 / 667 * IPHONE_H, IPHONE_W - 90.0 / 375 * IPHONE_W, 30.0 / 667 * IPHONE_H)];
    pinglunTextF.placeholder = @"输入评论";
    pinglunTextF.backgroundColor = [UIColor whiteColor];
    [pinglunBgView addSubview:pinglunTextF];
    
    UIView *pinglunDownLine = [[UIView alloc]initWithFrame:CGRectMake(pinglunTextF.frame.origin.x, CGRectGetMaxY(pinglunTextF.frame) + 2.0 / 667 * IPHONE_H, pinglunTextF.frame.size.width, 1.0 / 667 * IPHONE_H)];
    pinglunDownLine.backgroundColor = [[UIColor grayColor]colorWithAlphaComponent:0.7f];
    [pinglunBgView addSubview:pinglunDownLine];
    
    UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
    btn.frame = CGRectMake(CGRectGetMaxX(pinglunTextF.frame) + 4.0 / 375 * IPHONE_W, pinglunTextF.frame.origin.y, 50.0 / 375 * IPHONE_W, 30.0 / 667 * IPHONE_H);
    [btn setTitle:@"发送" forState:UIControlStateNormal];
    [btn.layer setBorderWidth:1.0];
    [btn.layer setBorderColor:gSubColor.CGColor];
    [btn.layer setMasksToBounds:YES];
    [btn.layer setCornerRadius:5.0];
    btn.titleLabel.font = [UIFont systemFontOfSize:15.0 / 375 * IPHONE_W];
    [btn setTitleColor:[[UIColor grayColor]colorWithAlphaComponent:0.7f] forState:UIControlStateNormal];
    [btn addTarget:self action:@selector(fasongpinglunAction:) forControlEvents:UIControlEventTouchUpInside];
    [pinglunBgView addSubview:btn];
    
}

- (void)bofangyepinglunkuang{
    pinglunBgView = [[UIView alloc]initWithFrame:CGRectMake(0, IPHONE_H, IPHONE_W, 50.0 / 667 * IPHONE_H)];
    [self.view addSubview:pinglunBgView];
    pinglunBgView.backgroundColor = [UIColor whiteColor];
    
    UIImageView *imgV = [[UIImageView alloc]initWithFrame:CGRectMake(5.0 / 375 * IPHONE_W, 10.0 / 667 * IPHONE_H, 24.0 / 375 * IPHONE_W, 24.0 / 667 * IPHONE_H)];
    imgV.image = [UIImage imageNamed:@"iconfont_shuru"];
    [pinglunBgView addSubview:imgV];
    imgV.backgroundColor = [UIColor whiteColor];
    
    pinglunTextF = [[UITextField alloc]initWithFrame:CGRectMake(CGRectGetMaxX(imgV.frame) + 3.0 / 375 * IPHONE_W, 10.0 / 667 * IPHONE_H, IPHONE_W - 90.0 / 375 * IPHONE_W, 30.0 / 667 * IPHONE_H)];
    pinglunTextF.placeholder = @"输入评论";
    pinglunTextF.backgroundColor = [UIColor whiteColor];
    [pinglunBgView addSubview:pinglunTextF];
    
    UIView *pinglunDownLine = [[UIView alloc]initWithFrame:CGRectMake(pinglunTextF.frame.origin.x, CGRectGetMaxY(pinglunTextF.frame) + 2.0 / 667 * IPHONE_H, pinglunTextF.frame.size.width, 1.0 / 667 * IPHONE_H)];
    pinglunDownLine.backgroundColor = [[UIColor grayColor]colorWithAlphaComponent:0.7f];
    [pinglunBgView addSubview:pinglunDownLine];
    
    UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
    btn.frame = CGRectMake(CGRectGetMaxX(pinglunTextF.frame) + 4.0 / 375 * IPHONE_W, pinglunTextF.frame.origin.y, 50.0 / 375 * IPHONE_W, 30.0 / 667 * IPHONE_H);
    [btn setTitle:@"发送" forState:UIControlStateNormal];
    btn.titleLabel.font = [UIFont systemFontOfSize:15.0 / 375 * IPHONE_W];
    [btn setTitleColor:[[UIColor grayColor]colorWithAlphaComponent:0.7f] forState:UIControlStateNormal];
    [btn.layer setBorderWidth:1.0];
    [btn.layer setBorderColor:gSubColor.CGColor];
    [btn.layer setMasksToBounds:YES];
    [btn.layer setCornerRadius:5.0];
    [btn addTarget:self action:@selector(fasongpinglunAction:) forControlEvents:UIControlEventTouchUpInside];
    [pinglunBgView addSubview:btn];
    
    pinglunBgView.frame = CGRectMake(pinglunBgView.frame.origin.x, IPHONE_H, pinglunBgView.frame.size.width, pinglunBgView.frame.size.height);
    
}

#pragma mark - Utilities

/**
 新闻数据

 @param tableView 对应tableview
 */
- (void)xinwenRefresh:(UITableView *)tableView{
    [NetWorkTool postPaoGuoZhuBoOrJieMuMessageWithID:self.jiemuID andpage:@"1" andlimit:@"10" sccess:^(NSDictionary *responseObject) {
        if ([responseObject[@"results"] isKindOfClass:[NSArray class]])
        {
            xinwenArr = [[NSMutableArray alloc]initWithArray:responseObject[@"results"]];
            [tableView reloadData];
        }
        [tableView.mj_header endRefreshing];
    } failure:^(NSError *error) {
        NSLog(@"error = %@",error);
        [tableView.mj_header endRefreshing];
    }];
}

/**
 新闻上拉加载更多

 @param tableView 对应tableview
 */
- (void)xinwenshanglajiazai:(UITableView *)tableView{
    xinwenPageNumber++;
    
    [NetWorkTool postPaoGuoZhuBoOrJieMuMessageWithID:self.jiemuID andpage:[NSString stringWithFormat:@"%d",xinwenPageNumber] andlimit:@"10" sccess:^(NSDictionary *responseObject) {
        if ([responseObject[@"results"] isKindOfClass:[NSArray class]])
        {
            [xinwenArr addObjectsFromArray:responseObject[@"results"]];
            [tableView reloadData];
        }
        [tableView.mj_footer endRefreshing];
    } failure:^(NSError *error) {
        NSLog(@"error = %@",error);
        [tableView.mj_footer endRefreshing];
    }];
}

/**
 粉丝数据

 @param tableView 对应tableview
 */
- (void)fansRefresh:(UITableView *)tableView{
    fansPageNumber = 1;
    NSString *accesstoken = nil;
    _myRank = 0;
    _isOnRank = NO;
    if ([[CommonCode readFromUserD:@"isLogin"]boolValue] == YES){
        accesstoken = AvatarAccessToken;
    }
    else{
        accesstoken = nil;
    }
    
    [NetWorkTool getZan_boardWithaccessToken:accesstoken act_id:self.jiemuID sccess:^(NSDictionary *responseObject) {
        _myRank = [responseObject[@"results"][@"rank"] integerValue];
        if (_myRank == 0 ) {
            [self.myRanking setText:[NSString stringWithFormat:@"我的排名：暂无排名"]];
            _isOnRank = NO;
        }
        else{
            [self.myRanking setText:[NSString stringWithFormat:@"我的排名：%ld",(long)_myRank]];
            _isOnRank = YES;
        }
        if ([responseObject[@"results"][@"list"] isKindOfClass:[NSArray class]]) {
            self.rewardListArray = responseObject[@"results"][@"list"];
        }
        else{
            self.rewardListArray = [NSMutableArray array];
        }
        [tableView reloadData];
        [tableView.mj_header endRefreshing];
    } failure:^(NSError *error) {
        //
        [tableView.mj_header endRefreshing];
    }];
}

/**
 留言数据

 @param tableView 对应tableView
 */
- (void)liuyanRefresh:(UITableView *)tableView{
    
    liuyanPageNumber = 1;
    
    [NetWorkTool getPaoguoJieMuOrZhuBoPingLunLieBiaoWithact_id:self.jiemuID andpage:@"1" andlimit:@"10" sccess:^(NSDictionary *responseObject) {
        if ([responseObject[@"results"] isKindOfClass:[NSArray class]])
        {
            liuyanArr = [[NSMutableArray alloc]initWithArray:responseObject[@"results"]];
            [tableView reloadData];
        }
        [tableView.mj_header endRefreshing];
    } failure:^(NSError *error) {
        NSLog(@"error = %@",error);
        [tableView.mj_header endRefreshing];
    }];
}

/**
 留言上拉加载更多

 @param tableView 对应tableview
 */
- (void)liuyanshanglajiazai:(UITableView *)tableView{
    liuyanPageNumber ++ ;
    
    [NetWorkTool getPaoguoJieMuOrZhuBoPingLunLieBiaoWithact_id:self.jiemuID andpage:[NSString stringWithFormat:@"%d",liuyanPageNumber] andlimit:@"10" sccess:^(NSDictionary *responseObject) {
        if ([responseObject[@"results"] isKindOfClass:[NSArray class]])
        {
            [liuyanArr addObjectsFromArray:responseObject[@"results"]];
            [tableView reloadData];
        }
        [tableView.mj_footer endRefreshing];
    } failure:^(NSError *error) {
        NSLog(@"error = %@",error);
        [tableView.mj_footer endRefreshing];
    }];
}

/**
 图片数据

 @param array 主播图片数组
 */
- (void)imageArrayWithImageData:(NSMutableArray *)array
{
    imageArr = [[NSMutableArray alloc]initWithArray:[AutoImageViewHeightFrameModel frameArrayWithImageUrlArray:array tableView:ImageTableView indexPath:[NSIndexPath indexPathForRow:0 inSection:0]]];
    [ImageTableView reloadData];
    if (imageArr.count == 0) {
        [ImageTableView addSubview:self.tipLabel];
    }
}

/**
 新闻数据上拉加载更多

 @param notifacation 对应tableview
 */
- (void)zhuboxiangqingbofangJiaZai:(NSNotification *)notifacation {
    xinwenPageNumber++;
    
    [NetWorkTool postPaoGuoZhuBoOrJieMuMessageWithID:self.jiemuID andpage:[NSString stringWithFormat:@"%d",xinwenPageNumber] andlimit:@"10" sccess:^(NSDictionary *responseObject) {
        if ([responseObject[@"results"] isKindOfClass:[NSArray class]])
        {
            [xinwenArr addObjectsFromArray:responseObject[@"results"]];
            [xinwenshuaxinTableView reloadData];
        }
        [xinwenshuaxinTableView.mj_footer endRefreshing];
    } failure:^(NSError *error) {
        NSLog(@"error = %@",error);
        [xinwenshuaxinTableView.mj_footer endRefreshing];
    }];
}

- (void)fasongpinglunAction:(UIButton *)sender {
    
    if ([[CommonCode readFromUserD:@"isLogin"]boolValue] == YES){
        [SVProgressHUD setDefaultMaskType:SVProgressHUDMaskTypeBlack];
        [SVProgressHUD showWithStatus:@"发送中..."];
        //emoji解析上传
        NSArray *ContentArr = [self stringContainsEmoji:pinglunTextF.text];
        NSString *str = pinglunTextF.text;
        for (NSString *emoji in ContentArr) {
            str = [str stringByReplacingOccurrencesOfString:emoji withString:[NSString stringWithFormat:@"[e1]%@[/e1]", [DSE encryptUseDES:emoji]]];
        }
        if (_isReplyComment) {
            _isReplyComment = NO;
            [pinglunTextF setPlaceholder:@"输入评论"];
            [self.view endEditing:YES];
            [NetWorkTool postPaoGuoZhuBoOrJieMuLiuYanWithaccessToken:[DSE encryptUseDES:ExdangqianUser] andto_uid:_replyTouid andact_id:self.jiemuID andcomment_id:_replyCommentid andact_table:@"act" andcontent:str sccess:^(NSDictionary *responseObject) {
                [SVProgressHUD showWithStatus:responseObject[@"msg"]];
                [self performSelector:@selector(SVPDismiss) withObject:nil afterDelay:1.0];
                [pinglunhoushuaxinTableView.mj_header beginRefreshing];
                [self.view endEditing:YES];
                pinglunTextF.text = @"";
                
            } failure:^(NSError *error) {
                [SVProgressHUD dismiss];
                NSLog(@"error = %@",error);
            }];
        }
        else{
            [NetWorkTool postPaoGuoZhuBoOrJieMuLiuYanWithaccessToken:[DSE encryptUseDES:ExdangqianUser] andto_uid:@"0" andact_id:self.jiemuID andcomment_id:nil andact_table:@"act" andcontent:str sccess:^(NSDictionary *responseObject) {
                [SVProgressHUD showWithStatus:responseObject[@"msg"]];
                [self performSelector:@selector(SVPDismiss) withObject:nil afterDelay:1.0];
                [pinglunhoushuaxinTableView.mj_header beginRefreshing];
                [self.view endEditing:YES];
                pinglunTextF.text = @"";
            } failure:^(NSError *error) {
                [SVProgressHUD dismiss];
                NSLog(@"error = %@",error);
            }];
        }
        
    }
    else{
        [self loginFirst];
    }
}

- (void)isbofangyeBuJv {
    UIView *topView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, IPHONE_W, 64)];
    topView.backgroundColor = gMainColor;
    [self.view addSubview:topView];
    
    UIButton *leftBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    leftBtn.frame = CGRectMake(8, 30, 25, 25);
    [leftBtn setImage:[UIImage imageNamed:@"back"] forState:UIControlStateNormal];
    [leftBtn addTarget:self action:@selector(back) forControlEvents:UIControlEventTouchUpInside];
    leftBtn.accessibilityLabel = @"返回";
    [topView addSubview:leftBtn];
    //    leftBtn.transform = CGAffineTransformMakeRotation(-M_PI / 2);
    UIView *tapView = [[UIView alloc]initWithFrame:CGRectMake(CGRectGetMaxX(leftBtn.frame), leftBtn.frame.origin.y, 40.0 / 375 * IPHONE_W, leftBtn.frame.size.height - 4)];
    [topView addSubview:tapView];
    tapView.backgroundColor = gMainColor;
    
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(back)];
    [tapView addGestureRecognizer:tap];
    
    UILabel *topLab = [[UILabel alloc]initWithFrame:CGRectMake(50, 30, IPHONE_W - 100, 30)];
    topLab.textColor = [UIColor whiteColor];
    topLab.font = [UIFont boldSystemFontOfSize:17.0f];
    topLab.text = @"详情";
    topLab.backgroundColor = [UIColor clearColor];
    topLab.textAlignment = NSTextAlignmentCenter;
    [topView addSubview:topLab];
    
}

- (void)addHeaderView{
    
    headerView = [[UIImageView alloc]initWithFrame:CGRectMake(0, 0, IPHONE_W, 273.0 / 667 * SCREEN_HEIGHT)];
    headerView.backgroundColor = [UIColor whiteColor];
    headerView.userInteractionEnabled = YES;
    
    UIImageView *shadowView = [[UIImageView alloc]initWithFrame:CGRectMake(0, 0, IPHONE_W,167.0 / 667 * IPHONE_H)];
    [shadowView setUserInteractionEnabled:YES];
    [shadowView setImage:[UIImage imageNamed:@"me_mypage_mettopbg"]];
    [headerView addSubview:shadowView];
    
    if (!self.isClass) {
        downHeaderV = [[UIView alloc]initWithFrame:CGRectMake(0, 223.0 / 667 *SCREEN_HEIGHT, IPHONE_W, 50.0 / 667 *SCREEN_HEIGHT)];
    }else{
        downHeaderV = [[UIView alloc]initWithFrame:CGRectMake(0, 223.0 / 667 *SCREEN_HEIGHT, IPHONE_W, 0.0 / 667 *SCREEN_HEIGHT)];
    }
    [downHeaderV setBackgroundColor:[UIColor whiteColor]];
    //返回按钮
    UIButton *leftBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    leftBtn.frame = CGRectMake(10, 25, 35, 35);
    [leftBtn setImageEdgeInsets:UIEdgeInsetsMake(5, 0, 5, 10)];
    [leftBtn setImage:[UIImage imageNamed:@"back"] forState:UIControlStateNormal];
    [leftBtn addTarget:self action:@selector(backAction:) forControlEvents:UIControlEventTouchUpInside];
    leftBtn.accessibilityLabel = @"返回";
    [headerView addSubview:leftBtn];
    //title
    UILabel *topLab = [[UILabel alloc]initWithFrame:CGRectMake(50, 30, IPHONE_W - 100, 30)];
    topLab.textColor = nTextColorMain;
    topLab.font = [UIFont boldSystemFontOfSize:17.0f];
    topLab.text = @"详情";
    topLab.backgroundColor = [UIColor clearColor];
    topLab.textAlignment = NSTextAlignmentCenter;
    [headerView addSubview:topLab];
    
    //分享按钮
    UIButton *shareBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    shareBtn.frame = CGRectMake(SCREEN_WIDTH - 45, 25, 35, 35);
    [shareBtn setImageEdgeInsets:UIEdgeInsetsMake(7.5, 0, 7.5, 15)];
    [shareBtn setImage:[UIImage imageNamed:@"title_ic_share"] forState:UIControlStateNormal];
    [shareBtn addTarget:self action:@selector(shareAction:) forControlEvents:UIControlEventTouchUpInside];
    shareBtn.accessibilityLabel = @"节目分享";
    [headerView addSubview:shareBtn];
    
    //头像背景
    UIView *imgBorderView = [[UIView alloc]initWithFrame:CGRectMake(15.0 / 375 * IPHONE_W, 112.0 / 667 * IPHONE_H, 95.0 / 667 * IPHONE_H, 95.0 / 667 * IPHONE_H)];
    [imgBorderView setBackgroundColor:gSubColor];
    [headerView addSubview:imgBorderView];
    [imgBorderView.layer setMasksToBounds:YES];
    [imgBorderView.layer setCornerRadius:95.0 / 667 * IPHONE_H / 2];
    
    //头像
    UIImageView *img = [[UIImageView alloc]initWithFrame:CGRectMake(2.5 / 667 * SCREEN_HEIGHT, 2.5 / 667 * SCREEN_HEIGHT, 90.0 / 667 * IPHONE_H, 90.0 / 667 * IPHONE_H)];
    if([self.jiemuImages rangeOfString:@"/data/upload/"].location !=NSNotFound){
        [img sd_setImageWithURL:[NSURL URLWithString:USERPHOTOHTTPSTRINGZhuBo(self.jiemuImages)] placeholderImage:[UIImage imageNamed:@"tingwen_bg_square"]];
    }
    else{
        [img sd_setImageWithURL:[NSURL URLWithString:USERPOTOAD(self.jiemuImages)] placeholderImage:[UIImage imageNamed:@"tingwen_bg_square"]];
    }
    img.accessibilityLabel = @"主播头像";
    img.layer.masksToBounds = YES;
    img.layer.cornerRadius = 90.0 / 667 * IPHONE_H / 2;
    img.contentMode = UIViewContentModeScaleAspectFill;
    [imgBorderView addSubview:img];
    img.userInteractionEnabled = YES;
    //添加单击手势
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(showHeadImageView:)];
    [img addGestureRecognizer:tap];
    
    //姓名
    UILabel *name = [[UILabel alloc]init];
    if (!self.isClass) {
        name.frame = CGRectMake(CGRectGetMaxX(imgBorderView.frame) + 12, imgBorderView.frame.origin.y + 20.0 / 667 * IPHONE_H, 150, 20.0 / 667 * IPHONE_H);
    }else{//课堂
        name.frame = CGRectMake(CGRectGetMaxX(imgBorderView.frame) + 12, imgBorderView.frame.origin.y + 20.0 / 667 * IPHONE_H, SCREEN_WIDTH - CGRectGetMaxX(imgBorderView.frame) - 12 - 20, 60.0 / 667 * IPHONE_H);
    }
    name.numberOfLines = 0;
    name.textColor = nTextColorMain;
    name.font = gFontMajor17;
    name.textAlignment = NSTextAlignmentLeft;
    name.text = self.jiemuName;
    [headerView addSubview:name];
    
    //简介
    UILabel *fensiliuyan = [[UILabel alloc]init];
    
    if (!self.isClass) {
        fensiliuyan.frame = CGRectMake(name.frame.origin.x,CGRectGetMaxY(imgBorderView.frame) - 30.0 / 667 *SCREEN_HEIGHT, SCREEN_WIDTH - name.frame.origin.x - 80.0 / 375 * SCREEN_WIDTH, 40.0 / 667 * IPHONE_H);
    }else{//课堂
        fensiliuyan.frame = CGRectMake(name.frame.origin.x,CGRectGetMaxY(name.frame) + 20.0 / 667 *SCREEN_HEIGHT, SCREEN_WIDTH - name.frame.origin.x - 80.0 / 375 * SCREEN_WIDTH, 40.0 / 667 * IPHONE_H);
    }
    fensiliuyan.textColor = gTextColorSub;
    fensiliuyan.font = gFontMain14;
    fensiliuyan.textAlignment = NSTextAlignmentLeft;
    fensiliuyan.numberOfLines = 2;
    [headerView addSubview:fensiliuyan];
    fensiliuyan.text = [NSString stringWithFormat:@"%@",self.jiemuDescription];
    
    if (!self.isClass) {//课堂详情隐藏控件
        UIButton *guanzhuBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        guanzhuBtn.frame = CGRectMake(SCREEN_WIDTH - 80.0 / 375 * IPHONE_W,161.0 / 667 * IPHONE_H, 80.0 / 375 * IPHONE_W, 20.0 / 667 * IPHONE_H);
        if (isGuanZhu == YES)
        {
            [guanzhuBtn setTitle:@"取消" forState:UIControlStateNormal];
        }
        else{
            [guanzhuBtn setTitle:@"+ 关注" forState:UIControlStateNormal];
        }
        guanzhuBtn.accessibilityLabel = @"关注按钮";
        [guanzhuBtn setTitleColor:gMainColor forState:UIControlStateNormal];
        guanzhuBtn.titleLabel.font                  = [UIFont systemFontOfSize:11.0];
        [guanzhuBtn setBackgroundColor:[UIColor clearColor]];
        guanzhuBtn.layer.cornerRadius               = 4;
        guanzhuBtn.layer.masksToBounds              = YES;
        guanzhuBtn.layer.borderColor = gMainColor.CGColor;
        guanzhuBtn.layer.borderWidth = .3f;
        guanzhuBtn.bounds     = CGRectMake(0, 0, 50, 30);
        [guanzhuBtn addTarget:self action:@selector(guanzhuBtnAction:) forControlEvents:UIControlEventTouchUpInside];
        [headerView addSubview:guanzhuBtn];
        
        //粉丝
        UIButton *fansButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [fansButton setFrame:CGRectMake(0, 25.0 / 667 * SCREEN_HEIGHT, SCREEN_WIDTH /2 , 25.0 / 667 * SCREEN_HEIGHT)];
        [fansButton setBackgroundColor:[UIColor clearColor]];
        [fansButton.titleLabel setFont:[UIFont systemFontOfSize:16.0]];
        [fansButton setTitle:[NSString stringWithFormat:@"%@",self.jiemuFan_num] forState:UIControlStateNormal];
        [fansButton setTitleColor:nTextColorMain forState:UIControlStateNormal];
        [fansButton addTarget:self action:@selector(fansButtonAction:) forControlEvents:UIControlEventTouchUpInside];
        fansButton.accessibilityLabel = [NSString stringWithFormat:@"粉丝 %@",self.jiemuFan_num];
        UILabel *fansLabel = [[UILabel alloc]initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH / 2, 25.0 / 667 * SCREEN_HEIGHT)];
        [fansLabel setText:@"粉丝"];
        [fansLabel setFont:gFontMain12];
        [fansLabel setTextAlignment:NSTextAlignmentCenter];
        [fansLabel setTextColor:gTextColorSub];
        fansLabel.accessibilityLabel = [NSString stringWithFormat:@"粉丝 %@",self.jiemuFan_num];
        [downHeaderV addSubview:fansLabel];
        [downHeaderV addSubview:fansButton];
        
        //留言
        UIButton *messageButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [messageButton setFrame:CGRectMake(SCREEN_WIDTH /2, 25.0 / 667 * SCREEN_HEIGHT, SCREEN_WIDTH /2 , 25.0 / 667 * SCREEN_HEIGHT)];
        [messageButton setBackgroundColor:[UIColor clearColor]];
        [messageButton.titleLabel setFont:[UIFont systemFontOfSize:16.0]];
        [messageButton setTitle:[NSString stringWithFormat:@"%@",self.jiemuMessage_num] forState:UIControlStateNormal];
        [messageButton setTitleColor:nTextColorMain forState:UIControlStateNormal];
        [messageButton addTarget:self action:@selector(fansButtonAction:) forControlEvents:UIControlEventTouchUpInside];
        messageButton.accessibilityLabel = [NSString stringWithFormat:@"留言 %@",self.jiemuMessage_num];
        UILabel *messageLabel = [[UILabel alloc]initWithFrame:CGRectMake(SCREEN_WIDTH /2,0, SCREEN_WIDTH / 2, 25.0 / 667 * SCREEN_HEIGHT)];
        [messageLabel setText:@"留言"];
        [messageLabel setFont:gFontMain12];
        [messageLabel setTextAlignment:NSTextAlignmentCenter];
        [messageLabel setTextColor:gTextColorSub];
        messageLabel.accessibilityLabel = [NSString stringWithFormat:@"留言 %@",self.jiemuMessage_num];
        [downHeaderV addSubview:messageLabel];
        [downHeaderV addSubview:messageButton];
    }
    
    [headerView addSubview:downHeaderV];
//    [ZhuscrollView addSubview:headerView];
}


- (NSArray *)stringContainsEmoji:(NSString *)string {
    
    __block BOOL returnValue    = NO;
    __block NSMutableArray *arr = [NSMutableArray array];
    [string enumerateSubstringsInRange:NSMakeRange(0, [string length])
                               options:NSStringEnumerationByComposedCharacterSequences
                            usingBlock:^(NSString *substring, NSRange substringRange, NSRange enclosingRange, BOOL *stop) {
                                const unichar hs            = [substring characterAtIndex:0];
                                if (0xd800 <= hs && hs <= 0xdbff) {
                                    if (substring.length > 1) {
                                        const unichar ls            = [substring characterAtIndex:1];
                                        const int uc                = ((hs - 0xd800) * 0x400) + (ls - 0xdc00) + 0x10000;
                                        if (0x1d000 <= uc && uc <= 0x1f77f) {
                                            returnValue                 = YES;
                                            [arr addObject:substring];
                                        }
                                    }
                                } else if (substring.length > 1) {
                                    const unichar ls            = [substring characterAtIndex:1];
                                    if (ls == 0x20e3) {
                                        returnValue                 = YES;
                                        [arr addObject:substring];
                                    }
                                } else {
                                    if (0x2100 <= hs && hs <= 0x27ff) {
                                        returnValue                 = YES;
                                        [arr addObject:substring];
                                    } else if (0x2B05 <= hs && hs <= 0x2b07) {
                                        returnValue                 = YES;
                                        [arr addObject:substring];
                                    } else if (0x2934 <= hs && hs <= 0x2935) {
                                        returnValue                 = YES;
                                        [arr addObject:substring];
                                    } else if (0x3297 <= hs && hs <= 0x3299) {
                                        returnValue                 = YES;
                                        [arr addObject:substring];
                                    } else if (hs == 0xa9 || hs == 0xae || hs == 0x303d || hs == 0x3030 || hs == 0x2b55 || hs == 0x2b1c || hs == 0x2b1b || hs == 0x2b50) {
                                        returnValue                 = YES;
                                        [arr addObject:substring];
                                    }
                                }
                            }];
    return arr;
}
- (void)showHeadImageViewWithImageView:(UIImageView *)imgView
{
    //scrollView作为背景
    UIScrollView *bgView = [[UIScrollView alloc] init];
    bgView.frame = [UIScreen mainScreen].bounds;
    bgView.backgroundColor = [UIColor blackColor];
    UITapGestureRecognizer *tapBg = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapBgView:)];
    [bgView addGestureRecognizer:tapBg];
    
    
    UIImageView *imageView = [[UIImageView alloc] init];
    imageView.image = imgView.image;
    imageView.frame = [bgView convertRect:imgView.frame fromView:self.view];
    [bgView addSubview:imageView];
    
    [[[UIApplication sharedApplication] keyWindow] addSubview:bgView];
    
    self.lastImageView = imageView;
    self.originalFrame = imageView.frame;
    self.scrollView = bgView;
    //最大放大比例
    self.scrollView.maximumZoomScale = 2.0f;
    self.scrollView.showsHorizontalScrollIndicator = NO;
    self.scrollView.showsVerticalScrollIndicator = NO;
    [UIView animateWithDuration:0.35 animations:^{
        CGRect frame = imageView.frame;
        frame.size.width = bgView.frame.size.width;
        frame.size.height = frame.size.width * (imageView.image.size.height / imageView.image.size.width);
        frame.origin.x = 0;
        frame.origin.y = (bgView.frame.size.height - frame.size.height) * 0.5;
        imageView.frame = frame;
    }];
}

- (void)showHeadImageView:(UITapGestureRecognizer *)tap
{
    NSLog(@"点击头像");
    if (![(UIImageView *)tap.view image]) {
        return;
    }
    //scrollView作为背景
    UIScrollView *bgView = [[UIScrollView alloc] init];
    bgView.frame = [UIScreen mainScreen].bounds;
    bgView.backgroundColor = [UIColor blackColor];
    UITapGestureRecognizer *tapBg = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapBgView:)];
    [bgView addGestureRecognizer:tapBg];
    
    UIImageView *picView = (UIImageView *)tap.view;
    
    UIImageView *imageView = [[UIImageView alloc] init];
    imageView.image = picView.image;
    imageView.frame = [bgView convertRect:picView.frame fromView:self.view];
    [bgView addSubview:imageView];
    
    [[[UIApplication sharedApplication] keyWindow] addSubview:bgView];
    
    self.lastImageView = imageView;
    self.originalFrame = imageView.frame;
    self.scrollView = bgView;
    //最大放大比例
    self.scrollView.maximumZoomScale = 2.0f;
    self.scrollView.showsHorizontalScrollIndicator = NO;
    self.scrollView.showsVerticalScrollIndicator = NO;
    [UIView animateWithDuration:0.35 animations:^{
        CGRect frame = imageView.frame;
        frame.size.width = bgView.frame.size.width;
        frame.size.height = frame.size.width * (imageView.image.size.height / imageView.image.size.width);
        frame.origin.x = 0;
        frame.origin.y = (bgView.frame.size.height - frame.size.height) * 0.5;
        imageView.frame = frame;
    }];
}

-(void)tapBgView:(UITapGestureRecognizer *)tapBgRecognizer
{
    self.scrollView.contentOffset = CGPointZero;
    [UIView animateWithDuration:0.35 animations:^{
        self.lastImageView.frame = self.originalFrame;
        tapBgRecognizer.view.backgroundColor = [UIColor clearColor];
    } completion:^(BOOL finished) {
        [tapBgRecognizer.view removeFromSuperview];
        self.scrollView = nil;
        self.lastImageView = nil;
    }];
}

- (void)fansButtonAction:(UIButton *)sender {
    
}

- (void)backAction:(UIButton *)sender {
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)shareAction:(UIButton *)sender {
    ShareAlertView *shareView = [[ShareAlertView alloc]init];
    AppDelegate *appDelegate = (AppDelegate *)[UIApplication sharedApplication].delegate;
    [appDelegate.window addSubview:shareView];
    NSMutableArray *itemArr = [NSMutableArray array];
    NSDictionary *dic0 = @{@"image":@"sinaShareBtn",@"title":@"微博"};
    [itemArr addObject:dic0];
    NSDictionary *dic1 = @{@"image":@"wechat_session",@"title":@"微信好友"};
    [itemArr addObject:dic1];
    NSDictionary *dic2 = @{@"image":@"wechat_timeline",@"title":@"朋友圈"};
    [itemArr addObject:dic2];
    NSDictionary *dic3 = @{@"image":@"iconfont_copy_url",@"title":@"复制链接"};
    [itemArr addObject:dic3];
    [shareView setShareTitle:@"主播分享:"];
    [shareView setSelectItemWithTitleArr:itemArr];
    
    
    shareView.selectedTypeBlock = ^ (NSInteger selectedindex) {
        switch (selectedindex) {
            case 0:{
                //主播头像URL
                NSString *imageStr;
                if([self.jiemuImages rangeOfString:@"/data/upload/"].location !=NSNotFound){
                    imageStr = USERPHOTOHTTPSTRINGZhuBo(self.jiemuImages);
                }
                else{
                    imageStr = USERPOTOAD(self.jiemuImages);
                }
                UIImage *thumbImage = [UIImage imageWithData:[NSData dataWithContentsOfURL:[NSURL URLWithString:imageStr]]];
                //压缩图片大小
                CGFloat compression = 0.9f;
                CGFloat maxCompression = 0.1f;
                int maxFileSize = 32*1000;
                NSData *imageData = UIImageJPEGRepresentation(thumbImage, compression);
                while ([imageData length] > maxFileSize && compression > maxCompression) {
                    compression -= 0.1;
                    imageData = UIImageJPEGRepresentation(thumbImage, compression);
                }
                if ([imageData length] > maxFileSize) {
                    imageData = UIImageJPEGRepresentation([UIImage imageNamed:@"Icon-60"], 0.9);
                    //        imageData = [thumbImage dataWithMaxFileSize:25*25 maxSide:100.0];
                }
                
                NSLog(@"imageData length == %lu",[imageData length]/1024);
                
                WBMessageObject *message = [WBMessageObject message];
                //消息的文本内容
                message.text = [NSString stringWithFormat:@"我觉得【%@】的节目不错~http://tingwen.me/index.php/act/detail/id/%@",self.jiemuName,self.jiemuID];
                WBImageObject *imgObjc = [WBImageObject object];
                imgObjc.imageData = imageData;
                message.imageObject = imgObjc;
                WBSendMessageToWeiboRequest *send = [WBSendMessageToWeiboRequest requestWithMessage:message];
                [WeiboSDK sendRequest:send];
                
            }
                break;
            case 1:{
                [self shareToWechatWithscene:WXSceneSession];
            }
                break;
            case 2:{
                [self shareToWechatWithscene:WXSceneTimeline];
            }
                break;
            default:
            {
                UIPasteboard *gr                             = [UIPasteboard generalPasteboard];
                gr.string                                    = [NSString stringWithFormat:@"http://tingwen.me/index.php/act/detail/id/%@",self.jiemuID];
                XWAlerLoginView *xw = [[XWAlerLoginView alloc]initWithTitle:@"分享链接已复制到您的剪切板~~"];
                [xw show];
            }
                break;
        }
        
    };
}

- (void)shareToWechatWithscene:(int)scene{
    //注册微信
    [WXApi registerApp:KweChatappID];
    if (![WXApi isWXAppInstalled]){
        UIAlertView *al = [[UIAlertView alloc]initWithTitle:@"提示" message:@"请安装微信" delegate:nil cancelButtonTitle:@"知道了" otherButtonTitles: nil];
        [al show];
        return;
    }
    //主播头像URL
    NSString *imageStr;
    if([self.jiemuImages rangeOfString:@"/data/upload/"].location !=NSNotFound){
        imageStr = USERPHOTOHTTPSTRINGZhuBo(self.jiemuImages);
    }
    else{
        imageStr = USERPOTOAD(self.jiemuImages);
    }
    WXMediaMessage *message = [WXMediaMessage message];
    message.title = self.jiemuName;
    message.description = self.jiemuDescription;
    
    [self getImageWithURLStr:imageStr OnSucceed:^(UIImage *image) {
        //压缩图片大小
        CGFloat compression = 0.9f;
        CGFloat maxCompression = 0.1f;
        int maxFileSize = 32*1000;
        //转化为二进制
        NSData *imageData = UIImageJPEGRepresentation(image, compression);
        //压缩小于32K
        while ([imageData length] > maxFileSize && compression > maxCompression) {
            compression -= 0.1;
            imageData = UIImageJPEGRepresentation(image, compression);
        }
        //当图片还是大于32K时，则用图标
        if ([imageData length] < maxFileSize) {
            //设置图片
            [message setThumbData:imageData];
            WXWebpageObject *ext = [WXWebpageObject object];
            ext.webpageUrl =  [NSString stringWithFormat:@"http://tingwen.me/index.php/act/detail/id/%@",self.jiemuID];
            message.mediaObject = ext;
            SendMessageToWXReq *req = [[SendMessageToWXReq alloc] init];
            req.bText = NO;
            req.message = message;
            req.scene = scene;
            [WXApi sendReq:req];
        }else{
            
            [self getImageWithURLStr:imageStr OnSucceed:^(UIImage *image) {
                
                //压缩图片大小
                CGFloat compression = 0.9f;
                CGFloat maxCompression = 0.1f;
                int maxFileSize = 32*1000;
                //转化为二进制
                NSData *imageData = UIImageJPEGRepresentation(image, compression);
                //压缩小于32K
                while ([imageData length] > maxFileSize && compression > maxCompression) {
                    compression -= 0.1;
                    imageData = UIImageJPEGRepresentation(image, compression);
                }
                //当图片还是大于32K时，则用图标
                if ([imageData length] > maxFileSize) {
                    
                    imageData = UIImageJPEGRepresentation([UIImage imageNamed:@"Icon-60"], 0.9);
                }
                //设置图片
                [message setThumbData:imageData];
                WXWebpageObject *ext = [WXWebpageObject object];
                ext.webpageUrl =  [NSString stringWithFormat:@"http://tingwen.me/index.php/act/detail/id/%@",self.jiemuID];
                message.mediaObject = ext;
                SendMessageToWXReq *req = [[SendMessageToWXReq alloc] init];
                req.bText = NO;
                req.message = message;
                req.scene = scene;
                [WXApi sendReq:req];
            }];
        }
        
    }];
}

- (void)pinglundianzanAction:(UIButton *)sender {
    
    UITableViewCell *cell = (UITableViewCell *)[[sender superview] superview];
    UITableView *tableView = (UITableView *)[[cell superview] superview];
    NSIndexPath *indexPath = [tableView indexPathForCell:cell];
    UILabel *dianzanNumlab = (UILabel *)[cell.contentView viewWithTag:indexPath.row + 2000];
    if (sender.selected == YES)
    {
        [sender setImage:[UIImage imageNamed:@"pinglun-10"] forState:UIControlStateNormal];
        dianzanNumlab.text = [NSString stringWithFormat:@"%d",[dianzanNumlab.text intValue] - 1];
        dianzanNumlab.textColor = [UIColor grayColor];
        dianzanNumlab.alpha = 0.7f;
        sender.selected = NO;
        [NetWorkTool postPaoGuoXinWenPingLunDianZanWithaccessToken:[DSE encryptUseDES:ExdangqianUser] andact_id:liuyanArr[indexPath.row][@"id"] sccess:^(NSDictionary *responseObject) {
            NSLog(@"responseObject = %@",responseObject);
            NSLog(@"针对评论取消点赞");
        } failure:^(NSError *error) {
            NSLog(@"error = %@",error);
        }];
    }
    else{
        [sender setImage:[UIImage imageNamed:@"pinglun-yizan"] forState:UIControlStateNormal];
        dianzanNumlab.text = [NSString stringWithFormat:@"%d",[dianzanNumlab.text intValue] + 1];
        dianzanNumlab.textColor = ColorWithRGBA(0, 159, 240, 1);
        dianzanNumlab.alpha = 1.0f;
        sender.selected = YES;
        [NetWorkTool postPaoGuoXinWenPingLunDianZanWithaccessToken:[DSE encryptUseDES:ExdangqianUser] andact_id:liuyanArr[indexPath.row][@"id"] sccess:^(NSDictionary *responseObject) {
            NSLog(@"responseObject = %@",responseObject);
            NSLog(@"针对评论点赞");
        } failure:^(NSError *error) {
            NSLog(@"error = %@",error);
        }];
    }
}
- (void)back {
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)guanzhuBtnAction:(UIButton *)sender
{
    
    if ([[CommonCode readFromUserD:@"isLogin"]boolValue] == YES){
        if (isGuanZhu == NO){
            [NetWorkTool postPaoGuoGuanZhuWithaccessToken:[DSE encryptUseDES:ExdangqianUser] andact_id:self.jiemuID sccess:^(NSDictionary *responseObject) {
                [sender setTitle:@"取消" forState:UIControlStateNormal];
                isGuanZhu = YES;
                [[NSNotificationCenter defaultCenter] postNotificationName:@"reloadAchordata" object:nil];
            } failure:^(NSError *error) {
                NSLog(@"error = %@",error);
            }];
        }
        else{
            [NetWorkTool postPaoGuoQuXiaoGuanZhuWithaccessToken:[DSE encryptUseDES:ExdangqianUser] andact_id:self.jiemuID sccess:^(NSDictionary *responseObject) {
                [sender setTitle:@"+ 关注" forState:UIControlStateNormal];
                isGuanZhu = NO;
                [[NSNotificationCenter defaultCenter] postNotificationName:@"reloadAchordata" object:nil];
            } failure:^(NSError *error) {
                NSLog(@"error = %@",error);
            }];
        }
    }
    else{
        UIAlertController *qingshuruyonghuming = [UIAlertController alertControllerWithTitle:@"请先登录" message:nil preferredStyle:UIAlertControllerStyleAlert];
        [qingshuruyonghuming addAction:[UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        }]];
        [qingshuruyonghuming addAction:[UIAlertAction actionWithTitle:@"去登录" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            LoginVC *loginFriVC = [LoginVC new];
            LoginNavC *loginNavC = [[LoginNavC alloc]initWithRootViewController:loginFriVC];
            [loginNavC.navigationBar setBackgroundColor:[UIColor whiteColor]];
            loginNavC.navigationBar.tintColor = [UIColor blackColor];
            [self presentViewController:loginNavC animated:YES completion:nil];
        }]];
        
        [self presentViewController:qingshuruyonghuming animated:YES completion:nil];
    }
}

- (void)gaibianyanse:(NSNotification *)notification {
    [xinwenshuaxinTableView reloadData];
}

- (void)clickPinglunImgHead:(UITapGestureRecognizer *)tapG {
    NSLog(@"%ld",tapG.view.tag);
    NSDictionary *components = liuyanArr[tapG.view.tag - 1000];
    [self skipToUserVCWihtcomponents:components];
}

- (void)skipToUserVCWihtcomponents:(NSDictionary *)components{
    gerenzhuyeVC *gerenzhuye = [gerenzhuyeVC new];
    if ([components[@"user_login"] isEqualToString:ExdangqianUser] && [[CommonCode readFromUserD:@"isLogin"]boolValue] == YES) {
        gerenzhuye.isMypersonalPage = YES;
    }
    else{
        gerenzhuye.isMypersonalPage = NO;
    }
    gerenzhuye.isNewsComment = NO;
    gerenzhuye.user_nicename = components[@"user_nicename"];
    gerenzhuye.sex = components[@"sex"];
    gerenzhuye.signature = components[@"signature"];
    gerenzhuye.user_login = components[@"user_login"];
    gerenzhuye.avatar = components[@"avatar"];
    gerenzhuye.fan_num = components[@"fan_num"];
    gerenzhuye.guan_num = components[@"guan_num"];
    gerenzhuye.user_id = components[@"uid"];
    self.hidesBottomBarWhenPushed = YES;
    [self.navigationController pushViewController:gerenzhuye animated:YES];
    self.hidesBottomBarWhenPushed = YES;
}


#pragma mark - 获取图片
- (void)getImageWithURLStr:(NSString *)urlstring OnSucceed:(void(^)(UIImage *image))succeed {
    //获取图片管理
    SDWebImageManager *manager = [SDWebImageManager sharedManager];
    //图片URL
    NSURL *url = [NSURL URLWithString:urlstring];
    //获取缓存key
    NSString *cacheKey = [manager cacheKeyForURL:url];
    //判断图片是否缓存
    if ([manager cachedImageExistsForURL:url]) {
        //先从内存中获取图片
        UIImage *image = [[SDImageCache sharedImageCache] imageFromMemoryCacheForKey:cacheKey];
        //如果图片为空，则从本地获取图片
        if (!image) {
            image = [[SDImageCache sharedImageCache] imageFromDiskCacheForKey:cacheKey];
        }
        //如果还是不存在图片， 则取图标
        if (!image) {
            image = [UIImage imageNamed:@"Icon-60"];
        }
        
        dispatch_async(dispatch_get_main_queue(), ^{
            succeed(image);
        });
        
    }else{
        [manager downloadImageWithURL:url options:0 progress:^(NSInteger receivedSize, NSInteger expectedSize) {
            
        } completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, BOOL finished, NSURL *imageURL) {
            //下载图片完成后， 存在图片
            if (image) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    succeed(image);
                });
                
            }else if (error){
                //如果发生错误，则取图标
                UIImage *palaceImage = [UIImage imageNamed:@"Icon-60"];
                dispatch_async(dispatch_get_main_queue(), ^{
                    succeed(palaceImage);
                });
            }
        }];
    }
}

- (void)rewardButtonAction:(UIButton *)sender{
    [self reward];
}

- (void)goButtonAction:(UIButton *)sender {
    
    if (_isOnRank) {
        NSIndexPath *index = [NSIndexPath indexPathForRow:_myRank - 1 inSection:0];
        UITableView *fansBoardTableView = (UITableView *)[TwoScrollV viewWithTag:4];
        [fansBoardTableView scrollToRowAtIndexPath:index atScrollPosition:UITableViewScrollPositionTop animated:YES];
    }
    else{
        [self reward];
        
    }
}

- (void)reward{
    //弹框赞赏
    if ([[CommonCode readFromUserD:@"isLogin"]boolValue] == YES){
        _isRewardLoginBack = NO;
        [self rewardAlert];
    }
    else{
        //先登录
        _isRewardLoginBack = YES;
        LoginVC *loginFriVC = [LoginVC new];
        LoginNavC *loginNavC = [[LoginNavC alloc]initWithRootViewController:loginFriVC];
        [loginNavC.navigationBar setBackgroundColor:[UIColor whiteColor]];
        loginNavC.navigationBar.tintColor = [UIColor blackColor];
        [self presentViewController:loginNavC animated:YES completion:nil];
        _isRewardLoginBack = NO;
    }
}

- (void)rewardAlert{
    
    NSMutableArray *items = [NSMutableArray array];
    NSDictionary *dic0 = @{@"title":@"1听币"};
    [items addObject:dic0];
    NSDictionary *dic1 = @{@"title":@"5听币"};
    [items addObject:dic1];
    NSDictionary *dic2 = @{@"title":@"10听币"};
    [items addObject:dic2];
    NSDictionary *dic3 = @{@"title":@"50听币"};
    [items addObject:dic3];
    NSDictionary *dic4 = @{@"title":@"100听币"};
    [items addObject:dic4];
    NSDictionary *dic5 = @{@"title":@"自定义"};
    [items addObject:dic5];
    
    self.rewardView = [RewardCustomView new];
    AppDelegate *appDelegate = (AppDelegate *)[UIApplication sharedApplication].delegate;
    [appDelegate.window addSubview:self.rewardView];
    [self.rewardView setSelectItemWithTitleArr:items];
    
    DefineWeakSelf;
    self.rewardView.rewardBlock = ^ (float rewardCount){
        NSLog(@"%f",rewardCount);
        PayOnlineViewController *vc = [PayOnlineViewController new];
        NSString *accesstoken = nil;
        accesstoken = AvatarAccessToken;
        [weakSelf.rewardView removeFromSuperview];
        [NetWorkTool getListenMoneyWithaccessToken:accesstoken sccess:^(NSDictionary *responseObject) {
            if ([responseObject[@"status"] integerValue] == 1) {
                vc.balanceCount = [responseObject[@"results"][@"listen_money"] doubleValue];
                vc.rewardCount = rewardCount;
                vc.uid = weakSelf.jiemuID;
                vc.post_id = @"";
                vc.isPayClass = NO;
                weakSelf.hidesBottomBarWhenPushed=YES;
                [weakSelf.navigationController setNavigationBarHidden:NO animated:YES];
                [weakSelf.navigationController pushViewController:vc animated:YES];
                weakSelf.hidesBottomBarWhenPushed = YES;
            }
            
        } failure:^(NSError *error) {
            
        }];
        
    };
}

- (void)rewardLoginfirst{
    
    LoginVC *loginFriVC = [LoginVC new];
    LoginNavC *loginNavC = [[LoginNavC alloc]initWithRootViewController:loginFriVC];
    [loginNavC.navigationBar setBackgroundColor:[UIColor whiteColor]];
    loginNavC.navigationBar.tintColor = [UIColor blackColor];
    [self presentViewController:loginNavC animated:YES completion:nil];
}
- (void)loginFirst {
    
    UIAlertController *qingshuruyonghuming = [UIAlertController alertControllerWithTitle:@"温馨提示" message:@"您还没登录，请先登录后操作" preferredStyle:UIAlertControllerStyleAlert];
    [qingshuruyonghuming addAction:[UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
    }]];
    [qingshuruyonghuming addAction:[UIAlertAction actionWithTitle:@"登录" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        LoginVC *loginFriVC = [LoginVC new];
        LoginNavC *loginNavC = [[LoginNavC alloc]initWithRootViewController:loginFriVC];
        [loginNavC.navigationBar setBackgroundColor:[UIColor whiteColor]];
        loginNavC.navigationBar.tintColor = [UIColor blackColor];
        [self presentViewController:loginNavC animated:YES completion:nil];
    }]];
    
    [self presentViewController:qingshuruyonghuming animated:YES completion:nil];
}

- (void)SVPDismiss {
    [SVProgressHUD dismiss];
}
//点击播放按钮
- (void)playBtnPlay:(zhuboxiangqingNewVCPlayBtn *)button
{
    NSIndexPath *indexPath = button.indexPath;
    button.selected = YES;
    button.titleLab.textColor = gMainColor;
    _isTapPlayBtn = YES;
    if ([[CommonCode readFromUserD:@"dangqianbofangxinwenID"] isEqualToString:xinwenArr[indexPath.row][@"id"]]){
        
        if (self.isfaxian) {
            self.hidesBottomBarWhenPushed = YES;
            [self.navigationController.navigationBar setHidden:NO];
            [[NSNotificationCenter defaultCenter]postNotificationName:@"getAhocComment" object:xinwenArr[indexPath.row][@"id"]];
        }
        else{
            [self.navigationController popViewControllerAnimated:YES];
            [[NSNotificationCenter defaultCenter]postNotificationName:@"getAhocComment" object:xinwenArr[indexPath.row][@"id"]];
        }
        [bofangVC shareInstance].isFromzhuboXiangQingVC = YES;
        if ([bofangVC shareInstance].isPlay) {
        }
        else{
            [[bofangVC shareInstance] doplay2];
        }
    }
    else{
        
        [bofangVC shareInstance].newsModel.jiemuID = xinwenArr[indexPath.row][@"id"];
        [bofangVC shareInstance].newsModel.Titlejiemu = xinwenArr[indexPath.row][@"post_title"];
        [bofangVC shareInstance].newsModel.RiQijiemu = xinwenArr[indexPath.row][@"post_date"];
        [bofangVC shareInstance].newsModel.ImgStrjiemu = xinwenArr[indexPath.row][@"smeta"];
        [bofangVC shareInstance].newsModel.post_lai = xinwenArr[indexPath.row][@"post_lai"];
        [bofangVC shareInstance].newsModel.post_news = self.jiemuID;
        [bofangVC shareInstance].newsModel.jiemuName = self.jiemuName;
        [bofangVC shareInstance].newsModel.jiemuDescription = self.jiemuDescription;
        [bofangVC shareInstance].newsModel.jiemuImages = self.jiemuImages;
        [bofangVC shareInstance].newsModel.jiemuFan_num = self.jiemuFan_num;
        [bofangVC shareInstance].newsModel.jiemuMessage_num = self.jiemuMessage_num;
        [bofangVC shareInstance].newsModel.jiemuIs_fan = self.jiemuIs_fan;
        [bofangVC shareInstance].newsModel.post_mp = xinwenArr[indexPath.row][@"post_mp"];
        [bofangVC shareInstance].newsModel.post_time = xinwenArr[indexPath.row][@"post_time"];
        [bofangVC shareInstance].newsModel.post_keywords = xinwenArr[indexPath.row][@"post_keywords"];
        [bofangVC shareInstance].newsModel.url = xinwenArr[indexPath.row][@"url"];
        [bofangVC shareInstance].yinpinzongTime.text = [[bofangVC shareInstance] convertStringWithTime:[xinwenArr[indexPath.row][@"post_time"] intValue] / 1000];
        ExcurrentNumber = (int)indexPath.row;
        [bofangVC shareInstance].newsModel.ImgStrjiemu = xinwenArr[indexPath.row][@"smeta"];
        [bofangVC shareInstance].newsModel.ZhengWenjiemu = xinwenArr[indexPath.row][@"post_excerpt"];
        [bofangVC shareInstance].newsModel.praisenum = xinwenArr[indexPath.row][@"praisenum"];
        [bofangVC shareInstance].iszhuboxiangqing = YES;
        [[bofangVC shareInstance].tableView reloadData];
        [Explayer replaceCurrentItemWithPlayerItem:[[AVPlayerItem alloc]initWithURL:[NSURL URLWithString:xinwenArr[indexPath.row][@"post_mp"]]]];
        if ([bofangVC shareInstance].isPlay || ExIsKaiShiBoFang == NO) {
        }
        else{
            [[bofangVC shareInstance] doplay2];
        }
        ExisRigester = YES;
        ExIsKaiShiBoFang = YES;
        ExwhichBoFangYeMianStr = @"zhuboxiangqingbofang";
        if (self.isfaxian) {
            [[NSNotificationCenter defaultCenter]postNotificationName:@"getAhocComment" object:xinwenArr[indexPath.row][@"id"]];
        }
        else{
            [self.navigationController popViewControllerAnimated:YES];
            [[NSNotificationCenter defaultCenter]postNotificationName:@"getAhocComment" object:xinwenArr[indexPath.row][@"id"]];
        }
        [[NSNotificationCenter defaultCenter] postNotificationName:@"yuanpanzhuan" object:nil];
        [[NSNotificationCenter defaultCenter] postNotificationName:@"qiehuanxinwen" object:nil];
        [CommonCode writeToUserD:xinwenArr andKey:@"zhuyeliebiao"];
        [CommonCode writeToUserD:xinwenArr[indexPath.row][@"id"] andKey:@"dangqianbofangxinwenID"];
        if ([[CommonCode readFromUserD:@"yitingguoxinwenID"] isKindOfClass:[NSArray class]])
        {
            NSMutableArray *yitingguoArr = [NSMutableArray arrayWithArray:[CommonCode readFromUserD:@"yitingguoxinwenID"]];
            [yitingguoArr addObject:xinwenArr[indexPath.row][@"id"]];
            [CommonCode writeToUserD:yitingguoArr andKey:@"yitingguoxinwenID"];
        }else
        {
            NSMutableArray *yitingguoArr = [NSMutableArray array];
            [yitingguoArr addObject:xinwenArr[indexPath.row][@"id"]];
            [CommonCode writeToUserD:yitingguoArr andKey:@"yitingguoxinwenID"];
        }
        [xinwenshuaxinTableView reloadData];
    }
}

/**
 图片列表点击显示大图

 @param tap imageTap
 */
- (void)showZoomImageView:(UITapGestureRecognizer *)tap{
    if (![(UIImageView *)tap.view image]) {
        return;
    }
    [YJImageBrowserView showWithImageView:(UIImageView *)tap.view];
}
#pragma mark - UITableViewDelegate

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if ([tableView isEqual:xinwenshuaxinTableView]){
        return xinwenArr.count;
    }
    else if ([tableView isEqual:fansWallTableView]){
        return self.rewardListArray.count;
    }
    else if ([tableView isEqual:pinglunhoushuaxinTableView]){
        return liuyanArr.count;
    }
    else if ([tableView isEqual:ImageTableView]){
        return imageArr.count;
    }
    else{
        return 0;
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    //粉丝榜
    if ([tableView isEqual:fansWallTableView]){
        return 40.0f;
    }
    else{
        return 0.01f;
    }
    
}

- (nullable UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section{
    //粉丝榜
    if ([tableView isEqual:fansWallTableView]){
        UIView *sectionHeadView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, 40)];
        [sectionHeadView setBackgroundColor:gSubColor];
        //TODO:我的排名
        [sectionHeadView addSubview:self.myRanking];
        
        UIButton *goButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [goButton setFrame:CGRectMake(SCREEN_WIDTH - 75, 10, 60, 20)];
        [goButton.titleLabel setFont:gFontSub11];
        
        [goButton.layer setBorderWidth:0.5f];
        [goButton.layer setBorderColor:gThinLineColor.CGColor];
        [goButton.layer setMasksToBounds:YES];
        [goButton.layer setCornerRadius:5.0f];
        [goButton addTarget:self action:@selector(goButtonAction:) forControlEvents:UIControlEventTouchUpInside];
        //追加赞赏
        UIButton *rewardButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [rewardButton setFrame:CGRectMake(SCREEN_WIDTH - 145, 10, 60, 20)];
        [rewardButton.titleLabel setFont:gFontSub11];
        
        [rewardButton.layer setBorderWidth:0.5f];
        [rewardButton.layer setBorderColor:gThinLineColor.CGColor];
        [rewardButton.layer setMasksToBounds:YES];
        [rewardButton.layer setCornerRadius:5.0f];
        [rewardButton addTarget:self action:@selector(rewardButtonAction:) forControlEvents:UIControlEventTouchUpInside];
        [rewardButton setBackgroundColor:gButtonRewardColor];
        [rewardButton setTitle:@"我要赞赏" forState:UIControlStateNormal];
        [rewardButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [sectionHeadView addSubview:rewardButton];
        
        if (_isOnRank) {
            [rewardButton setHidden:NO];
            [goButton setTitleColor:gTextColorBackground forState:UIControlStateNormal];
            [goButton setTitle:@"立即前往" forState:UIControlStateNormal];
        }
        else{
            [rewardButton setHidden:YES];
            [goButton setBackgroundColor:gButtonRewardColor];
            [goButton setTitle:@"我要上榜" forState:UIControlStateNormal];
            [goButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        }
        [sectionHeadView addSubview:goButton];
        return sectionHeadView;
    }
    else{
        return nil;
    }
}

#pragma mark - UITableViewDataSource

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    //新闻
    if ([tableView isEqual:xinwenshuaxinTableView]){
        static NSString *zhuboxiangqingxinwenIdentify = @"zhuboxiangqingxinwenIdentify";
        UITableViewCell *cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:zhuboxiangqingxinwenIdentify];
        if (!cell){
            cell = [tableView dequeueReusableCellWithIdentifier:zhuboxiangqingxinwenIdentify forIndexPath:indexPath];
        }
        UILabel *titleLab = [[UILabel alloc]init];
        zhuboxiangqingNewVCPlayBtn *playBtn = [[zhuboxiangqingNewVCPlayBtn alloc] init];
        if (self.isClass) {
            titleLab.frame = CGRectMake(72.0 / 375 * IPHONE_W, 12.0 / 667 * IPHONE_H, SCREEN_WIDTH - 137.0 / 375 * IPHONE_W, 21 * 3);
            //播放按钮
            playBtn.titleLab = titleLab;
            playBtn.frame = CGRectMake(SCREEN_WIDTH - 50 - 10, 10, 50, 50);
            [playBtn setImage:[UIImage imageNamed:@"classpause"] forState:UIControlStateNormal];
            [playBtn setImage:[UIImage imageNamed:@"classplay"] forState:UIControlStateSelected];
            //            playBtn.tag = indexPath.row;
            playBtn.indexPath = indexPath;
            [playBtn addTarget:self action:@selector(playBtnPlay:) forControlEvents:UIControlEventTouchUpInside];
            [cell.contentView addSubview:playBtn];
        }else{
            titleLab.frame = CGRectMake(72.0 / 375 * IPHONE_W, 12.0 / 667 * IPHONE_H, SCREEN_WIDTH - 87.0 / 375 * IPHONE_W, 21 * 3);
        }
        titleLab.text = xinwenArr[indexPath.row][@"post_title"];
        if ([[CommonCode readFromUserD:@"yitingguoxinwenID"] isKindOfClass:[NSArray class]]){
            NSArray *yitingguoArr = [NSArray arrayWithArray:[CommonCode readFromUserD:@"yitingguoxinwenID"]];
            for (int i = 0; i < yitingguoArr.count - 1; i ++ )
            {
                if ([xinwenArr[indexPath.row][@"id"] isEqualToString:yitingguoArr[i]])
                {
                    if ([[CommonCode readFromUserD:@"dangqianbofangxinwenID"] isEqualToString:xinwenArr[indexPath.row][@"id"]])
                    {
                        titleLab.textColor = gMainColor;
                        break;
                    }
                    else{
                        titleLab.textColor = [[UIColor grayColor] colorWithAlphaComponent:0.7f];
                        break;
                    }
                }else
                {
                    titleLab.textColor = nTextColorMain;
                }
            }
        }
        if ([[CommonCode readFromUserD:@"dangqianbofangxinwenID"] isEqualToString:xinwenArr[indexPath.row][@"id"]])
        {
            if (![bofangVC shareInstance].isPlay && !_isTapPlayBtn){
                playBtn.selected = NO;
                titleLab.textColor = [[UIColor grayColor] colorWithAlphaComponent:0.7f];
            }else{
                playBtn.selected = YES;
                titleLab.textColor = gMainColor;
            }
        }
        titleLab.numberOfLines = 0;
        titleLab.textAlignment = NSTextAlignmentLeft;
        titleLab.font = [UIFont boldSystemFontOfSize:17.0f];
        [cell.contentView addSubview:titleLab];
        [titleLab setNumberOfLines:3];
        titleLab.lineBreakMode = NSLineBreakByWordWrapping;
        CGSize size = [titleLab sizeThatFits:CGSizeMake(titleLab.frame.size.width, MAXFLOAT)];
        titleLab.frame = CGRectMake(titleLab.frame.origin.x, titleLab.frame.origin.y, titleLab.frame.size.width, size.height);
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        [cell.contentView addSubview:titleLab];
        
        if (IS_IPAD) {
            //正文
            UILabel *detailNews = [[UILabel alloc]initWithFrame:CGRectMake(titleLab.frame.origin.x, titleLab.frame.origin.y + titleLab.frame.size.height + 10.0 / 667 * SCREEN_HEIGHT, titleLab.frame.size.width, 21.0 / 667 *IPHONE_H)];
            detailNews.text = xinwenArr[indexPath.row][@"post_excerpt"];
            detailNews.textColor = gTextColorSub;
            detailNews.font = [UIFont systemFontOfSize:15.0f];
            [cell.contentView addSubview:detailNews];
        }
        
        //大小
        if (!self.isClass) {
            UIButton *dataLab = [UIButton buttonWithType:UIButtonTypeCustom];
            [dataLab setFrame:CGRectMake(SCREEN_WIDTH -  55.0 / 375 * IPHONE_W, 64.0 / 667 * SCREEN_HEIGHT, 35.0 / 375 * IPHONE_W, 15.0 / 667 * SCREEN_HEIGHT)];
            [dataLab setTitle:[NSString stringWithFormat:@"%.1lf%@",[xinwenArr[indexPath.row][@"post_size"] intValue] / 1024.0 / 1024.0,@"M"] forState:UIControlStateNormal];
            dataLab.backgroundColor = [UIColor whiteColor];
            [dataLab.layer setBorderWidth:0.5f];
            [dataLab.layer setBorderColor:nTextColorSub.CGColor];
            [dataLab.layer setMasksToBounds:YES];
            [dataLab.layer setCornerRadius:4.0f];
            [dataLab setTitleColor:nTextColorSub forState:UIControlStateNormal];
            [dataLab.titleLabel setFont:[UIFont systemFontOfSize:10.0f]];
            [cell.contentView addSubview:dataLab];
        }
        
        
        TTTAttributedLabel *riqiLab = [[TTTAttributedLabel alloc]initWithFrame:CGRectMake(20.0 / 375 * IPHONE_W, 12.0 / 667 * SCREEN_HEIGHT, 52.0 / 375 * IPHONE_W, 30.0 / 667 * SCREEN_HEIGHT)];
        riqiLab.text = xinwenArr[indexPath.row][@"post_modified"];
        NSDate *date = [NSDate dateFromString:xinwenArr[indexPath.row][@"post_modified"]];
        riqiLab.text = [date showTimeFormatD];
        
        NSRange rangeD = NSMakeRange(0,2);
        [riqiLab setLinkAttributes:@{NSForegroundColorAttributeName : nTextColorMain,NSFontAttributeName :[UIFont systemFontOfSize:20.0f]}];
        [riqiLab addLinkToTransitInformation:nil withRange:rangeD];
        NSRange rangeM = NSMakeRange(2,3);
        [riqiLab setLinkAttributes:@{NSForegroundColorAttributeName : nTextColorMain,NSFontAttributeName :[UIFont systemFontOfSize:8.0f]}];
        [riqiLab addLinkToTransitInformation:nil withRange:rangeM];
        riqiLab.textColor = nTextColorMain;
        riqiLab.font = [UIFont systemFontOfSize:8.0f];
        [cell.contentView addSubview:riqiLab];
        
        return cell;
    }
    //粉丝榜
    else if ([tableView isEqual:fansWallTableView]){
        static NSString *identify = @"reWardCell";
        RewardListTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:identify];
        if (cell == nil) {
            cell = [[RewardListTableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identify];
        }
        [tableView setSeparatorStyle:UITableViewCellSeparatorStyleSingleLine];
        [cell updateCellValueWithDict:self.rewardListArray[indexPath.row] andIndexPathOfRow:indexPath.row];
        [cell setSelectionStyle:UITableViewCellSelectionStyleNone];
        return cell;
    }
    //留言
    else if ([tableView isEqual:pinglunhoushuaxinTableView]){
        static NSString *pinglunIdentify = @"ZhuBopinglunIdentify";
        UITableViewCell *cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:pinglunIdentify];
        if (!cell){
            cell = [tableView dequeueReusableCellWithIdentifier:pinglunIdentify];
        }
        UIImageView *pinglunImg = [[UIImageView alloc]initWithFrame:CGRectMake(5.0 / 375 * IPHONE_W, 8.0 / 667 * IPHONE_H, 50.0 / 667 * SCREEN_HEIGHT, 50.0 / 667 * IPHONE_H)];
        if ([liuyanArr[indexPath.row][@"avatar"]  rangeOfString:@"http"].location != NSNotFound)
        {
            [pinglunImg sd_setImageWithURL:[NSURL URLWithString:liuyanArr[indexPath.row][@"avatar"]] placeholderImage:[UIImage imageNamed:@"right-1"]];
        }else
        {
            [pinglunImg sd_setImageWithURL:[NSURL URLWithString:USERPHOTOHTTPSTRING(liuyanArr[indexPath.row][@"avatar"])] placeholderImage:[UIImage imageNamed:@"right-1"]];
        }
        pinglunImg.contentMode = UIViewContentModeScaleAspectFill;
        pinglunImg.layer.masksToBounds = YES;
        pinglunImg.layer.cornerRadius = 25.0 / 667 * SCREEN_HEIGHT;
        pinglunImg.tag = 1000 + indexPath.row;
        [pinglunImg setUserInteractionEnabled:YES];
        UITapGestureRecognizer *TapG = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(clickPinglunImgHead:)];
        [pinglunImg addGestureRecognizer:TapG];
        [cell.contentView addSubview:pinglunImg];
        
        UILabel *pinglunTitle = [[UILabel alloc]initWithFrame:CGRectMake(CGRectGetMaxX(pinglunImg.frame) + 8.0 / 375 * IPHONE_W, 10.0 / 667 * IPHONE_H, 200.0 / 375 * IPHONE_W, 20.0 / 667 * IPHONE_H)];
        pinglunTitle.text = liuyanArr[indexPath.row][@"full_name"];
        pinglunTitle.textAlignment = NSTextAlignmentLeft;
        pinglunTitle.textColor = [UIColor blackColor];
        pinglunTitle.font = [UIFont systemFontOfSize:16.0f];
        [cell.contentView addSubview:pinglunTitle];
        
        UILabel *pinglunshijian = [[UILabel alloc]initWithFrame:CGRectMake(CGRectGetMaxX(pinglunImg.frame) + 8.0 / 375 * IPHONE_W, CGRectGetMaxY(pinglunTitle.frame) + 5.0 / 667 * IPHONE_H, 200.0 / 375 * IPHONE_W, 20.0 / 667 * IPHONE_H)];
        pinglunshijian.text = liuyanArr[indexPath.row][@"createtime"];
        pinglunshijian.textAlignment = NSTextAlignmentLeft;
        pinglunshijian.textColor = [UIColor grayColor];
        pinglunshijian.font = [UIFont systemFontOfSize:13.0f];
        [cell.contentView addSubview:pinglunshijian];
        
        //评论
        TTTAttributedLabel *pinglunLab = [[TTTAttributedLabel alloc]initWithFrame:CGRectMake(CGRectGetMaxX(pinglunImg.frame) - 3.0 / 375 * IPHONE_W, CGRectGetMaxY(pinglunshijian.frame) + 10.0 / 667 * IPHONE_H, IPHONE_W - 80.0 / 375 * IPHONE_W, 20.0 / 667 * IPHONE_H)];
        pinglunLab.text = liuyanArr[indexPath.row][@"content"];
        pinglunLab.textColor = [UIColor blackColor];
        pinglunLab.font = [UIFont systemFontOfSize:16.0f];
        pinglunLab.textAlignment = NSTextAlignmentLeft;
        pinglunLab.tag = indexPath.row + 3000;
        pinglunLab.numberOfLines = 0;
        pinglunLab.lineSpacing = 5;
        pinglunLab.fd_collapsed = NO;
        pinglunLab.lineBreakMode = NSLineBreakByWordWrapping;
        if ([liuyanArr[indexPath.row][@"content"] rangeOfString:@"[e1]"].location != NSNotFound && [liuyanArr[indexPath.row][@"content"] rangeOfString:@"[/e1]"].location != NSNotFound){
            if ([liuyanArr[indexPath.row][@"to_user_login"] length]) {
                pinglunLab.text = [NSString stringWithFormat:@"回复@%@:%@",[liuyanArr[indexPath.row][@"to_user_nicename"] length] ? liuyanArr[indexPath.row][@"to_user_nicename"]:liuyanArr[indexPath.row][@"to_user_login"],[CommonCode jiemiEmoji:liuyanArr[indexPath.row][@"content"]]];
                NSMutableDictionary *to_user = [NSMutableDictionary new];
                [to_user setValue:liuyanArr[indexPath.row][@"to_user_nicename"] forKey:@"user_nicename"];
                [to_user setValue:liuyanArr[indexPath.row][@"to_sex"] forKey:@"sex"];
                [to_user setValue:liuyanArr[indexPath.row][@"to_signature"] forKey:@"signature"];
                [to_user setValue:liuyanArr[indexPath.row][@"to_user_login"] forKey:@"user_login"];
                [to_user setValue:liuyanArr[indexPath.row][@"to_avatar"] forKey:@"avatar"];
                [to_user setValue:liuyanArr[indexPath.row][@"to_uid"] forKey:@"id"];
                
                NSRange nameRange = NSMakeRange(2, [liuyanArr[indexPath.row][@"to_user_nicename"] length] ? [liuyanArr[indexPath.row][@"to_user_nicename"] length] + 1 : [liuyanArr[indexPath.row][@"to_user_login"] length] + 1);
                [pinglunLab setLinkAttributes:@{NSForegroundColorAttributeName : gMainColor,NSFontAttributeName :gFontMajor16}];
                [pinglunLab setActiveLinkAttributes:@{NSForegroundColorAttributeName : gMainColor,NSFontAttributeName :gFontMajor16}];
                [pinglunLab addLinkToTransitInformation:to_user withRange:nameRange];
                [pinglunLab setDelegate:self];
                
            }
            else{
                pinglunLab.text = [CommonCode jiemiEmoji:liuyanArr[indexPath.row][@"content"]];
            }
            
        }
        else{
            if ([liuyanArr[indexPath.row][@"to_user_login"] length]) {
                pinglunLab.text = [NSString stringWithFormat:@"回复@%@:%@",[liuyanArr[indexPath.row][@"to_user_nicename"] length] ? liuyanArr[indexPath.row][@"to_user_nicename"]:liuyanArr[indexPath.row][@"to_user_login"],liuyanArr[indexPath.row][@"content"]];
                NSMutableDictionary *to_user = [NSMutableDictionary new];
                [to_user setValue:liuyanArr[indexPath.row][@"to_user_nicename"] forKey:@"user_nicename"];
                [to_user setValue:liuyanArr[indexPath.row][@"to_sex"] forKey:@"sex"];
                [to_user setValue:liuyanArr[indexPath.row][@"to_signature"] forKey:@"signature"];
                [to_user setValue:liuyanArr[indexPath.row][@"to_user_login"] forKey:@"user_login"];
                [to_user setValue:liuyanArr[indexPath.row][@"to_avatar"] forKey:@"avatar"];
                [to_user setValue:liuyanArr[indexPath.row][@"to_uid"] forKey:@"id"];
                
                NSRange nameRange = NSMakeRange(2,  [liuyanArr[indexPath.row][@"to_user_nicename"] length] ? [liuyanArr[indexPath.row][@"to_user_nicename"] length] + 1 : [liuyanArr[indexPath.row][@"to_user_login"] length] + 1);
                [pinglunLab setLinkAttributes:@{NSForegroundColorAttributeName : gMainColor,NSFontAttributeName :gFontMajor16}];
                [pinglunLab setActiveLinkAttributes:@{NSForegroundColorAttributeName : gMainColor,NSFontAttributeName :gFontMajor16}];
                [pinglunLab addLinkToTransitInformation:to_user withRange:nameRange];
                [pinglunLab setDelegate:self];
            }
            else{
                pinglunLab.text = liuyanArr[indexPath.row][@"content"];
            }
        }
        //获取tttLabel的高度
        //先通过NSMutableAttributedString设置和上面tttLabel一样的属性,例如行间距,字体
        NSMutableAttributedString *attrString = [[NSMutableAttributedString alloc] initWithString:pinglunLab.text];
        //自定义str和TTTAttributedLabel一样的行间距
        NSMutableParagraphStyle *paragrapStyle = [[NSMutableParagraphStyle alloc] init];
        [paragrapStyle setLineSpacing:5];
        //设置行间距
        [attrString addAttribute:NSParagraphStyleAttributeName value:paragrapStyle range:NSMakeRange(0, [pinglunLab.text length])];
        //设置字体
        [attrString addAttribute:NSFontAttributeName value:[UIFont systemFontOfSize:16] range:NSMakeRange(0, [pinglunLab.text length])];
        //得到自定义行间距的UILabel的高度
        //CGSizeMake(300,MAXFLOAt)中的300,代表是UILable控件的宽度,它和初始化TTTAttributedLabel的宽度是一样的.
        CGFloat height = [TTTAttributedLabel sizeThatFitsAttributedString:attrString withConstraints:CGSizeMake(pinglunLab.frame.size.width, MAXFLOAT) limitedToNumberOfLines:0].height;
        //重新改变tttLabel的frame高度
        CGRect rect = pinglunLab.frame;
        rect.size.height = height + 10 ;
        pinglunLab.frame = rect;
        [cell.contentView addSubview:pinglunLab];
        cell.tag = indexPath.row + 1000;
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        
        
        PinglundianzanCustomBtn *PingLundianzanBtn = [PinglundianzanCustomBtn buttonWithType:UIButtonTypeCustom];
        PingLundianzanBtn.frame = CGRectMake(IPHONE_W - 60.0 / 375 * IPHONE_W, 20.0 / 667 * IPHONE_H, 50.0 / 375 * IPHONE_W, 20.0 / 667 * IPHONE_H);
        //        PingLundianzanBtn.enabled = NO;
        PingLundianzanBtn.backgroundColor = [UIColor clearColor];
        //        [PingLundianzanBtn.imageView setContentMode:UIViewContentModeCenter];
        [cell.contentView addSubview:PingLundianzanBtn];
        [PingLundianzanBtn addTarget:self action:@selector(pinglundianzanAction:) forControlEvents:UIControlEventTouchUpInside];
        
        PingLundianzanNumLab = [[UILabel alloc]initWithFrame:CGRectMake(CGRectGetMaxX(PingLundianzanBtn.frame) - 30.0 / 375 * IPHONE_W, PingLundianzanBtn.frame.origin.y + 1.0 / 667 * IPHONE_H, 20.0 / 375 * IPHONE_W, 20.0 / 667 * IPHONE_H)];
        PingLundianzanNumLab.text = liuyanArr[indexPath.row][@"praisenum"];
        //        [PingLundianzanNumLab addTapGesWithTarget:self action:@selector(pinglundianzanAction:)];
        PingLundianzanNumLab.textAlignment = NSTextAlignmentCenter;
        PingLundianzanNumLab.font = [UIFont systemFontOfSize:16.0f];
        PingLundianzanNumLab.tag = indexPath.row + 2000;
        [cell.contentView insertSubview:PingLundianzanNumLab aboveSubview:PingLundianzanBtn];
        [PingLundianzanBtn setImage:[UIImage imageNamed:@"pinglun-10"] forState:UIControlStateNormal];
        if ([[NSString stringWithFormat:@"%@",liuyanArr[indexPath.row][@"praiseFlag"]] isEqualToString:@"1"]){
            [PingLundianzanBtn setImage:[UIImage imageNamed:@"pinglun-10"] forState:UIControlStateNormal];
            PingLundianzanBtn.selected = NO;
            PingLundianzanNumLab.textColor = [UIColor grayColor];
            PingLundianzanNumLab.alpha = 0.7f;
        }
        else if([[NSString stringWithFormat:@"%@",liuyanArr[indexPath.row][@"praiseFlag"]] isEqualToString:@"2"]){
            [PingLundianzanBtn setImage:[UIImage imageNamed:@"pinglun-yizan"] forState:UIControlStateNormal];
            PingLundianzanBtn.selected = YES;
            PingLundianzanNumLab.textColor = ColorWithRGBA(0, 159, 240, 1);
            PingLundianzanNumLab.alpha = 1.0f;
        }
        cell.tag = indexPath.row + 1000;
        return cell;
    }else if ([tableView isEqual:ImageTableView]){
        AutoImageTableViewCell *cell = [AutoImageTableViewCell cellWithTableView:tableView];
        cell.frameModel = imageArr[indexPath.row];
        cell.tapImage = ^(UITapGestureRecognizer *tap) {
            [self showZoomImageView:tap];
        };
        return cell;
    }
    else
    {
        UITableViewCell *cell = [[UITableViewCell alloc] init];
        return cell;
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if ([tableView isEqual:xinwenshuaxinTableView]){
        if (self.isClass) {
            return 70.0 / 667 * SCREEN_HEIGHT;
        }else{
            return 99.0 / 667 * SCREEN_HEIGHT;
        }
    }
    else if ([tableView isEqual:fansWallTableView]){
        if (indexPath.row == 0 || indexPath.row == 1 || indexPath.row == 2){
            return 98.0;
        }
        else{
            return 75.0;
        }
    }
    else if ([tableView isEqual:ImageTableView]){
        AutoImageViewHeightFrameModel *frameModel = imageArr[indexPath.row];
        RTLog(@"%f",frameModel.imageViewF.size.height);
        return frameModel.imageViewF.size.height + 10;
    }
    else{
        UITableViewCell *cell = (UITableViewCell *)[tableView viewWithTag:indexPath.row + 1000];
        UILabel *lab = (UILabel *)[cell viewWithTag:indexPath.row + 3000];
        
        return (CGRectGetMaxY(lab.frame) + 20.0) / 667 * IPHONE_H;
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    
    if ([tableView isEqual:xinwenshuaxinTableView]){
        if ([[CommonCode readFromUserD:@"dangqianbofangxinwenID"] isEqualToString:xinwenArr[indexPath.row][@"id"]]){
            
            if (self.isfaxian) {
                self.hidesBottomBarWhenPushed = YES;
                [self.navigationController.navigationBar setHidden:NO];
                [self.navigationController pushViewController:[bofangVC shareInstance ] animated:YES];
                [[bofangVC shareInstance] scrollToTop];
                [[NSNotificationCenter defaultCenter]postNotificationName:@"getAhocComment" object:xinwenArr[indexPath.row][@"id"]];
            }
            else{
                [self.navigationController popViewControllerAnimated:YES];
                [[NSNotificationCenter defaultCenter]postNotificationName:@"getAhocComment" object:xinwenArr[indexPath.row][@"id"]];
            }
            if ([bofangVC shareInstance].isPlay) {
                
            }
            else{
                [[bofangVC shareInstance] doplay2];
            }
        }
        else{
            
            [bofangVC shareInstance].newsModel.jiemuID = xinwenArr[indexPath.row][@"id"];
            [bofangVC shareInstance].newsModel.Titlejiemu = xinwenArr[indexPath.row][@"post_title"];
            [bofangVC shareInstance].newsModel.RiQijiemu = xinwenArr[indexPath.row][@"post_date"];
            [bofangVC shareInstance].newsModel.ImgStrjiemu = xinwenArr[indexPath.row][@"smeta"];
            [bofangVC shareInstance].newsModel.post_lai = xinwenArr[indexPath.row][@"post_lai"];
            [bofangVC shareInstance].newsModel.post_news = self.jiemuID;
            [bofangVC shareInstance].newsModel.jiemuName = self.jiemuName;
            [bofangVC shareInstance].newsModel.jiemuDescription = self.jiemuDescription;
            [bofangVC shareInstance].newsModel.jiemuImages = self.jiemuImages;
            [bofangVC shareInstance].newsModel.jiemuFan_num = self.jiemuFan_num;
            [bofangVC shareInstance].newsModel.jiemuMessage_num = self.jiemuMessage_num;
            [bofangVC shareInstance].newsModel.jiemuIs_fan = self.jiemuIs_fan;
            [bofangVC shareInstance].newsModel.post_mp = xinwenArr[indexPath.row][@"post_mp"];
            [bofangVC shareInstance].newsModel.post_time = xinwenArr[indexPath.row][@"post_time"];
            [bofangVC shareInstance].newsModel.post_keywords = xinwenArr[indexPath.row][@"post_keywords"];
            [bofangVC shareInstance].newsModel.url = xinwenArr[indexPath.row][@"url"];
            [bofangVC shareInstance].yinpinzongTime.text = [[bofangVC shareInstance] convertStringWithTime:[xinwenArr[indexPath.row][@"post_time"] intValue] / 1000];
            ExcurrentNumber = (int)indexPath.row;
            [bofangVC shareInstance].newsModel.ImgStrjiemu = xinwenArr[indexPath.row][@"smeta"];
            [bofangVC shareInstance].newsModel.ZhengWenjiemu = xinwenArr[indexPath.row][@"post_excerpt"];
            [bofangVC shareInstance].newsModel.praisenum = xinwenArr[indexPath.row][@"praisenum"];
            [bofangVC shareInstance].iszhuboxiangqing = YES;
            [[bofangVC shareInstance].tableView reloadData];
            [Explayer replaceCurrentItemWithPlayerItem:[[AVPlayerItem alloc]initWithURL:[NSURL URLWithString:xinwenArr[indexPath.row][@"post_mp"]]]];
            if ([bofangVC shareInstance].isPlay || ExIsKaiShiBoFang == NO) {
                
            }
            else{
                [[bofangVC shareInstance] doplay2];
            }
            ExisRigester = YES;
            ExIsKaiShiBoFang = YES;
            ExwhichBoFangYeMianStr = @"zhuboxiangqingbofang";
            if (self.isfaxian) {
                self.hidesBottomBarWhenPushed = YES;
                [self.navigationController.navigationBar setHidden:NO];
                [self.navigationController pushViewController:[bofangVC shareInstance ] animated:YES];
                [[bofangVC shareInstance] scrollToTop];
                [[NSNotificationCenter defaultCenter]postNotificationName:@"getAhocComment" object:xinwenArr[indexPath.row][@"id"]];
            }
            else{
                [self.navigationController popViewControllerAnimated:YES];
                [[NSNotificationCenter defaultCenter]postNotificationName:@"getAhocComment" object:xinwenArr[indexPath.row][@"id"]];
            }
            [[NSNotificationCenter defaultCenter] postNotificationName:@"yuanpanzhuan" object:nil];
            [[NSNotificationCenter defaultCenter] postNotificationName:@"qiehuanxinwen" object:nil];
            [CommonCode writeToUserD:xinwenArr andKey:@"zhuyeliebiao"];
            [CommonCode writeToUserD:xinwenArr[indexPath.row][@"id"] andKey:@"dangqianbofangxinwenID"];
            if ([[CommonCode readFromUserD:@"yitingguoxinwenID"] isKindOfClass:[NSArray class]])
            {
                NSMutableArray *yitingguoArr = [NSMutableArray arrayWithArray:[CommonCode readFromUserD:@"yitingguoxinwenID"]];
                [yitingguoArr addObject:xinwenArr[indexPath.row][@"id"]];
                [CommonCode writeToUserD:yitingguoArr andKey:@"yitingguoxinwenID"];
            }else
            {
                NSMutableArray *yitingguoArr = [NSMutableArray array];
                [yitingguoArr addObject:xinwenArr[indexPath.row][@"id"]];
                [CommonCode writeToUserD:yitingguoArr andKey:@"yitingguoxinwenID"];
            }
            [tableView reloadData];
        }
    }
    else if ([tableView isEqual:fansWallTableView]){
        NSMutableDictionary *components = self.rewardListArray[indexPath.row];
        gerenzhuyeVC *gerenzhuye = [gerenzhuyeVC new];
        if ([[CommonCode readFromUserD:@"dangqianUserUid"] isEqualToString:components[@"user_id"]] && [[CommonCode readFromUserD:@"isLogin"]boolValue] == YES) {
            gerenzhuye.isMypersonalPage = YES;
        }
        else{
            gerenzhuye.isMypersonalPage = NO;
        }
        gerenzhuye.isNewsComment = YES;
        gerenzhuye.isComefromRewardlist = YES;
        gerenzhuye.user_nicename = components[@"user_nicename"];
        gerenzhuye.avatar = components[@"user_avatar"];
        gerenzhuye.user_id = components[@"user_id"];
        self.hidesBottomBarWhenPushed=YES;
        [self.navigationController pushViewController:gerenzhuye animated:YES];
        self.hidesBottomBarWhenPushed=YES;
        
    }
    else if ([tableView isEqual:pinglunhoushuaxinTableView]){
        //TODO:删除自己的留言 或者回复、复制
        NSDictionary *dic = liuyanArr[indexPath.row];
        if ([ExdangqianUserUid isEqualToString:dic[@"uid"]]) {
            [UIActionSheet actionSheetWithTitle:nil message:nil buttons:@[@"删除", @"复制"] showInView:self.view onDismiss:^(int buttonIndex) {
                if (buttonIndex == 0) {
                    [NetWorkTool delActWithaccessToken:AvatarAccessToken act_id:dic[@"id"] sccess:^(NSDictionary *responseObject) {
                        //刷新留言列表
                        UITableView *fansBoardTableView = (UITableView *)[TwoScrollV viewWithTag:5];
                        [fansBoardTableView.mj_header beginRefreshing];
                        
                    } failure:^(NSError *error) {
                        //
                        NSLog(@"delete error");
                    }];
                }
                else{
                    UIPasteboard *gr                             = [UIPasteboard generalPasteboard];
                    gr.string                                    = [NSString stringWithFormat:@"%@",dic[@"content"]];
                    XWAlerLoginView *xw = [[XWAlerLoginView alloc]initWithTitle:@"分享链接已复制到您的剪切板~~"];
                    [xw show];
                }
            } onCancel:^{
                
            }];
        }
        else{
            
            [UIActionSheet actionSheetWithTitle:nil message:nil buttons:@[@"回复", @"复制"] showInView:self.view onDismiss:^(int buttonIndex) {
                if (buttonIndex == 0) {
                    if ([[CommonCode readFromUserD:@"isLogin"]boolValue] == YES){
                        //TODO:弹起键盘上方带@xxx
                        _isReplyComment = YES;
                        _replyTouid = liuyanArr[indexPath.row][@"uid"];
                        _replyCommentid = liuyanArr[indexPath.row][@"id"];
                        pinglunTextF.placeholder = [NSString stringWithFormat:@"@%@",liuyanArr[indexPath.row][@"full_name"]];
                        [pinglunTextF becomeFirstResponder];
                        
                    }
                    else{
                        [self loginFirst];
                    }
                }
                else{
                    UIPasteboard *gr                             = [UIPasteboard generalPasteboard];
                    gr.string                                    = [NSString stringWithFormat:@"%@",dic[@"content"]];
                    XWAlerLoginView *xw = [[XWAlerLoginView alloc]initWithTitle:@"分享链接已复制到您的剪切板~~"];
                    [xw show];
                }
            } onCancel:^{
                
            }];
        }
    }
}

#pragma mark - UIScrollViewDelegate

//开始滚动就开始监听知道滚动结束
- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    
    [self.view endEditing:YES];
    _isReplyComment = NO;
    pinglunTextF.placeholder = @"输入评论";
    
    if (scrollView.tag == 1){
        if (scrollView.contentOffset.y > 273.0 / 667 * IPHONE_H){
            [scrollView setContentOffset:CGPointMake(0, 273.0 / 667 * IPHONE_H)];
            scrollView.scrollEnabled = NO;
            UITableView *yaodakaiTabV = (UITableView *)[TwoScrollV viewWithTag:lastBtnTag - 7];
            yaodakaiTabV.scrollEnabled = YES;
        }
        else{
            scrollView.scrollEnabled = YES;
            UITableView *yaodakaiTabV = (UITableView *)[TwoScrollV viewWithTag:lastBtnTag - 7];
            yaodakaiTabV.scrollEnabled = NO;
        }
    }
    else if (scrollView.tag == lastBtnTag - 7){
        if (scrollView.contentOffset.y > 0.0){
            
        }
        else{
            scrollView.scrollEnabled = NO;
            ZhuscrollView.scrollEnabled = YES;
        }
    }
    
}
- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
    if (scrollView.tag == lastBtnTag - 7){
        if (scrollView.contentOffset.y > 0.0){
            
        }
        else{
            scrollView.scrollEnabled = NO;
            ZhuscrollView.scrollEnabled = YES;
        }
    }
    else if (scrollView.tag == 2){
        CGPoint point = scrollView.contentOffset;
        NSInteger i = point.x / IPHONE_W;
        zhuboxiangqingBtn *btn = (zhuboxiangqingBtn *)[CenterView viewWithTag:lastBtnTag];
        [btn ChangeBlueToBlack:[UIImage imageNamed:[NSString stringWithFormat:@"BzhuboBtn%ld",(long)lastBtnTag - 9]]];
        zhuboxiangqingBtn *btn1 = (zhuboxiangqingBtn *)[CenterView viewWithTag:i + 10];
        [btn1 ChangeBlackToBlue:[UIImage imageNamed:[NSString stringWithFormat:@"zhuboBtn%ld",(long)i + 1]]];
        lastBtnTag = i + 10;
        if (i + 10 == 11){
            if (self.isbofangye == YES){
                [UIView animateWithDuration:0.3f animations:^{
                    pinglunBgView.frame = CGRectMake(pinglunBgView.frame.origin.x, IPHONE_H - pinglunBgView.frame.size.height, pinglunBgView.frame.size.width, pinglunBgView.frame.size.height);
                }];
            }
            else{
                [UIView animateWithDuration:0.3f animations:^{
                    pinglunBgView.frame = CGRectMake(pinglunBgView.frame.origin.x, IPHONE_H - pinglunBgView.frame.size.height, pinglunBgView.frame.size.width, pinglunBgView.frame.size.height);
                }];
            }
        }
        else if (i + 10 == 10){
            NSLog(@"xinwen");
        }
        else{
            if (self.isbofangye == YES){
                [UIView animateWithDuration:0.3f animations:^{
                    pinglunBgView.frame = CGRectMake(pinglunBgView.frame.origin.x, IPHONE_H, pinglunBgView.frame.size.width, pinglunBgView.frame.size.height);
                }];
            }
            else{
                [UIView animateWithDuration:0.3f animations:^{
                    pinglunBgView.frame = CGRectMake(pinglunBgView.frame.origin.x, IPHONE_H - 64, pinglunBgView.frame.size.width, pinglunBgView.frame.size.height);
                }];
            }
        }
    }
    //限制下拉刷新的调用频率，防止高度适配在调用频率过高的状态下错误
    if(touchCount<1)
    {
        //不是频繁操作执行对应点击事件
        [self.pagingView autoContentOffsetY];
        touchCount++;
        RTLog(@"autoContentOffsetY");
    }
    else
    {
        [self performSelector:@selector(timeSetting) withObject:nil afterDelay:0.5];//4秒后点击次数清零
    }
}
-(void)timeSetting
{
    touchCount=0;
}

#pragma mark - TTTAttributedLabelDelegate

- (void)attributedLabel:(TTTAttributedLabel *)label
didSelectLinkWithTransitInformation:(NSDictionary *)components {
    
    gerenzhuyeVC *gerenzhuye = [gerenzhuyeVC new];
    if ([components[@"user_login"] isEqualToString:ExdangqianUser] && [[CommonCode readFromUserD:@"isLogin"]boolValue] == YES) {
        gerenzhuye.isMypersonalPage = YES;
    }
    else{
        gerenzhuye.isMypersonalPage = NO;
    }
    gerenzhuye.isNewsComment = NO;
    gerenzhuye.user_nicename = components[@"user_nicename"];
    gerenzhuye.sex = components[@"sex"];
    gerenzhuye.signature = components[@"signature"];
    gerenzhuye.user_login = components[@"user_login"];
    gerenzhuye.avatar = components[@"avatar"];
    gerenzhuye.user_id = components[@"id"];
    self.hidesBottomBarWhenPushed=YES;
    [self.navigationController pushViewController:gerenzhuye animated:YES];
    self.hidesBottomBarWhenPushed=YES;
}

- (UILabel *)myRanking{
    if (!_myRanking) {
        _myRanking = [[UILabel alloc]initWithFrame:CGRectMake(15, 10, 150, 20)];
        [_myRanking setFont:gFontMain14];
        [_myRanking setTextColor:gTextDownload];
    }
    return _myRanking;
}
- (UILabel *)tipLabel
{
    if (_tipLabel == nil) {
        _tipLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, 50)];
        _tipLabel.text = @"暂无数据";
        _tipLabel.textAlignment = NSTextAlignmentCenter;
        _tipLabel.font = [UIFont systemFontOfSize:20];
        _tipLabel.textColor = [UIColor lightGrayColor];
    }
    return _tipLabel;
}
//- (UIView *)sectionHeadView
//{
//    if (_sectionHeadView == nil) {
//        _sectionHeadView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, 44)];
//        [_sectionHeadView setBackgroundColor:gSubColor];
//        //TODO:我的排名
//        [_sectionHeadView addSubview:self.myRanking];
//        
//        UIButton *goButton = [UIButton buttonWithType:UIButtonTypeCustom];
//        [goButton setFrame:CGRectMake(SCREEN_WIDTH - 75, 10, 60, 25)];
//        [goButton.titleLabel setFont:gFontSub11];
//        
//        [goButton.layer setBorderWidth:0.5f];
//        [goButton.layer setBorderColor:gThinLineColor.CGColor];
//        [goButton.layer setMasksToBounds:YES];
//        [goButton.layer setCornerRadius:5.0f];
//        [goButton addTarget:self action:@selector(goButtonAction:) forControlEvents:UIControlEventTouchUpInside];
//        //追加赞赏
//        UIButton *rewardButton = [UIButton buttonWithType:UIButtonTypeCustom];
//        [rewardButton setFrame:CGRectMake(SCREEN_WIDTH - 145, 10, 60, 25)];
//        [rewardButton.titleLabel setFont:gFontSub11];
//        
//        [rewardButton.layer setBorderWidth:0.5f];
//        [rewardButton.layer setBorderColor:gThinLineColor.CGColor];
//        [rewardButton.layer setMasksToBounds:YES];
//        [rewardButton.layer setCornerRadius:5.0f];
//        [rewardButton addTarget:self action:@selector(rewardButtonAction:) forControlEvents:UIControlEventTouchUpInside];
//        [rewardButton setBackgroundColor:gButtonRewardColor];
//        [rewardButton setTitle:@"我要赞赏" forState:UIControlStateNormal];
//        [rewardButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
//        [_sectionHeadView addSubview:rewardButton];
//        
//        if (_isOnRank) {
//            [rewardButton setHidden:NO];
//            [goButton setTitleColor:gTextColorBackground forState:UIControlStateNormal];
//            [goButton setTitle:@"立即前往" forState:UIControlStateNormal];
//        }
//        else{
//            [rewardButton setHidden:YES];
//            [goButton setBackgroundColor:gButtonRewardColor];
//            [goButton setTitle:@"我要上榜" forState:UIControlStateNormal];
//            [goButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
//        }
//        [_sectionHeadView addSubview:goButton];
//    }
//    return _sectionHeadView;
//}
- (void)dealloc
{
    RTLog(@"dealloc");
}
@end
