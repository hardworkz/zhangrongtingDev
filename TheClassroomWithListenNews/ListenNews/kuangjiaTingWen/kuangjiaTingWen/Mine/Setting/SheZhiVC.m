//
//  SheZhiVC.m
//  reHeardTheNews
//
//  Created by Pop Web on 16/3/18.
//  Copyright © 2016年 paoguo. All rights reserved.
//

#import "SheZhiVC.h"
#import "AboutViewController.h"
#import "SDImageCache.h"
#import "FontViewController.h"
#import "TimerViewController.h"
#import "bofangVC.h"
#import "BlogViewController.h"
#import "VoteViewController.h"
@interface SheZhiVC ()<UITableViewDataSource,UITableViewDelegate,UIActionSheetDelegate>
{
    NSString *SDImageHuanCun;
}
/* 本页面主tableView */
@property(strong,nonatomic)UITableView *tableView;
/* tableViewLable数据 */
@property(strong,nonatomic)NSArray *dataArr;
/* tableViewImgName数据 */
@property(strong,nonatomic)NSArray *imgNameArr;

@property (strong,nonatomic)NSString *fontSize;

@property (strong,nonatomic)NSString *isNightModelON;// 0：非夜间模式 1：夜间模式

@property (strong, nonatomic) UIButton *newSettingMessageButton;



@end

@implementation SheZhiVC

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.title = @"设置";
    NSString *fontSizeStr = [CommonCode readFromUserD:NEWSFONTKEY];
    if ([fontSizeStr length]) {
        self.fontSize = fontSizeStr;
    }
    else {
        self.fontSize = @"大";
    }
    
    
    //    self.edgesForExtendedLayout = UIRectEdgeNone;
    self.navigationController.navigationBar.titleTextAttributes = @{NSForegroundColorAttributeName: [UIColor blackColor],
                                                                    NSFontAttributeName : [UIFont boldSystemFontOfSize:18]};
    
    SDImageHuanCun = [NSString stringWithFormat:@"%.2fM",[self getCacheSize]];
    
    UISwipeGestureRecognizer *rightTapG = [[UISwipeGestureRecognizer alloc]initWithTarget:self action:@selector(tapGAction)];
    [rightTapG setDirection:UISwipeGestureRecognizerDirectionRight];
    [self.tableView addGestureRecognizer:rightTapG];
    
    UIButton *leftBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [leftBtn setBackgroundImage:[UIImage imageNamed:@"back"] forState:UIControlStateNormal];
    leftBtn.accessibilityLabel = @"返回";
    leftBtn.bounds = CGRectMake(0, 0, 9, 15);
    UIBarButtonItem *back = [[UIBarButtonItem alloc]initWithCustomView:leftBtn];
    [leftBtn addTarget:self action:@selector(back) forControlEvents:UIControlEventTouchUpInside];
    self.navigationItem.leftBarButtonItem = back;
    
    [self.view addSubview:self.tableView];
    self.view.backgroundColor = ColorWithRGBA(244, 246, 247, 1);
    
    self.isNightModelON = [CommonCode readFromUserD:@"isNightModelON"];
    if ([self.isNightModelON isEqualToString:@"1"]) {
        self.isNightModelON = @"1";
    }
    else{
        self.isNightModelON = @"0";
    }
}

-(void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self.navigationController setNavigationBarHidden:NO animated:YES];
    self.hidesBottomBarWhenPushed = YES;
    //TODO:未读消息提醒
    NSArray *feedback = [CommonCode readFromUserD:FEEDBACKFORMEDATAKEY];
    if ([feedback count] && [[CommonCode readFromUserD:FEEDBACKYMESSAGEREAD] isEqualToString:@"NO"]) {
        [self.newSettingMessageButton setHidden:NO];
        [self.newSettingMessageButton setTitle:[NSString stringWithFormat:@"%lu",(unsigned long)[feedback count]] forState:UIControlStateNormal];
    }
    else{
        [self.newSettingMessageButton setHidden:YES];
    }
}
#pragma mark - UITableViewDelegate
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (section == 0){
        return 2;
    }
    else if (section == 1){
        return 3;
    }
    else{
        if ([[CommonCode readFromUserD:@"isLogin"]boolValue] == YES){
            return 4;
        }
        else{
            return 3;
        }
        
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    if (!section){
        return 10;
    }
    else{
        return 0.01;
    }
}

//- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section
//{
//
//    UIView *footerV = [[UIView alloc]initWithFrame:CGRectMake(0, 0, IPHONE_W, 10)];
//    footerV.backgroundColor = [UIColor whiteColor];
//    return footerV;
//}
//- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
//{
//    UIView *footerV = [[UIView alloc]initWithFrame:CGRectMake(0, 0, IPHONE_W, 10)];
//    footerV.backgroundColor = [UIColor whiteColor];
//    return footerV;
//}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
    if (section == 2){
        return 0;
    }
    else{
        return 10;
    }
    
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 49.0 / 667 * IPHONE_H;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 3;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    static NSString *shezhiidentify = @"shezhiidentify";
    UITableViewCell *cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:shezhiidentify];
    if (!cell){
        cell = [tableView dequeueReusableCellWithIdentifier:shezhiidentify];
    }
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    UIImageView *titleImg = [[UIImageView alloc]initWithFrame:CGRectMake(10.0 / 375 * IPHONE_W, 14.0 / 667 * SCREEN_HEIGHT, 15.0 / 375 * IPHONE_W, 15.0)];
    titleImg.image = [UIImage imageNamed:self.imgNameArr[indexPath.section][indexPath.row]];
    titleImg.contentMode = UIViewContentModeScaleAspectFit;
    [cell.contentView addSubview:titleImg];
    UILabel *lab = [[UILabel alloc]initWithFrame:CGRectMake(38.0 / 375 * IPHONE_W, 11.0 / 667 * SCREEN_HEIGHT, 150.0 / 375 * IPHONE_W, 21)];
    lab.text = [NSString stringWithFormat:@"%@",self.dataArr[indexPath.section][indexPath.row]];
    [cell.contentView addSubview:lab];
    lab.font = [UIFont systemFontOfSize:15.0f];
    lab.userInteractionEnabled = YES;
    if ([[CommonCode readFromUserD:@"isLogin"]boolValue] == YES){
        if (indexPath.section == 2 && indexPath.row == 4){
            lab.textColor = [UIColor redColor];
        }
        else{
            lab.textColor = [UIColor blackColor];
        }
    }
    else{
        lab.textColor = [UIColor blackColor];
    }
    
    if (indexPath.section == 0 && indexPath.row == 0){
        UILabel *banBenRightLab = [[UILabel alloc]initWithFrame:CGRectMake(300.0 / 375 * IPHONE_W, 15.0, 63.0 / 375 * IPHONE_W, 11.0)];
        banBenRightLab.textColor = ColorWithRGBA(0, 159, 240, 1);
        banBenRightLab.text = [NSString stringWithFormat:@"%@", [[[NSBundle mainBundle] infoDictionary] valueForKey:@"CFBundleShortVersionString"]];;
        banBenRightLab.font = [UIFont systemFontOfSize:15.0f];
        banBenRightLab.textAlignment = NSTextAlignmentRight;
        [cell.contentView addSubview:banBenRightLab];
    }
    else if (indexPath.section == 0 && indexPath.row == 1){
        UILabel *qingchuhuancunLab = [[UILabel alloc]initWithFrame:CGRectMake(300.0 / 375 * IPHONE_W, 15.0, 63.0 / 375 * IPHONE_W, 11.0)];
        qingchuhuancunLab.textColor = ColorWithRGBA(0, 159, 240, 1);
        qingchuhuancunLab.text = SDImageHuanCun;
        qingchuhuancunLab.font = [UIFont systemFontOfSize:15.0f];
        qingchuhuancunLab.textAlignment = NSTextAlignmentRight;
        [cell.contentView addSubview:qingchuhuancunLab];
    }
    else if (indexPath.section == 1 && indexPath.row == 0){
        UILabel *zitiLab = [[UILabel alloc]initWithFrame:CGRectMake(295.0 / 375 * IPHONE_W, 14.0 / 667 * SCREEN_HEIGHT, 50.0 / 375 * IPHONE_W, 20.0 / 667 * SCREEN_HEIGHT)];
        zitiLab.textAlignment = NSTextAlignmentRight;
        zitiLab.font = [UIFont systemFontOfSize:15.0f];
        zitiLab.textColor = ColorWithRGBA(0, 159, 240, 1);
        zitiLab.text = self.fontSize;
        [cell.contentView addSubview:zitiLab];
    }
    else if (indexPath.section == 1 && indexPath.row == 1){
        UISwitch *shoushiSwi = [[UISwitch alloc]initWithFrame:CGRectMake(315.0 / 375 * IPHONE_W, 10.0 / 667 * SCREEN_HEIGHT, 20.0 / 667 * SCREEN_HEIGHT, 20.0 / 667 * SCREEN_HEIGHT)];
        [cell.contentView addSubview:shoushiSwi];
        if ([[NSUserDefaults standardUserDefaults] boolForKey:@"shoushi"]) {
            [shoushiSwi setOn:YES];
        }
        else {
            [shoushiSwi setOn:NO];
        }
        [shoushiSwi addTarget:self action:@selector(shoushiSwiAction:) forControlEvents:UIControlEventValueChanged];
    }
    else if (indexPath.section == 1 && indexPath.row == 2){
        UISwitch *yejianSwi = [[UISwitch alloc]initWithFrame:CGRectMake(315.0 / 375 * IPHONE_W, 10.0 / 667 * SCREEN_HEIGHT, 20.0 / 667 * SCREEN_HEIGHT, 20.0 / 667 * SCREEN_HEIGHT)];
        if ([self.isNightModelON isEqualToString:@"1"]){
            [yejianSwi setOn:YES];
        }
        else if ([self.isNightModelON isEqualToString:@"0"]){
            [yejianSwi setOn:NO];
        }
        [yejianSwi addTarget:self action:@selector(yejianSwiAction:) forControlEvents:UIControlEventValueChanged];
        [cell.contentView addSubview:yejianSwi];
    }
    else if (indexPath.section == 2 && indexPath.row == 0){
        //未读消息
        NSArray *feedback = [CommonCode readFromUserD:FEEDBACKFORMEDATAKEY];
        if ([feedback count] && [[CommonCode readFromUserD:FEEDBACKYMESSAGEREAD] isEqualToString:@"NO"]) {
            [self.newSettingMessageButton setHidden:NO];
            [self.newSettingMessageButton setTitle:[NSString stringWithFormat:@"%lu",(unsigned long)[feedback count]] forState:UIControlStateNormal];
        }
        else{
            [self.newSettingMessageButton setHidden:YES];
        }
        [cell.contentView addSubview:self.newSettingMessageButton];
    }
    if ((indexPath.section == 0) || (indexPath.section == 1 && (indexPath.row == 1|| indexPath.row == 2))){
        cell.accessoryType = UITableViewCellAccessoryNone;
    }
    else{
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    }
    
    
    
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if(indexPath.section == 0 && indexPath.row == 1){
        UIAlertController *qingdengru = [UIAlertController alertControllerWithTitle:@"是否清除缓存" message:nil preferredStyle:UIAlertControllerStyleAlert];
        [qingdengru addAction:[UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        }]];
        [qingdengru addAction:[UIAlertAction actionWithTitle:@"清除" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            
            NSString *cachPath = [NSSearchPathForDirectoriesInDomains(NSCachesDirectory,NSUserDomainMask, YES) objectAtIndex:0];
            
            NSArray *files = [[NSFileManager defaultManager] subpathsAtPath:cachPath];
            for (NSString *p in files) {
                NSError *error;
                NSString *path = [cachPath stringByAppendingPathComponent:p];
                if ([[NSFileManager defaultManager] fileExistsAtPath:path]) {
                    [[NSFileManager defaultManager] removeItemAtPath:path error:&error];
                }
            }
            SDImageHuanCun = [NSString stringWithFormat:@"%.2fM",[self getCacheSize]];
            [self.tableView reloadData];
        }]];
        [self presentViewController:qingdengru animated:YES completion:^{
        }];
        
    }
    else if (indexPath.section == 1 && indexPath.row == 0){
        self.hidesBottomBarWhenPushed=YES;
        FontViewController *vc = [[UIStoryboard storyboardWithName:@"Main" bundle:nil]instantiateViewControllerWithIdentifier:@"FontViewController"];
        DefineWeakSelf;
        [vc setDidFinishSetFont:^(FontViewController *fontVC) {
            //
            self.fontSize = fontVC.fontSizeStr;
            [weakSelf updateFontSize];
        }];
        
        [self.navigationController pushViewController:vc animated:YES];
    }
//    else if (indexPath.section == 1 && indexPath.row == 1){
//        self.hidesBottomBarWhenPushed=YES;
//        TimerViewController *TimerV = [TimerViewController new];
//        TimerV.isSheZhi = YES;
//        [self.navigationController pushViewController:TimerV animated:YES];
//    }
    else if (indexPath.section == 2 && indexPath.row == 0){
        self.hidesBottomBarWhenPushed=YES;
        BlogViewController *blogVC = [BlogViewController new];
        blogVC.isFeedbackVC = YES;
        [self.navigationController pushViewController:blogVC animated:YES];
    }
    else if (indexPath.section == 2 && indexPath.row == 1){
        AboutViewController *v = [[UIStoryboard storyboardWithName:@"Main" bundle:nil]instantiateViewControllerWithIdentifier:@"AboutViewController"];
        self.hidesBottomBarWhenPushed=YES;
        [self.navigationController pushViewController:v animated:YES];
        return;
    }
    else if (indexPath.section == 2 && indexPath.row == 2){
        //FIXME:听闻(公司)旧版
//        NSString *str = @"https://itunes.apple.com/us/developer/sha-men-pao-guo-wang-luo-you/id883917088?uo=4";
//        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:str]];
//        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"http://itunes.apple.com/WebObjects/MZStore.woa/wa/viewContentsUserReviews?id=883917088&pageNumber=0&sortOrdering=2&type=Purple+Software&mt=8"]];
        //听闻电台
        if ([APPBUNDLEIDENTIFIER isEqualToString:@"com.popwcn.ListenNewsExploreVersion"]){
            NSString *str = @"https://itunes.apple.com/cn/app/ting-wen-dian-tai-ting-zi/id1164861942?mt=8";
            [[UIApplication sharedApplication] openURL:[NSURL URLWithString:str]];
            [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"http://itunes.apple.com/WebObjects/MZStore.woa/wa/viewContentsUserReviews?id=1164861942&pageNumber=0&sortOrdering=2&type=Purple+Software&mt=8"]];
        }
        else{
            NSString *str = @"https://itunes.apple.com/cn/app/ting-wen-zhuan-ye-ban-bu-xiang/id1160650661?mt=8";
            [[UIApplication sharedApplication] openURL:[NSURL URLWithString:str]];
            [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"http://itunes.apple.com/WebObjects/MZStore.woa/wa/viewContentsUserReviews?id=1160650661&pageNumber=0&sortOrdering=2&type=Purple+Software&mt=8"]];
        }
        return;
    }
    else if (indexPath.section == 2 && indexPath.row == 3){
        
        UIActionSheet *ac = [[UIActionSheet alloc]initWithTitle:@"提示" delegate:self cancelButtonTitle:@"取消" destructiveButtonTitle:@"退出登录" otherButtonTitles: nil];
        [ac showInView:self.view];
        
        
    }
}

#pragma mark --- 获取SD图片缓存
- (double)getCacheSize{
    SDImageCache *imageCache = [SDImageCache sharedImageCache];
    NSUInteger fileSize = [imageCache getSize];
    double cacheM = fileSize/1024/1024.0;
    
    return cacheM;
}
#pragma mark --- alert代理事件
- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
    
    if (buttonIndex == 0){
        if ([[CommonCode readFromUserD:@"isWhatLogin"] isEqualToString:@"Weibo"]) {
            [WeiboSDK logOutWithToken:[CommonCode readFromUserD:@"wbtoken"] delegate:self withTag:@"user1"];
        }
        
        [CommonCode writeToUserD:@(NO) andKey:@"isLogin"];
        self.dataArr = @[@[@"当前版本",@"清除缓存"],@[@"字体大小",@"手势控制",@"夜间模式"],@[@"意见反馈",@"关于听闻",@"喜欢，就来评分吧"]];
        self.imgNameArr = @[@[@"shuaxin",@"shanchu"],@[@"font",@"shoushi",@"nightMode"],@[@"yijian",@"guanyu",@"favourable_comment"]];
        [self.tableView reloadData];
        [[NSNotificationCenter defaultCenter] postNotificationName:@"tuichuLoginSeccess" object:nil];
        ExdangqianUser = nil;
        [CommonCode writeToUserD:nil andKey:@"dangqianUserInfo"];
        [CommonCode writeToUserD:nil andKey:@"dangqianUser"];
        [CommonCode writeToUserD:nil andKey:@"isWhatLogin"];
        //设置 我 的未读消息
        [CommonCode writeToUserD:nil andKey:NEWPROMPTFORMEDATAKEY];
        [CommonCode writeToUserD:nil andKey:FEEDBACKFORMEDATAKEY];
        [CommonCode writeToUserD:nil andKey:ADDCRITICISMNUMDATAKEY];
        [CommonCode writeToUserD:nil andKey:FEEDBACKFIRSTUNREADID];
        [CommonCode writeToUserD:nil andKey:TINGYOUQUANFIRSTUNREADID];

         [CommonCode writeToUserD:@"NO" andKey:FEEDBACKYMESSAGEREAD];
         [CommonCode writeToUserD:@"NO" andKey:TINGYOUQUANMESSAGEREAD];
        
        [[NSNotificationCenter defaultCenter] postNotificationName:@"setMyunreadMessageTips" object:nil];
        NSError *error;
        [[NSFileManager defaultManager]removeItemAtPath:ExTouXiangPath error:&error];
        if (error){
            NSLog(@"删除头像文件时错误 = %@",error);
        }
    }
}

#pragma mark --- 事件
- (void)yejianSwiAction:(UISwitch *)sender{
    if (sender.isOn == YES){
        [[UIScreen mainScreen] setBrightness:0.2];
        [CommonCode writeToUserD:@"1" andKey:@"isNightModelON"];
    }
    else{
        [CommonCode writeToUserD:@"0" andKey:@"isNightModelON"];
        [[UIScreen mainScreen] setBrightness:0.8];
    }
}

- (void)shoushiSwiAction:(UISwitch *)sender {
    
    UISwitch *sw = (UISwitch *)sender;
    if (IS_IPAD) {
        UIAlertView *al = [[UIAlertView alloc]initWithTitle:@"提示" message:@"ipad下不支持手势控制" delegate:nil cancelButtonTitle:nil otherButtonTitles:@"知道了", nil];
        [al show];
        sw.on = NO;
        return;
    }
    if ([bofangVC shareInstance].isPlay) {
        if (!sw.on) {
            [[UIDevice currentDevice] setProximityMonitoringEnabled:sw.on];
        }
    }
    [[NSUserDefaults standardUserDefaults] setBool:sw.on forKey:@"shoushi"];
    [[bofangVC shareInstance].tableView reloadData];
}

- (void)back{
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)tapGAction{
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)updateFontSize {
    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:0  inSection:1];
    UITableViewCell *cell = [self.tableView cellForRowAtIndexPath:indexPath];
    UILabel *zitiLab = [[UILabel alloc]initWithFrame:CGRectMake(295.0 / 375 * IPHONE_W, 14.0, 50.0 / 375 * IPHONE_W, 20)];
    zitiLab.textAlignment = NSTextAlignmentRight;
    zitiLab.font = [UIFont systemFontOfSize:15.0f];
    zitiLab.textColor = ColorWithRGBA(0, 159, 240, 1);
    zitiLab.text = self.fontSize;
    [cell.contentView addSubview:zitiLab];
    [self.tableView reloadData];
}

#pragma mark --- 懒加载
- (UITableView *)tableView{
    if (!_tableView){
        _tableView = [[UITableView alloc]initWithFrame:CGRectMake(0, 0, IPHONE_W, IPHONE_H - 64) style:UITableViewStyleGrouped];
        _tableView.backgroundColor = [UIColor clearColor];
        _tableView.dataSource = self;
        _tableView.delegate = self;
        _tableView.tableFooterView = [UIView new];
        
    }
    return _tableView;
}

- (NSArray *)dataArr{
    if (!_dataArr){
        _dataArr = [NSArray array];
        if ([[CommonCode readFromUserD:@"isLogin"]boolValue] == YES){
            _dataArr = @[@[@"当前版本",@"清除缓存"],@[@"字体大小",@"手势控制",@"夜间模式"],@[@"意见反馈",@"关于听闻",@"喜欢，就来评分吧",@"账号注销"]];
        }
        else{
            _dataArr = @[@[@"当前版本",@"清除缓存"],@[@"字体大小",@"手势控制",@"夜间模式"],@[@"意见反馈",@"关于听闻",@"喜欢，就来评分吧"]];
        }
    }
    return _dataArr;
}

- (NSArray *)imgNameArr{
    if (!_imgNameArr){
        _imgNameArr = [NSArray array];
        if ([[CommonCode readFromUserD:@"isLogin"]boolValue] == YES){
            _imgNameArr = @[@[@"shuaxin",@"shanchu"],@[@"font",@"shoushi",@"nightMode"],@[@"yijian",@"guanyu",@"favourable_comment",@"tuichu"]];
        }
        else{
            _imgNameArr = @[@[@"shuaxin",@"shanchu"],@[@"font",@"shoushi",@"nightMode"],@[@"yijian",@"guanyu",@"favourable_comment"]];
        }
    }
    return _imgNameArr;
}

- (UIButton *)newSettingMessageButton {
    if (!_newSettingMessageButton ) {
        _newSettingMessageButton  = [UIButton buttonWithType:UIButtonTypeCustom];
        [_newSettingMessageButton setFrame:CGRectMake(110, 15.0 / 667 * IPHONE_H, 20, 20)];
        [_newSettingMessageButton.layer setMasksToBounds:YES];
        [_newSettingMessageButton.layer setCornerRadius:10.0];
        [_newSettingMessageButton setBackgroundColor:UIColorFromHex(0xf23131)];
        [_newSettingMessageButton.titleLabel setFont:[UIFont systemFontOfSize:11.0]];
    }
    return _newSettingMessageButton;
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
