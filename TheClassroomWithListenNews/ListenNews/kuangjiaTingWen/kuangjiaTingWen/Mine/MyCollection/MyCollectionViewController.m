//
//  MyCollectionViewController.m
//  kuangjiaTingWen
//
//  Created by Zhimi on 17/3/9.
//  Copyright © 2017年 贺楠. All rights reserved.
//

#import "MyCollectionViewController.h"
#import "NSDate+TimeFormat.h"
#import "bofangVC.h"
#import "ProjiectDownLoadManager.h"
#import "WHC_Download.h"

@interface MyCollectionViewController ()<UITableViewDelegate,UITableViewDataSource>

@property (nonatomic, strong) UITableView *helpTableView;
@property (nonatomic, strong) NSMutableArray *dataSourceArr;

@property (nonatomic, strong) UILabel *label;

@end

@implementation MyCollectionViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setUpData];
    [self setUpView];
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(gaibianyanse:) name:@"gaibianyanse" object:nil];
}
- (void)gaibianyanse:(NSNotification *)notification
{
    [self.helpTableView reloadData];
}
- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    self.hidesBottomBarWhenPushed = YES;
    [self.navigationController setNavigationBarHidden:YES animated:YES];
}

- (void)setUpData{
    
    [NetWorkTool get_collectionWithaccessToken:AvatarAccessToken sccess:^(NSDictionary *responseObject) {
        if ([responseObject[@"results"] isKindOfClass:[NSArray class]]) {
            self.dataSourceArr = [responseObject[@"results"] mutableCopy];
            //替换id为当前新闻ID
            for (int i = 0; i<self.dataSourceArr.count; i++) {
                NSDictionary *dict = self.dataSourceArr[i];
                [dict setValue:dict[@"post_id"] forKey:@"id"];
            }
            [self.helpTableView reloadData];
        }else{
            if (self.dataSourceArr.count == 0) {
                [[BJNoDataView shareNoDataView] showCenterWithSuperView:self.helpTableView icon:nil iconClicked:^{
                    //图片点击回调
                    [self setUpData];//刷新数据
                }];
            }else{
                //有数据
                [[BJNoDataView shareNoDataView] clear];
            }
        }

    } failure:^(NSError *error) {
        //
    }];
}

- (void)setUpView{
    
    [self setTitle:@"我的收藏"];
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
    topLab.text = @"我的收藏";
    topLab.backgroundColor = [UIColor clearColor];
    topLab.textAlignment = NSTextAlignmentCenter;
    [topView addSubview:topLab];
    UIView *seperatorLine = [[UIView alloc]initWithFrame:CGRectMake(0, 63.5, SCREEN_WIDTH, 0.5)];
    [seperatorLine setBackgroundColor:[UIColor lightGrayColor]];
    [topView addSubview:seperatorLine];
    
    [self.view addSubview:self.helpTableView];
    
    UISwipeGestureRecognizer *rightSwipe = [[UISwipeGestureRecognizer alloc]initWithTarget:self action:@selector(back)];
    [rightSwipe setDirection:UISwipeGestureRecognizerDirectionRight];
    [self.helpTableView addGestureRecognizer:rightSwipe];
}

- (void)back {
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)deletePostNewsWithIndexPath:(NSIndexPath *)indexPath{
    
    [NetWorkTool del_collectionWithaccessToken:AvatarAccessToken post_id:self.dataSourceArr[indexPath.row][@"post_id"] sccess:^(NSDictionary *responseObject) {
        [self.dataSourceArr removeObjectAtIndex:indexPath.row];
        // 之后更新view
        [self.helpTableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
    } failure:^(NSError *error) {
        //
    }];
}

- (void)downloadNewsAction:(UIButton *)sender {
    
    [SVProgressHUD showInfoWithStatus:@"开始下载"];
    [self performSelector:@selector(SVPDismiss) withObject:nil afterDelay:1.0];
    NSMutableDictionary *dic = self.dataSourceArr[sender.tag - 100];
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


#pragma mark - UITableViewDelegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    //设置频道类型
    [ZRT_PlayerManager manager].channelType = ChannelTypeMineCollection;
    //设置播放器播放内容类型
    [ZRT_PlayerManager manager].playType = ZRTPlayTypeNews;
    DefineWeakSelf;
    //播放内容切换后刷新对应的播放列表
    [ZRT_PlayerManager manager].playReloadList = ^(NSInteger currentSongIndex) {
        [weakSelf.helpTableView reloadData];
    };
    //设置播放界面打赏view的状态
    [NewPlayVC shareInstance].rewardType = RewardViewTypeNone;
    //判断是否是点击当前正在播放的新闻，如果是则直接跳转
    if ([[CommonCode readFromUserD:@"dangqianbofangxinwenID"] isEqualToString:self.dataSourceArr[indexPath.row][@"post_id"]]){
        
        //设置播放器播放数组
        [ZRT_PlayerManager manager].songList = self.dataSourceArr;
        [[NewPlayVC shareInstance] reloadInterface];
        [self.navigationController.navigationBar setHidden:YES];
        [self.navigationController pushViewController:[NewPlayVC shareInstance] animated:YES];
    }
    else{
        
        //设置播放器播放数组
        [ZRT_PlayerManager manager].songList = self.dataSourceArr;
        //设置新闻ID
        [NewPlayVC shareInstance].post_id = self.dataSourceArr[indexPath.row][@"post_id"];
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

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath{
    
    [self deletePostNewsWithIndexPath:indexPath];
}

#pragma mark - UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return  [self.dataSourceArr count];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 120.0 / 667 * SCREEN_HEIGHT;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    static NSString *wotouxiangcellIdentify = @"Identify";
    UITableViewCell *cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:wotouxiangcellIdentify];
    if (!cell){
        
        cell = [tableView dequeueReusableCellWithIdentifier:wotouxiangcellIdentify];
    }
    
    //图片
    UIImageView *imgLeft = [[UIImageView alloc]initWithFrame:CGRectMake(SCREEN_WIDTH - 125.0 / 375 * IPHONE_W, 19, 105.0 / 375 * IPHONE_W,   84.72 / 375 *IPHONE_W)];
    if (IS_IPAD) {
        [imgLeft setFrame:CGRectMake(SCREEN_WIDTH - 125.0 / 375 * IPHONE_W, 19, 105.0 / 375 * IPHONE_W, 70.0 / 375 *IPHONE_W)];
    }
    
    if ([NEWSSEMTPHOTOURL(self.dataSourceArr[indexPath.row][@"smeta"])  rangeOfString:@"http"].location != NSNotFound){
        [imgLeft sd_setImageWithURL:[NSURL URLWithString:NEWSSEMTPHOTOURL(self.dataSourceArr[indexPath.row][@"smeta"])]];
        //placeholderImage:[UIImage imageNamed:@"thumbnailsdefault"]
    }
    else{
        NSString *str = USERPHOTOHTTPSTRINGZhuBo(NEWSSEMTPHOTOURL(self.dataSourceArr[indexPath.row][@"smeta"]));
        [imgLeft sd_setImageWithURL:[NSURL URLWithString:str]];
        //placeholderImage:[UIImage imageNamed:@"thumbnailsdefault"]
    }
    [cell.contentView addSubview:imgLeft];
    imgLeft.contentMode = UIViewContentModeScaleAspectFill;
    imgLeft.clipsToBounds = YES;
    
    //标题
    UILabel *titleLab = [[UILabel alloc]initWithFrame:CGRectMake(20.0 / 375 * IPHONE_W, 16.0 / 667 * IPHONE_H,  SCREEN_WIDTH - 155.0 / 375 * IPHONE_W, 21.0 / 667 *IPHONE_H)];
    titleLab.text = self.dataSourceArr[indexPath.row][@"post_title"];
    titleLab.textColor = [[ZRT_PlayerManager manager] textColorFormID:self.dataSourceArr[indexPath.row][@"post_id"]];
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
        detailNews.text = self.dataSourceArr[indexPath.row][@"post_excerpt"];
        detailNews.textColor = gTextColorSub;
        detailNews.font = [UIFont systemFontOfSize:15.0f];
        [cell.contentView addSubview:detailNews];
    }
    
    //日期
    UILabel *riqiLab = [[UILabel alloc]initWithFrame:CGRectMake(20.0 / 375 * IPHONE_W, 86.0 / 667 *IPHONE_H, 135.0 / 375 * IPHONE_W, 21.0 / 667 *IPHONE_H)];
    NSDate *date = [NSDate dateFromString:self.dataSourceArr[indexPath.row][@"post_modified"]];
    riqiLab.text = [date showTimeByTypeA];
    riqiLab.textColor = nSubColor;
    riqiLab.font = [UIFont systemFontOfSize:13.0f];
    [cell.contentView addSubview:riqiLab];
    //大小
    UILabel *dataLab = [[UILabel alloc]initWithFrame:CGRectMake(SCREEN_WIDTH - 213.0 / 375 * IPHONE_W, 86.0 / 667 *IPHONE_H, 45.0 / 375 * IPHONE_W, 21.0 / 667 *IPHONE_H)];
    dataLab.text = [NSString stringWithFormat:@"%.1lf%@",[self.dataSourceArr[indexPath.row][@"post_size"] intValue] / 1024.0 / 1024.0,@"M"];
    dataLab.textColor = nSubColor;
    dataLab.font = [UIFont systemFontOfSize:13.0f];
    dataLab.textAlignment = NSTextAlignmentCenter;
    [cell.contentView addSubview:dataLab];
    //下载
    UIButton *download = [UIButton buttonWithType:UIButtonTypeCustom];
    [download setFrame:CGRectMake(CGRectGetMaxX(dataLab.frame), 86.0 / 667 *IPHONE_H, 30.0 / 667 *IPHONE_H, 30.0 / 667 *IPHONE_H)];
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

- (UITableView *)helpTableView{
    if (_helpTableView == nil) {
        _helpTableView = [[UITableView alloc]initWithFrame:CGRectMake(0, 64, SCREEN_WIDTH, SCREEN_HEIGHT - 64) style:UITableViewStylePlain];
        [_helpTableView setDelegate:self];
        [_helpTableView setDataSource:self];
        [_helpTableView setSeparatorStyle:UITableViewCellSeparatorStyleNone];
    }
    return _helpTableView;
}

- (NSMutableArray *)dataSourceArr{
    if (!_dataSourceArr) {
        _dataSourceArr = [NSMutableArray array];
    }
    return _dataSourceArr;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
