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
            [self.helpTableView reloadData];
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
    if ([[CommonCode readFromUserD:@"dangqianbofangxinwenID"] isEqualToString:self.dataSourceArr[indexPath.row][@"post_id"]]){
        self.hidesBottomBarWhenPushed = YES;
        [self.navigationController.navigationBar setHidden:YES];
        [self.navigationController pushViewController:[bofangVC shareInstance] animated:YES];
        [[bofangVC shareInstance].tableView reloadData];
        self.hidesBottomBarWhenPushed = YES;
        if ([bofangVC shareInstance].isPlay) {
            
        }
        else{
            [[bofangVC shareInstance] doplay2];
        }
    }
    else{
        [bofangVC shareInstance].newsModel.jiemuID = self.dataSourceArr[indexPath.row][@"post_id"];
        [bofangVC shareInstance].newsModel.Titlejiemu = self.dataSourceArr[indexPath.row][@"post_title"];
        [bofangVC shareInstance].newsModel.RiQijiemu = self.dataSourceArr[indexPath.row][@"post_date"];
        [bofangVC shareInstance].newsModel.ImgStrjiemu = self.dataSourceArr[indexPath.row][@"smeta"];
        [bofangVC shareInstance].newsModel.post_lai = self.dataSourceArr[indexPath.row][@"post_lai"];
        [bofangVC shareInstance].newsModel.post_news = self.dataSourceArr[indexPath.row][@"post_act"][@"id"];
        [bofangVC shareInstance].newsModel.jiemuName = self.dataSourceArr[indexPath.row][@"post_act"][@"name"];
        [bofangVC shareInstance].newsModel.jiemuDescription = self.dataSourceArr[indexPath.row][@"post_act"][@"description"];
        [bofangVC shareInstance].newsModel.jiemuImages = self.dataSourceArr[indexPath.row][@"post_act"][@"images"];
        [bofangVC shareInstance].newsModel.jiemuFan_num = self.dataSourceArr[indexPath.row][@"post_act"][@"fan_num"];
        [bofangVC shareInstance].newsModel.jiemuMessage_num = self.dataSourceArr[indexPath.row][@"post_act"][@"message_num"];
        [bofangVC shareInstance].newsModel.jiemuIs_fan = self.dataSourceArr[indexPath.row][@"post_act"][@"is_fan"];
        [bofangVC shareInstance].newsModel.post_mp = self.dataSourceArr[indexPath.row][@"post_mp"];
        [bofangVC shareInstance].newsModel.post_time = self.dataSourceArr[indexPath.row][@"post_time"];
        [bofangVC shareInstance].iszhuboxiangqing = NO;
        [bofangVC shareInstance].newsModel.post_keywords = self.dataSourceArr[indexPath.row][@"post_keywords"];
        [bofangVC shareInstance].newsModel.url = self.dataSourceArr[indexPath.row][@"url"];
        [bofangVC shareInstance].yinpinzongTime.text = [[bofangVC shareInstance] convertStringWithTime:[self.dataSourceArr[indexPath.row][@"post_time"] intValue] / 1000];
        
        ExcurrentNumber = (int)indexPath.row;
        [bofangVC shareInstance].newsModel.ImgStrjiemu = self.dataSourceArr[indexPath.row][@"smeta"];
        [bofangVC shareInstance].newsModel.ZhengWenjiemu = self.dataSourceArr[indexPath.row][@"post_excerpt"];
        [bofangVC shareInstance].newsModel.praisenum = self.dataSourceArr[indexPath.row][@"praisenum"];
        [[bofangVC shareInstance].tableView reloadData];
        [Explayer replaceCurrentItemWithPlayerItem:[[AVPlayerItem alloc]initWithURL:[NSURL URLWithString:self.dataSourceArr[indexPath.row][@"post_mp"]]]];
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
        [self.navigationController pushViewController:[bofangVC shareInstance] animated:YES];
        [[bofangVC shareInstance].tableView reloadData];
        //        [self.navigationController.navigationBar setHidden:NO];
        self.hidesBottomBarWhenPushed = YES;
        [[NSNotificationCenter defaultCenter] postNotificationName:@"yuanpanzhuan" object:nil];
        [[NSNotificationCenter defaultCenter] postNotificationName:@"qiehuanxinwen" object:nil];
        [CommonCode writeToUserD:self.dataSourceArr andKey:@"zhuyeliebiao"];
        [CommonCode writeToUserD:self.dataSourceArr[indexPath.row][@"post_id"] andKey:@"dangqianbofangxinwenID"];
        if ([[CommonCode readFromUserD:@"yitingguoxinwenID"] isKindOfClass:[NSArray class]]){
            NSMutableArray *yitingguoArr = [NSMutableArray arrayWithArray:[CommonCode readFromUserD:@"yitingguoxinwenID"]];
            [yitingguoArr addObject:self.dataSourceArr[indexPath.row][@"post_id"]];
            [CommonCode writeToUserD:yitingguoArr andKey:@"yitingguoxinwenID"];
        }
        else{
            NSMutableArray *yitingguoArr = [NSMutableArray array];
            [yitingguoArr addObject:self.dataSourceArr[indexPath.row][@"post_id"]];
            [CommonCode writeToUserD:yitingguoArr andKey:@"yitingguoxinwenID"];
        }
        [tableView reloadData];
    }

}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath{
    
    [self deletePostNewsWithIndexPath:indexPath];
}

#pragma mark - UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
//    if (! [self.dataSourceArr count]) {
//        if (!_label) {
//            _label = [[UILabel alloc]initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, 20)];
//            _label.textAlignment = NSTextAlignmentCenter;
//            _label.text = @"暂无数据";
//            _label.textColor = [UIColor lightGrayColor];
//            _label.center = self.helpTableView.center;
//            [self.helpTableView addSubview:_label];
//        }else {
//            [self.helpTableView addSubview:_label];
//        }
//    }
//    else{
//        [_label removeFromSuperview];
//    }
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
    titleLab.textColor = [UIColor blackColor];
    if ([[CommonCode readFromUserD:@"yitingguoxinwenID"] isKindOfClass:[NSArray class]]){
        NSArray *yitingguoArr = [NSArray arrayWithArray:[CommonCode readFromUserD:@"yitingguoxinwenID"]];
        for (int i = 0; i < yitingguoArr.count - 1; i ++ ){
            if ([self.dataSourceArr[indexPath.row][@"post_id"] isEqualToString:yitingguoArr[i]]){
                if ([[CommonCode readFromUserD:@"dangqianbofangxinwenID"] isEqualToString:self.dataSourceArr[indexPath.row][@"post_id"]]){
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
    if ([[CommonCode readFromUserD:@"dangqianbofangxinwenID"] isEqualToString:self.dataSourceArr[indexPath.row][@"post_id"]]){
        titleLab.textColor = gMainColor;
    }
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

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
