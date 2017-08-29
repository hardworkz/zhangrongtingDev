//
//  lunboxiangqingVC.m
//  kuangjiaTingWen
//
//  Created by 贺楠 on 16/6/27.
//  Copyright © 2016年 贺楠. All rights reserved.
//

#import "lunboxiangqingVC.h"
#import "UIImageView+WebCache.h"
#import "bofangVC.h"
#import "NSDate+TimeFormat.h"
#import "AppDelegate.h"
#import "ProjiectDownLoadManager.h"
#import "WHC_Download.h"

@interface lunboxiangqingVC () <UITableViewDataSource,UITableViewDelegate>
{
    NSIndexPath *quanjvIndexPath;
}
@property(strong,nonatomic)UITableView *tableView;
@end

@implementation lunboxiangqingVC

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.navigationController.navigationBarHidden=NO;
    
    self.edgesForExtendedLayout = UIRectEdgeNone;
    self.view.backgroundColor = [UIColor whiteColor];
    self.title = @"新闻播报";
    self.navigationController.navigationBar.titleTextAttributes = @{NSForegroundColorAttributeName: [UIColor blackColor],
                                                                    NSFontAttributeName : [UIFont boldSystemFontOfSize:18]};
    UIButton *leftBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [leftBtn setBackgroundImage:[UIImage imageNamed:@"title_ic_back"] forState:UIControlStateNormal];
    leftBtn.bounds = CGRectMake(0, 0, 9, 15);
    leftBtn.accessibilityLabel = @"返回";
    UIBarButtonItem *back = [[UIBarButtonItem alloc]initWithCustomView:leftBtn];
    [leftBtn addTarget:self action:@selector(back) forControlEvents:UIControlEventTouchUpInside];
    self.navigationItem.leftBarButtonItem = back;
    
    [self jianliUI];
    [self.view addSubview:self.tableView];
}

#pragma mark - Utilities
- (void)jianliUI
{
    UIImageView *topImgV = [[UIImageView alloc]initWithFrame:CGRectMake(0, 0, IPHONE_W, 206.25 / 667 * IPHONE_H)];
    [topImgV sd_setImageWithURL:[NSURL URLWithString:NEWSSEMTPHOTOURL(self.infoArr[0][@"smeta"])] placeholderImage:[UIImage imageNamed:@"thumbnailsdefault"]];
    
    UIView *dibuLabView = [[UIView alloc]initWithFrame:CGRectMake(0, topImgV.frame.size.height - 30.0 / 667 * IPHONE_H, IPHONE_W, 30.0 / 667 * IPHONE_H)];
    dibuLabView.backgroundColor = [[UIColor blackColor]colorWithAlphaComponent:0.5f];
    [topImgV addSubview:dibuLabView];
    
    UILabel *dibuLab = [[UILabel alloc]initWithFrame:CGRectMake(3.0 / 375 * IPHONE_W, 0, IPHONE_W - 50.0 / 375 * IPHONE_W, 30.0 / 667 * IPHONE_H)];
    dibuLab.textColor = [UIColor whiteColor];
    dibuLab.textAlignment = NSTextAlignmentLeft;
    dibuLab.font = [UIFont systemFontOfSize:15.0f];
    dibuLab.text = [NSString stringWithFormat:@"%@",self.infoArr[0][@"zhutitle"]];
    [dibuLabView addSubview:dibuLab];

    
    [self.tableView.tableHeaderView addSubview:topImgV];
}

//- (void)downloadNewsAction:(UIButton *)sender {
//    
//    [SVProgressHUD showInfoWithStatus:@"开始下载"];
//    [self performSelector:@selector(SVPDismiss) withObject:nil afterDelay:1.0];
//    NSMutableDictionary *dic = self.infoArr[sender.tag - 100];
//    dispatch_async(dispatch_get_main_queue(), ^{
//        ProjiectDownLoadManager *manager = [ProjiectDownLoadManager defaultProjiectDownLoadManager];
//        [manager insertSevaDownLoadArray:dic];
        
//        WHC_Download *op = [[WHC_Download alloc]initStartDownloadWithURL:[NSURL URLWithString:dic[@"post_mp"]] savePath:manager.userDownLoadPath savefileName:[dic[@"post_mp"] stringByReplacingOccurrencesOfString:@"/" withString:@""] withObj:dic delegate:nil];
//        [manager.downLoadQueue addOperation:op];
//    });
//}

- (void)SVPDismiss {
    [SVProgressHUD dismiss];
}

#pragma mark - UITableViewDelegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if ([[CommonCode readFromUserD:@"dangqianbofangxinwenID"] isEqualToString:self.infoArr[indexPath.row][@"id"]]){
        [UIView animateWithDuration:0.3f animations:^{
            [bofangVC shareInstance].view.frame = CGRectMake(0, 0, IPHONE_W, IPHONE_H);
        }];
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
        [bofangVC shareInstance].yinpinzongTime.text = [[bofangVC shareInstance] convertStringWithTime:[self.infoArr[indexPath.row][@"post_time"] intValue] / 1000];
        
        ExcurrentNumber = (int)indexPath.row;
        [bofangVC shareInstance].newsModel.ImgStrjiemu = self.infoArr[indexPath.row][@"smeta"];
        [bofangVC shareInstance].newsModel.ZhengWenjiemu = self.infoArr[indexPath.row][@"post_excerpt"];
        [bofangVC shareInstance].newsModel.praisenum = self.infoArr[indexPath.row][@"praisenum"];
         [bofangVC shareInstance].newsModel.url = self.infoArr[indexPath.row][@"url"];
        [bofangVC shareInstance].newsModel.post_keywords = self.infoArr[indexPath.row][@"post_keywords"];
        [[bofangVC shareInstance].tableView reloadData];

        [Explayer replaceCurrentItemWithPlayerItem:[[AVPlayerItem alloc]initWithURL:[NSURL URLWithString:self.infoArr[indexPath.row][@"post_mp"]]]];
        ExisRigester = YES;
        ExIsKaiShiBoFang = YES;
        ExwhichBoFangYeMianStr = @"dingyuebofang";
        self.hidesBottomBarWhenPushed = YES;
        [self.navigationController.navigationBar setHidden:YES];
        [self.navigationController pushViewController:[bofangVC shareInstance ] animated:YES];
        self.hidesBottomBarWhenPushed = YES;
        
        [[NSNotificationCenter defaultCenter] postNotificationName:@"yuanpanzhuan" object:nil];
        [[NSNotificationCenter defaultCenter] postNotificationName:@"qiehuanxinwen" object:nil];
        [CommonCode writeToUserD:self.infoArr andKey:@"zhuyeliebiao"];
        [CommonCode writeToUserD:self.infoArr[indexPath.row][@"id"] andKey:@"dangqianbofangxinwenID"];
    }
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.infoArr.count;
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *wodeJieMuIdentify = @"lunboxiangqingIdentify";
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
    //        [cell.contentView addSubview:imgV];
    //    }
    [cell.contentView addSubview:imgV];
    
    UILabel *titleLab = [[UILabel alloc]initWithFrame:CGRectMake(20.0 / 375 * IPHONE_W, 6.0 / 667 * IPHONE_H , SCREEN_WIDTH - 169.0 / 375 * IPHONE_W, 21.0 / 667 *IPHONE_H)];
    titleLab.text = self.infoArr[indexPath.row][@"post_title"];
    titleLab.textColor = [UIColor blackColor];
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
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 124.0 / 667 * SCREEN_HEIGHT;
}
#pragma mark --- 懒加载
- (UITableView *)tableView
{
    if (!_tableView)
    {
        _tableView = [[UITableView alloc]initWithFrame:CGRectMake(0, 0, IPHONE_W, IPHONE_H - 64) style:UITableViewStylePlain];
        _tableView.delegate = self;
        _tableView.dataSource = self;
        _tableView.tableFooterView = [UIView new];
        _tableView.tableHeaderView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, IPHONE_W, 206.25 / 667 * IPHONE_H)];
    }
    return _tableView;
}

- (void)rightCellBtnAction:(UIButton *)sender
{
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
    }else
    {
        quanjvIndexPath = nil;
        sender.selected = NO;
        [UIView animateWithDuration:0.3f animations:^{
            cell.frame = CGRectMake(0, cell.frame.origin.y, cell.frame.size.width, cell.frame.size.height);
        }];
    }
}


- (void)back
{
    [self.navigationController popViewControllerAnimated:YES];
}
- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    self.navigationController.navigationBarHidden=YES;
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
