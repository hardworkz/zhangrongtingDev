//
//  HomePageViewController.m
//  kuangjiaTingWen
//
//  Created by Zhimi on 17/3/20.
//  Copyright © 2017年 zhimi. All rights reserved.
//

#import "HomePageViewController.h"
#import "HMSegmentedControl.h"
#import "TBCircleScrollView.h"
#import "NSDate+TimeFormat.h"
#import "ProjiectDownLoadManager.h"
#import "WHC_Download.h"
#import "AppDelegate.h"
#import "guanggaoVC.h"
#import "NewReportViewController.h"
#import "ClassViewController.h"

@interface HomePageViewController ()<UIScrollViewDelegate,UITableViewDelegate,UITableViewDataSource>

@property (strong,nonatomic) UIScrollView *scrollView;
@property (strong,nonatomic) HMSegmentedControl *segmentedControl;
@property (strong,nonatomic) UITableView *columnTableView;
@property (strong,nonatomic) UITableView *newsTableView;
@property (strong,nonatomic) UITableView *classroomTableView;
@property (strong,nonatomic) NSMutableArray *columnInfoArr;
@property (strong,nonatomic) NSMutableArray *newsInfoArr;
@property (strong,nonatomic) NSMutableArray *classroomInfoArr;
@property (assign, nonatomic) NSInteger columnIndex;
@property (assign, nonatomic) NSInteger columnPageSize;
@property (assign, nonatomic) NSInteger newsIndex;
@property (assign, nonatomic) NSInteger newsPageSize;
@property (assign, nonatomic) NSInteger classIndex;
@property (assign, nonatomic) NSInteger classPageSize;
@property (strong, nonatomic) NSMutableArray *slideADResult;
@property (strong, nonatomic) NSMutableArray *ztADResult;
@property (strong, nonatomic) NSMutableDictionary *pushNewsInfo;
@property (strong, nonatomic) UIView *lineView;
@property (assign, nonatomic) NSInteger playListIndex;
@end

@implementation HomePageViewController
/**
 系统公告方法
 */
//- (void)getSystemNotice
//{
//    RTLog(@"getSystemNotice");
//    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(3.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
//        UIAlertController *qingshuruyonghuming = [UIAlertController alertControllerWithTitle:@"公告" message:@"请前往App Store升级最新版本" preferredStyle:UIAlertControllerStyleAlert];
//        [qingshuruyonghuming addAction:[UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
//            
//        }]];
//        [qingshuruyonghuming addAction:[UIAlertAction actionWithTitle:@"前往App Store" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
//            [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"https://itunes.apple.com/cn/app/id1160650661?mt=8"]];
//            
//        }]];
//        [self presentViewController:qingshuruyonghuming animated:YES completion:nil];
//    });
//}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.playListIndex = 1;
    //这里是启动app时广告
    RegisterNotify(@"getStartAD", @selector(getStartAD))
//    [self getStartAD];
    [self setUpData];
    [self setUpView];
    
    //系统消息提醒
//    [self getSystemNotice];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self.navigationController setNavigationBarHidden:NO animated:YES];
    [self.navigationController.navigationBar setTranslucent:YES];
    
    [self.newsTableView reloadData];
    [self.columnTableView reloadData];
}

- (void)setUpData
{
    self.columnIndex = 1;
    self.columnPageSize = 15;
    self.newsIndex = 1;
    self.newsPageSize = 15;
    self.classIndex = 1;
    self.classPageSize = 15;
    _columnInfoArr = [NSMutableArray new];
    _newsInfoArr = [NSMutableArray new];
    _classroomInfoArr = [NSMutableArray new];
    _slideADResult = [NSMutableArray new];
    _ztADResult = [NSMutableArray new];
    _pushNewsInfo = [NSMutableDictionary new];
    [self loadColumnDataWithAutoLoading:NO];
    [self loadNewsDataWithAutoLoading:NO];
    [self loadClassData];
    //获取频道列表 - 下载时有用到
    [NetWorkTool getPaoGuoFenLeiLieBiaoWithWhateverSomething:@"q" sccess:^(NSDictionary *responseObject) {
        if ([responseObject[@"results"] isKindOfClass:[NSArray class]]){
            NSMutableArray *commonListArr = [NSMutableArray arrayWithArray:responseObject[@"results"]];
            [CommonCode writeToUserD:commonListArr andKey:@"commonListArr"];
        }
    } failure:^(NSError *error) {
        NSLog(@"error = %@",error);
    }];
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(reloadClassList) name:ReloadClassList object:nil];
    RegisterNotify(ReloadHomeSelectPageData, @selector(reloadSelectedList))
    RegisterNotify(@"loginSccess", @selector(reloadClassList))
    RegisterNotify(@"tuichuLoginSeccess", @selector(reloadClassList))
}

- (void)setUpView{
    [self CustomNavigationBar];
    [self.scrollView addSubview:self.columnTableView];
    [self.scrollView addSubview:self.newsTableView];
    [self.scrollView addSubview:self.classroomTableView];
    [self.view addSubview:self.segmentedControl];
    [self.view addSubview:self.scrollView];
    DefineWeakSelf;
    [self.segmentedControl setIndexChangeBlock:^(NSInteger index) {
        [weakSelf.scrollView scrollRectToVisible:CGRectMake(SCREEN_WIDTH * index, 0, SCREEN_WIDTH, SCREEN_HEIGHT - 104 - 49) animated:YES];
    }];
    [self.segmentedControl setSelectedSegmentIndex:1 animated:YES];
    self.columnTableView.mj_header = [MJRefreshNormalHeader headerWithRefreshingBlock:^{
        weakSelf.columnIndex = 1;
        [self loadColumnDataWithAutoLoading:NO];
    }];
    self.columnTableView.mj_footer = [MJRefreshAutoNormalFooter footerWithRefreshingBlock:^{
        weakSelf.columnIndex ++;
        [self loadColumnDataWithAutoLoading:NO];
    }];
    self.newsTableView.mj_header = [MJRefreshNormalHeader headerWithRefreshingBlock:^{
        weakSelf.newsIndex = 1;
        [self loadNewsDataWithAutoLoading:NO];
    }];
    self.newsTableView.mj_footer = [MJRefreshAutoNormalFooter footerWithRefreshingBlock:^{
        weakSelf.newsIndex ++;
        [self loadNewsDataWithAutoLoading:NO];
    }];
    self.classroomTableView.mj_header = [MJRefreshNormalHeader headerWithRefreshingBlock:^{
        weakSelf.classIndex = 1;
        [weakSelf loadClassData];
    }];
    self.classroomTableView.mj_footer = [MJRefreshAutoNormalFooter footerWithRefreshingBlock:^{
        weakSelf.classIndex ++;
        [weakSelf loadClassData];
    }];
}

#pragma mark - setter
- (UIScrollView *)scrollView{
    if (!_scrollView) {
        _scrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0,IS_IPHONEX? 128:104, SCREEN_WIDTH, SCREEN_HEIGHT - 104 - 49)];
        _scrollView.backgroundColor = [UIColor whiteColor];
        _scrollView.pagingEnabled = YES;
        _scrollView.showsHorizontalScrollIndicator = NO;
        _scrollView.contentSize = CGSizeMake(SCREEN_WIDTH * 3, SCREEN_HEIGHT - 104 - 49);
        _scrollView.delegate = self;
        [_scrollView scrollRectToVisible:CGRectMake(SCREEN_WIDTH, 0, SCREEN_WIDTH, SCREEN_HEIGHT - 104 - 49) animated:NO];
    }
    return _scrollView;
}

- (HMSegmentedControl *)segmentedControl{
    if (!_segmentedControl) {
        _segmentedControl = [[HMSegmentedControl alloc] initWithSectionTitles: @[@"专栏", @"快讯",@"课堂"]];
        _segmentedControl.autoresizingMask = UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleWidth;
        _segmentedControl.frame = CGRectMake(0,IS_IPHONEX?88:64, SCREEN_WIDTH, 40);
        _segmentedControl.backgroundColor = [UIColor whiteColor];
        _segmentedControl.segmentEdgeInset = UIEdgeInsetsMake(0, 30, 0, 30);
        _segmentedControl.selectionStyle = HMSegmentedControlSelectionStyleTextWidthStripe;
        _segmentedControl.selectionIndicatorLocation =   HMSegmentedControlSelectionIndicatorLocationDown;
        _segmentedControl.selectedSegmentIndex = 1;
        _segmentedControl.verticalDividerEnabled = YES;
        _segmentedControl.verticalDividerColor = [UIColor whiteColor];
        _segmentedControl.selectionIndicatorColor = gTextColorSub;
        _segmentedControl.selectionIndicatorBoxColor = [UIColor whiteColor];
        _segmentedControl.selectionIndicatorHeight = 5.0;
        _segmentedControl.shouldAnimateUserSelection = YES;
        _segmentedControl.verticalDividerWidth = 1.0f;
        [_segmentedControl setTitleFormatter:^NSAttributedString *(HMSegmentedControl *segmentedControl, NSString *title, NSUInteger index, BOOL selected) {
            if (selected) {
                NSAttributedString *attString = [[NSAttributedString alloc] initWithString:title attributes:@{NSForegroundColorAttributeName :gTextDownload,NSFontAttributeName : [UIFont boldSystemFontOfSize:16]}];
                return attString;
            }
            else{
                NSAttributedString *attString = [[NSAttributedString alloc] initWithString:title attributes:@{NSForegroundColorAttributeName :gTextColorSub,NSFontAttributeName : [UIFont boldSystemFontOfSize:16]}];
                return attString;
            }
        }];
        [_segmentedControl addTarget:self action:@selector(segmentedControlChangedValue:) forControlEvents:UIControlEventValueChanged];
        
        UIView *downLine = [[UIView alloc]initWithFrame:CGRectMake(15.0 / 375 * IPHONE_W, _segmentedControl.frame.size.height - 1, SCREEN_WIDTH - 30.0 / 375 * IPHONE_W, 0.8)];
        [downLine setBackgroundColor:[UIColor colorWithHue:0.00 saturation:0.00 brightness:0.85 alpha:1.00]];
        [_segmentedControl addSubview:downLine];
    }
    return _segmentedControl;
}

- (UITableView *)columnTableView{
    if (!_columnTableView){
        _columnTableView = [[UITableView alloc]initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, self.scrollView.frame.size.height) style:UITableViewStylePlain];
        [_columnTableView setSeparatorStyle:UITableViewCellSeparatorStyleNone];
        _columnTableView.delegate = self;
        _columnTableView.dataSource = self;
        _columnTableView.tableFooterView = [UIView new];
    }
    return _columnTableView;
}

- (UITableView *)newsTableView{
    if (!_newsTableView){
        _newsTableView = [[UITableView alloc]initWithFrame:CGRectMake(SCREEN_WIDTH, 0, SCREEN_WIDTH, self.scrollView.frame.size.height) style:UITableViewStylePlain];
        [_newsTableView setSeparatorStyle:UITableViewCellSeparatorStyleNone];
        _newsTableView.delegate = self;
        _newsTableView.dataSource = self;
        _newsTableView.tableFooterView = [UIView new];
    }
    return _newsTableView;
}

- (UITableView *)classroomTableView{
    if (!_classroomTableView){
        _classroomTableView = [[UITableView alloc]initWithFrame:CGRectMake(SCREEN_WIDTH * 2, 0, SCREEN_WIDTH, self.scrollView.frame.size.height) style:UITableViewStylePlain];
        [_classroomTableView setSeparatorStyle:UITableViewCellSeparatorStyleNone];
        _classroomTableView.delegate = self;
        _classroomTableView.dataSource = self;
        _classroomTableView.tableFooterView = [UIView new];
    }
    return _classroomTableView;
}

#pragma mark - Utiliteis
- (void)loadNewsDataWithAutoLoading:(BOOL)isAuto{
    if (self.newsIndex == 1) {
        [self getAD];
    }
    DefineWeakSelf;
    [NetWorkTool getInformationListWithaccessToken:AvatarAccessToken andPage:[NSString stringWithFormat:@"%ld",(long)self.newsIndex] andLimit:[NSString stringWithFormat:@"%ld",(long)self.newsPageSize] sccess:^(NSDictionary *responseObject) {
        if ([responseObject[@"results"] isKindOfClass:[NSArray class]]){
            if (weakSelf.newsIndex == 1) {
                [weakSelf.newsInfoArr removeAllObjects];
            }
            else{
                NSRange range = {NSNotFound, NSNotFound};
                for (int i = 0 ; i < [weakSelf.newsInfoArr count]; i ++) {
                    if ([weakSelf.newsInfoArr[i][@"id"] isEqualToString:[responseObject[@"results"] firstObject][@"id"] ]) {
                        range = NSMakeRange(i, [weakSelf.newsInfoArr count] - i);
                        break;
                    }
                }
                if (range.location < [weakSelf.newsInfoArr count]) {
                    [weakSelf.newsInfoArr removeObjectsInRange:range];
                }
            }
            [weakSelf.newsInfoArr addObjectsFromArray:responseObject[@"results"]];
            weakSelf.newsInfoArr = [[NSMutableArray alloc]initWithArray:weakSelf.newsInfoArr];
            if ([ZRT_PlayerManager manager].channelType == ChannelTypeHomeChannelOne) {
                [ZRT_PlayerManager manager].songList = weakSelf.newsInfoArr;
            }
            [weakSelf.newsTableView reloadData];
            [weakSelf endNewsRefreshing];
        }
        else{
            [weakSelf endNewsRefreshing];
        }
    } failure:^(NSError *error) {
        [weakSelf endNewsRefreshing];
    }];
}

- (void)loadColumnDataWithAutoLoading:(BOOL)isAuto
{
    DefineWeakSelf;
    [NetWorkTool getColumnListWithaccessToken:AvatarAccessToken andPage:[NSString stringWithFormat:@"%ld",(long)self.columnIndex] andLimit:[NSString stringWithFormat:@"%ld",(long)self.columnPageSize] sccess:^(NSDictionary *responseObject) {
        if ([responseObject[@"results"] isKindOfClass:[NSArray class]]){
            if (weakSelf.columnIndex == 1) {
                [weakSelf.columnInfoArr removeAllObjects];
            }
            else{
                NSRange range = {NSNotFound, NSNotFound};
                for (int i = 0 ; i < [weakSelf.columnInfoArr count]; i ++) {
                    if ([weakSelf.columnInfoArr[i][@"id"] isEqualToString:[responseObject[@"results"] firstObject][@"id"] ]) {
                        range = NSMakeRange(i, [weakSelf.columnInfoArr count] - i);
                        break;
                    }
                }
                if (range.location < [weakSelf.columnInfoArr count]) {
                    [weakSelf.columnInfoArr removeObjectsInRange:range];
                }
            }
            [weakSelf.columnInfoArr addObjectsFromArray:responseObject[@"results"]];
            weakSelf.columnInfoArr = [[NSMutableArray alloc]initWithArray:weakSelf.columnInfoArr];
            if ([ZRT_PlayerManager manager].channelType == ChannelTypeHomeChannelTwo) {
                [ZRT_PlayerManager manager].songList = weakSelf.newsInfoArr;
            }
            [weakSelf.columnTableView reloadData];
            [weakSelf endColumnRefreshing];
        }
        else{
            [weakSelf endColumnRefreshing];
        }
    } failure:^(NSError *error) {
        [weakSelf endColumnRefreshing];
    }];
}

- (void)loadClassData{
    NSString *accessToken;
    if (ExdangqianUser.length == 0 || ExdangqianUser == nil){
        accessToken = nil;
    }
    else{
        accessToken = [DSE encryptUseDES:ExdangqianUser];
    }
    DefineWeakSelf;
    //[DSE encryptUseDES:@"tw1499171698533660"]
    [NetWorkTool getClassroomListWithaccessToken:AvatarAccessToken andPage:[NSString stringWithFormat:@"%ld",(long)self.classIndex] andLimit:[NSString stringWithFormat:@"%ld",(long)self.classPageSize] sccess:^(NSDictionary *responseObject) {
        if ([responseObject[@"results"] isKindOfClass:[NSArray class]]){
            if (weakSelf.classIndex == 1) {
                [weakSelf.classroomInfoArr removeAllObjects];
            }
            NSMutableArray *classArray = [self frameWithDataArray:[MyClassroomListModel mj_objectArrayWithKeyValuesArray:responseObject[@"results"]]];
            [weakSelf.classroomInfoArr addObjectsFromArray:classArray];
            weakSelf.classroomInfoArr = [[NSMutableArray alloc]initWithArray:weakSelf.classroomInfoArr];
            [weakSelf.classroomTableView reloadData];
            if (classArray.count < self.classPageSize) {
                [weakSelf.classroomTableView.mj_footer endRefreshingWithNoMoreData];
                [weakSelf.classroomTableView.mj_header endRefreshing];
            }else{
                [weakSelf endClassroomRefreshing];
            }
        }
        else{
            [weakSelf endClassroomRefreshing];
        }
    } failure:^(NSError *error) {
        [weakSelf endClassroomRefreshing];
    }];
    
}
/**
 返回frameArray
 
 @param modeArray 数据模型数组
 @return frame数据模型数组
 */
- (NSMutableArray *)frameWithDataArray:(NSMutableArray *)modeArray
{
    NSMutableArray *array = [NSMutableArray array];
    for (MyClassroomListModel *model in modeArray) {
        MyClassroomListFrameModel *frameModel = [[MyClassroomListFrameModel alloc] init];
        frameModel.model = model;
        [array addObject:frameModel];
    }
    return array;
}
- (void)CustomNavigationBar{
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
}

- (void)segmentedControlChangedValue:(HMSegmentedControl *)segmentedControl {
    NSLog(@"Selected index %ld (via UIControlEventValueChanged)", (long)segmentedControl.selectedSegmentIndex);
    [self.lineView setFrame:CGRectMake(segmentedControl.selectedSegmentIndex * (SCREEN_WIDTH )/3 + 30, self.segmentedControl.frame.size.height - 5, (SCREEN_WIDTH)/6, 5)];
}

- (void)endColumnRefreshing{
    [self.columnTableView.mj_header endRefreshing];
    [self.columnTableView.mj_footer endRefreshing];
}

- (void)endNewsRefreshing{
    [self.newsTableView.mj_header endRefreshing];
    [self.newsTableView.mj_footer endRefreshing];
}

- (void)endClassroomRefreshing{
    [self.classroomTableView.mj_header endRefreshing];
    [self.classroomTableView.mj_footer endRefreshing];
}

- (void)SVPDismiss {
    [SVProgressHUD dismiss];
}

- (void)getStartAD{
    //获取开屏广告数据，判断屏幕尺寸
    NSDictionary *responseObject = [CommonCode readFromUserD:@"StartAD_Data"];
    if ([responseObject[@"results"] isKindOfClass:[NSArray class]] && responseObject != nil){
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
        }else if (TARGETED_DEVICE_IS_IPHONE_812 &&  [responseObject[@"results"][10][@"status"] isEqualToString:@"1"]){
            [self openLaunchAD];
        }
    }
}

- (void)openLaunchAD{
    guanggaoVC *guangao = [guanggaoVC new];
    [self.navigationController pushViewController:guangao animated:NO];
    //清空开屏广告本地数据
    [CommonCode writeToUserD:nil andKey:@"StartAD_Data"];   
}

- (void)newsItemAction:(UIButton *)sender{
    NSString *term_id;
    NSString *newsType;
    if (sender.tag  == 500) {
        term_id = @"6";
        newsType = @"财经";
    }
    else if (sender.tag == 501){
        term_id = @"4";
        newsType = @"文娱";
    }
    else if (sender.tag == 502){
        term_id = @"8";
        newsType = @"国际";
    }
    else if (sender.tag == 503){
        term_id = @"7";
        newsType = @"科技";
    }
    else if (sender.tag == 504){
        term_id = @"14";
        newsType = @"时政";
    }
    NewReportViewController *newreportVC = [[NewReportViewController alloc]init];
    newreportVC.term_id = term_id;
    newreportVC.NewsTpye = newsType;
    newreportVC.view.backgroundColor = [UIColor whiteColor];
    [self.navigationController pushViewController:newreportVC animated:YES];
}

#pragma mark - NSNotificationAction
- (void)gaibianyanse:(NSNotification *)notification{
    if (self.segmentedControl.selectedSegmentIndex == 0) {
        [self.columnTableView reloadData];
    }
    else if (self.segmentedControl.selectedSegmentIndex == 1){
        [self.newsTableView reloadData];
    }
}

- (void)zidongjiazai:(NSNotification *)notification{
    DefineWeakSelf;
    if (self.segmentedControl.selectedSegmentIndex == 0) {
        weakSelf.columnIndex ++;
        [weakSelf loadColumnDataWithAutoLoading:YES];
    }
    else if (self.segmentedControl.selectedSegmentIndex == 1){
        weakSelf.newsIndex ++;
        [weakSelf loadNewsDataWithAutoLoading:YES];
    }
}
//刷新课堂列表
- (void)reloadClassList
{
    self.classIndex = 1;
    [self loadClassData];
    [self getAD];
}

/**
 重复点击刷新首页对应列表
 */
- (void)reloadSelectedList
{
    if (self.segmentedControl.selectedSegmentIndex == 0) {
        [self.columnTableView.mj_header beginRefreshing];
    }else if (self.segmentedControl.selectedSegmentIndex == 1){
        [self.newsTableView.mj_header beginRefreshing];
    }else{
        [self.classroomTableView.mj_header beginRefreshing];
    }
}

#pragma mark -UIScrollViewDelegate
- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
    CGFloat pageWidth = self.scrollView.frame.size.width;
    NSInteger page = self.scrollView.contentOffset.x / pageWidth;
    [self.segmentedControl setSelectedSegmentIndex:page animated:YES];
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView{
}

#pragma mark - UITableViewDataSource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    NSInteger numberOfRows = 0;
    if (tableView == self.columnTableView) {
        numberOfRows = [self.columnInfoArr count];
    }
    else if (tableView == self.newsTableView){
        numberOfRows = [self.newsInfoArr count];
    }
    else if (tableView == self.classroomTableView){
        numberOfRows = [self.classroomInfoArr count];
    }
    return numberOfRows;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    if (tableView == self.columnTableView){
        NewsCell *cell = [NewsCell cellWithTableView:tableView];
        if ([self.columnInfoArr count]) {
            cell.dataDict = self.columnInfoArr[indexPath.row];
        }
        return cell;
    }
    else if (tableView == self.newsTableView){
        static NSString *NewsCellIdentify = @"NewsCellIdentify";
        UITableViewCell *cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:NewsCellIdentify];
        if (!cell){
            cell = [tableView dequeueReusableCellWithIdentifier:NewsCellIdentify];
        }
        CGFloat offsetY = 0;
        if (indexPath.row == 0) {
            offsetY = 30;
            //新闻频道
            CGFloat newsItem_width = (SCREEN_WIDTH - 10.0 / 375 * IPHONE_W)/5;
            NSArray *newsItemTitle = @[@"财经",@"文娱",@"国际",@"科技",@"时政"];
            for (int i = 0 ; i < 5; i ++) {
                UIButton *newsItem = [UIButton buttonWithType:UIButtonTypeCustom];
                [newsItem setFrame:CGRectMake(newsItem_width * i + 5.0 / 375 * IPHONE_W + 5.0, 5, newsItem_width - 5,IS_IPAD?40:25)];
                [newsItem.layer setMasksToBounds:YES];
                [newsItem.layer setCornerRadius:IS_IPAD?20:12.5];
                [newsItem.layer setBorderWidth:0.5];
                [newsItem.layer setBorderColor:TITLE_COLOR_HEX.CGColor];
                [newsItem setTitle:newsItemTitle[i] forState:UIControlStateNormal];
                [newsItem setTitleColor:TITLE_COLOR_HEX forState:UIControlStateNormal];
                [newsItem.titleLabel setFont:CUSTOM_FONT_TYPE(14.0)];
                [newsItem setTag:(500+ i)];
                [newsItem addTarget:self action:@selector(newsItemAction:) forControlEvents:UIControlEventTouchUpInside];
                [cell.contentView addSubview:newsItem];
            }
            return cell;
        }
        else{
            NewsCell *cell = [NewsCell cellWithTableView:tableView];
            if ([self.newsInfoArr count]) {
                cell.dataDict = self.newsInfoArr[indexPath.row];
            }
            return cell;
        }
    }
    else{
        MyClassroomTableViewCell *cell = [MyClassroomTableViewCell cellWithTableView:tableView];
        [cell setSelectionStyle:UITableViewCellSelectionStyleNone];
        cell.hiddenDevider = YES;
        MyClassroomListFrameModel *frameModel = self.classroomInfoArr[indexPath.row];
        cell.frameModel = frameModel;
        return cell;
    }
}

#pragma mark - UITableViewDelegate
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    CGFloat heightForRow = 44.0;
    if (tableView == self.columnTableView) {
        heightForRow = IS_IPHONEX?120.0: 120.0 / 667 * IPHONE_H;
    }
    else if (tableView == self.newsTableView){
        if (indexPath.row == 0) {
            heightForRow = 30.0;
        }
        else{
            heightForRow = IS_IPHONEX?120.0:120.0 / 667 * IPHONE_H;
        }
    }
    else if (tableView == self.classroomTableView){
        MyClassroomListFrameModel *frameModel = self.classroomInfoArr[indexPath.row];
        heightForRow = frameModel.cellHeight;
    }
    return heightForRow;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    if (tableView == self.columnTableView || tableView == self.newsTableView) {
        
        if (self.segmentedControl.selectedSegmentIndex != 2) {
            self.playListIndex = self.segmentedControl.selectedSegmentIndex;
        }
        
        NSArray *arr;
        if (self.segmentedControl.selectedSegmentIndex == 0) {
            arr = self.columnInfoArr;
            [ZRT_PlayerManager manager].channelType = ChannelTypeHomeChannelTwo;
        }
        else if (self.segmentedControl.selectedSegmentIndex == 1){
            arr = self.newsInfoArr;
            [ZRT_PlayerManager manager].channelType = ChannelTypeHomeChannelOne;
        }
        //设置播放器播放内容类型
        [ZRT_PlayerManager manager].playType = ZRTPlayTypeNews;
        //设置播放器播放完成自动加载更多block
        DefineWeakSelf;
        [ZRT_PlayerManager manager].loadMoreList = ^(NSInteger currentSongIndex) {
            if (weakSelf.playListIndex == 0) {
                weakSelf.columnIndex ++;
                [weakSelf loadColumnDataWithAutoLoading:YES];
            }
            else if (weakSelf.playListIndex == 1){
                weakSelf.newsIndex ++;
                [weakSelf loadNewsDataWithAutoLoading:YES];
            }
        };
        //播放内容切换后刷新对应的播放列表
        [ZRT_PlayerManager manager].playReloadList = ^(NSInteger currentSongIndex) {
            if (weakSelf.playListIndex == 0) {
                [weakSelf.columnTableView reloadData];
            }
            else if (weakSelf.playListIndex == 1){
                [weakSelf.newsTableView reloadData];
            }
        };
        //设置播放界面打赏view的状态
        [NewPlayVC shareInstance].rewardType = RewardViewTypeNone;
        //判断是否是点击当前正在播放的新闻，如果是则直接跳转
        if ([[CommonCode readFromUserD:@"dangqianbofangxinwenID"] isEqualToString:arr[indexPath.row][@"id"]]){
            
            //设置播放器播放数组
            [ZRT_PlayerManager manager].songList = arr;
//            [[NewPlayVC shareInstance] reloadInterface];
            [self.navigationController.navigationBar setHidden:YES];
            [self.navigationController pushViewController:[NewPlayVC shareInstance] animated:YES];
        }
        else{
            
            //设置播放器播放数组
            [ZRT_PlayerManager manager].songList = arr;
            //设置新闻ID
            [NewPlayVC shareInstance].post_id = arr[indexPath.row][@"id"];
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
    else if (tableView == self.classroomTableView){
        NSDictionary *userInfoDict = [CommonCode readFromUserD:@"dangqianUserInfo"];
        //跳转已购买课堂界面，超级会员可直接跳转课堂已购买界面
        MyClassroomListFrameModel *frameModel = self.classroomInfoArr[indexPath.row];
        if ([frameModel.model.is_free isEqualToString:@"1"]||[userInfoDict[results][member_type] intValue] == 2||[[CommonCode readFromUserD:@"isIAP"] boolValue] == YES) {
            zhuboXiangQingVCNewController *faxianzhuboVC = [[zhuboXiangQingVCNewController alloc]init];
            faxianzhuboVC.jiemuDescription = frameModel.model.Description;
            faxianzhuboVC.jiemuFan_num = frameModel.model.fan_num;
            faxianzhuboVC.jiemuID = frameModel.model.ID;
            faxianzhuboVC.jiemuImages = frameModel.model.images;
            faxianzhuboVC.jiemuIs_fan = frameModel.model.is_fan;
            faxianzhuboVC.jiemuMessage_num = frameModel.model.message_num;
            faxianzhuboVC.jiemuName = frameModel.model.name;
            faxianzhuboVC.isfaxian = YES;
            faxianzhuboVC.isClass = YES;
            [self.navigationController pushViewController:faxianzhuboVC animated:YES];
        }
        //跳转未购买课堂界面
        else if ([frameModel.model.is_free isEqualToString:@"0"]){
            ClassViewController *vc = [ClassViewController shareInstance];
            vc.jiemuDescription = frameModel.model.Description;
            vc.jiemuFan_num = frameModel.model.fan_num;
            vc.jiemuID = frameModel.model.ID;
            vc.jiemuImages = frameModel.model.images;
            vc.jiemuIs_fan = frameModel.model.is_fan;
            vc.jiemuMessage_num = frameModel.model.message_num;
            vc.jiemuName = frameModel.model.name;
            vc.act_id = frameModel.model.ID;
            vc.listVC = self;
            [self.navigationController.navigationBar setHidden:YES];
            [self.navigationController pushViewController:vc animated:YES];
        }
    }
}
- (void)getAD{
    //获取轮播图数据
//    [self.ztADResult removeAllObjects];
    [NetWorkTool getNewSlideListWithaccessToken:ExdangqianUser?[DSE encryptUseDES:ExdangqianUser]:@"" sccess:^(NSDictionary *responseObject) {
//        RTLog(@"%@",responseObject);
        if ([responseObject[@"results"] isKindOfClass:[NSArray class]]){
            
            self.slideADResult = responseObject[@"results"];
            [self setupTBCView];
        }
        else{
            self.slideADResult = [NSMutableArray array];
            [self setupTBCView];
        }
        [self.newsTableView reloadData];
    } failure:^(NSError *error) {
        NSLog(@"%@",error);
    }];
}
- (void)setupTBCView{
    if (self.slideADResult.count != 0) {
        TBCircleScrollView *tbScView = [[TBCircleScrollView alloc] initWithFrame:CGRectMake(15.0 / 375 * IPHONE_W, 0, IPHONE_W - 30.0 / 375 * IPHONE_W, 162.0 / 667 * SCREEN_HEIGHT) andArr:self.slideADResult];
        tbScView.scrollView.scrollsToTop = NO;
        tbScView.biaozhiStr = @"头条";
        NSMutableArray *imgArr = [[NSMutableArray alloc]init];
        for (int i = 0; i <self.slideADResult.count; i++ ){
            [imgArr addObject:NEWSSEMTPHOTOURL(self.slideADResult[i][@"picture"])];
        }
        tbScView.ztADCount = [imgArr count];
        tbScView.imageArray = [NSArray arrayWithArray:imgArr];
        self.newsTableView.tableHeaderView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, 162.0 / 667 * SCREEN_HEIGHT)];
        [self.newsTableView.tableHeaderView addSubview:tbScView];
        [self.newsTableView reloadData];
    }else{
        self.newsTableView.tableHeaderView = [[UIView alloc] init];
        [self.newsTableView.tableHeaderView removeFromSuperview];
        [self.newsTableView reloadData];
    }
}
@end
