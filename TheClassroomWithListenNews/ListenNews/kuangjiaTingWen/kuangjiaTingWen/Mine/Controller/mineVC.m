//
//  mineVC.m
//  kuangjiaTingWen
//
//  Created by 贺楠 on 16/6/3.
//  Copyright © 2016年 贺楠. All rights reserved.
//

#import "mineVC.h"
#import "SheZhiVC.h"
#import "yingyongtuijianVC.h"
#import "bofangVC.h"
#import "wodeguanzhuVC.h"
#import "LoginNavC.h"
#import "LoginVC.h"
#import "gerenzhuyeVC.h"
#import "DownloadViewController.h"
#import "FriendsNewsViewController.h"
#import "AppDelegate.h"
#import "BlogViewController.h"
#import "UIView+tap.h"
#import "SingleWebViewController.h"
#import "HelpAndFeedbackViewController.h"
#import "TTTAttributedLabel.h"
#import "PayViewController.h"
#import "MyCollectionViewController.h"

#define KunitTime 1.0

typedef void(^animateBlock)();

@interface mineVC ()<UITableViewDataSource,UITableViewDelegate,UIGestureRecognizerDelegate>
{
    //animateBlock Arr
    NSMutableArray * _animateArr;
}
@property(strong,nonatomic)UITableView *tableView;

@property (strong, nonatomic) NSMutableDictionary *pushNewsInfo;

@property (strong, nonatomic) UIButton *newPersonMessageButton;

@property (strong, nonatomic) UIButton *newFriendMessageButton;

@property (strong, nonatomic) UIButton *newSettingMessageButton;

@property (strong, nonatomic) UIView *signInView;

@property (strong, nonatomic) UIImageView *signInImageView;

@property (strong, nonatomic) NSTimer * time;

@property (assign, nonatomic) BOOL isSigned;

@property (strong, nonatomic) UIView *experienceView;
@property (strong, nonatomic) UILabel *exp;


@end

@implementation mineVC

- (void)viewDidLoad {
    [super viewDidLoad];
//    self.navigationItem.title = @"我";
    DefineWeakSelf;
    APPDELEGATE.woSkipToPlayingVC = ^ (NSString *pushNewsID){
        
        if (ExIsClassVCPlay && Exact_id != nil) {
            NSMutableDictionary *dict = [CommonCode readFromUserD:@"is_free_data"];
            ClassViewController *vc = [ClassViewController shareInstance];
            vc.jiemuDescription = dict[@"jiemuDescription"];
            vc.jiemuFan_num = dict[@"jiemuFan_num"];
            vc.jiemuID = dict[@"jiemuID"];
            vc.jiemuImages = dict[@"jiemuImages"];
            vc.jiemuIs_fan = dict[@"jiemuIs_fan"];
            vc.jiemuMessage_num = dict[@"jiemuMessage_num"];
            vc.jiemuName = dict[@"jiemuName"];
            vc.act_id = Exact_id;
            vc.listVC = self;
            [weakSelf.navigationController.navigationBar setHidden:YES];
            [weakSelf.navigationController pushViewController:vc animated:YES];
            return;
        }
        
        if ([pushNewsID isEqualToString:@"NO"]) {
            //上一次听过的新闻
            if (ExIsKaiShiBoFang) {
                self.hidesBottomBarWhenPushed = YES;
                [self.navigationController pushViewController:[bofangVC shareInstance] animated:YES];
                [[bofangVC shareInstance].tableView reloadData];
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
                    [[bofangVC shareInstance].tableView reloadData];
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
    
    self.view.backgroundColor = [UIColor whiteColor];
    [self.view addSubview:self.tableView];
    [self.view addSubview:self.signInView];
    _animateArr=@[].mutableCopy;
    //+ 经验
    _experienceView = [[UIView alloc]initWithFrame:CGRectMake(SCREEN_WIDTH - 63, SCREEN_HEIGHT - 160, 40, 40)];
    _experienceView.alpha=0;
    [self.view addSubview:_experienceView];
    UILabel *exptitle = [[UILabel alloc]initWithFrame:CGRectMake(0, 0, 35, 20)];
    [exptitle setText:@"经验"];
    [exptitle setFont:[UIFont systemFontOfSize:10.0]];
    [exptitle setTextColor:gTextDownload];
    [_experienceView addSubview:exptitle];
    _exp = [[UILabel alloc]initWithFrame:CGRectMake(5, 15, 35, 20)];
    //每日签到 +2经验
    [_exp setText:@"+2"];
    [_exp setFont:[UIFont systemFontOfSize:10.0]];
    [_exp setTextColor:UIColorFromHex(0xF67825)];
    [_experienceView addSubview:_exp];
    
//    dispatch_queue_t queue = dispatch_queue_create("kk", DISPATCH_QUEUE_SERIAL);
//    dispatch_async(queue, ^{
//        NSTimer * time = [NSTimer scheduledTimerWithTimeInterval:0.8 target:self selector:@selector(animat) userInfo:nil repeats:YES];
//        [time fire];
//        self.time = time;
//        //将计时器添加到主线程，拖拽其他控件不会让计时器停止运行
//        [[NSRunLoop currentRunLoop] addTimer:time forMode:NSRunLoopCommonModes];
//    });
//    dispatch_sync(dispatch_get_main_queue(), ^(){
//        // 这里的代码会在主线程执行
//        NSTimer * time = [NSTimer scheduledTimerWithTimeInterval:0.8 target:self selector:@selector(animat) userInfo:nil repeats:YES];
//        [time fire];
//        self.time = time;
//    });
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(loginAlert:) name:@"loginAlert" object:nil];
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(updateUserInfo:) name:@"updateUserInfo" object:nil];
    
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
//    [self.navigationController setNavigationBarHidden:NO animated:YES];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
//    self.navBarBgAlpha = @"0.0";
    [self.navigationController setNavigationBarHidden:YES animated:YES];
    if ([[CommonCode readFromUserD:@"isLogin"]boolValue] == YES){
        self.signInView.hidden = NO;
        NSDictionary *userInfo = [CommonCode readFromUserD:@"dangqianUserInfo"];
        if ([userInfo[@"results"][@"sign"] isEqualToString:@"0"]) {
            self.isSigned = NO;
            [_signInImageView setImage:[UIImage imageNamed:@"sign_in"]];
            //TODO:未签到时添加动画
            CAKeyframeAnimation *anim = [CAKeyframeAnimation animation];
            anim.keyPath = @"position";
            anim.path = [UIBezierPath bezierPathWithOvalInRect:CGRectMake(SCREEN_WIDTH - 23 - 18, SCREEN_HEIGHT - 85 - 60, 0, 10)].CGPath;
            anim.repeatCount = HUGE_VALF;
            anim.duration = 1.0;
            anim.calculationMode = kCAAnimationPaced;//动画连续效果
            [self.signInView.layer addAnimation:anim forKey:nil];
            
        }
        else{
            self.isSigned = YES;
            [_signInImageView setImage:[UIImage imageNamed:@"sign_ined"]];
        }
    }
    else{
        self.signInView.hidden = YES;
    }
//    [self.tableView reloadData];
    [self getUnreadMessage];
    
}

#pragma mark - Utilities

- (void)updateUserInfo:(NSNotification *)notification{
    //获取个人经验值，听币，金币,签到情况以及个人信息，粉丝数，关注数
    NSDictionary *userInfo = [CommonCode readFromUserD:@"dangqianUserInfo"];
    if ([[CommonCode readFromUserD:@"isWhatLogin"] isEqualToString:@"QQ"]){
        ExdangqianUser = [CommonCode readFromUserD:@"user_login"];
    }
    else if ([[CommonCode readFromUserD:@"isWhatLogin"] isEqualToString:@"ShouJi"]){
        ExdangqianUser = [CommonCode readFromUserD:@"dangqianUser"];
    }
    else if ([[CommonCode readFromUserD:@"isWhatLogin"] isEqualToString:@"WeiBo"]){
        ExdangqianUser = [CommonCode readFromUserD:@"user_login"];
    }
    else if ([[CommonCode readFromUserD:@"isWhatLogin"] isEqualToString:@"weixin"]){
        ExdangqianUser = [CommonCode readFromUserD:@"user_login"];
    }
//    ExdangqianUser = [CommonCode readFromUserD:userInfo[@"results"][@"user_login"]];
    [NetWorkTool getMyuserinfoWithaccessToken:AvatarAccessToken user_id:userInfo[@"results"][@"id"]  sccess:^(NSDictionary *responseObject) {
        if ([responseObject[@"msg"] isEqualToString:@"获取成功!"]) {
            if ([[CommonCode readFromUserD:@"isWhatLogin"] isEqualToString:@"QQ"]){
                ExdangqianUser = responseObject[@"results"][@"user_login"];
            }
            else if ([[CommonCode readFromUserD:@"isWhatLogin"] isEqualToString:@"ShouJi"]){
                ExdangqianUser = responseObject[@"results"][@"user_phone"];
            }
            else if ([[CommonCode readFromUserD:@"isWhatLogin"] isEqualToString:@"WeiBo"]){
                ExdangqianUser = responseObject[@"results"][@"user_login"];
            }
            else if ([[CommonCode readFromUserD:@"isWhatLogin"] isEqualToString:@"weixin"]){
                ExdangqianUser = responseObject[@"results"][@"user_login"];
            }
//            ExdangqianUser = responseObject[@"results"][@"user_login"];
            [CommonCode writeToUserD:ExdangqianUser andKey:@"dangqianUser"];
            [CommonCode writeToUserD:responseObject[@"results"][@"id"] andKey:@"dangqianUserUid"];
            [CommonCode writeToUserD:@(YES) andKey:@"isLogin"];
            [CommonCode writeToUserD:responseObject andKey:@"dangqianUserInfo"];
            //拿到图片
            UIImage *userAvatar = [UIImage imageWithData:[NSData dataWithContentsOfURL:[NSURL URLWithString:USERPHOTOHTTPSTRING(responseObject[@"results"][@"avatar"])]]];
            NSString *path_sandox = NSHomeDirectory();
            //设置一个图片的存储路径
            NSString *avatarPath = [path_sandox stringByAppendingString:@"/Documents/userAvatar.png"];
            //把图片直接保存到指定的路径（同时应该把图片的路径imagePath存起来，下次就可以直接用来取）
            [UIImagePNGRepresentation(userAvatar) writeToFile:avatarPath atomically:YES];
            [self.tableView reloadData];
        }
    } failure:^(NSError *error) {
        NSLog(@"%@",error);
    }];
}

- (void)dianjitouxiangshijian {
    if ([[CommonCode readFromUserD:@"isLogin"]boolValue] == YES){
        gerenzhuyeVC *gerenzhuye = [gerenzhuyeVC new];
        gerenzhuye.isMypersonalPage = YES;
        gerenzhuye.isNewsComment = NO;
        gerenzhuye.user_nicename = [CommonCode readFromUserD:@"dangqianUserInfo"][@"results"][@"user_nicename"];
        gerenzhuye.sex = [CommonCode readFromUserD:@"dangqianUserInfo"][@"results"][@"sex"];
        gerenzhuye.signature =  [CommonCode readFromUserD:@"dangqianUserInfo"][@"results"][@"signature"];
        gerenzhuye.user_login = ExdangqianUser;
        gerenzhuye.fan_num = @"0";
        gerenzhuye.guan_num = @"0";
        self.hidesBottomBarWhenPushed=YES;
        [self.navigationController pushViewController:gerenzhuye animated:YES];
        self.hidesBottomBarWhenPushed=NO;
    }
    else{
        LoginVC *loginFriVC = [LoginVC new];
        LoginNavC *loginNavC = [[LoginNavC alloc]initWithRootViewController:loginFriVC];
        [loginNavC.navigationBar setBackgroundColor:[UIColor whiteColor]];
        //        [loginNavC.navigationBar setBackgroundImage:[UIImage imageNamed:@"mian-1"] forBarMetrics:UIBarMetricsDefault];
        loginNavC.navigationBar.tintColor = [UIColor blackColor];
        [self presentViewController:loginNavC animated:YES completion:nil];
    }
}

- (void)payButtonAction:(UIButton *)sender{
    self.hidesBottomBarWhenPushed=YES;
    [self.navigationController pushViewController:[PayViewController new] animated:YES];
    self.hidesBottomBarWhenPushed=NO;
}

- (void)loginFirst {
    
    UIAlertController *qingshuruyonghuming = [UIAlertController alertControllerWithTitle:@"温馨提示\n 您还没登录，请先登录后操作" message:nil preferredStyle:UIAlertControllerStyleAlert];
    qingshuruyonghuming.accessibilityLabel = @"温馨提示 您还没登录，请先登录后操作 取消、登录";
    [qingshuruyonghuming addAction:[UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
    }]];
    [qingshuruyonghuming addAction:[UIAlertAction actionWithTitle:@"登录" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        LoginVC *loginFriVC = [LoginVC new];
        LoginNavC *loginNavC = [[LoginNavC alloc]initWithRootViewController:loginFriVC];
        [loginNavC.navigationBar setBackgroundColor:[UIColor whiteColor]];
//        [loginNavC.navigationBar setBackgroundImage:[UIImage imageNamed:@"mian-1"] forBarMetrics:UIBarMetricsDefault];
        loginNavC.navigationBar.tintColor = [UIColor blackColor];
        [self presentViewController:loginNavC animated:YES completion:nil];
    }]];
    
    [self presentViewController:qingshuruyonghuming animated:YES completion:nil];
}

- (void)loginAlert:(NSNotification *)notification{
    [self loginFirst];
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
    [[bofangVC shareInstance].tableView reloadData];
    [Explayer replaceCurrentItemWithPlayerItem:[[AVPlayerItem alloc]initWithURL:[NSURL URLWithString:self.pushNewsInfo[@"post_mp"]]]];
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
            [[bofangVC shareInstance].tableView reloadData];
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
        [[bofangVC shareInstance].tableView reloadData];
        self.hidesBottomBarWhenPushed = NO;
        if ([bofangVC shareInstance].isPlay) {
            
        }
        else{
            [[bofangVC shareInstance] doplay2];
        }
    }
    
    [[NSNotificationCenter defaultCenter] postNotificationName:@"yuanpanzhuan" object:nil];
    [[NSNotificationCenter defaultCenter] postNotificationName:@"qiehuanxinwen" object:nil];
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
    [[bofangVC shareInstance].tableView reloadData];
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
            [[bofangVC shareInstance].tableView reloadData];
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
        [[bofangVC shareInstance].tableView reloadData];
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

-(void)animat{
    
    self.signInImageView.alpha = 1;
    [UIView animateWithDuration:0.4 animations:^{
        CGRect fram = self.signInImageView.frame;
        fram.origin.y += 15;
        self.signInImageView.frame = fram;
    } completion:^(BOOL finished) {
        [UIView animateWithDuration:0.4 animations:^{
            CGRect fram = self.signInImageView.frame;
            fram.origin.y -= 15;
            self.signInImageView.frame = fram;
        }];
    }];
}

- (void)signInAction:(UITapGestureRecognizer *)tap{
    
    if (self.isSigned) {
        self.isSigned = YES;
        [self.signInImageView setImage:[UIImage imageNamed:@"sign_ined"]];
        [self.signInView.layer removeAllAnimations];
        [[NSNotificationCenter defaultCenter] postNotificationName:@"updateUserInfo" object:nil];
    }
    else{
        //签到
        NSDictionary *userInfo = [CommonCode readFromUserD:@"dangqianUserInfo"];
        NSString *accesstoken = nil;
        if ([[CommonCode readFromUserD:@"isWhatLogin"] isEqualToString:@"ShouJi"]) {
            //
            accesstoken = [DSE encryptUseDES:userInfo[@"results"][@"user_phone"]];
        }
        else{
            accesstoken = AvatarAccessToken;
        }
        [NetWorkTool signInWithaccessToken:AvatarAccessToken sccess:^(NSDictionary *responseObject) {
            if ([responseObject[@"msg"] isEqualToString:@"签到成功!"]) {
                self.isSigned = YES;
                [self.signInImageView setImage:[UIImage imageNamed:@"sign_ined"]];
                [self.signInView.layer removeAllAnimations];
                 [[NSNotificationCenter defaultCenter] postNotificationName:@"updateUserInfo" object:nil];
                [self showUpAnimations];
                [self getUnreadMessage];
            }
            else if([responseObject[@"msg"] isEqualToString:@"签到失败，今天已经签到过了!"]){
                self.isSigned = YES;
                [self.signInImageView setImage:[UIImage imageNamed:@"sign_ined"]];
                [self.signInView.layer removeAllAnimations];
                [[NSNotificationCenter defaultCenter] postNotificationName:@"updateUserInfo" object:nil];
                [self showUpAnimations];
                [self getUnreadMessage];
            }
            else {
                XWAlerLoginView *alert = [[XWAlerLoginView alloc] initWithTitle:responseObject[@"msg"]];
                [alert show];
//                [SVProgressHUD showErrorWithStatus:responseObject[@"msg"]];
            }
        } failure:^(NSError *error) {
            //
        }];
    }
}

- (void)lvQAButtonAction{
    
    NSURL *url = [NSURL URLWithString:@"http://admin.tingwen.me/help/help_core.html"];
    SingleWebViewController *singleWebVC = [[SingleWebViewController alloc] initWithTitle:@"帮助中心" url:url];
    [self.navigationController pushViewController:singleWebVC animated:YES];
}

- (void)showUpAnimations{
    animateBlock up = ^(){
        _experienceView.frame = CGRectMake(SCREEN_WIDTH - 63, SCREEN_HEIGHT - 160, 40, 40);
        _experienceView.alpha=0;
        [UIView animateWithDuration:KunitTime delay:0 options:UIViewAnimationOptionCurveEaseInOut animations:^{
            _experienceView.alpha=1;
            _experienceView.frame = CGRectMake(SCREEN_WIDTH - 63, SCREEN_HEIGHT - 200, 40, 40);
        } completion:^(BOOL finished) {
            [self removeAni];
        }];
    };
    [_animateArr addObject:up];
    [self nextAnimate];
}

-(void)nextAnimate{
    
    if (_animateArr.count==0) {
        _experienceView.frame = CGRectMake(SCREEN_WIDTH - 63, SCREEN_HEIGHT - 160, 40, 40);
        _experienceView.alpha=0;
        return;
    }
    animateBlock ani= [_animateArr firstObject];
    ani();
}

-(void)removeAni{
    //数组越界删除崩溃bug
    if (_animateArr.count != 0) {
        [_animateArr removeObjectAtIndex:0];
    }
    [self nextAnimate];
}

- (void)getUnreadMessage{
    //TODO:未读消息小红点
    if ([CommonCode readFromUserD:FEEDBACKYMESSAGEREAD] == nil) {
        [CommonCode writeToUserD:@"NO" andKey:FEEDBACKYMESSAGEREAD];
    }
    if ([CommonCode readFromUserD:TINGYOUQUANMESSAGEREAD] == nil) {
        [CommonCode writeToUserD:@"NO" andKey:TINGYOUQUANMESSAGEREAD];
    }
    if ([[CommonCode readFromUserD:@"isLogin"]boolValue] == YES){
        
        dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
        dispatch_group_t group = dispatch_group_create();
        
        dispatch_group_enter(group);
        dispatch_group_async(group, queue, ^{
            [NetWorkTool getFeedbackForMeWithaccessToken:AvatarAccessToken sccess:^(NSDictionary *responseObject) {
                dispatch_group_leave(group);
                if ([responseObject[@"status"] integerValue] == 1) {
                    if ([responseObject[@"results"] isKindOfClass:[NSArray class]]){
                        NSString *unreadID = [CommonCode readFromUserD:FEEDBACKFIRSTUNREADID];
                        NSMutableArray *resultArr = [responseObject[@"results"] mutableCopy];
                        if (unreadID == nil) {
                            unreadID = [responseObject[@"results"] firstObject][@"id"];
                            [CommonCode writeToUserD:[responseObject[@"results"] firstObject][@"id"] andKey:FEEDBACKFIRSTUNREADID];
                            [CommonCode writeToUserD:responseObject[@"results"] andKey:FEEDBACKFORMEDATAKEY];
                            [CommonCode writeToUserD:@"NO" andKey:FEEDBACKYMESSAGEREAD];
                            
                        }
                        else{
                            NSRange range;
                            for (int i = 0 ; i < [resultArr count]; i ++) {
                                if ([resultArr[i][@"id"] isEqualToString:unreadID ]) {
                                    range = NSMakeRange(i, [resultArr count] - i);
                                    break;
                                }
                            }
                            if (range.location < [resultArr count]) {
                                if (![[CommonCode readFromUserD:FEEDBACKYMESSAGEREAD] isEqualToString:@"NO"]) {
                                    [resultArr removeObjectsInRange:range];
                                }
                            }
                            [CommonCode writeToUserD:resultArr andKey:FEEDBACKFORMEDATAKEY];
                            if ([resultArr count]) {
                                [CommonCode writeToUserD:@"NO" andKey:FEEDBACKYMESSAGEREAD];
                            }
                        }
                        if ([resultArr count] && [[CommonCode readFromUserD:FEEDBACKYMESSAGEREAD] isEqualToString:@"NO"] ) {
                            [self.newSettingMessageButton setHidden:NO];
                            [self.newSettingMessageButton setTitle:[NSString stringWithFormat:@"%lu",[resultArr count]] forState:UIControlStateNormal];
                        }
                        else{
                            [self.newSettingMessageButton setHidden:YES];
                        }
                    }
                    else{
                        [CommonCode writeToUserD:nil andKey:FEEDBACKFORMEDATAKEY];
                        [self.newSettingMessageButton setHidden:YES];
                    }
                }
            } failure:^(NSError *error) {
                dispatch_group_leave(group);
            }];
        });
        dispatch_group_enter(group);
        dispatch_group_async(group, queue, ^{
            [NetWorkTool getNewPromptForMeWithaccessToken:AvatarAccessToken andpage:@"1" andlimit:@"100" sccess:^(NSDictionary *responseObject) {
                dispatch_group_leave(group);
                if ([responseObject[@"status"] integerValue] == 1) {
                    if ([responseObject[@"results"] isKindOfClass:[NSArray class]]){
                        NSString *unreadID1 = [CommonCode readFromUserD:TINGYOUQUANFIRSTUNREADID];
                        NSMutableArray *resultArrr = [responseObject[@"results"] mutableCopy];
                        if (unreadID1 == nil) {
                            unreadID1 = [responseObject[@"results"] firstObject][@"id"];
                            [CommonCode writeToUserD:[responseObject[@"results"] firstObject][@"id"] andKey:TINGYOUQUANFIRSTUNREADID];
                            [CommonCode writeToUserD:responseObject[@"results"] andKey:NEWPROMPTFORMEDATAKEY];
                            [CommonCode writeToUserD:@"NO" andKey:TINGYOUQUANMESSAGEREAD];
                        }
                        else{
                            
                            NSRange range;
                            for (int i = 0 ; i < [resultArrr count]; i ++) {
                                if ([resultArrr[i][@"id"] isEqualToString:unreadID1 ]) {
                                    range = NSMakeRange(i, [resultArrr count] - i);
                                    break;
                                }
                            }
                            if (range.location < [resultArrr count]) {
                                if (![[CommonCode readFromUserD:TINGYOUQUANMESSAGEREAD] isEqualToString:@"NO"]) {
                                    [resultArrr removeObjectsInRange:range];
                                }
                                
                            }
                            [CommonCode writeToUserD:resultArrr andKey:NEWPROMPTFORMEDATAKEY];
                            if ([resultArrr count]) {
                                [CommonCode writeToUserD:@"NO" andKey:TINGYOUQUANMESSAGEREAD];
                            }
                        }
                        if ([resultArrr count] && [[CommonCode readFromUserD:TINGYOUQUANMESSAGEREAD] isEqualToString:@"NO"]) {
                            [self.newFriendMessageButton setHidden:NO];
                            [self.newFriendMessageButton setTitle:[NSString stringWithFormat:@"%lu",[resultArrr count]] forState:UIControlStateNormal];
                        }
                        else{
                            [self.newFriendMessageButton setHidden:YES];
                        }
                    }
                    else{
                        [CommonCode writeToUserD:nil andKey:NEWPROMPTFORMEDATAKEY];
                        [self.newFriendMessageButton setHidden:YES];
                    }
                }
            } failure:^(NSError *error) {
                dispatch_group_leave(group);
            }];
        });
        dispatch_group_enter(group);
        dispatch_group_async(group, queue, ^{
            
            NSString *lastReadTime = [CommonCode readFromUserD:PERSONALLASTREAD];
            [NetWorkTool getAddcriticismNumWithaccessToken:AvatarAccessToken andpage:@"1" andlimit:@"100" anddate:lastReadTime sccess:^(NSDictionary *responseObject) {
                dispatch_group_leave(group);
                if ([responseObject[@"status"] integerValue] == 1) {
                    if ([responseObject[@"results"] isKindOfClass:[NSArray class]]){
                        [CommonCode writeToUserD:responseObject[@"results"] andKey:ADDCRITICISMNUMDATAKEY];
                        [self.newPersonMessageButton setHidden:NO];
                        [self.newPersonMessageButton setTitle:[NSString stringWithFormat:@"%lu",[responseObject[@"results"] count]] forState:UIControlStateNormal];
                        
                    }
                    else{
                        [CommonCode writeToUserD:nil andKey:ADDCRITICISMNUMDATAKEY];
                        [self.newPersonMessageButton setHidden:YES];
                    }
                }
                
            } failure:^(NSError *error) {
                dispatch_group_leave(group);
            }];
        });
        dispatch_group_notify(group, dispatch_get_main_queue(), ^{
            //设置 我 的未读消息
            [[NSNotificationCenter defaultCenter] postNotificationName:@"setMyunreadMessageTips" object:nil];
        });
    }
    else{
        [self.newPersonMessageButton setHidden:YES];
        [self.newFriendMessageButton setHidden: YES];
        [self.newSettingMessageButton setHidden:YES];
        //        [self loginFirst];
    }
    [self.tableView reloadData];
}

#pragma mark --- UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 6;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if (indexPath.row == 0){
        
        static NSString *wotouxiangcellIdentify = @"wotouxiangcellIdentify";
        UITableViewCell *cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:wotouxiangcellIdentify];
        if (!cell){
            
            cell = [tableView dequeueReusableCellWithIdentifier:wotouxiangcellIdentify];
        }
        
        UIImageView *cellBgView = [[UIImageView alloc]initWithFrame:CGRectMake(0, -20, SCREEN_WIDTH, 240.0 / 667 * IPHONE_H)];
        [cellBgView setUserInteractionEnabled:YES];
        [cell.contentView addSubview:cellBgView];
        
        UIImageView *ShadowImageView = [[UIImageView alloc]initWithFrame:CGRectMake(0, -20, SCREEN_WIDTH, 240.0 / 667 * IPHONE_H)];
        [cellBgView setUserInteractionEnabled:YES];
        [cell.contentView addSubview:ShadowImageView];
        
        UIImageView *coverView = [UIImageView new];
        [coverView setFrame:CGRectMake(0, -20, SCREEN_WIDTH, 240.0/ 667 * IPHONE_H)];
        [coverView setImage:[UIImage imageNamed:@"me_topbg1"]];
        [cell.contentView addSubview:coverView];
        
        //title
        UILabel *topLab = [[UILabel alloc]initWithFrame:CGRectMake((SCREEN_WIDTH - 44 )/2, 0, 44, 44)];
        topLab.textColor = gTextColorMain;
        topLab.font = [UIFont fontWithName:@"Semibold" size:17.0f ];
        topLab.text = @"我";
        topLab.backgroundColor = [UIColor clearColor];
        topLab.textAlignment = NSTextAlignmentCenter;
        [cell.contentView addSubview:topLab];
        
//        //图片高斯模糊处理
//        CIContext *context = [CIContext contextWithOptions:nil];
//        CIImage *inputImage = [[CIImage alloc] initWithImage:[UIImage imageNamed:@"top_bg"]];
//        CIFilter *filter = [CIFilter filterWithName:@"CIGaussianBlur"];
//        [filter setValue:inputImage forKey:kCIInputImageKey];
//        [filter setValue:[NSNumber numberWithFloat:15.0] forKey:@"inputRadius"];
//        //        CIImage *result = [filter valueForKey:kCIOutputImageKey];
//        CIImage *result=[filter outputImage];
//        CGImageRef cgImage = [context createCGImage:result fromRect:[inputImage extent]];
//        UIImage *image = [UIImage imageWithCGImage:cgImage];
//        CGImageRelease(cgImage);
//        [cellBgView setImage:image];
//        UIView *markView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, cellBgView.frame.size.width, cellBgView.frame.size.height)];
//        [markView setBackgroundColor:gImageMarkColor];
//        [markView setUserInteractionEnabled:YES];
//        [cellBgView addSubview:markView];
        
        
        UIView *imgBorderView = [[UIView alloc]initWithFrame:CGRectMake(30.0 / 667 * IPHONE_H, 170.0 / 667 * IPHONE_H, 95.0 / 667 * IPHONE_H, 95.0 / 667 * IPHONE_H)];
        [imgBorderView setBackgroundColor:gImageBorderColor];
        [imgBorderView setUserInteractionEnabled:YES];
        [imgBorderView.layer setMasksToBounds:YES];
        [imgBorderView.layer setCornerRadius:95.0 / 667 * IPHONE_H / 2];
        [cell.contentView addSubview:imgBorderView];
        
        UIImageView *titleImage = [[UIImageView alloc]initWithFrame:CGRectMake(2.5/ 667 * IPHONE_H, 2.5 / 667 *IPHONE_H, 90.0 / 667 * IPHONE_H, 90.0 / 667 * IPHONE_H)];
        titleImage.image = [UIImage imageWithContentsOfFile:ExTouXiangPath];
        ShadowImageView.image = [UIImage imageWithContentsOfFile:ExTouXiangPath];
        ShadowImageView.contentMode = UIViewContentModeScaleAspectFill;
        ShadowImageView.clipsToBounds = YES;
        
        if (titleImage.image == nil){
            titleImage.image = [UIImage imageNamed:@"right-1"];
        }
        titleImage.layer.cornerRadius = titleImage.frame.size.width / 2;
        titleImage.clipsToBounds = YES;
        titleImage.userInteractionEnabled = YES;
        [titleImage addTapGesWithTarget:self action:@selector(dianjitouxiangshijian)];
        [imgBorderView addSubview:titleImage];
        //加边框
        CALayer *layer = [titleImage layer];
        layer.borderColor = [gImageBorderColor CGColor];
        layer.borderWidth = 0.0f;
        [self.newPersonMessageButton setHidden:YES];
        [cell.contentView addSubview:self.newPersonMessageButton];
        
    
        UILabel *lab = [[UILabel alloc]initWithFrame:CGRectMake(CGRectGetMaxX(imgBorderView.frame) + 12, imgBorderView.frame.origin.y + 10.0 / 667 * IPHONE_H, SCREEN_WIDTH - 150, 20.0 / 667 * IPHONE_H)];
        lab.font = [UIFont fontWithName:@"Semibold" size:18.0f ];
        lab.textColor = [UIColor blackColor];
        lab.textAlignment = NSTextAlignmentLeft;
        [lab addTapGesWithTarget:self action:@selector(dianjitouxiangshijian)];
        [cell.contentView addSubview:lab];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        
        UIImageView *lvView = [[UIImageView alloc]initWithFrame:CGRectMake(CGRectGetMaxX(lab.frame) + 5, lab.frame.origin.y, 44.0, 16.0)];
        [lvView setImage:[UIImage imageNamed:@"LV1~9"]];
        lvView.hidden = YES;
        lvView.contentMode = UIViewContentModeScaleAspectFill;
        lvView.clipsToBounds = YES;
        [lvView addTapGesWithTarget:self action:@selector(lvQAButtonAction)];
        [cell.contentView addSubview:lvView];
        UILabel *lvLab = [[UILabel alloc]initWithFrame:CGRectMake(lvView.frame.size.width - 20, 0, 25, 16)];
        if (TARGETED_DEVICE_IS_IPHONE_480) {
            [lvLab setFrame:CGRectMake(lvView.frame.size.width - 25, 0, 25, 16)];
        }
        else if (TARGETED_DEVICE_IS_IPHONE_568){
            [lvLab setFrame:CGRectMake(lvView.frame.size.width - 25, 0, 25, 16)];
        }
        else if (TARGETED_DEVICE_IS_IPHONE_667){
            [lvLab setFrame:CGRectMake(lvView.frame.size.width - 20, 0, 25, 16)];
        }
        else if (TARGETED_DEVICE_IS_IPHONE_736){
            [lvLab setFrame:CGRectMake(lvView.frame.size.width - 20, 0, 25, 16)];
        }
        [lvLab setFont:gFontMain12];
        [lvLab setTextAlignment:NSTextAlignmentCenter];
        [lvLab setTextColor:[UIColor whiteColor]];
        [lvView addSubview:lvLab];
        
        TTTAttributedLabel *signtureLab = [[TTTAttributedLabel alloc]initWithFrame:CGRectMake(lab.frame.origin.x, 230.0 / 667 * IPHONE_H, SCREEN_WIDTH - 150, 20.0 / 667 * IPHONE_H)];
//        signtureLab.textAlignment = NSTextAlignmentLeft;
//        signtureLab.font = [UIFont systemFontOfSize:12.0F];
//        signtureLab.textColor = gTextColorSub;
        [cell.contentView addSubview:signtureLab];
        
        if ([[CommonCode readFromUserD:@"isLogin"]boolValue] == YES){
            NSDictionary *userInfo = [CommonCode readFromUserD:@"dangqianUserInfo"];
            NSString *isNameNil = userInfo[@"results"][@"user_nicename"];
            if (isNameNil.length == 0){
                lab.text = userInfo[@"results"][@"user_login"];
            }
            else{
                lab.text = userInfo[@"results"][@"user_nicename"];
            }
            
            //账户信息
            NSString *df = [NSString stringWithFormat:@"金币：%@ | 听币：%@",userInfo[@"results"][@"gold"],userInfo[@"results"][@"listen_money"]];
            NSMutableAttributedString *attriString =[[NSMutableAttributedString alloc] initWithString:df attributes:@{NSForegroundColorAttributeName:gTextDownload,NSFontAttributeName:gFontMain12}];
            NSRange range1=[df rangeOfString:[NSString stringWithFormat:@"%@",userInfo[@"results"][@"gold"]]];
            [attriString addAttributes:@{NSForegroundColorAttributeName:UIColorFromHex(0xf78540),NSFontAttributeName:gFontMain12} range:range1];
            [signtureLab addLinkToTransitInformation:nil withRange:range1];
            NSRange range2=[df rangeOfString:[NSString stringWithFormat:@"%@",userInfo[@"results"][@"listen_money"]]];
            [attriString addAttributes:@{NSForegroundColorAttributeName:UIColorFromHex(0xf78540),NSFontAttributeName:gFontMain12} range:range2];
            [signtureLab addLinkToTransitInformation:nil withRange:range2];
            signtureLab.attributedText = attriString;
            //充值按钮
            UIButton *payButton = [UIButton buttonWithType:UIButtonTypeCustom];
            [payButton setFrame:CGRectMake(lab.frame.origin.x, 255.0 / 667 * IPHONE_H, 80.0 / 375 * SCREEN_WIDTH, 20.0 / 667 * IPHONE_H)];
            [payButton setBackgroundColor:gButtonRewardColor];
            [payButton setTitle:@"充值" forState:UIControlStateNormal];
            [payButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
            [payButton.titleLabel setFont:gFontMain12];
            [payButton.layer setMasksToBounds:YES];
            [payButton.layer setCornerRadius:8.0];
            [payButton addTarget:self action:@selector(payButtonAction:) forControlEvents:UIControlEventTouchUpInside];
            [cell.contentView addSubview:payButton];
            
            CGSize contentSize = [lab sizeThatFits:CGSizeMake(lab.frame.size.width, MAXFLOAT)];
            lab.frame = CGRectMake(lab.frame.origin.x, lab.frame.origin.y,contentSize.width, lab.frame.size.height);
            [lvView setFrame:CGRectMake(CGRectGetMaxX(lab.frame)+ 10, lab.frame.origin.y, 50.0 / 667 * IPHONE_H, 16.0 / 667 * IPHONE_H)];
            lvView.hidden = NO;
            NSInteger lv = [userInfo[@"results"][@"level"] integerValue];
            if (lv > 0 && lv < 10) {
                [lvView setImage:[UIImage imageNamed:@"LV1~9"]];
            }
            else if (lv >= 10 && lv < 20){
                [lvView setImage:[UIImage imageNamed:@"LV10~19"]];
            }
            else if (lv >= 20 && lv < 30){
                [lvView setImage:[UIImage imageNamed:@"LV20~29"]];
            }
            else if (lv >= 30 && lv < 40){
                [lvView setImage:[UIImage imageNamed:@"LV30~39"]];
            }
            else if (lv >= 40 && lv < 50){
                [lvView setImage:[UIImage imageNamed:@"LV40~49"]];
            }
            else if (lv >= 50 && lv < 60){
                [lvView setImage:[UIImage imageNamed:@"LV50~59"]];
            }
            else if (lv >= 60 && lv < 70){
                [lvView setImage:[UIImage imageNamed:@"LV60~69"]];
            }
            else if (lv >= 70 && lv < 80){
                [lvView setImage:[UIImage imageNamed:@"LV70~79"]];
            }
            else if (lv >= 80 && lv < 90){
                [lvView setImage:[UIImage imageNamed:@"LV80~89"]];
            }
            else if (lv >= 90 && lv < 99){
                [lvView setImage:[UIImage imageNamed:@"LV90~99"]];
            }
            else{
                [lvView setImage:[UIImage imageNamed:@"LV100"]];
            }
            [lvLab setText:userInfo[@"results"][@"level"]];
            
        }
        else{
            lab.text = nil;
            signtureLab.text = nil;
            lvView.hidden = YES;
        }
//        用户简介
//        NSString *signtureStr = [CommonCode readFromUserD:@"dangqianUserInfo"][@"results"][@"signature"];;
//        if (signtureStr.length == 0){
//            signtureLab.text = @"该用户没有什么想说的";
//        }
//        else if ([signtureStr isEqualToString:@"没有简介"]){
//            signtureLab.text = @"该用户没有什么想说的";
//        }
//        else if ([signtureStr isEqualToString:@"暂无简介"]){
//            signtureLab.text = @"该用户没有什么想说的";
//        }
//        else{
//            signtureLab.text = signtureStr;
//        }
        
        return cell;
    }
    else if (indexPath.row == 1){
        UITableViewCell *cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"wotwoIdentify"];
//        UIImageView *img = [[UIImageView alloc]initWithFrame:CGRectMake(15.0 / 375 * IPHONE_W, 15.0 / 667 * IPHONE_H, 20.0 / 375 * IPHONE_W, 20.0 / 667 * IPHONE_H)];
//        img.image = [UIImage imageNamed:@"pengyouquan"];
////        img.image = [UIImage imageNamed:@"attention"];
//        [cell.contentView addSubview:img];
//        img.contentMode = UIViewContentModeScaleAspectFit;
        UILabel *lab = [[UILabel alloc]initWithFrame:CGRectMake(40.0 / 375 * IPHONE_W, 14.0 / 667 * IPHONE_H, 100.0 / 375 * IPHONE_W, 30.0 / 667 * IPHONE_H)];
        lab.text = @"听友圈";
//        lab.text = @"我的关注";
        lab.textAlignment = NSTextAlignmentLeft;
        lab.textColor = nTextColorMain;
        [cell.contentView addSubview:lab];
        lab.font =  [UIFont fontWithName:@"Regular" size:17.0f ];
        UIView *line = [[UIView alloc]initWithFrame:CGRectMake(20.0 / 375 * IPHONE_W, 57.0 / 667 * IPHONE_H, SCREEN_WIDTH - 20.0 / 375 * IPHONE_W, 1)];
        [line setBackgroundColor:gThinLineColor];
        [cell.contentView addSubview:line];
        [self.newFriendMessageButton setHidden:YES];
        [cell.contentView addSubview:self.newFriendMessageButton];
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        return cell;
    }
    else if (indexPath.row == 2){
        UITableViewCell *cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"wothreeIdentify"];
//        UIImageView *img = [[UIImageView alloc]initWithFrame:CGRectMake(15.0 / 375 * IPHONE_W, 15.0 / 667 * IPHONE_H, 20.0 / 375 * IPHONE_W, 20.0 / 667 * IPHONE_H)];
//        img.image = [UIImage imageNamed:@"dowload"];
//        [cell.contentView addSubview:img];
//        img.contentMode = UIViewContentModeScaleAspectFit;
         UILabel *lab = [[UILabel alloc]initWithFrame:CGRectMake(40.0 / 375 * IPHONE_W, 14.0 / 667 * IPHONE_H, 100.0 / 375 * IPHONE_W, 30.0 / 667 * IPHONE_H)];
        lab.text = @"我的下载";
        lab.textAlignment = NSTextAlignmentLeft;
        lab.textColor = nTextColorMain;
        [cell.contentView addSubview:lab];
        lab.font = gFontMajor17;
        UIView *line = [[UIView alloc]initWithFrame:CGRectMake(20.0 / 375 * IPHONE_W, 57.0 / 667 * IPHONE_H, SCREEN_WIDTH - 20.0 / 375 * IPHONE_W, 1)];
        [line setBackgroundColor:gThinLineColor];
        [cell.contentView addSubview:line];
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        return cell;
    }
    else if (indexPath.row == 3){
        UITableViewCell *cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"wofourIdentify"];
        //        UIImageView *img = [[UIImageView alloc]initWithFrame:CGRectMake(15.0 / 375 * IPHONE_W, 15.0 / 667 * IPHONE_H, 20.0 / 375 * IPHONE_W, 20.0 / 667 * IPHONE_H)];
        //        img.image = [UIImage imageNamed:@"yingyong"];
        //        [cell.contentView addSubview:img];
        //        img.contentMode = UIViewContentModeScaleAspectFit;
        UILabel *lab = [[UILabel alloc]initWithFrame:CGRectMake(40.0 / 375 * IPHONE_W, 14.0 / 667 * IPHONE_H, 100.0 / 375 * IPHONE_W, 30.0 / 667 * IPHONE_H)];
        lab.text = @"我的收藏";
        lab.textAlignment = NSTextAlignmentLeft;
        lab.textColor = nTextColorMain;
        [cell.contentView addSubview:lab];
        lab.font = gFontMajor17;
        UIView *line = [[UIView alloc]initWithFrame:CGRectMake(20.0 / 375 * IPHONE_W, 57.0 / 667 * IPHONE_H, SCREEN_WIDTH - 20.0 / 375 * IPHONE_W, 1)];
        [line setBackgroundColor:gThinLineColor];
        [cell.contentView addSubview:line];
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        return cell;
    }
    else if (indexPath.row == 4){
        UITableViewCell *cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"wofourIdentify"];
//        UIImageView *img = [[UIImageView alloc]initWithFrame:CGRectMake(15.0 / 375 * IPHONE_W, 15.0 / 667 * IPHONE_H, 20.0 / 375 * IPHONE_W, 20.0 / 667 * IPHONE_H)];
//        img.image = [UIImage imageNamed:@"yingyong"];
//        [cell.contentView addSubview:img];
//        img.contentMode = UIViewContentModeScaleAspectFit;
         UILabel *lab = [[UILabel alloc]initWithFrame:CGRectMake(40.0 / 375 * IPHONE_W, 14.0 / 667 * IPHONE_H, 100.0 / 375 * IPHONE_W, 30.0 / 667 * IPHONE_H)];
        lab.text = @"我的课堂";
        lab.textAlignment = NSTextAlignmentLeft;
        lab.textColor = nTextColorMain;
        [cell.contentView addSubview:lab];
        lab.font = gFontMajor17;
        UIView *line = [[UIView alloc]initWithFrame:CGRectMake(20.0 / 375 * IPHONE_W, 57.0 / 667 * IPHONE_H, SCREEN_WIDTH - 20.0 / 375 * IPHONE_W, 1)];
        [line setBackgroundColor:gThinLineColor];
        [cell.contentView addSubview:line];
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        return cell;
    }
//    else if (indexPath.row == 4){
//        UITableViewCell *cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"wofourIdentify"];
//        //        UIImageView *img = [[UIImageView alloc]initWithFrame:CGRectMake(15.0 / 375 * IPHONE_W, 15.0 / 667 * IPHONE_H, 20.0 / 375 * IPHONE_W, 20.0 / 667 * IPHONE_H)];
//        //        img.image = [UIImage imageNamed:@"yingyong"];
//        //        [cell.contentView addSubview:img];
//        //        img.contentMode = UIViewContentModeScaleAspectFit;
//        UILabel *lab = [[UILabel alloc]initWithFrame:CGRectMake(40.0 / 375 * IPHONE_W, 14.0 / 667 * IPHONE_H, 100.0 / 375 * IPHONE_W, 30.0 / 667 * IPHONE_H)];
//        lab.text = @"上传节目";
//        lab.textAlignment = NSTextAlignmentLeft;
//        lab.textColor = nTextColorMain;
//        [cell.contentView addSubview:lab];
//        lab.font = gFontMajor17;
//        UIView *line = [[UIView alloc]initWithFrame:CGRectMake(20.0 / 375 * IPHONE_W, 57.0 / 667 * IPHONE_H, SCREEN_WIDTH - 20.0 / 375 * IPHONE_W, 1)];
//        [line setBackgroundColor:gThinLineColor];
//        [cell.contentView addSubview:line];
//        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
//        cell.selectionStyle = UITableViewCellSelectionStyleNone;
//        return cell;
//    }
//    else if (indexPath.row == 4){
//        UITableViewCell *cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"wofourIdentify"];
//        //        UIImageView *img = [[UIImageView alloc]initWithFrame:CGRectMake(15.0 / 375 * IPHONE_W, 15.0 / 667 * IPHONE_H, 20.0 / 375 * IPHONE_W, 20.0 / 667 * IPHONE_H)];
//        //        img.image = [UIImage imageNamed:@"yingyong"];
//        //        [cell.contentView addSubview:img];
//        //        img.contentMode = UIViewContentModeScaleAspectFit;
//        UILabel *lab = [[UILabel alloc]initWithFrame:CGRectMake(40.0 / 375 * IPHONE_W, 14.0 / 667 * IPHONE_H, 150.0 / 375 * IPHONE_W, 30.0 / 667 * IPHONE_H)];
//        lab.text = @"帮助与反馈";
//        lab.textAlignment = NSTextAlignmentLeft;
//        lab.textColor = nTextColorMain;
//        [cell.contentView addSubview:lab];
//        lab.font = gFontMajor17;
//        UIView *line = [[UIView alloc]initWithFrame:CGRectMake(20.0 / 375 * IPHONE_W, 57.0 / 667 * IPHONE_H, SCREEN_WIDTH - 20.0 / 375 * IPHONE_W, 1)];
//        [line setBackgroundColor:gThinLineColor];
//        [cell.contentView addSubview:line];
//        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
//        cell.selectionStyle = UITableViewCellSelectionStyleNone;
//        return cell;
//    }
    else {
        static NSString *wosixIdentify = @"wosixIdentify";
        UITableViewCell *cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:wosixIdentify];
        if (!cell){
            cell = [tableView dequeueReusableCellWithIdentifier:wosixIdentify];
        }
//        UIImageView *img = [[UIImageView alloc]initWithFrame:CGRectMake(15.0 / 375 * IPHONE_W, 15.0 / 667 * IPHONE_H, 20.0 / 375 * IPHONE_W, 20.0 / 667 * IPHONE_H)];
//        img.image = [UIImage imageNamed:@"setting"];
//        [cell.contentView addSubview:img];
//        img.contentMode = UIViewContentModeScaleAspectFit;
         UILabel *lab = [[UILabel alloc]initWithFrame:CGRectMake(40.0 / 375 * IPHONE_W, 14.0 / 667 * IPHONE_H, 100.0 / 375 * IPHONE_W, 30.0 / 667 * IPHONE_H)];
        lab.text = @"设置";
        lab.textAlignment = NSTextAlignmentLeft;
        lab.textColor = nTextColorMain;
        [cell.contentView addSubview:lab];
        lab.font = gFontMajor17;
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        [self.newSettingMessageButton setHidden:YES];
        [cell.contentView addSubview:self.newSettingMessageButton];
        UIView *line = [[UIView alloc]initWithFrame:CGRectMake(20.0 / 375 * IPHONE_W, 57.0 / 667 * IPHONE_H, SCREEN_WIDTH - 20.0 / 375 * IPHONE_W, 1)];
        [line setBackgroundColor:gThinLineColor];
        [cell.contentView addSubview:line];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        return cell;
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.row == 0){
        return 285.0 / 667 * IPHONE_H;
    }
    else{
        return 58.0f / 667 * IPHONE_H;
    }
    
}
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if (indexPath.row == 0) {
//        [self dianjitouxiangshijian];
    }
    else if (indexPath.row == 1) {
        if ([[CommonCode readFromUserD:@"isLogin"]boolValue] == YES){
            
//            wodeguanzhuVC *vc = [wodeguanzhuVC new];
//            vc.user_login = ExdangqianUser;
//            self.hidesBottomBarWhenPushed=YES;
//            [self.navigationController pushViewController:vc animated:YES];
//            self.hidesBottomBarWhenPushed=NO;
//            //TODO:听友圈
            self.hidesBottomBarWhenPushed=YES;
            BlogViewController *blogVC = [BlogViewController new];
            blogVC.view.backgroundColor = [UIColor whiteColor];
            blogVC.isFeedbackVC = NO;
            [self.navigationController pushViewController:blogVC animated:YES];
            self.hidesBottomBarWhenPushed=NO;
        }
        else {
            [self loginFirst];
        }
    }
    else if (indexPath.row == 2) {
            self.hidesBottomBarWhenPushed=YES;
            [self.navigationController pushViewController:[DownloadViewController new] animated:NO];
            self.hidesBottomBarWhenPushed=NO;
    }
    else if (indexPath.row == 3) {
        if ([[CommonCode readFromUserD:@"isLogin"]boolValue] == YES){
            self.hidesBottomBarWhenPushed=YES;
            [self.navigationController pushViewController:[MyCollectionViewController new] animated:YES];
            self.hidesBottomBarWhenPushed=NO;
        }
        else {
            [self loginFirst];
        }
    }
    else if (indexPath.row == 4) {
        if ([[CommonCode readFromUserD:@"isLogin"]boolValue] == YES){
            self.hidesBottomBarWhenPushed=YES;
            [self.navigationController pushViewController:[MyClassroomController new] animated:YES];
            self.hidesBottomBarWhenPushed=NO;
        }
        else {
            [self loginFirst];
        }
    }
//    else if (indexPath.row == 4) {
//        NSURL *url = [NSURL URLWithString:@"http://admin.tingwen.me/index.php/article/zhinan.html"];
//        SingleWebViewController *singleWebVC = [[SingleWebViewController alloc] initWithTitle:@"上传攻略" url:url];
//        self.hidesBottomBarWhenPushed=YES;
//        [self.navigationController pushViewController:singleWebVC animated:YES];
//        self.hidesBottomBarWhenPushed=NO;
//    }
//    else if (indexPath.row == 4) {
//        self.hidesBottomBarWhenPushed=YES;
//        [self.navigationController pushViewController:[HelpAndFeedbackViewController new] animated:YES];
//        self.hidesBottomBarWhenPushed=NO;
//        
//    }
    else if (indexPath.row == 5) {
        self.hidesBottomBarWhenPushed=YES;
        [self.navigationController pushViewController:[SheZhiVC new] animated:YES];
        self.hidesBottomBarWhenPushed=NO;
    }

}

#pragma mark UIScrollViewDelegate
-(void)scrollViewDidScroll:(UIScrollView *)scrollView{
    if (self.tableView.contentOffset.y <= 0) {
        self.tableView.bounces = NO;
    }
    else if (self.tableView.contentOffset.y >= 0){
            self.tableView.bounces = YES;
        }
}

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch{
    
    UITableViewCell *cell = [UITableViewCell new];
    if ([touch.view isKindOfClass:[cell.contentView class]]) {
        //放过对单元格点击事件的拦截
        return NO;
    }else{
        return YES;
    }
}

#pragma mark -- getter
- (UITableView *)tableView {
    if (!_tableView){
        _tableView = [[UITableView alloc]initWithFrame:CGRectMake(0, 0, IPHONE_W, IPHONE_H- 49) style:UITableViewStylePlain];
        _tableView.delegate = self;
        _tableView.dataSource = self;
        _tableView.tableFooterView = [UIView new];
        _tableView.backgroundColor = [UIColor whiteColor];
        _tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
        //        _tableView.backgroundColor = ColorWithRGBA(0, 107, 153, 1);
    }
    return _tableView;
}

- (NSMutableDictionary *)pushNewsInfo {
    if (!_pushNewsInfo) {
        _pushNewsInfo = [NSMutableDictionary new];
    }
    return _pushNewsInfo;
}


- (UIButton *)newPersonMessageButton {
    if (!_newPersonMessageButton ) {
        _newPersonMessageButton  = [UIButton buttonWithType:UIButtonTypeCustom];
        [_newPersonMessageButton setFrame:CGRectMake(114.0 / 667 * IPHONE_H,240.0 / 667 * IPHONE_H, 20, 20)];
        [_newPersonMessageButton.layer setMasksToBounds:YES];
        [_newPersonMessageButton.layer setCornerRadius:10.0];
        [_newPersonMessageButton setBackgroundColor:UIColorFromHex(0xf23131)];
        [_newPersonMessageButton.titleLabel setFont:[UIFont systemFontOfSize:11.0]];
    }
    return _newPersonMessageButton;
}

- (UIButton *)newFriendMessageButton {
    if (!_newFriendMessageButton ) {
        _newFriendMessageButton  = [UIButton buttonWithType:UIButtonTypeCustom];
        [_newFriendMessageButton setFrame:CGRectMake(110, 19.0 / 667 * IPHONE_H, 20, 20)];
        [_newFriendMessageButton.layer setMasksToBounds:YES];
        [_newFriendMessageButton.layer setCornerRadius:10.0];
        [_newFriendMessageButton setBackgroundColor:UIColorFromHex(0xf23131)];
        [_newFriendMessageButton.titleLabel setFont:[UIFont systemFontOfSize:11.0]];
    }
    return _newFriendMessageButton;
}

- (UIButton *)newSettingMessageButton {
    if (!_newSettingMessageButton ) {
        _newSettingMessageButton  = [UIButton buttonWithType:UIButtonTypeCustom];
        [_newSettingMessageButton setFrame:CGRectMake(110, 19.0 / 667 * IPHONE_H, 20, 20)];
        [_newSettingMessageButton.layer setMasksToBounds:YES];
        [_newSettingMessageButton.layer setCornerRadius:10.0];
        [_newSettingMessageButton setBackgroundColor:UIColorFromHex(0xf23131)];
        [_newSettingMessageButton.titleLabel setFont:[UIFont systemFontOfSize:11.0]];
    }
    return _newSettingMessageButton;
}

- (UIView *)signInView{
    if (!_signInView) {
        _signInView = [[UIView alloc]init];
        [_signInView setFrame:CGRectMake(SCREEN_WIDTH - 83, SCREEN_HEIGHT - 85 - 83, 83, 83)];
        [_signInView setUserInteractionEnabled:YES];
        [_signInView addSubview:self.signInImageView];
        [_signInView addTapGesWithTarget:self action:@selector(signInAction:)];
    }
    return _signInView;
}

- (UIImageView *)signInImageView {
    if (!_signInImageView ) {
        _signInImageView  = [[UIImageView alloc]initWithFrame:CGRectMake(0,23, 60, 60)];
        [_signInImageView setUserInteractionEnabled:YES];
        [_signInImageView setImage:[UIImage imageNamed:@"sign_in"]];
    }
    return _signInImageView;
}

@end
