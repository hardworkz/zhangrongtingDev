//
//  NewPlayVC.m
//  kuangjiaTingWen
//
//  Created by 泡果 on 2017/7/26.
//  Copyright © 2017年 zhimi. All rights reserved.
//

#import "NewPlayVC.h"
#import "ShareView.h"
#import "UIImage+compress.h"
#include <TencentOpenAPI/QQApiInterface.h>
#import "GestureControlAlertView.h"

@interface NewPlayVC ()<UITableViewDelegate,UITableViewDataSource>
{
    //底部播放模块控件容器
    UIView *dibuView;
    //播放上一首
    UIButton *bofangLeftBtn;
    //播放开始/暂停
    UIButton *bofangCenterBtn;
    //播放下一首
    UIButton *bofangRightBtn;
    //当前播放时间label
    UILabel *dangqianTime;
    //腾讯分享对象
    TencentOAuth *tencentOAuth;
    //是否正在显示快进后退15秒按钮
    BOOL isShowfastBackView;
    //view的显示时间默认5s
    NSInteger showTime;
    //点赞数据
    NSMutableArray *jiaDianZanShuJv;
    //是否关注
    BOOL isGuanZhu;
    //新闻头部详情View
    UIView *xiangqingView;
}
/**
 主页面tableView
 */
@property(strong,nonatomic)UITableView *tableView;
/**
 新闻详情数据
 */
@property (strong, nonatomic) newsDetailModel *postDetailModel;
/**
 评论数据数组
 */
@property(strong,nonatomic)NSMutableArray *pinglunArr;
/**
 播放进度条
 */
@property(strong,nonatomic)UISlider *sliderProgress;
/**
 缓冲进度条
 */
@property(strong,nonatomic)UIProgressView *prgBufferProgress;
/**
 滚动置顶按钮
 */
@property (strong, nonatomic) UIButton *scrollTopBtn;
/**
 标题字体大小
 */
@property(assign,nonatomic)CGFloat titleFontSize;
/**
 日期字体大小
 */
@property(assign,nonatomic)CGFloat dateFont;
/**
 顶部自定义导航栏
 */
@property (strong, nonatomic) UIView *topView;
/**
 返回按钮
 */
@property (strong, nonatomic) UIButton *leftBtn;
/**
 分享按钮
 */
@property (strong, nonatomic) UIButton *rightBtn;
/**
 音频总时长label
 */
@property(strong,nonatomic)UILabel *yinpinzongTime;
/**
 快进15秒，后退15秒的View
 */
@property (strong, nonatomic) UIView *forwardBackView;
/**
 自动消失定时器
 */
@property (strong, nonatomic) NSTimer *showForwardBackViewTimer;
/**
 是否已经收藏
 */
@property (assign, nonatomic) BOOL isCollected;
/**
 投金币数
 */
@property (strong, nonatomic) UILabel *appreciateNum;
/**
 评论数
 */
@property (strong, nonatomic) UILabel *commentNum;
//新闻详情控件------------------------------------
/**
 新闻图片
 */
@property (strong, nonatomic) UIImageView *zhengwenImg;
/**
 主播头像
 */
@property (strong, nonatomic) UIImageView *zhuboImg;
/**
 主播昵称
 */
@property (strong, nonatomic) UILabel *zhuboTitleLab;
/**
 主播标识麦克风图标
 */
@property (strong, nonatomic) UIImageView *mic;
/**
 主播一行空白区域点击事件view
 */
@property (strong, nonatomic) UIView *achorTouch;
/**
 关注图标
 */
@property (strong, nonatomic) UIButton *guanzhuBtn;
/**
 分割线
 */
@property (strong, nonatomic) UIView *seperatorLine;
/**
 标题
 */
@property (strong, nonatomic) UILabel *titleLab;
@property (strong, nonatomic) UILabel *riqiLab;
//新闻详情控件------------------------------------

/**
 打赏金额
 */
@property (assign, nonatomic) float rewardCount;
@end
static NewPlayVC *_instance = nil;
@implementation NewPlayVC
//单例
+ (instancetype)shareInstance {
    static dispatch_once_t onceToken ;
    dispatch_once(&onceToken, ^{
        _instance = [[self alloc] init];
    }) ;
    return _instance ;
}
- (void)viewDidLoad {
    [super viewDidLoad];
    
    //添加tableView控件
    [self.view addSubview:self.tableView];
    //置顶按钮
    [self.view insertSubview:self.scrollTopBtn aboveSubview:self.tableView];
    
    //设置正文和日期字体
    self.titleFontSize = [[CommonCode readFromUserD:TitleFontSize] floatValue]?[[CommonCode readFromUserD:TitleFontSize] floatValue]:19.0;
    [CommonCode writeToUserD:@(self.titleFontSize) andKey:TitleFontSize];
    self.dateFont = [[CommonCode readFromUserD:DateFont] floatValue]?[[CommonCode readFromUserD:DateFont] floatValue]:14.0;
    
    //设置自定义导航栏
    [self setupNavigation];
    
    //设置新闻头部详情控件
    self.tableView.tableHeaderView = [self setupTableViewHeader];
    
    //添加手势返回
    UISwipeGestureRecognizer *rightSwipe = [[UISwipeGestureRecognizer alloc]initWithTarget:self action:@selector(rightSwipeAction:)];
    [rightSwipe setDirection:UISwipeGestureRecognizerDirectionRight];
    [self.view addGestureRecognizer:rightSwipe];

    
    //通知
    //监听外面列表加载成功通知
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(jiazaichenggong:) name:@"jiazaichenggong" object:nil];
    //后台系统中断音频控制通知
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleInterruption:) name:AVAudioSessionInterruptionNotification object:[AVAudioSession sharedInstance]];
    //添加通知，拔出耳机后暂停播放
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(routeChange:) name:AVAudioSessionRouteChangeNotification object:nil];
    //支付宝支付回调
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(aliPayResultsBack:) name:@"PayResultsBack" object:nil];
    //微信支付回调
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(WechatPayResultsBack:) name:@"WechatPayResultsBack" object:nil];
    //听币支付回调
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(TcoinPayResultsBack:) name:@"TcoinPayResultsBack" object:nil];
    //网络连接状态改变通知
    RegisterNotify(NETWORKSTATUSCHANGE, @selector(networkChange))
    //跳转打赏支付页面后返回的通知
//    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(RewardBack:) name:@"RewardBack" object:nil];
}
#pragma mark - 加载新闻详情数据
- (void)loadData{
    //postDetail
    [NetWorkTool getPostDetailWithaccessToken:AvatarAccessToken post_id:self.post_id sccess:^(NSDictionary *responseObject) {
        if ([responseObject[@"status"] intValue] == 1){
            _postDetailModel = [newsDetailModel mj_objectWithKeyValues:responseObject[@"results"]];
            if (_postDetailModel.reward.count != 0) {
//                self.isPay = YES;
//                self.rewardArray = detailModel.reward;
                //修复广告点击进入的主播详情粉丝数错误
//                self.newsModel.act_id = detailModel.act.act_id;
//                self.newsModel.jiemuFan_num = detailModel.act.fan_num;
//                self.newsModel.jiemuMessage_num = detailModel.act.message_num;
            }
            else{
//                self.isPay = NO;
//                self.rewardArray = nil;
            }
            [self.appreciateNum setText:_postDetailModel.gold];
            if ([_postDetailModel.is_collection integerValue] == 1) {
                _isCollected = YES;
                UIButton *collectBtn = (UIButton *)[dibuView viewWithTag:99];
                [collectBtn setImage:[UIImage imageNamed:@"home_news_collectioned"] forState:UIControlStateNormal];
            }
            else{
                _isCollected = NO;
                UIButton *collectBtn = (UIButton *)[dibuView viewWithTag:99];
                [collectBtn setImage:[UIImage imageNamed:@"home_news_collection"] forState:UIControlStateNormal];
            }
        }
        else{
//            self.isPay = NO;
//            self.rewardArray = nil;
            [self.appreciateNum setText:@"0"];
            [SVProgressHUD showErrorWithStatus:responseObject[@"msg"]];
        }
        
//        if (self.isRewardBack) {
//            self.isReward = YES;
//            self.isRewardBack = NO;
//        }
//        else{
//            self.isReward = NO;
//            self.isCustomRewardCount = NO;
//        }
        
        [self.tableView reloadData];
    } failure:^(NSError *error) {
        RTLog(@"%@",error);
    }];
    
}
#pragma mark - 获取评论列表
- (void)getCommentList{
    //获取评论列表
    [NetWorkTool getPaoGuoJieMuPingLunLieBiaoWithJieMuID:self.post_id anduid:ExdangqianUserUid andPage:@"1" andLimit:@"10" sccess:^(NSDictionary *responseObject) {
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
#pragma mark - 设置导航栏控件
- (void)setupNavigation
{
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
    
    _rightBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    _rightBtn.frame = CGRectMake(SCREEN_WIDTH - 55, 25, 35, 35);
    [_rightBtn setImageEdgeInsets:UIEdgeInsetsMake(5, 10, 5, 0)];
    [_rightBtn setImage:[UIImage imageNamed:@"title_ic_share_white"] forState:UIControlStateNormal];
    _rightBtn.accessibilityLabel = @"分享";
    [_rightBtn addTarget:self action:@selector(shareNewsBtnAction) forControlEvents:UIControlEventTouchUpInside];
    [_topView addSubview:_rightBtn];
}
#pragma mark - 设置新闻头部控件
- (void)setupTableViewHeaderData
{
    //设置新闻图片
//    NSString *imgUrl4 = self.newsModel.ImgStrjiemu;
//    if ([imgUrl4 rangeOfString:@"userDownLoadPathImage"].location != NSNotFound) {
//        [_zhengwenImg sd_setImageWithURL:[NSURL fileURLWithPath:imgUrl4] placeholderImage:[UIImage imageNamed:@"thumbnailsdefault"]];
//    }
//    else if ([imgUrl4  rangeOfString:@"http"].location != NSNotFound)
//    {
//        [_zhengwenImg sd_setImageWithURL:[NSURL URLWithString:imgUrl4] placeholderImage:[UIImage imageNamed:@"thumbnailsdefault"]];
//    }else
//    {
//        NSString *str = USERPHOTOHTTPSTRINGZhuBo(imgUrl4);
//        [_zhengwenImg sd_setImageWithURL:[NSURL URLWithString:str] placeholderImage:[UIImage imageNamed:@"thumbnailsdefault"]];
//    }
    //设置主播头像
//    if([self.newsModel.jiemuImages rangeOfString:@"/data/upload/"].location !=NSNotFound)//_roaldSearchText
//    {
//        IMAGEVIEWHTTP(_zhuboImg, self.newsModel.jiemuImages);
//    }
//    else
//    {
//        IMAGEVIEWHTTP2(_zhuboImg, self.newsModel.jiemuImages);
//    }
    //设置主播昵称
//    _zhuboTitleLab.text = self.newsModel.jiemuName;
    //设置标题名称
//    _titleLab.text = self.newsModel.Titlejiemu;
}
- (UIView *)setupTableViewHeader
{
    xiangqingView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, IPHONE_W, IPHONE_H)];
    xiangqingView.backgroundColor = [UIColor whiteColor];
    
    //新闻图片
    self.zhengwenImg.frame = CGRectMake(0, -20, IPHONE_W, 209.0 / 667 * SCREEN_HEIGHT);
    
    UIBezierPath *maskPath = [UIBezierPath bezierPathWithRoundedRect:_zhengwenImg.bounds byRoundingCorners:UIRectCornerBottomRight cornerRadii:CGSizeMake(160.0 / 667 * SCREEN_HEIGHT, 160.0 / 667 * SCREEN_HEIGHT)];
    CAShapeLayer *maskLayer = [[CAShapeLayer alloc] init];
    maskLayer.frame = _zhengwenImg.bounds;
    maskLayer.path = maskPath.CGPath;
    _zhengwenImg.layer.mask = maskLayer;
    
    //添加单击手势
    UITapGestureRecognizer *tapZhengwenImg = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(showZoomImageView:)];
    [_zhengwenImg addGestureRecognizer:tapZhengwenImg];
    [xiangqingView addSubview:_zhengwenImg];
    //主播头像
    self.zhuboImg.frame = CGRectMake(20.0 / 375 * IPHONE_W, CGRectGetMaxY(_zhengwenImg.frame) + 10.0 / 667 * IPHONE_H,  27.0 / 667 * IPHONE_H, 27.0 / 667 * IPHONE_H);
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(zhuboBtnVAction:)];
    [_zhuboImg addGestureRecognizer:tap];
    
    [xiangqingView addSubview:_zhuboImg];
    //主播名字
    self.zhuboTitleLab.frame = CGRectMake(CGRectGetMaxX(_zhuboImg.frame) + 4.0 / 375 * IPHONE_W, _zhuboImg.frame.origin.y +  5.0 / 667 * IPHONE_H, 88.0 / 375 * IPHONE_W, 15.0 / 667 * IPHONE_H);
    [_zhuboTitleLab addTapGesWithTarget:self action:@selector(zhuboBtnVAction:)];
    CGSize contentSize = [_zhuboTitleLab sizeThatFits:CGSizeMake(_zhuboTitleLab.frame.size.width, MAXFLOAT)];
    _zhuboTitleLab.frame = CGRectMake(_zhuboTitleLab.frame.origin.x, _zhuboTitleLab.frame.origin.y,contentSize.width, _zhuboTitleLab.frame.size.height);
    [xiangqingView addSubview:_zhuboTitleLab];
    //主播麦克风图标
    self.mic.frame = CGRectMake(CGRectGetMaxX(_zhuboTitleLab.frame) + 6.0 / 375 * SCREEN_WIDTH, _zhuboTitleLab.frame.origin.y + 1.0 / 667 * SCREEN_HEIGHT, 8.0 /375 * SCREEN_WIDTH, 14.0 / 667 * SCREEN_HEIGHT);
    [_mic addTapGesWithTarget:self action:@selector(zhuboBtnVAction:)];
    [xiangqingView addSubview:_mic];
    //空白区域view
    self.achorTouch.frame = CGRectMake(CGRectGetMaxX(_mic.frame), CGRectGetMaxY(_zhengwenImg.frame), SCREEN_WIDTH - CGRectGetMaxX(_mic.frame) - 80.0 / 375 * IPHONE_W , 47.0 / 667 * SCREEN_HEIGHT);
    [_achorTouch  addTapGesWithTarget:self action:@selector(zhuboBtnVAction:)];
    [xiangqingView addSubview:_achorTouch];
    
    //关注、取消
    _guanzhuBtn.frame = CGRectMake(SCREEN_WIDTH - 80.0 / 375 * IPHONE_W, CGRectGetMaxY(_zhengwenImg.frame) + 9.0 / 375 * IPHONE_W, 60.0 / 375 * IPHONE_W, 30.0 / 667 * IPHONE_H);
    [xiangqingView addSubview:_guanzhuBtn];
    
    
    self.seperatorLine.frame = CGRectMake(20.0 / 375 * SCREEN_WIDTH, CGRectGetMaxY(_zhuboImg.frame) +  12.0 / 667 * SCREEN_HEIGHT, SCREEN_WIDTH - 40.0 / 375 * SCREEN_WIDTH, 1.0);
    [xiangqingView addSubview:_seperatorLine];

    return xiangqingView;
}
#pragma mark - 设置底部播放控件
- (void)xinwenxiangqingbujv{
    
    //底部view主容器控件
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
    
    //底部定时按钮
    UIButton *bofangdingshiBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    bofangdingshiBtn.frame = CGRectMake(20.0 / 375 * IPHONE_W, 54.0 / 667 * IPHONE_H, 32.0 / 667 * IPHONE_H, 32.0 / 667 * IPHONE_H);
    [bofangdingshiBtn setImage:[UIImage imageNamed:@"home_news_ic_time"] forState:UIControlStateNormal];
    [bofangdingshiBtn setImageEdgeInsets:UIEdgeInsetsMake(5, 5, 5, 5)];
    bofangdingshiBtn.accessibilityLabel = @"定时";
    [bofangdingshiBtn addTarget:self action:@selector(bofangdingshiBtnAction:) forControlEvents:UIControlEventTouchUpInside];
    bofangdingshiBtn.contentMode = UIViewContentModeScaleToFill;
    [dibuView addSubview:bofangdingshiBtn];
    
    UIView *dibuTopLine = [[UIView alloc]initWithFrame:CGRectMake(0, 0, IPHONE_W, 0.5)];
    dibuTopLine.backgroundColor = [UIColor grayColor];
    dibuTopLine.alpha = 0.5f;
    [dibuView addSubview:dibuTopLine];
    
    [self bofangqiSet];
}
#pragma mark - 播放器设置
- (void)bofangqiSet
{
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
    [bofangCenterBtn addTarget:self action:@selector(playPauseClicked:) forControlEvents:UIControlEventTouchUpInside];
    bofangCenterBtn.contentMode = UIViewContentModeScaleToFill;
    
    //初始时，禁用播放按钮
    [bofangCenterBtn setEnabled:NO];
    
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
- (UIButton *)guanzhuBtn
{
    if (_guanzhuBtn == nil) {
        _guanzhuBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        [_guanzhuBtn setTitle:@"取消" forState:UIControlStateNormal];
        [_guanzhuBtn setTitle:@"+ 关注" forState:UIControlStateSelected];
        _guanzhuBtn.selected = NO;
        [_guanzhuBtn setTitleColor:gMainColor forState:UIControlStateNormal];
        _guanzhuBtn.titleLabel.font  = [UIFont systemFontOfSize:13.0];
        _guanzhuBtn.layer.cornerRadius = 4;
        _guanzhuBtn.layer.masksToBounds = YES;
        _guanzhuBtn.layer.borderColor = gMainColor.CGColor;
        _guanzhuBtn.layer.borderWidth = 0.5f;
        _guanzhuBtn.bounds = CGRectMake(0, 0, 50, 30);
        [_guanzhuBtn addTarget:self action:@selector(guanzhuBtnAction:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _guanzhuBtn;
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
        _titleLab.textAlignment = NSTextAlignmentLeft;
        _titleLab.textColor = nTextColorMain;
        _titleLab.lineBreakMode = NSLineBreakByWordWrapping;
        _titleLab.numberOfLines = 0;
    }
    return _titleLab;
}
- (UILabel *)riqiLab
{
    if (_riqiLab == nil) {
        _riqiLab = [[UILabel alloc] init];
        _riqiLab.textAlignment = NSTextAlignmentCenter;
        _riqiLab.textColor = nTextColorSub;
        _riqiLab.font = [UIFont systemFontOfSize:self.dateFont];
    }
    return _riqiLab;
}

#pragma mark --- 懒加载控件
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
- (UIButton *)scrollTopBtn
{
    if (_scrollTopBtn == nil) {
        CGFloat W = 40.0f;
        _scrollTopBtn = [[UIButton alloc] initWithFrame:CGRectMake(SCREEN_WIDTH - W, SCREEN_HEIGHT - W - 10 - 109.0/667*IPHONE_H, W, W)];
        _scrollTopBtn.layer.cornerRadius = 25;
        [_scrollTopBtn setImage:@"置顶"];
        [_scrollTopBtn addTarget:self action:@selector(scrollToTop)];
        _scrollTopBtn.alpha = 0.0;
    }
    return _scrollTopBtn;
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
- (UILabel *)commentNum{
    if (!_commentNum) {
        _commentNum = [[UILabel alloc]init];
        [_commentNum setTextAlignment:NSTextAlignmentLeft];
        [_commentNum setFont:gFontSub11];
        [_commentNum setTextColor:[UIColor colorWithHue:0.01 saturation:0.57 brightness:0.93 alpha:1.00]];
    }
    return _commentNum;
}
#pragma mark --- 懒加载数组容器
- (NSMutableArray *)pinglunArr
{
    if (!_pinglunArr)
    {
        _pinglunArr = [NSMutableArray array];
    }
    return _pinglunArr;
}
#pragma mark - table datasource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 0;
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return nil;
}
#pragma mark - table delegate
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    
}
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 0;
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


/**
 打赏操作，跳转支付界面
 */
- (void)rewarding{
    if (!self.postDetailModel.act.act_id) {
        XWAlerLoginView *alert = [[XWAlerLoginView alloc] initWithTitle:@"数据获取失败，请重新进入该新闻刷新数据"];
        [alert show];
        return;
    }
    //TODO:打赏跳转支付界面
    PayOnlineViewController *vc = [PayOnlineViewController new];
    NSString *accesstoken = nil;
    if ([[CommonCode readFromUserD:@"isLogin"]boolValue] == YES){
        accesstoken = AvatarAccessToken;
        [NetWorkTool getListenMoneyWithaccessToken:accesstoken sccess:^(NSDictionary *responseObject) {
            RTLog(@"%@",responseObject);
            if ([responseObject[@"status"] integerValue] == 1) {
                vc.balanceCount = [responseObject[@"results"][@"listen_money"] doubleValue];
//                vc.rewardCount = self.rewardCount;
//                vc.uid = (self.newsModel.post_news != nil) ? self.newsModel.post_news : self.newsModel.jiemuID;
//                vc.post_id = self.newsModel.jiemuID;
//                vc.act_id = self.newsModel.act_id;
//                vc.isPayClass = NO;
//                [self.navigationController pushViewController:vc animated:YES];
            }
            
        } failure:^(NSError *error) {
            
        }];
    }
    else{
        accesstoken = nil;
        vc.balanceCount = 0.00;
//        vc.rewardCount = self.rewardCount;
//        vc.uid = (self.newsModel.post_news != nil) ? self.newsModel.post_news : self.newsModel.jiemuID;
//        vc.post_id = self.newsModel.jiemuID;
//        vc.isPayClass = NO;
//        [self.navigationController pushViewController:vc animated:YES];
    }
    
}

#pragma mark - UITextFieldDelegate
- (BOOL)textFieldShouldEndEditing:(UITextField *)textField{
    self.rewardCount = [textField.text floatValue];
    return YES;
}
#pragma mark - 打赏调用action
- (void)selecteRewardCountAction:(UIButton *)sender {
    
    //TODO:打赏按钮数据
//    for ( int i = 0 ; i < self.buttons.count; i ++ ) {
//        if (i == sender.tag - 100 ) {
//            UIButton *allDoneButton = self.buttons[i];
//            [allDoneButton setBackgroundColor:gButtonRewardColor];
//            [allDoneButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
//            continue;
//        }
//        else{
//            UIButton *anotherButton = self.buttons[i];
//            [anotherButton setBackgroundColor:[UIColor whiteColor]];
//            [anotherButton setTitleColor:gTextRewardColor forState:UIControlStateNormal];
//            continue;
//        }
//    }
//    DefineWeakSelf;
//    switch (sender.tag - 100) {
//        case 0:self.rewardCount = 1;break;
//        case 1:self.rewardCount = 5;break;
//        case 2:self.rewardCount = 10;break;
//        case 3:self.rewardCount = 50;break;
//        case 4:self.rewardCount = 100;break;
//        case 5:[weakSelf customRewardCount];break;
//        default:break;
//    }
}

- (void)backButtonAction:(UIButton *)sender {
    self.rewardType = RewardViewTypeNone;
    [self.tableView reloadData];
}

- (void)customRewardCount {
    self.rewardType = RewardViewTypeCustomReward;
    [self.tableView reloadData];
}
#pragma mark - 快进 后退 15秒控件
- (UIView *)forwardBackView
{
    if (_forwardBackView == nil) {
        CGFloat height = 70;
        _forwardBackView = [[UIView alloc] init];
        _forwardBackView.frame = CGRectMake(0, IPHONE_H - 109.0 / 667 * IPHONE_H - height, SCREEN_WIDTH, height);
        _forwardBackView.backgroundColor = ColorWithRGBA(0, 0, 0, 0.5);
        
        UIButton *back = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH * 0.5, height)];
        [back setImage:[UIImage imageNamed:@"fast_back"] forState:UIControlStateNormal];
        [back setImage:[UIImage imageNamed:@"fast_back_blue"] forState:UIControlStateHighlighted];
        [back addTarget:self action:@selector(back15)];
        [_forwardBackView addSubview:back];
        
        UIButton *go = [[UIButton alloc] initWithFrame:CGRectMake(SCREEN_WIDTH * 0.5, 0, SCREEN_WIDTH * 0.5, height)];
        [go setImage:[UIImage imageNamed:@"fast_go"] forState:UIControlStateNormal];
        [go setImage:[UIImage imageNamed:@"fast_go_blue"] forState:UIControlStateHighlighted];
        [go addTarget:self action:@selector(go15)];
        [_forwardBackView addSubview:go];
    }
    return _forwardBackView;
}

/**
 后退15s
 */
- (void)back15
{
    [self attAction];
    [Explayer pause];
    //调到指定时间去播放
    [Explayer seekToTime:CMTimeMake(self.sliderProgress.value > 15?self.sliderProgress.value - 15:0, 1) completionHandler:^(BOOL finished) {
        RTLog(@"拖拽结果：%d",finished);
        if (finished == YES){
            //TODO:设置数据
//            if (_isClass) {//限制播放新闻
//                [Explayer play];
//            }else{
//                if (!isLimitPlaying) {
//                    [Explayer play];
//                }
//            }
        }
    }];
    [[UIDevice currentDevice] setProximityMonitoringEnabled:[[NSUserDefaults standardUserDefaults] boolForKey:@"shoushi"]];
}
/**
 快进15s
 */
- (void)go15
{
    [self attAction];
    [Explayer pause];
    //调到指定时间去播放
    [Explayer seekToTime:CMTimeMake(self.sliderProgress.value + 15, 1) completionHandler:^(BOOL finished) {
        RTLog(@"拖拽结果：%d",finished);
        if (finished == YES){
            //TODO:设置数据
//            if (_isClass) {//限制播放新闻
//                [Explayer play];
//            }else{
//                if (!isLimitPlaying) {
//                    [Explayer play];
//                }
//            }
        }
    }];
    [[UIDevice currentDevice] setProximityMonitoringEnabled:[[NSUserDefaults standardUserDefaults] boolForKey:@"shoushi"]];
}

/**
 显示快进/后退控件
 */
- (void)showForwardBackView
{
    self.forwardBackView.alpha = 0.;
    [self.view addSubview:self.forwardBackView];
    [UIView animateWithDuration:1.0 animations:^{
        _forwardBackView.alpha = 1.;
    }];
}
/**
 隐藏快进/后退控件
 */
- (void)hideForwardBackView
{
    [UIView animateWithDuration:1.0 animations:^{
        _forwardBackView.alpha = 0.;
    } completion:^(BOOL finished) {
        [_forwardBackView removeFromSuperview];
        isShowfastBackView = NO;
    }];
}
#pragma mark - 手势控制
/**
 播放器手势控制弹窗提示
 */
- (void)setGestureControl
{
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

}
#pragma mark - 后台系统中断音频控制
- (void)handleInterruption:(NSNotification *)notification{
    NSDictionary *info = notification.userInfo;
    AVAudioSessionInterruptionType type = [info[AVAudioSessionInterruptionTypeKey] unsignedIntegerValue];
    if (type == AVAudioSessionInterruptionTypeBegan) {//进入别的应用
        //Handle InterruptionBegan
        //系统暂停音频，则设置暂停播放器
//        [self doPlay:bofangCenterBtn];
        RTLog(@"interruptionTypeBegan");
    }else{
        RTLog(@"interruptionTypeEnd");
        AVAudioSessionInterruptionOptions options = [info[AVAudioSessionInterruptionOptionKey] unsignedIntegerValue];
        if (options == AVAudioSessionInterruptionOptionShouldResume) {
            //Handle Resume 重新开始播放
            //            [self doPlay:bofangCenterBtn];
        }
    }
}
#pragma mark - 线控方法
- (void)remoteControlReceivedWithEvent:(UIEvent *)event {
    //判断是否是后台音频
    if (event.type == UIEventTypeRemoteControl) {
        switch (event.subtype) {
            case UIEventSubtypeRemoteControlTogglePlayPause:
                //暂停或播放
//                [self doPlay:bofangCenterBtn];
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
//                [self doPlay:bofangCenterBtn];
                break;
        }
    }
}
#pragma mark - 拔插耳机线方法
/**
 *  一旦输出改变则执行此方法
 *
 *  @param notification 输出改变通知对象
 */
-(void)routeChange:(NSNotification *)notification{
    NSDictionary *dic=notification.userInfo;
    int changeReason= [dic[AVAudioSessionRouteChangeReasonKey] intValue];
    //等于AVAudioSessionRouteChangeReasonOldDeviceUnavailable表示旧输出不可用
    if (changeReason==AVAudioSessionRouteChangeReasonOldDeviceUnavailable) {
        AVAudioSessionRouteDescription *routeDescription=dic[AVAudioSessionRouteChangePreviousRouteKey];
        AVAudioSessionPortDescription *portDescription= [routeDescription.outputs firstObject];
        //原设备为耳机则暂停
        RTLog(@"%@",portDescription.portType);
        if ([portDescription.portType isEqualToString:@"Headphones"]) {
//            [self doPlay:bofangCenterBtn];
        }
    }
}
#pragma mark - 控件事件action
/**
 上一首
 */
- (void)bofangLeftAction:(UIButton *)sender
{
    
}
/**
 播放/暂停
 */
- (void)playPauseClicked:(UIButton *)sender
{
    //添加手势控制
    [self setGestureControl];
}
/**
 下一首
 */
- (void)bofangRightAction:(UIButton *)sender
{
    
}
/**
 点击定时跳转定时设置控制器
 */
- (void)bofangdingshiBtnAction:(UIButton *)sender
{
    [self.navigationController.navigationBar setHidden:YES];
    [self.navigationController pushViewController:[TimerViewController defaultTimerViewController] animated:YES];
}
/**
 计算音频总时长
 */
- (void)reloadPlayAllTime
{
    //TODO:设置数据
//    self.yinpinzongTime.text = [self convertStringWithTime:[self.newsModel.post_time intValue] / 1000];
}
- (void)back{
    [self.navigationController popViewControllerAnimated:YES];
}
- (void)rightSwipeAction:(UIGestureRecognizer *)gesture {
    
    [self.navigationController popViewControllerAnimated:YES];
}
- (void)SVPDismiss {
    [SVProgressHUD dismiss];
}

/**
 图片放大
 */
- (void)showZoomImageView:(UITapGestureRecognizer *)tap{
    if (![(UIImageView *)tap.view image]) {
        return;
    }
    [YJImageBrowserView showWithImageView:(UIImageView *)tap.view];
}
/**
 拖拽播放进度
 */
- (void)doChangeProgress:(UISlider *)sender{
    
    if (!isShowfastBackView) {
        [self showForwardBackView];
        
        isShowfastBackView = YES;
        [self attAction];
    }
    
    [Explayer pause];
    //调到指定时间去播放
    [Explayer seekToTime:CMTimeMake(self.sliderProgress.value, 1) completionHandler:^(BOOL finished) {
        RTLog(@"拖拽结果：%d",finished);
        if (finished == YES){
            //TODO:设置数据
//            if (_isClass) {//限制播放新闻
//                [Explayer play];
//            }else{
//                if (!isLimitPlaying) {
//                    [Explayer play];
//                }
//            }
        }
    }];
    [[UIDevice currentDevice] setProximityMonitoringEnabled:[[NSUserDefaults standardUserDefaults] boolForKey:@"shoushi"]];
}

/**
 快进，后退15sView隐藏定时器
 */
- (void)attAction
{
    showTime = 5;
    [_showForwardBackViewTimer invalidate];
    _showForwardBackViewTimer = nil;
    //启动定时器
    _showForwardBackViewTimer = [NSTimer scheduledTimerWithTimeInterval:1.0
                                                                 target:self
                                                               selector:@selector(timeAction)
                                                               userInfo:nil
                                                                repeats:YES];
    [_showForwardBackViewTimer fire];//
    [[NSRunLoop currentRunLoop] addTimer:_showForwardBackViewTimer forMode:NSDefaultRunLoopMode];
    
}

/**
 定时器调用方法
 */
- (void)timeAction
{
    showTime --;
    if (showTime == 0) {
        //隐藏快进，后退view
        [self hideForwardBackView];
    }
}

/**
 收藏按钮点击
 */
- (void)collect{
    
    if ([[CommonCode readFromUserD:@"isLogin"]boolValue] == YES){
        if (_isCollected) {
            [NetWorkTool del_collectionWithaccessToken:AvatarAccessToken post_id:self.post_id sccess:^(NSDictionary *responseObject) {
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
            [NetWorkTool collectionPostNewsWithaccessToken:AvatarAccessToken post_id:self.post_id sccess:^(NSDictionary *responseObject) {
                
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

/**
 点击跳转主播详情页面按钮
 */
- (void)zhuboBtnVAction:(UITapGestureRecognizer *)tap {
    zhuboXiangQingVCNewController *zhubo = [zhuboXiangQingVCNewController new];
    //TODO:设置数据
//    zhubo.jiemuDescription = self.newsModel.jiemuDescription;
//    zhubo.jiemuFan_num = self.newsModel.jiemuFan_num;
//    zhubo.jiemuID = (self.newsModel.post_news != nil) ? self.newsModel.post_news : self.newsModel.jiemuID;
//    zhubo.jiemuImages = self.newsModel.jiemuImages;
//    zhubo.jiemuIs_fan = self.newsModel.jiemuIs_fan;
//    zhubo.jiemuMessage_num = self.newsModel.jiemuMessage_num;
//    zhubo.jiemuName = self.newsModel.jiemuName;
    zhubo.isbofangye = YES;
    [self.navigationController pushViewController:zhubo animated:YES];
}
/**
 关注主播按钮点击
 */
- (void)guanzhuBtnAction:(UIButton *)sender{
    if ([[CommonCode readFromUserD:@"isLogin"]boolValue] == YES){
        if (sender.selected == NO){
            [NetWorkTool postPaoGuoGuanZhuWithaccessToken:[DSE encryptUseDES:ExdangqianUser] andact_id:self.postDetailModel.act.act_id sccess:^(NSDictionary *responseObject) {
                [sender setTitle:@"取消" forState:UIControlStateNormal];
                sender.selected = YES;
                //TODO:设置数据
//                self.newsModel.jiemuIs_fan = @"1";
                [self.tableView reloadData];
            } failure:^(NSError *error) {
                RTLog(@"error = %@",error);
            }];
        }
        else{
            [NetWorkTool postPaoGuoQuXiaoGuanZhuWithaccessToken:[DSE encryptUseDES:ExdangqianUser] andact_id:self.postDetailModel.act.act_id sccess:^(NSDictionary *responseObject) {
                [sender setTitle:@"+ 关注" forState:UIControlStateNormal];
                sender.selected = NO;
                //TODO:设置数据
//                self.newsModel.jiemuIs_fan = @"0";
                [self.tableView reloadData];
            } failure:^(NSError *error) {
                RTLog(@"error = %@",error);
            }];
        }
        
    }
    else{
        if ([[CommonCode readFromUserD:@"isIAP"] boolValue] == YES) {
            [sender setTitle:@"取消" forState:UIControlStateNormal];
        }else{
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
    }
}

/**
 点击跳转评论页面
 */
- (void)pinglunAction
{
    
    if ([[CommonCode readFromUserD:@"isLogin"] boolValue] == YES){
        pinglunyeVC *pinglunye = [pinglunyeVC new];
        pinglunye.isNewsCommentPage = YES;
        pinglunye.post_id = self.post_id;
        
        pinglunye.to_uid = @"0";
        self.hidesBottomBarWhenPushed = YES;
        [self.navigationController pushViewController:pinglunye animated:YES];
        self.hidesBottomBarWhenPushed = YES;
    }
    else{
        if ([[CommonCode readFromUserD:@"isIAP"] boolValue] == YES) {
            XWAlerLoginView *xw = [[XWAlerLoginView alloc]initWithTitle:@"登录后才可以评论哦~"];
            [xw show];
        }else{
            UIAlertController *qingshuruyonghuming = [UIAlertController alertControllerWithTitle:@"请先登录" message:nil preferredStyle:UIAlertControllerStyleAlert];
            [qingshuruyonghuming addAction:[UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            }]];
            [qingshuruyonghuming addAction:[UIAlertAction actionWithTitle:@"去登录" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
                LoginVC *loginFriVC = [LoginVC new];
                LoginNavC *loginNavC = [[LoginNavC alloc]initWithRootViewController:loginFriVC];
                [loginNavC.navigationBar setBackgroundColor:[UIColor whiteColor]];
                loginNavC.navigationBar.tintColor = [UIColor blackColor];
                [self presentViewController:loginNavC animated:YES completion:nil];
            }]];
            
            [self presentViewController:qingshuruyonghuming animated:YES completion:nil];
        }
    }
}
//TODO:分享内容设置
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
                NSURL *url = [NSURL URLWithString:@""];
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
                NSString *contentURLStr = [NSString stringWithFormat:@"http://tingwen.me/index.php/article/yulan/id/%@.html",@""];
                strCount = [CommonCode countWord:contentURLStr];
                
                strCount += [CommonCode countWord:@""];
                
                strCount += [CommonCode countWord:@"【】详情内容：..... 收听地址："];
                
                NSInteger RemainingCount = 137 - strCount;
                if (RemainingCount < 0) {
                    RemainingCount = 0;
                }
                NSInteger contentCount = [CommonCode countWord:@""];
                NSString *contentStr = [@"" substringWithRange:NSMakeRange(0, contentCount > RemainingCount ? RemainingCount : contentCount)];
                
                //创建消息的文本内容
                NSString *shareContent = [NSString stringWithFormat:@"【%@】详情内容：%@..... 收听地址：%@", @"", contentStr, contentURLStr];
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
                gr.string                                    = [NSString stringWithFormat:@"http://tingwen.me/index.php/article/yulan/id/%@.html",@""];
                XWAlerLoginView *xw = [[XWAlerLoginView alloc]initWithTitle:@"分享链接已复制到您的剪切板~~"];
                [xw show];
            }
                break;
        }
    };
}

/**
 分享到QQ
 */
- (void)shareToQQWithscene:(int)scene{
    if (![TencentOAuth iphoneQQInstalled]){
        UIAlertView *al = [[UIAlertView alloc]initWithTitle:@"提示" message:@"请安装QQ" delegate:nil cancelButtonTitle:@"知道了" otherButtonTitles: nil];
        [al show];
        return;
    }
    tencentOAuth = [[TencentOAuth alloc]initWithAppId:kAppId_QQ andDelegate:self];
    
    [self getImageWithURLStr:@"" OnSucceed:^(UIImage *image) {
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
            NSString *url = [NSString stringWithFormat:@"http://tingwen.me/index.php/article/yulan/id/%@.html",@""];
            
            //音乐播放的网络流媒体地址
            NSString *flashURL = @"";
            QQApiAudioObject *audioObj =[QQApiAudioObject
                                         objectWithURL :[NSURL URLWithString:url]
                                         title:@""
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
            
            [self getImageWithURLStr:@"" OnSucceed:^(UIImage *image) {
                
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
                NSString *url = [NSString stringWithFormat:@"http://tingwen.me/index.php/article/yulan/id/%@.html",@""];
                //音乐播放的网络流媒体地址
                NSString *flashURL = @"";
                QQApiAudioObject *audioObj =[QQApiAudioObject
                                             objectWithURL :[NSURL URLWithString:url]
                                             title:@""
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

/**
 分享到微信
 */
- (void)shareToWechatWithscene:(int)scene{
    //注册微信
    [WXApi registerApp:KweChatappID];
    
    if (![WXApi isWXAppInstalled]){
        UIAlertView *al = [[UIAlertView alloc]initWithTitle:@"提示" message:@"请先安装微信" delegate:nil cancelButtonTitle:@"知道了" otherButtonTitles: nil];
        [al show];
        return;
    }
    WXMediaMessage *message = [WXMediaMessage message];
    message.title = @"";
    message.description = @"";
    NSString *musicUrl = [NSString stringWithFormat:@"http://admin.tingwen.me/index.php/article/yulan/id/%@.html",@""];
    //    NSString *musicUrl = @"https://zhidao.baidu.com/question/2143697514695119428.html";
    
    [self getImageWithURLStr:@"" OnSucceed:^(UIImage *image) {
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
            ext.musicLowBandUrl = ext.musicUrl;
            ext.musicDataUrl = @"";
            ext.musicLowBandDataUrl = ext.musicDataUrl;
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
            
            [self getImageWithURLStr:@"" OnSucceed:^(UIImage *image) {
                
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
                ext.musicDataUrl = @"";
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

/**
 获取分享图片
 */
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
#pragma mark - 支付成功回调
- (void)aliPayResultsBack:(NSNotification *)notification {
    
    NSString* title=@"PaySuccess1",*msg=@"您已赞赏成功",*sureTitle=@"确定" , *cancelTitle=@"取消吧";
    AKAlertView* av;
    
    NSDictionary *resultDic = notification.object;
    if ([resultDic[@"resultStatus"]integerValue] == 9000) {
        //支付成功
//        NSMutableDictionary *dic = [CommonCode readFromUserD:REWARDINFODICTKEY];
//        if ([[CommonCode readFromUserD:@"isLogin"]boolValue] == YES){
//            [NetWorkTool listenMoneyRechargeWithaccessToken:AvatarAccessToken listen_money:dic[@"listen_money"] act_id:dic[@"act_id"] post_id:dic[@"post_id"]  type:dic[@"type"] sccess:^(NSDictionary *responseObject) {
//                //
//            } failure:^(NSError *error) {
//                //
//            }];
//        }
//        else{
//            
//        }
        
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
//        NSMutableDictionary *dic = [CommonCode readFromUserD:REWARDINFODICTKEY];
//        if ([[CommonCode readFromUserD:@"isLogin"]boolValue] == YES){
//            [NetWorkTool listenMoneyRechargeWithaccessToken:AvatarAccessToken listen_money:dic[@"listen_money"] act_id:dic[@"act_id"] post_id:dic[@"post_id"] type:dic[@"type"] sccess:^(NSDictionary *responseObject) {
//                //
//            } failure:^(NSError *error) {
//                //
//            }];
//        }
//        else{
//            
//        }
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

/**
 赞赏成功回复

 @param message 回复消息内容
 @param isToShare 是否分享
 */
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
#pragma mark - 工具方法
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
    
    CGRect rect  = [string boundingRectWithSize:CGSizeMake(width, MAXFLOAT)
                                        options: NSStringDrawingUsesFontLeading |NSStringDrawingUsesLineFragmentOrigin
                                     attributes:@{NSFontAttributeName:fontSize}
                                        context:nil];
    return ceil(rect.size.height);
}
@end
