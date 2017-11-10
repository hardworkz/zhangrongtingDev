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
    int SouSuonumberPage; //搜索结果页数
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

@property (assign, nonatomic) BOOL isSelectedSearchTip;
@end

@implementation faxianVC

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.edgesForExtendedLayout = UIRectEdgeNone;
    
    self.view.backgroundColor = [UIColor whiteColor];
    SouSuonumberPage = 1;
    self.CurrentSearchKeyWords = @"";
    SouSuoquanjvIndexPath = nil;
    
    if ([[CommonCode readFromUserD:@"faxianDataArr"] isKindOfClass:[NSArray class]]){
        self.faxianArrM = [faxianModel mj_objectArrayWithKeyValuesArray:[CommonCode readFromUserD:@"faxianDataArr"]];
        [self.faxianTableView reloadData];
    }
    
    self.faxianTableView.mj_header = [MJRefreshNormalHeader headerWithRefreshingBlock:^{
        [self loadData];
    }];
    
    [self loadData];
    
    [self.view addSubview:self.SouSuotableView];
    [self.view addSubview:self.SouSuosearchBar];
    [self.view addSubview:self.SouSuosousuoTableView];
    [self.view insertSubview:self.faxianTableView atIndex:0];
    
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(reloadClassList) name:ReloadClassList object:nil];
    RegisterNotify(@"loginSccess", @selector(reloadClassList))
    RegisterNotify(@"tuichuLoginSeccess", @selector(reloadClassList))
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
//刷新课堂列表数据
- (void)reloadClassList
{
    [self loadData];
    
    if (self.SearchActResultsArrM.count != 0) {
        [self SouSuorefreshData];
    }
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
    
//    if (tableView == self.SouSuotableView) {
        
        UIView *SearchTableViewSectionFootView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, 10)];
        [SearchTableViewSectionFootView setBackgroundColor:gSubColor];
        return SearchTableViewSectionFootView;
//    }else{
//        return nil;
//    }
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
        }else {
            if ([self.SearchActResultsArrM count] != 0) {
                if (indexPath.section == 0) {
                    if ([self.SearchActResultsArrM[indexPath.row][@"price"] intValue] == 0) {
                        //搜索的节目，主播cell
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
                        
                        //是否关注按钮（节目，主播）
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

                    }else{
                        //课堂cell
                        SearchLessonListTableViewCell *cell = [SearchLessonListTableViewCell cellWithTableView:tableView];
                        cell.dataDict = self.SearchActResultsArrM[indexPath.row];
                        cell.selectionStyle = UITableViewCellSelectionStyleNone;
                        return cell;
                    }
                }
                else {
                    
                    NewsCell *cell = [NewsCell cellWithTableView:tableView];
                    cell.dataDict = self.SouSuodataArrM[indexPath.row];
                    return cell;
                }
            }
            else {
                
                NewsCell *cell = [NewsCell cellWithTableView:tableView];
                cell.dataDict = self.SouSuodataArrM[indexPath.row];
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
                tempHeight = 30;
            }
            else{
                tempHeight = 0;
            }
            //图片
            UIImageView *imgLeft = [[UIImageView alloc]initWithFrame:CGRectMake(IS_IPHONEX?20.0: 20.0 / 375 * IPHONE_W, 15 + tempHeight,IS_IPHONEX?105.0: 105.0 / 375 * IPHONE_W, 105.0 / 375 *IPHONE_W)];
            if (IS_IPAD) {
                [imgLeft setFrame:CGRectMake(20.0 / 375 * IPHONE_W, 15, 105.0 / 375 * IPHONE_W, 70.0 / 375 *IPHONE_W)];
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
            UILabel *classTitle = [[UILabel alloc]initWithFrame:CGRectMake(IS_IPHONEX?CGRectGetMaxX(imgLeft.frame) +5.0 / 375 * 375: CGRectGetMaxX(imgLeft.frame) +5.0 / 375 * IPHONE_W, imgLeft.frame.origin.y,IS_IPHONEX?SCREEN_WIDTH - CGRectGetMaxX(imgLeft.frame) - 70.0 / 375 * 375:SCREEN_WIDTH - CGRectGetMaxX(imgLeft.frame) - 70.0 / 375 * IPHONE_W, IS_IPHONEX?21.0:21.0 / 667 *IPHONE_H)];
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
            UILabel *price = [[UILabel alloc]initWithFrame:CGRectMake(CGRectGetMaxX(classTitle.frame) + 10, classTitle.frame.origin.y,IS_IPHONEX?40.0:40.0 / 375 * IPHONE_W, IS_IPHONEX?21.0:21.0 / 667 *IPHONE_H)];
            price.text = [NSString stringWithFormat:@"¥%@",[NetWorkTool formatFloat:[subModel2.price floatValue]]];
            price.font = gFontMain14;
            price.textColor = gMainColor;
            [cell.contentView addSubview:price];
            
            //简介
            UILabel *describe = [[UILabel alloc]initWithFrame:CGRectMake(classTitle.frame.origin.x,IS_IPHONEX?60.0: 60.0 * 667.0/SCREEN_HEIGHT + tempHeight,IS_IPHONEX?SCREEN_WIDTH - CGRectGetMaxX(imgLeft.frame) - 20.0 / 375 * 375:  SCREEN_WIDTH - CGRectGetMaxX(imgLeft.frame) - 20.0 / 375 * IPHONE_W,IS_IPHONEX?21.0: 21.0 / 667 *IPHONE_H)];
            if (TARGETED_DEVICE_IS_IPHONE_568){
                [describe setFrame:CGRectMake(classTitle.frame.origin.x, CGRectGetMaxY(classTitle.frame), SCREEN_WIDTH - CGRectGetMaxX(imgLeft.frame) - 20.0 / 375 * IPHONE_W, 21.0 / 667 *IPHONE_H)];
            }
            else{
                [describe setFrame:CGRectMake(classTitle.frame.origin.x,IS_IPHONEX?60.0 + tempHeight: 60.0 * 667.0/SCREEN_HEIGHT + tempHeight,IS_IPHONEX?SCREEN_WIDTH - CGRectGetMaxX(imgLeft.frame) - 20.0 / 375 * 375:  SCREEN_WIDTH - CGRectGetMaxX(imgLeft.frame) - 20.0 / 375 * IPHONE_W,IS_IPHONEX?21.0: 21.0 / 667 *IPHONE_H)];
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
                if (IS_IPHONEX) {
                    zhuboBtn.frame = CGRectMake(25.0 + (87.5 * i),40.0,82.5, 82.5);
                }else{
                    zhuboBtn.frame = CGRectMake(25.0 / 375 * IPHONE_W + (87.5 / 375 * IPHONE_W * i), 40.0 / 667 * IPHONE_H, 82.5 / 667 * IPHONE_H,82.5 / 667 * IPHONE_H);
                }
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
                    if (IS_IPHONEX) {
                        zhuboBtn.frame = CGRectMake((120.0) * i, 40.0, 120.0, 120.0);
                    }else{
                        zhuboBtn.frame = CGRectMake((120.0 / 375 * IPHONE_W) * i, 40.0 / 667 * IPHONE_H, 120.0 / 667 * SCREEN_HEIGHT, 120.0 / 667 * SCREEN_HEIGHT);
                    }
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
            if (IS_IPAD) {
                return  172.5 ;
            }else{
                return IS_IPHONEX?167.5 / 667 * 667: 167.5 / 667 * IPHONE_H;
            }
        }
        else if(indexPath.row < [model.data count]){
            if (IS_IPAD) {
                return  172.5;
            }else{
                return IS_IPHONEX?135.0 / 667 * 667: 135.0 / 667 * IPHONE_H;
            }
        }
        else if (indexPath.row == [model.data  count]){
            return IS_IPHONEX?161.0 / 667 * 667: 161.0 / 667 * IPHONE_H;
        }
        else{
            return IS_IPHONEX?200.0 / 667 * 667:200.0 / 667 * IPHONE_H;
        }
    }
}
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    if (tableView == self.SouSuosousuoTableView){
        _isSelectedSearchTip = YES;
        self.SouSuosearchBar.text = self.SouSuosousuoArrM[self.SouSuosousuoArrM.count - indexPath.row - 1];
        [self.SouSuosearchBar setShowsCancelButton:NO animated:YES];
        [self.SouSuosearchBar resignFirstResponder];
        [self.SouSuosousuoArrM addObject:self.SouSuosearchBar.text];
        NSSet *set = [NSSet setWithArray:self.SouSuosousuoArrM];
        self.SouSuosousuoArrM = [NSMutableArray arrayWithArray:[set allObjects]];
        [self.SouSuosousuoTableView reloadData];
        
        self.SouSuosousuoTableView.hidden = YES;
        self.SouSuotableView.hidden = NO;
        
//        [self.SouSuodataArrM removeAllObjects];
        
        [self.SouSuotableView.mj_header beginRefreshing];
    }
    else if(tableView == self.SouSuotableView){
        if ([self.SearchActResultsArrM count]) {
            if (indexPath.section == 0) {
                //TODO:搜索结果，主播或者频道详情页判断跳转
                NSDictionary *dic = [[NSDictionary alloc]initWithDictionary:self.SearchActResultsArrM[indexPath.row]];
                if ([dic[@"price"] intValue] == 0) {
                    zhuboXiangQingVCNewController *faxianzhuboVC = [[zhuboXiangQingVCNewController alloc]init];
                    faxianzhuboVC.jiemuDescription = dic[@"description"];
                    faxianzhuboVC.jiemuFan_num = dic[@"fan_num"];
                    faxianzhuboVC.jiemuID = dic[@"id"];
                    faxianzhuboVC.jiemuImages = dic[@"images"];
                    faxianzhuboVC.jiemuIs_fan = dic[@"is_fan"];
                    faxianzhuboVC.jiemuMessage_num = dic[@"message_num"];
                    faxianzhuboVC.jiemuName = dic[@"name"];
                    faxianzhuboVC.isfaxian = YES;
                    faxianzhuboVC.isClass = NO;
                    [self.navigationController pushViewController:faxianzhuboVC animated:YES];
                }else{
                    NSDictionary *userInfoDict = [CommonCode readFromUserD:@"dangqianUserInfo"];
                    if ([dic[@"is_free"] isEqualToString:@"1"]||[userInfoDict[results][member_type] intValue] == 2||[[CommonCode readFromUserD:@"isIAP"] boolValue] == YES) {
                        zhuboXiangQingVCNewController *faxianzhuboVC = [[zhuboXiangQingVCNewController alloc]init];
                        faxianzhuboVC.jiemuDescription = dic[@"description"];
                        faxianzhuboVC.jiemuFan_num = dic[@"fan_num"];
                        faxianzhuboVC.jiemuID = dic[@"id"];
                        faxianzhuboVC.jiemuImages = dic[@"images"];
                        faxianzhuboVC.jiemuIs_fan = dic[@"is_fan"];
                        faxianzhuboVC.jiemuMessage_num = dic[@"message_num"];
                        faxianzhuboVC.jiemuName = dic[@"name"];
                        faxianzhuboVC.isfaxian = YES;
                        faxianzhuboVC.isClass = YES;
                        [self.navigationController pushViewController:faxianzhuboVC animated:YES];
                    }else{
                        //跳转未购买课堂界面
                        ClassViewController *vc = [ClassViewController shareInstance];
                        vc.jiemuDescription = dic[@"description"];
                        vc.jiemuFan_num = dic[@"fan_num"];
                        vc.jiemuID = dic[@"id"];
                        vc.act_id = dic[@"id"];
                        vc.jiemuImages = dic[@"images"];
                        vc.jiemuIs_fan = dic[@"is_fan"];
                        vc.jiemuMessage_num = dic[@"message_num"];
                        vc.jiemuName = dic[@"name"];
                        vc.listVC = self;
                        [self.navigationController.navigationBar setHidden:YES];
                        [self.navigationController pushViewController:vc animated:YES];
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
                //设置频道类型
                [ZRT_PlayerManager manager].channelType = ChannelTypeDiscoverSearchNewsResult;
                //设置播放器播放内容类型
                [ZRT_PlayerManager manager].playType = ZRTPlayTypeNews;
                //设置播放器播放完成自动加载更多block
                DefineWeakSelf;
                [ZRT_PlayerManager manager].loadMoreList = ^(NSInteger currentSongIndex) {
                    [weakSelf SouSuoshanglajiazai];
                };
                //播放内容切换后刷新对应的播放列表
                [ZRT_PlayerManager manager].playReloadList = ^(NSInteger currentSongIndex) {
                    [weakSelf.SouSuotableView reloadData];
                };
                //设置播放界面打赏view的状态
                [NewPlayVC shareInstance].rewardType = RewardViewTypeNone;
                //判断是否是点击当前正在播放的新闻，如果是则直接跳转
                if ([[CommonCode readFromUserD:@"dangqianbofangxinwenID"] isEqualToString:self.SouSuodataArrM[indexPath.row][@"id"]]){
                    
                    //设置播放器播放数组
                    [ZRT_PlayerManager manager].songList = self.SouSuodataArrM;
//                    [[NewPlayVC shareInstance] reloadInterface];
                    [self.navigationController.navigationBar setHidden:YES];
                    [self.navigationController pushViewController:[NewPlayVC shareInstance] animated:YES];
                }
                else{
                    
                    //设置播放器播放数组
                    [ZRT_PlayerManager manager].songList = self.SouSuodataArrM;
                    //设置新闻ID
                    [NewPlayVC shareInstance].post_id = self.SouSuodataArrM[indexPath.row][@"id"];
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
                //设置频道类型
                [ZRT_PlayerManager manager].channelType = ChannelTypeDiscoverSearchNewsResult;
                //设置播放器播放内容类型
                [ZRT_PlayerManager manager].playType = ZRTPlayTypeNews;
                //设置播放器播放完成自动加载更多block
                DefineWeakSelf;
                [ZRT_PlayerManager manager].loadMoreList = ^(NSInteger currentSongIndex) {
                    [weakSelf SouSuoshanglajiazai];
                };
                //播放内容切换后刷新对应的播放列表
                [ZRT_PlayerManager manager].playReloadList = ^(NSInteger currentSongIndex) {
                    [weakSelf.SouSuotableView reloadData];
                };
                //设置播放界面打赏view的状态
                [NewPlayVC shareInstance].rewardType = RewardViewTypeNone;
                //判断是否是点击当前正在播放的新闻，如果是则直接跳转
                if ([[CommonCode readFromUserD:@"dangqianbofangxinwenID"] isEqualToString:self.SouSuodataArrM[indexPath.row][@"id"]]){
                    
                    //设置播放器播放数组
                    [ZRT_PlayerManager manager].songList = self.SouSuodataArrM;
//                    [[NewPlayVC shareInstance] reloadInterface];
                    [self.navigationController.navigationBar setHidden:YES];
                    [self.navigationController pushViewController:[NewPlayVC shareInstance] animated:YES];
                }
                else{
                    
                    //设置播放器播放数组
                    [ZRT_PlayerManager manager].songList = self.SouSuodataArrM;
                    //设置新闻ID
                    [NewPlayVC shareInstance].post_id = self.SouSuodataArrM[indexPath.row][@"id"];
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
        }
        [[NSNotificationCenter defaultCenter] postNotificationName:@"gaibianyanse" object:nil];
    }
    else{
        //TODO：发现课堂模块
        faxianModel *model = [self.faxianArrM firstObject];
        if (indexPath.row < [model.data count]) {
            faxianSubModel *dic = model.data[indexPath.row];
            NSDictionary *userInfoDict = [CommonCode readFromUserD:@"dangqianUserInfo"];
            if ([dic.is_free isEqualToString:@"1"]||[userInfoDict[results][member_type] intValue] == 2||[[CommonCode readFromUserD:@"isIAP"] boolValue] == YES) {
                zhuboXiangQingVCNewController *faxianzhuboVC = [[zhuboXiangQingVCNewController alloc]init];
                faxianzhuboVC.jiemuDescription = dic.Description;
                faxianzhuboVC.jiemuFan_num = dic.fan_num;
                faxianzhuboVC.jiemuID = dic.ID;
                faxianzhuboVC.jiemuImages = dic.images;
                faxianzhuboVC.jiemuIs_fan = dic.is_fan;
                faxianzhuboVC.jiemuMessage_num = dic.message_num;
                faxianzhuboVC.jiemuName = dic.name;
                faxianzhuboVC.isfaxian = YES;
                faxianzhuboVC.isClass = YES;
                [self.navigationController pushViewController:faxianzhuboVC animated:YES];
                
            }
            //跳转未购买课堂界面
            else if ([dic.is_free isEqualToString:@"0"]){
                ClassViewController *vc = [ClassViewController shareInstance];
                vc.jiemuDescription = dic.Description;
                vc.jiemuFan_num = dic.fan_num;
                vc.jiemuID = dic.ID;
                vc.jiemuImages = dic.images;
                vc.jiemuIs_fan = dic.is_fan;
                vc.jiemuMessage_num = dic.message_num;
                vc.jiemuName = dic.name;
                vc.act_id = dic.ID;
                vc.listVC = self;
                [self.navigationController.navigationBar setHidden:YES];
                [self.navigationController pushViewController:vc animated:YES];
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
    RTLog(@"searchBarTextDidEndEditing");
    [searchBar setShowsCancelButton:NO animated:YES];
    [searchBar resignFirstResponder];
    
}
//搜索按钮点击的回调
- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar {
    self.CurrentSearchKeyWords = searchBar.text;
    [searchBar setShowsCancelButton:NO animated:YES];
    [searchBar resignFirstResponder];
    
    [self.SouSuosousuoArrM addObject:searchBar.text];
    NSSet *set = [NSSet setWithArray:self.SouSuosousuoArrM];
    self.SouSuosousuoArrM = [NSMutableArray arrayWithArray:[set allObjects]];
    
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
    if (indexPath == nil) {
        return;
    }
    //TODO:发现课堂模块
#warning 越界bug,崩溃
    faxianModel *model = [self.faxianArrM firstObject];
    faxianModel *model2 = self.faxianArrM[indexPath.row - [model.data count] + 1];
    faxianSubModel *dic = model2.data[sender.tag];
    
    zhuboXiangQingVCNewController *faxianzhuboVC = [[zhuboXiangQingVCNewController alloc]init];
    faxianzhuboVC.isfaxian = YES;
    faxianzhuboVC.jiemuDescription = dic.Description;
    faxianzhuboVC.jiemuFan_num = dic.fan_num;
    faxianzhuboVC.jiemuID = dic.ID;
    faxianzhuboVC.jiemuImages = dic.images;
    faxianzhuboVC.jiemuIs_fan = dic.is_fan;
    faxianzhuboVC.jiemuMessage_num = dic.message_num;
    faxianzhuboVC.jiemuName = dic.name;
    faxianzhuboVC.post_content = dic.post_content;
//    self.hidesBottomBarWhenPushed=YES;
    [self.navigationController pushViewController:faxianzhuboVC animated:YES];
//    self.hidesBottomBarWhenPushed=NO;
    
}
- (void)faxianliebiaoGengDuoAction:(UIButton *)sender{
    UITableViewCell *cell = (UITableViewCell *)[[sender superview] superview];
    NSIndexPath *indexPath = [self.faxianTableView indexPathForCell:cell];
    RTLog(@"%ld",indexPath.row);
    if (indexPath.row == 0) {
        MoreClassViewController *classVC = [[MoreClassViewController alloc]init];
        [self.navigationController pushViewController:classVC animated:YES];
    }else{
        faxianModel *model = self.faxianArrM[indexPath.row - 2];
        faxianGengDuoVC *faxiangengduoVC = [[faxianGengDuoVC alloc]init];
        faxiangengduoVC.term_id = model.ID;
        [self.navigationController pushViewController:faxiangengduoVC animated:YES];
    }
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
        [self.faxianTableView.mj_header endRefreshing];
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
        [self.faxianTableView.mj_header endRefreshing];
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
                                                 if ([responseObject[results] isKindOfClass:[NSArray class]]){
                                                     NSArray *array = responseObject[results];
                                                     [self.SouSuodataArrM addObjectsFromArray:array];
                                                     [self.SouSuotableView reloadData];
                                                     if ([ZRT_PlayerManager manager].channelType == ChannelTypeDiscoverSearchNewsResult) {
                                                         [ZRT_PlayerManager manager].songList = self.SouSuodataArrM;
                                                     }
                                                     if (array.count!= 0) {
                                                         self.SouSuotableView.mj_footer.state = MJRefreshStateIdle;
                                                     }
            
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
    
    RTLog(@"SouSuorefreshData");
    if ([self.SouSuosearchBar.text length]) {
        [NetWorkTool getAllActInfoListWithAccessToken:accessToken
                                                ac_id:nil
                                              keyword:self.SouSuosearchBar.text
                                              andPage:@"1"
                                             andLimit:@"10"
                                               sccess:^(NSDictionary *responseObject) {
                                                   if ([responseObject[status] intValue] == 1)
                                                   {
//                                                       self.SearchActResultsArrM = responseObject[@"results"];
                                                       
                                                       //主播，节目
                                                       NSArray *actArray = responseObject[results][@"act"];
                                                       //课程
                                                       NSArray *lessonArray = responseObject[results][@"lesson"];
                                                       self.SearchActResultsArrM = [NSMutableArray arrayWithArray:lessonArray];
                                                       //拼接搜索结果
                                                       [self.SearchActResultsArrM addObjectsFromArray:actArray];
                                                   }
                                                   else{
                                                       RTLog(@"没有相关信息");
                                                   }
                                                   [self.SouSuotableView reloadData];
                                                   [self.SouSuotableView.mj_header endRefreshing];
                                               } failure:^(NSError *error) {
                                                   
                                                   NSLog(@"error = %@",error);
                                                   [self.SouSuotableView.mj_header endRefreshing];
                                               }];
    }
    //搜索新闻
    [NetWorkTool getPaoguoSearchNewsWithaccessToken:AvatarAccessToken
                                            term_id:nil
                                            keyword:self.SouSuosearchBar.text
                                            andPage:@"1"
                                           andLimit:@"10"
                                             sccess:^(NSDictionary *responseObject) {
        if ([responseObject[results] isKindOfClass:[NSArray class]]){
            NSArray *array = responseObject[results];
            self.SouSuodataArrM = [NSMutableArray arrayWithArray:array];
            if ([ZRT_PlayerManager manager].channelType == ChannelTypeDiscoverSearchNewsResult) {
                [ZRT_PlayerManager manager].songList = self.SouSuodataArrM;
            }
            if (array.count!= 0) {
                self.SouSuotableView.mj_footer.state = MJRefreshStateIdle;
            }
        }
        else{
            RTLog(@"没有相关信息");
            self.SouSuotableView.mj_footer.state = MJRefreshStateNoMoreData;
        }
        [self.SouSuotableView reloadData];
        [self.SouSuotableView.mj_header endRefreshing];
    } failure:^(NSError *error) {
        NSLog(@"error = %@",error);
        [self.SouSuotableView.mj_header endRefreshing];
    }];
    
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
    //搜索主播、节目,课堂
    [NetWorkTool getAllActInfoListWithAccessToken:AvatarAccessToken
                                            ac_id:nil
                                          keyword:kewwords
                                          andPage:@"1"
                                         andLimit:@"10"
                                           sccess:^(NSDictionary *responseObject) {
                                               if ([responseObject[status] intValue] == 1)
                                               {
                                                   //                                                   self.SearchActResultsArrM = responseObject[results];
                                                   //主播，节目
                                                   NSArray *actArray = responseObject[results][@"act"];
                                                   //课程
                                                   NSArray *lessonArray = responseObject[results][@"lesson"];
                                                   self.SearchActResultsArrM = [NSMutableArray arrayWithArray:lessonArray];
                                                   //拼接搜索结果
                                                   [self.SearchActResultsArrM addObjectsFromArray:actArray];
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
/**
 根据推送ID获取新闻详情数据
 */
- (void)getPushNewsDetail{
    DefineWeakSelf;
    [NetWorkTool getpostinfoWithpost_id:[[NSUserDefaults standardUserDefaults]valueForKey:@"pushNews"] andpage:nil andlimit:nil sccess:^(NSDictionary *responseObject) {
        if ([responseObject[status] integerValue] == 1) {
            weakSelf.pushNewsInfo = [responseObject[results] mutableCopy];
            [NetWorkTool getAllActInfoListWithAccessToken:nil ac_id:weakSelf.pushNewsInfo[@"post_news"] keyword:nil andPage:nil andLimit:nil sccess:^(NSDictionary *responseObject) {
                if ([responseObject[status] integerValue] == 1){
                    [weakSelf.pushNewsInfo setObject:[responseObject[results] firstObject] forKey:@"post_act"];
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
/**
 通知消息点击跳转新闻详情界面播放
 */
- (void)presentPushNews
{
    [ZRT_PlayerManager manager].songList = @[self.pushNewsInfo];
    [ZRT_PlayerManager manager].currentSong = self.pushNewsInfo;
    //设置播放器播放内容类型
    [ZRT_PlayerManager manager].playType = ZRTPlayTypeNews;
    [NewPlayVC shareInstance].rewardType = RewardViewTypeNone;
    [ZRT_PlayerManager manager].channelType = ChannelTypeChannelNone;
    [[NewPlayVC shareInstance] playFromIndex:0];
    [self.navigationController.navigationBar setHidden:YES];
    [self.navigationController pushViewController:[NewPlayVC shareInstance] animated:YES];
}
/**
 点击中心按钮跳转上一次记录新闻详情界面播放
 */
- (void)skipToLastNews
{
    [ZRT_PlayerManager manager].songList = [CommonCode readFromUserD:NewPlayVC_PLAYLIST];
    [ZRT_PlayerManager manager].currentSong = [CommonCode readFromUserD:NewPlayVC_THELASTNEWSDATA];
    //设置播放器播放内容类型
    [ZRT_PlayerManager manager].playType = ZRTPlayTypeNews;
    [NewPlayVC shareInstance].rewardType = RewardViewTypeNone;
    [ZRT_PlayerManager manager].channelType = [[CommonCode readFromUserD:NewPlayVC_PLAY_CHANNEL] intValue];
    [[NewPlayVC shareInstance] playFromIndex:[[CommonCode readFromUserD:NewPlayVC_PLAY_INDEX] integerValue]];
    [self.navigationController.navigationBar setHidden:YES];
    [self.navigationController pushViewController:[NewPlayVC shareInstance] animated:YES];
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
        _SouSuotableView.separatorStyle = UITableViewCellSeparatorStyleNone;
        _SouSuotableView.mj_header = [MJRefreshNormalHeader headerWithRefreshingBlock:^{
            SouSuonumberPage = 1;
            [self SouSuorefreshData];
        }];
        _SouSuotableView.mj_footer = [MJRefreshAutoNormalFooter footerWithRefreshingBlock:^{
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
        
//        UIButton *cleanBtn = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, 49)];
//        [cleanBtn setTitle:@"清空搜索历史" forState:UIControlStateNormal];
//        [cleanBtn addTarget:self action:@selector(cleanHistorySearchWord)];
        
        _SouSuosousuoTableView.tableFooterView = [UIView new];
    }
    return _SouSuosousuoTableView;
}
//- (void)cleanHistorySearchWord
//{
//    [self.SouSuosousuoArrM removeAllObjects];
//    [CommonCode writeToUserD:self.SouSuosousuoArrM andKey:@"lishisousuoci"];
//    [self.SouSuosousuoTableView reloadData];
//}
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
        _SouSuosearchBar = [[UISearchBar alloc]initWithFrame:CGRectMake(20 , 46, IPHONE_W - 40, 44)];
        _SouSuosearchBar.delegate = self;
        _SouSuosearchBar.placeholder = @"搜索新闻、主播、专栏、课堂";
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
