//
//  bofangVC.m
//  kuangjiaTingWen
//
//  Created by 贺楠 on 16/6/3.
//  Copyright © 2016年 贺楠. All rights reserved.
//

#import "bofangVC.h"
#import "bofangBtn.h"
#import "UIImageView+WebCache.h"
#import <AVFoundation/AVFoundation.h>
#import "zhuboxiangqingVCNew.h"
#import "pinglunyeVC.h"
#import "LoginNavC.h"
#import "LoginVC.h"
//#import "UMSocialSnsService.h"
//#import "UMSocialSnsPlatformManager.h"
#import <UShareUI/UShareUI.h>
#import "AppDelegate.h"
#import "TimerViewController.h"
#import "NSDate+TimeFormat.h"
#import "ShareAlertView.h"
#import "GestureControlAlertView.h"
#import "WXApi.h"
#import "UIImage+compress.h"
#import "UIActionSheet+MKBlockAdditions.h"
#import "gerenzhuyeVC.h"
#import <MediaPlayer/MediaPlayer.h>
#import "UIView+tap.h"
#import "ShareView.h"
#import "ProjiectDownLoadManager.h"
#import "WHC_Download.h"
#import "MenuItemV.h"
#include <TencentOpenAPI/QQApiInterface.h>
#import <TencentOpenAPI/QQApiInterfaceObject.h>
#import <TencentOpenAPI/TencentOAuthObject.h>
#import <TencentOpenAPI/TencentOAuth.h>
#import <TencentOpenAPI/TencentApiInterface.h>
#import <TencentOpenAPI/TencentMessageObject.h>
#import "PayOnlineViewController.h"
#import "RewardListViewController.h"
#import "OJLAnimationButton.h"
#import "AKAlertView.h"
//#import "TTTAttributedLabel.h"
#import "YJImageBrowserView.h"
#import "PinglundianzanCustomBtn.h"

#define PINGLUN_ROW 2

@interface bofangVC ()<UITableViewDataSource,UITableViewDelegate,WXApiDelegate,UITextViewDelegate,UITextFieldDelegate,TencentSessionDelegate,OJLAnimationButtonDelegate>
{
    UIView *xiangqingView;
    double angle;
    UIButton *xuanzhuanBtn;
    BOOL isDianZan;
    NSMutableArray *jiaDianZanShuJv;
    NSString *dianzanshu;
    UIView *dibuView;
    UIButton *bofangCenterBtn;
    UIButton *bofangLeftBtn;
    NSTimer *ShangTimer;
    UILabel *dangqianTime;
    UILabel *PingLundianzanNumLab;
    BOOL isJiaZaiWan;
    //播放队列
    NSArray *arrayPlayList;
    //        //播放器
    //        AVPlayer *player;
    //当前播放的是第几个
    int currentPlayIndex;
    //播放状态
    BOOL isPlaying;
    //观察者对象
    id timeObserver;
    
    NSMutableArray *arr;
    UIButton *bofangRightBtn;
    BOOL isGuanZhu;
    TencentOAuth *tencentOAuth;
}
@property(strong,nonatomic)NSDictionary *infoDic;
@property(strong,nonatomic)NSMutableArray *pinglunArr;
@property(strong,nonatomic)UISlider *sliderProgress;
@property(strong,nonatomic)UIProgressView *prgBufferProgress;

@property (weak, nonatomic) UIScrollView *scrollView;
@property (weak, nonatomic) UIImageView *lastImageView;
@property (nonatomic)CGRect originalFrame;

@property (strong, nonatomic) AVAudioSession *session;

@property (strong, nonatomic) OJLAnimationButton *finalRewardButton;
@property (nonatomic, strong) NSMutableArray *buttons;
@property (assign, nonatomic) float rewardCount;
@property (assign, nonatomic) BOOL isReward;
@property (assign, nonatomic) BOOL isPay;
@property (assign, nonatomic) BOOL isCustomRewardCount;
@property (strong, nonatomic) UITextField *customRewardTextField;
@property (strong, nonatomic) NSArray *rewardArray;
@property (strong, nonatomic) UIView *topView;
@property (strong, nonatomic) UIButton *leftBtn;
@property (strong, nonatomic) UIButton *rightBtn;
//新闻详情控件
@property (strong, nonatomic) UITextView *zhengwenTextView;
@property (strong, nonatomic) UIImageView *zhengwenImg;
@property (strong, nonatomic) UIImageView *zhuboImg;
@property (strong, nonatomic) UILabel *zhuboTitleLab;
@property (strong, nonatomic) UIImageView *mic;
@property (strong, nonatomic) UIView *achorTouch;
@property (strong, nonatomic) UIView *seperatorLine;
@property (strong, nonatomic) UILabel *titleLab;
@property (strong, nonatomic) UILabel *riqiLab;
//@property (strong, nonatomic) UIView *rewardView;
//@property (strong, nonatomic) UIView *rewardBorderView;
//@property (strong, nonatomic) UILabel *tipLabel;
//@property (strong, nonatomic) UIView *customRewardView;

@property (strong, nonatomic) UILabel *appreciateNum;//投金币数
@property (strong, nonatomic) UILabel *commentNum;//评论数

@property (strong, nonatomic) NSTimer *timer;//刷新锁屏页面数据计时器

@property (assign, nonatomic) BOOL isRewardBack;

@property (assign, nonatomic) BOOL isCollected;

@property (strong, nonatomic) AVPlayer *bofangPlayer;

+ (instancetype)shareInstance;
@end
__weak bofangVC *weakVC;
__weak AVPlayer *weakPlayer;
static bofangVC *_instance = nil;
@implementation bofangVC
- (AVPlayer *)bofangPlayer
{
//    static AVPlayer * player;
//    static dispatch_once_t onceToken;
//    dispatch_once(&onceToken, ^{
//        player = [[AVPlayer alloc]init];
//    });
//    return player;
    if (_bofangPlayer == nil) {
        _bofangPlayer = [[AVPlayer alloc] init];
    }
    return _bofangPlayer;
}
+ (instancetype)shareInstance {
    static dispatch_once_t onceToken ;
    dispatch_once(&onceToken, ^{
        _instance = [[self alloc] init];
        _instance.newsModel = [[NewsModel alloc] init];
    }) ;
    return _instance ;
}
- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
    isJiaZaiWan = NO;
    _isCollected = NO;
    self.titleFontSize = 19.0;
//    self.dateFont = gFontMain14;
    ExdangqianUserUid = [CommonCode readFromUserD:@"dangqianUserUid"];
    angle = 0.0f;
    [self.view addSubview:self.tableView];
    _topView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, IPHONE_W, 64)];
    _topView.backgroundColor = [UIColor clearColor];
    _topView.hidden = NO;
    [self.view addSubview:_topView];
    _leftBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    _leftBtn.frame = CGRectMake(10, 25, 35, 35);
    [_leftBtn setImageEdgeInsets:UIEdgeInsetsMake(5, 0, 5, 10)];
    [_leftBtn setImage:[UIImage imageNamed:@"title_ic_white"] forState:UIControlStateNormal];
    _leftBtn.accessibilityLabel = @"返回";
    [_leftBtn addTarget:self action:@selector(back) forControlEvents:UIControlEventTouchUpInside];
    [_topView addSubview:_leftBtn];
    UILabel *topLab = [[UILabel alloc]initWithFrame:CGRectMake(50, 30, IPHONE_W - 100, 30)];
    topLab.textColor = [UIColor whiteColor];
    topLab.font = [UIFont boldSystemFontOfSize:17.0f];
    topLab.text = @"新闻详情";
    topLab.backgroundColor = [UIColor clearColor];
    topLab.textAlignment = NSTextAlignmentCenter;
//    [_topView addSubview:topLab];
    
    _rightBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    _rightBtn.frame = CGRectMake(SCREEN_WIDTH - 55, 25, 35, 35);
    [_rightBtn setImageEdgeInsets:UIEdgeInsetsMake(5, 10, 5, 0)];
    [_rightBtn setImage:[UIImage imageNamed:@"title_ic_share_white"] forState:UIControlStateNormal];
    _rightBtn.accessibilityLabel = @"分享";
    [_rightBtn addTarget:self action:@selector(shareNewsBtnAction) forControlEvents:UIControlEventTouchUpInside];
    [_topView addSubview:_rightBtn];
    
    [self xinwenxiangqingbujv];
    [self huoqupinglunliebiao];
    if (!ShangTimer){
        ShangTimer = [NSTimer scheduledTimerWithTimeInterval: 0.01 target: self selector:@selector(xuanzhuanAction) userInfo: nil repeats: YES];
    }
    ///加载成功
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(jiazaichenggong:) name:@"jiazaichenggong" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(jiazaichenggong:) name:@"dingyuejiazaichenggong" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(pinglunchenggong:) name:@"pinglunchenggong" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(qiehuanxinwen:) name:@"qiehuanxinwen" object:nil];
//    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(houtaibofangxiayishou:) name:@"houtaibofangxiayishou" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(getActInfoNotification:) name:@"getActInfoNotification" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(getAhocComment:) name:@"getAhocComment" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector       (tingyouquanbofangwanbi:) name:TINGYOUQUANBOFANGWANBI object:nil];
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(PayResultsBack:) name:@"PayResultsBack" object:nil];
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(WechatPayResultsBack:) name:@"WechatPayResultsBack" object:nil];
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(TcoinPayResultsBack:) name:@"TcoinPayResultsBack" object:nil];
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(RewardBack:) name:@"RewardBack" object:nil];
    //监听播放完毕
//    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(PlayedidEnd:) name:AVPlayerItemDidPlayToEndTimeNotification object:Explayer.currentItem];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(playStop) name:AVPlayerItemPlaybackStalledNotification object:Explayer.currentItem];
    //定时器通知
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(timerStop:) name:@"timerStop" object:nil];
    //手势控制通知
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(captureDevice:) name:UIDeviceProximityStateDidChangeNotification object:[UIDevice currentDevice]];
    //网络连接状态改变通知
    RegisterNotify(NETWORKSTATUSCHANGE, @selector(networkChange))
    //添加手势
    UISwipeGestureRecognizer *rightSwipe = [[UISwipeGestureRecognizer alloc]initWithTarget:self action:@selector(rightSwipeAction:)];
    [rightSwipe setDirection:UISwipeGestureRecognizerDirectionRight];
    [self.view addGestureRecognizer:rightSwipe];
    
    //AudioSession负责应用音频的设置，比如支不支持后台，打断等等
    NSError *error;
    //设置音频会话
    self.session = [AVAudioSession sharedInstance];
    //AVAudioSessionCategoryPlayback一般用于支持后台播放
    [self.session setCategory:AVAudioSessionCategoryPlayback error:&error];
    //激活会话
    [self.session setActive:YES error:&error];
//    [CommonCode writeToUserD:@"YES" andKey:@"isPlayingVC"];
    
     [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleInterruption:) name:AVAudioSessionInterruptionNotification object:[AVAudioSession sharedInstance]];
    
    self.isReward = NO;
    self.isPay = NO;
    self.isCustomRewardCount = NO;
    self.isRewardBack = NO;
    
}
//新闻缓冲没有完成播放暂停调用方法
- (void)playStop
{
    RTLog(@"播放停止了");
    [self performSelector:@selector(bofangRightAction:) withObject:nil afterDelay:0.5f];
}
- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self.tableView setContentOffset:CGPointMake(0, 0) animated:NO];
    IQKeyboardManager *manager = [IQKeyboardManager sharedManager];
    manager.enable = YES;
    manager.shouldResignOnTouchOutside = YES;
    manager.shouldToolbarUsesTextFieldTintColor = NO;
    manager.enableAutoToolbar = NO;
    if (!isPlaying) {
        [[UIDevice currentDevice] setProximityMonitoringEnabled:NO];
        [[NSNotificationCenter defaultCenter] postNotificationName:@"stopAnimate" object:nil];
    }else {
        [[UIDevice currentDevice] setProximityMonitoringEnabled:[[NSUserDefaults standardUserDefaults] boolForKey:@"shoushi"]];
        [[NSNotificationCenter defaultCenter] postNotificationName:@"startAnimate" object:nil];
    }
    [self.navigationController setNavigationBarHidden:YES animated:YES];
    
    if (![ExwhichBoFangYeMianStr isEqualToString:@"Downloadbofang"]) {
//        [self handleKeyword];
        [self loadData];
    }
    [CommonCode writeToUserD:@"YES" andKey:@"isPlayingVC"];
    
    //有上一次浏览的新闻
    [CommonCode writeToUserD:@"YES" andKey:@"haveTheLastNewsData"];
    //记录上一次浏览的新闻详情
    [self recordTheLastNews];
    //获取评论列表
    [self huoqupinglunliebiao];
}

-(void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    RTLog(@"viewWillDisappear");
    [IQKeyboardManager sharedManager].enable = NO;
    [self.navigationController setNavigationBarHidden:NO animated:YES];
    if (!isPlaying) {
        [[NSNotificationCenter defaultCenter] postNotificationName:@"stopAnimate" object:nil];
    }else {
        [[NSNotificationCenter defaultCenter] postNotificationName:@"startAnimate" object:nil];
    }
    [CommonCode writeToUserD:@"NO" andKey:@"isPlayingVC"];
}

#pragma mark - NSNotification

- (void)onAudioSessionEvent:(NSNotification *)no {
    static BOOL isP = NO;
    if ([[NSString stringWithFormat:@"%@", no.userInfo[@"AVAudioSessionInterruptionTypeKey"]] isEqualToString:@"1"]) {
        if (self.isPlay) {
            isP = YES;
        }else  {
            isP = NO;
        }
        [self doPlay:bofangCenterBtn];
        
    }else {
        if (isP) {
            [self doPlay:bofangCenterBtn];
        }
        isP = NO;
    }
}


- (void)qiehuanxinwen:(NSNotification *)notification {
    if ([[NSString stringWithFormat:@"%@",self.newsModel.jiemuIs_fan] isEqualToString:@"0"]){
        isGuanZhu = NO;
    }
    else{
        isGuanZhu = YES;
    }
    isDianZan = NO;
    dianzanshu = self.newsModel.praisenum;
    if ([[CommonCode readFromUserD:@"jiaDianZanShuJv"] isKindOfClass:[NSArray class]]){
        jiaDianZanShuJv = [NSMutableArray arrayWithArray:[CommonCode readFromUserD:@"jiaDianZanShuJv"]];
    }
    else{
        jiaDianZanShuJv = [NSMutableArray array];
    }
    for (NSDictionary *dic in jiaDianZanShuJv){
        if ([dic[@"jiemuID"] isEqualToString:self.newsModel.jiemuID]){
            if ([dic[@"isdianzan"] isEqualToString:@"YES"]){
                isDianZan = YES;
                dianzanshu = dic[@"praisenum"];
                break;
            }
        }
    }
    dianzanshu = self.newsModel.praisenum;
    self.sliderProgress.maximumValue = [self.newsModel.post_time intValue] / 1000;
    [self huoqupinglunliebiao];
    [self loadData];
//    [self handleKeyword];
    [self.tableView reloadData];
}

- (void)pinglunchenggong:(NSNotification *)notification{
    
    [self huoqupinglunliebiao];
}

- (void)getAhocComment:(NSNotification *)notification {
    
    self.newsModel.jiemuID = notification.object;
    [self huoqupinglunliebiao];
}

- (void)tingyouquanbofangwanbi:(NSNotification *)notification {
        [Explayer pause];
}

- (void)getActInfoNotification:(NSNotification *)notification{
    
    [NetWorkTool getAllActInfoListWithAccessToken:AvatarAccessToken
                                            ac_id:notification.object
                                          keyword:nil
                                          andPage:nil
                                         andLimit:nil sccess:^(NSDictionary *responseObject) {
                                             if ([responseObject[@"status"] integerValue] == 1) {
                                                 if ([responseObject[@"results"] isKindOfClass:[NSArray class]]) {
                                                     self.newsModel.jiemuName = [responseObject[@"results"] firstObject][@"name"];
                                                     self.newsModel.jiemuDescription = [responseObject[@"results"] firstObject][@"description"];
                                                     self.newsModel.jiemuImages = [responseObject[@"results"] firstObject][@"images"];
                                                     self.newsModel.jiemuFan_num = [responseObject[@"results"] firstObject][@"fan_num"];
                                                     self.newsModel.jiemuMessage_num = [responseObject[@"results"] firstObject][@"message_num"];
                                                     self.newsModel.jiemuIs_fan = [responseObject[@"results"] firstObject][@"is_fan"];
                                                     self.newsModel.post_news = [responseObject[@"results"] firstObject][@"id"];

                                                     [self.tableView reloadData];
                                                 }
                                                 
                                             }
                                             
                                         } failure:^(NSError *error) {
                                             //
                                         }];
}

- (void)PayResultsBack:(NSNotification *)notification {
    
    NSString* title=@"PaySuccess1",*msg=@"您已赞赏成功",*sureTitle=@"确定" , *cancelTitle=@"取消吧";
    AKAlertView* av;
    
    NSDictionary *resultDic = notification.object;
        if ([resultDic[@"resultStatus"]integerValue] == 9000) {
            //支付成功
            NSMutableDictionary *dic = [CommonCode readFromUserD:REWARDINFODICTKEY];
            if ([[CommonCode readFromUserD:@"isLogin"]boolValue] == YES){
                [NetWorkTool listenMoneyRechargeWithaccessToken:AvatarAccessToken listen_money:dic[@"listen_money"] act_id:dic[@"act_id"] post_id:dic[@"post_id"]  type:dic[@"type"] sccess:^(NSDictionary *responseObject) {
                    //
                } failure:^(NSError *error) {
                    //
                }];
            }
            else{
                
            }
            
            title=@"PaySuccess1",msg=@"您已赞赏成功",sureTitle=@"确定";
            av= [AKAlertView alertView:title des:msg  type:AKAlertSuccess effect:AKAlertEffectDrop sureTitle:sureTitle cancelTitle:cancelTitle];
        }
        else if ([resultDic[@"resultStatus"]integerValue] == 8000){
            //正在处理中
            av= [AKAlertView alertView:title des:msg  type:AKAlertSuccess effect:AKAlertEffectDrop sureTitle:sureTitle cancelTitle:cancelTitle];
        }
        else if ([resultDic[@"resultStatus"]integerValue] == 4000){
            //订单支付失败
            title=@"PayFail1";msg=@"返回信息错误，请稍后再试";sureTitle=@"确定";
            av= [AKAlertView alertView:title des:msg  type:AKAlertFaild effect:AKAlertEffectDrop sureTitle:sureTitle cancelTitle:cancelTitle];
        }
        else if ([resultDic[@"resultStatus"]integerValue] == 6001){
            //用户中途取消
            title=@"PayFail1";msg=@"用户中途取消，请稍后再试";sureTitle=@"确定";
            av= [AKAlertView alertView:title des:msg  type:AKAlertFaild effect:AKAlertEffectDrop sureTitle:sureTitle cancelTitle:cancelTitle];
//            title=@"PaySuccess1",msg=@"您已赞赏成功",sureTitle=@"确定";
//            av= [AKAlertView alertView:title des:msg  type:AKAlertSuccess effect:AKAlertEffectDrop sureTitle:sureTitle cancelTitle:cancelTitle];
        }
        else if ([resultDic[@"resultStatus"]integerValue] == 6002){
            //网络连接出错
            title=@"PayFail1";msg=@"网络连接出错，请稍后再试";sureTitle=@"确定";
            av= [AKAlertView alertView:title des:msg  type:AKAlertFaild effect:AKAlertEffectDrop sureTitle:sureTitle cancelTitle:cancelTitle];
        }
        else{
            //
            title=@"PayFail1";msg=@"返回信息错误，请稍后再试";sureTitle=@"确定";
            av= [AKAlertView alertView:title des:msg  type:AKAlertFaild effect:AKAlertEffectDrop sureTitle:sureTitle cancelTitle:cancelTitle];
        }
    
    av.sureClick=^(AKAlertView* av,BOOL isMessageSelected,NSString *message){
        [self rewardMessageWithmessage:message andIsToShare:isMessageSelected];
    };
    [av show];
    //充值成功 --》 获取用户信息
    [[NSNotificationCenter defaultCenter] postNotificationName:@"updateUserInfo" object:nil];
}

- (void)WechatPayResultsBack:(NSNotification *)notification{
    NSString* title=@"PaySuccess1",*msg=@"您已赞赏成功",*sureTitle=@"确定" , *cancelTitle=@"取消吧";
    AKAlertView* av;
    if ([notification.object integerValue] == 0) {
        NSMutableDictionary *dic = [CommonCode readFromUserD:REWARDINFODICTKEY];
        if ([[CommonCode readFromUserD:@"isLogin"]boolValue] == YES){
            [NetWorkTool listenMoneyRechargeWithaccessToken:AvatarAccessToken listen_money:dic[@"listen_money"] act_id:dic[@"act_id"] post_id:dic[@"post_id"] type:dic[@"type"] sccess:^(NSDictionary *responseObject) {
                //
            } failure:^(NSError *error) {
                //
            }];
        }
        else{
            
        }
        title=@"PaySuccess1",msg=@"您已赞赏成功",sureTitle=@"确定";
        av= [AKAlertView alertView:title des:msg  type:AKAlertSuccess effect:AKAlertEffectDrop sureTitle:sureTitle cancelTitle:cancelTitle];
    }
    else if ([notification.object integerValue] == -2){
        title=@"PayFail1";msg=@"用户中途取消，请稍后再试";sureTitle=@"确定";
        av= [AKAlertView alertView:title des:msg  type:AKAlertFaild effect:AKAlertEffectDrop sureTitle:sureTitle cancelTitle:cancelTitle];
//        title=@"PaySuccess1",msg=@"您已赞赏成功",sureTitle=@"确定";
//        av= [AKAlertView alertView:title des:msg  type:AKAlertSuccess effect:AKAlertEffectDrop sureTitle:sureTitle cancelTitle:cancelTitle];
    }
    else{
        title=@"PayFail1";msg=@"返回信息错误，请稍后再试";sureTitle=@"确定";
        av= [AKAlertView alertView:title des:msg  type:AKAlertFaild effect:AKAlertEffectDrop sureTitle:sureTitle cancelTitle:cancelTitle];
    }
    
    av.sureClick=^(AKAlertView* av,BOOL isMessageSelected,NSString *message){
        [av removeFromSuperview];
        [self rewardMessageWithmessage:message andIsToShare:isMessageSelected];
    };
    
    [av show];
    //充值成功 --》 获取用户信息
    [[NSNotificationCenter defaultCenter] postNotificationName:@"updateUserInfo" object:nil];
}

- (void)TcoinPayResultsBack:(NSNotification *)notification{
    NSString* title=@"PaySuccess1",*msg=@"您已赞赏成功",*sureTitle=@"确定" , *cancelTitle=@"取消吧";
    AKAlertView* av;
    av= [AKAlertView alertView:title des:msg  type:AKAlertSuccess effect:AKAlertEffectDrop sureTitle:sureTitle cancelTitle:cancelTitle];
    av.sureClick=^(AKAlertView* av,BOOL isMessageSelected,NSString *message){
        [self rewardMessageWithmessage:message andIsToShare:isMessageSelected];
    };
    [av show];
    //充值成功 --》 获取用户信息
    [[NSNotificationCenter defaultCenter] postNotificationName:@"updateUserInfo" object:nil];
}

- (void)RewardBack:(NSNotification *)notification{
    self.isRewardBack = YES;
    [self.tableView reloadData];
    
}

- (void)rewardMessageWithmessage:(NSString *)message andIsToShare:(BOOL )isToShare{
    if ([[CommonCode readFromUserD:@"isLogin"]boolValue] == YES && [message length] > 0){
         NSMutableDictionary *dic = [CommonCode readFromUserD:REWARDINFODICTKEY];
        [NetWorkTool rewardedMessageWithaccessToken:AvatarAccessToken act_id:dic[@"act_id"] message:message sccess:^(NSDictionary *responseObject) {
            //
        } failure:^(NSError *error) {
            //
        }];
    }
    if (isToShare) {
        dispatch_sync(dispatch_get_main_queue(), ^{
             [self shareNewsBtnAction];
        });
        
    }
}


#pragma mark --- 新闻详情的布局

- (void)huoqupinglunliebiao{
    //获取评论列表
    [NetWorkTool getPaoGuoJieMuPingLunLieBiaoWithJieMuID:self.newsModel.jiemuID anduid:ExdangqianUserUid andPage:@"1" andLimit:@"10" sccess:^(NSDictionary *responseObject) {
        RTLog(@"%@",responseObject[@"results"]);
        if ([responseObject[@"results"] isKindOfClass:[NSArray class]])
        {
            NSArray *array = [PlayVCCommentModel mj_objectArrayWithKeyValuesArray:responseObject[@"results"]];
            self.pinglunArr = [self pinglunFrameModelArrayWithModelArray:array];
            [self.commentNum setText:[NSString stringWithFormat:@"%lu",(unsigned long)self.pinglunArr.count]];
        }
        else{
            self.pinglunArr = [NSMutableArray array];
            [self.commentNum setText:@"0"];
        }
        [self.tableView reloadData];
    } failure:^(NSError *error) {
        RTLog(@"error = %@",error);
    }];
}
- (NSMutableArray *)pinglunFrameModelArrayWithModelArray:(NSArray *)array
{
    NSMutableArray *frameArray = [NSMutableArray array];
    for (PlayVCCommentModel *model in array) {
        PlayVCCommentFrameModel *frameModel = [[PlayVCCommentFrameModel alloc] init];
        frameModel.model = model;
        [frameArray addObject:frameModel];
    }
    return frameArray;
}
- (void)xinwenxiangqingbujv{
    
    dibuView = [[UIView alloc]initWithFrame:CGRectMake(0, IPHONE_H - 109.0 / 667 * IPHONE_H, IPHONE_W, 109.0 / 667 * IPHONE_H)];
    dibuView.backgroundColor = [UIColor whiteColor];
    [self.view addSubview:dibuView];
    //底部收藏按钮
    UIButton *bofangfenxiangBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    bofangfenxiangBtn.frame = CGRectMake(IPHONE_W - 52.0 / 375 * IPHONE_W, 54.0 / 667 * IPHONE_H, 32.0 / 667 * IPHONE_H, 32.0 / 667 * IPHONE_H);
    [bofangfenxiangBtn setImageEdgeInsets:UIEdgeInsetsMake(5, 5, 7, 7)];
    [bofangfenxiangBtn setImage:[UIImage imageNamed:@"home_news_collection"] forState:UIControlStateNormal];
    [bofangfenxiangBtn setTag:99];
    bofangfenxiangBtn.accessibilityLabel = @"收藏";
    [bofangfenxiangBtn addTarget:self action:@selector(collect) forControlEvents:UIControlEventTouchUpInside];
    bofangfenxiangBtn.contentMode = UIViewContentModeScaleToFill;
    [dibuView addSubview:bofangfenxiangBtn];
    
//    UILabel *fenxiangLab = [[UILabel alloc]initWithFrame:CGRectMake(bofangfenxiangBtn.frame.origin.x - 1.5 / 375 * IPHONE_W, CGRectGetMaxY(bofangfenxiangBtn.frame) + 3.0 - 10.0 / 667 * IPHONE_H, bofangfenxiangBtn.frame.size.width + 3.0 / 375 * IPHONE_W, 15.0 / 667 * IPHONE_H)];
//    fenxiangLab.text = @"下载";
//    fenxiangLab.textColor = [UIColor grayColor];
//    fenxiangLab.font = [UIFont systemFontOfSize:12.0f ];
//    fenxiangLab.textAlignment = NSTextAlignmentCenter;
//    fenxiangLab.alpha = 0.7f;
//    [dibuView addSubview:fenxiangLab];
//    UITapGestureRecognizer *fenxiangTap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(fenxiangTapAction:)];
//    [fenxiangLab addGestureRecognizer:fenxiangTap];
//    fenxiangLab.userInteractionEnabled = YES;
    
    //底部定时按钮
    UIButton *bofangdingshiBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    bofangdingshiBtn.frame = CGRectMake(20.0 / 375 * IPHONE_W, 54.0 / 667 * IPHONE_H, 32.0 / 667 * IPHONE_H, 32.0 / 667 * IPHONE_H);
    [bofangdingshiBtn setImage:[UIImage imageNamed:@"home_news_ic_time"] forState:UIControlStateNormal];
    [bofangdingshiBtn setImageEdgeInsets:UIEdgeInsetsMake(5, 5, 5, 5)];
    bofangdingshiBtn.accessibilityLabel = @"定时";
    [bofangdingshiBtn addTarget:self action:@selector(bofangdingshiBtnAction:) forControlEvents:UIControlEventTouchUpInside];
    bofangdingshiBtn.contentMode = UIViewContentModeScaleToFill;
    [dibuView addSubview:bofangdingshiBtn];
    
//    UILabel *dingshiLab = [[UILabel alloc]initWithFrame:CGRectMake(bofangdingshiBtn.frame.origin.x - 5.0 / 375 * SCREEN_WIDTH, CGRectGetMaxY(bofangdingshiBtn.frame) + 3.0 / 667 * IPHONE_H, bofangfenxiangBtn.frame.size.width + 3.0 / 375 * IPHONE_W, 15.0 / 667 * IPHONE_H)];
//    dingshiLab.text = @"定时";
//    dingshiLab.textColor = [UIColor grayColor];
//    dingshiLab.textAlignment = NSTextAlignmentCenter;
//    dingshiLab.alpha = 0.7f;
//    [dibuView addSubview:dingshiLab];
//    UITapGestureRecognizer *dingshiTap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(dingshiTapAction:)];
//    dingshiLab.font = [UIFont systemFontOfSize:12.0f ];
//    [dingshiLab addGestureRecognizer:dingshiTap];
//    dingshiLab.userInteractionEnabled = YES;
    
    UIView *dibuTopLine = [[UIView alloc]initWithFrame:CGRectMake(0, 0, IPHONE_W, 0.5)];
    dibuTopLine.backgroundColor = [UIColor grayColor];
    dibuTopLine.alpha = 0.5f;
    [dibuView addSubview:dibuTopLine];
    
    [self bofangqiSet];
}
#pragma mark - 播放器设置
- (void)bofangqiSet{
    self.isFirst = YES;
    //程序刚运行时，有播放
    isPlaying = NO;
    self.isPlay = isPlaying;
//    self.sliderProgress.value = 0;
    
    //底部播放左按钮
    bofangLeftBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    bofangLeftBtn.frame = CGRectMake(104.5 / 375 * IPHONE_W, 54.0 / 667 * IPHONE_H, 32.0 / 667 * IPHONE_H, 32.0 / 667 * IPHONE_H);
    [bofangLeftBtn setImage:[UIImage imageNamed:@"home_news_ic_before"] forState:UIControlStateNormal];
    bofangLeftBtn.accessibilityLabel = @"上一条新闻";
    [bofangLeftBtn addTarget:self action:@selector(bofangLeftAction:) forControlEvents:UIControlEventTouchUpInside];
    bofangLeftBtn.contentMode = UIViewContentModeScaleToFill;
    [dibuView addSubview:bofangLeftBtn];
    
    //底部播放右按钮
    bofangRightBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    bofangRightBtn.frame = CGRectMake(IPHONE_W - 104.5 / 375 * SCREEN_WIDTH -  bofangLeftBtn.frame.size.width, bofangLeftBtn.frame.origin.y, bofangLeftBtn.frame.size.width,bofangLeftBtn.frame.size.height);
    [bofangRightBtn setImage:[UIImage imageNamed:@"home_news_ic_next"] forState:UIControlStateNormal];
    bofangRightBtn.accessibilityLabel = @"下一则新闻";
    [bofangRightBtn addTarget:self action:@selector(bofangRightAction:) forControlEvents:UIControlEventTouchUpInside];
    bofangRightBtn.contentMode = UIViewContentModeScaleToFill;
    [dibuView addSubview:bofangRightBtn];
    
    //底部播放暂停按钮
    bofangCenterBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    bofangCenterBtn.frame = CGRectMake((IPHONE_W  - bofangLeftBtn.frame.size.width)/ 2, bofangLeftBtn.frame.origin.y, bofangLeftBtn.frame.size.width ,bofangLeftBtn.frame.size.height);
    [bofangCenterBtn setImage:[UIImage imageNamed:@"home_news_ic_play"] forState:UIControlStateNormal];
    bofangCenterBtn.accessibilityLabel = @"播放";
    [bofangCenterBtn addTarget:self action:@selector(doPlay:) forControlEvents:UIControlEventTouchUpInside];
    bofangCenterBtn.contentMode = UIViewContentModeScaleToFill;
    
    //初始时，禁用播放按钮
    [bofangCenterBtn setEnabled:NO];
    if (self.newsModel.post_mp.length > 0){
        
    }
    Explayer = self.bofangPlayer;
    //添加观察者，用来监视播放器的状态变化
    [Explayer addObserver:self forKeyPath:@"status" options:NSKeyValueObservingOptionNew context:nil];
    //添加观察者，用来监听播放器的缓冲进度loadedTimeRanges属性
    [Explayer addObserver:self forKeyPath:@"loadedTimeRanges" options:NSKeyValueObservingOptionNew context:nil];
    
    //新闻时长
    if (IS_IPAD) {
        self.yinpinzongTime = [[UILabel alloc]initWithFrame:CGRectMake(SCREEN_WIDTH - 70.0 / 375 * SCREEN_WIDTH, 32.0 / 667 * IPHONE_H, 50.0 / 375 * IPHONE_W, 20.0 / 667 * IPHONE_H)];
    }
    else{
       self.yinpinzongTime = [[UILabel alloc]initWithFrame:CGRectMake(SCREEN_WIDTH - 70.0 / 375 * SCREEN_WIDTH, 32.0 / 667 * IPHONE_H, 50.0 / 375 * IPHONE_W, 20.0 / 667 * IPHONE_H)];
    }
    
    self.yinpinzongTime.textColor = nTextColorMain;
    [self.yinpinzongTime setTextAlignment:NSTextAlignmentRight];
    self.yinpinzongTime.font = [UIFont systemFontOfSize:12.0f ];
    [self reloadPlayAllTime];/**<刷新音频总时长*/
    
    [dibuView addSubview:self.yinpinzongTime];
    
    //当前时间
    if (IS_IPAD) {
        dangqianTime = [[UILabel alloc]initWithFrame:CGRectMake(20.0 / 375 * IPHONE_W, 32.0 / 667 * IPHONE_H, 50.0 / 375 * IPHONE_W, 20.0 / 667 * IPHONE_H)];
    }
    else{
       dangqianTime = [[UILabel alloc]initWithFrame:CGRectMake(20.0 / 375 * IPHONE_W, 32.0 / 667 * IPHONE_H, 50.0 / 375 * IPHONE_W, 20.0 / 667 * IPHONE_H)];
    }
    
    dangqianTime.textColor = gMainColor;
    dangqianTime.font = [UIFont systemFontOfSize:12.0f ];
    dangqianTime.text = @"00:00";
    [dibuView addSubview:dangqianTime];
    
    //播放完毕后监听通知
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(PlayedidEnd:) name:AVPlayerItemDidPlayToEndTimeNotification object:Explayer.currentItem];
    
    weakVC = self;
    
    weakPlayer = Explayer;
    
    self.sliderProgress.continuous = YES;
    [self.sliderProgress setThumbImage:[UIImage imageNamed:@"slider"] forState:UIControlStateNormal];
    self.sliderProgress.minimumTrackTintColor = gMainColor;
    self.sliderProgress.maximumTrackTintColor = [UIColor clearColor];
    [self.sliderProgress addTarget:self action:@selector(doChangeProgress:) forControlEvents:UIControlEventValueChanged];
    
    if (IS_IPAD) {
        self.prgBufferProgress.frame = CGRectMake(20.0 / 375 * IPHONE_W, 22.0 / 667 * IPHONE_H, SCREEN_WIDTH - 40.0 / 375 * SCREEN_WIDTH, 2.0);
    }
    else if (TARGETED_DEVICE_IS_IPHONE_736){
        self.prgBufferProgress.frame = CGRectMake(20.0 / 375 * IPHONE_W, 22.0 / 667 * IPHONE_H, SCREEN_WIDTH - 40.0 / 375 * SCREEN_WIDTH, 2.0);
    }else if (TARGETED_DEVICE_IS_IPHONE_667){
        self.prgBufferProgress.frame = CGRectMake(20.0 / 375 * IPHONE_W, 22.0 / 667 * IPHONE_H, SCREEN_WIDTH - 40.0 / 375 * SCREEN_WIDTH, 2.0);
    }else if (TARGETED_DEVICE_IS_IPHONE_568){
        self.prgBufferProgress.frame = CGRectMake(20.0 / 375 * IPHONE_W, 22.0 / 667 * IPHONE_H, SCREEN_WIDTH - 40.0 / 375 * SCREEN_WIDTH, 2.0);
    }
    else{
        self.prgBufferProgress.frame = CGRectMake(20.0 / 375 * IPHONE_W, 22.0 / 667 * IPHONE_H, SCREEN_WIDTH - 40.0 / 375 * SCREEN_WIDTH, 2.0);
    }
    
    self.prgBufferProgress.progressTintColor = gMainColor;;
    [dibuView addSubview:self.prgBufferProgress];
    [dibuView addSubview:self.sliderProgress];
    self.sliderProgress.maximumTrackTintColor = [UIColor clearColor];
    
    [dibuView addSubview:bofangCenterBtn];
    
    if (timeObserver != nil) {
        [Explayer removeTimeObserver:timeObserver];
        timeObserver = nil;
    }
    timeObserver = [Explayer addPeriodicTimeObserverForInterval:CMTimeMake(1, 1) queue:dispatch_get_main_queue() usingBlock:^(CMTime time) {
        //获取当前播放时间
        float currentTime = (float)weakPlayer.currentItem.currentTime.value / (float)weakPlayer.currentItem.currentTime.timescale;
        int testTime = (int)currentTime;
        weakVC.sliderProgress.value = currentTime;
        //更新缓冲进度
        if ([ExwhichBoFangYeMianStr isEqualToString:@"Downloadbofang"]){
            
        }
        NSTimeInterval timeInterval = [weakVC availableDuration];//计算缓冲进度

        dangqianTime.text = [self convertStringWithTime:testTime];
        CMTime duration = weakPlayer.currentItem.duration;
        CGFloat totalDuration = CMTimeGetSeconds(duration);
        [weakVC.prgBufferProgress setProgress:timeInterval / totalDuration animated:YES];
        
    }];
}
//计算缓冲进度
- (NSTimeInterval)availableDuration{
    
    NSArray *loadedTimeRanges = [[Explayer currentItem]loadedTimeRanges];
    CMTimeRange timeRange = [loadedTimeRanges.firstObject CMTimeRangeValue];//获取缓冲区域
    float startSeconds = CMTimeGetSeconds(timeRange.start);
    float durationSeconds = CMTimeGetSeconds(timeRange.duration);
    NSTimeInterval result = startSeconds + durationSeconds;//计算缓冲总进度
    return result;
}
//观察者方法，用来监听播放状态
- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSString *,id> *)change context:(void *)context
{
    //当播放器状态（status）改变时，会进入此判断
    if ([keyPath isEqualToString:@"status"])
    {
        switch (Explayer.status) {
            case AVPlayerStatusUnknown:
                RTLog(@"KVO：未知状态，此时不能播放");
                break;
            case AVPlayerStatusReadyToPlay:
                [bofangCenterBtn setEnabled:YES];
                RTLog(@"KVO：准备完毕，可以播放");
                //自动播放
                if (self.isFirst == YES){
                    if (self.isPushNews) {
                        [Explayer play];
                    }
                    else{
                        [self performSelector:@selector(doPlay:) withObject:nil afterDelay:0.5f];
                        self.isFirst = NO;
                    }
                }
                
                break;
            case AVPlayerStatusFailed:
                RTLog(@"KVO：加载失败，网络或者服务器出现问题");
                [self performSelector:@selector(bofangRightAction:) withObject:nil afterDelay:0.5f];
                break;
            default:
                break;
        }
    }else if ([keyPath isEqualToString:@"loadedTimeRanges"])
    {
        AVPlayerItem *songItem = object;
        NSArray *array = songItem.loadedTimeRanges;
        CMTimeRange timeRange = [array.firstObject CMTimeRangeValue];//本次缓冲的时间范围
        NSTimeInterval totalBuffer = CMTimeGetSeconds(timeRange.start) + CMTimeGetSeconds(timeRange.duration);//缓冲总长度
        RTLog(@"共缓冲%.2f",totalBuffer);
    }
}
//播放音频
- (void)doPlay:(UIButton *)sender {
    if (isPlaying){
        [[UIDevice currentDevice] setProximityMonitoringEnabled:NO];
        [Explayer pause];
        isPlaying = NO;
        self.isPlay = isPlaying;
        [bofangCenterBtn setImage:[UIImage imageNamed:@"home_news_ic_play"] forState:UIControlStateNormal];
        self.sliderProgress.maximumValue = [self.newsModel.post_time intValue] / 1000;
    }
    else{
        [[UIDevice currentDevice] setProximityMonitoringEnabled:[[NSUserDefaults standardUserDefaults] boolForKey:@"shoushi"]];
        isPlaying = YES;
        self.isPlay = isPlaying;
        [Explayer play];
        [bofangCenterBtn setImage:[UIImage imageNamed:@"home_news_ic_pause"] forState:UIControlStateNormal];
        bofangCenterBtn.accessibilityLabel = @"暂停、播放";
        //获取当前播放音视频的总长度（s秒)
        self.sliderProgress.maximumValue = [self.newsModel.post_time intValue] / 1000;
//         RTLog(@"总长度 = %f",self.sliderProgress.maximumValue);
//
    }
    [self configNowPlayingInfoCenter];
}
//拖拽播放进度
- (void)doChangeProgress:(UISlider *)sender{
    
    [Explayer pause];
    //调到指定时间去播放
    [Explayer seekToTime:CMTimeMake(self.sliderProgress.value, 1) completionHandler:^(BOOL finished) {
        RTLog(@"拖拽结果：%d",finished);
        if (finished == YES){
            [Explayer play];
        }
    }];
    [[UIDevice currentDevice] setProximityMonitoringEnabled:[[NSUserDefaults standardUserDefaults] boolForKey:@"shoushi"]];
}
//播放完毕时调用的方法
- (void)PlayedidEnd:(NSNotification *)notice
{
    [self performSelector:@selector(bofangwanbi:) withObject:notice afterDelay:0.5f];
}

#pragma mark - 计算音频总时长方法
- (void)reloadPlayAllTime
{
    self.yinpinzongTime.text = [self convertStringWithTime:[self.newsModel.post_time intValue] / 1000];
//    if ([self.newsModel.post_time intValue] / 1000 / 60)
//    {
//        if ([self.newsModel.post_time intValue] / 1000 / 60 > 9)
//        {
//            self.yinpinzongTime.text = [NSString stringWithFormat:@"%d:%d",[self.newsModel.post_time intValue] / 1000 / 60,[self.newsModel.post_time intValue] / 1000 % 60];
//        }else
//        {
//            if ([self.newsModel.post_time intValue] / 1000 % 60 < 10)
//            {
//                self.yinpinzongTime.text = [NSString stringWithFormat:@"0%d:0%d",[self.newsModel.post_time intValue] / 1000 / 60,[self.newsModel.post_time intValue] / 1000 % 60];
//            }else
//            {
//                self.yinpinzongTime.text = [NSString stringWithFormat:@"0%d:%d",[self.newsModel.post_time intValue] / 1000 / 60,[self.newsModel.post_time intValue] / 1000 % 60];
//            }
//        }
//    }else
//    {
//        if ([self.newsModel.post_time intValue] / 1000 > 10)
//        {
//            self.yinpinzongTime.text = [NSString stringWithFormat:@"00:%d",[self.newsModel.post_time intValue] / 1000 % 60];
//        }else
//        {
//            self.yinpinzongTime.text = [NSString stringWithFormat:@"00:0%d",[self.newsModel.post_time intValue] / 1000 % 60];
//        }
//    }
}
#pragma mark - 私有方法转换时间为时分秒
- (NSString *)convertStringWithTime:(float)time {
    if (isnan(time)) time = 0.f;
    int min = time / 60.0;
    int sec = time - min * 60;
    NSString * minStr = min > 9 ? [NSString stringWithFormat:@"%d",min] : [NSString stringWithFormat:@"0%d",min];
    NSString * secStr = sec > 9 ? [NSString stringWithFormat:@"%d",sec] : [NSString stringWithFormat:@"0%d",sec];
    NSString * timeStr = [NSString stringWithFormat:@"%@:%@",minStr, secStr];
    return timeStr;
}
#pragma mark - 设置新闻模型数据
- (void)playActionWithNextIndex:(NSUInteger)index
{
    self.newsModel.Titlejiemu = arr[ExcurrentNumber - index][@"post_title"];
    self.newsModel.RiQijiemu = arr[ExcurrentNumber - index][@"post_date"];
    self.newsModel.ImgStrjiemu = arr[ExcurrentNumber - index][@"smeta"];
    self.newsModel.post_lai = arr[ExcurrentNumber - index][@"post_lai"];
    self.newsModel.post_news = arr[ExcurrentNumber - index][@"post_news"];
    self.newsModel.post_mp = arr[ExcurrentNumber - index][@"post_mp"];
    self.newsModel.post_time = arr[ExcurrentNumber - index][@"post_time"];
    self.newsModel.jiemuImages = arr[ExcurrentNumber - index][@"post_act"][@"images"];
    self.newsModel.jiemuName = arr[ExcurrentNumber - index][@"post_act"][@"name"];
    self.newsModel.jiemuDescription = arr[ExcurrentNumber - index][@"post_act"][@"description"];
    self.newsModel.jiemuFan_num = arr[ExcurrentNumber - index][@"post_act"][@"fan_num"];
    self.newsModel.jiemuMessage_num = arr[ExcurrentNumber - index][@"post_act"][@"message_num"];
    self.newsModel.jiemuIs_fan = arr[ExcurrentNumber - index][@"post_act"][@"is_fan"];
    self.newsModel.post_keywords = arr[ExcurrentNumber - index][@"post_keywords"];
    self.newsModel.url = arr[ExcurrentNumber - index][@"url"];
    self.newsModel.ImgStrjiemu = arr[ExcurrentNumber - index][@"smeta"];
    self.newsModel.ZhengWenjiemu =  arr[ExcurrentNumber - index][@"post_excerpt"];
    self.newsModel.praisenum =  arr[ExcurrentNumber - index][@"praisenum"];
}
#pragma mark - 抽出共用方法
- (void)sameMethod
{
//    [Explayer.currentItem cancelPendingSeeks];
//    [Explayer.currentItem.asset cancelLoading];
//    [Explayer replaceCurrentItemWithPlayerItem:nil];/**<清空之前设置的值，改善内存泄露问题*/
    [self reloadPlayAllTime];/**<刷新音频总时长*/
    dianzanshu = self.newsModel.praisenum;
    self.sliderProgress.maximumValue = [self.newsModel.post_time intValue] / 1000;
//    [self handleKeyword];
    [self loadData];
    [self huoqupinglunliebiao];
    [self configNowPlayingInfoCenter];
    [self.tableView reloadData];
    [self.tableView setContentOffset:CGPointMake(0, 0) animated:NO];
    
    if ([ExwhichBoFangYeMianStr isEqualToString:@"Downloadbofang"]){
        [Explayer replaceCurrentItemWithPlayerItem:[[AVPlayerItem alloc]initWithURL:[NSURL fileURLWithPath:self.newsModel.post_mp]]];
    }
    else{
        [Explayer replaceCurrentItemWithPlayerItem:[[AVPlayerItem alloc]initWithURL:[NSURL URLWithString:self.newsModel.post_mp]]];
    }
    
    if (ExisRigester == NO)
    {
        //添加观察者，用来监视播放器的状态变化
        [Explayer addObserver:self forKeyPath:@"status" options:NSKeyValueObservingOptionNew context:nil];
        //添加观察者，用来监听播放器的缓冲进度loadedTimeRanges属性
        [Explayer addObserver:self forKeyPath:@"loadedTimeRanges" options:NSKeyValueObservingOptionNew context:nil];
        ExisRigester = YES;
    }
    [bofangRightBtn setEnabled:NO];
    [bofangLeftBtn setEnabled:NO];
    [bofangCenterBtn setEnabled:NO];
    [self doPlay:bofangCenterBtn];
    [self performSelector:@selector(doplay2) withObject:nil afterDelay:0.5f];
    
    [CommonCode writeToUserD:arr[ExcurrentNumber][@"id"] andKey:@"dangqianbofangxinwenID"];
    if ([[CommonCode readFromUserD:@"yitingguoxinwenID"] isKindOfClass:[NSArray class]])
    {
        NSMutableArray *yitingguoArr = [NSMutableArray arrayWithArray:[CommonCode readFromUserD:@"yitingguoxinwenID"]];
        [yitingguoArr addObject:arr[ExcurrentNumber][@"id"]];
        [CommonCode writeToUserD:yitingguoArr andKey:@"yitingguoxinwenID"];
    }else
    {
        NSMutableArray *yitingguoArr = [NSMutableArray array];
        [yitingguoArr addObject:arr[ExcurrentNumber][@"id"]];
        [CommonCode writeToUserD:yitingguoArr andKey:@"yitingguoxinwenID"];
    }
    [[NSNotificationCenter defaultCenter] postNotificationName:@"gaibianyanse" object:nil];
}
#pragma mark - 点击左边按钮
- (void)bofangLeftAction:(UIButton *)sender{
    RTLog(@"bofangLeftAction--------");
    if ([[CommonCode readFromUserD:@"zhuyeliebiao"] isKindOfClass:[NSArray class]]){
        
        if (ExcurrentNumber == 0){
            RTLog(@"后面没有新闻了");
            [[NSNotificationCenter defaultCenter] postNotificationName:@"gaibianyanse" object:nil];
        }
        else{
            if (ExisRigester == YES){
                [Explayer removeObserver:self forKeyPath:@"status"];
                [Explayer removeObserver:self forKeyPath:@"loadedTimeRanges"];
                ExisRigester = NO;
            }
            
            
            arr = [NSMutableArray arrayWithArray:[CommonCode readFromUserD:@"zhuyeliebiao"]];
            if ((ExcurrentNumber - 1) > [arr count] ) {
                self.newsModel.jiemuID = [arr firstObject][@"id"];
                ExcurrentNumber = 1;
            }
            else{
                self.newsModel.jiemuID = arr[ExcurrentNumber - 1][@"id"];
            }
            
            [CommonCode writeToUserD:self.newsModel.jiemuID andKey:@"dangqianbofangxinwenID"];
            
            [NetWorkTool getPaoGuoJieMuPingLunLieBiaoWithJieMuID:[CommonCode readFromUserD:@"dangqianbofangxinwenID"] anduid:ExdangqianUserUid andPage:@"1" andLimit:@"10" sccess:^(NSDictionary *responseObject) {
                if ([responseObject[@"results"] isKindOfClass:[NSArray class]])
                {
                    self.pinglunArr = [NSMutableArray arrayWithArray:[self pinglunFrameModelArrayWithModelArray:[PlayVCCommentModel mj_objectArrayWithKeyValuesArray:responseObject[@"results"]]]];
                }else
                {
                    self.pinglunArr = [NSMutableArray array];
                }
                [self.tableView reloadData];
            } failure:^(NSError *error) {
                RTLog(@"error = %@",error);
            }];
            [CommonCode writeToUserD:arr[ExcurrentNumber - 1] andKey:@"dangqianbofangxinwen"];
            //设置新闻模型数据
            [self playActionWithNextIndex:1];
            ExcurrentNumber --;
            //公共方法
            [self sameMethod];
            //记录上一次浏览的新闻详情
            [self recordTheLastNews];
        }
    }
    
    RTLog(@"播放后退");
}
- (void)bofangRightAction:(UIButton *)sender {
    RTLog(@"bofangRightAction--------");
    static NSInteger tishi = 0;
    tishi ++;
    if ([[NSUserDefaults standardUserDefaults]boolForKey:@"shoushitixing"] && tishi == 5 && !IS_IPAD) {
        
        [[NSUserDefaults standardUserDefaults]setBool:NO forKey:@"shoushitixing"];
        
        [[NSUserDefaults standardUserDefaults]setBool:NO forKey:@"shoushi"];
        //手势控制提示框
        GestureControlAlertView *gestureControlAlert = [[GestureControlAlertView alloc]init];
        AppDelegate *appDelegate = (AppDelegate *)[UIApplication sharedApplication].delegate;
        [appDelegate.window addSubview:gestureControlAlert];
        GestureControlAlertView *gestureCAView;
        //获取手势控制提示框设置为弱引用
        for (UIView *view in appDelegate.window.subviews) {
            if ([view isKindOfClass:[GestureControlAlertView class]]) {
                gestureCAView = (GestureControlAlertView *)view;
                break;
            }
        }
        __weak __typeof(gestureCAView) weakGestureCAView = gestureCAView;
        gestureControlAlert.clickKnowBlock = ^ {
            [weakGestureCAView removeFromSuperview];
        };
        
    }
    
    arr = [NSMutableArray arrayWithArray:[CommonCode readFromUserD:@"zhuyeliebiao"]];
    if ([[CommonCode readFromUserD:@"zhuyeliebiao"] isKindOfClass:[NSArray class]]){
        
        if (ExisRigester == YES){
            [Explayer removeObserver:self forKeyPath:@"status"];
            [Explayer removeObserver:self forKeyPath:@"loadedTimeRanges"];
            ExisRigester = NO;
        }
        
        if (ExcurrentNumber == (arr.count - 1)){
            [bofangRightBtn setEnabled:NO];
            if ([ExwhichBoFangYeMianStr isEqualToString:@"shouyebofang"])
            {
                //如果数组中的播放成员播放完毕，就要加载
                [[NSNotificationCenter defaultCenter] postNotificationName:@"bofangRightyaojiazaishujv" object:nil];
            }
            else if ([ExwhichBoFangYeMianStr isEqualToString:@"dingyuebofang"]){
                [[NSNotificationCenter defaultCenter] postNotificationName:@"dingyuebofangRightyaojiazaishujv" object:nil];
            }
            else if([ExwhichBoFangYeMianStr isEqualToString:@"faxianbofang"]){
                [[NSNotificationCenter defaultCenter] postNotificationName:@"faxianbofangyaojiazaishujv" object:nil];
            }
            else if([ExwhichBoFangYeMianStr isEqualToString:@"zhuboxiangqingbofang"]){
                [[NSNotificationCenter defaultCenter] postNotificationName:@"zhuboxiangqingbofang" object:nil];
            }
            //改变播放新闻列表文字颜色通知
            [[NSNotificationCenter defaultCenter] postNotificationName:@"gaibianyanse" object:nil];
            //记录上一次浏览的新闻详情
            [self recordTheLastNews];
            
        }
        else{
            if ((ExcurrentNumber + 1) <= [arr count] - 1) {
                self.newsModel.jiemuID = arr[ExcurrentNumber + 1][@"id"];
            }
            else{
                self.newsModel.jiemuID = [arr firstObject][@"id"];
                ExcurrentNumber = -1;
            }
            [CommonCode writeToUserD:self.newsModel.jiemuID andKey:@"dangqianbofangxinwenID"];
            [NetWorkTool getPaoGuoJieMuPingLunLieBiaoWithJieMuID:[CommonCode readFromUserD:@"dangqianbofangxinwenID"] anduid:ExdangqianUserUid andPage:@"1" andLimit:@"10" sccess:^(NSDictionary *responseObject) {
                if ([responseObject[@"results"] isKindOfClass:[NSArray class]])
                {
                    self.pinglunArr = [NSMutableArray arrayWithArray:[self pinglunFrameModelArrayWithModelArray:[PlayVCCommentModel mj_objectArrayWithKeyValuesArray:responseObject[@"results"]]]];
                }else
                {
                    self.pinglunArr = [NSMutableArray array];
                }
                [self.tableView reloadData];
            } failure:^(NSError *error) {
                RTLog(@"error = %@",error);
            }];
            [CommonCode writeToUserD:arr[ExcurrentNumber + 1] andKey:@"dangqianbofangxinwen"];
            //设置新闻模型数据
            [self playActionWithNextIndex:-1];
            ExcurrentNumber ++;
            //公共方法
            [self sameMethod];
            //记录上一次浏览的新闻详情
            [self recordTheLastNews];
        }
    }
}

- (void)bofangwanbi:(NSNotification *)notice{
    RTLog(@"bofangwanbi----------");
    if ([[CommonCode readFromUserD:TINGYOUQUANBOFANGWANBI] isEqualToString:@"YES"]) {
        [CommonCode writeToUserD:@"NO" andKey:TINGYOUQUANBOFANGWANBI];
        return;
    }
    if ([[CommonCode readFromUserD:@"zhuyeliebiao"] isKindOfClass:[NSArray class]]){
        if (ExisRigester == YES){
            if (ExisZaiWaiMianBoFangWanBi == NO){
                [Explayer removeObserver:self forKeyPath:@"status"];
                [Explayer removeObserver:self forKeyPath:@"loadedTimeRanges"];
                ExisRigester = NO;
            }
        }
        
        arr = [NSMutableArray arrayWithArray:[CommonCode readFromUserD:@"zhuyeliebiao"]];
        
        if (ExcurrentNumber == (arr.count - 1)){
            [bofangRightBtn setEnabled:NO];
            if ([ExwhichBoFangYeMianStr isEqualToString:@"Downloadbofang"]){
                [self doPlay:bofangCenterBtn];
                if (ExisRigester == YES){
                    [Explayer removeObserver:self forKeyPath:@"status"];
                    [Explayer removeObserver:self forKeyPath:@"loadedTimeRanges"];
                    ExisRigester = NO;
                }
            }
            else{
                //如果数组中的播放成员播放完毕，就要加载
                [[NSNotificationCenter defaultCenter] postNotificationName:@"bofangRightyaojiazaishujv" object:nil];
                [[NSNotificationCenter defaultCenter] postNotificationName:@"gaibianyanse" object:nil];
            }
           
        }
        else{
            if ((ExcurrentNumber + 1) <= [arr count] - 1) {
                self.newsModel.jiemuID = arr[ExcurrentNumber + 1][@"id"];
            }
            else{
                self.newsModel.jiemuID = [arr firstObject][@"id"];
                ExcurrentNumber = -1;
            }
            [CommonCode writeToUserD:self.newsModel.jiemuID andKey:@"dangqianbofangxinwenID"];
            [CommonCode writeToUserD:arr[ExcurrentNumber + 1] andKey:@"dangqianbofangxinwen"];
            //设置新闻模型数据
            [self playActionWithNextIndex:-1];
            ExcurrentNumber ++;
            //公共方法
            [self sameMethod];
            
        }
    }
}

- (void)jiazaichenggong:(NSNotification *)notification{
    RTLog(@"jiazaichenggong----------");
    if ([[CommonCode readFromUserD:@"zhuyeliebiao"] isKindOfClass:[NSArray class]]){
        arr = [NSMutableArray arrayWithArray:[CommonCode readFromUserD:@"zhuyeliebiao"]];
        
        [CommonCode writeToUserD:arr[ExcurrentNumber + 1] andKey:@"dangqianbofangxinwen"];
        
        self.newsModel.jiemuID = arr[ExcurrentNumber + 1][@"id"];
        [CommonCode writeToUserD:self.newsModel.jiemuID andKey:@"dangqianbofangxinwenID"];
        [NetWorkTool getPaoGuoJieMuPingLunLieBiaoWithJieMuID:[CommonCode readFromUserD:@"dangqianbofangxinwenID"] anduid:ExdangqianUserUid andPage:@"1" andLimit:@"10" sccess:^(NSDictionary *responseObject) {
            if ([responseObject[@"results"] isKindOfClass:[NSArray class]])
            {
                self.pinglunArr = [NSMutableArray arrayWithArray:[self pinglunFrameModelArrayWithModelArray:[PlayVCCommentModel mj_objectArrayWithKeyValuesArray:responseObject[@"results"]]]];
            }else
            {
                self.pinglunArr = [NSMutableArray array];
            }
            [self.tableView reloadData];
        } failure:^(NSError *error) {
            RTLog(@"error = %@",error);
        }];
        [self playActionWithNextIndex:-1];
        [self reloadPlayAllTime];/**<刷新音频总时长*/
        [self.tableView reloadData];
        ExcurrentNumber ++;
        if ([ExwhichBoFangYeMianStr isEqualToString:@"Downloadbofang"]){
            [Explayer replaceCurrentItemWithPlayerItem:[[AVPlayerItem alloc]initWithURL:[NSURL fileURLWithPath:self.newsModel.post_mp]]];
        }
        else{
            [Explayer replaceCurrentItemWithPlayerItem:[[AVPlayerItem alloc]initWithURL:[NSURL URLWithString:self.newsModel.post_mp]]];
        }
        if (ExisRigester == NO){
            //添加观察者，用来监视播放器的状态变化
            [Explayer addObserver:self forKeyPath:@"status" options:NSKeyValueObservingOptionNew context:nil];
            //添加观察者，用来监听播放器的缓冲进度loadedTimeRanges属性
            [Explayer addObserver:self forKeyPath:@"loadedTimeRanges" options:NSKeyValueObservingOptionNew context:nil];
            ExisRigester = YES;
        }
        [bofangRightBtn setEnabled:NO];
        [bofangLeftBtn setEnabled:NO];
        [bofangCenterBtn setEnabled:NO];
        [self doPlay:bofangCenterBtn];
        [self performSelector:@selector(doplay2) withObject:nil afterDelay:0.5f];
    }
}

- (void)doplay2{
    [bofangRightBtn setEnabled:YES];
    [bofangLeftBtn setEnabled:YES];
    [bofangCenterBtn setEnabled:YES];
    [self doPlay:bofangCenterBtn];
}
#pragma mark --- 事件
- (void)guanzhuBtnAction:(UIButton *)sender{
    if ([[CommonCode readFromUserD:@"isLogin"]boolValue] == YES){
        if (isGuanZhu == NO){
            [NetWorkTool postPaoGuoGuanZhuWithaccessToken:[DSE encryptUseDES:ExdangqianUser] andact_id:self.newsModel.post_news sccess:^(NSDictionary *responseObject) {
                [sender setTitle:@"取消" forState:UIControlStateNormal];
                isGuanZhu = YES;
                self.newsModel.jiemuIs_fan = @"1";
                [self.tableView reloadData];
            } failure:^(NSError *error) {
                RTLog(@"error = %@",error);
            }];
        }
        else{
            [NetWorkTool postPaoGuoQuXiaoGuanZhuWithaccessToken:[DSE encryptUseDES:ExdangqianUser] andact_id:self.newsModel.post_news sccess:^(NSDictionary *responseObject) {
                [sender setTitle:@"+ 关注" forState:UIControlStateNormal];
                isGuanZhu = NO;
                self.newsModel.jiemuIs_fan = @"0";
                [self.tableView reloadData];
            } failure:^(NSError *error) {
                RTLog(@"error = %@",error);
            }];
        }
        
    }
    else{
        UIAlertController *qingshuruyonghuming = [UIAlertController alertControllerWithTitle:@"温馨提示" message:@"您还没登录，请先登录后操作" preferredStyle:UIAlertControllerStyleAlert];
        [qingshuruyonghuming addAction:[UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        }]];
        [qingshuruyonghuming addAction:[UIAlertAction actionWithTitle:@"登录" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            [self doPlay:bofangCenterBtn];
            LoginVC *loginFriVC = [LoginVC new];
            LoginNavC *loginNavC = [[LoginNavC alloc]initWithRootViewController:loginFriVC];
            [loginNavC.navigationBar setBackgroundColor:[UIColor whiteColor]];
            loginNavC.navigationBar.tintColor = [UIColor blackColor];
            [self presentViewController:loginNavC animated:YES completion:nil];
        }]];
        
        [self presentViewController:qingshuruyonghuming animated:YES completion:nil];
    }
}

- (void)dianzanAction:(UIButton *)sender{
    jiaDianZanShuJv = [NSMutableArray arrayWithArray:[CommonCode readFromUserD:@"jiaDianZanShuJv"]];
    UIImageView *image = (UIImageView *)[sender viewWithTag:1];
    UILabel *lab = (UILabel *)[sender viewWithTag:2];
    if (isDianZan == NO){
        
        RTLog(@"点赞");
        for (int i = 0; i < jiaDianZanShuJv.count; i ++){
            NSString *str = jiaDianZanShuJv[i][@"jiemuID"];
            if ([str isEqualToString:self.newsModel.jiemuID])
            {
                [jiaDianZanShuJv removeObjectAtIndex:i];
                break;
            }
        }
        image.image = [UIImage imageNamed:@"pinglun-yizan"];
        lab.text = [NSString stringWithFormat:@"%d",[lab.text intValue] + 1];
        lab.textColor = ColorWithRGBA(0, 159, 240, 1);
        isDianZan = YES;
        NSDictionary *dic = @{@"jiemuID":self.newsModel.jiemuID,@"praisenum":lab.text,@"isdianzan":@"YES"};
        [jiaDianZanShuJv addObject:dic];
        [CommonCode writeToUserD:jiaDianZanShuJv andKey:@"jiaDianZanShuJv"];
    }
    else{
        RTLog(@"取消点赞");
        
        for (int i = 0; i < jiaDianZanShuJv.count; i ++){
            NSString *str = jiaDianZanShuJv[i][@"jiemuID"];
            if ([str isEqualToString:self.newsModel.jiemuID]) {
                [jiaDianZanShuJv removeObjectAtIndex:i];
                break;
            }
        }
        image.image = [UIImage imageNamed:@"pinglun-7"];
        lab.text = [NSString stringWithFormat:@"%d",[lab.text intValue] - 1];
        lab.textColor = [UIColor blackColor];
        isDianZan = NO;
        NSDictionary *dic = @{@"jiemuID":self.newsModel.jiemuID,@"praisenum":lab.text,@"isdianzan":@"NO"};
        [jiaDianZanShuJv addObject:dic];
        [CommonCode writeToUserD:jiaDianZanShuJv andKey:@"jiaDianZanShuJv"];
    }
}

- (void)pinglunAction{
    
    if ([[CommonCode readFromUserD:@"isLogin"]boolValue] == YES){
        pinglunyeVC *pinglunye = [pinglunyeVC new];
        pinglunye.isNewsCommentPage = YES;
        pinglunye.post_id = self.newsModel.jiemuID;
    
        pinglunye.to_uid = @"0";
        self.hidesBottomBarWhenPushed = YES;
        [self.navigationController pushViewController:pinglunye animated:YES];
        self.hidesBottomBarWhenPushed = YES;
    }
    else{
        UIAlertController *qingshuruyonghuming = [UIAlertController alertControllerWithTitle:@"请先登录" message:nil preferredStyle:UIAlertControllerStyleAlert];
        [qingshuruyonghuming addAction:[UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        }]];
        [qingshuruyonghuming addAction:[UIAlertAction actionWithTitle:@"去登录" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            [self doPlay:bofangCenterBtn];
            LoginVC *loginFriVC = [LoginVC new];
            LoginNavC *loginNavC = [[LoginNavC alloc]initWithRootViewController:loginFriVC];
            [loginNavC.navigationBar setBackgroundColor:[UIColor whiteColor]];
            loginNavC.navigationBar.tintColor = [UIColor blackColor];
            [self presentViewController:loginNavC animated:YES completion:nil];
        }]];
        
        [self presentViewController:qingshuruyonghuming animated:YES completion:nil];
    }
}

//3D水平旋转
- (void)xuanzhuanAction{
    
    if ((angle > 160.0 && angle < 200.0 ))
    {
        angle = angle + 1.0;//angle角度 double angle; //（控制翻转角度）
        
    }else
    {
        angle = angle + 3.5;
    }
    
    if (angle > 360.0) {//大于 M_PI*2(360度) 角度再次从0开始
        angle = 0;
    }
    
    CGFloat m34 = 800;
    CGPoint point = CGPointMake(0.5, 0.5);//设定翻转时的中心点，0.5为视图layer的正中
    CATransform3D transfrom = CATransform3DIdentity;
    transfrom.m34 = 1.0 / m34;
    CGFloat radiants = angle / 360.0 * 2 * M_PI;
    transfrom = CATransform3DRotate(transfrom, radiants, 0.0f, 1.0f, 0.0f);//(后面3个 数字分别代表不同的轴来翻转，本处为x轴)
    CALayer *layer = xuanzhuanBtn.layer;
    layer.anchorPoint = point;
    layer.transform = transfrom;
}

- (void)shangAction {
    RTLog(@"打赏");
}

- (void)zhuboBtnVAction:(UITapGestureRecognizer *)tap {
    zhuboxiangqingVCNew *zhubo = [zhuboxiangqingVCNew new];
    zhubo.jiemuDescription = self.newsModel.jiemuDescription;
    zhubo.jiemuFan_num = self.newsModel.jiemuFan_num;
    zhubo.jiemuID = (self.newsModel.post_news != nil) ? self.newsModel.post_news : self.newsModel.jiemuID;
    zhubo.jiemuImages = self.newsModel.jiemuImages;
    zhubo.jiemuIs_fan = self.newsModel.jiemuIs_fan;
    zhubo.jiemuMessage_num = self.newsModel.jiemuMessage_num;
    zhubo.jiemuName = self.newsModel.jiemuName;
    zhubo.isbofangye = YES;
    self.hidesBottomBarWhenPushed = YES;
    [self.navigationController pushViewController:zhubo animated:YES];
}

- (void)bofangdingshiBtnAction:(UIButton *)sender {
    self.hidesBottomBarWhenPushed = YES;
    [self.navigationController.navigationBar setHidden:YES];
    [self.navigationController pushViewController:[TimerViewController defaultTimerViewController] animated:YES];
}

- (void)dingshiTapAction:(UITapGestureRecognizer *)tap {
    self.hidesBottomBarWhenPushed = YES;
    [self.navigationController.navigationBar setHidden:YES];
    [self.navigationController pushViewController:[TimerViewController defaultTimerViewController] animated:YES];
}
//TODO:分享
- (void)shareNewsBtnAction{
    
    DefineWeakSelf;
    ShareView *shareView = [[ShareView alloc]init];
    AppDelegate *appDelegate = (AppDelegate *)[UIApplication sharedApplication].delegate;
    [appDelegate.window addSubview:shareView];
    NSMutableArray *itemArr = [NSMutableArray array];
    NSDictionary *dic0 = @{@"image":@"sina",@"title":@"新浪微博"};
    [itemArr addObject:dic0];
    NSDictionary *dic1 = @{@"image":@"wechat",@"title":@"微信"};
    [itemArr addObject:dic1];
    NSDictionary *dic2 = @{@"image":@"cicle",@"title":@"朋友圈"};
    [itemArr addObject:dic2];
    NSDictionary *dic3 = @{@"image":@"qq",@"title":@"QQ好友"};
    [itemArr addObject:dic3];
    NSDictionary *dic4 = @{@"image":@"qzone",@"title":@"QQ空间"};
    [itemArr addObject:dic4];
    NSDictionary *dic5 = @{@"image":@"url",@"title":@"复制链接"};
    [itemArr addObject:dic5];
    [shareView setSelectItemWithTitleArr:itemArr];
    shareView.selectedTypeBlock = ^ (NSInteger selectedindex) {
        switch (selectedindex) {
            case 0:
            {
                NSURL *url = [NSURL URLWithString:self.newsModel.ImgStrjiemu];
                NSURLRequest *q = [NSURLRequest requestWithURL:url cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:5];
                NSData *dataImage = [NSURLConnection sendSynchronousRequest:q returningResponse:nil error:nil];
                
                if (!dataImage) {
                    dataImage = UIImageJPEGRepresentation([UIImage imageNamed:@"Icon-60"], 0.9);
                }
                
                UIImage *image = [UIImage imageWithData:dataImage];
                WBMessageObject *message = [WBMessageObject message];
                WBImageObject *imgObjc = [WBImageObject object];
                imgObjc.imageData = UIImageJPEGRepresentation(image, 0.9f);
                NSInteger strCount = 0;
                NSString *contentURLStr = [NSString stringWithFormat:@"http://tingwen.me/index.php/article/yulan/id/%@.html",self.newsModel.jiemuID];
                strCount = [CommonCode countWord:contentURLStr];
                
                strCount += [CommonCode countWord:self.newsModel.Titlejiemu];
                
                strCount += [CommonCode countWord:@"【】详情内容：..... 收听地址："];
                
                NSInteger RemainingCount = 137 - strCount;
                if (RemainingCount < 0) {
                    RemainingCount = 0;
                }
                NSInteger contentCount = [CommonCode countWord:self.newsModel.ZhengWenjiemu];
                NSString *contentStr = [self.newsModel.ZhengWenjiemu substringWithRange:NSMakeRange(0, contentCount > RemainingCount ? RemainingCount : contentCount)];
                
                //创建消息的文本内容
                NSString *shareContent = [NSString stringWithFormat:@"【%@】详情内容：%@..... 收听地址：%@", self.newsModel.Titlejiemu, contentStr, contentURLStr];
                //消息的文本内容
                message.text = shareContent;
                //设置消息的图片内容
                message.imageObject = imgObjc;
                
                WBSendMessageToWeiboRequest *send = [WBSendMessageToWeiboRequest requestWithMessage:message];
                [WeiboSDK sendRequest:send];
            }
                break;
            case 1:{
                [weakSelf shareToWechatWithscene:WXSceneSession];
            }
                break;
            case 2:{
                [weakSelf shareToWechatWithscene:WXSceneTimeline];
            }
                break;
            case 3:{
                [weakSelf shareToQQWithscene:0];
            }
                break;
            case 4:{
                [weakSelf shareToQQWithscene:1];
            }
                break;
            default:
            {
                UIPasteboard *gr                             = [UIPasteboard generalPasteboard];
                gr.string                                    = [NSString stringWithFormat:@"http://tingwen.me/index.php/article/yulan/id/%@.html",self.newsModel.jiemuID];
                XWAlerLoginView *xw = [[XWAlerLoginView alloc]initWithTitle:@"分享链接已复制到您的剪切板~~"];
                [xw show];
            }
                break;
        }
    };
}


- (void)collect{
    
    if ([[CommonCode readFromUserD:@"isLogin"]boolValue] == YES){
        if (_isCollected) {
            [NetWorkTool del_collectionWithaccessToken:AvatarAccessToken post_id:self.newsModel.jiemuID sccess:^(NSDictionary *responseObject) {
                if ([responseObject[@"status"] integerValue] == 1) {
                    UIButton *collectBtn = (UIButton *)[dibuView viewWithTag:99];
                    [collectBtn setImage:[UIImage imageNamed:@"home_news_collection"] forState:UIControlStateNormal];
                    _isCollected = NO;
                }
                [SVProgressHUD showSuccessWithStatus:responseObject[@"msg"]];
                [self performSelector:@selector(SVPDismiss) withObject:nil afterDelay:1.0];
            } failure:^(NSError *error) {
                //
            }];
        }
        else{
            [NetWorkTool collectionPostNewsWithaccessToken:AvatarAccessToken post_id:self.newsModel.jiemuID sccess:^(NSDictionary *responseObject) {
                
                if ([responseObject[@"status"] integerValue] == 1) {
                    UIButton *collectBtn = (UIButton *)[dibuView viewWithTag:99];
                    [collectBtn setImage:[UIImage imageNamed:@"home_news_collectioned"] forState:UIControlStateNormal];
                    _isCollected = YES;
                }
                else{
                    
                }
                [SVProgressHUD showSuccessWithStatus:responseObject[@"msg"]];
                [self performSelector:@selector(SVPDismiss) withObject:nil afterDelay:1.0];
                
            } failure:^(NSError *error) {
                [SVProgressHUD showErrorWithStatus:@"收藏失败"];
                [self performSelector:@selector(SVPDismiss) withObject:nil afterDelay:1.0];
            }];
        }
        
    }
    else{
        XWAlerLoginView *xw = [[XWAlerLoginView alloc]initWithTitle:@"登录后才可以收藏哦~"];
        [xw show];
    }
}


- (void)appreciateGold{
    if ([[CommonCode readFromUserD:@"isLogin"]boolValue] == YES){
        NSDictionary *userInfo = [CommonCode readFromUserD:@"dangqianUserInfo"];
        if ([userInfo[@"results"][@"gold"] floatValue] > 0) {
            [NetWorkTool goldUseWithaccessToken:AvatarAccessToken act_id:(self.newsModel.post_news != nil) ? self.newsModel.post_news : self.newsModel.jiemuID post_id:self.newsModel.jiemuID sccess:^(NSDictionary *responseObject) {
                [self loadData];
                XWAlerLoginView *xw = [[XWAlerLoginView alloc]initWithTitle:responseObject[@"msg"]];
                [xw show];
                //投完金币 --》 获取用户信息
                [[NSNotificationCenter defaultCenter] postNotificationName:@"updateUserInfo" object:nil];
                
            } failure:^(NSError *error) {
                //
            }];
        }
        else{
            XWAlerLoginView *xw = [[XWAlerLoginView alloc]initWithTitle:@"金币不足"];
            [xw show];
        }
    }
    else{
        XWAlerLoginView *xw = [[XWAlerLoginView alloc]initWithTitle:@"登录后才可以投金币哦~"];
        [xw show];
    }
}

- (void)downloadAction:(UIButton *)sender {
    [SVProgressHUD showInfoWithStatus:@"开始下载"];
    [self performSelector:@selector(SVPDismiss) withObject:nil afterDelay:1.0];
    //TODO:下载单条新闻
    NSArray *nowarr = [CommonCode readFromUserD:@"zhuyeliebiao"];
     NSMutableDictionary *dic = [NSMutableDictionary dictionary];
    for ( int i = 0 ; i < [nowarr count]; i ++) {
        if ([nowarr[i][@"id"] isEqualToString:[CommonCode readFromUserD:@"dangqianbofangxinwenID"]]) {
            dic = nowarr[i];
            break;
        }
    }
    if (dic != nil) {
        dispatch_async(dispatch_get_main_queue(), ^{
            ProjiectDownLoadManager *manager = [ProjiectDownLoadManager defaultProjiectDownLoadManager];
            [manager insertSevaDownLoadArray:dic];
            
            WHC_Download *op = [[WHC_Download alloc]initStartDownloadWithURL:[NSURL URLWithString:dic[@"post_mp"]] savePath:manager.userDownLoadPath savefileName:[dic[@"post_mp"] stringByReplacingOccurrencesOfString:@"/" withString:@""] withObj:dic delegate:nil];
            [manager.downLoadQueue addOperation:op];
        });
    }
    
}

- (void)SVPDismiss {
    [SVProgressHUD dismiss];
}

- (void)back {

    [self.navigationController popViewControllerAnimated:YES];
    
}

- (void)rightSwipeAction:(UIGestureRecognizer *)gesture {

    [self.navigationController popViewControllerAnimated:YES];
}

/**
 *  计算文本高度
 *
 *  @param string   要计算的文本
 *  @param width    单行文本的宽度
 *  @param fontSize 文本的字体size
 *
 *  @return 返回文本高度
 */
- (CGFloat)computeTextHeightWithString:(NSString *)string andWidth:(CGFloat)width andFontSize:(UIFont *)fontSize{
    
    CGRect rect  = [string boundingRectWithSize:CGSizeMake(width, 10000)
                                        options: NSStringDrawingUsesFontLeading |NSStringDrawingUsesLineFragmentOrigin
                                     attributes:@{NSFontAttributeName:fontSize}
                                        context:nil];
    return ceil(rect.size.height);
}

- (void)timerStop:(NSNotification *)notice {
    [Explayer pause];
    isPlaying = NO;
    self.isPlay = isPlaying;
    [bofangCenterBtn setImage:[UIImage imageNamed:@"home_news_ic_play"] forState:UIControlStateNormal];
    bofangCenterBtn.accessibilityLabel = @"播放";
    self.sliderProgress.maximumValue = [self.newsModel.post_time intValue] / 1000;
}

- (void)captureDevice:(NSNotification *)n {
    if ([[UIDevice currentDevice] proximityState]) {
        if (isPlaying) {
            [self bofangRightAction:nil];
        }
    }
}

- (void)loadData{
    NSString *accesstoken = nil;
    if ([[CommonCode readFromUserD:@"isLogin"]boolValue] == YES){
        accesstoken = [DSE encryptUseDES:ExdangqianUser];
    }
    else{
        accesstoken = nil;
    }
    //postDetail
    RTLog(@"%@",self.newsModel.jiemuID);
    [NetWorkTool getPostDetailWithaccessToken:accesstoken post_id:self.newsModel.jiemuID sccess:^(NSDictionary *responseObject) {
        RTLog(@"%@",responseObject[@"results"]);
        if ([responseObject[@"results"] isKindOfClass:[NSDictionary class]]){
            if ([responseObject[@"results"][@"reward"] isKindOfClass:[NSArray class]]) {
                self.isPay = YES;
                self.rewardArray = responseObject[@"results"][@"reward"];
                //修复广告点击进入的主播详情粉丝数错误
                self.newsModel.jiemuFan_num = responseObject[@"results"][@"act"][@"fan_num"];
                self.newsModel.jiemuMessage_num = responseObject[@"results"][@"act"][@"message_num"];
            }
            else{
                self.isPay = NO;
                self.rewardArray = nil;
            }
            [self.appreciateNum setText:responseObject[@"results"][@"gold"] ];
        }
        else{
            self.isPay = NO;
            self.rewardArray = nil;
            [self.appreciateNum setText:@"0"];
            [SVProgressHUD showErrorWithStatus:responseObject[@"msg"]];
        }
        if (self.isRewardBack) {
            self.isReward = YES;
            self.isRewardBack = NO;
        }
        else{
            self.isReward = NO;
            self.isCustomRewardCount = NO;
        }
        if ([responseObject[@"results"][@"is_collection"] integerValue] == 1) {
            _isCollected = YES;
            UIButton *collectBtn = (UIButton *)[dibuView viewWithTag:99];
            [collectBtn setImage:[UIImage imageNamed:@"home_news_collectioned"] forState:UIControlStateNormal];
        }
        else{
            _isCollected = NO;
            UIButton *collectBtn = (UIButton *)[dibuView viewWithTag:99];
            [collectBtn setImage:[UIImage imageNamed:@"home_news_collection"] forState:UIControlStateNormal];
        }
        [self.tableView reloadData];
    } failure:^(NSError *error) {
        //
    }];
    
}
- (void)handleKeyword {
    
    if ([[CommonCode readFromUserD:@"isLogin"]boolValue] == YES){
        DefineWeakSelf;
        [NetWorkTool getlistUserKeywordWithaccessToken:[DSE encryptUseDES:ExdangqianUser] sccess:^(NSDictionary *responseObject) {
            if ([responseObject[@"results"] isKindOfClass:[NSArray class]]) {
                [weakSelf handleListKeywordDataWithResultArr:responseObject[@"results"]];
            }
            else{
                //TODO:新增关键词
                [weakSelf addkeywordWithKeyword:weakSelf.newsModel.post_keywords];
            }
            
        } failure:^(NSError *error) {
            
        }];
    }
}

- (void)handleListKeywordDataWithResultArr:(NSArray *)resultArr{
    
    NSString *keywordsStr = [self.newsModel.post_keywords stringByReplacingOccurrencesOfString:@"，" withString:@","];
    NSArray *array = [keywordsStr componentsSeparatedByString:@","];
    for (int i = 0 ; i < [array count]; i ++) {
        BOOL isAddFrequency = NO;
        for (int j = 0 ; j < [resultArr count]; j ++) {
            if ([resultArr[j][@"keywords"] isEqualToString:array[i]]) {
                //条件为真，表示字符串searchStr包含一个自字符串substr
                isAddFrequency = YES;
                [NetWorkTool frequencykeywordWithaccessToken:[DSE encryptUseDES:ExdangqianUser] k_id:resultArr[j][@"id"] sccess:^(NSDictionary *responseObject) {
                    //
                    RTLog(@"%@",responseObject);
                } failure:^(NSError *error) {
                    //
                }];
                break;
            }
            else{
                continue;
            }
        }
        if (! isAddFrequency) {
            [self addkeywordWithKeyword:array[i]];
        }
    }
    

    
}

- (void)addkeywordWithKeyword:(NSString *)keyword{
    
    [NetWorkTool addUserKeywordWithaccessToken:[DSE encryptUseDES:ExdangqianUser] keyword:keyword sccess:^(NSDictionary *responseObject) {
        //
        RTLog(@"%@",responseObject);
    } failure:^(NSError *error) {
        //
    }];
}

- (void)readOriginalEssay:(UIButton *)sender {
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:self.newsModel.url]];
}

- (void)shareToQQWithscene:(int)scene{
    if (![TencentOAuth iphoneQQInstalled]){
        UIAlertView *al = [[UIAlertView alloc]initWithTitle:@"提示" message:@"请安装QQ" delegate:nil cancelButtonTitle:@"知道了" otherButtonTitles: nil];
        [al show];
        return;
    }
    tencentOAuth = [[TencentOAuth alloc]initWithAppId:kAppId_QQ andDelegate:self];
    
    [self getImageWithURLStr:self.newsModel.ImgStrjiemu OnSucceed:^(UIImage *image) {
        //压缩图片大小
        CGFloat compression = 0.8f;
        CGFloat maxCompression = 0.1f;
        int maxFileSize = 32*1024;
        //转化为二进制
        NSData *imageData = UIImageJPEGRepresentation(image, compression);
        //压缩小于32K
        while ([imageData length] > maxFileSize && compression > maxCompression) {
            compression -= 0.1;
            imageData = UIImageJPEGRepresentation(image, compression);
        }
        //当图片还是大于32K时，则用图标
        if ([imageData length] < maxFileSize) {
            //设置图片
            UIImage *thumbImage = [UIImage imageWithData:imageData];
            //分享内容的预览图像
            NSData *thumbImageData = [thumbImage dataWithMaxFileSize:25 * 1024 maxSide:200];
            //分享跳转URL
            NSString *url = [NSString stringWithFormat:@"http://tingwen.me/index.php/article/yulan/id/%@.html",self.newsModel.jiemuID];
            
            //音乐播放的网络流媒体地址
            NSString *flashURL = self.newsModel.post_mp;
            QQApiAudioObject *audioObj =[QQApiAudioObject
                                         objectWithURL :[NSURL URLWithString:url]
                                         title:self.newsModel.Titlejiemu
                                         description:nil
                                         previewImageData:thumbImageData];
            //设置播放流媒体地址
            [audioObj setFlashURL:[NSURL URLWithString:flashURL]];
            SendMessageToQQReq *req = [SendMessageToQQReq reqWithContent:audioObj];
            switch (scene) {
                case 0:
                {
                    //将内容分享到qq
                    QQApiSendResultCode sent = [QQApiInterface sendReq:req];
                    if (sent == EQQAPISENDSUCESS) {
                        RTLog(@"分享QQ成功");
                    }
//                    [self handleSendResult:sent];
                }
                    break;
                case 1:
                {
                    //将被容分享到qzone
                    QQApiSendResultCode sent = [QQApiInterface SendReqToQZone:req];
                    if (sent == EQQAPISENDSUCESS) {
                        RTLog(@"分享QQ空间成功");
                    }
//                    [self handleSendResult:sent];
                }
                    break;
                default:
                    break;
            }


            
        }else{
            
            [self getImageWithURLStr:self.newsModel.ImgStrjiemu OnSucceed:^(UIImage *image) {
                
                //压缩图片大小
                CGFloat compression = 0.8f;
                CGFloat maxCompression = 0.1f;
                int maxFileSize = 32*1024;
                //转化为二进制
                NSData *imageData = UIImageJPEGRepresentation(image, compression);
                //压缩小于32K
                while ([imageData length] > maxFileSize && compression > maxCompression) {
                    compression -= 0.1;
                    imageData = UIImageJPEGRepresentation(image, compression);
                }
                //设置图片
                UIImage *thumbImage = [UIImage imageWithData:imageData];
                //分享内容的预览图像
                NSData *thumbImageData = [thumbImage dataWithMaxFileSize:25 * 1024 maxSide:200];
                //分享跳转URL
                NSString *url = [NSString stringWithFormat:@"http://tingwen.me/index.php/article/yulan/id/%@.html",self.newsModel.jiemuID];
                //音乐播放的网络流媒体地址
                NSString *flashURL = self.newsModel.post_mp;
                QQApiAudioObject *audioObj =[QQApiAudioObject
                                             objectWithURL :[NSURL URLWithString:url]
                                             title:self.newsModel.Titlejiemu
                                             description:nil
                                             previewImageData:thumbImageData];
                //设置播放流媒体地址
                [audioObj setFlashURL:[NSURL URLWithString:flashURL]];
                SendMessageToQQReq *req = [SendMessageToQQReq reqWithContent:audioObj];
                switch (scene) {
                    case 0:
                    {
                        [audioObj setCflag:kQQAPICtrlFlagQQShare];
                        //将内容分享到qq
                        QQApiSendResultCode sent = [QQApiInterface sendReq:req];
                        if (sent == EQQAPISENDSUCESS) {
                            RTLog(@"分享QQ成功");
                        }
//                        [self handleSendResult:sent];
                    }
                        break;
                    case 1:
                    {
                         [audioObj setCflag:kQQAPICtrlFlagQZoneShareOnStart];
                        //将被容分享到qzone
                        QQApiSendResultCode sent = [QQApiInterface SendReqToQZone:req];
                        if (sent == EQQAPISENDSUCESS) {
                            RTLog(@"分享QQ空间成功");
                        }
//                        [self handleSendResult:sent];
                    }
                        break;
                    default:
                        break;
                }


            }];
        }
    }];

}

- (void)shareToWechatWithscene:(int)scene{
    //注册微信
    [WXApi registerApp:KweChatappID];
    
    if (![WXApi isWXAppInstalled]){
        UIAlertView *al = [[UIAlertView alloc]initWithTitle:@"提示" message:@"请先安装微信" delegate:nil cancelButtonTitle:@"知道了" otherButtonTitles: nil];
        [al show];
        return;
    }
    WXMediaMessage *message = [WXMediaMessage message];
    message.title = self.newsModel.Titlejiemu;
    NSString *musicUrl = [NSString stringWithFormat:@"https://tingwen.me/index.php/article/yulan/id/%@.html",self.newsModel.jiemuID];
//    NSString *musicUrl = @"http://jingyan.baidu.com/article/a378c960b49034b3282830db.html";
    
    [self getImageWithURLStr:self.newsModel.ImgStrjiemu OnSucceed:^(UIImage *image) {
        //压缩图片大小
        CGFloat compression = 0.8f;
        CGFloat maxCompression = 0.1f;
        int maxFileSize = 32*1024;
        //转化为二进制
        NSData *imageData = UIImageJPEGRepresentation(image, compression);
        //压缩小于32K
        while ([imageData length] > maxFileSize && compression > maxCompression) {
            compression -= 0.1;
            imageData = UIImageJPEGRepresentation(image, compression);
        }
        //当图片还是大于32K时，则用图标
        if ([imageData length] < maxFileSize) {
            //设置图片
            UIImage *thumbImage = [UIImage imageWithData:imageData];
            NSData *thumbImageData = [thumbImage dataWithMaxFileSize:25 * 1024 maxSide:200];
            [message setThumbImage:[UIImage imageWithData:thumbImageData]];
            WXMusicObject *ext = [WXMusicObject object];
            ext.musicUrl = musicUrl;
            ext.musicDataUrl = self.newsModel.post_mp;
            message.mediaObject = ext;
            SendMessageToWXReq* req = [[SendMessageToWXReq alloc] init];
            req.bText = NO;
            req.message = message;
            req.scene = scene;
            if ([WXApi sendReq:req]) {
                RTLog(@"微信发送请求成功");
            }
            else{
                RTLog(@"微信发送请求失败");
            }
            
        }else{
            
            [self getImageWithURLStr:self.newsModel.ImgStrjiemu OnSucceed:^(UIImage *image) {
                
                //压缩图片大小
                CGFloat compression = 0.8f;
                CGFloat maxCompression = 0.1f;
                int maxFileSize = 32*1024;
                //转化为二进制
                NSData *imageData = UIImageJPEGRepresentation(image, compression);
                //压缩小于32K
                while ([imageData length] > maxFileSize && compression > maxCompression) {
                    compression -= 0.1;
                    imageData = UIImageJPEGRepresentation(image, compression);
                }
                //设置图片
                UIImage *thumbImage = [UIImage imageWithData:imageData];
                NSData *thumbImageData = [thumbImage dataWithMaxFileSize:25 * 1024 maxSide:200];
                [message setThumbImage:[UIImage imageWithData:thumbImageData]];
                WXMusicObject *ext = [WXMusicObject object];
                ext.musicUrl = musicUrl;
                ext.musicDataUrl = self.newsModel.post_mp;
                message.mediaObject = ext;
                SendMessageToWXReq* req = [[SendMessageToWXReq alloc] init];
                req.bText = NO;
                req.message = message;
                req.scene = scene;
                if ([WXApi sendReq:req]) {
                    RTLog(@"微信发送请求成功");
                }
                else{
                    RTLog(@"微信发送请求失败");
                }
            }];
        }
    }];
}
- (void)getImageWithURLStr:(NSString *)urlstring OnSucceed:(void(^)(UIImage *image))succeed {
    //获取图片管理
    SDWebImageManager *manager = [SDWebImageManager sharedManager];
    //图片URL
    NSURL *url = [NSURL URLWithString:urlstring];
    //获取缓存key
    NSString *cacheKey = [manager cacheKeyForURL:url];
    //判断图片是否缓存
    if ([manager cachedImageExistsForURL:url]) {
        //先从内存中获取图片
        UIImage *image = [[SDImageCache sharedImageCache] imageFromMemoryCacheForKey:cacheKey];
        //如果图片为空，则从本地获取图片
        if (!image) {
            image = [[SDImageCache sharedImageCache] imageFromDiskCacheForKey:cacheKey];
        }
        //如果还是不存在图片， 则取图标
        if (!image) {
            image = [UIImage imageNamed:@"Icon-60"];
        }
        
        dispatch_async(dispatch_get_main_queue(), ^{
            succeed(image);
        });
        
    }else{
        [manager downloadImageWithURL:url options:0 progress:^(NSInteger receivedSize, NSInteger expectedSize) {
            
        } completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, BOOL finished, NSURL *imageURL) {
            //下载图片完成后， 存在图片
            if (image) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    succeed(image);
                });
                
            }else if (error){
                //如果发生错误，则取图标
                UIImage *palaceImage = [UIImage imageNamed:@"Icon-60"];
                dispatch_async(dispatch_get_main_queue(), ^{
                    succeed(palaceImage);
                });
            }
        }];
    }
}

 - (void)loginFirst {
    
    UIAlertController *qingshuruyonghuming = [UIAlertController alertControllerWithTitle:@"温馨提示" message:@"您还没登录，请先登录后操作" preferredStyle:UIAlertControllerStyleAlert];
    [qingshuruyonghuming addAction:[UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
    }]];
    [qingshuruyonghuming addAction:[UIAlertAction actionWithTitle:@"登录" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        LoginVC *loginFriVC = [LoginVC new];
        LoginNavC *loginNavC = [[LoginNavC alloc]initWithRootViewController:loginFriVC];
        [loginNavC.navigationBar setBackgroundColor:[UIColor whiteColor]];
        loginNavC.navigationBar.tintColor = [UIColor blackColor];
        [self presentViewController:loginNavC animated:YES completion:nil];
    }]];
    
    [self presentViewController:qingshuruyonghuming animated:YES completion:nil];
}

- (void)rewardOrLoginfirst{
    
    UIAlertController *alertC = [UIAlertController alertControllerWithTitle:@"温馨提示" message:@"您还没有登录，登录后赞赏才有排名哦~是否去登录" preferredStyle:UIAlertControllerStyleAlert];
    [alertC addAction:[UIAlertAction actionWithTitle:@"赞赏" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        [_finalRewardButton startAnimation];
    }]];
    [alertC addAction:[UIAlertAction actionWithTitle:@"登录" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        LoginVC *loginFriVC = [LoginVC new];
        LoginNavC *loginNavC = [[LoginNavC alloc]initWithRootViewController:loginFriVC];
        [loginNavC.navigationBar setBackgroundColor:[UIColor whiteColor]];
        loginNavC.navigationBar.tintColor = [UIColor blackColor];
        [self presentViewController:loginNavC animated:YES completion:nil];
    }]];
    [self presentViewController:alertC animated:YES completion:nil];
}

- (void)showZoomImageView:(UITapGestureRecognizer *)tap{
    if (![(UIImageView *)tap.view image]) {
        return;
    }
    [YJImageBrowserView showWithImageView:(UIImageView *)tap.view];
}

-(void)tapBgView:(UITapGestureRecognizer *)tapBgRecognizer
{
    self.scrollView.contentOffset = CGPointZero;
    [UIView animateWithDuration:0.35 animations:^{
        self.lastImageView.frame = self.originalFrame;
        tapBgRecognizer.view.backgroundColor = [UIColor clearColor];
    } completion:^(BOOL finished) {
        [tapBgRecognizer.view removeFromSuperview];
        self.scrollView = nil;
        self.lastImageView = nil;
    }];
}

- (void)longtapImage:(UILongPressGestureRecognizer *)longtapImageReconizer{
    if (longtapImageReconizer.state == UIGestureRecognizerStateEnded) {
        DefineWeakSelf;
        [UIActionSheet actionSheetWithTitle:nil message:nil buttons:@[@"存储照片"] showInView:self.view onDismiss:^(int buttonIndex) {
            UIImageView *picView = (UIImageView *)longtapImageReconizer.view;
            [weakSelf loadImageFinished:picView.image];
        } onCancel:^{
            
        }];
    }
}
//图片保存到本地
- (void)loadImageFinished:(UIImage *)image{
    UIImageWriteToSavedPhotosAlbum(image, self, @selector(image:didFinishSavingWithError:contextInfo:), (__bridge void *)self);
}

- (void)image:(UIImage *)image didFinishSavingWithError:(NSError *)error contextInfo:(void *)contextInfo{
    XWAlerLoginView *xw = [[XWAlerLoginView alloc]initWithTitle:@"图片存储成功!"];
    [xw show];
}

//返回可缩放的视图
-(UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView{
    return self.lastImageView;
}

- (BOOL)canPerformAction:(SEL)action withSender:(id)sender{
    if (action == @selector(copy:) || action == @selector(selectAll:))
        return YES;
    
    return [super canPerformAction:action withSender:sender];
}

-(BOOL)canBecomeFirstResponder{
    return YES;
}

- (void)handleLongPress:(UILongPressGestureRecognizer *)uilpgr {
    
    UIMenuController *menu=[UIMenuController sharedMenuController];
    UIMenuItem *allCopy=[[UIMenuItem alloc]initWithTitle:@"全部复制" action:@selector(allCopy)];
    UIMenuItem *allselected =[[UIMenuItem alloc]initWithTitle:@"全选" action:@selector(allselected)];
    UIMenuItem *selecte =[[UIMenuItem alloc]initWithTitle:@"选择" action:@selector(selecte)];
    //类似于UIBarButtonItem,实例化每个UIMenuItem，然后添加到menuItems中，menuItems是个数组。
    menu.menuItems=@[allCopy,allselected,selecte];
    
    [menu setTargetRect:CGRectMake((SCREEN_WIDTH - 200 ) / 2, SCREEN_HEIGHT / 2 , 200, 50) inView:self.view];
    //这里是这只箭头方向UIMenuControllerArrowDown就是这样iOS <wbr>弹出菜单UIMenuController的基本使用
    //UIMenuControllerArrowUp就是这样iOS <wbr>弹出菜单UIMenuController的基本使用同理还有left和right
    menu.arrowDirection=UIMenuControllerArrowDown;
    //调用update方法才能使我们对菜单所做的修改生效
    [menu update];
    //将菜单设为可见就可以了
    [menu setMenuVisible:YES];
}

- (void)allCopy {
    
    UIPasteboard *pboard = [UIPasteboard generalPasteboard];
    pboard.string = self.newsModel.ZhengWenjiemu;
    XWAlerLoginView *xw = [[XWAlerLoginView alloc]initWithTitle:@"已复制到您的剪切板~~"];
    [xw show];
}

- (void)selectAll:(id)sender {
    NSRange range;
    range.location = 0;
    range.length = [self.newsModel.ZhengWenjiemu length];
    _zhengwenTextView.selectedRange = range;
    [[UIPasteboard generalPasteboard] setString:self.newsModel.ZhengWenjiemu];
}

- (void)selecte {
    
}
- (void)allselected {
    
}
#pragma mark - 空值处理防止空值崩溃
- (void)recordTheLastNews{
    
    NSMutableDictionary *dic = [NSMutableDictionary new];
    [dic setObject:self.newsModel.jiemuID forKey:@"jiemuID"];
    [dic setObject:self.newsModel.Titlejiemu forKey:@"Titlejiemu"];
    [dic setObject:self.newsModel.RiQijiemu forKey:@"RiQijiemu"];
    [dic setObject:self.newsModel.ImgStrjiemu forKey:@"ImgStrjiemu"];
    [dic setObject:self.newsModel.post_lai forKey:@"post_lai"];
    [dic setObject:self.newsModel.post_news forKey:@"post_news"];
    [dic setObject:self.newsModel.jiemuName forKey:@"jiemuName"];
    [dic setObject:self.newsModel.jiemuDescription forKey:@"jiemuDescription"];
    [dic setObject:self.newsModel.jiemuImages forKey:@"jiemuImages"];
    [dic setObject:self.newsModel.jiemuFan_num forKey:@"jiemuFan_num"];
    [dic setObject:self.newsModel.jiemuMessage_num forKey:@"jiemuMessage_num"];
    [dic setObject:self.newsModel.jiemuIs_fan forKey:@"jiemuIs_fan"];
    [dic setObject:self.newsModel.post_mp forKey:@"post_mp"];
    [dic setObject:self.newsModel.post_time forKey:@"post_time"];
    [dic setObject:self.newsModel.post_keywords forKey:@"post_keywords"];
    [dic setObject:self.newsModel.url forKey:@"url"];
    [dic setObject:self.newsModel.ImgStrjiemu forKey:@"ImgStrjiemu"];
    [dic setObject:self.newsModel.ZhengWenjiemu forKey:@"ZhengWenjiemu"];
    [dic setObject:self.newsModel.praisenum forKey:@"praisenum"];
    [CommonCode writeToUserD:dic andKey:THELASTNEWSDATA];
    
}
#pragma mark - UIButtonAction

- (void)selecteItemAction:(UIButton *)sender {
    switch (sender.tag - 10) {
        case 0:
        {
            //下载
            [self downloadAction:sender];
        }
            break;
        case 1:
        {
            //投金币
            [self appreciateGold];
            
        }
            break;
        case 2:
        {
            //评论
            [self pinglunAction];
        }
            break;
            
        default:
            break;
    }
}

- (void)rewardButtonAciton:(UIButton *)sender {
    self.isReward = YES;
    [self.tableView reloadData];
}

- (void)lookupRewardListButton:(UIButton *)sender {
    
    RewardListViewController *vc = [RewardListViewController new];
    vc.post_id = self.newsModel.jiemuID;
    vc.act_id = self.newsModel.post_news;
    self.hidesBottomBarWhenPushed = YES;
    [self.navigationController pushViewController:vc animated:YES];
    
}

- (void)finalRewardButtonAciton:(OJLAnimationButton *)sender {
    [self.view endEditing:YES];
    if ([[CommonCode readFromUserD:@"isLogin"]boolValue] == YES){
        [sender startAnimation];
    }
    else{
        [self rewardOrLoginfirst];
    }
}

- (void)rewarding{
    PayOnlineViewController *vc = [PayOnlineViewController new];
    NSString *accesstoken = nil;
    if ([[CommonCode readFromUserD:@"isLogin"]boolValue] == YES){
        accesstoken = AvatarAccessToken;
        [NetWorkTool getListenMoneyWithaccessToken:accesstoken sccess:^(NSDictionary *responseObject) {
            RTLog(@"%@",responseObject);
            if ([responseObject[@"status"] integerValue] == 1) {
                vc.balanceCount = [responseObject[@"results"][@"listen_money"] doubleValue];
                vc.rewardCount = self.rewardCount;
                vc.uid = (self.newsModel.post_news != nil) ? self.newsModel.post_news : self.newsModel.jiemuID;
                vc.post_id = self.newsModel.jiemuID;
                vc.isPayClass = NO;
                self.hidesBottomBarWhenPushed = YES;
                [self.navigationController pushViewController:vc animated:YES];
            }
            
        } failure:^(NSError *error) {
            
        }];
    }
    else{
        accesstoken = nil;
        vc.balanceCount = 0.00;
        vc.rewardCount = self.rewardCount;
        vc.uid = (self.newsModel.post_news != nil) ? self.newsModel.post_news : self.newsModel.jiemuID;
        vc.post_id = self.newsModel.jiemuID;
        vc.isPayClass = NO;
        self.hidesBottomBarWhenPushed = YES;
        [self.navigationController pushViewController:vc animated:YES];
    }
   
}

- (void)selecteRewardCountAction:(UIButton *)sender {
    
    for ( int i = 0 ; i < self.buttons.count; i ++ ) {
        if (i == sender.tag - 100 ) {
            UIButton *allDoneButton = self.buttons[i];
            [allDoneButton setBackgroundColor:gButtonRewardColor];
            [allDoneButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
            continue;
        }
        else{
            UIButton *anotherButton = self.buttons[i];
            [anotherButton setBackgroundColor:[UIColor whiteColor]];
            [anotherButton setTitleColor:gTextRewardColor forState:UIControlStateNormal];
            continue;
        }
    }
    DefineWeakSelf;
    switch (sender.tag - 100) {
        case 0:self.rewardCount = 1;break;
        case 1:self.rewardCount = 5;break;
        case 2:self.rewardCount = 10;break;
        case 3:self.rewardCount = 50;break;
        case 4:self.rewardCount = 100;break;
        case 5:[weakSelf customRewardCount];break;
        default:break;
    }
}

- (void)backButtonAction:(UIButton *)sender {
    self.isReward = NO;
    self.isCustomRewardCount = NO;
    [self.tableView reloadData];
}

- (void)customRewardCount {
    self.isCustomRewardCount = YES;
    [self.tableView reloadData];
}

#pragma mark - 后台控制
- (void)handleInterruption:(NSNotification *)notification{
    NSDictionary *info = notification.userInfo;
    AVAudioSessionInterruptionType type = [info[AVAudioSessionInterruptionTypeKey] unsignedIntegerValue];
    if (type == AVAudioSessionInterruptionTypeBegan) {
        //Handle InterruptionBegan
        RTLog(@"interruptionTypeBegan");
    }else{
        AVAudioSessionInterruptionOptions options = [info[AVAudioSessionInterruptionOptionKey] unsignedIntegerValue];
        if (options == AVAudioSessionInterruptionOptionShouldResume) {
            //Handle Resume
            [Explayer play];
            [bofangCenterBtn setImage:[UIImage imageNamed:@"home_news_ic_pause"] forState:UIControlStateNormal];
        }
    }
}


- (void)configNowPlayingInfoCenter{
    if (self.newsModel.jiemuID == nil) {
        return;
    }
    //    设置后台播放时显示的东西，例如歌曲名字，图片等
    
    [self getImageWithURLStr:self.newsModel.ImgStrjiemu OnSucceed:^(UIImage *image) {
        if (image == nil) {
            image = [UIImage imageNamed:@"tingwen_bg_square"];
        }
        MPMediaItemArtwork *artWork = [[MPMediaItemArtwork alloc] initWithImage:image];
        //歌曲名称、演唱者、专辑缩列图、音乐剩余时长、音乐当前播放时间
        //MPMediaItemPropertyAlbumTitle:专辑名
        NSDictionary *dic = @{MPMediaItemPropertyTitle:[self.newsModel.Titlejiemu length] ? self.newsModel.Titlejiemu : @"听闻",
                              MPMediaItemPropertyArtist:[self.newsModel.jiemuName length] ? self.newsModel.jiemuName : @"听闻",
                              MPMediaItemPropertyArtwork:artWork,
                              MPNowPlayingInfoPropertyPlaybackRate:[NSNumber numberWithFloat:1.0],
                              MPMediaItemPropertyPlaybackDuration:[NSNumber numberWithDouble:[self.newsModel.post_time intValue] / 1000]
                              };
        [[MPNowPlayingInfoCenter defaultCenter] setNowPlayingInfo:dic];
    }];

}
- (void)remoteControlReceivedWithEvent:(UIEvent *)event {
    //判断是否是后台音频
    if (event.type == UIEventTypeRemoteControl) {
        switch (event.subtype) {
            case UIEventSubtypeRemoteControlTogglePlayPause:
                //暂停或播放
                [self doPlay:bofangCenterBtn];
                break;
                
            case UIEventSubtypeRemoteControlPreviousTrack:
                //上一首
                [self bofangLeftAction:bofangLeftBtn];
                break;
            case UIEventSubtypeRemoteControlNextTrack:
                //下一首
                [self bofangRightAction:bofangRightBtn];
                break;
                
            default:
                [self doPlay:bofangCenterBtn];
                break;
        }
    }
}

#pragma mark - WXApiDelegate
/*! @brief 收到一个来自微信的请求，第三方应用程序处理完后调用sendResp向微信发送结果
 *
 * 收到一个来自微信的请求，异步处理完成后必须调用sendResp发送处理结果给微信。
 * 可能收到的请求有GetMessageFromWXReq、ShowMessageFromWXReq等。
 * @param req 具体请求内容，是自动释放的
 */
-(void) onReq:(BaseReq*)req{
    RTLog(@"%@",req);
}


/*! @brief 发送一个sendReq后，收到微信的回应
 *
 * 收到一个来自微信的处理结果。调用一次sendReq后会收到onResp。
 * 可能收到的处理结果有SendMessageToWXResp、SendAuthResp等。
 * @param resp具体的回应内容，是自动释放的
 */
-(void) onResp:(BaseResp*)resp{
    RTLog(@"%@",resp);
}

#pragma mark -TencentSessionDelegate
- (void)addShareResponse:(APIResponse*) response{
    RTLog(@"%@",response);
}

- (void)handleSendResult:(QQApiSendResultCode)sendResult {
    switch (sendResult)
    {
        case EQQAPIAPPNOTREGISTED:
        {
            UIAlertView *msgbox = [[UIAlertView alloc] initWithTitle:@"Error" message:@"App未注册" delegate:nil cancelButtonTitle:@"取消" otherButtonTitles:nil];
            [msgbox show];
            
            break;
        }
        case EQQAPIMESSAGECONTENTINVALID:
        case EQQAPIMESSAGECONTENTNULL:
        case EQQAPIMESSAGETYPEINVALID:
        {
            UIAlertView *msgbox = [[UIAlertView alloc] initWithTitle:@"Error" message:@"发送参数错误" delegate:nil cancelButtonTitle:@"取消" otherButtonTitles:nil];
            [msgbox show];
            
            break;
        }
        case EQQAPIQQNOTINSTALLED:
        {
            UIAlertView *msgbox = [[UIAlertView alloc] initWithTitle:@"Error" message:@"未安装手Q" delegate:nil cancelButtonTitle:@"取消" otherButtonTitles:nil];
            [msgbox show];
            
            break;
        }
        case EQQAPIQQNOTSUPPORTAPI:
        {
            UIAlertView *msgbox = [[UIAlertView alloc] initWithTitle:@"Error" message:@"API接口不支持" delegate:nil cancelButtonTitle:@"取消" otherButtonTitles:nil];
            [msgbox show];
            
            break;
        }
        case EQQAPISENDFAILD:
        {
            UIAlertView *msgbox = [[UIAlertView alloc] initWithTitle:@"Error" message:@"发送失败" delegate:nil cancelButtonTitle:@"取消" otherButtonTitles:nil];
            [msgbox show];
            
            break;
        }
        case EQQAPIVERSIONNEEDUPDATE:
        {
            UIAlertView *msgbox = [[UIAlertView alloc] initWithTitle:@"Error" message:@"当前QQ版本太低，需要更新" delegate:nil cancelButtonTitle:@"取消" otherButtonTitles:nil];
            [msgbox show];
            break;
        }
        default:
        {
            break;
        }
    }
}

#pragma mark - UITableViewDelegate

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.pinglunArr.count + 2;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if (indexPath.row == 0){
        static NSString *xinwenxiangqingIdentify = @"xinwenxiangqingIdentify";
        UITableViewCell *cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:xinwenxiangqingIdentify];
        if (!cell)
        {
            cell = [tableView dequeueReusableCellWithIdentifier:xinwenxiangqingIdentify];
        }
        xiangqingView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, IPHONE_W, IPHONE_H)];
        xiangqingView.backgroundColor = [UIColor whiteColor];
        
        //新闻图片
        self.zhengwenImg.frame = CGRectMake(0, -20, IPHONE_W, 209.0 / 667 * SCREEN_HEIGHT);
        
        UIBezierPath *maskPath = [UIBezierPath bezierPathWithRoundedRect:_zhengwenImg.bounds byRoundingCorners:UIRectCornerBottomRight cornerRadii:CGSizeMake(160.0 / 667 * SCREEN_HEIGHT, 160.0 / 667 * SCREEN_HEIGHT)];
        CAShapeLayer *maskLayer = [[CAShapeLayer alloc] init];
        maskLayer.frame = _zhengwenImg.bounds;
        maskLayer.path = maskPath.CGPath;
        _zhengwenImg.layer.mask = maskLayer;
        
        //生成图片
        NSString *imgUrl4 = self.newsModel.ImgStrjiemu;
        if ([imgUrl4 rangeOfString:@"userDownLoadPathImage"].location != NSNotFound) {
            [_zhengwenImg sd_setImageWithURL:[NSURL fileURLWithPath:imgUrl4] placeholderImage:[UIImage imageNamed:@"thumbnailsdefault"]];
        }
        else if ([imgUrl4  rangeOfString:@"http"].location != NSNotFound)
        {
            [_zhengwenImg sd_setImageWithURL:[NSURL URLWithString:imgUrl4] placeholderImage:[UIImage imageNamed:@"thumbnailsdefault"]];
        }else
        {
            NSString *str = USERPHOTOHTTPSTRINGZhuBo(imgUrl4);
            [_zhengwenImg sd_setImageWithURL:[NSURL URLWithString:str] placeholderImage:[UIImage imageNamed:@"thumbnailsdefault"]];
        }
        
        //添加单击手势
        UITapGestureRecognizer *tapZhengwenImg = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(showZoomImageView:)];
        [_zhengwenImg addGestureRecognizer:tapZhengwenImg];
        [xiangqingView addSubview:_zhengwenImg];
        //主播头像
        self.zhuboImg.frame = CGRectMake(20.0 / 375 * IPHONE_W, CGRectGetMaxY(_zhengwenImg.frame) + 10.0 / 667 * IPHONE_H,  27.0 / 667 * IPHONE_H, 27.0 / 667 * IPHONE_H);
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(zhuboBtnVAction:)];
        [_zhuboImg addGestureRecognizer:tap];
        if([self.newsModel.jiemuImages rangeOfString:@"/data/upload/"].location !=NSNotFound)//_roaldSearchText
        {
            IMAGEVIEWHTTP(_zhuboImg, self.newsModel.jiemuImages);
        }
        else
        {
            IMAGEVIEWHTTP2(_zhuboImg, self.newsModel.jiemuImages);
        }
        [xiangqingView addSubview:_zhuboImg];
        //主播名字
        self.zhuboTitleLab.frame = CGRectMake(CGRectGetMaxX(_zhuboImg.frame) + 4.0 / 375 * IPHONE_W, _zhuboImg.frame.origin.y +  5.0 / 667 * IPHONE_H, 88.0 / 375 * IPHONE_W, 15.0 / 667 * IPHONE_H);
        _zhuboTitleLab.text = self.newsModel.jiemuName;
        [_zhuboTitleLab addTapGesWithTarget:self action:@selector(zhuboBtnVAction:)];
        CGSize contentSize = [_zhuboTitleLab sizeThatFits:CGSizeMake(_zhuboTitleLab.frame.size.width, MAXFLOAT)];
        _zhuboTitleLab.frame = CGRectMake(_zhuboTitleLab.frame.origin.x, _zhuboTitleLab.frame.origin.y,contentSize.width, _zhuboTitleLab.frame.size.height);
        [xiangqingView addSubview:_zhuboTitleLab];
        
        self.mic.frame = CGRectMake(CGRectGetMaxX(_zhuboTitleLab.frame) + 6.0 / 375 * SCREEN_WIDTH, _zhuboTitleLab.frame.origin.y + 1.0 / 667 * SCREEN_HEIGHT, 8.0 /375 * SCREEN_WIDTH, 14.0 / 667 * SCREEN_HEIGHT);
        [_mic addTapGesWithTarget:self action:@selector(zhuboBtnVAction:)];
        [xiangqingView addSubview:_mic];
        
        self.achorTouch.frame = CGRectMake(CGRectGetMaxX(_mic.frame), CGRectGetMaxY(_zhengwenImg.frame), SCREEN_WIDTH - CGRectGetMaxX(_mic.frame) - 80.0 / 375 * IPHONE_W , 47.0 / 667 * SCREEN_HEIGHT);
        [_achorTouch  addTapGesWithTarget:self action:@selector(zhuboBtnVAction:)];
        [xiangqingView addSubview:_achorTouch];
        
        //主播简介
//        UILabel *zhuboSignatureLab = [[UILabel alloc]initWithFrame:CGRectMake(CGRectGetMaxX(zhuboImg.frame) + 10.0 / 375 * IPHONE_W, CGRectGetMaxY(zhuboTitleLab.frame) + 10.0 / 667 * IPHONE_H, 250.0 / 375 * IPHONE_W, 15.0 / 667 * IPHONE_H)];
//        
//        zhuboSignatureLab.textColor = [UIColor blackColor];
//        zhuboSignatureLab.font = [UIFont fontWithName:@"Helvetica-Bold" size:13.0f ];
//        zhuboSignatureLab.textAlignment = NSTextAlignmentLeft;
//        zhuboSignatureLab.alpha = 0.5f;
//        zhuboSignatureLab.text = self.newsModel.jiemuDescription;
//        [xiangqingView addSubview:zhuboSignatureLab];
        //关注、取消
        UIButton *guanzhuBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        guanzhuBtn.frame = CGRectMake(SCREEN_WIDTH - 80.0 / 375 * IPHONE_W, CGRectGetMaxY(_zhengwenImg.frame) + 9.0 / 375 * IPHONE_W, 60.0 / 375 * IPHONE_W, 30.0 / 667 * IPHONE_H);
        if (isGuanZhu == YES)
        {
            [guanzhuBtn setTitle:@"取消" forState:UIControlStateNormal];
        }
        else{
            [guanzhuBtn setTitle:@"+ 关注" forState:UIControlStateNormal];
        }
        [guanzhuBtn setTitleColor:gMainColor forState:UIControlStateNormal];
        guanzhuBtn.titleLabel.font  = [UIFont systemFontOfSize:13.0];
        guanzhuBtn.layer.cornerRadius = 4;
        guanzhuBtn.layer.masksToBounds = YES;
        guanzhuBtn.layer.borderColor = gMainColor.CGColor;
        guanzhuBtn.layer.borderWidth = 0.5f;
        guanzhuBtn.bounds = CGRectMake(0, 0, 50, 30);
        [guanzhuBtn addTarget:self action:@selector(guanzhuBtnAction:) forControlEvents:UIControlEventTouchUpInside];
        [xiangqingView addSubview:guanzhuBtn];
        

        self.seperatorLine.frame = CGRectMake(20.0 / 375 * SCREEN_WIDTH, CGRectGetMaxY(_zhuboImg.frame) +  12.0 / 667 * SCREEN_HEIGHT, SCREEN_WIDTH - 40.0 / 375 * SCREEN_WIDTH, 1.0);
        [xiangqingView addSubview:_seperatorLine];
        
        //标题
        self.titleLab.frame = CGRectMake(20.0 / 375 * IPHONE_W,CGRectGetMaxY(_seperatorLine.frame) + 20.0 / 667 * SCREEN_HEIGHT, IPHONE_W - 40.0 / 375 * IPHONE_W, 40.0 / 667 * IPHONE_H);
        _titleLab.text = self.newsModel.Titlejiemu;
        _titleLab.font = [UIFont fontWithName:@"Semibold" size:self.titleFontSize];
        CGFloat titleHight = [self computeTextHeightWithString:self.newsModel.jiemuDescription andWidth:(SCREEN_WIDTH-20) andFontSize:[UIFont systemFontOfSize:self.titleFontSize]];
        [_titleLab setFrame:CGRectMake(20.0 / 375 * IPHONE_W, CGRectGetMaxY(_seperatorLine.frame) + 20.0 / 667 * SCREEN_HEIGHT, IPHONE_W - 40.0 / 375 * IPHONE_W, (titleHight + 20) / 667 * IPHONE_H)];
        
        [xiangqingView addSubview:_titleLab];
        //日期
        self.riqiLab.frame = CGRectMake(10.0 / 375 * IPHONE_W, CGRectGetMaxY(_titleLab.frame) + 10.0 / 667 * IPHONE_H, IPHONE_W - 20.0 / 375 * IPHONE_W, 10.0 / 667 * IPHONE_H);
        NSDate *date = [NSDate dateFromString:self.newsModel.RiQijiemu];
        _riqiLab.text = [NSString stringWithFormat:@"#来自:%@   %@ ",self.newsModel.post_lai,[date showTimeByTypeA]];
        [xiangqingView addSubview:_riqiLab];
        
        //新闻内容
        self.zhengwenTextView.frame = CGRectMake(20.0 / 375 * IPHONE_W, CGRectGetMaxY(_riqiLab.frame) + 24.0 / 667 * IPHONE_H, IPHONE_W - 40.0 / 375 * IPHONE_W, 50.0 / 667 * IPHONE_H);
        NSString *str1 = [self.newsModel.ZhengWenjiemu stringByReplacingOccurrencesOfString:@"\r" withString:@""];
        _zhengwenTextView.text = str1;
        _zhengwenTextView.font = [UIFont systemFontOfSize:self.titleFontSize];
        NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle alloc]init];
        [paragraphStyle setLineSpacing:8.0];
        [paragraphStyle setAlignment:NSTextAlignmentLeft];
        [paragraphStyle setFirstLineHeadIndent:5.0];
        [paragraphStyle setLineBreakMode:NSLineBreakByCharWrapping];
        [_zhengwenTextView sizeToFit];
        if (_zhengwenTextView.text.length != 0)
        {
            NSMutableAttributedString *attributedString =  [[NSMutableAttributedString alloc] initWithString:_zhengwenTextView.text attributes:@{NSForegroundColorAttributeName : gTextDownload,NSFontAttributeName : [UIFont systemFontOfSize:self.titleFontSize]}];
            [attributedString addAttribute:NSParagraphStyleAttributeName value:paragraphStyle range:NSMakeRange(0, _zhengwenTextView.text.length)];
            _zhengwenTextView.attributedText = attributedString;
        }
        
        CGSize size2 = [_zhengwenTextView sizeThatFits:CGSizeMake(_zhengwenTextView.frame.size.width, MAXFLOAT)];
        _zhengwenTextView.frame = CGRectMake(_zhengwenTextView.frame.origin.x, _zhengwenTextView.frame.origin.y, _zhengwenTextView.frame.size.width, size2.height);
        [xiangqingView addSubview:_zhengwenTextView];
        
        //阅读原文
        UIButton *readOriginalEssay = [UIButton buttonWithType:UIButtonTypeCustom];
        CGFloat OriginalEssay = 0.0f;
        if ([self.newsModel.url length]) {
            [readOriginalEssay setFrame:CGRectMake(20, CGRectGetMaxY(_zhengwenTextView.frame) + 10, SCREEN_WIDTH - 40, 35.0 / 667 * IPHONE_H)];
            readOriginalEssay.backgroundColor = gMainColor;
            [readOriginalEssay setTitle:@"阅读原文" forState:UIControlStateNormal];
            [readOriginalEssay.layer setMasksToBounds:YES];
            [readOriginalEssay.layer setCornerRadius:5.0f];
            readOriginalEssay.userInteractionEnabled = YES;
            [readOriginalEssay addTarget:self action:@selector(readOriginalEssay:) forControlEvents:UIControlEventTouchUpInside];
            OriginalEssay = 50.0f;
        }
        else{
            [readOriginalEssay setFrame:CGRectMake(0, CGRectGetMaxY(_zhengwenTextView.frame), SCREEN_WIDTH, 1)];
            readOriginalEssay.userInteractionEnabled = NO;
            OriginalEssay = 0.0f;
        }
        [xiangqingView addSubview:readOriginalEssay];
        
        //
        UIView *topLine = [[UIView alloc]initWithFrame:CGRectMake(0, CGRectGetMaxY(_zhengwenTextView.frame) + OriginalEssay + 15.0 / 667 * IPHONE_H, IPHONE_W, 1)];
        topLine.backgroundColor = [UIColor lightGrayColor];
        topLine.alpha = 0.5f;
        [xiangqingView addSubview:topLine];
    
        //下载、投金币、评论
        NSMutableArray *itemArr = [NSMutableArray array];
        
        NSDictionary *dic0 = @{@"image":@"home_news_download",@"title":@"下载"};
        [itemArr addObject:dic0];
        NSDictionary *dic1 = @{@"image":@"tb",@"title":@"投金币"};
        [itemArr addObject:dic1];
        NSDictionary *dic2 = @{@"image":@"iconfont_pinglun",@"title":@"评论"};
        [itemArr addObject:dic2];
        for (int i = 0; i < [itemArr count]; i ++) {
            CGFloat w = (SCREEN_WIDTH - 30 * itemArr.count) / (itemArr.count * 2);
            UIButton *itemImgBtn = [UIButton buttonWithType:UIButtonTypeCustom];
            [itemImgBtn setFrame:CGRectMake(i % itemArr.count * (2 * w + 30) + w , CGRectGetMaxY(topLine.frame) + 10, 30, 30)];
            [itemImgBtn setImage:[UIImage imageNamed:itemArr[i][@"image"]] forState:UIControlStateNormal];
            [itemImgBtn setTag:(10 + i)];
            [itemImgBtn addTarget:self action:@selector(selecteItemAction:) forControlEvents:UIControlEventTouchUpInside];
            [xiangqingView addSubview:itemImgBtn];
            
            UIButton *itemBtn = [UIButton buttonWithType:UIButtonTypeCustom];
            [itemBtn setFrame:CGRectMake(itemImgBtn.frame.origin.x - 5, itemImgBtn.frame.origin.y + itemImgBtn.frame.size.height, 40, 20)];
            [itemBtn setTitle:itemArr[i][@"title"] forState:UIControlStateNormal];
            [itemBtn setTitleColor:gTextDownload forState:UIControlStateNormal];
            [itemBtn.titleLabel setFont:gFontMain12];
            [itemBtn setTag:(10 + i)];
            [itemBtn addTarget:self action:@selector(selecteItemAction:) forControlEvents:UIControlEventTouchUpInside];
            [xiangqingView addSubview:itemBtn];
            if (i == 1) {
                [self.appreciateNum setFrame:CGRectMake(CGRectGetMaxX(itemImgBtn.frame) - 10, itemImgBtn.frame.origin.y, 20, 10)];
                [xiangqingView addSubview:self.appreciateNum];
            }
            else if (i == 2){
                [self.commentNum setFrame:CGRectMake(CGRectGetMaxX(itemImgBtn.frame) - 10, itemImgBtn.frame.origin.y, 20, 10)];
                [xiangqingView addSubview:self.commentNum];
            }
        }
        
        UIView *downLine = [[UIView alloc]initWithFrame:CGRectMake(0, CGRectGetMaxY(topLine.frame) + 70, IPHONE_W, 1)];
        downLine.backgroundColor = [UIColor lightGrayColor];
        downLine.alpha = 0.5f;
        [xiangqingView addSubview:downLine];
        

        UIView *payTopLine = [[UIView alloc]initWithFrame:CGRectMake(0, CGRectGetMaxY(downLine.frame) , IPHONE_W, 5)];
        payTopLine.backgroundColor = [UIColor colorWithRed:0.95 green:0.96 blue:0.98 alpha:1.00];
        payTopLine.alpha = 0.5f;
        [xiangqingView addSubview:payTopLine];
        
        //TODO:打赏入口
        UIView *rewardView = [[UIView alloc] initWithFrame:CGRectMake(-5, CGRectGetMaxY(payTopLine.frame) ,  SCREEN_WIDTH + 10, 170)];
        
        [rewardView setUserInteractionEnabled:YES];
        [rewardView setBackgroundColor:[UIColor whiteColor]];
        [rewardView.layer setBorderWidth:0.5];
        [rewardView.layer setBorderColor:[UIColor lightGrayColor].CGColor];
        UIView *rewardBorderView = [[UIView alloc]initWithFrame:CGRectMake(15, 55, SCREEN_WIDTH - 30, 100)];
        [rewardBorderView setUserInteractionEnabled:YES];
        [rewardBorderView.layer setBorderWidth:1.0];
        [rewardBorderView.layer setBorderColor:gTextRewardColor.CGColor];
        [rewardBorderView.layer setMasksToBounds:YES];
        [rewardBorderView.layer setCornerRadius:5.0];
        [rewardView addSubview:rewardBorderView];
        UIImageView *smile = [[UIImageView alloc]initWithFrame:CGRectMake(30, 15, 60, 66.5)];
        [smile setImage:[UIImage imageNamed:@"COIN21"]];
        [rewardView addSubview:smile];
        
        if (self.isReward) {
            
            UILabel *tipLabel = [[UILabel alloc]initWithFrame:CGRectMake( 80, 5, 220, 32)];
            [tipLabel setText:self.isCustomRewardCount ? @"请输入自定义金额" : @"您的支持是我们最大的动力~"];
            [tipLabel setTextColor:gTextDownload];
            [tipLabel setFont:gFontMain14];
            [rewardBorderView addSubview:tipLabel];
            
            UIView *selectedView = [[UIView alloc]initWithFrame:CGRectMake(0, 41, rewardBorderView.frame.size.width, 80)];
            [rewardBorderView addSubview:selectedView];
            selectedView.hidden = self.isCustomRewardCount ? YES : NO;
            NSMutableArray *itemArr = [NSMutableArray array];
            NSDictionary *dic0 = @{@"title":@"1听币"};
            [itemArr addObject:dic0];
            NSDictionary *dic1 = @{@"title":@"5听币"};
            [itemArr addObject:dic1];
            NSDictionary *dic2 = @{@"title":@"10听币"};
            [itemArr addObject:dic2];
            NSDictionary *dic3 = @{@"title":@"50听币"};
            [itemArr addObject:dic3];
            NSDictionary *dic4 = @{@"title":@"100听币"};
            [itemArr addObject:dic4];
            NSDictionary *dic5 = @{@"title":@"自定义"};
            [itemArr addObject:dic5];
            if ([self.buttons count]) {
                [self.buttons removeAllObjects];
            }
            for (int i = 0 ; i < 2 * 3; i ++) {
                CGFloat w = (rewardBorderView.frame.size.width - 240) / 4;
                CGFloat h = (rewardBorderView.frame.size.height - 90)/3;
                UIButton *itemImgBtn = [UIButton buttonWithType:UIButtonTypeCustom];
                [itemImgBtn setFrame:CGRectMake(i % 3 * (w + 80) + w , i / 3 *(30 + h)+ h, 80, 30)];
                [itemImgBtn setTitle:itemArr[i][@"title"] forState:UIControlStateNormal];
                [itemImgBtn setTitleColor:gTextRewardColor forState:UIControlStateNormal];
                [itemImgBtn.layer setBorderWidth:0.5];
                [itemImgBtn.layer setBorderColor:gTextRewardColor.CGColor];
                [itemImgBtn.layer setMasksToBounds:YES];
                [itemImgBtn.layer setCornerRadius:15.0];
                [itemImgBtn.titleLabel setFont:gFontSub11];
                [itemImgBtn setTag:(100 + i)];
                [itemImgBtn addTarget:self action:@selector(selecteRewardCountAction:) forControlEvents:UIControlEventTouchUpInside];
                [self.buttons addObject:itemImgBtn];
                [selectedView addSubview:itemImgBtn];
                if (i == 1) {
                    [self selecteRewardCountAction:itemImgBtn];
                }
            }
            
            UIView *customRewardView = [[UIView alloc] initWithFrame:CGRectMake(15, 55, rewardBorderView.frame.size.width - 30, 50)];
            [customRewardView setUserInteractionEnabled:YES];
            [customRewardView.layer setBorderWidth:1.0];
            [customRewardView.layer setBorderColor:gTextRewardColor.CGColor];
            [customRewardView.layer setMasksToBounds:YES];
            [customRewardView.layer setCornerRadius:10.0];
            [rewardBorderView addSubview:customRewardView];
            customRewardView.hidden = self.isCustomRewardCount ? NO : YES;
            UIImageView *tcoin = [[UIImageView alloc]initWithFrame:CGRectMake(15, 13, 22.5, 25.5)];
            [tcoin setImage:[UIImage imageNamed:@"tcoin"]];
            [customRewardView addSubview:tcoin];
            _customRewardTextField = [[UITextField alloc]initWithFrame:CGRectMake(CGRectGetMaxX(tcoin.frame) + 13, 13, customRewardView.frame.size.width - 30 - 13 - 22.5, 25.5)];
            [_customRewardTextField setPlaceholder:@"可输入1-500整数"];
            [_customRewardTextField setFont:gFontSub11];
            [_customRewardTextField setClearButtonMode:UITextFieldViewModeAlways];
            [_customRewardTextField setKeyboardType:UIKeyboardTypeNumberPad];
            [_customRewardTextField setDelegate:self];
            [customRewardView addSubview:_customRewardTextField];
            
            //TODO:自定义打赏
            _finalRewardButton = [OJLAnimationButton buttonWithFrame:CGRectMake(15, CGRectGetMaxY(selectedView.frame), rewardBorderView.frame.size.width - 30, 40)];
            _finalRewardButton.delegate = self;
            [_finalRewardButton.layer setMasksToBounds:YES];
            [_finalRewardButton.layer setCornerRadius:5.0];
            [_finalRewardButton setBackgroundColor:gButtonRewardColor];
            [_finalRewardButton.titleLabel setFont:gFontMajor17];
            [_finalRewardButton setTitle:@"赞赏" forState:UIControlStateNormal];
            [_finalRewardButton addTarget:self action:@selector(finalRewardButtonAciton:) forControlEvents:UIControlEventTouchUpInside];
            [rewardBorderView addSubview:_finalRewardButton];
            
            UIButton *backButton = [UIButton buttonWithType:UIButtonTypeCustom];
            [backButton setFrame:CGRectMake(CGRectGetMaxX(_finalRewardButton.frame) - 38, CGRectGetMaxY(_finalRewardButton.frame) + 5, 30, 15)];
            [backButton.titleLabel setFont:gFontSub11];
            [backButton setTitleColor:gTextColorSub forState:UIControlStateNormal];
            [backButton setTitle:@"返回" forState:UIControlStateNormal];
            [backButton addTarget:self action:@selector(backButtonAction:) forControlEvents:UIControlEventTouchUpInside];
            [rewardBorderView addSubview:backButton];
            
            [rewardBorderView setFrame:CGRectMake(rewardBorderView.frame.origin.x, rewardBorderView.frame.origin.y, rewardBorderView.frame.size.width, CGRectGetMaxY(_finalRewardButton.frame) + 35)];
             [rewardView setFrame:CGRectMake(rewardView.frame.origin.x, rewardView.frame.origin.y, rewardView.frame.size.width, CGRectGetMaxY(rewardBorderView.frame) + 15)];
        }
        else{
            UILabel *tipLabel = [[UILabel alloc]initWithFrame:CGRectMake( 80, 5, 170, 32)];
            [tipLabel setText:@"千山万水总是情，\n支持一下行不行~"];
            [tipLabel setNumberOfLines:0];
            [tipLabel setTextColor:gTextDownload];
            [tipLabel setFont:gFontSub11];
            [rewardBorderView addSubview:tipLabel];
            
            UIButton *rewardButton = [UIButton buttonWithType:UIButtonTypeCustom];
            [rewardButton setFrame:CGRectMake(CGRectGetMaxX(rewardBorderView.frame) - 90, 10, 60, 30)];
            [rewardButton.layer setMasksToBounds:YES];
            [rewardButton.layer setCornerRadius:5.0];
            [rewardButton setBackgroundColor:gButtonRewardColor];
            [rewardButton.titleLabel setFont:gFontMain12];
            [rewardButton setTitle:@"赞赏" forState:UIControlStateNormal];
            [rewardButton addTarget:self action:@selector(rewardButtonAciton:) forControlEvents:UIControlEventTouchUpInside];
            [rewardBorderView addSubview:rewardButton];
            
            UIView *midleLine = [[UIView alloc]initWithFrame:CGRectMake(0, rewardBorderView.frame.size.height / 2, rewardBorderView.frame.size.width, 0.5)];
            midleLine.backgroundColor = [UIColor lightGrayColor];
            midleLine.alpha = 0.5f;
            [rewardBorderView addSubview:midleLine];
            
           
            if (self.isPay) {
                NSMutableArray *titleArr = [NSMutableArray new];
                NSMutableArray *imageArr = [NSMutableArray new];
                NSInteger num = (self.rewardArray.count > 5) ? 5 : self.rewardArray.count;
                for (int i = 0 ; i < num; i ++) {
                    [titleArr addObject:self.rewardArray[i][@"money"]];
                    [imageArr addObject:self.rewardArray[i][@"avatar"] ];
                }
                
                MenuItemV *paidView = [[MenuItemV alloc]initWithFrame:CGRectMake(15, CGRectGetMaxY(midleLine.frame),32 * AdaptiveScale_W * [titleArr count] + 20,36) andTitleArr:titleArr andImgArr:imageArr andLineNum:[titleArr count]];
                
                [rewardBorderView addSubview:paidView];
                
                if ([self.rewardArray count] >= 5) {
                    UILabel *paidLabel = [[UILabel alloc]initWithFrame:CGRectMake(CGRectGetMaxX(paidView.frame) - 20,CGRectGetMaxY(midleLine.frame) + 10, 60, 32)];
                    [paidLabel setText:[NSString stringWithFormat:@"等%lu人赞过",(unsigned long)[self.rewardArray count]]];
                    [paidLabel setTextAlignment:NSTextAlignmentCenter];
                    [paidLabel setTextColor:UIColorFromHex(666666)];
                    [paidLabel setFont:gFontSub11];
                    [rewardBorderView addSubview:paidLabel];
                }
                
                UIButton *rewardListButton = [UIButton buttonWithType:UIButtonTypeCustom];
                [rewardListButton setFrame:CGRectMake(CGRectGetMaxX(rewardBorderView.frame) - 90, CGRectGetMaxY(midleLine.frame) + 10, 60, 30)];
                [rewardListButton.layer setMasksToBounds:YES];
                [rewardListButton.layer setCornerRadius:5.0];
                [rewardListButton.layer setBorderColor:gTextRewardColor.CGColor];
                [rewardListButton.layer setBorderWidth:0.5];
                [rewardListButton.titleLabel setFont:gFontMain12];
                [rewardListButton setTitleColor:gButtonRewardColor forState:UIControlStateNormal];
                [rewardListButton setTitle:@"查看榜单" forState:UIControlStateNormal];
                [rewardListButton addTarget:self action:@selector(lookupRewardListButton:) forControlEvents:UIControlEventTouchUpInside];
                [rewardBorderView addSubview:rewardListButton];
                
            }
            else{
                UILabel *noPayLabel = [[UILabel alloc]initWithFrame:CGRectMake( 0,rewardBorderView.frame.size.height / 2 + 10, rewardBorderView.frame.size.width, 32)];
                [noPayLabel setText:@"还没有人赞过呢，快来当第一~"];
                [noPayLabel setTextAlignment:NSTextAlignmentCenter];
                [noPayLabel setTextColor:UIColorFromHex(666666)];
                [noPayLabel setFont:gFontSub11];
                [rewardBorderView addSubview:noPayLabel];
            }
        }
        
        [xiangqingView addSubview:rewardView];
        
        xiangqingView.frame = CGRectMake(xiangqingView.frame.origin.x, xiangqingView.frame.origin.y, xiangqingView.frame.size.width, CGRectGetMaxY(rewardView.frame));
        [cell.contentView addSubview:xiangqingView];
        
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        return cell;
    }
    else if (indexPath.row == 1){
        static NSString *youmeiyoupinglunIdentify = @"youmeiyoupinglunIdentify";
        UITableViewCell *cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:youmeiyoupinglunIdentify];
        if (!cell)
        {
            cell = [tableView dequeueReusableCellWithIdentifier:youmeiyoupinglunIdentify];
        }
//                UILabel *meiyoupinglun = [[UILabel alloc]initWithFrame:CGRectMake(IPHONE_W / 2 - 50.0 / 375 * IPHONE_W, 20.0 / 667 * IPHONE_H, 100.0 / 375 * IPHONE_W, 30.0 / 667 * IPHONE_H)];
//                meiyoupinglun.backgroundColor = ColorWithRGBA(0, 159, 240, 1);
//                meiyoupinglun.textAlignment = NSTextAlignmentCenter;
//                meiyoupinglun.textColor = [UIColor whiteColor];
//                meiyoupinglun.layer.masksToBounds = YES;
//                meiyoupinglun.layer.cornerRadius = 6.0f;
//                [cell.contentView addSubview:meiyoupinglun];
//                if (self.pinglunArr.count == 0)
//                {
//                    meiyoupinglun.text = @"没有评论";
//                }else
//                {
//                    meiyoupinglun.text = @"热门评论";
//                }
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        
        return cell;
    }
    else{
        RTLog(@"indexPath-------------%ld",indexPath.row);
        PlayVCCommentTableViewCell *cell = [PlayVCCommentTableViewCell cellWithTableView:tableView];
        PlayVCCommentFrameModel *frameModel = self.pinglunArr[indexPath.row - 2];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        cell.frameModel = frameModel;
        return cell;
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.row == 0){
        return xiangqingView.frame.size.height;
    }
    else if (indexPath.row == 1){
        return 0.001;
    }
    else{
        PlayVCCommentFrameModel *frameModel = self.pinglunArr[indexPath.row - PINGLUN_ROW];
        return frameModel.cellHeight;
    }
    
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.row == 0){
        
    }
    else if ( !(indexPath.row == 1)) {
        //TODO:删除自己的评论 或者回复、复制
        PlayVCCommentFrameModel *frameModel = self.pinglunArr[indexPath.row - PINGLUN_ROW];
        PlayVCCommentModel *model = frameModel.model;
        NSDictionary *userInfo = [CommonCode readFromUserD:@"dangqianUserInfo"];
        NSString *currentUserID = userInfo[@"results"][@"id"];
        if ([currentUserID isEqualToString:model.uid]) {
            [UIActionSheet actionSheetWithTitle:nil message:nil buttons:@[@"删除", @"复制"] showInView:self.view onDismiss:^(int buttonIndex) {
                if (buttonIndex == 0) {
                    [NetWorkTool delCommentWithaccessToken:[DSE encryptUseDES:ExdangqianUser] comment_id:model.playCommentID sccess:^(NSDictionary *responseObject) {
                        [self huoqupinglunliebiao];

                    } failure:^(NSError *error) {
                        //
                        RTLog(@"delete error");
                    }];
                }
                else{
                    UIPasteboard *gr                             = [UIPasteboard generalPasteboard];
                    gr.string                                    = [NSString stringWithFormat:@"%@",model.content];
                    XWAlerLoginView *xw = [[XWAlerLoginView alloc]initWithTitle:@"分享链接已复制到您的剪切板~~"];
                    [xw show];
                }
            } onCancel:^{
                
            }];
            
        }
        else{
            
            [UIActionSheet actionSheetWithTitle:nil message:nil buttons:@[@"回复", @"复制"] showInView:self.view onDismiss:^(int buttonIndex) {
                if (buttonIndex == 0) {
                    if ([[CommonCode readFromUserD:@"isLogin"]boolValue] == YES)
                    {
                        pinglunyeVC *pinglunye = [pinglunyeVC new];
                        pinglunye.isNewsCommentPage = YES;
                        pinglunye.post_id = model.post_id;
                        pinglunye.to_uid = model.uid;
                        pinglunye.comment_id = model.playCommentID;
                        pinglunye.post_table = model.post_table;
                        self.hidesBottomBarWhenPushed = YES;
                        [self.navigationController pushViewController:pinglunye animated:YES];
                        self.hidesBottomBarWhenPushed = YES;
                    }
                    else{
                        [self loginFirst];
                    }
                }
                else{
                    UIPasteboard *gr                             = [UIPasteboard generalPasteboard];
                    gr.string                                    = [NSString stringWithFormat:@"%@",model.content];
                    XWAlerLoginView *xw = [[XWAlerLoginView alloc]initWithTitle:@"分享链接已复制到您的剪切板~~"];
                    [xw show];
                }
            } onCancel:^{
                
            }];

        }
        
    }
    else{
        
    }
}

#pragma mark - UIScrollViewDelegate

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    if (scrollView.contentOffset.y > 209.0 / 667 * SCREEN_HEIGHT) {
        [_rightBtn setImage:[UIImage imageNamed:@"title_ic_share"] forState:UIControlStateNormal];
        [_leftBtn setImage:[UIImage imageNamed:@"back"] forState:UIControlStateNormal];
        _topView.backgroundColor = [UIColor whiteColor];
    }
    else{
        [_rightBtn setImage:[UIImage imageNamed:@"title_ic_share_white"] forState:UIControlStateNormal];
        [_leftBtn setImage:[UIImage imageNamed:@"title_ic_white"] forState:UIControlStateNormal];
         _topView.backgroundColor = [UIColor clearColor];
    }
}

#pragma mark OJLAnimationButtonDelegate

-(void)OJLAnimationButtonDidStartAnimation:(OJLAnimationButton *)OJLAnimationButton{
    RTLog(@"start");
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.8 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [OJLAnimationButton stopAnimation];
    });
}

-(void)OJLAnimationButtonDidFinishAnimation:(OJLAnimationButton *)OJLAnimationButton{
    RTLog(@"stop");
}

-(void)OJLAnimationButtonWillFinishAnimation:(OJLAnimationButton *)OJLAnimationButton{
     [self rewarding];
}
#pragma mark - UITextFieldDelegate

- (BOOL)textFieldShouldEndEditing:(UITextField *)textField{
    self.rewardCount = [textField.text floatValue];
    return YES;
}
#pragma mark - 网络状态改变通知
- (void)networkChange
{
    if ([[SuNetworkMonitor monitor] isWiFiEnable]) {//网络切换为WiFi
//        [Explayer replaceCurrentItemWithPlayerItem:[[AVPlayerItem alloc]initWithURL:[NSURL fileURLWithPath:self.newsModel.post_mp]]];
//        [self doplay2];
    }else if([[SuNetworkMonitor monitor] isNetworkEnable]){//网络切换为手机网络
//        [Explayer replaceCurrentItemWithPlayerItem:[[AVPlayerItem alloc]initWithURL:[NSURL fileURLWithPath:self.newsModel.post_mp]]];
//        [self doplay2];
    }else{
//        [self doPlay:bofangCenterBtn];
    }
}
#pragma mark - 懒加载新闻详情控件

- (UIImageView *)zhengwenImg
{
    if (_zhengwenImg == nil) {
        _zhengwenImg = [[UIImageView alloc] init];
        [_zhengwenImg setUserInteractionEnabled:YES];
        _zhengwenImg.contentMode = UIViewContentModeScaleAspectFill;
        _zhengwenImg.clipsToBounds = YES;
    }
    return _zhengwenImg;
}
- (UIImageView *)zhuboImg
{
    if (_zhuboImg == nil) {
        _zhuboImg = [[UIImageView alloc] init];
        _zhuboImg.layer.masksToBounds = YES;
        _zhuboImg.userInteractionEnabled = YES;
        _zhuboImg.layer.cornerRadius = 27.0 / 667 * IPHONE_H / 2;
        _zhuboImg.contentMode = UIViewContentModeScaleAspectFill;
    }
    return _zhuboImg;
}
- (UILabel *)zhuboTitleLab
{
    if (_zhuboTitleLab == nil) {
        _zhuboTitleLab = [[UILabel alloc] init];
        _zhuboTitleLab.textColor = nTextColorSub;
        _zhuboTitleLab.font = gFontMain14;
        _zhuboTitleLab.textAlignment = NSTextAlignmentLeft;
    }
    return _zhuboTitleLab;
}
- (UIImageView *)mic
{
    if (_mic == nil) {
        _mic = [[UIImageView alloc] init];
        [_mic setImage:[UIImage imageNamed:@"home_news_ic_anchor"]];
    }
    return _mic;
}
- (UIView *)achorTouch
{
    if (_achorTouch == nil) {
        _achorTouch = [[UIView alloc] init];
        [_achorTouch setUserInteractionEnabled:YES];
    }
    return _achorTouch;
}
- (UIView *)seperatorLine
{
    if (_seperatorLine == nil) {
        _seperatorLine = [[UIView alloc] init];
        [_seperatorLine setBackgroundColor:gThickLineColor];
    }
    return _seperatorLine;
}
- (UILabel *)titleLab
{
    if (_titleLab == nil) {
        _titleLab = [[UILabel alloc] init];
        _titleLab.textAlignment = NSTextAlignmentCenter;
        _titleLab.textColor = nTextColorMain;
        _titleLab.lineBreakMode = NSLineBreakByWordWrapping;
        [_titleLab setNumberOfLines:0];
    }
    return _titleLab;
}
- (UILabel *)riqiLab
{
    if (_riqiLab == nil) {
        _riqiLab = [[UILabel alloc] init];
        _riqiLab.textAlignment = NSTextAlignmentCenter;
        _riqiLab.textColor = nTextColorSub;
        //TODO: 设置字体导致崩溃的bug
        _riqiLab.font = gFontMain14;/**<这一行存在bug,导致应用崩溃*/
    }
    return _riqiLab;
}
- (UITextView *)zhengwenTextView
{
    if (_zhengwenTextView == nil) {
        _zhengwenTextView = [[UITextView alloc] init];
        _zhengwenTextView.scrollEnabled = NO;
        _zhengwenTextView.editable = NO;
        _zhengwenTextView.scrollsToTop = NO;
        _zhengwenTextView.delegate = self;
    }
    return _zhengwenTextView;
}
#pragma mark --- 懒加载
- (UITableView *)tableView
{
    if (!_tableView)
    {
        _tableView = [[UITableView alloc]initWithFrame:CGRectMake(0, 0, IPHONE_W, IPHONE_H - 109.0 / 667 * IPHONE_H) style:UITableViewStylePlain];
        _tableView.delegate = self;
        _tableView.scrollsToTop = YES;
        _tableView.dataSource = self;
        _tableView.tableFooterView = [UIView new];
    }
    return _tableView;
}
- (NSMutableArray *)pinglunArr
{
    if (!_pinglunArr)
    {
        _pinglunArr = [NSMutableArray array];
    }
    return _pinglunArr;
}
- (NSDictionary *)infoDic
{
    if (!_infoDic)
    {
        _infoDic = [NSDictionary dictionary];
    }
    return _infoDic;
}
- (UIProgressView *)prgBufferProgress
{
    if (!_prgBufferProgress)
    {
        _prgBufferProgress = [[UIProgressView alloc]initWithProgressViewStyle:UIProgressViewStyleDefault];
    }
    return _prgBufferProgress;
}
- (UISlider *)sliderProgress
{
    if (!_sliderProgress)
    {
        _sliderProgress = [[UISlider alloc]initWithFrame:CGRectMake(20.0 / 375 * IPHONE_W, 22.0 / 667 * SCREEN_HEIGHT - 6, IPHONE_W - 40.0 / 375 * IPHONE_W, 14.0)];
        _sliderProgress.value = 0.0f;
    }
    return _sliderProgress;
}

//-(UIFont *)dateFont{
//    if (_dateFont == nil) {
//        _dateFont = gFontMain14;
//    }
//    return _dateFont;
//}

- (NSMutableArray *)buttons{
    if (!_buttons)
    {
        _buttons = [NSMutableArray array];
    }
    return _buttons;
}

- (UILabel *)appreciateNum{
    if (!_appreciateNum) {
        _appreciateNum = [[UILabel alloc]init];
        [_appreciateNum setTextAlignment:NSTextAlignmentLeft];
        [_appreciateNum setFont:gFontSub11];
        [_appreciateNum setTextColor:[UIColor colorWithHue:0.12 saturation:0.78 brightness:0.98 alpha:1.00]];
    }
    return _appreciateNum;
    
}
- (UILabel *)commentNum{
    if (!_commentNum) {
        _commentNum = [[UILabel alloc]init];
        [_commentNum setTextAlignment:NSTextAlignmentLeft];
        [_commentNum setFont:gFontSub11];
        [_commentNum setTextColor:[UIColor colorWithHue:0.01 saturation:0.57 brightness:0.93 alpha:1.00]];
    }
    return _commentNum;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
- (void)dealloc
{
    RTLog(@"dealloc");
    [[NSNotificationCenter defaultCenter] removeObserver:self name:AVPlayerItemDidPlayToEndTimeNotification object:Explayer.currentItem];
}

@end
