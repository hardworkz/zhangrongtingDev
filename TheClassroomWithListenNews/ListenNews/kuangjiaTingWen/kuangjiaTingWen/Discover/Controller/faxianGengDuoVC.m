//
//  faxianGengDuoVC.m
//  reHeardTheNews
//
//  Created by 贺楠 on 16/5/31.
//  Copyright © 2016年 paoguo. All rights reserved.
//

#import "faxianGengDuoVC.h"
#import "UIImageView+WebCache.h"
#import "MJRefresh.h"
#import "zhuboxiangqingVCNew.h"
#import "HMSegmentedControl.h"
#import "NSDate+TimeFormat.h"
#import "UIView+tap.h"
#import "LoginVC.h"
#import "LoginNavC.h"

@interface faxianGengDuoVC ()<UIGestureRecognizerDelegate,UITableViewDataSource,UITableViewDelegate>
{
//    NSString *selfGuanZhuId;
    NSMutableArray *isGuanZhuArr;
    NSMutableArray *rankListIsGuanZhuArr;
}
/* 本页面主TableView */
@property(strong,nonatomic)UITableView *tableView;
/* 主数据源 */
@property(strong,nonatomic)NSMutableArray *infoArr;

@property(strong,nonatomic)UITableView *rankTableView;

@property(strong,nonatomic)NSMutableArray *rankListInfoArr;

@property (nonatomic, strong) UIScrollView *scrollView;
@property (nonatomic, strong) HMSegmentedControl *segmentedControl;
@property (assign, nonatomic) BOOL isAchor;


@end

@implementation faxianGengDuoVC

- (void)viewDidLoad {
    [super viewDidLoad];
    self.edgesForExtendedLayout = UIRectEdgeNone;
    self.automaticallyAdjustsScrollViewInsets = NO;
    self.extendedLayoutIncludesOpaqueBars = NO;
    self.title = @"更多";
    self.navigationController.navigationBar.titleTextAttributes = @{NSForegroundColorAttributeName: [UIColor blackColor],
                                                                    NSFontAttributeName : [UIFont boldSystemFontOfSize:18]};
    UIButton *leftBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [leftBtn setBackgroundImage:[UIImage imageNamed:@"title_ic_back"] forState:UIControlStateNormal];
    leftBtn.bounds = CGRectMake(0, 0, 9, 15);
    leftBtn.accessibilityLabel = @"返回";
    UIBarButtonItem *back = [[UIBarButtonItem alloc]initWithCustomView:leftBtn];
    [leftBtn addTarget:self action:@selector(back) forControlEvents:UIControlEventTouchUpInside];
    self.navigationItem.leftBarButtonItem = back;
    self.extendedLayoutIncludesOpaqueBars = YES;
    self.view.backgroundColor = [UIColor whiteColor];
    self.isAchor = ([self.term_id isEqualToString:@"0"]) ? YES : NO;
    self.segmentedControl = [[HMSegmentedControl alloc] initWithSectionTitles:self.isAchor ? @[@"主播推荐", @"主播排行"] : @[@"专栏推荐", @"专栏排行"]];
    self.segmentedControl.autoresizingMask = UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleWidth;
    self.segmentedControl.frame = CGRectMake(0, 0, SCREEN_WIDTH, 40);
    self.segmentedControl.backgroundColor = [UIColor whiteColor];
    self.segmentedControl.segmentEdgeInset = UIEdgeInsetsMake(0, 10, 0, 10);
    self.segmentedControl.selectionStyle = HMSegmentedControlSelectionStyleFullWidthStripe;
    self.segmentedControl.selectionIndicatorLocation = HMSegmentedControlSelectionIndicatorLocationDown;
    self.segmentedControl.selectedSegmentIndex = 0;
    self.segmentedControl.verticalDividerEnabled = YES;
    self.segmentedControl.verticalDividerColor = gTextColorSub;
    self.segmentedControl.selectionIndicatorColor = [UIColor whiteColor];
    self.segmentedControl.selectionIndicatorBoxColor = [UIColor whiteColor];
    self.segmentedControl.selectionIndicatorHeight = 3.0;
    self.segmentedControl.verticalDividerWidth = 1.0f;
    [self.segmentedControl setTitleFormatter:^NSAttributedString *(HMSegmentedControl *segmentedControl, NSString *title, NSUInteger index, BOOL selected) {
        if (selected) {
            NSAttributedString *attString = [[NSAttributedString alloc] initWithString:title attributes:@{NSForegroundColorAttributeName :gMainColor}];
            return attString;
        }
        else{
            NSAttributedString *attString = [[NSAttributedString alloc] initWithString:title attributes:@{NSForegroundColorAttributeName :gTextDownload}];
            return attString;
        }
        
    }];
    [self.segmentedControl addTarget:self action:@selector(segmentedControlChangedValue:) forControlEvents:UIControlEventValueChanged];
    UIView *downLine = [[UIView alloc]initWithFrame:CGRectMake(0, self.segmentedControl.frame.size.height - 1, SCREEN_WIDTH, 0.8)];
    [downLine setBackgroundColor:[UIColor colorWithHue:0.00 saturation:0.00 brightness:0.85 alpha:1.00]];
    [self.segmentedControl addSubview:downLine];
    [self.view addSubview:self.segmentedControl];
    self.scrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 40, SCREEN_WIDTH, SCREEN_HEIGHT - 40 - 64)];
    self.scrollView.backgroundColor = [UIColor whiteColor];
    self.scrollView.pagingEnabled = YES;
    self.scrollView.showsHorizontalScrollIndicator = NO;
    self.scrollView.contentSize = CGSizeMake(SCREEN_WIDTH * 2, SCREEN_HEIGHT - 40 - 64);
    self.scrollView.delegate = self;
    [self.scrollView scrollRectToVisible:CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_HEIGHT - 40 - 64) animated:NO];
    [self.view addSubview:self.scrollView];
    [self.tableView setFrame:CGRectMake(0, 0, SCREEN_WIDTH, self.scrollView.frame.size.height)];
    [self.rankTableView setFrame:CGRectMake(SCREEN_WIDTH + 2, 0, SCREEN_WIDTH - 2, self.scrollView.frame.size.height)];
    
    DefineWeakSelf;
    [self.segmentedControl setIndexChangeBlock:^(NSInteger index) {
        [weakSelf.scrollView scrollRectToVisible:CGRectMake(SCREEN_HEIGHT * index, 0, SCREEN_HEIGHT, SCREEN_HEIGHT - 40 - 64) animated:YES];
    }];
    [self.scrollView addSubview:self.tableView];
    [self.scrollView addSubview:self.rankTableView];
    
    UISwipeGestureRecognizer *rightSwipe = [[UISwipeGestureRecognizer alloc]initWithTarget:self action:@selector(rightSwipeAction)];
    [rightSwipe setDirection:UISwipeGestureRecognizerDirectionRight];
    [self.tableView addGestureRecognizer:rightSwipe];
    
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(ReloadAchordata) name:@"reloadAchordata" object:nil];
    
    self.tableView.mj_header = [MJRefreshNormalHeader headerWithRefreshingBlock:^{
        [self refreshData];
    }];
    self.rankTableView.mj_header = [MJRefreshNormalHeader headerWithRefreshingBlock:^{
        [self rankListRefreshData];
    }];
    [self.tableView.mj_header beginRefreshing];
    [self.rankTableView.mj_header beginRefreshing];
    
}

- (void)viewWillAppear:(BOOL)animated {
    
    [super viewWillAppear:animated];
    [self.navigationController setNavigationBarHidden:NO animated:YES];
    self.hidesBottomBarWhenPushed = YES;
}

- (void)segmentedControlChangedValue:(HMSegmentedControl *)segmentedControl {
    NSLog(@"Selected index %ld (via UIControlEventValueChanged)", (long)segmentedControl.selectedSegmentIndex);
    
}


#pragma mark - UIGestureRecognizerDelegate

- (void)rightSwipeAction {
    [self.navigationController popViewControllerAnimated:YES];
}

//- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch{
//    
//    UITableViewCell *cell = [UITableViewCell new];
//    if ([touch.view isKindOfClass:[cell.contentView class]]) {
//        //放过对单元格点击事件的拦截
//        return NO;
//    }else{
//        return YES;
//    }
//    
//}

#pragma mark - UITableViewDelegate

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    UITableViewCell *cell = (UITableViewCell *)[tableView viewWithTag:indexPath.row + 1000];
//    UILabel *lab = (UILabel *)[cell viewWithTag:indexPath.row + 2000];
    UILabel *lab1 = (UILabel *)[cell viewWithTag:indexPath.row + 3000];
//    UILabel *lab2 = (UILabel *)[cell viewWithTag:indexPath.row + 4000];
//    if (self.isAchor) {
//        if (indexPath.row < 3) {
//            return CGRectGetMaxY(lab2.frame) + 15.0 / 667 * IPHONE_H;
//        }
//        else{
//            return CGRectGetMaxY(lab.frame) + 20.0 / 667 * IPHONE_H;
//        }
//    }
//    else{
        return CGRectGetMaxY(lab1.frame) + 15.0 / 667 * IPHONE_H;
//    }
    
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    if (tableView == self.tableView) {
        return self.infoArr.count;
    }
    else{
        return self.rankListInfoArr.count;
    }
    
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    NSDictionary *dic;
    if (tableView == self.tableView) {
        dic = [[NSDictionary alloc]initWithDictionary:self.infoArr[indexPath.row]];
    }
    else{
        dic = [[NSDictionary alloc]initWithDictionary:self.rankListInfoArr[indexPath.row]];
    }
    zhuboxiangqingVCNew *faxianzhuboVC = [[zhuboxiangqingVCNew alloc]init];
    faxianzhuboVC.jiemuDescription = dic[@"description"];
    faxianzhuboVC.jiemuFan_num = dic[@"fan_num"];
    faxianzhuboVC.jiemuID = dic[@"id"];
    faxianzhuboVC.jiemuImages = dic[@"images"];
    faxianzhuboVC.jiemuIs_fan = dic[@"is_fan"];
    faxianzhuboVC.jiemuMessage_num = dic[@"message_num"];
    faxianzhuboVC.jiemuName = dic[@"name"];
    faxianzhuboVC.isfaxian = YES;
    self.hidesBottomBarWhenPushed=YES;
    [self.navigationController pushViewController:faxianzhuboVC animated:YES];
    self.hidesBottomBarWhenPushed=YES;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    if (tableView == self.tableView) {
        static NSString *jiemuLieBiaoIdentify = @"jiemuLieBiaoIdentify";
        UITableViewCell *cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:jiemuLieBiaoIdentify];
        if (!cell){
            cell = [tableView dequeueReusableCellWithIdentifier:jiemuLieBiaoIdentify];
        }
        //头像
        UIImageView *imgV = [[UIImageView alloc]initWithFrame:CGRectMake(10.0 / 375 * IPHONE_W, 10, 57, 57)];
        if([self.infoArr[indexPath.row][@"images"] rangeOfString:@"/data/upload/"].location !=NSNotFound){
            [imgV sd_setImageWithURL:[NSURL URLWithString:USERPHOTOHTTPSTRINGZhuBo(self.infoArr[indexPath.row][@"images"])] placeholderImage:[UIImage imageNamed:@"user-5"]];
        }
        else{
            [imgV sd_setImageWithURL:[NSURL URLWithString:USERPOTOAD( self.infoArr[indexPath.row][@"images"])] placeholderImage:[UIImage imageNamed:@"user-5"]];
        }
        imgV.layer.cornerRadius = 28.5f;
        imgV.layer.masksToBounds = YES;
        imgV.contentMode = UIViewContentModeScaleAspectFill;
        [cell.contentView addSubview:imgV];
        //名字
        UILabel *titleLab = [[UILabel alloc]initWithFrame:CGRectMake(CGRectGetMaxX(imgV.frame) + 10.0 / 375 * IPHONE_W, 10.0 / 667 * SCREEN_HEIGHT, 200.0 / 375 * IPHONE_W, 15)];
        titleLab.text = self.infoArr[indexPath.row][@"name"];
        titleLab.textColor = gTextDownload;
        titleLab.textAlignment = NSTextAlignmentLeft;
//        titleLab.font = gFontMajor16;
        [titleLab setFont:[UIFont fontWithName:@"Helvetica-Bold" size:16]];
        [cell.contentView addSubview:titleLab];
        //简介
        UILabel *neirongLab = [[UILabel alloc]initWithFrame:CGRectMake(titleLab.frame.origin.x, CGRectGetMaxY(titleLab.frame) + 15, 230.0 / 375 * IPHONE_W, 15)];
        neirongLab.text = [NSString stringWithFormat:@"粉丝:%@  金币:%@  ",self.infoArr[indexPath.row][@"fan_num"],self.infoArr[indexPath.row][@"gold"]];
        neirongLab.textColor = UIColorFromHex(0x999999);
        neirongLab.font = gFontMain12;
        neirongLab.textAlignment = NSTextAlignmentLeft;
        neirongLab.tag = indexPath.row + 2000;
        [cell.contentView addSubview:neirongLab];
        //关注
        UIButton *isSelectBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        isSelectBtn.frame = CGRectMake(IPHONE_W - 60.0 / 375 * IPHONE_W, 10, 50.0 / 375 * IPHONE_W, 25);
        isSelectBtn.contentMode = UIViewContentModeScaleAspectFit;
        isSelectBtn.backgroundColor = gMainColor;
        isSelectBtn.layer.masksToBounds = YES;
        isSelectBtn.layer.cornerRadius = 5.0f;
        isSelectBtn.titleLabel.font = [UIFont systemFontOfSize:13.0f];
//        if ([[CommonCode readFromUserD:@"isLogin"]boolValue] == YES){
//            isSelectBtn.enabled = YES;
//        }
//        else{
//            isSelectBtn.enabled = NO;
//        }
        if ([isGuanZhuArr[indexPath.row] isEqualToString:@"0"]){
            [isSelectBtn setTitle:@"关注" forState:UIControlStateNormal];
            isSelectBtn.selected = YES;
        }
        else{
            [isSelectBtn setTitle:@"取消" forState:UIControlStateNormal];
            isSelectBtn.selected = NO;
        }
        [isSelectBtn addTarget:self action:@selector(attentionAction:) forControlEvents:UIControlEventTouchUpInside];
        [cell.contentView addSubview:isSelectBtn];
        
        if (self.isAchor) {
            //前三条
//            if (indexPath.row < 3) {
//                //new1
//                UILabel *newOne = [[UILabel alloc]initWithFrame:CGRectMake(imgV.frame.origin.x, CGRectGetMaxY(imgV.frame) + 10.0 / 667 * SCREEN_HEIGHT, SCREEN_WIDTH - 60.0 / 375 * IPHONE_W- 10 - imgV.frame.origin.x, 20)];
//                newOne.text = [self.infoArr[indexPath.row][@"news"] firstObject][@"post_title"];
//                newOne.textColor = gTextDownload;
//                newOne.font = gFontMain12;
//                newOne.textAlignment = NSTextAlignmentLeft;
//                newOne.numberOfLines = 2;
//                newOne.tag = indexPath.row + 3000;
//                CGSize size1 = [newOne sizeThatFits:CGSizeMake(newOne.frame.size.width, MAXFLOAT)];
//                newOne.frame = CGRectMake(newOne.frame.origin.x, newOne.frame.origin.y, newOne.frame.size.width, size1.height);
//                [cell.contentView addSubview:newOne];
//                
//                //post_modified
//                UILabel *newsTimeONe = [[UILabel alloc]initWithFrame:CGRectMake(isSelectBtn.frame.origin.x - 10, newOne.frame.origin.y, 60, 15)];
//                //时间戳转时间
//                NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
//                [formatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
//                NSString *timeStr = [self stringWithTime:[([self.infoArr[indexPath.row][@"news"] firstObject][@"post_modified"]) doubleValue]];
//                NSDate *date = [NSDate dateFromString:timeStr];
//                newsTimeONe.text = [date showTimeByTypeA];
//                newsTimeONe.textColor = UIColorFromHex(0x999999);
//                newsTimeONe.font = [UIFont systemFontOfSize:10.0];
//                newsTimeONe.textAlignment = NSTextAlignmentCenter;
//                [cell.contentView addSubview:newsTimeONe];
//                
//                //new2
//                UILabel *newTwo = [[UILabel alloc]initWithFrame:CGRectMake(newOne.frame.origin.x, CGRectGetMaxY(newOne.frame) + 10.0 / 667 * SCREEN_HEIGHT, newOne.frame.size.width, 20)];
//                newTwo.text = [self.infoArr[indexPath.row][@"news"] lastObject][@"post_title"];
//                newTwo.textColor = gTextDownload;
//                newTwo.font = gFontMain12;
//                newTwo.textAlignment = NSTextAlignmentLeft;
//                newTwo.numberOfLines = 2;
//                newTwo.tag = indexPath.row + 4000;
//                CGSize size2 = [newTwo sizeThatFits:CGSizeMake(newTwo.frame.size.width, MAXFLOAT)];
//                newTwo.frame = CGRectMake(newTwo.frame.origin.x, newTwo.frame.origin.y, newTwo.frame.size.width, size2.height);
//                [cell.contentView addSubview:newTwo];
//                
//                //post_modified
//                UILabel *newsTimeTwo = [[UILabel alloc]initWithFrame:CGRectMake(isSelectBtn.frame.origin.x - 10, newTwo.frame.origin.y, 60, 15)];
//                NSDateFormatter* formatter1 = [[NSDateFormatter alloc] init];
//                [formatter1 setDateFormat:@"MM-dd HH:mm:ss"];
//                NSString *timeStr1 = [self stringWithTime:[([self.infoArr[indexPath.row][@"news"] lastObject][@"post_modified"]) integerValue]];
//                NSDate *date1 = [NSDate dateFromString:timeStr1];
//                newsTimeTwo.text = [date1 showTimeByTypeA];
//                newsTimeTwo.textColor = UIColorFromHex(0x999999);
//                newsTimeTwo.font = [UIFont systemFontOfSize:10.0];
//                newsTimeTwo.textAlignment = NSTextAlignmentCenter;
//                [cell.contentView addSubview:newsTimeTwo];
//            }
            //new1
            UILabel *newOne = [[UILabel alloc]initWithFrame:CGRectMake(titleLab.frame.origin.x, CGRectGetMaxY(imgV.frame) + 10.0 / 667 * SCREEN_HEIGHT, SCREEN_WIDTH - titleLab.frame.origin.x - 15, 20)];
            newOne.text = self.infoArr[indexPath.row][@"description"] ;
            newOne.textColor = gTextDownload;
            newOne.font = gFontMain12;
            newOne.textAlignment = NSTextAlignmentLeft;
            newOne.numberOfLines = 2;
            newOne.tag = indexPath.row + 3000;
            CGSize size1 = [newOne sizeThatFits:CGSizeMake(newOne.frame.size.width, MAXFLOAT)];
            newOne.frame = CGRectMake(newOne.frame.origin.x, newOne.frame.origin.y, newOne.frame.size.width, size1.height);
            [cell.contentView addSubview:newOne];
        }
        else{
            //new1
            UILabel *newOne = [[UILabel alloc]initWithFrame:CGRectMake(titleLab.frame.origin.x, CGRectGetMaxY(imgV.frame) + 10.0 / 667 * SCREEN_HEIGHT, SCREEN_WIDTH - titleLab.frame.origin.x - 15, 20)];
            newOne.text = self.infoArr[indexPath.row][@"description"] ;
            newOne.textColor = gTextDownload;
            newOne.font = gFontMain12;
            newOne.textAlignment = NSTextAlignmentLeft;
            newOne.numberOfLines = 2;
            newOne.tag = indexPath.row + 3000;
            CGSize size1 = [newOne sizeThatFits:CGSizeMake(newOne.frame.size.width, MAXFLOAT)];
            newOne.frame = CGRectMake(newOne.frame.origin.x, newOne.frame.origin.y, newOne.frame.size.width, size1.height);
            [cell.contentView addSubview:newOne];
        }
        
        
        cell.tag = indexPath.row + 1000;
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        
        return cell;
    }
    else{
        static NSString *jiemuLieBiaoIdentify = @"jiemupaihangIdentify";
        UITableViewCell *cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:jiemuLieBiaoIdentify];
        if (!cell){
            cell = [tableView dequeueReusableCellWithIdentifier:jiemuLieBiaoIdentify];
        }
        //排行
        UIButton *level = [UIButton buttonWithType:UIButtonTypeCustom];
        [level setFrame:CGRectMake(15.0 / 375 * IPHONE_W, 10, 25, 35)];
        [level setTitleColor:gTextColorBackground forState:UIControlStateNormal];
        if (indexPath.row == 0) {
            [level setImage:[UIImage imageNamed:@"level1"] forState:UIControlStateNormal];
        }
        else if (indexPath.row == 1){
            [level setImage:[UIImage imageNamed:@"level2"] forState:UIControlStateNormal];
        }
        else if (indexPath.row == 2){
            [level setImage:[UIImage imageNamed:@"level3"] forState:UIControlStateNormal];
        }
        else{
           [level setTitle:[NSString stringWithFormat:@"%ld",(long)indexPath.row + 1] forState:UIControlStateNormal];
        }

        [cell.contentView addSubview:level];
        //头像
        UIImageView *imgV = [[UIImageView alloc]initWithFrame:CGRectMake(CGRectGetMaxX(level.frame) + 10, 10, 57, 57)];
        if([self.rankListInfoArr[indexPath.row][@"images"] rangeOfString:@"/data/upload/"].location !=NSNotFound){
            [imgV sd_setImageWithURL:[NSURL URLWithString:USERPHOTOHTTPSTRINGZhuBo(self.rankListInfoArr[indexPath.row][@"images"])] placeholderImage:[UIImage imageNamed:@"user-5"]];
        }
        else{
            [imgV sd_setImageWithURL:[NSURL URLWithString:USERPOTOAD( self.rankListInfoArr[indexPath.row][@"images"])] placeholderImage:[UIImage imageNamed:@"user-5"]];
        }
        imgV.layer.cornerRadius = 28.5f;
        imgV.layer.masksToBounds = YES;
        imgV.contentMode = UIViewContentModeScaleAspectFill;
        [cell.contentView addSubview:imgV];
        //名字
        UILabel *titleLab = [[UILabel alloc]initWithFrame:CGRectMake(CGRectGetMaxX(imgV.frame) + 10.0 / 375 * IPHONE_W, 10.0 / 667 * SCREEN_HEIGHT, 180.0 / 375 * IPHONE_W, 15)];
        titleLab.text = self.rankListInfoArr[indexPath.row][@"name"];
        titleLab.textColor = gTextDownload;
        titleLab.textAlignment = NSTextAlignmentLeft;
//        titleLab.font = gFontMajor16;
        [titleLab setFont:[UIFont fontWithName:@"Helvetica-Bold" size:16]];
        [cell.contentView addSubview:titleLab];
        //简介
        UILabel *neirongLab = [[UILabel alloc]initWithFrame:CGRectMake(titleLab.frame.origin.x, CGRectGetMaxY(titleLab.frame) + 15, 200.0 / 375 * IPHONE_W, 15)];
        neirongLab.text = [NSString stringWithFormat:@"粉丝:%@  金币:%@  ",self.rankListInfoArr[indexPath.row][@"fan_num"],self.rankListInfoArr[indexPath.row][@"gold"]];
        neirongLab.textColor = UIColorFromHex(0x999999);
        neirongLab.font = gFontMain12;
        neirongLab.textAlignment = NSTextAlignmentLeft;
        neirongLab.tag = indexPath.row + 2000;
        [cell.contentView addSubview:neirongLab];
        //关注
        UIButton *isSelectBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        isSelectBtn.frame = CGRectMake(IPHONE_W - 60.0 / 375 * IPHONE_W, 10, 50.0 / 375 * IPHONE_W, 25);
        isSelectBtn.contentMode = UIViewContentModeScaleAspectFit;
        isSelectBtn.backgroundColor = gMainColor;
        isSelectBtn.layer.masksToBounds = YES;
        isSelectBtn.layer.cornerRadius = 5.0f;
        isSelectBtn.titleLabel.font = [UIFont systemFontOfSize:13.0f];
//        if ([[CommonCode readFromUserD:@"isLogin"]boolValue] == YES){
//            isSelectBtn.enabled = YES;
//        }
//        else{
//            isSelectBtn.enabled = NO;
//        }
        if ([rankListIsGuanZhuArr[indexPath.row] isEqualToString:@"0"]){
            [isSelectBtn setTitle:@"关注" forState:UIControlStateNormal];
            isSelectBtn.selected = YES;
        }
        else{
            [isSelectBtn setTitle:@"取消" forState:UIControlStateNormal];
            isSelectBtn.selected = NO;
        }
        [isSelectBtn addTarget:self action:@selector(attentionAction:) forControlEvents:UIControlEventTouchUpInside];
        [cell.contentView addSubview:isSelectBtn];
        
        if (self.isAchor) {
            //前三条
//            if (indexPath.row < 3) {
//                //new1
//                UILabel *newOne = [[UILabel alloc]initWithFrame:CGRectMake(imgV.frame.origin.x, CGRectGetMaxY(imgV.frame) + 10.0 / 667 * SCREEN_HEIGHT, SCREEN_WIDTH - 60.0 / 375 * IPHONE_W- 10 - imgV.frame.origin.x, 20)];
//                newOne.text = [self.rankListInfoArr[indexPath.row][@"news"] firstObject][@"post_title"];
//                newOne.textColor = gTextDownload;
//                newOne.font = gFontMain12;
//                newOne.textAlignment = NSTextAlignmentLeft;
//                newOne.numberOfLines = 2;
//                newOne.tag = indexPath.row + 3000;
//                CGSize size1 = [newOne sizeThatFits:CGSizeMake(newOne.frame.size.width, MAXFLOAT)];
//                newOne.frame = CGRectMake(newOne.frame.origin.x, newOne.frame.origin.y, newOne.frame.size.width, size1.height);
//                [cell.contentView addSubview:newOne];
//                
//                //post_modified
//                UILabel *newsTimeONe = [[UILabel alloc]initWithFrame:CGRectMake(isSelectBtn.frame.origin.x - 10, newOne.frame.origin.y, 60, 15)];
//                //时间戳转时间
//                NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
//                [formatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
//                NSString *timeStr = [self stringWithTime:[([self.rankListInfoArr[indexPath.row][@"news"] firstObject][@"post_modified"]) doubleValue]];
//                NSDate *date = [NSDate dateFromString:timeStr];
//                newsTimeONe.text = [date showTimeByTypeA];
//                newsTimeONe.textColor = UIColorFromHex(0x999999);
//                newsTimeONe.font = [UIFont systemFontOfSize:10.0];
//                newsTimeONe.textAlignment = NSTextAlignmentCenter;
//                [cell.contentView addSubview:newsTimeONe];
//                
//                //new2
//                UILabel *newTwo = [[UILabel alloc]initWithFrame:CGRectMake(newOne.frame.origin.x, CGRectGetMaxY(newOne.frame) + 10.0 / 667 * SCREEN_HEIGHT, newOne.frame.size.width, 20)];
//                newTwo.text = [self.rankListInfoArr[indexPath.row][@"news"] lastObject][@"post_title"];
//                newTwo.textColor = gTextDownload;
//                newTwo.font = gFontMain12;
//                newTwo.textAlignment = NSTextAlignmentLeft;
//                newTwo.numberOfLines = 2;
//                newTwo.tag = indexPath.row + 4000;
//                CGSize size2 = [newTwo sizeThatFits:CGSizeMake(newTwo.frame.size.width, MAXFLOAT)];
//                newTwo.frame = CGRectMake(newTwo.frame.origin.x, newTwo.frame.origin.y, newTwo.frame.size.width, size2.height);
//                [cell.contentView addSubview:newTwo];
//                
//                //post_modified
//                UILabel *newsTimeTwo = [[UILabel alloc]initWithFrame:CGRectMake(isSelectBtn.frame.origin.x - 10, newTwo.frame.origin.y, 60, 15)];
//                NSDateFormatter* formatter1 = [[NSDateFormatter alloc] init];
//                [formatter1 setDateFormat:@"MM-dd HH:mm:ss"];
//                NSString *timeStr1 = [self stringWithTime:[([self.rankListInfoArr[indexPath.row][@"news"] lastObject][@"post_modified"]) integerValue]];
//                NSDate *date1 = [NSDate dateFromString:timeStr1];
//                newsTimeTwo.text = [date1 showTimeByTypeA];
//                newsTimeTwo.textColor = UIColorFromHex(0x999999);
//                newsTimeTwo.font = [UIFont systemFontOfSize:10.0];
//                newsTimeTwo.textAlignment = NSTextAlignmentCenter;
//                [cell.contentView addSubview:newsTimeTwo];
//            }
            
            //new1
            UILabel *newOne = [[UILabel alloc]initWithFrame:CGRectMake(titleLab.frame.origin.x, CGRectGetMaxY(imgV.frame) + 10.0 / 667 * SCREEN_HEIGHT, SCREEN_WIDTH - titleLab.frame.origin.x - 15, 20)];
            newOne.text = self.rankListInfoArr[indexPath.row][@"description"] ;
            newOne.textColor = gTextDownload;
            newOne.font = gFontMain12;
            newOne.textAlignment = NSTextAlignmentLeft;
            newOne.numberOfLines = 2;
            newOne.tag = indexPath.row + 3000;
            CGSize size1 = [newOne sizeThatFits:CGSizeMake(newOne.frame.size.width, MAXFLOAT)];
            newOne.frame = CGRectMake(newOne.frame.origin.x, newOne.frame.origin.y, newOne.frame.size.width, size1.height);
            [cell.contentView addSubview:newOne];
        }
        else{
            //new1
            UILabel *newOne = [[UILabel alloc]initWithFrame:CGRectMake(titleLab.frame.origin.x, CGRectGetMaxY(imgV.frame) + 10.0 / 667 * SCREEN_HEIGHT, SCREEN_WIDTH - titleLab.frame.origin.x - 15, 20)];
            newOne.text = self.rankListInfoArr[indexPath.row][@"description"] ;
            newOne.textColor = gTextDownload;
            newOne.font = gFontMain12;
            newOne.textAlignment = NSTextAlignmentLeft;
            newOne.numberOfLines = 2;
            newOne.tag = indexPath.row + 3000;
            CGSize size1 = [newOne sizeThatFits:CGSizeMake(newOne.frame.size.width, MAXFLOAT)];
            newOne.frame = CGRectMake(newOne.frame.origin.x, newOne.frame.origin.y, newOne.frame.size.width, size1.height);
            [cell.contentView addSubview:newOne];
        }
        
        cell.tag = indexPath.row + 1000;
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        
        return cell;
    }
    
}

#pragma mark - UIScrollViewDelegate

//开始滚动就开始监听直到滚动结束
//- (void)scrollViewDidScroll:(UIScrollView *)scrollView{
//    CGFloat pageWidth = scrollView.frame.size.width;
//    NSInteger page = scrollView.contentOffset.x / pageWidth;
//    [self.segmentedControl setSelectedSegmentIndex:page animated:YES];
//}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
    CGFloat pageWidth = self.scrollView.frame.size.width;
    NSInteger page = self.scrollView.contentOffset.x / pageWidth;
    [self.segmentedControl setSelectedSegmentIndex:page animated:YES];
}


#pragma mark - Utilities

- (void)refreshData{
    [NetWorkTool getPaoguoJieMuLieBiaoWithterm_id:self.term_id andaccessToken:[DSE encryptUseDES:ExdangqianUser] sccess:^(NSDictionary *responseObject) {
        if ([responseObject[@"results"] isKindOfClass:[NSArray class]]){
            [self.infoArr removeAllObjects];
            [self.infoArr addObjectsFromArray:responseObject[@"results"]];
        }
        isGuanZhuArr = [NSMutableArray array];
        for (int i = 0; i < self.infoArr.count; i ++ ){
            [isGuanZhuArr addObject:[NSString stringWithFormat:@"%@",self.infoArr[i][@"is_fan"]]];
        }
        [self.tableView reloadData];
//        [self.segmentedControl setSelectedSegmentIndex:0 animated:YES];
        [self.tableView.mj_header endRefreshing];
    } failure:^(NSError *error) {
        NSLog(@"error = %@",error);
        [self.tableView reloadData];
        [self.segmentedControl setSelectedSegmentIndex:0 animated:YES];
        [self.tableView.mj_header endRefreshing];
    }];
}

- (void)rankListRefreshData{
    [NetWorkTool getFindList_goldWithterm_id:self.term_id andaccessToken:AvatarAccessToken sccess:^(NSDictionary *responseObject) {
        if ([responseObject[@"results"] isKindOfClass:[NSArray class]]){
            [self.rankListInfoArr removeAllObjects];
            [self.rankListInfoArr addObjectsFromArray:responseObject[@"results"]];
        }
        rankListIsGuanZhuArr = [NSMutableArray array];
        for (int i = 0; i < self.rankListInfoArr.count; i ++ ){
            [rankListIsGuanZhuArr addObject:[NSString stringWithFormat:@"%@",self.rankListInfoArr[i][@"is_fan"]]];
        }
        [self.rankTableView reloadData];
//        [self.segmentedControl setSelectedSegmentIndex:1 animated:YES];
        [self.rankTableView.mj_header endRefreshing];
    } failure:^(NSError *error) {
        NSLog(@"error = %@",error);
        [self.rankTableView reloadData];
        [self.segmentedControl setSelectedSegmentIndex:1 animated:YES];
        [self.rankTableView.mj_header endRefreshing];
    }];
}

- (NSString *)stringWithTime:(NSTimeInterval)timestamp {
    //设置时间显示格式
    NSDateFormatter *formatter = [[NSDateFormatter alloc]init];
    [formatter setDateStyle:NSDateFormatterMediumStyle];
    [formatter setTimeStyle:NSDateFormatterShortStyle];
    //先设置好dateStyle、timeStyle,再设置格式
    [formatter setDateFormat:@"YYYY-MM-dd HH:mm:ss"];
    NSDate *date = [NSDate dateWithTimeIntervalSince1970:timestamp];
    //将NSDate按格式转化为对应的时间格式字符串
    NSString *timesString = [formatter stringFromDate:date];
    
    return timesString;
}

- (void)ReloadAchordata{
    [self refreshData];
}

#pragma mark - UIButtonAction

- (void)attentionAction:(UIButton *)sender{
    if ([[CommonCode readFromUserD:@"isLogin"]boolValue] == YES) {
        UITableViewCell *cell = (UITableViewCell *)[[sender superview] superview];
        NSIndexPath *indexPath = [self.tableView indexPathForCell:cell];
        
        if (sender.selected == NO){
            [NetWorkTool postPaoGuoCancelJieMuGuanZhuWithaccessToken:[DSE encryptUseDES:ExdangqianUser] andAct_id:self.infoArr[indexPath.row][@"id"] sccess:^(NSDictionary *responseObject) {
                [SVProgressHUD showSuccessWithStatus:responseObject[@"msg"]];
                [self performSelector:@selector(SVPDismiss) withObject:nil afterDelay:1.0];
                [isGuanZhuArr replaceObjectAtIndex:indexPath.row withObject:@"0"];
                [sender setTitle:@"关注" forState:UIControlStateNormal];
                sender.selected = YES;
                [self refreshData];
            } failure:^(NSError *error) {
                NSLog(@"error = %@",error);
            }];
            
        }
        else{
            
            [NetWorkTool postPaoGuoAddJieMuGuanZhuWithaccessToken:[DSE encryptUseDES:ExdangqianUser] andAct_id:self.infoArr[indexPath.row][@"id"] sccess:^(NSDictionary *responseObject) {
                [SVProgressHUD showSuccessWithStatus:responseObject[@"msg"]];
                [self performSelector:@selector(SVPDismiss) withObject:nil afterDelay:1.0];
                NSLog(@"responseObject = %@",responseObject);
                [isGuanZhuArr replaceObjectAtIndex:indexPath.row withObject:@"1"];
                [sender setTitle:@"取消" forState:UIControlStateNormal];
                sender.selected = NO;
                [self refreshData];
            } failure:^(NSError *error) {
                NSLog(@"error = %@",error);
            }];
            
        }
    }
    else{
        UIAlertController *qingshuruyonghuming = [UIAlertController alertControllerWithTitle:@"温馨提示" message:@"您还没登录，请先登录后操作" preferredStyle:UIAlertControllerStyleAlert];
        [qingshuruyonghuming addAction:[UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        }]];
        [qingshuruyonghuming addAction:[UIAlertAction actionWithTitle:@"登录" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
//            LoginNavC *loginNavC = [LoginNavC new];
            LoginVC *loginFriVC = [LoginVC new];
            LoginNavC *loginNavC = [[LoginNavC alloc]initWithRootViewController:loginFriVC];
            [loginNavC.navigationBar setBackgroundColor:[UIColor whiteColor]];
            //        [loginNavC.navigationBar setBackgroundImage:[UIImage imageNamed:@"mian-1"] forBarMetrics:UIBarMetricsDefault];
            loginNavC.navigationBar.tintColor = [UIColor blackColor];
            [self presentViewController:loginNavC animated:YES completion:nil];
        }]];
        
        [self presentViewController:qingshuruyonghuming animated:YES completion:nil];
    }
    
}

- (void)SVPDismiss {
    [SVProgressHUD dismiss];
}

- (void)back {
    [self.navigationController popViewControllerAnimated:YES];
}

#pragma mark - setter

- (UITableView *)tableView{
    if (!_tableView){
        _tableView = [[UITableView alloc]initWithFrame:CGRectMake(0, 0, IPHONE_W, IPHONE_H - 40 - 64) style:UITableViewStylePlain];
        _tableView.delegate = self;
        _tableView.dataSource = self;
        _tableView.tableFooterView = [UIView new];
    }
    return _tableView;
}

- (NSMutableArray *)infoArr{
    if (!_infoArr){
        _infoArr = [NSMutableArray array];
    }
    return _infoArr;
}

- (UITableView *)rankTableView{
    if (!_rankTableView){
        _rankTableView = [[UITableView alloc]initWithFrame:CGRectMake(0, 0, IPHONE_W, IPHONE_H - 40 - 64) style:UITableViewStylePlain];
        _rankTableView.delegate = self;
        _rankTableView.dataSource = self;
        _rankTableView.tableFooterView = [UIView new];
    }
    return _rankTableView;
}

- (NSMutableArray *)rankListInfoArr{
    if (!_rankListInfoArr){
        _rankListInfoArr = [NSMutableArray array];
    }
    return _rankListInfoArr;
}

- (void)dealloc{
    [[NSNotificationCenter defaultCenter]removeObserver:self];
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
