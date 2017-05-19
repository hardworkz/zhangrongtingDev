//
//  RewardListViewController.m
//  kuangjiaTingWen
//
//  Created by Zhimi on 17/1/3.
//  Copyright © 2017年 贺楠. All rights reserved.
//

#import "RewardListViewController.h"
#import "RewardListTableViewCell.h"
#import "gerenzhuyeVC.h"

@interface RewardListViewController ()<UITableViewDelegate,UITableViewDataSource>

@property (strong, nonatomic) UITableView *rewardListTableview;
@property (strong, nonatomic) NSMutableArray *rewardListArray;

@property (strong, nonatomic)UILabel *myRanking;

@property (assign, nonatomic) NSInteger myRank;
@property (assign, nonatomic) BOOL isOnRank;


@end

@implementation RewardListViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self setupData];
    [self setupView];
}


- (void)setupData{
    
    NSString *accesstoken = nil;
    _myRank = 0;
    _isOnRank = NO;
    if ([[CommonCode readFromUserD:@"isLogin"]boolValue] == YES){
        accesstoken = AvatarAccessToken;
    }
    else{
        accesstoken = nil;
    }
//    [NetWorkTool getAwardListWithaccessToken:accesstoken post_id:self.post_id act_id:self.act_id sccess:^(NSDictionary *responseObject) {
//        _myRank = [responseObject[@"results"][@"rank"] integerValue];
//        if (_myRank == 0 ) {
//            [self.myRanking setText:[NSString stringWithFormat:@"我的排名：暂无排名"]];
//            _isOnRank = NO;
//        }
//        else{
//            [self.myRanking setText:[NSString stringWithFormat:@"我的排名：%ld",(long)_myRank]];
//            _isOnRank = YES;
//        }
//        if ([responseObject[@"results"][@"list"] isKindOfClass:[NSArray class]]) {
//            self.rewardListArray = responseObject[@"results"][@"list"];
//        }
//        else{
//            self.rewardListArray = [NSMutableArray array];
//        }
//        [self.rewardListTableview reloadData];
//    } failure:^(NSError *error) {
//        //
//    }];
    
    [NetWorkTool getZan_boardWithaccessToken:accesstoken act_id:self.act_id sccess:^(NSDictionary *responseObject) {
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
        [self.rewardListTableview reloadData];
    } failure:^(NSError *error) {
        //
    }];
    
}

- (void)setupView{
    self.title = @"赏谢榜";
    //    [self enableAutoBack];
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
    topLab.text = @"赏谢榜";
    topLab.backgroundColor = [UIColor clearColor];
    topLab.textAlignment = NSTextAlignmentCenter;
    [topView addSubview:topLab];
    UIView *seperatorLine = [[UIView alloc]initWithFrame:CGRectMake(0, 63.5, SCREEN_WIDTH, 0.5)];
    [seperatorLine setBackgroundColor:[UIColor lightGrayColor]];
    [topView addSubview:seperatorLine];
    [self.view addSubview:self.rewardListTableview];
    self.rewardListTableview.separatorStyle = UITableViewCellSeparatorStyleNone;
    
    UISwipeGestureRecognizer *rightSwipe = [[UISwipeGestureRecognizer alloc]initWithTarget:self action:@selector(back)];
    [rightSwipe setDirection:UISwipeGestureRecognizerDirectionRight];
    [self.rewardListTableview addGestureRecognizer:rightSwipe];
    
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(back) name:@"isBackfromPersonalPage" object:nil];
    
}

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    [self.navigationController setNavigationBarHidden:YES animated:YES];
}

#pragma mark - Getter

- (UITableView *)rewardListTableview {
    if (!_rewardListTableview) {
        _rewardListTableview = [[UITableView alloc]initWithFrame:CGRectMake(0, 64, SCREEN_WIDTH, SCREEN_HEIGHT - 64) style:UITableViewStylePlain];
        [_rewardListTableview setDelegate:self];
        [_rewardListTableview setDataSource:self];
        _rewardListTableview.tableFooterView =  [UIView new];
    }
    return  _rewardListTableview;
}

- (UILabel *)myRanking{
    if (!_myRanking) {
        _myRanking = [[UILabel alloc]initWithFrame:CGRectMake(15, 15, 150, 20)];
        [_myRanking setFont:gFontMain14];
        [_myRanking setTextColor:gTextDownload];
//        [_myRanking setText:[NSString stringWithFormat:@"我的排名：暂无排名"]];
    }
    return _myRanking;
}

#pragma mark - Utilities
- (void)back {
    
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)goButtonAction:(UIButton *)sender {
    if (_isOnRank) {
        NSIndexPath *index = [NSIndexPath indexPathForRow:_myRank - 1 inSection:0];
        [self.rewardListTableview scrollToRowAtIndexPath:index atScrollPosition:UITableViewScrollPositionTop animated:YES];
    }
    else{
        [[NSNotificationCenter defaultCenter] postNotificationName:@"RewardBack" object:nil];
        [self back];
    }
}

- (void)rewardButtonAction:(UIButton *)sender{
    [[NSNotificationCenter defaultCenter] postNotificationName:@"RewardBack" object:nil];
    [self back];
}

#pragma mark -UITableViewDelegate
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.row == 0 || indexPath.row == 1 || indexPath.row == 2){
        return 98.0;
    }
    else{
        return 75.0;
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return 44.0f;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
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

- (nullable UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section{
    UIView *sectionHeadView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, 44)];
    [sectionHeadView setBackgroundColor:gSubColor];
    //TODO:我的排名
    [sectionHeadView addSubview:self.myRanking];
    
    UIButton *goButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [goButton setFrame:CGRectMake(SCREEN_WIDTH - 75, 10, 60, 25)];
    [goButton.titleLabel setFont:gFontSub11];
    
    [goButton.layer setBorderWidth:0.5f];
    [goButton.layer setBorderColor:gThinLineColor.CGColor];
    [goButton.layer setMasksToBounds:YES];
    [goButton.layer setCornerRadius:5.0f];
    [goButton addTarget:self action:@selector(goButtonAction:) forControlEvents:UIControlEventTouchUpInside];
    
    //追加赞赏
    UIButton *rewardButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [rewardButton setFrame:CGRectMake(SCREEN_WIDTH - 145, 10, 60, 25)];
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

#pragma mark - UITableViewDataSource
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return [self.rewardListArray count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    static NSString *identify = @"reWardCell";
    RewardListTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:identify];
    if (cell == nil) {
        cell = [[RewardListTableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identify];
    }
    [cell updateCellValueWithDict:self.rewardListArray[indexPath.row] andIndexPathOfRow:indexPath.row];
    [cell setSelectionStyle:UITableViewCellSelectionStyleNone];
    
    return cell;
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
