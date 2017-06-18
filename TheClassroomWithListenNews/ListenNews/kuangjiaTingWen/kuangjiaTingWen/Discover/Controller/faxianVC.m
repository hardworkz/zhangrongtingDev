//
//  faxianVC.m
//  kuangjiaTingWen
//
//  Created by 贺楠 on 16/6/3.
//  Copyright © 2016年 贺楠. All rights reserved.
//

#import "faxianVC.h"
#import "MJRefresh.h"
#import "UIImageView+WebCache.h"
#import "faxianBtn.h"
#import "faxianGengDuoVC.h"
//#import "UMSocialSnsService.h"
//#import "UMSocialSnsPlatformManager.h"
#import "zhuboxiangqingVCNew.h"
#import "bofangVC.h"
#import "cellRightBtn.h"
#import "NSDate+TimeFormat.h"
#import "AppDelegate.h"
#import "LoginNavC.h"
#import "LoginVC.h"
#import "ProjiectDownLoadManager.h"
#import "WHC_Download.h"
#import "ClassViewController.h"
#import "MoreClassViewController.h"

@interface faxianVC ()<UITableViewDataSource,UITableViewDelegate,UISearchBarDelegate>
{
    UILabel *SouSuotitleLab;          //cell内标题lab
    int SouSuonumberPage;
    UILabel *titleLab;          //cell内标题lab
    
    NSIndexPath *SouSuoquanjvIndexPath;
}
@property (strong, nonatomic) NSArray *SouSuodataSource;/**<排序前的整个数据源*/
@property(strong,nonatomic)UITableView *SouSuotableView;
@property(strong,nonatomic)UISearchBar *SouSuosearchBar;
@property(strong,nonatomic)UITableView *SouSuosousuoTableView;
@property(strong,nonatomic)NSMutableArray *SouSuosousuoArrM;
@property(strong,nonatomic)NSMutableArray *SouSuodataArrM;
@property(strong,nonatomic)NSMutableArray *SearchActResultsArrM;
@property(strong,nonatomic)UITableView *faxianTableView;
@property(strong,nonatomic)NSMutableArray *faxianArrM;
@property(strong,nonatomic)NSString *CurrentSearchKeyWords;

@property (strong, nonatomic) NSMutableDictionary *pushNewsInfo;


@end

@implementation faxianVC

- (void)viewDidLoad {
    [super viewDidLoad];
//    self.navigationItem.title = @"发现";
    DefineWeakSelf;
    APPDELEGATE.faxianSkipToPlayingVC = ^(NSString *pushNewsID){
        if ([pushNewsID isEqualToString:@"NO"]) {
            //上一次听过的新闻
            if (ExIsKaiShiBoFang) {
                self.hidesBottomBarWhenPushed = YES;
                [self.navigationController pushViewController:[bofangVC shareInstance] animated:YES];
                self.hidesBottomBarWhenPushed = NO;
            }
            else{
                //跳转上一次播放的新闻
                [self skipToLastNews];
            }
        }
        else{
            NSString *pushNewsID = [[NSUserDefaults standardUserDefaults]valueForKey:@"pushNews"];
            if ([[CommonCode readFromUserD:@"dangqianbofangxinwenID"] isEqualToString:pushNewsID]){
                NSString *isPlayingVC = [CommonCode readFromUserD:@"isPlayingVC"];
                if ([isPlayingVC isEqualToString:@"YES"]) {
                    
                }
                else{
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
                [weakSelf getPushNewsDetail];
            }
        }
    };
    
    self.edgesForExtendedLayout = UIRectEdgeNone;
    
    self.view.backgroundColor = [UIColor whiteColor];
    SouSuonumberPage = 1;
    self.CurrentSearchKeyWords = @"";
    SouSuoquanjvIndexPath = nil;
    
    if ([[CommonCode readFromUserD:@"faxianDataArr"] isKindOfClass:[NSArray class]]){
        self.faxianArrM = [faxianModel mj_objectArrayWithKeyValuesArray:[CommonCode readFromUserD:@"faxianDataArr"]];
        [self.faxianTableView reloadData];
    }
    
    [self loadData];
    
    [self.view addSubview:self.SouSuotableView];
    [self.view addSubview:self.SouSuosearchBar];
    [self.view addSubview:self.SouSuosousuoTableView];
    [self.view insertSubview:self.faxianTableView atIndex:0];
    
    //播放下一条自动加载更多新闻信息通知
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(zidongjiazai:) name:@"faxianbofangyaojiazaishujv" object:nil];
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(gaibianyanse:) name:@"gaibianyanse" object:nil];
    
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
//    self.navBarBgAlpha = @"0.0";
    [self.navigationController setNavigationBarHidden:YES animated:YES];
//    [self loadData];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [self.navigationController setNavigationBarHidden:YES animated:YES];
}

#pragma mark - UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    if (tableView == self.SouSuotableView) {
        if ([self.SearchActResultsArrM count]) {
            return 2;
        }
        else{
          return 1;
        }
    }
    else{
        return 1;
    }
}

-(UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section {
    
    UIView *SearchTableViewSectionFootView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, 10)];
    [SearchTableViewSectionFootView setBackgroundColor:gSubColor];
    return SearchTableViewSectionFootView;
}

#pragma mark - UITableViewDelegate

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section{
    if (tableView == self.SouSuotableView) {
        return 10.0;
    }
    else {
        return 0.1;
    }
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (tableView == self.SouSuotableView){
        if ([self.SearchActResultsArrM count]) {
            if (section == 0) {
                return [self.SearchActResultsArrM count];
            }
            else{
                return [self.SouSuodataArrM count];
            }
        }else {
            return self.SouSuodataArrM.count;
        }
    }
    else if (tableView == self.SouSuosousuoTableView){
        return self.SouSuosousuoArrM.count;
    }
    else{
        //TODO:发现课堂模块
        faxianModel *model = [self.faxianArrM firstObject];
        return self.faxianArrM.count + [model.data count] - 1;
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if (tableView == self.SouSuotableView){
        static NSString *xinwensousuoIdentify = @"xinwensousuoIdentify";
        UITableViewCell *cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:xinwensousuoIdentify];
        if (!cell){
            cell = [tableView dequeueReusableCellWithIdentifier:xinwensousuoIdentify];
        }
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        
        if (self.SouSuodataArrM.count == 0 && self.SearchActResultsArrM.count == 0){
            return cell;
        }
        else {
            if ([self.SearchActResultsArrM count]) {
                if (indexPath.section == 0) {
                    //搜索的节目分区内容
                    UIImageView *imgV = [[UIImageView alloc]initWithFrame:CGRectMake(10.0 / 375 * IPHONE_W, 11, 45, 45)];
                    if([self.SearchActResultsArrM[indexPath.row][@"images"] rangeOfString:@"/data/upload/"].location !=NSNotFound)
                    {
                        [imgV sd_setImageWithURL:[NSURL URLWithString:USERPHOTOHTTPSTRINGZhuBo(self.SearchActResultsArrM[indexPath.row][@"images"])] placeholderImage:[UIImage imageNamed:@"user-5"]];
                    }
                    else
                    {
                        [imgV sd_setImageWithURL:[NSURL URLWithString:USERPOTOAD( self.SearchActResultsArrM[indexPath.row][@"images"])] placeholderImage:[UIImage imageNamed:@"user-5"]];
                    }

                    imgV.layer.cornerRadius = 22.5f;
                    imgV.layer.masksToBounds = YES;
                    imgV.contentMode = UIViewContentModeScaleAspectFit;
                    [cell.contentView addSubview:imgV];
                
                    UILabel *nameLab = [[UILabel alloc]initWithFrame:CGRectMake(5.0 / 375 * IPHONE_W + 57 + 10.0 / 375 * IPHONE_W, 15, 200.0 / 375 * IPHONE_W, 15)];
                    if ([self.SearchActResultsArrM isKindOfClass:[NSArray class]])
                    {
                        nameLab.text = self.SearchActResultsArrM[indexPath.row ][@"name"];
                    }
                    
                    nameLab.textColor = [UIColor blackColor];
                    nameLab.textAlignment = NSTextAlignmentLeft;
                    nameLab.font = [UIFont systemFontOfSize:16.0f];
                    [cell.contentView addSubview:nameLab];
                    
                    UILabel *neirongLab = [[UILabel alloc]initWithFrame:CGRectMake(nameLab.frame.origin.x, 37.0 / 667 * SCREEN_HEIGHT, 250.0 / 375 * IPHONE_W, 15.0 / 667 * SCREEN_HEIGHT)];
                    
                    NSString *sigtStr = self.SearchActResultsArrM[indexPath.row][@"description"];
                    
                    if (sigtStr.length == 0)
                    {
                        neirongLab.text = @"该用户没有什么想说的";
                    }else
                    {
                        neirongLab.text = sigtStr;
                    }
                    
                    neirongLab.textColor = [UIColor grayColor];
                    neirongLab.font = [UIFont systemFontOfSize:13.0f];
                    neirongLab.textAlignment = NSTextAlignmentLeft;
                    neirongLab.alpha = 0.7f;
                    [cell.contentView addSubview:neirongLab];
                    
                    UIButton *isSelectBtn = [UIButton buttonWithType:UIButtonTypeCustom];
                    isSelectBtn.frame = CGRectMake(IPHONE_W - 45.0 / 375 * IPHONE_W, 18.5, 24, 24);
                    isSelectBtn.contentMode = UIViewContentModeScaleAspectFit;
                    NSString *is_fan = [NSString stringWithFormat:@"%@",self.SearchActResultsArrM[indexPath.row][@"is_fan"]];
                        if ([is_fan isEqualToString:@"0"]) {
                            
                            [isSelectBtn setBackgroundImage:[UIImage imageNamed:@"card_icon_addattention"] forState:UIControlStateNormal];
                            isSelectBtn.selected = YES;
                        }
                        else if([is_fan isEqualToString:@"1"]){
                            [isSelectBtn setBackgroundImage:[UIImage imageNamed:@"card_icon_unfollow"] forState:UIControlStateNormal];
                            isSelectBtn.selected = NO;
                        }
                    [isSelectBtn addTarget:self action:@selector(tapAction:) forControlEvents:UIControlEventTouchUpInside];
                    [cell.contentView addSubview:isSelectBtn];
                    
                    cell.selectionStyle = UITableViewCellSelectionStyleNone;
                    return cell;
                }
                else {
//                    UIImageView *imgLeft = [[UIImageView alloc]initWithFrame:CGRectMake(5.0 / 375 * SCREEN_WIDTH, 19.0 / 667 * SCREEN_HEIGHT, 112.0 / 375 * IPHONE_W, 62.72 / 375 *IPHONE_W)];
                    UIImageView *imgLeft = [[UIImageView alloc]initWithFrame:CGRectMake(SCREEN_WIDTH - 125.0 / 375 * IPHONE_W, 19, 105.0 / 375 * IPHONE_W,   84.72 / 375 *IPHONE_W)];
                    if (IS_IPAD) {
                        [imgLeft setFrame:CGRectMake(SCREEN_WIDTH - 125.0 / 375 * IPHONE_W, 19, 105.0 / 375 * IPHONE_W, 70.0 / 375 *IPHONE_W)];
                    }
                    RTLog(@"%@----%@",NEWSSEMTPHOTOURL(self.SouSuodataArrM[indexPath.row][@"smeta"]),self.SouSuodataArrM[indexPath.row][@"smeta"]);
                    [imgLeft sd_setImageWithURL:[NSURL URLWithString:NEWSSEMTPHOTOURL(self.SouSuodataArrM[indexPath.row][@"smeta"])]];
                    imgLeft.contentMode = UIViewContentModeScaleAspectFill;
                    imgLeft.clipsToBounds = YES;
                    [cell.contentView addSubview:imgLeft];
                    imgLeft.contentMode = UIViewContentModeScaleToFill;
                    titleLab =[[UILabel alloc]initWithFrame:CGRectMake(20.0 / 375 * IPHONE_W, 16.0 / 667 * IPHONE_H , SCREEN_WIDTH - 155.0 / 375 * IPHONE_W, 21.0 / 667 *IPHONE_H)];
                    titleLab.text = self.SouSuodataArrM[indexPath.row][@"post_title"];
//                    if ([[CommonCode readFromUserD:@"yitingguoxinwenID"] isKindOfClass:[NSArray class]]){
//                        
//                        NSArray *yitingguoArr = [NSArray arrayWithArray:[CommonCode readFromUserD:@"yitingguoxinwenID"]];
//                        for (int i = 0; i < yitingguoArr.count - 1; i ++ ){
//                            
//                            if ([self.SouSuodataArrM[indexPath.row][@"id"] isEqualToString:yitingguoArr[i]]){
//                                
//                                if ([[CommonCode readFromUserD:@"dangqianbofangxinwenID"] isEqualToString:self.SouSuodataArrM[indexPath.row][@"id"]]){
//                                    
//                                    titleLab.textColor = gMainColor;
//                                    break;
//                                }
//                                else{
//                                    titleLab.textColor = [[UIColor grayColor]colorWithAlphaComponent:0.7f];
//                                    break;
//                                }
//                            }
//                            else{
//                                titleLab.textColor = [UIColor blackColor];
//                            }
//                        }
//                    }
                    if ([[CommonCode readFromUserD:@"yitingguoxinwenID"] isKindOfClass:[NSArray class]]){
                        NSArray *yitingguoArr = [NSArray arrayWithArray:[CommonCode readFromUserD:@"yitingguoxinwenID"]];
                        for (int i = 0; i < yitingguoArr.count - 1; i ++ ){
                            if ([self.SouSuodataArrM[indexPath.row][@"id"] isEqualToString:yitingguoArr[i]]){
                                if ([[CommonCode readFromUserD:@"dangqianbofangxinwenID"] isEqualToString:self.SouSuodataArrM[indexPath.row][@"id"]]){
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
                    if ([[CommonCode readFromUserD:@"dangqianbofangxinwenID"] isEqualToString:self.SouSuodataArrM[indexPath.row][@"id"]]){
                        titleLab.textColor = gMainColor;
                    }

                    titleLab.textAlignment = NSTextAlignmentLeft;
                    titleLab.font = [UIFont boldSystemFontOfSize:17.0f];
                    [cell.contentView addSubview:titleLab];
                    [titleLab setNumberOfLines:3];
                    titleLab.lineBreakMode = NSLineBreakByWordWrapping;
                    CGSize size = [titleLab sizeThatFits:CGSizeMake(titleLab.frame.size.width, MAXFLOAT)];
                    titleLab.frame = CGRectMake(titleLab.frame.origin.x, titleLab.frame.origin.y, titleLab.frame.size.width, size.height);
                    
                    //日期
                    UILabel *riqiLab = [[UILabel alloc]initWithFrame:CGRectMake(20.0 / 375 * IPHONE_W, 86.0 / 667 *IPHONE_H, 135.0 / 375 * IPHONE_W, 21.0 / 667 *IPHONE_H)];
                    NSDate *date = [NSDate dateFromString:self.SouSuodataArrM[indexPath.row][@"post_modified"]];
                    riqiLab.text = [date showTimeByTypeA];
                    riqiLab.textColor = gTextColorSub;
                    riqiLab.font = [UIFont systemFontOfSize:13.0f];
                    [cell.contentView addSubview:riqiLab];
                    //大小
                    UILabel *dataLab = [[UILabel alloc]initWithFrame:CGRectMake(SCREEN_WIDTH - 213.0 / 375 * IPHONE_W, 86.0 / 667 *IPHONE_H, 45.0 / 375 * IPHONE_W, 21.0 / 667 *IPHONE_H)];
                    dataLab.text = [NSString stringWithFormat:@"%.1lf%@",[self.SouSuodataArrM[indexPath.row][@"post_size"] intValue] / 1024.0 / 1024.0,@"M"];
//                    NSString *str = [NSString stringWithFormat:@"%@",dataLab.text];
//                    if (str.length > 5)
//                    {
//                        dataLab.frame = CGRectMake(dataLab.frame.origin.x, dataLab.frame.origin.y, (str.length - 1) * 9.2 / 375 * IPHONE_W, 21);
//                    }else
//                    {
//                        dataLab.frame = CGRectMake(dataLab.frame.origin.x, dataLab.frame.origin.y, (str.length - 1) * 11.0 / 375 * IPHONE_W, 21);
//                    }
                    dataLab.textColor = gTextColorSub;
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
                    [cell.contentView addSubview:download];
                    
                    cell.selectionStyle = UITableViewCellSelectionStyleNone;
                    
                    return cell;
                }
                
            }
            else {
            UIImageView *imgLeft = [[UIImageView alloc]initWithFrame:CGRectMake(SCREEN_WIDTH - 125.0 / 375 * IPHONE_W, 19, 105.0 / 375 * IPHONE_W,   84.72 / 375 *IPHONE_W)];
            [imgLeft sd_setImageWithURL:[NSURL URLWithString:NEWSSEMTPHOTOURL(self.SouSuodataArrM[indexPath.row][@"smeta"])]];
            //placeholderImage:[UIImage imageNamed:@"thumbnailsdefault"]
            [cell.contentView addSubview:imgLeft];
            imgLeft.contentMode = UIViewContentModeScaleAspectFill;
            imgLeft.clipsToBounds = YES;
                
            titleLab = [[UILabel alloc]initWithFrame:CGRectMake(20.0 / 375 * IPHONE_W, 16.0 / 667 * IPHONE_H , SCREEN_WIDTH - 155.0 / 375 * IPHONE_W, 21.0 / 667 *IPHONE_H)];
            titleLab.text = self.SouSuodataArrM[indexPath.row][@"post_title"];
            if ([[CommonCode readFromUserD:@"yitingguoxinwenID"] isKindOfClass:[NSArray class]]){
                
                NSArray *yitingguoArr = [NSArray arrayWithArray:[CommonCode readFromUserD:@"yitingguoxinwenID"]];
                for (int i = 0; i < yitingguoArr.count - 1; i ++ ){
                    
                    if ([self.SouSuodataArrM[indexPath.row][@"id"] isEqualToString:yitingguoArr[i]]){
                        
                        if ([[CommonCode readFromUserD:@"dangqianbofangxinwenID"] isEqualToString:self.SouSuodataArrM[indexPath.row][@"id"]]){
                            titleLab.textColor = gMainColor;
                            break;
                        }
                        else{
                            titleLab.textColor = [[UIColor grayColor]colorWithAlphaComponent:0.7f];
                            break;
                        }
                    }
                    else{
                        titleLab.textColor = [UIColor blackColor];
                    }
                }
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
                    UILabel *detailNews = [[UILabel alloc]initWithFrame:CGRectMake(titleLab.frame.origin.x, titleLab.frame.origin.y + titleLab.frame.size.height + 20.0 / 667 * SCREEN_HEIGHT, titleLab.frame.size.width, 21.0 / 667 *IPHONE_H)];
                    detailNews.text = self.SouSuodataArrM[indexPath.row][@"post_excerpt"];
                    detailNews.textColor = gTextColorSub;
                    detailNews.font = [UIFont systemFontOfSize:15.0f];
                    [cell.contentView addSubview:detailNews];
                }
                
                
                
            //日期
            UILabel *riqiLab =  [[UILabel alloc]initWithFrame:CGRectMake(20.0 / 375 * IPHONE_W, 86.0 / 667 *IPHONE_H, 135.0 / 375 * IPHONE_W, 21.0 / 667 *IPHONE_H)];
            NSDate *date = [NSDate dateFromString:self.SouSuodataArrM[indexPath.row][@"post_modified"]];
            riqiLab.text = [date showTimeByTypeA];
            riqiLab.textColor = gTextColorSub;
            riqiLab.font = [UIFont systemFontOfSize:13.0f ];
            [cell.contentView addSubview:riqiLab];
            //大小
            UILabel *dataLab = [[UILabel alloc]initWithFrame:CGRectMake(SCREEN_WIDTH - 213.0 / 375 * IPHONE_W, 86.0 / 667 *IPHONE_H, 45.0 / 375 * IPHONE_W, 21.0 / 667 *IPHONE_H)];
            dataLab.text = [NSString stringWithFormat:@"%.1lf%@",[self.SouSuodataArrM[indexPath.row][@"post_size"] intValue] / 1024.0 / 1024.0,@"M"];
//            NSString *str = [NSString stringWithFormat:@"%@",dataLab.text];
//            if (str.length > 5)
//            {
//                dataLab.frame = CGRectMake(dataLab.frame.origin.x, dataLab.frame.origin.y, (str.length - 1) * 9.2 / 375 * IPHONE_W, 21.0 / 667 * SCREEN_HEIGHT);
//            }else
//            {
//                dataLab.frame = CGRectMake(dataLab.frame.origin.x, dataLab.frame.origin.y, (str.length - 1) * 11.0 / 375 * IPHONE_W, 21.0 / 667 * SCREEN_HEIGHT);
//            }
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
        }
    }
    else if (tableView == self.SouSuosousuoTableView) {
        static NSString *lishisousuociIdentify = @"lishisousuociIdentify";
        UITableViewCell *cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:lishisousuociIdentify];
        if (!cell)
        {
            cell = [tableView dequeueReusableCellWithIdentifier:lishisousuociIdentify];
        }
        cell.textLabel.text = self.SouSuosousuoArrM[self.SouSuosousuoArrM.count - indexPath.row - 1];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        return cell;
    }
    else{
        static NSString *faxianIdentify = @"faxianidentify";
        UITableViewCell *cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:faxianIdentify];
        if (!cell){
            cell = [tableView dequeueReusableCellWithIdentifier:faxianIdentify];
        }
        UILabel *faxiantitleLab = [[UILabel alloc]initWithFrame:CGRectMake(21.0 / 375 * IPHONE_W, 10.0 / 667 * IPHONE_H, 100.0 / 375 * IPHONE_W, 20.0 / 667 * IPHONE_H)];
        faxiantitleLab.textColor = [UIColor blackColor];
        faxiantitleLab.font = [UIFont boldSystemFontOfSize:17.0f];
        faxiantitleLab.textAlignment = NSTextAlignmentLeft;
        UIView *faxianshutiao = [[UIView alloc]initWithFrame:CGRectMake(faxiantitleLab.frame.origin.x - 6.0 / 375 * IPHONE_W, faxiantitleLab.frame.origin.y + 0.5 / 667 * IPHONE_H, 4.0 / 375 * IPHONE_W, faxiantitleLab.frame.size.height - 1.0 / 667 * IPHONE_H)];
        faxianshutiao.backgroundColor = gMainColor;
//        [cell.contentView addSubview:faxianshutiao];
        
        UIButton *faxiangengduoBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        faxiangengduoBtn.frame = CGRectMake(IPHONE_W - 70.0 / 375 * IPHONE_W, faxiantitleLab.frame.origin.y, 60.0 / 375 * IPHONE_W, 20.0 / 667 * IPHONE_H);
        [faxiangengduoBtn setTitle:@"更多" forState:UIControlStateNormal];
        [faxiangengduoBtn addTarget:self action:@selector(faxianliebiaoGengDuoAction:) forControlEvents:UIControlEventTouchUpInside];
        faxiangengduoBtn.titleLabel.font = [UIFont systemFontOfSize:13.0f];
        [faxiangengduoBtn setTitleColor:gTextColorSub forState:UIControlStateNormal];
        
        
        UIButton *faxianjiantou = [UIButton buttonWithType:UIButtonTypeCustom];
        faxianjiantou.frame = CGRectMake(IPHONE_W - 25.0 / 375 * IPHONE_W, faxiangengduoBtn.frame.origin.y + 1.0 / 667 * IPHONE_H, faxiangengduoBtn.frame.size.height - 5.0 / 667 * IPHONE_H, faxiangengduoBtn.frame.size.height - 5.0 / 667 * IPHONE_H);
        [faxianjiantou setImage:[UIImage imageNamed:@"fine_list_ic_more"] forState:UIControlStateNormal];
        
        [faxianjiantou addTarget:self action:@selector(faxianliebiaoGengDuoAction:) forControlEvents:UIControlEventTouchUpInside];
        //TODO:发现课堂模块时需注释
//        [cell.contentView addSubview:faxiantitleLab];
//        [cell.contentView addSubview:faxiangengduoBtn];
//        [cell.contentView addSubview:faxianjiantou];
//        faxiantitleLab.text = self.faxianArrM[indexPath.row][@"type"];
        
//        //TODO:发现课堂模块
        RTLog(@"%ld",indexPath.row);
        faxianModel *firstModel = [self.faxianArrM firstObject];
        faxianSubModel *subModel;
        faxianModel *model2;
        if (indexPath.row == 0 || indexPath.row >= [firstModel.data count]) {
            [cell.contentView addSubview:faxiantitleLab];
            [cell.contentView addSubview:faxiangengduoBtn];
            [cell.contentView addSubview:faxianjiantou];
        }
        if (indexPath.row == 0) {
            faxiantitleLab.text = firstModel.type;
        }
        else if (indexPath.row >= [firstModel.data count]){
            model2 = self.faxianArrM[indexPath.row - [firstModel.data count] + 1];
            faxiantitleLab.text = model2.type;
        }
        if (indexPath.row < [firstModel.data count]){
            subModel = firstModel.data[indexPath.row];
            CGFloat tempHeight = 0;
            if (indexPath.row == 0) {
                tempHeight = 27.5;
            }
            else{
                tempHeight = 0;
            }
            //图片
            UIImageView *imgLeft = [[UIImageView alloc]initWithFrame:CGRectMake(20.0 / 375 * IPHONE_W, 7.5 + tempHeight, 105.0 / 375 * IPHONE_W, 105.0 / 375 *IPHONE_W)];
            if (IS_IPAD) {
                [imgLeft setFrame:CGRectMake(20.0 / 375 * IPHONE_W, 7.5, 105.0 / 375 * IPHONE_W, 70.0 / 375 *IPHONE_W)];
            }
            [imgLeft.layer setMasksToBounds:YES];
            [imgLeft.layer setCornerRadius:5.0];
            if ([NEWSSEMTPHOTOURL(subModel.images)  rangeOfString:@"http"].location != NSNotFound){
                [imgLeft sd_setImageWithURL:[NSURL URLWithString:NEWSSEMTPHOTOURL(subModel.images)]];
                //placeholderImage:[UIImage imageNamed:@"thumbnailsdefault"]
            }
            else{
                NSString *str = USERPOTOAD(NEWSSEMTPHOTOURL(subModel.images));
                [imgLeft sd_setImageWithURL:[NSURL URLWithString:str]];
                //placeholderImage:[UIImage imageNamed:@"thumbnailsdefault"]
            }
            
            [cell.contentView addSubview:imgLeft];
            imgLeft.contentMode = UIViewContentModeScaleAspectFill;
            imgLeft.clipsToBounds = YES;
            
            faxianSubModel *subModel2 = firstModel.data[indexPath.row];
            //标题
            UILabel *classTitle = [[UILabel alloc]initWithFrame:CGRectMake(CGRectGetMaxX(imgLeft.frame) + 5.0 / 375 * IPHONE_W, imgLeft.frame.origin.y,  SCREEN_WIDTH - CGRectGetMaxX(imgLeft.frame) - 70.0 / 375 * IPHONE_W, 21.0 / 667 *IPHONE_H)];
            classTitle.text = subModel2.name;
            classTitle.textColor = [UIColor blackColor];
            classTitle.textAlignment = NSTextAlignmentLeft;
            classTitle.font = [UIFont boldSystemFontOfSize:16.0f ];
            [cell.contentView addSubview:classTitle];
            [classTitle setNumberOfLines:3];
            classTitle.lineBreakMode = NSLineBreakByWordWrapping;
            CGSize size = [classTitle sizeThatFits:CGSizeMake(classTitle.frame.size.width, MAXFLOAT)];
            classTitle.frame = CGRectMake(classTitle.frame.origin.x, classTitle.frame.origin.y, classTitle.frame.size.width, size.height);
            //价钱
            UILabel *price = [[UILabel alloc]initWithFrame:CGRectMake(CGRectGetMaxX(classTitle.frame) + 10, classTitle.frame.origin.y,40.0 / 375 * IPHONE_W, 21.0 / 667 *IPHONE_H)];
            price.text = [NSString stringWithFormat:@"￥%ld",[subModel2.price integerValue]];
            price.font = gFontMain14;
            price.textColor = gMainColor;
            [cell.contentView addSubview:price];
            
            //简介
            UILabel *describe = [[UILabel alloc]initWithFrame:CGRectMake(classTitle.frame.origin.x, 60.0 * 667.0/SCREEN_HEIGHT + tempHeight, SCREEN_WIDTH - CGRectGetMaxX(imgLeft.frame) - 20.0 / 375 * IPHONE_W, 21.0 / 667 *IPHONE_H)];
            if (TARGETED_DEVICE_IS_IPHONE_568){
                [describe setFrame:CGRectMake(classTitle.frame.origin.x, CGRectGetMaxY(classTitle.frame), SCREEN_WIDTH - CGRectGetMaxX(imgLeft.frame) - 20.0 / 375 * IPHONE_W, 21.0 / 667 *IPHONE_H)];
            }
            else{
                [describe setFrame:CGRectMake(classTitle.frame.origin.x, 60.0 * 667.0/SCREEN_HEIGHT + tempHeight, SCREEN_WIDTH - CGRectGetMaxX(imgLeft.frame) - 20.0 / 375 * IPHONE_W, 21.0 / 667 *IPHONE_H)];
            }
            describe.text = subModel2.Description;
            describe.textColor = [[UIColor grayColor]colorWithAlphaComponent:0.7f];
            describe.textColor = gTextColorSub;
            describe.textAlignment = NSTextAlignmentLeft;
            describe.font = gFontMain13;
            [cell.contentView addSubview:describe];
            [describe setNumberOfLines:3];
            describe.lineBreakMode = NSLineBreakByWordWrapping;
            CGSize size1 = [describe sizeThatFits:CGSizeMake(describe.frame.size.width, MAXFLOAT)];
            describe.frame = CGRectMake(describe.frame.origin.x, describe.frame.origin.y, describe.frame.size.width, size1.height);
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
        }
        else if (indexPath.row == [firstModel.data count]){
            NSArray *arr = model2.data;
            //主播
            for (int i = 0; i < arr.count; i ++ ){
                faxianSubModel *currenSubModel = model2.data[i];
                faxianBtn *zhuboBtn = [[faxianBtn alloc]initWithImageUrlStr:currenSubModel.images andTitle:currenSubModel.name andIndex_row:(NSInteger *)indexPath.row forzhubo:YES];
                zhuboBtn.frame = CGRectMake(25.0 / 375 * IPHONE_W + (87.5 / 375 * IPHONE_W * i), 40.0 / 667 * IPHONE_H, 82.5 / 667 * IPHONE_H, 82.5 / 667 * IPHONE_H);
                zhuboBtn.tag = i;
                [zhuboBtn addTarget:self action:@selector(zhuboBtnAction:) forControlEvents:UIControlEventTouchUpInside];
                [cell.contentView addSubview:zhuboBtn];
                cell.selectionStyle = UITableViewCellSelectionStyleNone;
            }
        }
        else{
            //节目
            NSArray *arr = model2.data;
            if ([arr isKindOfClass:[NSArray class]]){
                for (int i = 0; i < arr.count; i ++ ){
                    faxianSubModel *currenSubModel = model2.data[i];
                    faxianBtn *zhuboBtn = [[faxianBtn alloc]initWithImageUrlStr:currenSubModel.images andTitle:currenSubModel.name andIndex_row:(NSInteger *)indexPath.row forzhubo:NO];
                    zhuboBtn.frame = CGRectMake((120.0 / 375 * IPHONE_W) * i, 40.0 / 667 * IPHONE_H, 120.0 / 667 * SCREEN_HEIGHT, 120.0 / 667 * SCREEN_HEIGHT);
                    zhuboBtn.tag = i;
                    [zhuboBtn addTarget:self action:@selector(zhuboBtnAction:) forControlEvents:UIControlEventTouchUpInside];
                    [cell.contentView addSubview:zhuboBtn];
                }
            }
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
        }
        return cell;
    }
}
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    if (tableView == self.SouSuosousuoTableView){
        return 44.0 / 667 * SCREEN_HEIGHT;
    }
    else if (tableView == self.SouSuotableView){
        if ([self.SearchActResultsArrM count]) {
            if (indexPath.section == 0) {
                return 67.0 / 667 * SCREEN_HEIGHT;
            }
            else{
                return 120.0 / 667 * SCREEN_HEIGHT;
            }
        }
        else{
           return 120.0 / 667 * SCREEN_HEIGHT;
        }
    }
    else{
        //TODO:发现课堂模块
        faxianModel *model = [self.faxianArrM firstObject];
        if (indexPath.row == 0){
            return  147.5 / 667 * IPHONE_H;
        }
        else if(indexPath.row < [model.data count]){
            return  120.0 / 667 * IPHONE_H;
        }
        else if (indexPath.row == [model.data  count]){
            return 161.0 / 667 * IPHONE_H;
        }
        else{
            return 200.0 / 667 * IPHONE_H;
        }
//        if (indexPath.row == 0){
//            return  161.0 / 667 * IPHONE_H;
//        }
//        else{
//            return 200.0 / 667 * IPHONE_H;
//        }
    }
}
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    if (tableView == self.SouSuosousuoTableView){
        self.SouSuosearchBar.text = self.SouSuosousuoArrM[self.SouSuosousuoArrM.count - indexPath.row - 1];
        [self.SouSuosousuoArrM addObject:self.SouSuosearchBar.text];
        [self.SouSuosousuoTableView reloadData];
        
        self.SouSuosousuoTableView.hidden = YES;
        self.SouSuotableView.hidden = NO;
        
        [self.SouSuodataArrM removeAllObjects];
        
        [self.SouSuotableView.mj_header beginRefreshing];
    }
    else if(tableView == self.SouSuotableView){
        if ([self.SearchActResultsArrM count]) {
            if (indexPath.section == 0) {
                NSDictionary *dic = [[NSDictionary alloc]initWithDictionary:self.SearchActResultsArrM[indexPath.row]];
//                zhuboxiangqingVCNew *faxianzhuboVC = [[zhuboxiangqingVCNew alloc]init];
//                faxianzhuboVC.jiemuDescription = dic[@"description"];
//                faxianzhuboVC.jiemuFan_num = dic[@"fan_num"];
//                faxianzhuboVC.jiemuID = dic[@"id"];
//                faxianzhuboVC.jiemuImages = dic[@"images"];
//                faxianzhuboVC.jiemuIs_fan = dic[@"is_fan"];
//                faxianzhuboVC.jiemuMessage_num = dic[@"message_num"];
//                faxianzhuboVC.jiemuName = dic[@"name"];
//                faxianzhuboVC.isfaxian = YES;
//                self.hidesBottomBarWhenPushed=YES;
//                [self.navigationController pushViewController:faxianzhuboVC animated:YES];
//                self.hidesBottomBarWhenPushed=NO;
                if ([dic[@"is_free"] isEqualToString:@"1"]) {
                    zhuboxiangqingVCNew *faxianzhuboVC = [[zhuboxiangqingVCNew alloc]init];
                    faxianzhuboVC.jiemuDescription = dic[@"description"];
                    faxianzhuboVC.jiemuFan_num = dic[@"fan_num"];
                    faxianzhuboVC.jiemuID = dic[@"id"];
                    faxianzhuboVC.jiemuImages = dic[@"images"];
                    faxianzhuboVC.jiemuIs_fan = dic[@"is_fan"];
                    faxianzhuboVC.jiemuMessage_num = dic[@"message_num"];
                    faxianzhuboVC.jiemuName = dic[@"name"];                    faxianzhuboVC.isfaxian = YES;
                    faxianzhuboVC.isClass = YES;
                    self.hidesBottomBarWhenPushed=YES;
                    [self.navigationController pushViewController:faxianzhuboVC animated:YES];
                    self.hidesBottomBarWhenPushed=NO;
                    
                }
                //跳转未购买课堂界面
                else if ([dic[@"is_free"] isEqualToString:@"0"]){
                    ClassViewController *vc = [ClassViewController new];
                    vc.act_id = dic[@"id"];
                    self.hidesBottomBarWhenPushed = YES;
                    [self.navigationController.navigationBar setHidden:YES];
                    [self.navigationController pushViewController:vc animated:YES];
                    self.hidesBottomBarWhenPushed = NO;
                }

            }
            else{
                if (SouSuoquanjvIndexPath){
                    UITableViewCell *yaoguanbiCell = [self.SouSuotableView cellForRowAtIndexPath:SouSuoquanjvIndexPath];
                    UIButton *yaoguanbiBtn = (UIButton *)[yaoguanbiCell.contentView viewWithTag:SouSuoquanjvIndexPath.row + 1000];
                    yaoguanbiBtn.selected = NO;
                    [UIView animateWithDuration:0.3f animations:^{
                        yaoguanbiCell.frame = CGRectMake(0, yaoguanbiCell.frame.origin.y, yaoguanbiCell.frame.size.width, yaoguanbiCell.frame.size.height);
                    }];
                    SouSuoquanjvIndexPath = nil;
                }
                if ([[CommonCode readFromUserD:@"dangqianbofangxinwenID"] isEqualToString:self.SouSuodataArrM[indexPath.row][@"id"]]){
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
                    [bofangVC shareInstance].newsModel.jiemuID = self.SouSuodataArrM[indexPath.row][@"id"];
                    [bofangVC shareInstance].newsModel.Titlejiemu = self.SouSuodataArrM[indexPath.row][@"post_title"];
                    [bofangVC shareInstance].newsModel.RiQijiemu = self.SouSuodataArrM[indexPath.row][@"post_date"];
                    [bofangVC shareInstance].newsModel.ImgStrjiemu = self.SouSuodataArrM[indexPath.row][@"smeta"];
                    [bofangVC shareInstance].newsModel.post_lai = self.SouSuodataArrM[indexPath.row][@"post_lai"];
                    [bofangVC shareInstance].newsModel.post_news = self.SouSuodataArrM[indexPath.row][@"post_act"][@"id"];
                    [bofangVC shareInstance].newsModel.jiemuName = self.SouSuodataArrM[indexPath.row][@"post_act"][@"name"];
                    [bofangVC shareInstance].newsModel.jiemuDescription = self.SouSuodataArrM[indexPath.row][@"post_act"][@"description"];
                    [bofangVC shareInstance].newsModel.jiemuImages = self.SouSuodataArrM[indexPath.row][@"post_act"][@"images"];
                    [bofangVC shareInstance].newsModel.jiemuFan_num = self.SouSuodataArrM[indexPath.row][@"post_act"][@"fan_num"];
                    [bofangVC shareInstance].newsModel.jiemuMessage_num = self.SouSuodataArrM[indexPath.row][@"post_act"][@"message_num"];
                    [bofangVC shareInstance].newsModel.jiemuIs_fan = self.SouSuodataArrM[indexPath.row][@"post_act"][@"is_fan"];
                    [bofangVC shareInstance].newsModel.post_mp = self.SouSuodataArrM[indexPath.row][@"post_mp"];
                    [bofangVC shareInstance].newsModel.post_time = self.SouSuodataArrM[indexPath.row][@"post_time"];
                    [bofangVC shareInstance].iszhuboxiangqing = NO;
                    [bofangVC shareInstance].yinpinzongTime.text = [[bofangVC shareInstance] convertStringWithTime:[self.SouSuodataArrM[indexPath.row][@"post_time"] intValue] / 1000];
                    
                    ExcurrentNumber = (int)indexPath.row;
                    
                    [bofangVC shareInstance].newsModel.ImgStrjiemu = self.SouSuodataArrM[indexPath.row][@"smeta"];
                    [bofangVC shareInstance].newsModel.ZhengWenjiemu = self.SouSuodataArrM[indexPath.row][@"post_excerpt"];
                    [bofangVC shareInstance].newsModel.praisenum = self.SouSuodataArrM[indexPath.row][@"praisenum"];
                    [bofangVC shareInstance].newsModel.post_keywords = self.SouSuodataArrM[indexPath.row][@"post_keywords"];
                    [bofangVC shareInstance].newsModel.url = self.SouSuodataArrM[indexPath.row][@"url"];
                    [[bofangVC shareInstance].tableView reloadData];
                    //        Explayer = [[AVPlayer alloc]initWithPlayerItem:[[AVPlayerItem alloc]initWithURL:[NSURL URLWithString:arr[indexPath.row][@"post_mp"]]]];
                    [Explayer replaceCurrentItemWithPlayerItem:[[AVPlayerItem alloc]initWithURL:[NSURL URLWithString:self.SouSuodataArrM[indexPath.row][@"post_mp"]]]];
                    ExisRigester = YES;
                    ExIsKaiShiBoFang = YES;
//                    [UIView animateWithDuration:0.3f animations:^{
//                        ExwhichBoFangYeMianStr = @"faxianbofang";
//                        [bofangVC shareInstance].newsModel.view.frame = CGRectMake(0, 0, IPHONE_W, IPHONE_H);
//                    }];
                    self.hidesBottomBarWhenPushed = YES;
                    [self.navigationController.navigationBar setHidden:YES];
                    [self.navigationController pushViewController:[bofangVC shareInstance ] animated:YES];
                    self.hidesBottomBarWhenPushed = NO;
                    [[NSNotificationCenter defaultCenter] postNotificationName:@"yuanpanzhuan" object:nil];
                    [[NSNotificationCenter defaultCenter] postNotificationName:@"qiehuanxinwen" object:nil];
                    [CommonCode writeToUserD:self.SouSuodataArrM andKey:@"zhuyeliebiao"];
                    [CommonCode writeToUserD:self.SouSuodataArrM[indexPath.row][@"id"] andKey:@"dangqianbofangxinwenID"];
                    if ([[CommonCode readFromUserD:@"yitingguoxinwenID"] isKindOfClass:[NSArray class]]){
                        NSMutableArray *yitingguoArr = [NSMutableArray arrayWithArray:[CommonCode readFromUserD:@"yitingguoxinwenID"]];
                        [yitingguoArr addObject:self.SouSuodataArrM[indexPath.row][@"id"]];
                        [CommonCode writeToUserD:yitingguoArr andKey:@"yitingguoxinwenID"];
                    }
                    else{
                        NSMutableArray *yitingguoArr = [NSMutableArray array];
                        [yitingguoArr addObject:self.SouSuodataArrM[indexPath.row][@"id"]];
                        [CommonCode writeToUserD:yitingguoArr andKey:@"yitingguoxinwenID"];
                    }
                }
            }
            
        }
        else{
            if (SouSuoquanjvIndexPath){
                UITableViewCell *yaoguanbiCell = [self.SouSuotableView cellForRowAtIndexPath:SouSuoquanjvIndexPath];
                UIButton *yaoguanbiBtn = (UIButton *)[yaoguanbiCell.contentView viewWithTag:SouSuoquanjvIndexPath.row + 1000];
                yaoguanbiBtn.selected = NO;
                [UIView animateWithDuration:0.3f animations:^{
                    yaoguanbiCell.frame = CGRectMake(0, yaoguanbiCell.frame.origin.y, yaoguanbiCell.frame.size.width, yaoguanbiCell.frame.size.height);
                }];
                SouSuoquanjvIndexPath = nil;
            }
            if ([self.SouSuodataArrM count]) {
                NSLog(@"8888=%@",[CommonCode readFromUserD:@"dangqianbofangxinwenID"]);
                
                if ([[CommonCode readFromUserD:@"dangqianbofangxinwenID"] isEqualToString:self.SouSuodataArrM[indexPath.row][@"id"]]){
                    //                [UIView animateWithDuration:0.3f animations:^{
                    //                    [bofangVC shareInstance].newsModel.view.frame = CGRectMake(0, 0, IPHONE_W, IPHONE_H);
                    //                }];
                    self.hidesBottomBarWhenPushed = YES;
                    [self.navigationController.navigationBar setHidden:YES];
                    [self.navigationController pushViewController:[bofangVC shareInstance] animated:YES];
                    self.hidesBottomBarWhenPushed = NO;
                }
                else{
                    [bofangVC shareInstance].newsModel.jiemuID = self.SouSuodataArrM[indexPath.row][@"id"];
                    [bofangVC shareInstance].newsModel.Titlejiemu = self.SouSuodataArrM[indexPath.row][@"post_title"];
                    [bofangVC shareInstance].newsModel.RiQijiemu = self.SouSuodataArrM[indexPath.row][@"post_date"];
                    [bofangVC shareInstance].newsModel.ImgStrjiemu = self.SouSuodataArrM[indexPath.row][@"smeta"];
                    [bofangVC shareInstance].newsModel.post_lai = self.SouSuodataArrM[indexPath.row][@"post_lai"];
                    [bofangVC shareInstance].newsModel.post_news = self.SouSuodataArrM[indexPath.row][@"post_act"][@"id"];
                    [bofangVC shareInstance].newsModel.jiemuName = self.SouSuodataArrM[indexPath.row][@"post_act"][@"name"];
                    [bofangVC shareInstance].newsModel.jiemuDescription = self.SouSuodataArrM[indexPath.row][@"post_act"][@"description"];
                    [bofangVC shareInstance].newsModel.jiemuImages = self.SouSuodataArrM[indexPath.row][@"post_act"][@"images"];
                    [bofangVC shareInstance].newsModel.jiemuFan_num = self.SouSuodataArrM[indexPath.row][@"post_act"][@"fan_num"];
                    [bofangVC shareInstance].newsModel.jiemuMessage_num = self.SouSuodataArrM[indexPath.row][@"post_act"][@"message_num"];
                    [bofangVC shareInstance].newsModel.jiemuIs_fan = self.SouSuodataArrM[indexPath.row][@"post_act"][@"is_fan"];
                    [bofangVC shareInstance].newsModel.post_mp = self.SouSuodataArrM[indexPath.row][@"post_mp"];
                    [bofangVC shareInstance].newsModel.post_time = self.SouSuodataArrM[indexPath.row][@"post_time"];
                    [bofangVC shareInstance].iszhuboxiangqing = NO;
                    [bofangVC shareInstance].yinpinzongTime.text = [[bofangVC shareInstance] convertStringWithTime:[self.SouSuodataArrM[indexPath.row][@"post_time"] intValue] / 1000];
                    
                    ExcurrentNumber = (int)indexPath.row;
                    
                    [bofangVC shareInstance].newsModel.ImgStrjiemu = self.SouSuodataArrM[indexPath.row][@"smeta"];
                    [bofangVC shareInstance].newsModel.ZhengWenjiemu = self.SouSuodataArrM[indexPath.row][@"post_excerpt"];
                    [bofangVC shareInstance].newsModel.praisenum = self.SouSuodataArrM[indexPath.row][@"praisenum"];
                    [bofangVC shareInstance].newsModel.post_keywords = self.SouSuodataArrM[indexPath.row][@"post_keywords"];
                    [bofangVC shareInstance].newsModel.url = self.SouSuodataArrM[indexPath.row][@"url"];
                    [[bofangVC shareInstance].tableView reloadData];
                    //        Explayer = [[AVPlayer alloc]initWithPlayerItem:[[AVPlayerItem alloc]initWithURL:[NSURL URLWithString:arr[indexPath.row][@"post_mp"]]]];
                    [Explayer replaceCurrentItemWithPlayerItem:[[AVPlayerItem alloc]initWithURL:[NSURL URLWithString:self.SouSuodataArrM[indexPath.row][@"post_mp"]]]];
                    ExisRigester = YES;
                    ExIsKaiShiBoFang = YES;
                    ExwhichBoFangYeMianStr = @"faxianbofang";
                    self.hidesBottomBarWhenPushed = YES;
                    [self.navigationController.navigationBar setHidden:YES];
                    [self.navigationController pushViewController:[bofangVC shareInstance ] animated:YES];
                    self.hidesBottomBarWhenPushed = NO;
                    //                [UIView animateWithDuration:0.3f animations:^{
                    //                    ExwhichBoFangYeMianStr = @"faxianbofang";
                    //                    [bofangVC shareInstance].newsModel.view.frame = CGRectMake(0, 0, IPHONE_W, IPHONE_H);
                    //                }];
                    [[NSNotificationCenter defaultCenter] postNotificationName:@"yuanpanzhuan" object:nil];
                    [[NSNotificationCenter defaultCenter] postNotificationName:@"qiehuanxinwen" object:nil];
                    [CommonCode writeToUserD:self.SouSuodataArrM andKey:@"zhuyeliebiao"];
                    [CommonCode writeToUserD:self.SouSuodataArrM[indexPath.row][@"id"] andKey:@"dangqianbofangxinwenID"];
                    if ([[CommonCode readFromUserD:@"yitingguoxinwenID"] isKindOfClass:[NSArray class]]){
                        NSMutableArray *yitingguoArr = [NSMutableArray arrayWithArray:[CommonCode readFromUserD:@"yitingguoxinwenID"]];
                        [yitingguoArr addObject:self.SouSuodataArrM[indexPath.row][@"id"]];
                        [CommonCode writeToUserD:yitingguoArr andKey:@"yitingguoxinwenID"];
                    }
                    else{
                        NSMutableArray *yitingguoArr = [NSMutableArray array];
                        [yitingguoArr addObject:self.SouSuodataArrM[indexPath.row][@"id"]];
                        [CommonCode writeToUserD:yitingguoArr andKey:@"yitingguoxinwenID"];
                    }
                }
            }
        }
        [[NSNotificationCenter defaultCenter] postNotificationName:@"gaibianyanse" object:nil];
    }
    else{
        //TODO：发现课堂模块
        faxianModel *model = [self.faxianArrM firstObject];
        if (indexPath.row < [model.data count]) {
//            if ([[self.faxianArrM firstObject][@"data"][indexPath.row][@"is_free"] isEqualToString:@"1"]) {
//                XWAlerLoginView *xw = [[XWAlerLoginView alloc]initWithTitle:@"已购买界面正在开发中"];
//                [xw show];
//            }
//            else if ([[self.faxianArrM firstObject][@"data"][indexPath.row][@"is_free"] isEqualToString:@"0"]){
//                ClassViewController *vc = [ClassViewController new];
//                vc.act_id = [self.faxianArrM firstObject][@"data"][indexPath.row][@"id"];
//                self.hidesBottomBarWhenPushed = YES;
//                [self.navigationController.navigationBar setHidden:YES];
//                [self.navigationController pushViewController:vc animated:YES];
//                self.hidesBottomBarWhenPushed = NO;
//            }
            faxianSubModel *dic = model.data[indexPath.row];
            if ([dic.is_free isEqualToString:@"1"]) {
                zhuboxiangqingVCNew *faxianzhuboVC = [[zhuboxiangqingVCNew alloc]init];
                faxianzhuboVC.jiemuDescription = dic.Description;
                faxianzhuboVC.jiemuFan_num = dic.fan_num;
                faxianzhuboVC.jiemuID = dic.ID;
                faxianzhuboVC.jiemuImages = dic.images;
                faxianzhuboVC.jiemuIs_fan = dic.is_fan;
                faxianzhuboVC.jiemuMessage_num = dic.message_num;
                faxianzhuboVC.jiemuName = dic.name;
                faxianzhuboVC.isfaxian = YES;
                faxianzhuboVC.isClass = YES;
                self.hidesBottomBarWhenPushed=YES;
                [self.navigationController pushViewController:faxianzhuboVC animated:YES];
                self.hidesBottomBarWhenPushed=NO;
                
            }
            //跳转未购买课堂界面
            else if ([dic.is_free isEqualToString:@"0"]){
                ClassViewController *vc = [ClassViewController new];
                vc.act_id = dic.ID;
                self.hidesBottomBarWhenPushed = YES;
                [self.navigationController.navigationBar setHidden:YES];
                [self.navigationController pushViewController:vc animated:YES];
                self.hidesBottomBarWhenPushed = NO;
            }
        }
    }
    
}

#pragma mark - UISearchBarDelegate
//将要开始编辑时的回调
- (void)searchBarTextDidBeginEditing:(UISearchBar *)searchBar {
    [searchBar setShowsCancelButton:YES animated:YES];
    self.SouSuotableView.hidden = YES;
    self.SouSuosousuoTableView.hidden = NO;
    self.faxianTableView.hidden = YES;
}
//点击取消按钮时的回调
- (void)searchBarCancelButtonClicked:(UISearchBar *)searchBar {
    [searchBar setShowsCancelButton:NO animated:YES];
    [searchBar resignFirstResponder];
    self.SouSuotableView.hidden = YES;
    self.SouSuosousuoTableView.hidden = YES;
    self.faxianTableView.hidden = NO;
}
//将要结束编辑时的回调
- (void)searchBarTextDidEndEditing:(UISearchBar *)searchBar {
    self.CurrentSearchKeyWords = searchBar.text;
    [searchBar setShowsCancelButton:NO animated:YES];
    [searchBar resignFirstResponder];
    
}
//搜索按钮点击的回调
- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar {
    self.CurrentSearchKeyWords = searchBar.text;
    [searchBar setShowsCancelButton:NO animated:YES];
    [searchBar resignFirstResponder];
    
    [self.SouSuosousuoArrM addObject:searchBar.text];
    [CommonCode writeToUserD:self.SouSuosousuoArrM andKey:@"lishisousuoci"];
    [self.SouSuosousuoTableView reloadData];
    
    self.SouSuosousuoTableView.hidden = YES;
    self.SouSuotableView.hidden = NO;
    self.faxianTableView.hidden = YES;
    
    [self loadSearchDataWithKeywords:searchBar.text];
}

#pragma mark - Utilities
//发现列表点击主播的跳转事件
- (void)zhuboBtnAction:(faxianBtn *)sender {
    UITableViewCell *cell = (UITableViewCell *)[[sender superview] superview];
    NSIndexPath *indexPath = [self.faxianTableView indexPathForCell:cell];
    //TODO:发现课堂模块
#warning 越界bug,崩溃
    faxianModel *model = [self.faxianArrM firstObject];
    faxianModel *model2 = self.faxianArrM[indexPath.row - [model.data count] + 1 ];
    faxianSubModel *dic = model2.data[sender.tag];
//    NSDictionary *dic = [[NSDictionary alloc]initWithDictionary:[@"data"][sender.tag]];
//    NSDictionary *dic = [[NSDictionary alloc]initWithDictionary:self.faxianArrM[indexPath.row][@"data"][sender.tag]];
    
    zhuboXiangQingVCNewController *faxianzhuboVC = [[zhuboXiangQingVCNewController alloc]init];
    faxianzhuboVC.isfaxian = YES;
    faxianzhuboVC.jiemuDescription = dic.Description;
    faxianzhuboVC.jiemuFan_num = dic.fan_num;
    faxianzhuboVC.jiemuID = dic.ID;
    faxianzhuboVC.jiemuImages = dic.images;
    faxianzhuboVC.jiemuIs_fan = dic.is_fan;
    faxianzhuboVC.jiemuMessage_num = dic.message_num;
    faxianzhuboVC.jiemuName = dic.name;
//    if (indexPath.row > 0){
//        faxianzhuboVC.act_table = @"act";
//    }
//    else{
//        faxianzhuboVC.act_table = @"posts";
//    }
    self.hidesBottomBarWhenPushed=YES;
    [self.navigationController pushViewController:faxianzhuboVC animated:YES];
    self.hidesBottomBarWhenPushed=NO;
    
}
- (void)faxianliebiaoGengDuoAction:(UIButton *)sender{
    UITableViewCell *cell = (UITableViewCell *)[[sender superview] superview];
    NSIndexPath *indexPath = [self.faxianTableView indexPathForCell:cell];
    //TODO:发现课堂模块
    faxianModel *model = [self.faxianArrM firstObject];
    faxianModel *model2 = self.faxianArrM[indexPath.row - [model.data count] + 1];
    if (indexPath.row >= [model.data count]) {
        faxianGengDuoVC *faxiangengduoVC = [[faxianGengDuoVC alloc]init];
        faxiangengduoVC.term_id = [NSString stringWithFormat:@"%@",model2.ID];
        self.hidesBottomBarWhenPushed=YES;
        [self.navigationController pushViewController:faxiangengduoVC animated:YES];
        self.hidesBottomBarWhenPushed=NO;
    }
    else{
        MoreClassViewController *classVC = [[MoreClassViewController alloc]init];
        self.hidesBottomBarWhenPushed=YES;
        [self.navigationController pushViewController:classVC animated:YES];
        self.hidesBottomBarWhenPushed=NO;
    }
//    faxianGengDuoVC *faxiangengduoVC = [[faxianGengDuoVC alloc]init];
//    faxiangengduoVC.term_id = [NSString stringWithFormat:@"%@",self.faxianArrM[indexPath.row][@"id"]];
//    self.hidesBottomBarWhenPushed=YES;
//    [self.navigationController pushViewController:faxiangengduoVC animated:YES];
//    self.hidesBottomBarWhenPushed=NO;
}

- (void)SouSuorightCellBtnAction:(UIButton *)sender {
    UITableViewCell *cell = (UITableViewCell *)[[sender superview] superview];
    NSIndexPath *indexPath = [self.SouSuotableView indexPathForCell:cell];
    
    
    if (SouSuoquanjvIndexPath != nil)
    {
        if (SouSuoquanjvIndexPath != indexPath)
        {
            UITableViewCell *yaoguanbiCell = [self.SouSuotableView cellForRowAtIndexPath:SouSuoquanjvIndexPath];
            //        NSLog(@"%@",yaoguanbiCell.)
            UIButton *yaoguanbiBtn = (UIButton *)[yaoguanbiCell.contentView viewWithTag:SouSuoquanjvIndexPath.row + 1000];
            yaoguanbiBtn.selected = NO;
            SouSuoquanjvIndexPath = indexPath;
            [UIView animateWithDuration:0.3f animations:^{
                yaoguanbiCell.frame = CGRectMake(0, yaoguanbiCell.frame.origin.y, yaoguanbiCell.frame.size.width, yaoguanbiCell.frame.size.height);
            }];
            sender.selected = YES;
            [UIView animateWithDuration:0.3f animations:^{
                cell.frame = CGRectMake(-150.0 / 375 * IPHONE_W, cell.frame.origin.y, cell.frame.size.width, cell.frame.size.height);
            }];
        }else
        {
            if (sender.selected == NO)
            {
                sender.selected = YES;
                SouSuoquanjvIndexPath = indexPath;
                [UIView animateWithDuration:0.3f animations:^{
                    cell.frame = CGRectMake(-150.0 / 375 * IPHONE_W, cell.frame.origin.y, cell.frame.size.width, cell.frame.size.height);
                }];
            }else
            {
                SouSuoquanjvIndexPath = nil;
                sender.selected = NO;
                [UIView animateWithDuration:0.3f animations:^{
                    cell.frame = CGRectMake(0, cell.frame.origin.y, cell.frame.size.width, cell.frame.size.height);
                }];
            }
        }
    }else
    {
        SouSuoquanjvIndexPath = indexPath;
        [UIView animateWithDuration:0.3f animations:^{
            cell.frame = CGRectMake(-150.0 / 375 * IPHONE_W, cell.frame.origin.y, cell.frame.size.width, cell.frame.size.height);
        }];
    }
}

- (void)loadData{
    //TODO:发现课堂模块 /interfaceNew/findIndex
    [NetWorkTool getPaoGuoShouYeSouSuoLieBiao:AvatarAccessToken sccess:^(NSDictionary *responseObject) {
        
        if ([responseObject[@"results"] isKindOfClass:[NSArray class]]){
            self.faxianArrM = [faxianModel mj_objectArrayWithKeyValuesArray:responseObject[@"results"]];
            for (int i = 0; i < self.faxianArrM.count; i ++ ){
                faxianModel *model = self.faxianArrM[i];
                NSString *str = [NSString stringWithFormat:@"%@",model.data];
                if (str.length == 0){
                    [self.faxianArrM removeObjectAtIndex:i];
                }
            }
            [CommonCode writeToUserD:responseObject[@"results"] andKey:@"faxianDataArr"];
            [self.faxianTableView reloadData];
        }
    } failure:^(NSError *error) {
        NSLog(@"error = %@",error);
    }];
    
}

- (void)SouSuoshanglajiazai {
    SouSuonumberPage ++ ;
    [NetWorkTool getPaoguoSearchNewsWithaccessToken:nil
                                            term_id:nil
                                            keyword:self.SouSuosearchBar.text
                                            andPage:[NSString stringWithFormat:@"%d",SouSuonumberPage]
                                           andLimit:@"10"
                                             sccess:^(NSDictionary *responseObject) {
                                                 [self.SouSuotableView.mj_footer endRefreshing];
                                                 if ([responseObject[@"results"] isKindOfClass:[NSArray class]]){
                                                     [self.SouSuodataArrM addObjectsFromArray:responseObject[@"results"]];
                                                     [self.SouSuotableView reloadData];
            
                                                 }
                                                 else{
                                                     self.SouSuotableView.mj_footer.state = MJRefreshStateNoMoreData;
                                                 }
                                             }
                                            failure:^(NSError *error) {
                                                NSLog(@"error = %@",error);
                                                [self.SouSuotableView.mj_footer endRefreshing];
                                            }];
}

- (void)SouSuorefreshData {
    
    SouSuonumberPage = 1;
    [self.SouSuodataArrM removeAllObjects];
    [self.SearchActResultsArrM removeAllObjects];
    NSString *accessToken = nil;
    
    if ([[CommonCode readFromUserD:@"isLogin"]boolValue] == YES) {
        accessToken = [DSE encryptUseDES:ExdangqianUser];
    }
    else{
        accessToken = nil;
    }
    
    if ([self.CurrentSearchKeyWords length]) {
        [NetWorkTool getAllActInfoListWithAccessToken:accessToken
                                                ac_id:nil
                                              keyword:self.CurrentSearchKeyWords
                                              andPage:@"1"
                                             andLimit:@"10"
                                               sccess:^(NSDictionary *responseObject) {
                                                   if ([responseObject[@"results"] isKindOfClass:[NSArray class]])
                                                   {
                                                       self.SearchActResultsArrM = responseObject[@"results"];
                                                   }
                                                   else{
                                                       NSLog(@"没有相关信息");
                                                   }
                                                   [self.SouSuotableView reloadData];
                                                   [self.SouSuotableView.mj_header endRefreshing];
                                               } failure:^(NSError *error) {
                                                   
                                                   NSLog(@"error = %@",error);
                                                   [self.SouSuotableView.mj_header endRefreshing];
                                               }];
    }
    
    [NetWorkTool getPaoguoSearchNewsWithaccessToken:accessToken
                                            term_id:nil
                                            keyword:self.SouSuosearchBar.text
                                            andPage:@"1"
                                           andLimit:@"10"
                                             sccess:^(NSDictionary *responseObject) {
        if ([responseObject[@"results"] isKindOfClass:[NSArray class]]){
            self.SouSuodataArrM = responseObject[@"results"];
        }
        else{
            NSLog(@"没有相关信息");
        }
        [self.SouSuotableView reloadData];
        [self.SouSuotableView.mj_header endRefreshing];
    } failure:^(NSError *error) {
        NSLog(@"error = %@",error);
        [self.SouSuotableView.mj_header endRefreshing];
    }];
    
}

- (void)downloadNewsAction:(UIButton *)sender {
    
    [SVProgressHUD showInfoWithStatus:@"开始下载"];
    [self performSelector:@selector(SVPDismiss) withObject:nil afterDelay:1.0];
    NSMutableDictionary *dic = self.SouSuodataArrM[sender.tag - 100];
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

- (void)tapAction:(UIButton *)sender {
    
    if ([[CommonCode readFromUserD:@"isLogin"]boolValue] == YES) {
        UITableViewCell *cell = (UITableViewCell *)[[sender superview] superview];
        NSIndexPath *indexPath = [self.SouSuotableView indexPathForCell:cell];
        if (sender.selected == NO){
            [NetWorkTool postPaoGuoCancelJieMuGuanZhuWithaccessToken:[DSE encryptUseDES:ExdangqianUser] andAct_id:self.SearchActResultsArrM[indexPath.row][@"id"] sccess:^(NSDictionary *responseObject) {
//                NSMutableDictionary *dict = [self.SearchActResultsArrM[indexPath.row]mutableCopy];
//                [dict setObject:@"0" forKey:@"is_fan"];
//                [self.SearchActResultsArrM replaceObjectAtIndex:indexPath.row withObject:dict];
 
            } failure:^(NSError *error) {
                NSLog(@"error = %@",error);
            }];
            [sender setBackgroundImage:[UIImage imageNamed:@"card_icon_addattention"] forState:UIControlStateNormal];
            sender.selected = YES;
        }
        else{
            
            [NetWorkTool postPaoGuoAddJieMuGuanZhuWithaccessToken:[DSE encryptUseDES:ExdangqianUser] andAct_id:self.SearchActResultsArrM[indexPath.row][@"id"] sccess:^(NSDictionary *responseObject) {
//                NSMutableDictionary *dict = [self.SearchActResultsArrM[indexPath.row]mutableCopy];
//                [dict setObject:@"0" forKey:@"is_fan"];
//                [self.SearchActResultsArrM replaceObjectAtIndex:indexPath.row withObject:dict];
            } failure:^(NSError *error) {
                NSLog(@"error = %@",error);
            }];
            [sender setBackgroundImage:[UIImage imageNamed:@"card_icon_unfollow"] forState:UIControlStateNormal];
            sender.selected = NO;
        }
    }
    else {
        [self loginFirst];
        [self SouSuorefreshData];
    }
    
}

- (void)loginFirst {
    
    UIAlertController *qingshuruyonghuming = [UIAlertController alertControllerWithTitle:@"请先登录" message:nil preferredStyle:UIAlertControllerStyleAlert];
    [qingshuruyonghuming addAction:[UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
    }]];
    [qingshuruyonghuming addAction:[UIAlertAction actionWithTitle:@"去登录" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        LoginVC *loginFriVC = [LoginVC new];
        LoginNavC *loginNavC = [[LoginNavC alloc]initWithRootViewController:loginFriVC];
        [loginNavC.navigationBar setBackgroundColor:[UIColor whiteColor]];
        //        [loginNavC.navigationBar setBackgroundImage:[UIImage imageNamed:@"mian-1"] forBarMetrics:UIBarMetricsDefault];
        loginNavC.navigationBar.tintColor = [UIColor blackColor];
        [self presentViewController:loginNavC animated:YES completion:nil];
    }]];
    
    [self presentViewController:qingshuruyonghuming animated:YES completion:nil];
    
    
}

- (void)loadSearchDataWithKeywords:(NSString *)kewwords {
    [self.SouSuodataArrM removeAllObjects];
    [self.SearchActResultsArrM removeAllObjects];
    
    NSString *accessToken = nil;
    
    if ([[CommonCode readFromUserD:@"isLogin"]boolValue] == YES) {
        accessToken = [DSE encryptUseDES:ExdangqianUser];
    }
    else{
        accessToken = nil;
    }
    //搜索主播、节目
    [NetWorkTool getAllActInfoListWithAccessToken:accessToken
                                            ac_id:nil
                                          keyword:kewwords
                                          andPage:@"1"
                                         andLimit:@"10"
                                           sccess:^(NSDictionary *responseObject) {
                                               if ([responseObject[@"results"] isKindOfClass:[NSArray class]])
                                               {
                                                   self.SearchActResultsArrM = responseObject[@"results"];
                                               }
                                               else{
                                                   NSLog(@"没有相关信息");
                                               }
                                               [self.SouSuotableView reloadData];
                                           } failure:^(NSError *error) {
                                               
                                               NSLog(@"error = %@",error);
                                           }];
    //搜索文章
    [NetWorkTool getPaoguoSearchNewsWithaccessToken:accessToken
                                            term_id:nil
                                            keyword:kewwords
                                            andPage:@"1"
                                           andLimit:@"10"
                                             sccess:^(NSDictionary *responseObject) {
                                             if ([responseObject[@"results"] isKindOfClass:[NSArray class]]){
                                                 self.SouSuodataArrM = responseObject[@"results"];
            
                                             }
                                             else{
                                                 NSLog(@"没有相关信息");
                                             }
                                             [self.SouSuotableView reloadData];
                                         }
                                            failure:^(NSError *error) {
                                            NSLog(@"error = %@",error);
                                        }];
    
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
    //            [[bofangVC shareInstance].newsModel.tableView reloadData];
    [Explayer replaceCurrentItemWithPlayerItem:[[AVPlayerItem alloc]initWithURL:[NSURL URLWithString:self.pushNewsInfo[@"post_mp"]]]];
    ExisRigester = YES;
    ExIsKaiShiBoFang = YES;
    ExwhichBoFangYeMianStr = @"faxianbofang";
    
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
    //  dangqianbofangTable = tableView;
    [bofangVC shareInstance].yinpinzongTime.text = [[bofangVC shareInstance] convertStringWithTime:[dic[@"post_time"] intValue] / 1000];
    
    [bofangVC shareInstance].newsModel.ImgStrjiemu = dic[@"ImgStrjiemu"];
    [bofangVC shareInstance].newsModel.ZhengWenjiemu = dic[@"ZhengWenjiemu"];
    [bofangVC shareInstance].newsModel.praisenum = dic[@"praisenum"];
    //[[bofangVC shareInstance].newsModel.tableView reloadData];
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
    //        [CommonCode writeToUserD:arr andKey:@"zhuyeliebiao"];
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

- (void)zidongjiazai:(NSNotification *)notification{
    [self SouSuoshanglajiazai];
}

- (void)gaibianyanse:(NSNotification *)notification {
    [self.SouSuotableView reloadData];
}

#pragma mark - Setter
- (UITableView *)faxianTableView{
    if (!_faxianTableView){
        _faxianTableView = [[UITableView alloc]initWithFrame:CGRectMake(0, CGRectGetMaxY(self.SouSuosearchBar.frame), IPHONE_W , IPHONE_H - CGRectGetMaxY(self.SouSuosearchBar.frame) - 49) style:UITableViewStylePlain];
        _faxianTableView.delegate = self;
        _faxianTableView.dataSource = self;
        _faxianTableView.tag = 4;
        _faxianTableView.hidden = NO;
        _faxianTableView.tableFooterView = [UIView new];
        _faxianTableView.userInteractionEnabled = YES;
//        _faxianTableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    }
    return _faxianTableView;
}
- (NSMutableArray *)faxianArrM
{
    if (!_faxianArrM)
    {
        _faxianArrM = [[NSMutableArray alloc]init];
    }
    return _faxianArrM;
}
- (UITableView *)SouSuotableView {
    if (!_SouSuotableView){
        _SouSuotableView = [[UITableView alloc]initWithFrame:CGRectMake(0, CGRectGetMaxY(self.SouSuosearchBar.frame), IPHONE_W , IPHONE_H - CGRectGetMaxY(self.SouSuosearchBar.frame)) style:UITableViewStylePlain];
        _SouSuotableView.delegate = self;
        _SouSuotableView.dataSource = self;
        _SouSuotableView.tag = 1;
        _SouSuotableView.hidden = YES;
        _SouSuotableView.mj_header = [MJRefreshNormalHeader headerWithRefreshingBlock:^{
            [self SouSuorefreshData];
        }];
        _SouSuotableView.mj_footer = [MJRefreshAutoStateFooter footerWithRefreshingBlock:^{
            [self SouSuoshanglajiazai];
        }];
        _SouSuotableView.tableFooterView = [UIView new];
    }
    return _SouSuotableView;
}
- (UITableView *)SouSuosousuoTableView
{
    if (!_SouSuosousuoTableView)
    {
        _SouSuosousuoTableView = [[UITableView alloc]initWithFrame:CGRectMake(0, CGRectGetMaxY(self.SouSuosearchBar.frame), IPHONE_W, IPHONE_H - CGRectGetMaxY(self.SouSuosearchBar.frame) - 49) style:UITableViewStylePlain];
        _SouSuosousuoTableView.backgroundColor = [UIColor clearColor];
        _SouSuosousuoTableView.delegate = self;
        _SouSuosousuoTableView.dataSource = self;
        _SouSuosousuoTableView.tag = 2;
        _SouSuosousuoTableView.hidden = YES;
        _SouSuosousuoTableView.tableFooterView = [UIView new];
    }
    return _SouSuosousuoTableView;
}

- (NSMutableArray *)SouSuosousuoArrM {
    if (!_SouSuosousuoArrM) {
        
        if ([[CommonCode readFromUserD:@"lishisousuoci"] isKindOfClass:[NSArray class]]){
            _SouSuosousuoArrM = [NSMutableArray arrayWithArray:[CommonCode readFromUserD:@"lishisousuoci"]];
        }
        else{
            _SouSuosousuoArrM = [NSMutableArray array];
        }
    }
    return _SouSuosousuoArrM;
}

- (NSMutableArray *)SouSuodataArrM{
    if (!_SouSuodataArrM) {
            _SouSuodataArrM = [NSMutableArray array];
    }
    return _SouSuodataArrM;
}

- (NSMutableArray *)SearchActResultsArrM {
    if (!_SearchActResultsArrM) {
        _SearchActResultsArrM = [NSMutableArray array];
    }
    return _SearchActResultsArrM;
}

- (UISearchBar *)SouSuosearchBar {
    if (!_SouSuosearchBar) {
        _SouSuosearchBar = [[UISearchBar alloc]initWithFrame:CGRectMake(20 , 26, IPHONE_W - 40, 44)];
        _SouSuosearchBar.delegate = self;
        _SouSuosearchBar.placeholder = @"搜索新闻、主播、节目";
        _SouSuosearchBar.showsCancelButton = NO;
        _SouSuosearchBar.searchBarStyle = UISearchBarStyleMinimal;
        //        _SouSuosearchBar.userInteractionEnabled = YES;
    }
    return _SouSuosearchBar;
}

- (NSMutableDictionary *)pushNewsInfo {
    if (!_pushNewsInfo) {
        _pushNewsInfo = [NSMutableDictionary new];
    }
    return _pushNewsInfo;
}

@end
