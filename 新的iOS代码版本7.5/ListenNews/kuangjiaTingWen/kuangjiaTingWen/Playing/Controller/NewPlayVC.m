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

@interface NewPlayVC ()<UITableViewDelegate,UITableViewDataSource,TencentSessionDelegate>
{
    //底部播放模块控件容器
    UIView *dibuView;
    //底部收藏按钮
    UIButton *bofangfenxiangBtn;
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
    //打赏动画按钮
    OJLAnimationButton *rewardAnimationBtn;
    //是否点击自定义打赏金额按钮
    BOOL isCustomPay;
    //金币上传定时器
    dispatch_source_t gcd_timer;
}
/**
 主页面tableView
 */
@property(strong,nonatomic) UITableView *tableView;
/**
 倍数更改tableView
 */
@property(strong,nonatomic) UITableView *playSpeedTableView;
/**
 倍数弹窗容器
 */
@property (strong, nonatomic) CustomAlertView *alertView;
/**
 新闻详情模型数据
 */
@property (strong, nonatomic) newsDetailModel *postDetailModel;
/**
 新闻内容模型数据
 */
@property (strong, nonatomic) PlayVCTextContentCellFramesModel *textFrameModel;
/**
 评论数据数组
 */
@property(strong,nonatomic)NSMutableArray *pinglunArr;
/**
 倍数数组
 */
@property (strong, nonatomic) NSMutableArray *speedArray;
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
 顶部自定义导航栏
 */
@property (strong, nonatomic) UIView *topView;
/**
 顶部自定义中心view
 */
@property (strong, nonatomic) UIView *topCenterView;
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
 主播头像导航栏
 */
@property (strong, nonatomic) UIImageView *zhuboImgNav;
/**
 主播昵称导航栏
 */
@property (strong, nonatomic) UILabel *zhuboTitleLabNav;
/**
 主播标识麦克风图标导航栏
 */
@property (strong, nonatomic) UIImageView *micNav;

/**
 主播一行空白区域点击事件view
 */
@property (strong, nonatomic) UIView *achorTouch;
/**
 关注图标
 */
@property (strong, nonatomic) UIButton *guanzhuBtn;
/**
 关注图标Nav
 */
@property (strong, nonatomic) UIButton *guanzhuBtnNav;
/**
 分割线
 */
@property (strong, nonatomic) UIView *seperatorLine;
/**
 标题
 */
@property (strong, nonatomic) UILabel *titleLab;
/**
 日期
 */
@property (strong, nonatomic) UILabel *riqiLab;
//新闻详情控件------------------------------------

/**
 打赏金额
 */
@property (assign, nonatomic) float rewardCount;
/**
 是否显示开通会员弹窗提示
 */
@property (assign, nonatomic) BOOL isShowVipTipsFromLogin;
/**
 分页数
 */
@property (assign, nonatomic) NSInteger commentPage;
/**
 分页评论条数
 */
@property (assign, nonatomic) NSInteger commentPageSize;
/**
 打赏输入框
 */
@property (strong, nonatomic) UITextField *customRewardTextField;
@property (strong, nonatomic) UILabel *appreciateNum;//投金币数
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
- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    [self.navigationController setNavigationBarHidden:YES animated:YES];
    
    if (![ZRT_PlayerManager manager].isPlaying) {
        [[UIDevice currentDevice] setProximityMonitoringEnabled:NO];
    }else {
        [[UIDevice currentDevice] setProximityMonitoringEnabled:[[NSUserDefaults standardUserDefaults] boolForKey:@"shoushi"]];
    }
    DefineWeakSelf
    [ZRT_PlayerManager manager].playDidEnd = ^(NSInteger currentSongIndex) {
        
        //设置详情模型
        weakSelf.postDetailModel = [newsDetailModel new];
        //保存当前播放新闻的ID
        [weakSelf saveCurrentPlayNewsID];
        //设置模型数据，从播放器中获取对应正在播放的数据赋值新闻模型
        [weakSelf setPostDetailModelDataFormPlayManager];
        //获取详情数据
        [weakSelf loadData];
        //获取评论数据
        [weakSelf getCommentList];
    };

    if (_isShowVipTipsFromLogin && [[CommonCode readFromUserD:@"isLogin"] boolValue] == YES) {
        UIAlertController *qingshuruyonghuming = [UIAlertController alertControllerWithTitle:@"温馨提示" message:[NSString stringWithFormat:@"您还不是会员，每日可收听的%@条已听完，是否前往开通会员，收听更多资讯",[CommonCode readFromUserD:[NSString stringWithFormat:@"%@",limit_num]]] preferredStyle:UIAlertControllerStyleAlert];
        [qingshuruyonghuming addAction:[UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        }]];
        [qingshuruyonghuming addAction:[UIAlertAction actionWithTitle:@"前往开通会员" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            MyVipMenbersViewController *MyVip = [MyVipMenbersViewController new];
            [self.navigationController pushViewController:MyVip animated:YES];
        }]];
        [self presentViewController:qingshuruyonghuming animated:YES completion:nil];
        _isShowVipTipsFromLogin = NO;
    }
}
- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [self.navigationController setNavigationBarHidden:NO animated:YES];
}
- (void)viewDidLoad {
    [super viewDidLoad];
    //倍数数据
    self.speedArray = [NSMutableArray arrayWithArray:@[@"0.666667",@"1.0",@"1.25",@"1.5",@"2.0",@"3.0"]];
    //评论分页数据
    self.commentPage = 1;
    self.commentPageSize = 10;
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
    
    //设置底部播放控件
    [self xinwenxiangqingbujvNew];
    
    //设置新闻头部详情控件
    self.tableView.tableHeaderView = [self setupTableViewHeader];
    
    //添加手势返回
    UISwipeGestureRecognizer *rightSwipe = [[UISwipeGestureRecognizer alloc]initWithTarget:self action:@selector(rightSwipeAction:)];
    [rightSwipe setDirection:UISwipeGestureRecognizerDirectionRight];
    [self.view addGestureRecognizer:rightSwipe];
    
    //通知
    //后台系统中断音频控制通知
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleInterruption:) name:AVAudioSessionInterruptionNotification object:[AVAudioSession sharedInstance]];
    //其他App占据AudioSession通知
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleInterruptionHint:) name:AVAudioSessionSilenceSecondaryAudioHintNotification object:[AVAudioSession sharedInstance]];
    
    //添加通知，拔出耳机后暂停播放
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(routeChange:) name:AVAudioSessionRouteChangeNotification object:nil];
    //支付宝支付回调
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(aliPayResultsBack:) name:@"PayResultsBack" object:nil];
    //微信支付回调
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(WechatPayResultsBack:) name:@"WechatPayResultsBack" object:nil];
    //听币支付回调
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(TcoinPayResultsBack:) name:@"TcoinPayResultsBack" object:nil];
    //播放器状态改变
    RegisterNotify(SONGPLAYSTATUSCHANGE, @selector(playStatusChange:))
    //网络连接状态改变通知
    RegisterNotify(NETWORKSTATUSCHANGE, @selector(networkChange))
    //评论成功通知刷新
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(pinglunchenggong:) name:@"pinglunchenggong" object:nil];
}
#pragma mark - 加载新闻详情数据
- (void)loadData
{
    if (!self.post_id) return;
    [NetWorkTool getPostDetailWithaccessToken:AvatarAccessToken post_id:self.post_id sccess:^(NSDictionary *responseObject) {
        [self.tableView.mj_header endRefreshing];
        if ([responseObject[status] intValue] == 1){
            //判断只有当前不是vip才进行记录
            NSDictionary *userInfoDict = [CommonCode readFromUserD:@"dangqianUserInfo"];
            if ([userInfoDict[results][member_type] intValue] == 0) {
                //判断当前播放内容为新闻播放，新闻播放限制数+1
                if ([ZRT_PlayerManager manager].playType == ZRTPlayTypeNews) {
                    //判断限制状态，记录次数限制
//                    [[ZRT_PlayerManager manager] limitPlayStatusWithAdd:YES];
                    [[ZRT_PlayerManager manager] limitPlayStatusWithPost_id:_post_id withAdd:YES];
                }
            }
            //刷新新闻详情模型数据
            _postDetailModel = [newsDetailModel mj_objectWithKeyValues:responseObject[results]];
            //设置新闻内容详情的frame数据
            [self setFrameModel];
            //设置详情头部状态控件数据
            [self setHeaderStateControl];
        }
        else{
            [SVProgressHUD showErrorWithStatus:responseObject[msg]];
        }
        //设置打赏模块状态
        self.rewardType = RewardViewTypeNone;
        
        //滚动到顶部
//        [self.tableView setContentOffset:CGPointMake(0, IS_IPHONEX?-44:-20) animated:NO];
        
        [self.tableView reloadData];
    } failure:^(NSError *error) {
        [self.tableView.mj_header endRefreshing];
        RTLog(@"%@",error);
    }];
}
/**
 设置新闻内容详情frame模型数据
 */
- (void)setFrameModel{
    PlayVCTextContentCellFramesModel *frameModel = [[PlayVCTextContentCellFramesModel alloc] init];
    frameModel.titleFontSize = self.titleFontSize;
    frameModel.dateFont = self.dateFont;
    frameModel.title = self.postDetailModel.post_title;
    NSDate *date = [NSDate dateFromString:self.postDetailModel.post_modified];
    frameModel.timeString = [NSString stringWithFormat:@"#来自:%@   %@ ",self.postDetailModel.post_lai,[date showTimeByTypeA]];
    frameModel.excerpt = self.postDetailModel.post_excerpt;
    self.textFrameModel = frameModel;
}
#pragma mark - 获取评论列表
- (void)getCommentList{
    if (!self.post_id) return;
    //获取评论列表
    [NetWorkTool getPaoGuoJieMuPingLunLieBiaoWithJieMuID:self.post_id anduid:ExdangqianUserUid andPage:[NSString stringWithFormat:@"%ld",self.commentPage] andLimit:[NSString stringWithFormat:@"%ld",self.commentPageSize] sccess:^(NSDictionary *responseObject) {
        if ([responseObject[status] intValue] == 1) {
            if ([responseObject[@"results"] isKindOfClass:[NSArray class]])
            {
                NSArray *array = [PlayVCCommentModel mj_objectArrayWithKeyValuesArray:responseObject[@"results"]];
                self.pinglunArr = [self pinglunFrameModelArrayWithModelArray:array];
                if (array.count == 10 && self.commentPage == 1) {
                    DefineWeakSelf
                    self.tableView.mj_footer = [MJRefreshAutoNormalFooter footerWithRefreshingBlock:^{
                        [weakSelf getCommentList];
                    }];
                }
                if (array.count == 10) {
                    self.commentPage++;
                }
            }
            else{
                self.pinglunArr = [NSMutableArray array];
            }
            [self.tableView reloadData];
        }else{
            XWAlerLoginView *alert = [XWAlerLoginView alertWithTitle:responseObject[msg]];
            [alert show];
        }
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
    _topView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, IPHONE_W,IS_IPHONEX?88: 64)];
    _topView.backgroundColor = [UIColor clearColor];
    _topView.hidden = NO;
    [self.view addSubview:_topView];
    
    _leftBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    _leftBtn.frame = CGRectMake(10,IS_IPHONEX?25+24:25, 35, 35);
    [_leftBtn setImageEdgeInsets:UIEdgeInsetsMake(5, 0, 5, 10)];
    [_leftBtn setImage:[UIImage imageNamed:@"title_ic_white"] forState:UIControlStateNormal];
    _leftBtn.accessibilityLabel = @"返回";
    [_leftBtn addTarget:self action:@selector(back) forControlEvents:UIControlEventTouchUpInside];
    [_topView addSubview:_leftBtn];
    
    _rightBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    _rightBtn.frame = CGRectMake(SCREEN_WIDTH - 55, IS_IPHONEX?25+24:25, 35, 35);
    [_rightBtn setImageEdgeInsets:UIEdgeInsetsMake(5, 10, 5, 0)];
    [_rightBtn setImage:[UIImage imageNamed:@"title_ic_share_white"] forState:UIControlStateNormal];
    _rightBtn.accessibilityLabel = @"分享";
    [_rightBtn addTarget:self action:@selector(shareNewsBtnAction) forControlEvents:UIControlEventTouchUpInside];
    [_topView addSubview:_rightBtn];
    
    _topCenterView = [[UIView alloc] initWithFrame:CGRectMake(CGRectGetMaxX(_leftBtn.frame),IS_IPHONEX?20+24: 20, SCREEN_WIDTH - CGRectGetMaxX(_leftBtn.frame) - 55, 44)];
    _topCenterView.backgroundColor = [UIColor clearColor];
    [_topView addSubview:_topCenterView];
    
    //关注、取消
    if (IS_IPAD||IS_IPHONEX) {
        self.guanzhuBtnNav.frame = CGRectMake(_topCenterView.width - 60.0 / 375 * IPHONE_W, 7, 55.0 / 375 * IPHONE_W, IS_IPHONEX?30: 30.0);
    }else{
        self.guanzhuBtnNav.frame = CGRectMake(_topCenterView.width - 60.0 / 375 * IPHONE_W, 7, 55.0 / 375 * IPHONE_W,IS_IPHONEX?30: 30.0 / 667 * IPHONE_H);
    }
    [_topCenterView addSubview:_guanzhuBtnNav];
    
    //主播头像
    self.zhuboImgNav.frame = CGRectMake(0, (44 - 27)/2.0,  27.0, 27.0);
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(zhuboBtnVAction:)];
    [_zhuboImgNav addGestureRecognizer:tap];
    [_topCenterView addSubview:_zhuboImgNav];
    //主播名字
    self.zhuboTitleLabNav.frame = CGRectMake(CGRectGetMaxX(_zhuboImgNav.frame)+5, (44 - 32)/2.0, 88.0 / 375 * IPHONE_W, 32.0);
    [_zhuboTitleLabNav addTapGesWithTarget:self action:@selector(zhuboBtnVAction:)];
    [_topCenterView addSubview:_zhuboTitleLabNav];
    //主播麦克风图标
    self.micNav.frame = CGRectMake(CGRectGetMaxX(_zhuboTitleLabNav.frame), (44 - 20)/2.0 , 8.0 /375 * SCREEN_WIDTH, 14.0 / 667 * SCREEN_HEIGHT);
    [_micNav addTapGesWithTarget:self action:@selector(zhuboBtnVAction:)];
    [_topCenterView addSubview:_micNav];
    
}
#pragma mark - 设置详情控件数据
- (void)setupTableViewHeaderData
{
    //设置新闻图片
    NSString *imgUrl4 = NEWSSEMTPHOTOURL(self.postDetailModel.smeta);
    if (imgUrl4 == nil) {
        return;
    }
    if ([imgUrl4 rangeOfString:@"userDownLoadPathImage"].location != NSNotFound) {
        [self.zhengwenImg sd_setImageWithURL:[NSURL fileURLWithPath:imgUrl4] placeholderImage:[UIImage imageNamed:@"thumbnailsdefault"]];
    }
    else if ([imgUrl4  rangeOfString:@"http"].location != NSNotFound)
    {
        [self.zhengwenImg sd_setImageWithURL:[NSURL URLWithString:imgUrl4] placeholderImage:[UIImage imageNamed:@"thumbnailsdefault"]];
    }else
    {
        NSString *str = USERPHOTOHTTPSTRINGZhuBo(imgUrl4);
        [self.zhengwenImg sd_setImageWithURL:[NSURL URLWithString:str] placeholderImage:[UIImage imageNamed:@"thumbnailsdefault"]];
    }
    //设置主播头像
    if([self.postDetailModel.act.images rangeOfString:@"/data/upload/"].location !=NSNotFound)//_roaldSearchText
    {
        IMAGEVIEWHTTP(self.zhuboImg, self.postDetailModel.act.images);
        IMAGEVIEWHTTP(self.zhuboImgNav, self.postDetailModel.act.images);
    }
    else
    {
        IMAGEVIEWHTTP2(self.zhuboImg, self.postDetailModel.act.images);
        IMAGEVIEWHTTP2(self.zhuboImgNav, self.postDetailModel.act.images);
    }
    //设置主播昵称
    self.zhuboTitleLab.text = self.postDetailModel.act.name;
    self.zhuboTitleLabNav.text = self.postDetailModel.act.name;
    CGSize contentSize = [_zhuboTitleLab sizeThatFits:CGSizeMake(SCREEN_WIDTH - _zhuboTitleLab.x - 100.0/375*SCREEN_WIDTH , MAXFLOAT)];
    _zhuboTitleLab.frame = CGRectMake(_zhuboTitleLab.x, _zhuboTitleLab.y,contentSize.width,contentSize.height>20?contentSize.height:_zhuboTitleLab.height);
    //主播麦克风图标frame
    self.mic.frame = CGRectMake(CGRectGetMaxX(_zhuboTitleLab.frame) + 6.0 / 375 * SCREEN_WIDTH, _zhuboTitleLab.center.y - 7.0 / 667 * SCREEN_HEIGHT, 8.0 /375 * SCREEN_WIDTH, 14.0 / 667 * SCREEN_HEIGHT);

    //是否关注
    self.guanzhuBtn.selected = [self.postDetailModel.act.is_fan intValue] == 1;
    self.guanzhuBtnNav.selected = [self.postDetailModel.act.is_fan intValue] == 1;
    //设置标题名称
    self.titleLab.text = self.postDetailModel.post_title;
    //是否收藏
    bofangfenxiangBtn.selected = [self.postDetailModel.is_collection intValue] == 1;
    [self reloadPlayAllTime];/**<刷新音频总时长*/
}
- (void)setHeaderStateControl
{
    //设置主播昵称
    self.zhuboTitleLab.text = self.postDetailModel.act.name;
    self.zhuboTitleLabNav.text = self.postDetailModel.act.name;
    CGSize contentSize = [_zhuboTitleLab sizeThatFits:CGSizeMake(SCREEN_WIDTH - _zhuboTitleLab.x - 100.0/375*SCREEN_WIDTH, MAXFLOAT)];
    CGSize navContentSize = [_zhuboTitleLabNav sizeThatFits:CGSizeMake(_topCenterView.width - _zhuboTitleLabNav.x - 80.0 / 375 * IPHONE_W, MAXFLOAT)];
    _zhuboTitleLab.frame = CGRectMake(_zhuboTitleLab.x, _zhuboTitleLab.y,contentSize.width, contentSize.height>20?contentSize.height:_zhuboTitleLab.height);
    _zhuboTitleLabNav.frame = CGRectMake(_zhuboTitleLabNav.x, _zhuboTitleLabNav.y,navContentSize.width, _zhuboTitleLabNav.height);
    //主播麦克风图标frame
    self.mic.frame = CGRectMake(CGRectGetMaxX(_zhuboTitleLab.frame) + 6.0 / 375 * SCREEN_WIDTH, _zhuboTitleLab.center.y - 7.0 / 667 * SCREEN_HEIGHT, 8.0 /375 * SCREEN_WIDTH, 14.0 / 667 * SCREEN_HEIGHT);
    if (IS_IPHONEX) {
        self.micNav.frame = CGRectMake(CGRectGetMaxX(_zhuboTitleLabNav.frame) + 6.0 / 375 * SCREEN_WIDTH, _zhuboTitleLabNav.center.y - 7.0 / 667 * SCREEN_HEIGHT, 8.0 /375 * SCREEN_WIDTH, 14.0 / 667 * SCREEN_HEIGHT);
    }else{
        self.micNav.frame = CGRectMake(CGRectGetMaxX(_zhuboTitleLabNav.frame) + 6.0 / 375 * SCREEN_WIDTH, _zhuboTitleLabNav.center.y - 7.0 / 667 * SCREEN_HEIGHT, 8.0 /375 * SCREEN_WIDTH, 14.0 / 667 * SCREEN_HEIGHT);
    }
    //设置标题名称
    self.titleLab.text = self.postDetailModel.post_title;
    //是否关注
    self.guanzhuBtn.selected = [self.postDetailModel.act.is_fan intValue] == 1;
    self.guanzhuBtnNav.selected = [self.postDetailModel.act.is_fan intValue] == 1;
    //是否收藏
    bofangfenxiangBtn.selected = [self.postDetailModel.is_collection intValue] == 1;
    [self reloadPlayAllTime];/**<刷新音频总时长*/
}
#pragma mark - 设置新闻头部控件
- (UIView *)setupTableViewHeader
{
    xiangqingView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, IPHONE_W, IPHONE_H)];
    xiangqingView.backgroundColor = [UIColor whiteColor];
    
    //新闻图片
    self.zhengwenImg.frame = CGRectMake(0, -20, IPHONE_W,IS_IPHONEX?209.0:209.0 / 667 * SCREEN_HEIGHT);
    
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
    self.zhuboTitleLab.frame = CGRectMake(CGRectGetMaxX(_zhuboImg.frame) + 4.0 / 375 * IPHONE_W, _zhuboImg.frame.origin.y, 88.0 / 375 * IPHONE_W, 30.0 / 667 * IPHONE_H);
    [_zhuboTitleLab addTapGesWithTarget:self action:@selector(zhuboBtnVAction:)];
    [xiangqingView addSubview:_zhuboTitleLab];
    
    //主播麦克风图标
    self.mic.frame = CGRectMake(CGRectGetMaxX(_zhuboTitleLab.frame) + 6.0 / 375 * SCREEN_WIDTH, _zhuboTitleLab.frame.origin.y + 7.0 / 667 * SCREEN_HEIGHT, 8.0 /375 * SCREEN_WIDTH, 14.0 / 667 * SCREEN_HEIGHT);
    [_mic addTapGesWithTarget:self action:@selector(zhuboBtnVAction:)];
    [xiangqingView addSubview:_mic];
    //空白区域view
    self.achorTouch.frame = CGRectMake(CGRectGetMaxX(_mic.frame), CGRectGetMaxY(_zhengwenImg.frame), SCREEN_WIDTH - CGRectGetMaxX(_mic.frame) - 80.0 / 375 * IPHONE_W , 47.0 / 667 * SCREEN_HEIGHT);
    [_achorTouch  addTapGesWithTarget:self action:@selector(zhuboBtnVAction:)];
    [xiangqingView addSubview:_achorTouch];
    
    //关注、取消
    if (IS_IPAD||IS_IPHONEX) {
        self.guanzhuBtn.frame = CGRectMake(SCREEN_WIDTH - 80.0 / 375 * IPHONE_W, CGRectGetMaxY(_zhengwenImg.frame) + 9.0 / 375 * IPHONE_W, 60.0 / 375 * IPHONE_W, 30.0);
    }else{
        self.guanzhuBtn.frame = CGRectMake(SCREEN_WIDTH - 80.0 / 375 * IPHONE_W, CGRectGetMaxY(_zhengwenImg.frame) + 9.0 / 375 * IPHONE_W, 60.0 / 375 * IPHONE_W, 30.0 / 667 * IPHONE_H);
    }
    [xiangqingView addSubview:_guanzhuBtn];
    
    
    self.seperatorLine.frame = CGRectMake(20.0 / 375 * SCREEN_WIDTH, CGRectGetMaxY(_zhuboImg.frame) +  12.0 / 667 * SCREEN_HEIGHT, SCREEN_WIDTH - 40.0 / 375 * SCREEN_WIDTH, 1.0);
    [xiangqingView addSubview:_seperatorLine];
    
    xiangqingView.height = CGRectGetMaxY(self.seperatorLine.frame);

    return xiangqingView;
}
#pragma mark - 设置底部播放控件
- (void)xinwenxiangqingbujv{
    
    //底部view主容器控件
    dibuView = [[UIView alloc]initWithFrame:CGRectMake(0, IPHONE_H - 109.0 / 667 * IPHONE_H, IPHONE_W, 109.0 / 667 * IPHONE_H)];
    dibuView.backgroundColor = [UIColor whiteColor];
    [self.view addSubview:dibuView];
    //底部收藏按钮
    bofangfenxiangBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    bofangfenxiangBtn.frame = CGRectMake(IPHONE_W - 52.0 / 375 * IPHONE_W, 54.0 / 667 * IPHONE_H,IS_IPHONEX?32.0: 32.0 / 667 * IPHONE_H,IS_IPHONEX?32.0: 32.0 / 667 * IPHONE_H);
    [bofangfenxiangBtn setImageEdgeInsets:UIEdgeInsetsMake(5, 5, 7, 7)];
    [bofangfenxiangBtn setImage:[UIImage imageNamed:@"home_news_collection"] forState:UIControlStateNormal];
    [bofangfenxiangBtn setImage:[UIImage imageNamed:@"home_news_collectioned"] forState:UIControlStateSelected];
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
- (void)xinwenxiangqingbujvNew{
    
    //底部view主容器控件
    dibuView = [[UIView alloc]initWithFrame:CGRectMake(0, IPHONE_H - 159.0 / 667 * IPHONE_H, IPHONE_W, 159.0 / 667 * IPHONE_H)];
    dibuView.backgroundColor = [UIColor whiteColor];
    [self.view addSubview:dibuView];
    
    //底部收藏按钮
    bofangfenxiangBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    bofangfenxiangBtn.frame = CGRectMake(IPHONE_W - 52.0 / 375 * IPHONE_W, 54.0 / 667 * IPHONE_H,IS_IPHONEX?32.0: 32.0 / 667 * IPHONE_H,IS_IPHONEX?32.0: 32.0 / 667 * IPHONE_H);
    [bofangfenxiangBtn setImageEdgeInsets:UIEdgeInsetsMake(5, 5, 7, 7)];
    [bofangfenxiangBtn setImage:[UIImage imageNamed:@"home_news_collection"] forState:UIControlStateNormal];
    [bofangfenxiangBtn setImage:[UIImage imageNamed:@"home_news_collectioned"] forState:UIControlStateSelected];
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
    
    
    UIView *bottomBgView = [[UIView alloc]initWithFrame:CGRectMake(0, IS_IPHONEX?159.0 / 667 * IPHONE_H - 50 - 34 + 10:159.0 / 667 * IPHONE_H - 50, IPHONE_W, IS_IPHONEX? 50 + 34:50)];
    bottomBgView.backgroundColor = HEXCOLOR(0xfafafa);
    [dibuView addSubview:bottomBgView];
    
    UIView *line = [[UIView alloc]initWithFrame:CGRectMake(0, 0, IPHONE_W, 0.5)];
    line.backgroundColor = [UIColor grayColor];
    line.alpha = 0.5f;
    [bottomBgView addSubview:line];
    //功能按钮
    int col = 3;
    for (int i = 0; i<col; i++) {
        UIButton *button = [[UIButton alloc] initWithFrame:CGRectMake(SCREEN_WIDTH/col * i, 10, SCREEN_WIDTH/col, 25)];
        button.imageView.contentMode = UIViewContentModeScaleAspectFit;
        [button addTarget:self action:@selector(button_click:)];
        [bottomBgView addSubview:button];
        
        UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(SCREEN_WIDTH/col * i, CGRectGetMaxY(button.frame)+2, SCREEN_WIDTH/col, 10)];
        label.textAlignment = NSTextAlignmentCenter;
        label.textColor = [UIColor grayColor];
        label.font = [UIFont systemFontOfSize:10.0];
        [bottomBgView addSubview:label];
        
        if (i == 0) {
            [button setImage:[UIImage imageNamed:@"icon_down"] forState:UIControlStateNormal];
            button.accessibilityIdentifier = @"下载";
            label.text = @"下载";
        }else if (i == 1) {
            [button setImage:[UIImage imageNamed:@"icon_played"] forState:UIControlStateNormal];
            button.accessibilityIdentifier = @"倍数";
            label.text = @"倍数";
        }
//        else if (i == 2) {
//            [button setImage:[UIImage imageNamed:@"icon_player_quality"] forState:UIControlStateNormal];
//            button.accessibilityIdentifier = @"音质";
//            label.text = @"音质";
//        }
        else if (i == 2) {
            [button setImage:[UIImage imageNamed:@"icon_comment"] forState:UIControlStateNormal];
            button.accessibilityIdentifier = @"评论";
            label.text = @"评论";
        }
    }
    
    [self bofangqiSetNew];
}
/**
 点击底部按钮时间
 */
- (void)button_click:(UIButton *)button
{
    if ([button.accessibilityIdentifier isEqualToString:@"下载"]) {
        //下载
        [self downloadAction:button];
    }else if ([button.accessibilityIdentifier isEqualToString:@"评论"]) {
        //评论
        [self pinglunAction];
    }else if ([button.accessibilityIdentifier isEqualToString:@"倍数"]) {
        
        _alertView = [[CustomAlertView alloc] initWithCustomView:[self setupPlaySpeedAlertView]];
        _alertView.alertHeight = 49 * (self.speedArray.count + 1);
        _alertView.alertDuration = 0.25;
        _alertView.coverAlpha = 0.6;
        [_alertView show];
    }else if ([button.accessibilityIdentifier isEqualToString:@"音质"]) {
        [[XWAlerLoginView alertWithTitle:@"~暂未开放~"] show];
    }
}
/**
 倍数设置弹窗
 */
- (UIView *)setupPlaySpeedAlertView
{
    UIView *bgView = [[UIView alloc] init];
    bgView.backgroundColor = HEXCOLOR(0xe3e3e3);
    bgView.frame = CGRectMake(0, 0, SCREEN_WIDTH, 49 * (self.speedArray.count + 1));
    
    [bgView addSubview:self.playSpeedTableView];
    
    return bgView;
}
#pragma mark - 播放器设置
- (void)bofangqiSet
{
    //底部播放左按钮
    bofangLeftBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    bofangLeftBtn.frame = CGRectMake(104.5 / 375 * IPHONE_W, 54.0 / 667 * IPHONE_H, 32.0 / 667 * IPHONE_H, 32.0 / 667 * IPHONE_H);
    [bofangLeftBtn setImage:[UIImage imageNamed:@"home_news_ic_before"] forState:UIControlStateNormal];
    [bofangLeftBtn setImage:[UIImage imageNamed:@"home_news_ic_before"] forState:UIControlStateDisabled];
    bofangLeftBtn.accessibilityLabel = @"上一条新闻";
    [bofangLeftBtn addTarget:self action:@selector(bofangLeftAction:) forControlEvents:UIControlEventTouchUpInside];
    bofangLeftBtn.contentMode = UIViewContentModeScaleToFill;
    [dibuView addSubview:bofangLeftBtn];
    
    //底部播放右按钮
    bofangRightBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    bofangRightBtn.frame = CGRectMake(IPHONE_W - 104.5 / 375 * SCREEN_WIDTH -  bofangLeftBtn.frame.size.width, bofangLeftBtn.frame.origin.y, bofangLeftBtn.frame.size.width,bofangLeftBtn.frame.size.height);
    [bofangRightBtn setImage:[UIImage imageNamed:@"home_news_ic_next"] forState:UIControlStateNormal];
    [bofangRightBtn setImage:[UIImage imageNamed:@"home_news_ic_next"] forState:UIControlStateDisabled];
    bofangRightBtn.accessibilityLabel = @"下一则新闻";
    [bofangRightBtn addTarget:self action:@selector(bofangRightAction:) forControlEvents:UIControlEventTouchUpInside];
    bofangRightBtn.contentMode = UIViewContentModeScaleToFill;
    [dibuView addSubview:bofangRightBtn];
    
    //底部播放暂停按钮
    bofangCenterBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    bofangCenterBtn.frame = CGRectMake((IPHONE_W  - bofangLeftBtn.frame.size.width)/ 2, bofangLeftBtn.frame.origin.y, bofangLeftBtn.frame.size.width ,bofangLeftBtn.frame.size.height);
    [bofangCenterBtn setImage:[UIImage imageNamed:@"home_news_ic_play"] forState:UIControlStateNormal];
    [bofangCenterBtn setImage:[UIImage imageNamed:@"home_news_ic_pause"] forState:UIControlStateSelected];
    bofangCenterBtn.accessibilityLabel = @"播放";
    [bofangCenterBtn addTarget:self action:@selector(playPauseClicked:) forControlEvents:UIControlEventTouchUpInside];
    bofangCenterBtn.contentMode = UIViewContentModeScaleToFill;
    bofangCenterBtn.selected = YES;
    
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
    
    //播放进度条
    [self.sliderProgress setThumbImage:[UIImage imageNamed:@"slider"] forState:UIControlStateNormal];
    self.sliderProgress.minimumTrackTintColor = gMainColor;
    self.sliderProgress.maximumTrackTintColor = [UIColor clearColor];
    [self.sliderProgress addTarget:self action:@selector(doChangeProgress:) forControlEvents:UIControlEventValueChanged];
    [self.sliderProgress addTarget:self action:@selector(sliderTouchDown:) forControlEvents:UIControlEventTouchDown];
    self.prgBufferProgress.frame = self.sliderProgress.frame;
    self.prgBufferProgress.centerY = self.sliderProgress.centerY;
//    self.prgBufferProgress.backgroundColor = [UIColor redColor];
    self.prgBufferProgress.progressTintColor = gMainColor;;
    [dibuView addSubview:self.prgBufferProgress];
    [dibuView addSubview:self.sliderProgress];
    self.sliderProgress.maximumTrackTintColor = [UIColor clearColor];
    
    [dibuView addSubview:bofangCenterBtn];
    
    DefineWeakSelf
    [ZRT_PlayerManager manager].playTimeObserve = ^(float progress,float currentTime,float totalDuration) {
        
        dangqianTime.text = [weakSelf convertStringWithTime:currentTime];
        weakSelf.sliderProgress.value = currentTime;
        weakSelf.sliderProgress.maximumValue = totalDuration;
    };
    [ZRT_PlayerManager manager].reloadBufferProgress = ^(float bufferProgress,float totalDuration) {
        if (bufferProgress>0) {
            //添加播放记录功能：实例60秒开始播放
            if ((bufferProgress*totalDuration)>self.starDate && self.starDate!= 0) {
                //调到指定时间去播放
                [[ZRT_PlayerManager manager].player seekToTime:CMTimeMake(_starDate, 1) completionHandler:^(BOOL finished) {
                    if (finished == YES){
                        [[ZRT_PlayerManager manager] startPlay];
                    }
                }];
                self.starDate = 0;
            }
            //更新播放条进度
            [weakSelf.prgBufferProgress setProgress:bufferProgress animated:YES];
        }else{
            [weakSelf.prgBufferProgress setProgress:0. animated:YES];
        }
    };
    
}
- (void)bofangqiSetNew
{
    //底部播放左按钮
    bofangLeftBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    bofangLeftBtn.frame = CGRectMake(104.5 / 375 * IPHONE_W, 54.0 / 667 * IPHONE_H, 32.0 / 667 * IPHONE_H, 32.0 / 667 * IPHONE_H);
    [bofangLeftBtn setImage:[UIImage imageNamed:@"home_news_ic_before"] forState:UIControlStateNormal];
    [bofangLeftBtn setImage:[UIImage imageNamed:@"home_news_ic_before"] forState:UIControlStateDisabled];
    bofangLeftBtn.accessibilityLabel = @"上一条新闻";
    [bofangLeftBtn addTarget:self action:@selector(bofangLeftAction:) forControlEvents:UIControlEventTouchUpInside];
    bofangLeftBtn.contentMode = UIViewContentModeScaleToFill;
    [dibuView addSubview:bofangLeftBtn];
    
    //底部播放右按钮
    bofangRightBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    bofangRightBtn.frame = CGRectMake(IPHONE_W - 104.5 / 375 * SCREEN_WIDTH -  bofangLeftBtn.frame.size.width, bofangLeftBtn.frame.origin.y, bofangLeftBtn.frame.size.width,bofangLeftBtn.frame.size.height);
    [bofangRightBtn setImage:[UIImage imageNamed:@"home_news_ic_next"] forState:UIControlStateNormal];
    [bofangRightBtn setImage:[UIImage imageNamed:@"home_news_ic_next"] forState:UIControlStateDisabled];
    bofangRightBtn.accessibilityLabel = @"下一则新闻";
    [bofangRightBtn addTarget:self action:@selector(bofangRightAction:) forControlEvents:UIControlEventTouchUpInside];
    bofangRightBtn.contentMode = UIViewContentModeScaleToFill;
    [dibuView addSubview:bofangRightBtn];
    
    //底部播放暂停按钮
    bofangCenterBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    bofangCenterBtn.frame = CGRectMake((IPHONE_W  - bofangLeftBtn.frame.size.width)/ 2, bofangLeftBtn.frame.origin.y, bofangLeftBtn.frame.size.width ,bofangLeftBtn.frame.size.height);
    [bofangCenterBtn setImage:[UIImage imageNamed:@"home_news_ic_play"] forState:UIControlStateNormal];
    [bofangCenterBtn setImage:[UIImage imageNamed:@"home_news_ic_pause"] forState:UIControlStateSelected];
    bofangCenterBtn.accessibilityLabel = @"播放";
    [bofangCenterBtn addTarget:self action:@selector(playPauseClicked:) forControlEvents:UIControlEventTouchUpInside];
    bofangCenterBtn.contentMode = UIViewContentModeScaleToFill;
    bofangCenterBtn.selected = YES;
    
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
    
    //播放进度条
    [self.sliderProgress setThumbImage:[UIImage imageNamed:@"slider"] forState:UIControlStateNormal];
    self.sliderProgress.minimumTrackTintColor = gMainColor;
    self.sliderProgress.maximumTrackTintColor = [UIColor clearColor];
    [self.sliderProgress addTarget:self action:@selector(doChangeProgress:) forControlEvents:UIControlEventValueChanged];
    [self.sliderProgress addTarget:self action:@selector(sliderTouchDown:) forControlEvents:UIControlEventTouchDown];
    self.prgBufferProgress.frame = self.sliderProgress.frame;
    self.prgBufferProgress.centerY = self.sliderProgress.centerY;
    self.prgBufferProgress.progressTintColor = gMainColor;
    [dibuView addSubview:self.prgBufferProgress];
    [dibuView addSubview:self.sliderProgress];
    self.sliderProgress.maximumTrackTintColor = [UIColor clearColor];
    
    [dibuView addSubview:bofangCenterBtn];
    
    DefineWeakSelf
    [ZRT_PlayerManager manager].playTimeObserve = ^(float progress,float currentTime,float totalDuration) {
        
        dangqianTime.text = [weakSelf convertStringWithTime:currentTime];
        weakSelf.sliderProgress.value = currentTime;
        weakSelf.sliderProgress.maximumValue = totalDuration;
    };
    [ZRT_PlayerManager manager].reloadBufferProgress = ^(float bufferProgress,float totalDuration) {
        if (bufferProgress>0) {
            //添加播放记录功能：实例60秒开始播放
            if ((bufferProgress*totalDuration)>self.starDate && self.starDate!= 0) {
                //调到指定时间去播放
                [[ZRT_PlayerManager manager].player seekToTime:CMTimeMake(_starDate, 1) completionHandler:^(BOOL finished) {
                    if (finished == YES){
                        [[ZRT_PlayerManager manager] startPlay];
                    }
                }];
                self.starDate = 0;
            }
            //更新播放条进度
            [weakSelf.prgBufferProgress setProgress:bufferProgress animated:YES];
        }else{
            [weakSelf.prgBufferProgress setProgress:0. animated:YES];
        }
    };
    
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
        _zhuboTitleLab.font = gFontMain13;
        _zhuboTitleLab.numberOfLines = 2;
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
- (UIImageView *)zhuboImgNav
{
    if (_zhuboImgNav == nil) {
        _zhuboImgNav = [[UIImageView alloc] init];
        _zhuboImgNav.layer.masksToBounds = YES;
        _zhuboImgNav.userInteractionEnabled = YES;
        _zhuboImgNav.layer.cornerRadius = 27.0 / 667 * IPHONE_H / 2;
        _zhuboImgNav.contentMode = UIViewContentModeScaleAspectFill;
    }
    return _zhuboImgNav;
}
- (UILabel *)zhuboTitleLabNav
{
    if (_zhuboTitleLabNav == nil) {
        _zhuboTitleLabNav = [[UILabel alloc] init];
        _zhuboTitleLabNav.textColor = nTextColorSub;
        _zhuboTitleLabNav.font = gFontMain13;
        _zhuboTitleLabNav.numberOfLines = 2;
        _zhuboTitleLabNav.textAlignment = NSTextAlignmentLeft;
    }
    return _zhuboTitleLabNav;
}
- (UIImageView *)micNav
{
    if (_micNav == nil) {
        _micNav = [[UIImageView alloc] init];
        [_micNav setImage:[UIImage imageNamed:@"home_news_ic_anchor"]];
    }
    return _micNav;
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
        [_guanzhuBtn setTitle:@"+ 关注" forState:UIControlStateNormal];
        [_guanzhuBtn setTitle:@"取消" forState:UIControlStateSelected];
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
- (UIButton *)guanzhuBtnNav
{
    if (_guanzhuBtnNav == nil) {
        _guanzhuBtnNav = [UIButton buttonWithType:UIButtonTypeCustom];
        [_guanzhuBtnNav setTitle:@"+ 关注" forState:UIControlStateNormal];
        [_guanzhuBtnNav setTitle:@"取消" forState:UIControlStateSelected];
        [_guanzhuBtnNav setTitleColor:gMainColor forState:UIControlStateNormal];
        _guanzhuBtnNav.titleLabel.font  = [UIFont systemFontOfSize:13.0];
        _guanzhuBtnNav.layer.cornerRadius = 4;
        _guanzhuBtnNav.layer.masksToBounds = YES;
        _guanzhuBtnNav.layer.borderColor = gMainColor.CGColor;
        _guanzhuBtnNav.layer.borderWidth = 0.5f;
        _guanzhuBtnNav.bounds = CGRectMake(0, 0, 50, 30);
        [_guanzhuBtnNav addTarget:self action:@selector(guanzhuBtnAction:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _guanzhuBtnNav;
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
        _tableView = [[UITableView alloc]initWithFrame:CGRectMake(0,IS_IPHONEX?-25:0, IPHONE_W, IPHONE_H - 159.0 / 667 * IPHONE_H) style:UITableViewStylePlain];
        _tableView.delegate = self;
        _tableView.backgroundColor = [UIColor whiteColor];
        _tableView.scrollsToTop = YES;
        _tableView.dataSource = self;
        _tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
        _tableView.estimatedRowHeight = 0;
        _tableView.estimatedSectionHeaderHeight = 0;
        _tableView.estimatedSectionFooterHeight = 0;
    }
    return _tableView;
}
- (UITableView *)playSpeedTableView
{
    if (!_playSpeedTableView)
    {
        _playSpeedTableView = [[UITableView alloc]initWithFrame:CGRectMake(0,0, IPHONE_W, 49 * (self.speedArray.count + 1)) style:UITableViewStylePlain];
        _playSpeedTableView.delegate = self;
        _playSpeedTableView.dataSource = self;
        _playSpeedTableView.backgroundColor = [UIColor whiteColor];
        
        UIButton *cancelBtn = [[UIButton alloc] init];
        cancelBtn.frame = CGRectMake(0, 0, SCREEN_WIDTH, 49);
        cancelBtn.backgroundColor = [UIColor whiteColor];
        [cancelBtn setTitle:@"取消" forState:UIControlStateNormal];
        [cancelBtn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        cancelBtn.titleLabel.font = [UIFont systemFontOfSize:15];
        [cancelBtn addTarget:self action:@selector(cancel_playSpeed_view)];
        _playSpeedTableView.tableFooterView = cancelBtn;
    }
    return _playSpeedTableView;
}
- (void)cancel_playSpeed_view
{
    [_alertView coverClick];
}
- (UIButton *)scrollTopBtn
{
    if (_scrollTopBtn == nil) {
        CGFloat W = 40.0f;
        _scrollTopBtn = [[UIButton alloc] initWithFrame:CGRectMake(SCREEN_WIDTH - W, SCREEN_HEIGHT - W - 10 - 159.0/667*IPHONE_H, W, W)];
        _scrollTopBtn.layer.cornerRadius = 25;
        [_scrollTopBtn setImage:@"置顶"];
        [_scrollTopBtn addTarget:self action:@selector(scrollToTop)];
        _scrollTopBtn.alpha = 0.0;
    }
    return _scrollTopBtn;
}
- (void)scrollToTop
{
    [self.tableView setContentOffset:CGPointMake(0, IS_IPHONEX?-44:-20) animated:YES];
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
        _sliderProgress = [[UISlider alloc]initWithFrame:CGRectMake(20.0 / 375 * IPHONE_W, 22.0 / 667 * SCREEN_HEIGHT - 10, IPHONE_W - 40.0 / 375 * IPHONE_W, 10.0)];
        _sliderProgress.value = 0.0f;
        _sliderProgress.continuous = NO;
//        _sliderProgress.backgroundColor = [UIColor redColor];
    }
    return _sliderProgress;
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
- (NSMutableArray *)listenedNewsIDArray
{
    if (!_listenedNewsIDArray) {
        if ([[CommonCode readFromUserD:yitingguoxinwenID] isKindOfClass:[NSArray class]])
        {
            _listenedNewsIDArray = [NSMutableArray arrayWithArray:[CommonCode readFromUserD:yitingguoxinwenID]];;
        }else
        {
            _listenedNewsIDArray = [NSMutableArray array];
        }

    }
    return _listenedNewsIDArray;
}
#pragma mark - table datasource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if ([tableView isEqual:self.tableView]) {
        if (self.pinglunArr.count != 0) {
            return 1 + self.pinglunArr.count;
        }else{
            return 1;
        }
    }else{
        return self.speedArray.count;
    }
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if ([tableView isEqual:self.tableView]) {
        if (indexPath.row == 0) {
            PlayVCTextContentTableViewCell *cell = [PlayVCTextContentTableViewCell cellWithTableView:tableView];
            cell.frameModel = self.textFrameModel;
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
            return cell;
            //    }
            //    else if (indexPath.row == 1) {
            //        PlayVCThreeBtnTableViewCell *cell = [PlayVCThreeBtnTableViewCell cellWithTableView:tableView];
            //        cell.appreciateNum.text = self.postDetailModel.gold;
            //        self.appreciateNum = cell.appreciateNum;
            //        cell.commentNum.text = self.postDetailModel.comment_count;
            //        DefineWeakSelf
            //        cell.selectedItem = ^(UIButton *item) {
            //            [weakSelf selecteItemAction:item];
            //        };
            //        cell.selectionStyle = UITableViewCellSelectionStyleNone;
            //        return cell;
            //    }else if (indexPath.row == 2) {
            //        if (_rewardType == RewardViewTypeNone) {
            //            PlayDefaultRewardTableViewCell *cell = [PlayDefaultRewardTableViewCell cellWithTableView:tableView];
            //            cell.rewardArray = self.postDetailModel.reward;
            //            DefineWeakSelf
            //            cell.rewardButtonAciton = ^(UIButton *item) {
            //                [weakSelf rewardButtonAciton:item];
            //            };
            //            cell.lookupRewardListButton = ^(UIButton *item) {
            //                [weakSelf lookupRewardListButton:item];
            //            };
            //            cell.selectionStyle = UITableViewCellSelectionStyleNone;
            //            return cell;
            //        }else{
            //            PlayCustomRewardTableViewCell *cell = [PlayCustomRewardTableViewCell cellWithTableView:tableView];
            //            cell.rewardType = _rewardType;
            //            rewardAnimationBtn = cell.finalRewardButton;
            //            DefineWeakSelf
            //            cell.selecteRewardCountAction = ^(UIButton *item, NSArray *buttons) {
            //                [weakSelf selecteRewardCountAction:item buttons:buttons];
            //            };
            //            cell.finalRewardButtonAciton = ^(OJLAnimationButton *item,UITextField *payTextField) {
            //                [weakSelf finalRewardButtonAciton:item payTextField:payTextField];
            //            };
            //            cell.backButtonAction = ^(UIButton *item) {
            //                [weakSelf backButtonAction:item];
            //            };
            //            cell.selectionStyle = UITableViewCellSelectionStyleNone;
            //            return cell;
            //        }
        }
        else{
            PlayVCCommentTableViewCell *cell = [PlayVCCommentTableViewCell cellWithTableView:tableView];
            cell.commentCellType = CommentCellTypeNewsDetail;
            PlayVCCommentFrameModel *frameModel = self.pinglunArr[indexPath.row - 1];
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
            cell.hideZanBtn = YES;
            cell.frameModel = frameModel;
            return cell;
        }
    }else{
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"play_speed_cell"];
        if (cell == nil) {
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"play_speed_cell"];
        }
        cell.textLabel.font = CUSTOM_FONT_TYPE(15.0);
        cell.accessoryType = UITableViewCellAccessoryNone;
        RTLog(@"%f",[self.speedArray[indexPath.row] floatValue]);
        if ([self.speedArray[indexPath.row] isEqualToString:@"0.666667"]) {
            cell.textLabel.text = @"0.7倍速";
        }else if ([self.speedArray[indexPath.row] floatValue] == 1.0) {
            cell.textLabel.text = @"正常倍速";
        }else if ([self.speedArray[indexPath.row] floatValue] == 1.25) {
            cell.textLabel.text = @"1.25倍速";
        }else if ([self.speedArray[indexPath.row] floatValue] == 1.5) {
            cell.textLabel.text = @"1.5倍速";
        }else if ([self.speedArray[indexPath.row] floatValue] == 2.0) {
            cell.textLabel.text = @"2倍速";
        }else if ([self.speedArray[indexPath.row] floatValue] == 3.0) {
            cell.textLabel.text = @"3倍速";
        }
        if ([[CommonCode readFromUserD:@"play_rate"] floatValue] == [self.speedArray[indexPath.row] floatValue]) {
            cell.accessoryType = UITableViewCellAccessoryCheckmark;
        }else{
            cell.accessoryType = UITableViewCellAccessoryNone;
        }
        return cell;
    }
}
#pragma mark - table delegate
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if ([tableView isEqual:self.tableView]) {
        if (indexPath.row >= 1) {
            //TODO:删除自己的评论 或者回复、复制
            PlayVCCommentFrameModel *frameModel = self.pinglunArr[indexPath.row - 3];
            PlayVCCommentModel *model = frameModel.model;
            NSDictionary *userInfo = [CommonCode readFromUserD:@"dangqianUserInfo"];
            NSString *currentUserID = userInfo[@"results"][@"id"];
            if ([currentUserID isEqualToString:model.uid]) {
                [UIActionSheet actionSheetWithTitle:nil message:nil buttons:@[@"删除", @"复制"] showInView:self.view onDismiss:^(int buttonIndex) {
                    if (buttonIndex == 0) {
                        [NetWorkTool delCommentWithaccessToken:[DSE encryptUseDES:ExdangqianUser] comment_id:model.playCommentID sccess:^(NSDictionary *responseObject)
                         {
                             [self getCommentList];
                             
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
                        if ([[CommonCode readFromUserD:@"isLogin"] boolValue] == YES)
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
    }else{
        //倍数弹窗退出
        [_alertView coverClick];
        //把倍数写入播放器和本地
        [ZRT_PlayerManager manager].playRate = [self.speedArray[indexPath.row] floatValue];
        [CommonCode writeToUserD:@([ZRT_PlayerManager manager].playRate) andKey:@"play_rate"];
        [tableView reloadData];
    }
}
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if ([tableView isEqual:self.tableView]) {
        if (indexPath.row == 0) {
            PlayVCTextContentCellFramesModel *frameModel = self.textFrameModel;
            return frameModel.cellHeight;
        }
//        else if (indexPath.row == 1) {
//            return 72.0;
//        }else if (indexPath.row == 2) {
//            if (self.rewardType == RewardViewTypeNone) {
//                return 177;
//            }else{
//                return 266;
//            }
//        }
        else{
            PlayVCCommentFrameModel *frameModel = self.pinglunArr[indexPath.row - 1];
            return frameModel.cellHeight;
        }
    }else{
        return 49;
    }
}
#pragma mark - UIScrollViewDelegate

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    if (scrollView.contentOffset.y > 209.0 / 667 * SCREEN_HEIGHT) {
        [_rightBtn setImage:[UIImage imageNamed:@"title_ic_share"] forState:UIControlStateNormal];
        [_leftBtn setImage:[UIImage imageNamed:@"back"] forState:UIControlStateNormal];
        _topView.backgroundColor = [UIColor whiteColor];
        [UIView animateWithDuration:0.25 animations:^{
            _topCenterView.alpha = 1.;
        }];
    }
    else{
        [_rightBtn setImage:[UIImage imageNamed:@"title_ic_share_white"] forState:UIControlStateNormal];
        [_leftBtn setImage:[UIImage imageNamed:@"title_ic_white"] forState:UIControlStateNormal];
        _topView.backgroundColor = [UIColor clearColor];
        [UIView animateWithDuration:0.25 animations:^{
            _topCenterView.alpha = 0.;
        }];
    }
    
    //设置置顶按钮alpha
    float alpha = scrollView.contentOffset.y/(SCREEN_HEIGHT * 1.5);
    if (alpha >= 0.75) {
        alpha = 0.75;
    }else{
        alpha = alpha;
    }
    _scrollTopBtn.alpha = alpha;
    
    RTLog(@"scrollView.contentOffset.y-----%f",scrollView.contentOffset.y);
}

#pragma mark --- 打赏按钮：OJLAnimationButtonDelegate
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
#pragma mark - UIButtonAction

/**
 下载，打赏金币，评论按钮
 */
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
            [self startGCDTimerWithGoldUpload];
            
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

/**
 下载
 */
- (void)downloadAction:(UIButton *)sender
{
    if ([[ZRT_PlayerManager manager] limitPlayStatusWithPost_id:nil withAdd:NO]) {
        [self alertMessageWithVipLimit];
        return;
    }
    if ([[ZRT_PlayerManager manager] post_mpWithDownloadNewsID:self.postDetailModel.post_id] != nil) {
        XWAlerLoginView *alert = [XWAlerLoginView alertWithTitle:@"该新闻已下载过"];
        [alert show];
        return;
    }
    [SVProgressHUD showInfoWithStatus:@"开始下载"];
    [self performSelector:@selector(SVPDismiss) withObject:nil afterDelay:1.0];
    //TODO:下载单条新闻
    if ([ZRT_PlayerManager manager].currentSong) {
        NSMutableDictionary *dic = [[ZRT_PlayerManager manager].currentSong mutableCopy];
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            ProjiectDownLoadManager *manager = [ProjiectDownLoadManager defaultProjiectDownLoadManager];
            [manager insertSevaDownLoadArray:dic];
            
            WHC_Download *op = [[WHC_Download alloc]initStartDownloadWithURL:[NSURL URLWithString:dic[@"post_mp"]] savePath:manager.userDownLoadPath savefileName:[dic[@"post_mp"] stringByReplacingOccurrencesOfString:@"/" withString:@""] withObj:dic isSingleDownload:YES delegate:nil];
            [manager.downLoadQueue addOperation:op];
        });
    }else{
        XWAlerLoginView *xw = [[XWAlerLoginView alloc]initWithTitle:@"下载路径为空"];
        [xw show];
    }
}
/**
 投金币
 */
- (void)appreciateGold
{
    if ([[CommonCode readFromUserD:@"isLogin"]boolValue] == YES){
        NSDictionary *userInfo = [CommonCode readFromUserD:@"dangqianUserInfo"];
        if ([userInfo[@"results"][@"gold"] floatValue] > 0) {
            [NetWorkTool goldUseWithaccessToken:AvatarAccessToken act_id:(self.postDetailModel.post_news != nil) ? self.postDetailModel.post_news : self.post_id post_id:self.post_id gold_num:[NSString stringWithFormat:@"%ld",(long)goldTouchCount] sccess:^(NSDictionary *responseObject) {
                goldTouchCount = 0;
                if ([responseObject[status] intValue] == 1) {
                    
                    XWAlerLoginView *xw = [[XWAlerLoginView alloc]initWithTitle:responseObject[@"msg"]];
                    [xw show];
                    //投完金币 --》 获取用户信息
                    [[NSNotificationCenter defaultCenter] postNotificationName:@"updateUserInfo" object:nil];
                }else{
                    XWAlerLoginView *xw = [[XWAlerLoginView alloc]initWithTitle:responseObject[@"msg"]];
                    [xw show];
                    //设置金币数值到界面，不reloadData
                    self.appreciateNum.text = [NSString stringWithFormat:@"%ld",[self.appreciateNum.text integerValue] - goldTouchCount];
                    //投完金币 --》 获取用户信息
                    [[NSNotificationCenter defaultCenter] postNotificationName:@"updateUserInfo" object:nil];
                }
            } failure:^(NSError *error) {
                XWAlerLoginView *xw = [[XWAlerLoginView alloc]initWithTitle:@"网络错误，金币打赏失败"];
                [xw show];
                goldTouchCount = 0;
                [self loadData];
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
-(void)startGCDTimerWithGoldUpload
{
    goldTouchCount++;
    self.appreciateNum.text = [NSString stringWithFormat:@"%d",[self.appreciateNum.text intValue] + 1];
    [self stopTimer];
    NSTimeInterval period = 1.0; //设置时间间隔
    __block NSInteger uploadTime = 3.0;//上传间隔
    dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    gcd_timer = dispatch_source_create(DISPATCH_SOURCE_TYPE_TIMER, 0, 0, queue);
    dispatch_source_set_timer(gcd_timer, dispatch_walltime(NULL, 0), period * NSEC_PER_SEC, 0); //每秒执行
    dispatch_source_set_event_handler(gcd_timer, ^{
        //在这里执行事件
        RTLog(@"startGCDTimerWithGoldUpload:%ld",goldTouchCount);
        uploadTime --;
        if (uploadTime == 0) {
            uploadTime = 3.0;
            [self stopTimer];
            //通知主线程刷新
            dispatch_async(dispatch_get_main_queue(), ^{
                //回调或者说是通知主线程刷新，
                [self appreciateGold];
                RTLog(@"上传操作--次数:%ld",goldTouchCount);
            });
        }
    });
    dispatch_resume(gcd_timer);
}
-(void)stopTimer{
    if(gcd_timer){
        dispatch_source_cancel(gcd_timer);
        gcd_timer = nil;
    }
}
- (void)goldTouchSetting
{
    RTLog(@"goldTouchSetting");
    [self performSelector:@selector(appreciateGold) withObject:nil afterDelay:3.0];//3秒后点击次数清零
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
        [self.navigationController pushViewController:pinglunye animated:YES];
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
#pragma mark - 打赏Viewaction
- (void)rewardButtonAciton:(UIButton *)sender
{
    self.rewardType = RewardViewTypeReward;
    [self.tableView reloadData];
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.25 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        //获取当前cell的frame
        CGRect cellRect = [_tableView rectForRowAtIndexPath:[NSIndexPath indexPathForRow:2 inSection:0]];
        
        [self.tableView setContentOffset:CGPointMake(0, cellRect.origin.y - self.tableView.height + cellRect.size.height) animated:YES];
    });
}

- (void)lookupRewardListButton:(UIButton *)sender
{
    RewardListViewController *vc = [RewardListViewController new];
    vc.post_id = self.post_id;
    vc.act_id = self.postDetailModel.post_news;
    self.hidesBottomBarWhenPushed = YES;
    [self.navigationController pushViewController:vc animated:YES];
    
}

- (void)finalRewardButtonAciton:(OJLAnimationButton *)sender payTextField:(UITextField *)textField {
    [self.view endEditing:YES];
    if ([[CommonCode readFromUserD:@"isLogin"]boolValue] == YES){
        self.customRewardTextField = textField;
        [sender startAnimation];
    }
    else{
        [self rewardOrLoginfirst];
    }
}
- (void)rewardOrLoginfirst{
    
    UIAlertController *alertC = [UIAlertController alertControllerWithTitle:@"温馨提示" message:@"您还没有登录，登录后赞赏才有排名哦~是否去登录" preferredStyle:UIAlertControllerStyleAlert];
    [alertC addAction:[UIAlertAction actionWithTitle:@"赞赏" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action)
    {
        [rewardAnimationBtn startAnimation];
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

/**
 打赏操作，跳转支付界面
 */
- (void)rewarding{
    if (!self.postDetailModel.act.act_id) {
        XWAlerLoginView *alert = [[XWAlerLoginView alloc] initWithTitle:@"数据获取失败，请重新进入该新闻刷新数据"];
        [alert show];
        return;
    }
    PayOnlineViewController *vc = [PayOnlineViewController new];
    NSString *accesstoken = nil;
    if ([[CommonCode readFromUserD:@"isLogin"]boolValue] == YES){
        accesstoken = AvatarAccessToken;
        [NetWorkTool getListenMoneyWithaccessToken:accesstoken sccess:^(NSDictionary *responseObject) {
            RTLog(@"%@",responseObject);
            if ([responseObject[@"status"] integerValue] == 1) {
                vc.balanceCount = [responseObject[@"results"][@"listen_money"] doubleValue];
                vc.rewardCount = isCustomPay? _customRewardTextField.text.floatValue : self.rewardCount;
                vc.uid = (self.postDetailModel.post_news != nil) ? self.postDetailModel.post_news : self.postDetailModel.act.act_id;
                vc.post_id = self.post_id;
                vc.act_id = self.postDetailModel.act.act_id;
                vc.isPayClass = NO;
                [self.navigationController pushViewController:vc animated:YES];
            }
            
        } failure:^(NSError *error) {
            
        }];
    }
    else{
        accesstoken = nil;
        vc.balanceCount = 0.00;
    }
    
}

#pragma mark - UITextFieldDelegate
- (BOOL)textFieldShouldEndEditing:(UITextField *)textField{
    self.rewardCount = [textField.text floatValue];
    return YES;
}
#pragma mark - 跳转阅读原文
- (void)readOriginalEssay:(UIButton *)sender
{
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:self.postDetailModel.url]];
}
#pragma mark - 打赏调用action
- (void)selecteRewardCountAction:(UIButton *)sender buttons:(NSArray *)buttons{
    
    //TODO:打赏按钮数据
    for ( int i = 0 ; i < buttons.count; i ++ ) {
        if (i == sender.tag - 100 ) {
            UIButton *allDoneButton = buttons[i];
            [allDoneButton setBackgroundColor:gButtonRewardColor];
            [allDoneButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
            continue;
        }
        else{
            UIButton *anotherButton = buttons[i];
            [anotherButton setBackgroundColor:[UIColor whiteColor]];
            [anotherButton setTitleColor:gTextRewardColor forState:UIControlStateNormal];
            continue;
        }
    }
    isCustomPay = NO;
    DefineWeakSelf;
    switch (sender.tag - 100) {
        case 0:self.rewardCount = 1; break;
        case 1:self.rewardCount = 5;break;
        case 2:self.rewardCount = 10;break;
        case 3:self.rewardCount = 50;break;
        case 4:self.rewardCount = 100;break;
        case 5:
                isCustomPay = YES;
                [weakSelf customRewardCount];
            break;
        default:break;
    }
}
/**
 返回初始打赏控件状态
 */
- (void)backButtonAction:(UIButton *)sender
{
    self.rewardType = RewardViewTypeNone;
    [self.tableView reloadData];
}
/**
 点击自定义打赏金额按钮，刷新页面
 */
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
        _forwardBackView.frame = CGRectMake(0, IPHONE_H - 159.0 / 667 * IPHONE_H - height, SCREEN_WIDTH, height);
        _forwardBackView.backgroundColor = ColorWithRGBA(0, 0, 0, 0.5);
        
        UIButton *back = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH * 0.5, height)];
        [back setImage:[UIImage imageNamed:@"fast_back_2"] forState:UIControlStateNormal];
        [back setImage:[UIImage imageNamed:@"fast_back_blue_2"] forState:UIControlStateHighlighted];
        [back addTarget:self action:@selector(back15)];
        [_forwardBackView addSubview:back];
        
        UIButton *go = [[UIButton alloc] initWithFrame:CGRectMake(SCREEN_WIDTH * 0.5, 0, SCREEN_WIDTH * 0.5, height)];
        [go setImage:[UIImage imageNamed:@"fast_go_2"] forState:UIControlStateNormal];
        [go setImage:[UIImage imageNamed:@"fast_go_blue_2"] forState:UIControlStateHighlighted];
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
    if ([ZRT_PlayerManager manager].isPlaying) {
        [[ZRT_PlayerManager manager] pausePlay];
    }
    //调到指定时间去播放
    [[ZRT_PlayerManager manager].player seekToTime:CMTimeMake(self.sliderProgress.value > 15?self.sliderProgress.value - 15:0, 1) completionHandler:^(BOOL finished) {
        RTLog(@"拖拽结果：%d",finished);
        if (finished == YES){
            [[ZRT_PlayerManager manager] startPlay];
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
    if ([ZRT_PlayerManager manager].isPlaying) {
        [[ZRT_PlayerManager manager] pausePlay];
    }
    //调到指定时间去播放
    [[ZRT_PlayerManager manager].player seekToTime:CMTimeMake(self.sliderProgress.value + 15, 1) completionHandler:^(BOOL finished) {
        RTLog(@"拖拽结果：%d",finished);
        if (finished == YES){
            [[ZRT_PlayerManager manager] startPlay];
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
    if (tishi == 5 && !IS_IPAD) {
        if ([[CommonCode readFromUserD:NewPlayVC_GESTUER_ALERT] boolValue] == YES) {
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

            [CommonCode writeToUserD:@(NO) andKey:NewPlayVC_GESTUER_ALERT];
        }
    }

}
#pragma mark -通知- 后台系统中断音频控制

- (void)handleInterruptionHint:(NSNotification *)notification{
    NSDictionary *info = notification.userInfo;
    AVAudioSessionInterruptionType hintType = [info[AVAudioSessionSilenceSecondaryAudioHintTypeKey] unsignedIntegerValue];
    if (hintType == AVAudioSessionSilenceSecondaryAudioHintTypeBegin) {//别的应用占用session
        //Handle InterruptionBegan
        //系统暂停音频，则设置暂停播放器
        RTLog(@"interruptionTypeBegan");
        [[ZRT_PlayerManager manager] pausePlay];
    }
}

- (void)handleInterruption:(NSNotification *)notification{
    NSDictionary *info = notification.userInfo;
    AVAudioSessionInterruptionType type = [info[AVAudioSessionInterruptionTypeKey] unsignedIntegerValue];
    if (type == AVAudioSessionInterruptionTypeBegan) {//中断开始
        //Handle InterruptionBegan
        //系统暂停音频，则设置暂停播放器
        RTLog(@"interruptionTypeBegan");
        [[ZRT_PlayerManager manager] pausePlay];
    }else{
        RTLog(@"interruptionTypeEnd");
        AVAudioSessionInterruptionOptions options = [info[AVAudioSessionInterruptionOptionKey] unsignedIntegerValue];
        if (options == AVAudioSessionInterruptionOptionShouldResume) {
            //Handle Resume 重新开始播放
            [[ZRT_PlayerManager manager] pausePlay];
        }
    }
}
#pragma mark - 线控方法
- (void)remoteControlReceivedWithEvent:(UIEvent *)event {
    //判断是否是后台音频
    if (event.type == UIEventTypeRemoteControl||event.type == UIEventTypeTouches) {
        switch (event.subtype) {
                
            case UIEventSubtypeRemoteControlPlay:
                //开始播放
                [[ZRT_PlayerManager manager] startPlay];
                break;
            case UIEventSubtypeRemoteControlTogglePlayPause:
                //暂停
                [[ZRT_PlayerManager manager] pausePlay];
                break;
            case UIEventSubtypeRemoteControlStop:
                //暂停
                [[ZRT_PlayerManager manager] pausePlay];
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
                //暂停
                [[ZRT_PlayerManager manager] pausePlay];
                break;
        }
    }
}
#pragma mark -通知- 拔插耳机线方法
/**
 *  一旦输出改变则执行此方法
 *
 *  @param notification 输出改变通知对象
 */
-(void)routeChange:(NSNotification *)notification{
    NSDictionary *interuptionDict = notification.userInfo;
    
    NSInteger routeChangeReason = [[interuptionDict valueForKey:AVAudioSessionRouteChangeReasonKey] integerValue];
    
    switch (routeChangeReason) {
            
        case AVAudioSessionRouteChangeReasonNewDeviceAvailable:
            // 耳机插入
            break;
            
        case AVAudioSessionRouteChangeReasonOldDeviceUnavailable:
        {
            // 耳机拔掉
            // 拔掉耳机继续播放
            [[ZRT_PlayerManager manager] startPlay];
        }
            break;
            
        case AVAudioSessionRouteChangeReasonCategoryChange:
            // called at start - also when other audio wants to play
            NSLog(@"AVAudioSessionRouteChangeReasonCategoryChange");
            break;
    }
}
#pragma mark -通知- 播放状态改变
- (void)playStatusChange:(NSNotification *)note
{
    switch ([ZRT_PlayerManager manager].status) {
        case ZRTPlayStatusPlay:
            bofangCenterBtn.selected = YES;
            break;
            
        case ZRTPlayStatusPause:
            bofangCenterBtn.selected = NO;
            break;
        case ZRTPlayStatusStop:
            bofangCenterBtn.selected = NO;
            break;
        default:
            break;
    }
}

#pragma mark -通知- 网络状态改变通知
/**
 监听网络改变方法
 */
- (void)networkChange
{
    if ([[SuNetworkMonitor monitor] isWiFiEnable]) {//网络切换为WiFi
        RTLog(@"wifi");
    }else if([[SuNetworkMonitor monitor] isNetworkEnable]){//网络切换为手机网络
        RTLog(@"iphone network");
    }else{
        RTLog(@"no network");
    }
}
#pragma mark -通知- 刷新评论数据
/**
 刷新评论数据
 */
- (void)pinglunchenggong:(NSNotification *)notification{
    
    [self getCommentList];
}

#pragma mark - 控件事件action
static NSInteger touchCount = 0;
static NSInteger goldTouchCount = 0;
/**
 播放/暂停
 */
- (void)playPauseClicked:(UIButton *)sender
{
    if ([ZRT_PlayerManager manager].currentSong) {
        [APPDELEGATE configNowPlayingCenter];
    }
    if ([[ZRT_PlayerManager manager] limitPlayStatusWithPost_id:nil withAdd:NO] &&![ZRT_PlayerManager manager].isPlaying) {
        //播放第五条暂停时，可以继续播放
//        int limitTime = [[CommonCode readFromUserD:limit_time] intValue];
//        int limitNum = [[CommonCode readFromUserD:limit_num] intValue];
        BOOL isStopPlay = YES;
        NSArray *limitArray = [CommonCode readFromUserD:limit_array];
        for (NSString *post_id in limitArray) {
            if ([post_id isEqualToString:self.post_id]) {
                isStopPlay = NO;
            }
        }
        if (isStopPlay) {
            [self alertMessageWithVipLimit];
            return;
        }
    }
    if ([ZRT_PlayerManager manager].isPlaying) {//点击暂停
        //上传课堂播放数据
//        if ([ZRT_PlayerManager manager].playType == ZRTPlayTypeClassroom) {
//            [[ZRT_PlayerManager manager].studyRecordTimer pauseCount];
            [[ZRT_PlayerManager manager] uploadClassPlayHistoryData];
//        }
        [[ZRT_PlayerManager manager] pausePlay];
        sender.selected = NO;
    }else{//点击播放
        [[UIDevice currentDevice] setProximityMonitoringEnabled:[[NSUserDefaults standardUserDefaults] boolForKey:@"shoushi"]];
        [[ZRT_PlayerManager manager] startPlay];
        sender.selected = YES;
    }
}
/**
 上一首
 */
- (void)bofangLeftAction:(UIButton *)sender
{
    //判断限制状态，记录次数限制
    if ([[ZRT_PlayerManager manager] limitPlayStatusWithPost_id:nil withAdd:NO]) {
        [self alertMessageWithVipLimit];
        return;
    }
    touchCount++;
    if(touchCount==1)
    {
        //清空跳转播放时间数据
        self.starDate = 0;
        //播放上一首
        BOOL isfirst = [[ZRT_PlayerManager manager] previousSong];
        //上传课堂播放数据
        [[ZRT_PlayerManager manager] uploadClassPlayHistoryData];
        if ([ZRT_PlayerManager manager].playType == ZRTPlayTypeClassroom) {
//            [[ZRT_PlayerManager manager].studyRecordTimer pauseCount];
            [ZRT_PlayerManager manager].act_sub_id = [ZRT_PlayerManager manager].currentSong[@"id"];
            //设置开始播放时间
            [NewPlayVC shareInstance].starDate = [[ZRT_PlayerManager manager].currentSong[@"play_time"] intValue];
        }
        //已经是第一首，则不往下执行
        if (isfirst) {
            return;
        }
        //保存当前播放新闻的ID
        [self saveCurrentPlayNewsID];
        //设置详情模型
        self.postDetailModel = [newsDetailModel new];
        //设置模型数据，从播放器中获取对应正在播放的数据赋值新闻模型
        [self setPostDetailModelDataFormPlayManager];
        //获取详情数据
        [self loadData];
        //获取评论数据
        [self getCommentList];
        

        
        [self performSelector:@selector(timeSetting) withObject:nil afterDelay:0.5];//1秒后点击次数清零
    }
    else
    {
        [self performSelector:@selector(timeSetting) withObject:nil afterDelay:0.5];//1秒后点击次数清零
    }
}
/**
 下一首
 */
- (void)bofangRightAction:(UIButton *)sender
{
    //判断限制状态，记录次数限制
    if ([[ZRT_PlayerManager manager] limitPlayStatusWithPost_id:nil withAdd:NO]) {
        [self alertMessageWithVipLimit];
        return;
    }
    touchCount++;
    if(touchCount==1)
    {
        //清空跳转播放时间数据
        self.starDate = 0;
        //播放下一首
        BOOL isLast = [[ZRT_PlayerManager manager] nextSong];
        //上传课堂播放数据
        [[ZRT_PlayerManager manager] uploadClassPlayHistoryData];
        if ([ZRT_PlayerManager manager].playType == ZRTPlayTypeClassroom) {
//            [[ZRT_PlayerManager manager].studyRecordTimer pauseCount];
            [ZRT_PlayerManager manager].act_sub_id = [ZRT_PlayerManager manager].currentSong[@"id"];
            //设置开始播放时间
            [NewPlayVC shareInstance].starDate = [[ZRT_PlayerManager manager].currentSong[@"play_time"] intValue];
        }
        //已经是最后一首，则不往下执行
        if (isLast) {
            return;
        }
        //设置详情模型
        self.postDetailModel = [newsDetailModel new];
        //保存当前播放新闻的ID
        [self saveCurrentPlayNewsID];
        //设置模型数据，从播放器中获取对应正在播放的数据赋值新闻模型
        [self setPostDetailModelDataFormPlayManager];
        //获取详情数据
        [self loadData];
        //获取评论数据
        [self getCommentList];

        //添加手势控制
//        [self setGestureControl];
        
        [self performSelector:@selector(timeSetting) withObject:nil afterDelay:0.5];//1秒后点击次数清零
    }
    else
    {
        [self performSelector:@selector(timeSetting) withObject:nil afterDelay:0.5];//1秒后点击次数清零
    }
}
-(void)timeSetting
{
    touchCount=0;
}
/**
 主播详情页面点击列表播放按钮调用
 */
- (void)achorVCDidClickedListPlayBtn
{
    DefineWeakSelf
    [ZRT_PlayerManager manager].playDidEnd = ^(NSInteger currentSongIndex) {
        
        //设置详情模型
        weakSelf.postDetailModel = [newsDetailModel new];
        //保存当前播放新闻的ID
        [weakSelf saveCurrentPlayNewsID];
        //设置模型数据，从播放器中获取对应正在播放的数据赋值新闻模型
        [weakSelf setPostDetailModelDataFormPlayManager];
        //获取详情数据
        [weakSelf loadData];
        //获取评论数据
        [weakSelf getCommentList];
    };
}
/**
 选中播放对应index的音频
 
 @param index 对应index
 */
- (void)playFromIndex:(NSInteger)index
{
    //判断限制状态，记录次数限制
    if ([[ZRT_PlayerManager manager] limitPlayStatusWithPost_id:nil withAdd:NO]) {
        if ([[ZRT_PlayerManager manager] post_mpWithDownloadNewsID:self.post_id] == nil) {
            [[ZRT_PlayerManager manager] pausePlay];
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                [self alertMessageWithVipLimit];
                return;
            });
        }
    }
    
    //设置播放器数据
    [[ZRT_PlayerManager manager] loadSongInfoFromIndex:index];
    //设置详情模型
    self.postDetailModel = [newsDetailModel new];
    //保存当前播放新闻的ID
    [self saveCurrentPlayNewsID];
    //设置模型数据，从播放器中获取对应正在播放的数据赋值新闻模型
    [self setPostDetailModelDataFormPlayManager];
    //设置界面数据
    [self loadData];
    //获取评论列表
    [self getCommentList];
}

/**
 弹窗提示已听完每日限制，需要购买会员才能继续收听
 */
- (void)alertMessageWithVipLimit
{
    UIAlertController *qingshuruyonghuming = [UIAlertController alertControllerWithTitle:@"温馨提示" message:[NSString stringWithFormat:@"您还不是会员，每日可收听的%@条已听完，是否前往开通会员，收听更多资讯",[CommonCode readFromUserD:[NSString stringWithFormat:@"%@",limit_num]]] preferredStyle:UIAlertControllerStyleAlert];
    [qingshuruyonghuming addAction:[UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
    }]];
    [qingshuruyonghuming addAction:[UIAlertAction actionWithTitle:@"前往开通会员" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        if ([[CommonCode readFromUserD:@"isLogin"] boolValue] == YES) {
            MyVipMenbersViewController *MyVip = [MyVipMenbersViewController new];
            [self.navigationController pushViewController:MyVip animated:YES];
        }else{
            LoginVC *loginFriVC = [LoginVC new];
            loginFriVC.isFormDownload = YES;
            LoginNavC *loginNavC = [[LoginNavC alloc]initWithRootViewController:loginFriVC];
            [loginNavC.navigationBar setBackgroundColor:[UIColor whiteColor]];
            loginNavC.navigationBar.tintColor = [UIColor blackColor];
            [self presentViewController:loginNavC animated:YES completion:nil];
            _isShowVipTipsFromLogin = YES;
        }
    }]];
    
    [self presentViewController:qingshuruyonghuming animated:YES completion:nil];
}
/**
 设置模型数据，从播放器中获取对应正在播放的数据赋值新闻模型
 */
- (void)setPostDetailModelDataFormPlayManager
{
    Exact_id = nil;
    [CommonCode writeToUserD:nil andKey:@"Exact_id"];
    
    _postDetailModel = [newsDetailModel mj_objectWithKeyValues:[ZRT_PlayerManager manager].currentSong];
    if ([ZRT_PlayerManager manager].channelType == ChannelTypeMineCollection) {
        _post_id = [ZRT_PlayerManager manager].currentSong[@"post_id"];
    }else{
        _post_id = [ZRT_PlayerManager manager].currentSong[@"id"];
    }
    _postDetailModel.post_id = [ZRT_PlayerManager manager].currentSong[@"id"];
    newsActModel *act = [newsActModel mj_objectWithKeyValues:[ZRT_PlayerManager manager].currentSong[@"post_act"]];
    _postDetailModel.act = act;
    
    //设置新闻内容详情的frame数据
    [self setFrameModel];
    //设置详情头部数据
    [self setupTableViewHeaderData];
    
    //设置进度条最大值
    self.sliderProgress.maximumValue = [_postDetailModel.post_time intValue] / 1000;
    //设置进度条初始值
    self.sliderProgress.value = 0.;
    //缓冲进度条清空
    [self.prgBufferProgress setProgress:0. animated:NO];
    //滚动到顶部
    [self.tableView setContentOffset:CGPointMake(0, IS_IPHONEX?-44:-20) animated:NO];
    
    [self.tableView reloadData];
    
    //设置音乐锁屏界面
    [[AppDelegate delegate] configNowPlayingCenter];
}

/**
 记录当前播放新闻的ID
 */
- (void)saveCurrentPlayNewsID
{
    //切换新闻ID
    self.post_id = [ZRT_PlayerManager manager].songList[[ZRT_PlayerManager manager].currentSongIndex][@"id"];
    if (self.post_id == nil) {
        return;
    }
    //当前播放新闻ID
    [CommonCode writeToUserD:self.post_id andKey:dangqianbofangxinwenID];
    //保存已听过新闻的ID数据
    [self.listenedNewsIDArray addObject:self.post_id];
    NSSet *set = [NSSet setWithArray:self.listenedNewsIDArray];
    self.listenedNewsIDArray = [NSMutableArray arrayWithArray:[set allObjects]];
}

/**
 刷新视图界面
 */
- (void)reloadInterface
{
    //滚动到顶部
    [self.tableView setContentOffset:CGPointMake(0, IS_IPHONEX?-44:-20) animated:YES];
    //重新刷新界面
    [self.tableView reloadData];
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
    dangqianTime.text = @"00:00";
    self.yinpinzongTime.text = [self convertStringWithTime:[self.postDetailModel.post_time floatValue] / 1000.0];
}
- (void)back{
    self.isFormClass = NO;
    [self.navigationController popViewControllerAnimated:YES];
    //上传播放记录
    [[ZRT_PlayerManager manager] uploadClassPlayHistoryData];
}
- (void)rightSwipeAction:(UIGestureRecognizer *)gesture
{
    [self.navigationController popViewControllerAnimated:YES];
    //上传播放记录
    [[ZRT_PlayerManager manager] uploadClassPlayHistoryData];
}
- (void)SVPDismiss
{
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
- (void)doChangeProgress:(UISlider *)sender
{
    //调到指定时间去播放
    if ([ZRT_PlayerManager manager].player.status == AVPlayerStatusReadyToPlay) {//防止未缓冲完成进行拖拽报错：AVPlayerItem cannot service a seek request with a completion handler until its status is AVPlayerItemStatusReadyToPlay
        
        //显示快进后退按钮
        if (!isShowfastBackView) {
            [self showForwardBackView];
            
            isShowfastBackView = YES;
            [self attAction];
        }
        [[ZRT_PlayerManager manager].player seekToTime:CMTimeMake(self.sliderProgress.value, [ZRT_PlayerManager manager].playRate) completionHandler:^(BOOL finished) {
            RTLog(@"拖拽结果：%d",finished);
            if (finished == YES){
                [[ZRT_PlayerManager manager] startPlay];
            }
        }];
        [[UIDevice currentDevice] setProximityMonitoringEnabled:[[NSUserDefaults standardUserDefaults] boolForKey:@"shoushi"]];
    }else{
        XWAlerLoginView *alert = [XWAlerLoginView alertWithTitle:@"请等待音频缓冲完成"];
        [alert show];
    }
}
/**
 开始拖拽进度条调用
 */
- (void)sliderTouchDown:(UISlider *)sender
{
    //显示快进后退按钮
    if (!isShowfastBackView) {
        [self showForwardBackView];
        
        isShowfastBackView = YES;
        [self attAction];
    }
    //暂停播放
    if ([ZRT_PlayerManager manager].isPlaying) {
        [[ZRT_PlayerManager manager] pausePlay];
    }
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
        if (bofangfenxiangBtn.selected) {
            [NetWorkTool del_collectionWithaccessToken:AvatarAccessToken post_id:self.post_id sccess:^(NSDictionary *responseObject) {
                if ([responseObject[@"status"] integerValue] == 1) {
                    bofangfenxiangBtn.selected = NO;
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
                    bofangfenxiangBtn.selected = YES;
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
- (void)zhuboBtnVAction:(UITapGestureRecognizer *)tap
{
    //无主播数据时不跳转主播页面
    if (!self.postDetailModel.act) {
        return;
    }
    if (self.isFormClass) {
        [self.navigationController popViewControllerAnimated:YES];
    }else{
        zhuboXiangQingVCNewController *zhubo = [zhuboXiangQingVCNewController new];
        zhubo.jiemuDescription = self.postDetailModel.act.Description;
        zhubo.jiemuFan_num = self.postDetailModel.act.fan_num;
        zhubo.jiemuID = (self.postDetailModel.post_news != nil) ? self.postDetailModel.post_news : self.postDetailModel.act.act_id;
        zhubo.jiemuImages = self.postDetailModel.act.images;
        zhubo.jiemuIs_fan = self.postDetailModel.act.is_fan;
        zhubo.jiemuMessage_num = self.postDetailModel.act.message_num;
        zhubo.jiemuName = self.postDetailModel.act.name;
        zhubo.isClass = self.isFormClass;
        zhubo.isbofangye = YES;
        [self.navigationController pushViewController:zhubo animated:YES];
    }
}
/**
 关注主播按钮点击
 */
- (void)guanzhuBtnAction:(UIButton *)sender{
    if ([[CommonCode readFromUserD:@"isLogin"]boolValue] == YES){
        if (sender.selected == NO){
            [NetWorkTool postPaoGuoGuanZhuWithaccessToken:[DSE encryptUseDES:ExdangqianUser] andact_id:self.postDetailModel.act.act_id sccess:^(NSDictionary *responseObject) {
                [sender setTitle:@"取消" forState:UIControlStateNormal];
                _postDetailModel.act.is_fan = @"1";
                _guanzhuBtn.selected = YES;
                _guanzhuBtnNav.selected = YES;
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
                _postDetailModel.act.is_fan = @"0";
                _guanzhuBtn.selected = NO;
                _guanzhuBtnNav.selected = NO;
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
                NSURL *url = [NSURL URLWithString:NEWSSEMTPHOTOURL(_postDetailModel.smeta)];
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
                NSString *contentURLStr = [NSString stringWithFormat:@"http://tingwen.me/index.php/article/yulan/id/%@.html",_postDetailModel.post_id];
                strCount = [CommonCode countWord:contentURLStr];
                
                strCount += [CommonCode countWord:_postDetailModel.post_title];
                
                strCount += [CommonCode countWord:@"【】详情内容：..... 收听地址："];
                
                NSInteger RemainingCount = 137 - strCount;
                if (RemainingCount < 0) {
                    RemainingCount = 0;
                }
                NSInteger contentCount = [CommonCode countWord:_postDetailModel.post_excerpt];
                NSString *contentStr = [_postDetailModel.post_excerpt substringWithRange:NSMakeRange(0, contentCount > RemainingCount ? RemainingCount : contentCount)];
                
                //创建消息的文本内容
                NSString *shareContent = [NSString stringWithFormat:@"【%@】详情内容：%@..... 收听地址：%@", _postDetailModel.post_title, contentStr, contentURLStr];
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
                gr.string                                    = [NSString stringWithFormat:@"http://tingwen.me/index.php/article/yulan/id/%@.html",_postDetailModel.post_id];
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
    
    [self getImageWithURLStr:NEWSSEMTPHOTOURL(_postDetailModel.smeta) OnSucceed:^(UIImage *image) {
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
            NSString *url = [NSString stringWithFormat:@"http://tingwen.me/index.php/article/yulan/id/%@.html",_postDetailModel.post_id];
            
            //音乐播放的网络流媒体地址
            NSString *flashURL = _postDetailModel.post_mp;
            QQApiAudioObject *audioObj =[QQApiAudioObject
                                         objectWithURL :[NSURL URLWithString:url]
                                         title:_postDetailModel.post_title
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
            
            [self getImageWithURLStr:NEWSSEMTPHOTOURL(_postDetailModel.smeta) OnSucceed:^(UIImage *image) {
                
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
                NSString *url = [NSString stringWithFormat:@"http://tingwen.me/index.php/article/yulan/id/%@.html",_postDetailModel.post_id];
                
                //音乐播放的网络流媒体地址
                NSString *flashURL = _postDetailModel.post_mp;
                QQApiAudioObject *audioObj =[QQApiAudioObject
                                             objectWithURL :[NSURL URLWithString:url]
                                             title:_postDetailModel.post_title
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
    message.title = _postDetailModel.post_title;
    message.description = @"";
    NSString *musicUrl = [NSString stringWithFormat:@"http://api.tingwen.me/index.php/article/yulan/id/%@.html",_postDetailModel.post_id];
    //    NSString *musicUrl = @"https://zhidao.baidu.com/question/2143697514695119428.html";
    
    [self getImageWithURLStr:NEWSSEMTPHOTOURL(_postDetailModel.smeta) OnSucceed:^(UIImage *image) {
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
            ext.musicDataUrl = _postDetailModel.post_mp;
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
            
            [self getImageWithURLStr:NEWSSEMTPHOTOURL(_postDetailModel.smeta) OnSucceed:^(UIImage *image) {
                
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
                ext.musicDataUrl = _postDetailModel.post_mp;
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
#pragma mark -通知- 支付宝支付成功回调
- (void)aliPayResultsBack:(NSNotification *)notification {
    
    NSString* title=@"PaySuccess1",*msg=@"您已赞赏成功",*sureTitle=@"确定" , *cancelTitle=@"取消吧";
    AKAlertView* av;
    
    NSDictionary *resultDic = notification.object;
    if ([resultDic[@"resultStatus"]integerValue] == 9000) {
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
#pragma mark -通知- 微信支付成功回调
- (void)WechatPayResultsBack:(NSNotification *)notification{
    NSString* title=@"PaySuccess1",*msg=@"您已赞赏成功",*sureTitle=@"确定" , *cancelTitle=@"取消吧";
    AKAlertView* av;
    if ([notification.object integerValue] == 0) {
        title=@"PaySuccess1",msg=@"您已赞赏成功",sureTitle=@"确定";
        av= [AKAlertView alertView:title des:msg  type:AKAlertSuccess effect:AKAlertEffectDrop sureTitle:sureTitle cancelTitle:cancelTitle];
    }
    else if ([notification.object integerValue] == -2){
        title=@"PayFail1";msg=@"用户中途取消，请稍后再试";sureTitle=@"确定";
        av= [AKAlertView alertView:title des:msg  type:AKAlertFaild effect:AKAlertEffectDrop sureTitle:sureTitle cancelTitle:cancelTitle];
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
#pragma mark -通知- 听币支付成功回调
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
#pragma mark - 登录弹窗
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
/**
 转换秒数为时间格式字符串
 */
- (NSString *)convertStringWithTime:(float)time
{
    if (isnan(time)) time = 0.f;
    int min = time / 60.0;
    int sec = time - min * 60;
    NSString * minStr = min > 9 ? [NSString stringWithFormat:@"%d",min] : [NSString stringWithFormat:@"0%d",min];
    NSString * secStr = sec > 9 ? [NSString stringWithFormat:@"%d",sec] : [NSString stringWithFormat:@"0%d",sec];
    NSString * timeStr = [NSString stringWithFormat:@"%@:%@",minStr, secStr];
    return timeStr;
}
@end
