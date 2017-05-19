//
//  NewReportViewController.m
//  kuangjiaTingWen
//
//  Created by Zhimi on 16/9/19.
//  Copyright © 2016年 贺楠. All rights reserved.
//

#import "NewReportViewController.h"
#import "MJRefresh.h"
#import "bofangVC.h"
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
    NSString *imgUrl = [NSString stringWithFormat:@"%@",[self.infoArr[indexPath.row][@"smeta"] stringByReplacingOccurrencesOfString:@"\\" withString:@""]];
    NSString *imgUrl1 = [imgUrl stringByReplacingOccurrencesOfString:@"\"" withString:@""];
    NSString *imgUrl2 = [imgUrl1 stringByReplacingOccurrencesOfString:@"thumb:" withString:@""];
    NSString *imgUrl3 = [imgUrl2 stringByReplacingOccurrencesOfString:@"{" withString:@""];
    NSString *imgUrl4 = [imgUrl3 stringByReplacingOccurrencesOfString:@"}" withString:@""];
    if ([imgUrl4  rangeOfString:@"http"].location != NSNotFound){
        [imgV sd_setImageWithURL:[NSURL URLWithString:imgUrl4] placeholderImage:[UIImage imageNamed:@"thumbnailsdefault"]];
    }else
    {
        NSString *str = USERPHOTOHTTPSTRINGZhuBo(imgUrl4);
        [imgV sd_setImageWithURL:[NSURL URLWithString:str] placeholderImage:[UIImage imageNamed:@"thumbnailsdefault"]];
    }
    imgV.contentMode = UIViewContentModeScaleAspectFill;
    imgV.clipsToBounds = YES;
    
    [cell.contentView addSubview:imgV];
    
    UILabel *titleLab = [[UILabel alloc]initWithFrame:CGRectMake(20.0 / 375 * IPHONE_W, 6.0 / 667 * IPHONE_H , SCREEN_WIDTH - 169.0 / 375 * IPHONE_W, 21.0 / 667 *IPHONE_H)];
    titleLab.text = self.infoArr[indexPath.row][@"post_title"];
    if ([[CommonCode readFromUserD:@"yitingguoxinwenID"] isKindOfClass:[NSArray class]])
    {
        NSArray *yitingguoArr = [NSArray arrayWithArray:[CommonCode readFromUserD:@"yitingguoxinwenID"]];
        for (int i = 0; i < yitingguoArr.count - 1; i ++ )
        {
            if ([self.infoArr[indexPath.row][@"id"] isEqualToString:yitingguoArr[i]])
            {
                if ([[CommonCode readFromUserD:@"dangqianbofangxinwenID"] isEqualToString:self.infoArr[indexPath.row][@"id"]])
                {
                    titleLab.textColor = gMainColor;
                    break;
                }else
                {
                    titleLab.textColor = [[UIColor grayColor]colorWithAlphaComponent:0.7f];
                    break;
                }
            }else
            {
                titleLab.textColor = [UIColor blackColor];
            }
        }
    }
    if ([[CommonCode readFromUserD:@"dangqianbofangxinwenID"] isEqualToString:self.infoArr[indexPath.row][@"id"]])
    {
        titleLab.textColor = gMainColor;
    }
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
    UILabel *dataLab = [[UILabel alloc]initWithFrame:CGRectMake(SCREEN_WIDTH - 227.0 / 375 * IPHONE_W, 86.0 / 667 *IPHONE_H, 45.0 / 375 * IPHONE_W, 21.0 / 667 *IPHONE_H)];
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
    
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    if ([[CommonCode readFromUserD:@"dangqianbofangxinwenID"] isEqualToString:self.infoArr[indexPath.row][@"id"]]){
        
        self.hidesBottomBarWhenPushed = YES;
        [self.navigationController.navigationBar setHidden:YES];
        [self.navigationController pushViewController:[bofangVC shareInstance] animated:YES];
        [[bofangVC shareInstance].tableView reloadData];
        self.hidesBottomBarWhenPushed = NO;
        if ([bofangVC shareInstance].isPlay) {
            
        }
        else{
            [[bofangVC shareInstance] doplay2];
        }
    }
    else{
        [bofangVC shareInstance].newsModel.jiemuID = self.infoArr[indexPath.row][@"id"];
        [bofangVC shareInstance].newsModel.Titlejiemu = self.infoArr[indexPath.row][@"post_title"];
        [bofangVC shareInstance].newsModel.RiQijiemu = self.infoArr[indexPath.row][@"post_date"];
        [bofangVC shareInstance].newsModel.ImgStrjiemu = self.infoArr[indexPath.row][@"smeta"];
        [bofangVC shareInstance].newsModel.post_lai = self.infoArr[indexPath.row][@"post_lai"];
        [bofangVC shareInstance].newsModel.post_news = self.infoArr[indexPath.row][@"post_act"][@"id"];
        [bofangVC shareInstance].newsModel.jiemuName = self.infoArr[indexPath.row][@"post_act"][@"name"];
        [bofangVC shareInstance].newsModel.jiemuDescription = self.infoArr[indexPath.row][@"post_act"][@"description"];
        [bofangVC shareInstance].newsModel.jiemuImages = self.infoArr[indexPath.row][@"post_act"][@"images"];
        [bofangVC shareInstance].newsModel.jiemuFan_num = self.infoArr[indexPath.row][@"post_act"][@"fan_num"];
        [bofangVC shareInstance].newsModel.jiemuMessage_num = self.infoArr[indexPath.row][@"post_act"][@"message_num"];
        [bofangVC shareInstance].newsModel.jiemuIs_fan = self.infoArr[indexPath.row][@"post_act"][@"is_fan"];
        [bofangVC shareInstance].newsModel.post_mp = self.infoArr[indexPath.row][@"post_mp"];
        [bofangVC shareInstance].newsModel.post_time = self.infoArr[indexPath.row][@"post_time"];
        [bofangVC shareInstance].iszhuboxiangqing = NO;
        [bofangVC shareInstance].newsModel.post_keywords = self.infoArr[indexPath.row][@"post_keywords"];
        [bofangVC shareInstance].newsModel.url = self.infoArr[indexPath.row][@"url"];
        if ([self.infoArr[indexPath.row][@"post_time"] intValue] / 1000 / 60)
        {
            if ([self.infoArr[indexPath.row][@"post_time"] intValue] / 1000 / 60 > 9)
            {
                [bofangVC shareInstance].yinpinzongTime.text = [NSString stringWithFormat:@"%d:%d",[self.infoArr[indexPath.row][@"post_time"] intValue] / 1000 / 60,[self.infoArr[indexPath.row][@"post_time"] intValue] / 1000 % 60];
            }
            else{
                if ([self.infoArr[indexPath.row][@"post_time"] intValue] / 1000 % 60 < 10)
                {
                    [bofangVC shareInstance].yinpinzongTime.text = [NSString stringWithFormat:@"0%d:0%d",[self.infoArr[indexPath.row][@"post_time"] intValue] / 1000 / 60,[self.infoArr[indexPath.row][@"post_time"] intValue] / 1000 % 60];
                }else
                {
                    [bofangVC shareInstance].yinpinzongTime.text = [NSString stringWithFormat:@"0%d:%d",[self.infoArr[indexPath.row][@"post_time"] intValue] / 1000 / 60,[self.infoArr[indexPath.row][@"post_time"] intValue] / 1000 % 60];
                }
            }
        }else
        {
            if ([self.infoArr[indexPath.row][@"post_time"] intValue] / 1000 > 10)
            {
                [bofangVC shareInstance].yinpinzongTime.text = [NSString stringWithFormat:@"00:%d",[self.infoArr[indexPath.row][@"post_time"] intValue] / 1000 % 60];
            }else
            {
                [bofangVC shareInstance].yinpinzongTime.text = [NSString stringWithFormat:@"00:0%d",[self.infoArr[indexPath.row][@"post_time"] intValue] / 1000 % 60];
            }
        }
        ExcurrentNumber = (int)indexPath.row;
        NSString *imgUrl = [NSString stringWithFormat:@"%@",[self.infoArr[indexPath.row][@"smeta"] stringByReplacingOccurrencesOfString:@"\\" withString:@""]];
        NSString *imgUrl1 = [imgUrl stringByReplacingOccurrencesOfString:@"\"" withString:@""];
        NSString *imgUrl2 = [imgUrl1 stringByReplacingOccurrencesOfString:@"thumb:" withString:@""];
        NSString *imgUrl3 = [imgUrl2 stringByReplacingOccurrencesOfString:@"{" withString:@""];
        NSString *imgUrl4 = [imgUrl3 stringByReplacingOccurrencesOfString:@"}" withString:@""];
        [bofangVC shareInstance].newsModel.ImgStrjiemu = imgUrl4;
        [bofangVC shareInstance].newsModel.ZhengWenjiemu = self.infoArr[indexPath.row][@"post_excerpt"];
        [bofangVC shareInstance].newsModel.praisenum = self.infoArr[indexPath.row][@"praisenum"];
        [[bofangVC shareInstance].tableView reloadData];

        [Explayer replaceCurrentItemWithPlayerItem:[[AVPlayerItem alloc]initWithURL:[NSURL URLWithString:self.infoArr[indexPath.row][@"post_mp"]]]];
        if ([bofangVC shareInstance].isPlay || ExIsKaiShiBoFang == NO) {
            
        }
        else{
            [[bofangVC shareInstance] doplay2];
        }
        ExisRigester = YES;
        ExIsKaiShiBoFang = YES;
        ExwhichBoFangYeMianStr = @"dingyuebofang";
        self.hidesBottomBarWhenPushed = YES;
        [self.navigationController.navigationBar setHidden:YES];
        [self.navigationController pushViewController:[bofangVC shareInstance] animated:YES];
        [[bofangVC shareInstance].tableView reloadData];
        self.hidesBottomBarWhenPushed = YES;
        [[NSNotificationCenter defaultCenter] postNotificationName:@"yuanpanzhuan" object:nil];
        [[NSNotificationCenter defaultCenter] postNotificationName:@"qiehuanxinwen" object:nil];
        [CommonCode writeToUserD:self.infoArr andKey:@"zhuyeliebiao"];
        [CommonCode writeToUserD:self.infoArr[indexPath.row][@"id"] andKey:@"dangqianbofangxinwenID"];
        if ([[CommonCode readFromUserD:@"yitingguoxinwenID"] isKindOfClass:[NSArray class]])
        {
            NSMutableArray *yitingguoArr = [NSMutableArray arrayWithArray:[CommonCode readFromUserD:@"yitingguoxinwenID"]];
            [yitingguoArr addObject:self.infoArr[indexPath.row][@"id"]];
            [CommonCode writeToUserD:yitingguoArr andKey:@"yitingguoxinwenID"];
        }else
        {
            NSMutableArray *yitingguoArr = [NSMutableArray array];
            [yitingguoArr addObject:self.infoArr[indexPath.row][@"id"]];
            [CommonCode writeToUserD:yitingguoArr andKey:@"yitingguoxinwenID"];
        }
        [tableView reloadData];
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 124.0 / 667 * SCREEN_HEIGHT;
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

- (void)dingyuezidongjiazai:(NSNotification *)notification{
    numberPage ++;
    
    [NetWorkTool getPaoGuoSelfWoDeJieMuWithaccessToken:[DSE encryptUseDES:ExdangqianUser] andPage:[NSString stringWithFormat:@"%d",numberPage] andLimit:@"10" sccess:^(NSDictionary *responseObject) {
        if ([responseObject[@"results"] isKindOfClass:[NSArray class]])
        {
            [self.infoArr addObjectsFromArray:responseObject[@"results"]];
            [CommonCode writeToUserD:self.infoArr andKey:@"zhuyeliebiao"];
            [[NSNotificationCenter defaultCenter] postNotificationName:@"dingyuejiazaichenggong" object:nil];
        }
        [self.tableView reloadData];
        [self.tableView.mj_footer endRefreshing];
    } failure:^(NSError *error) {
        NSLog(@"error = %@",error);
        [self.tableView.mj_footer endRefreshing];
    }];
}

- (void)refreshData
{
    numberPage = 1;
    NSLog(@"下拉刷新");
    
    DefineWeakSelf;
    [NetWorkTool postPaoGuoFenLeiZhuBoBoBaoXinWenWithterm_id:self.term_id andpage:@"1" andlimit:@"10" sccess:^(NSDictionary *responseObject) {
        if ([responseObject[@"results"] isKindOfClass:[NSArray class]]){
            [weakSelf.infoArr removeAllObjects];
            [weakSelf.infoArr addObjectsFromArray:responseObject[@"results"]];
//            [CommonCode writeToUserD:self.infoArr andKey:@"wodejiemu"];
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
    [NetWorkTool postPaoGuoFenLeiZhuBoBoBaoXinWenWithterm_id:self.term_id andpage:[NSString stringWithFormat:@"%d",numberPage] andlimit:@"10" sccess:^(NSDictionary *responseObject) {
        if ([responseObject[@"results"] isKindOfClass:[NSArray class]]){
            [weakSelf.infoArr addObjectsFromArray:responseObject[@"results"]];
        }
        [weakSelf.tableView reloadData];
        [weakSelf.tableView.mj_footer endRefreshing];
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
        _tableView = [[UITableView alloc]initWithFrame:CGRectMake(0, 0, IPHONE_W, IPHONE_H) style:UITableViewStylePlain];
        _tableView.delegate = self;
        _tableView.dataSource = self;
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
