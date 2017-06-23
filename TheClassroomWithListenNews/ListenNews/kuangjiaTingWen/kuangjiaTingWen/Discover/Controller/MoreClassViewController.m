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
        //        [_commentTableView setSeparatorStyle:UITableViewCellSeparatorStyleNone];
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
    [NetWorkTool getClassroomListWithaccessToken:accessToken andPage:[NSString stringWithFormat:@"%ld",(long)self.commentIndex] andLimit:[NSString stringWithFormat:@"%ld",(long)self.commentPageSize] sccess:^(NSDictionary *responseObject) {
        if ([responseObject[@"results"] isKindOfClass:[NSArray class]]){
            if (weakSelf.commentIndex == 1) {
                [weakSelf.commentInfoArr removeAllObjects];
            }
            else{
                NSRange range = {NSNotFound, NSNotFound};
                for (int i = 0 ; i < [weakSelf.commentInfoArr count]; i ++) {
                    if ([weakSelf.commentInfoArr[i][@"id"] isEqualToString:[responseObject[@"results"] firstObject][@"id"] ]) {
                        range = NSMakeRange(i, [weakSelf.commentInfoArr count] - i);
                        break;
                    }
                }
                if (range.location < [weakSelf.commentInfoArr count]) {
                    [weakSelf.commentInfoArr removeObjectsInRange:range];
                }
            }
            [weakSelf.commentInfoArr addObjectsFromArray:responseObject[@"results"]];
            weakSelf.commentInfoArr = [[NSMutableArray alloc]initWithArray:weakSelf.commentInfoArr];
            // [CommonCode writeToUserD:weakSelf.classroomInfoArr andKey:@"zhuyeliebiao"];
            [weakSelf.commentTableView reloadData];
            [weakSelf endRefreshing];
        }
        else{
            [weakSelf endRefreshing];
        }
    } failure:^(NSError *error) {
        [weakSelf endRefreshing];
    }];
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

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    static NSString *NewsCellIdentify = @"ClassCellIdentify";
    UITableViewCell *cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:NewsCellIdentify];
    if (!cell){
        cell = [tableView dequeueReusableCellWithIdentifier:NewsCellIdentify];
    }
    if ([self.commentInfoArr count]) {
        //图片
        UIImageView *imgLeft = [[UIImageView alloc]initWithFrame:CGRectMake(20.0 / 375 * IPHONE_W, 7.5, 105.0 / 375 * IPHONE_W, 105.0 / 375 *IPHONE_W)];
        if (IS_IPAD) {
            [imgLeft setFrame:CGRectMake(20.0 / 375 * IPHONE_W, 7.5, 105.0 / 375 * IPHONE_W, 70.0 / 375 *IPHONE_W)];
        }
        [imgLeft.layer setMasksToBounds:YES];
        [imgLeft.layer setCornerRadius:5.0];
        if ([NEWSSEMTPHOTOURL(self.commentInfoArr[indexPath.row][@"images"])  rangeOfString:@"http"].location != NSNotFound){
            [imgLeft sd_setImageWithURL:[NSURL URLWithString:NEWSSEMTPHOTOURL(self.commentInfoArr[indexPath.row][@"images"])]];
            //placeholderImage:[UIImage imageNamed:@"thumbnailsdefault"]
        }
        else{
            NSString *str = USERPOTOAD(NEWSSEMTPHOTOURL(self.commentInfoArr[indexPath.row][@"images"]));
            [imgLeft sd_setImageWithURL:[NSURL URLWithString:str]];
            //placeholderImage:[UIImage imageNamed:@"thumbnailsdefault"]
        }
        
        [cell.contentView addSubview:imgLeft];
        imgLeft.contentMode = UIViewContentModeScaleAspectFill;
        imgLeft.clipsToBounds = YES;
        
        //标题
        UILabel *titleLab = [[UILabel alloc]initWithFrame:CGRectMake(CGRectGetMaxX(imgLeft.frame) + 5.0 / 375 * IPHONE_W, imgLeft.frame.origin.y,  SCREEN_WIDTH - CGRectGetMaxX(imgLeft.frame) - 70.0 / 375 * IPHONE_W, 21.0 / 667 *IPHONE_H)];
        titleLab.text = self.commentInfoArr[indexPath.row][@"name"];
        titleLab.textColor = [UIColor blackColor];
        titleLab.textAlignment = NSTextAlignmentLeft;
        titleLab.font = [UIFont boldSystemFontOfSize:16.0f ];
        [cell.contentView addSubview:titleLab];
        [titleLab setNumberOfLines:3];
        titleLab.lineBreakMode = NSLineBreakByWordWrapping;
        CGSize size = [titleLab sizeThatFits:CGSizeMake(titleLab.frame.size.width, MAXFLOAT)];
        titleLab.frame = CGRectMake(titleLab.frame.origin.x, titleLab.frame.origin.y, titleLab.frame.size.width, size.height);
        //价钱
        UILabel *price = [[UILabel alloc]initWithFrame:CGRectMake(SCREEN_WIDTH - 20 - 40.0 / 375 * IPHONE_W, titleLab.frame.origin.y,40.0 / 375 * IPHONE_W, 21.0 / 667 *IPHONE_H)];
        price.text = [NSString stringWithFormat:@"¥%@",[NetWorkTool formatFloat:[self.commentInfoArr[indexPath.row][@"price"] floatValue]]];
        price.font = gFontMain14;
        price.textAlignment = NSTextAlignmentRight;
        price.textColor = gMainColor;
        [cell.contentView addSubview:price];
        
        //简介
        UILabel *describe = [[UILabel alloc]initWithFrame:CGRectMake(titleLab.frame.origin.x, 60.0 * 667.0/SCREEN_HEIGHT,  SCREEN_WIDTH - CGRectGetMaxX(imgLeft.frame) - 20.0 / 375 * IPHONE_W, 21.0 / 667 *IPHONE_H)];
        if (TARGETED_DEVICE_IS_IPHONE_568){
            [describe setFrame:CGRectMake(titleLab.frame.origin.x, CGRectGetMaxY(titleLab.frame), SCREEN_WIDTH - CGRectGetMaxX(imgLeft.frame) - 20.0 / 375 * IPHONE_W, 21.0 / 667 *IPHONE_H)];
        }
        else{
            [describe setFrame:CGRectMake(titleLab.frame.origin.x, 60.0 * 667.0/SCREEN_HEIGHT, SCREEN_WIDTH - CGRectGetMaxX(imgLeft.frame) - 20.0 / 375 * IPHONE_W, 21.0 / 667 *IPHONE_H)];
        }
        describe.text = self.commentInfoArr[indexPath.row][@"description"];
        describe.textColor = [[UIColor grayColor]colorWithAlphaComponent:0.7f];
        describe.textColor = gTextColorSub;
        describe.textAlignment = NSTextAlignmentLeft;
        describe.font = gFontMain14;
        [cell.contentView addSubview:describe];
        [describe setNumberOfLines:3];
        describe.lineBreakMode = NSLineBreakByWordWrapping;
        CGSize size1 = [describe sizeThatFits:CGSizeMake(describe.frame.size.width, MAXFLOAT)];
        describe.frame = CGRectMake(describe.frame.origin.x, describe.frame.origin.y, describe.frame.size.width, size1.height);
        UIView *line = [[UIView alloc]initWithFrame:CGRectMake(20.0 / 375 * SCREEN_WIDTH, CGRectGetMaxY(imgLeft.frame) + 7, SCREEN_WIDTH - 40.0 / 375 * SCREEN_WIDTH, 0.5)];
        [line setBackgroundColor:nMineNameColor];
        [cell.contentView addSubview:line];
    }
    
    [cell setSelectionStyle:UITableViewCellSelectionStyleNone];
    return cell;
}

#pragma mark - UITableViewDelegate
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 120.0 / 667 * IPHONE_H;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    if ([self.commentInfoArr[indexPath.row][@"is_free"] isEqualToString:@"1"]) {
        XWAlerLoginView *xw = [[XWAlerLoginView alloc]initWithTitle:@"已购买界面正在开发中"];
        [xw show];
    }
    else if ([self.commentInfoArr[indexPath.row][@"is_free"] isEqualToString:@"0"]){
        ClassViewController *vc = [ClassViewController shareInstance];
        vc.act_id = self.commentInfoArr[indexPath.row][@"id"];
        self.hidesBottomBarWhenPushed = YES;
        [self.navigationController.navigationBar setHidden:YES];
        [self.navigationController pushViewController:vc animated:YES];
        self.hidesBottomBarWhenPushed = YES;
    }
}


@end
