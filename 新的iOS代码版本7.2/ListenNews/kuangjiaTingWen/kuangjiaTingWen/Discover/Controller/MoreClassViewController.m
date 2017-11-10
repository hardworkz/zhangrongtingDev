//
//  MoreClassViewController.m
//  kuangjiaTingWen
//
//  Created by Zhimi on 17/4/21.
//  Copyright © 2017年 zhimi. All rights reserved.
//

#import "MoreClassViewController.h"
#import "ClassViewController.h"

@interface MoreClassViewController ()<UITableViewDelegate,UITableViewDataSource>

@property (strong,nonatomic) UITableView *commentTableView;
@property (strong,nonatomic) NSMutableArray *commentInfoArr;
@property (assign, nonatomic) NSInteger commentIndex;
@property (assign, nonatomic) NSInteger commentPageSize;

@end

@implementation MoreClassViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setUpData];
    [self setUpView];
    
    RegisterNotify(ReloadClassList, @selector(reloadClassList))
}
- (void)reloadClassList
{
    self.commentIndex = 1;
    [self loadData];
}
- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    [self.navigationController.navigationBar setHidden:YES];
}

- (void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
}

- (void)setUpData{
    self.commentIndex = 1;
    self.commentPageSize = 15;
    _commentInfoArr = [NSMutableArray new];
    [self loadData];
}

- (void)setUpView{
    self.automaticallyAdjustsScrollViewInsets = NO;
    self.extendedLayoutIncludesOpaqueBars = NO;
    [self.view setBackgroundColor:[UIColor whiteColor]];
    UIView *topView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, IPHONE_W, 64)];
    [topView setUserInteractionEnabled:YES];
    topView.backgroundColor = [UIColor whiteColor];
    [self.view addSubview:topView];
    UIButton *leftBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    leftBtn.frame = CGRectMake(10, 25, 35, 35);
    [leftBtn setImageEdgeInsets:UIEdgeInsetsMake(5, 0, 5, 10)];
    [leftBtn setImage:[UIImage imageNamed:@"back"] forState:UIControlStateNormal];
    leftBtn.accessibilityLabel = @"返回";
    [leftBtn addTarget:self action:@selector(back) forControlEvents:UIControlEventTouchUpInside];
    [topView addSubview:leftBtn];
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(back)];
    [topView addGestureRecognizer:tap];
    
    UILabel *topLab = [[UILabel alloc]initWithFrame:CGRectMake(50, 30, IPHONE_W - 100, 30)];
    topLab.textColor = [UIColor blackColor];
    topLab.font = [UIFont boldSystemFontOfSize:17.0f];
    topLab.text = @"听闻课堂";
    topLab.backgroundColor = [UIColor clearColor];
    topLab.textAlignment = NSTextAlignmentCenter;
    [topView addSubview:topLab];
    UIView *seperatorLine = [[UIView alloc]initWithFrame:CGRectMake(0, 63.5, SCREEN_WIDTH, 0.5)];
    [seperatorLine setBackgroundColor:[UIColor lightGrayColor]];
    [topView addSubview:seperatorLine];
    [self.view addSubview:self.commentTableView];
    UISwipeGestureRecognizer *rightSwipe = [[UISwipeGestureRecognizer alloc]initWithTarget:self action:@selector(back)];
    [rightSwipe setDirection:UISwipeGestureRecognizerDirectionRight];
    [self.commentTableView addGestureRecognizer:rightSwipe];
    DefineWeakSelf;
    self.commentTableView.mj_header = [MJRefreshNormalHeader headerWithRefreshingBlock:^{
        weakSelf.commentIndex = 1;
        [weakSelf loadData];
    }];
    self.commentTableView.mj_footer = [MJRefreshAutoNormalFooter footerWithRefreshingBlock:^{
        weakSelf.commentIndex ++;
        [weakSelf loadData];
    }];
}
- (UITableView *)commentTableView{
    if (!_commentTableView){
        _commentTableView = [[UITableView alloc]initWithFrame:CGRectMake(0, 64, SCREEN_WIDTH, SCREEN_HEIGHT - 64) style:UITableViewStylePlain];
        _commentTableView.delegate = self;
        _commentTableView.dataSource = self;
        _commentTableView.tableFooterView = [UIView new];
    }
    return _commentTableView;
}

#pragma mark - Utilities
- (void)loadData{
    DefineWeakSelf;
    NSString *accessToken;
    if (ExdangqianUser.length == 0 || ExdangqianUser == nil){
        accessToken = nil;
    }
    else{
        accessToken = [DSE encryptUseDES:ExdangqianUser];
    }
    [NetWorkTool getClassroomListWithaccessToken:AvatarAccessToken andPage:[NSString stringWithFormat:@"%ld",(long)self.commentIndex] andLimit:[NSString stringWithFormat:@"%ld",(long)self.commentPageSize] sccess:^(NSDictionary *responseObject) {
        if ([responseObject[@"results"] isKindOfClass:[NSArray class]]){
            if (weakSelf.commentIndex == 1) {
                [weakSelf.commentInfoArr removeAllObjects];
            }
            NSArray *array = [self frameWithDataArray:[MyClassroomListModel mj_objectArrayWithKeyValuesArray:responseObject[@"results"]]];
            [weakSelf.commentInfoArr addObjectsFromArray:array];
            weakSelf.commentInfoArr = [[NSMutableArray alloc]initWithArray:weakSelf.commentInfoArr];
            [weakSelf.commentTableView reloadData];
            if (array.count < self.commentPageSize) {
                [self.commentTableView.mj_header endRefreshing];
                [self.commentTableView.mj_footer endRefreshingWithNoMoreData];
            }else{
                [weakSelf endRefreshing];
            }
        }
        else{
            [weakSelf endRefreshing];
        }
    } failure:^(NSError *error) {
        [weakSelf endRefreshing];
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

- (void)endRefreshing{
    [self.commentTableView.mj_header endRefreshing];
    [self.commentTableView.mj_footer endRefreshing];
}

- (void)back {
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)SVPDismiss {
    [SVProgressHUD dismiss];
}

#pragma mark - UITableViewDataSource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return [self.commentInfoArr count];;
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    MyClassroomTableViewCell *cell = [MyClassroomTableViewCell cellWithTableView:tableView];
    [cell setSelectionStyle:UITableViewCellSelectionStyleNone];
    cell.hiddenDevider = YES;
    MyClassroomListFrameModel *frameModel = self.commentInfoArr[indexPath.row];
    cell.frameModel = frameModel;
    return cell;
}

#pragma mark - UITableViewDelegate
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    MyClassroomListFrameModel *frameModel = self.commentInfoArr[indexPath.row];
    return frameModel.cellHeight;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    MyClassroomListFrameModel *frameModel = self.commentInfoArr[indexPath.row];
    NSDictionary *userInfoDict = [CommonCode readFromUserD:@"dangqianUserInfo"];
    if ([frameModel.model.is_free isEqualToString:@"1"]||[userInfoDict[results][member_type] intValue] == 2||[[CommonCode readFromUserD:@"isIAP"] boolValue] == YES) {
        zhuboXiangQingVCNewController *faxianzhuboVC = [[zhuboXiangQingVCNewController alloc]init];
        faxianzhuboVC.jiemuDescription = frameModel.model.Description;
        faxianzhuboVC.jiemuFan_num = frameModel.model.fan_num;
        faxianzhuboVC.jiemuID = frameModel.model.ID;
        faxianzhuboVC.jiemuImages = frameModel.model.images;
        faxianzhuboVC.jiemuIs_fan = frameModel.model.is_fan;
        faxianzhuboVC.jiemuMessage_num = frameModel.model.message_num;
        faxianzhuboVC.jiemuName = frameModel.model.name;
        faxianzhuboVC.isfaxian = NO;
        faxianzhuboVC.isClass = YES;
        [self.navigationController pushViewController:faxianzhuboVC animated:YES];
    }
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
@end
