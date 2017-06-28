//
//  ClassViewController.m
//  kuangjiaTingWen
//
//  Created by Zhimi on 17/4/13.
//  Copyright © 2017年 zhimi. All rights reserved.
//

#import "ClassViewController.h"
#import "UIView+tap.h"
#import "gerenzhuyeVC.h"
#import "UIActionSheet+MKBlockAdditions.h"
#import "bofangVC.h"
#import "YJImageBrowserView.h"
#import "LoginVC.h"
#import "LoginNavC.h"
#import "PayOnlineViewController.h"
#import "CommentViewController.h"
#import "AppDelegate.h"

static NSString *const playList = @"playList";/**<当前正在播放的课堂试听列表*/
static NSString *const playAct_id = @"playAct_id";/**<当前正在播放的课堂ID*/

@interface ClassViewController ()<UITableViewDelegate,UITableViewDataSource,UITextViewDelegate,TTTAttributedLabelDelegate,UITextFieldDelegate>{
    UIView *xiangqingView;
    UILabel *PingLundianzanNumLab;
    NSInteger playIndex;
//    NSString *currentClassID;
    UITextView *zhengwenTextView;
    NSString *rewardMoney;
    NSString *orderNum;
    
    //提交信息输入框
    UITextField *nameTextField;
    UITextField *phoneTextField;
    UITextField *wxTextField;
    UITextField *cityTextField;
    UITextField *jobTextField;
}
@property (strong, nonatomic) CustomAlertView *alertView;
@property (nonatomic, strong) NSMutableArray *buttons;
@property (nonatomic, strong) NSMutableArray *dataSourceArr;
@property (nonatomic, strong) NSMutableArray *playShiTingListArr;
@property (nonatomic, strong) NSMutableArray *pinglunArr;
//@property (nonatomic, strong) NSMutableDictionary *auditionResult;
@property (strong, nonatomic) ClassModel *classModel;
@property (strong, nonatomic) NSMutableArray *frameArray;
@property (nonatomic, strong) UILabel *label;
@property (strong, nonatomic) UIView *topView;
@property (strong, nonatomic) UIButton *leftBtn;
@property (strong, nonatomic) UIButton *collectBtn;
@property (strong, nonatomic) UIButton *auditionnBtn;
@property (strong, nonatomic) UIButton *purchaseBtn;
@property (strong, nonatomic) UILabel *priceLabel;
@property (strong, nonatomic) UILabel *spriceLabel;
@property (strong, nonatomic) NSMutableArray *ImageSizeArr;
@property (weak, nonatomic) UIScrollView *scrollView;
@property (weak, nonatomic) UIImageView *lastImageView;
@property (assign, nonatomic) CGRect originalFrame;
//@property (strong, nonatomic) AVPlayer *voicePlayer;
@property (strong, nonatomic) AVAudioSession *session;
@property (assign, nonatomic) NSInteger playingIndex;
@property (assign, nonatomic) BOOL isVoicePlayEnd;//判断是否是播放完成回调
@property (strong, nonatomic) AVPlayer *Player;
/**
 提交已购买用户信息弹窗view
 */
@property (strong, nonatomic) UIView *alertCommitBuyUserDataView;
@property (strong, nonatomic) UIButton *cover;
@end

static ClassViewController *_instance = nil;
static AVPlayer *_instancePlay = nil;
@implementation ClassViewController
- (AVPlayer *)Player
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _instancePlay = [[AVPlayer alloc]init];
    });
    return _instancePlay;
}
+ (instancetype)shareInstance {
    static dispatch_once_t onceToken ;
    dispatch_once(&onceToken, ^{
        _instance = [[self alloc] init];
    }) ;
    return _instance ;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.titleFontSize = [[CommonCode readFromUserD:TitleFontSize] floatValue]?[[CommonCode readFromUserD:TitleFontSize] floatValue]:19.0;
    [CommonCode writeToUserD:@(self.titleFontSize) andKey:TitleFontSize];
    
    [self setUpData];
    [self setUpView];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(AliPayResults:) name:@"AliPayResults" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(WechatPayResults:) name:@"WechatPayResults" object:nil];
}

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    
    self.hidesBottomBarWhenPushed = YES;
    [self.navigationController setNavigationBarHidden:YES animated:YES];
    
    ExIsClassVCPlay = YES;
    //单例模式刷新数据
    RTLog(@"act_id:%@----Exact_id:%@",self.act_id,Exact_id);
    if (![Exact_id isEqualToString:self.act_id]) {//当前为不同页面，需要重新初始化控件状态
        
        playIndex = -1;
        [self.helpTableView setContentOffset:CGPointZero animated:NO];
    }
    
    [self loadData];
    
    if ([Exact_id isEqualToString:self.act_id] && _isPlaying)
    {
        self.auditionnBtn.selected = YES;
    }else{
        self.auditionnBtn.selected = NO;
    }
    
    //自动处理键盘事件的第三方库
    IQKeyboardManager *manager = [IQKeyboardManager sharedManager];
    [manager setKeyboardDistanceFromTextField:0];
}

- (void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    [self.navigationController setNavigationBarHidden:NO animated:YES];
    //自动处理键盘事件的第三方库
    IQKeyboardManager *manager = [IQKeyboardManager sharedManager];
    [manager setKeyboardDistanceFromTextField:0];
}
- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
}
- (void)setUpData{
    _pinglunArr = [NSMutableArray new];
    _dataSourceArr = [NSMutableArray new];
    _ImageSizeArr = [NSMutableArray new];
    
    [self loadData];
    
    _isPlaying = NO;
    _playingIndex = -1;
//    ExisRigester = NO;
    //AudioSession负责应用音频的设置，比如支不支持后台，打断等等
    NSError *error;
    //设置音频会话
    self.session = [AVAudioSession sharedInstance];
    //AVAudioSessionCategoryPlayback一般用于支持后台播放
    [self.session setCategory:AVAudioSessionCategoryPlayback error:&error];
    //激活会话
    [self.session setActive:YES error:&error];
    //接收播放完毕后发出的通知
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(voicePlayEnd:) name:AVPlayerItemDidPlayToEndTimeNotification object:ExclassPlayer.currentItem];
    
}

- (void)setUpView{
    
    [self.view setBackgroundColor:[UIColor whiteColor]];
    [self.view addSubview:self.helpTableView];
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
    
    UISwipeGestureRecognizer *rightSwipe = [[UISwipeGestureRecognizer alloc]initWithTarget:self action:@selector(back)];
    [rightSwipe setDirection:UISwipeGestureRecognizerDirectionRight];
    [self.helpTableView addGestureRecognizer:rightSwipe];
    UIView *seperatorLine = [[UIView alloc]initWithFrame:CGRectMake(0, CGRectGetMaxY(self.helpTableView.frame), SCREEN_WIDTH, 1.0)];
    [seperatorLine setBackgroundColor:gThickLineColor];
    [self.view addSubview:seperatorLine];
    
//    UIView *verticalLine = [[UIView alloc]initWithFrame:CGRectMake(SCREEN_WIDTH/4, CGRectGetMaxY(self.helpTableView.frame) + 8, 1.0, 33)];
//    [verticalLine setBackgroundColor:gThickLineColor];
//    [self.view addSubview:verticalLine];
//    [self.view addSubview:self.collectBtn];
    [self.view addSubview:self.auditionnBtn];
    [self.purchaseBtn addSubview:self.priceLabel];
    [self.purchaseBtn addSubview:self.spriceLabel];
    [self.view addSubview:self.purchaseBtn];
    
}

#pragma mark - Unitilities
- (void)loadData{
    NSString *accessToken;
    if (ExdangqianUser.length == 0 || ExdangqianUser == nil){
        accessToken = nil;
    }
    else{
        accessToken = [DSE encryptUseDES:ExdangqianUser];
    }
    DefineWeakSelf;
    [NetWorkTool getAuditionListWithaccessToken:accessToken act_id:self.act_id sccess:^(NSDictionary *responseObject) {
        if ([responseObject[@"status"] integerValue] == 1) {
//            ExisRigester = NO;
            if ([responseObject[@"results"][@"shiting"] isKindOfClass:[NSArray class]]) {
                self.playShiTingListArr = responseObject[@"results"][@"shiting"];
            }
            self.classModel = [ClassModel mj_objectWithKeyValues:responseObject[@"results"]];
            self.frameArray = [self frameArrayWithClassModel:self.classModel];
            self.pinglunArr = [self pinglunFrameModelArrayWithModelArray:[PlayVCCommentModel mj_objectArrayWithKeyValuesArray:responseObject[@"results"][@"comments"]]];
            [self setTableHeadView];
            [self.helpTableView reloadData];
            
            //判断是否是纯数字
            NSString *textStr = [NSString stringWithFormat:@" ￥%@ ",[NetWorkTool formatFloat:[responseObject[@"results"][@"sprice"] floatValue]]];
            //中划线
            NSDictionary *attribtDic = @{NSStrikethroughStyleAttributeName: [NSNumber numberWithInteger:NSUnderlineStyleSingle]};
            NSMutableAttributedString *attribtStr = [[NSMutableAttributedString alloc]initWithString:textStr attributes:attribtDic];
            // 赋值
            self.spriceLabel.attributedText = attribtStr;
            self.priceLabel.text = [NSString stringWithFormat:@" ￥%@",[NetWorkTool formatFloat:[responseObject[@"results"][@"price"] floatValue]]];
            
        }
    } failure:^(NSError *error) {
        //
        [weakSelf loadData];
    }];
}

/*
 * 设置frameArray数组
 */
- (NSMutableArray *)frameArrayWithClassModel:(ClassModel *)classModel
{
    classModel = classModel?classModel:self.classModel;
    NSMutableArray *array = [NSMutableArray array];
    //课堂内容frame
    ClassContentCellFrameModel *contentFrameModel = [ClassContentCellFrameModel new];
    contentFrameModel.titleFontSize = self.titleFontSize;
    contentFrameModel.excerpt = classModel.excerpt;
    [array addObject:contentFrameModel];
    //课堂图片frame
    for (int i = 0; i<classModel.imagesArray.count; i++) {
        ClassImageViewCellFrameModel *imageFrameModel = [ClassImageViewCellFrameModel new];
        imageFrameModel.downLoadImageSuccess = ^(UIImage *image) {
            //刷新对应行的cell
            [self.helpTableView reloadRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:1 + i inSection:0]] withRowAnimation:UITableViewRowAnimationNone];
        };
        imageFrameModel.imageUrl = classModel.imagesArray[i];
        [array addObject:imageFrameModel];
    }
    //试听列表frame
    ClassAuditionCellFrameModel *auditionFrameModel = [ClassAuditionCellFrameModel new];
    auditionFrameModel.auditionArray = classModel.shiting;
    [array addObject:auditionFrameModel];
    
    return array;
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
- (void)back {
//    [ExclassPlayer pause];
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
    
    CGRect rect  = [string boundingRectWithSize:CGSizeMake(width, MAXFLOAT)
                                        options: NSStringDrawingUsesFontLeading |NSStringDrawingUsesLineFragmentOrigin
                                     attributes:@{NSFontAttributeName:fontSize}
                                        context:nil];
    return ceil(rect.size.height);
}

- (void)setTableHeadView{
    xiangqingView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, IPHONE_W, IPHONE_H)];
    xiangqingView.backgroundColor = [UIColor whiteColor];
    //新闻图片
    UIImageView *zhengwenImg = [[UIImageView alloc]initWithFrame:CGRectMake(0, -20, IPHONE_W, 209.0 / 667 * SCREEN_HEIGHT)];
    [zhengwenImg setUserInteractionEnabled:YES];
    
    UIBezierPath *maskPath = [UIBezierPath bezierPathWithRoundedRect:zhengwenImg.bounds byRoundingCorners:UIRectCornerBottomRight cornerRadii:CGSizeMake(160.0 / 667 * SCREEN_HEIGHT, 160.0 / 667 * SCREEN_HEIGHT)];
    CAShapeLayer *maskLayer = [[CAShapeLayer alloc] init];
    maskLayer.frame = zhengwenImg.bounds;
    maskLayer.path = maskPath.CGPath;
    zhengwenImg.layer.mask = maskLayer;
    
    //生成图片
    if ([NEWSSEMTPHOTOURL(self.classModel.smeta) rangeOfString:@"userDownLoadPathImage"].location != NSNotFound) {
        [zhengwenImg sd_setImageWithURL:[NSURL fileURLWithPath:NEWSSEMTPHOTOURL(self.classModel.smeta)] placeholderImage:[UIImage imageNamed:@"thumbnailsdefault"]];
    }
    else if ([NEWSSEMTPHOTOURL(self.classModel.smeta)  rangeOfString:@"http"].location != NSNotFound)
    {
        [zhengwenImg sd_setImageWithURL:[NSURL URLWithString:NEWSSEMTPHOTOURL(self.classModel.smeta)] placeholderImage:[UIImage imageNamed:@"thumbnailsdefault"]];
    }
    else{
        NSString *str = USERPHOTOHTTPSTRINGZhuBo(NEWSSEMTPHOTOURL(self.classModel.smeta));
        [zhengwenImg sd_setImageWithURL:[NSURL URLWithString:str] placeholderImage:[UIImage imageNamed:@"thumbnailsdefault"]];
    }
    
    //添加单击手势
    UITapGestureRecognizer *tapZhengwenImg = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(showZoomImageView:)];
    [zhengwenImg addGestureRecognizer:tapZhengwenImg];
    zhengwenImg.contentMode = UIViewContentModeScaleAspectFill;
    zhengwenImg.clipsToBounds = YES;
    [xiangqingView addSubview:zhengwenImg];
    
    //标题
    UILabel *titleLab = [[UILabel alloc]initWithFrame:CGRectMake(20.0 / 375 * IPHONE_W,CGRectGetMaxY(zhengwenImg.frame) + 20.0 / 667 * SCREEN_HEIGHT, IPHONE_W - 40.0 / 375 * IPHONE_W, 40.0 / 667 * IPHONE_H)];
    titleLab.text = self.classModel.title;
    titleLab.textAlignment = NSTextAlignmentCenter;
    titleLab.textColor = nTextColorMain;
    titleLab.font = [UIFont boldSystemFontOfSize:self.titleFontSize];
//    titleLab.font = [UIFont fontWithName:@"Semibold" size:19];
    CGFloat titleHight = [self computeTextHeightWithString:self.classModel.title andWidth:(SCREEN_WIDTH-20) andFontSize:gFontMain14];
    [titleLab setFrame:CGRectMake(20.0 / 375 * IPHONE_W, CGRectGetMaxY(zhengwenImg.frame) + 20.0 / 667 * SCREEN_HEIGHT, IPHONE_W - 40.0 / 375 * IPHONE_W, (titleHight + 20) / 667 * IPHONE_H)];
    [titleLab setNumberOfLines:0];
    titleLab.lineBreakMode = NSLineBreakByWordWrapping;
    [xiangqingView addSubview:titleLab];
    
    //分割线
    UIView *seperatorLine = [[UIView alloc]initWithFrame:CGRectMake(20.0 / 375 * SCREEN_WIDTH, CGRectGetMaxY(titleLab.frame) +  12.0 / 667 * SCREEN_HEIGHT, SCREEN_WIDTH - 40.0 / 375 * SCREEN_WIDTH, 1.0)];
    [seperatorLine setBackgroundColor:gThickLineColor];
    [xiangqingView addSubview:seperatorLine];
    
    xiangqingView.frame = CGRectMake(xiangqingView.frame.origin.x, xiangqingView.frame.origin.y, xiangqingView.frame.size.width, CGRectGetMaxY(seperatorLine.frame));
    self.helpTableView.tableHeaderView = xiangqingView;
    //footer
    UIButton *moreComment = [UIButton buttonWithType:UIButtonTypeCustom];
    [moreComment setFrame:CGRectMake(0, 0, SCREEN_WIDTH, 44)];
    [moreComment setTitle:@"查看更多评价" forState:UIControlStateNormal];
    [moreComment.titleLabel setFont:gFontMain14];
    [moreComment setTitleColor:gTextColorSub forState:UIControlStateNormal];
    [moreComment addTarget:self action:@selector(morecommetAction:) forControlEvents:UIControlEventTouchUpInside];
    self.helpTableView.tableFooterView = moreComment;
    
    [self.helpTableView reloadData];
}

- (void)reloadData{
    [self.helpTableView reloadData];
}

- (void)showZoomImageView:(UITapGestureRecognizer *)tap{
    if (![(UIImageView *)tap.view image]) {
        return;
    }
    [YJImageBrowserView showWithImageView:(UIImageView *)tap.view];
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

-(void)tapBgView:(UITapGestureRecognizer *)tapBgRecognizer{
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

-(UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView{
    return self.lastImageView;
}

- (void)clickPinglunImgHead:(UITapGestureRecognizer *)tapG {
    NSDictionary *components = self.pinglunArr[tapG.view.tag - 1000];
    [self skipToUserVCWihtcomponents:components];
}

- (void)skipToUserVCWihtcomponents:(NSDictionary *)components{
    gerenzhuyeVC *gerenzhuye = [gerenzhuyeVC new];
    if ([components[@"user_login"] isEqualToString:ExdangqianUser] && [[CommonCode readFromUserD:@"isLogin"]boolValue] == YES) {
        gerenzhuye.isMypersonalPage = YES;
    }
    else{
        gerenzhuye.isMypersonalPage = NO;
    }
    gerenzhuye.isNewsComment = YES;
    gerenzhuye.user_nicename = components[@"user_nicename"];
    gerenzhuye.sex = components[@"sex"];
    gerenzhuye.signature = components[@"signature"];
    gerenzhuye.user_login = components[@"user_login"];
    gerenzhuye.avatar = components[@"avatar"];
    gerenzhuye.fan_num = components[@"fan_num"];
    gerenzhuye.guan_num = components[@"guan_num"];
    gerenzhuye.user_id = components[@"uid"];
    self.hidesBottomBarWhenPushed = YES;
    [self.navigationController pushViewController:gerenzhuye animated:YES];
    self.hidesBottomBarWhenPushed = YES;
}

- (void)loginFirst {
    UIAlertController *qingshuruyonghuming = [UIAlertController alertControllerWithTitle:@"温馨提示" message:@"您还没登录，请先登录后操作" preferredStyle:UIAlertControllerStyleAlert];
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

#pragma mark - KVO
//观察者方法，用来监听播放状态
- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSString *,id> *)change context:(void *)context{
    //当播放器状态（status）改变时，会进入此判断
    if ([keyPath isEqualToString:@"statu"]){
        switch (ExclassPlayer.status) {
            case AVPlayerStatusUnknown:
                NSLog(@"KVO：未知状态，此时不能播放");
                break;
            case AVPlayerStatusReadyToPlay:
                NSLog(@"KVO：准备完毕，可以播放");
                //自动播放
                //                [ExclassPlayer play];
                break;
            case AVPlayerStatusFailed:
                NSLog(@"KVO：加载失败，网络或者服务器出现问题");
                break;
            default:
                break;
        }
    }
}

#pragma mark - NSNotification
- (void)voicePlayEnd:(NSNotification *)notice {
    if (!ExIsClassVCPlay) {
        return;
    }
    NSArray *shitingArray = [CommonCode readFromUserD:playList];
    if (_playingIndex < [shitingArray count] - 1) {
        _isVoicePlayEnd = YES;
        if (self.buttons.count == 0) {
            UIButton *nextTextMPButton = self.buttons[_playingIndex + 1];
            [self playTestMp:nextTextMPButton];
        }else{
            [self playTestMpWithIndex:_playingIndex + 1];
        }
    }
    else{
        [self performSelector:@selector(wanbi:) withObject:notice afterDelay:0.5f];
        _isPlaying = NO;
    }
}

- (void)wanbi:(NSNotification *)notice{
    
    if (!ExIsClassVCPlay) {
        return;
    }
//    if (ExisRigester == YES){
//        ExisRigester = NO;
//    }
    //设置按钮状态为未播放图片
    _auditionnBtn.selected = NO;
    for ( int i = 0 ; i < self.buttons.count; i ++ ) {
        UIButton *anotherButton = self.buttons[i];
        anotherButton.selected = NO;
        continue;
    }
    [ExclassPlayer pause];
//    [CommonCode writeToUserD:@"YES" andKey:TINGYOUQUANBOFANGWANBI];
    _isPlaying = NO;
}

//- (void)dealloc {
//    [CommonCode writeToUserD:self.act_id andKey:@"currentClassID"];
//    [CommonCode writeToUserD:[NSString stringWithFormat:@"%ld",playIndex] andKey:@"playIndex"];
//}

#pragma mark - UIButtonAction
- (void)collectBtnAction:(UIButton *)sender{
    XWAlerLoginView *xw = [[XWAlerLoginView alloc]initWithTitle:@"购买了才能订阅哦~"];
    [xw show];
}
- (void)purchaseBtnAction:(UIButton *)sender{
    
    if ([[CommonCode readFromUserD:@"isIAP"] boolValue] == YES)
    {//当前为内购路线
        [NetWorkTool get_orderWithaccessToken:AvatarAccessToken act_id:self.classModel.act_id sccess:^(NSDictionary *responseObject) {
            RTLog(@"%@",responseObject);
            if ([responseObject[@"status"] intValue] == 1) {
                APPDELEGATE.isClassPay = YES;
                rewardMoney = responseObject[@"results"][@"money"];
                orderNum = responseObject[@"results"][@"order_num"];
                [CommonCode writeToUserD:orderNum andKey:@"orderNumber"];
                _alertView = [[CustomAlertView alloc] initWithCustomView:[self setupPayAlertWithIAP:YES]];
                _alertView.alertHeight = 105;
                _alertView.alertDuration = 0.25;
                _alertView.coverAlpha = 0.6;
                [_alertView show];
            }else{
                XWAlerLoginView *xw = [[XWAlerLoginView alloc]initWithTitle:@"订单获取失败"];
                [xw show];
            }
        } failure:^(NSError *error) {
            
        }];

    }
    else
    {//当前为支付宝，微信，听币支付路线
        if ([[CommonCode readFromUserD:@"isLogin"]boolValue] == YES){
            [NetWorkTool get_orderWithaccessToken:AvatarAccessToken act_id:self.classModel.act_id sccess:^(NSDictionary *responseObject) {
                RTLog(@"%@",responseObject);
                if ([responseObject[@"status"] intValue] == 1) {
                    APPDELEGATE.isClassPay = YES;
                    rewardMoney = [NSString stringWithFormat:@"%@",responseObject[@"results"][@"money"]];
                    orderNum = responseObject[@"results"][@"order_num"];
                    [CommonCode writeToUserD:orderNum andKey:@"orderNumber"];
                    _alertView = [[CustomAlertView alloc] initWithCustomView:[self setupPayAlertWithIAP:NO]];
                    _alertView.alertHeight = 205;
                    _alertView.alertDuration = 0.25;
                    _alertView.coverAlpha = 0.6;
                    [_alertView show];
                }else{
                    XWAlerLoginView *xw = [[XWAlerLoginView alloc]initWithTitle:@"订单获取失败"];
                    [xw show];
                }
            } failure:^(NSError *error) {
                
            }];
        }
        else{
            [self loginFirst];
        }
    }
}
//创建支付弹窗view
- (UIView *)setupPayAlertWithIAP:(BOOL)iap
{
    if (iap) {
        UIView *bgView = [[UIView alloc] init];
        bgView.backgroundColor = HEXCOLOR(0xe3e3e3);
        bgView.frame = CGRectMake(0, 0, SCREEN_WIDTH, 105);
        
        UIButton *tingbiBtn = [[UIButton alloc] init];
        tingbiBtn.frame = CGRectMake(0, 0, SCREEN_WIDTH, 50);
        tingbiBtn.backgroundColor = [UIColor whiteColor];
        [tingbiBtn setImage:@"pay2"];
        tingbiBtn.imageEdgeInsets = UIEdgeInsetsMake(0, -20, 0, 0);
        [tingbiBtn setTitle:@"听币支付" forState:UIControlStateNormal];
        [tingbiBtn setTitleColor:gMainColor forState:UIControlStateNormal];
        tingbiBtn.titleLabel.font = [UIFont systemFontOfSize:17];
        [tingbiBtn addTarget:self action:@selector(tingbiBtnClicked)];
        [bgView addSubview:tingbiBtn];
        
        UIButton *cancelBtn = [[UIButton alloc] init];
        cancelBtn.frame = CGRectMake(0, 55, SCREEN_WIDTH, 50);
        cancelBtn.backgroundColor = [UIColor whiteColor];
        [cancelBtn setTitle:@"取消" forState:UIControlStateNormal];
        [cancelBtn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        cancelBtn.titleLabel.font = [UIFont systemFontOfSize:17];
        [cancelBtn addTarget:self action:@selector(cancelAlert)];
        [bgView addSubview:cancelBtn];
        
        return bgView;

    }else{
        UIView *bgView = [[UIView alloc] init];
        bgView.backgroundColor = HEXCOLOR(0xe3e3e3);
        bgView.frame = CGRectMake(0, 0, SCREEN_WIDTH, 205);
        
        UIButton *zhifubaoBtn = [[UIButton alloc] init];
        zhifubaoBtn.frame = CGRectMake(0, 0, SCREEN_WIDTH, 50);
        zhifubaoBtn.backgroundColor = [UIColor whiteColor];
        [zhifubaoBtn setImage:@"pay3"];
        zhifubaoBtn.imageEdgeInsets = UIEdgeInsetsMake(0, -20, 0, 0);
        [zhifubaoBtn setTitle:@"支付宝支付" forState:UIControlStateNormal];
        [zhifubaoBtn setTitleColor:gMainColor forState:UIControlStateNormal];
        zhifubaoBtn.titleLabel.font = [UIFont systemFontOfSize:17];
        [zhifubaoBtn addTarget:self action:@selector(zhifubaoBtnClicked)];
        [bgView addSubview:zhifubaoBtn];
        
        UIButton *weixinBtn = [[UIButton alloc] init];
        weixinBtn.frame = CGRectMake(0, 50, SCREEN_WIDTH, 50);
        weixinBtn.backgroundColor = [UIColor whiteColor];
        [weixinBtn setImage:@"pay4"];
        weixinBtn.imageEdgeInsets = UIEdgeInsetsMake(0, -20, 0, 0);
        [weixinBtn setTitle:@"微信支付" forState:UIControlStateNormal];
        [weixinBtn setTitleColor:gMainColor forState:UIControlStateNormal];
        weixinBtn.titleLabel.font = [UIFont systemFontOfSize:17];
        [weixinBtn addTarget:self action:@selector(weixinBtnClicked)];
        [bgView addSubview:weixinBtn];
        
        UIButton *tingbiBtn = [[UIButton alloc] init];
        tingbiBtn.frame = CGRectMake(0, 100, SCREEN_WIDTH, 50);
        tingbiBtn.backgroundColor = [UIColor whiteColor];
        [tingbiBtn setImage:@"pay2"];
        tingbiBtn.imageEdgeInsets = UIEdgeInsetsMake(0, -20, 0, 0);
        [tingbiBtn setTitle:@"听币支付" forState:UIControlStateNormal];
        [tingbiBtn setTitleColor:gMainColor forState:UIControlStateNormal];
        tingbiBtn.titleLabel.font = [UIFont systemFontOfSize:17];
        [tingbiBtn addTarget:self action:@selector(tingbiBtnClicked)];
        [bgView addSubview:tingbiBtn];
        
        UIButton *cancelBtn = [[UIButton alloc] init];
        cancelBtn.frame = CGRectMake(0, 155, SCREEN_WIDTH, 50);
        cancelBtn.backgroundColor = [UIColor whiteColor];
        [cancelBtn setTitle:@"取消" forState:UIControlStateNormal];
        [cancelBtn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        cancelBtn.titleLabel.font = [UIFont systemFontOfSize:17];
        [cancelBtn addTarget:self action:@selector(cancelAlert)];
        [bgView addSubview:cancelBtn];
        
        return bgView;
    }
}
//支付宝支付
- (void)zhifubaoBtnClicked
{
    [_alertView coverClick];
    PayOnlineViewController *vc = [PayOnlineViewController new];
    vc.rewardCount = [rewardMoney doubleValue];
    vc.uid = self.classModel.act_id;
    vc.post_id = self.classModel.ID;
    vc.isPayClass = YES;
    [vc AliPayWithSubject:@"听闻课程订单" body:@"听闻课程"];
}
//微信支付
- (void)weixinBtnClicked
{
    [_alertView coverClick];
    PayOnlineViewController *vc = [PayOnlineViewController new];
    vc.rewardCount = [rewardMoney doubleValue];
    vc.uid = self.classModel.act_id;
    vc.post_id = self.classModel.ID;
    vc.isPayClass = YES;
    [vc WechatPay];
}
//听币支付
- (void)tingbiBtnClicked
{
    [_alertView coverClick];
    //获取听币余额
    PayOnlineViewController *vc = [PayOnlineViewController new];
    
    [NetWorkTool getListenMoneyWithaccessToken:AvatarAccessToken sccess:^(NSDictionary *responseObject) {
        NSLog(@"%@",responseObject);
        if ([responseObject[@"status"] integerValue] == 1) {
            if ([responseObject[@"results"][@"listen_money"] doubleValue] < [rewardMoney floatValue]) {//余额不足，前往充值
                vc.balanceCount = [responseObject[@"results"][@"listen_money"] doubleValue];
                vc.rewardCount = [rewardMoney floatValue];
                vc.uid = self.classModel.act_id;
                vc.post_id = self.classModel.ID;
                vc.isPayClass = NO;
                self.hidesBottomBarWhenPushed = YES;
                [self.navigationController pushViewController:vc animated:YES];
            }else{//调用购买接口
                [NetWorkTool buyActWithaccessToken:AvatarAccessToken act_id:self.classModel.ID money:rewardMoney sccess:^(NSDictionary *responseObject) {
                    if ([responseObject[@"status"] integerValue] == 1) {
                        //购买成功，退出课堂购买界面，刷新列表
                        XWAlerLoginView *xw = [[XWAlerLoginView alloc]initWithTitle:@"课程购买成功"];
                        [xw show];
                        //上传订单
                        [NetWorkTool order_notifyWithaccessToken:AvatarAccessToken order_num:orderNum sccess:^(NSDictionary *responseObject) {
                            if ([responseObject[@"status"] integerValue] == 1) {
                                APPDELEGATE.isClassPay = NO;
                                [CommonCode writeToUserD:nil andKey:@"orderNumber"];
                                [[NSNotificationCenter defaultCenter] postNotificationName:ReloadClassList object:nil];
                                [self.navigationController popViewControllerAnimated:YES];
                            }
                        } failure:^(NSError *error) {
                            
                        }];
                    }else{
                        XWAlerLoginView *xw = [[XWAlerLoginView alloc]initWithTitle:@"课程购买失败，请重新再试"];
                        [xw show];
                    }
                } failure:^(NSError *error) {
                    
                }];
            }
        }else{
            XWAlerLoginView *xw = [[XWAlerLoginView alloc]initWithTitle:@"获取听币余额失败"];
            [xw show];
        }
    } failure:^(NSError *error) {
        
    }];

}
//取消支付弹窗
- (void)cancelAlert
{
    APPDELEGATE.isClassPay = NO;
    [_alertView coverClick];
}
//点击底部试听按钮
- (void)auditionnBtnAction:(UIButton *)sender{
//    ExisRigester = NO;
    Exact_id = self.act_id;
    [CommonCode writeToUserD:Exact_id andKey:@"Exact_id"];
    [CommonCode writeToUserD:self.playShiTingListArr andKey:playList];
    [CommonCode writeToUserD:self.act_id andKey:playAct_id];
    if (sender.selected == YES) {//选中状态，为播放状态,则将列表按钮设置全部设置为暂停
        sender.selected = NO;
        for ( int i = 0 ; i < self.buttons.count; i ++ ) {
            UIButton *anotherButton = self.buttons[i];
            anotherButton.selected = NO;
            continue;
        }
        _playingIndex = -1;
        [ExclassPlayer pause];
        _isPlaying = NO;
        [[NSNotificationCenter defaultCenter] postNotificationName:@"stopAnimate" object:nil];
    }
    else{//未选中状态，为暂停状态,判断当前播放第一个按钮，设置播放状态
        [[NSNotificationCenter defaultCenter] postNotificationName:@"startAnimate" object:nil];
        sender.selected = YES;
        for ( int i = 0 ; i < self.buttons.count; i ++ ) {
            if (i == 0) {
                UIButton *allDoneButton = [self.buttons firstObject];
                allDoneButton.selected = YES;
                continue;
            }
            else{
                UIButton *anotherButton = self.buttons[i];
                anotherButton.selected = NO;
                continue;
            }
        }
        
        if ([bofangVC shareInstance].isPlay) {
            [[bofangVC shareInstance] doplay2];
        }
        else{
            
        }
        [ExclassPlayer pause];
        
        ExclassPlayer = self.Player;
//        if (ExclassPlayer == nil) {
//            ExclassPlayer = [[AVPlayer alloc]init];
//        }
        ClassAuditionListModel *auditionModel = [self.classModel.shiting firstObject];
        [ExclassPlayer replaceCurrentItemWithPlayerItem:[[AVPlayerItem alloc]initWithURL:[NSURL URLWithString:auditionModel.s_mpurl]]];
        
        [ExclassPlayer play];
        [Explayer pause];
        _isPlaying = YES;
        _playingIndex = 0;
//        [CommonCode writeToUserD:@"YES" andKey:TINGYOUQUANBOFANGWANBI];
//        if (ExisRigester == NO){
//            ExisRigester = YES;
//        }
    }
}
//列表试听按钮点击
- (void)playTestMp:(UIButton *)sender{
    if (!_isVoicePlayEnd) {//判断不是播放完成调用该方法
        [CommonCode writeToUserD:self.playShiTingListArr andKey:playList];
        [CommonCode writeToUserD:self.act_id andKey:playAct_id];
        Exact_id = self.act_id;
        [CommonCode writeToUserD:Exact_id andKey:@"Exact_id"];
//        ExisRigester = NO;
    }
    _isVoicePlayEnd = NO;
    
    BOOL isTestMpPlay = NO;//判断是否在试听列表里面有选中的按钮正在播放
    for ( int i = 0 ; i < self.buttons.count; i ++ ) {
        UIButton *allDoneButton = self.buttons[i];
        if ([Exact_id isEqualToString:self.act_id]) {
            if (sender.tag == i) {
                allDoneButton.selected = !allDoneButton.selected;
                if (allDoneButton.selected == NO) {
                    isTestMpPlay = NO;
                }else{
                    isTestMpPlay = YES;
                }
            }
            else{
                allDoneButton.selected = NO;
            }
        }
    }
    if (isTestMpPlay) {
        [[NSNotificationCenter defaultCenter] postNotificationName:@"startAnimate" object:nil];
        [self.auditionnBtn setSelected:YES];
    }
    else{
        [[NSNotificationCenter defaultCenter] postNotificationName:@"stopAnimate" object:nil];
        [self.auditionnBtn setSelected:NO];
    }
    //播放试听音频
    if (_isPlaying && (_playingIndex == sender.tag)) {
        [ExclassPlayer pause];
        _isPlaying = NO;
    }
    else{
        if ([bofangVC shareInstance].isPlay) {
            [[bofangVC shareInstance] doplay2];
        }
        else{
            
        }
        [ExclassPlayer pause];
//        if (ExclassPlayer == nil) {
//            ExclassPlayer = [[AVPlayer alloc]init];
            //添加观察者，用来监视播放器的状态变化
//            [ExclassPlayer addObserver:self forKeyPath:@"statu" options:NSKeyValueObservingOptionNew context:nil];
            //添加观察者，用来监听播放器的缓冲进度loadedTimeRanges属性
            //            [ExclassPlayer addObserver:self forKeyPath:@"loadedTimeRanges" options:NSKeyValueObservingOptionNew context:nil];
//        }
        ExclassPlayer = self.Player;
        
        NSArray *shitingArray = [CommonCode readFromUserD:playList];
        NSDictionary *auditionModel = shitingArray[sender.tag];
        [ExclassPlayer replaceCurrentItemWithPlayerItem:[[AVPlayerItem alloc]initWithURL:[NSURL URLWithString:auditionModel[@"s_mpurl"]]]];
        [ExclassPlayer play];
        [Explayer pause];
        _isPlaying = YES;
        _playingIndex = sender.tag;
//        [CommonCode writeToUserD:@"YES" andKey:TINGYOUQUANBOFANGWANBI];
//        if (ExisRigester == NO){
            //添加观察者，用来监视播放器的状态变化
//            [ExclassPlayer addObserver:self forKeyPath:@"statu" options:NSKeyValueObservingOptionNew context:nil];
            //添加观察者，用来监听播放器的缓冲进度loadedTimeRanges属性
            //[ExclassPlayer addObserver:self forKeyPath:@"loadedTimeRange" options:NSKeyValueObservingOptionNew context:nil];
//            ExisRigester = YES;
//        }
    }
}
//列表试听按钮点击
- (void)playTestMpWithIndex:(NSInteger)index{
    if (!_isVoicePlayEnd) {//判断不是播放完成调用该方法
        [CommonCode writeToUserD:self.playShiTingListArr andKey:playList];
        [CommonCode writeToUserD:self.act_id andKey:playAct_id];
        Exact_id = self.act_id;
        [CommonCode writeToUserD:Exact_id andKey:@"Exact_id"];
        //        ExisRigester = NO;
    }
    
    _isVoicePlayEnd = NO;
    
    //播放试听音频
    if (_isPlaying && (_playingIndex == index)) {
        [ExclassPlayer pause];
        _isPlaying = NO;
    }
    else{
        if ([bofangVC shareInstance].isPlay) {
            [[bofangVC shareInstance] doplay2];
        }
        else{
            
        }
        [ExclassPlayer pause];
        ExclassPlayer = self.Player;
        
        NSArray *shitingArray = [CommonCode readFromUserD:playList];
        NSDictionary *auditionModel = shitingArray[index];
        [ExclassPlayer replaceCurrentItemWithPlayerItem:[[AVPlayerItem alloc]initWithURL:[NSURL URLWithString:auditionModel[@"s_mpurl"]]]];
        [ExclassPlayer play];
        [Explayer pause];
        _isPlaying = YES;
        _playingIndex = index;
    }
}
- (void)pinglundianzanAction:(PinglundianzanCustomBtn *)pinglundianzanBtn frameModel:(PlayVCCommentFrameModel *)frameModel
{
    PlayVCCommentModel *model = frameModel.model;
    UILabel *dianzanNumlab = pinglundianzanBtn.PingLundianzanNumLab;
    if (pinglundianzanBtn.selected == YES){
        [NetWorkTool postPaoGuoXinWenPingLunDianZanWithaccessToken:[DSE encryptUseDES:ExdangqianUser] andact_id:model.playCommentID sccess:^(NSDictionary *responseObject) {
            NSLog(@"responseObject = %@",responseObject);
            NSLog(@"针对评论取消点赞");
            dianzanNumlab.text = [NSString stringWithFormat:@"%d",[dianzanNumlab.text intValue] - 1];
            dianzanNumlab.textColor = [UIColor grayColor];
            dianzanNumlab.alpha = 0.7f;
            pinglundianzanBtn.selected = NO;
        } failure:^(NSError *error) {
            NSLog(@"error = %@",error);
        }];
    }
    else{
        [NetWorkTool postPaoGuoXinWenPingLunDianZanWithaccessToken:[DSE encryptUseDES:ExdangqianUser] andact_id:model.playCommentID sccess:^(NSDictionary *responseObject) {
            NSLog(@"responseObject = %@",responseObject);
            NSLog(@"针对评论点赞");
            dianzanNumlab.text = [NSString stringWithFormat:@"%d",[dianzanNumlab.text intValue] + 1];
            dianzanNumlab.textColor = ColorWithRGBA(0, 159, 240, 1);
            dianzanNumlab.alpha = 1.0f;
            pinglundianzanBtn.selected = YES;
        } failure:^(NSError *error) {
            NSLog(@"error = %@",error);
        }];
    }
}

-(void)morecommetAction:(UIButton *)sender{
    CommentViewController *vc = [CommentViewController new];
    vc.act_id = self.classModel.act_id;
    self.hidesBottomBarWhenPushed = YES;
    [self.navigationController pushViewController:vc animated:YES];
}
#pragma mark - UITableViewDelegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    
}

#pragma mark - UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if ([self.classModel.comments isKindOfClass:[NSArray class]]){
        if ([self.classModel.comments count] >= 3) {
            return 5 + self.classModel.imagesArray.count;
        }
        else{
            return  [self.classModel.comments count] + self.classModel.imagesArray.count + 2;
        }
    }
    else{
        return 0;
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    if (indexPath.row == 0) {
        ClassContentCellFrameModel *frameModel = self.frameArray[indexPath.row];
        return frameModel.cellHeight;
    }else if(indexPath.row > 0 && indexPath.row <= self.classModel.imagesArray.count){
        ClassImageViewCellFrameModel *frameModel = self.frameArray[indexPath.row];
        return frameModel.cellHeight;
    }else if(indexPath.row > self.classModel.imagesArray.count && (indexPath.row <= self.classModel.imagesArray.count + 1)){
        ClassAuditionCellFrameModel *frameModel = self.frameArray[indexPath.row];
        return frameModel.cellHeight;
    }else{
        PlayVCCommentFrameModel *frameModel = self.pinglunArr[indexPath.row - 2 - self.classModel.imagesArray.count];
        return frameModel.cellHeight;
    }
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    if (indexPath.row == 0) {
        ClassContentTableViewCell *cell = [ClassContentTableViewCell cellWithTableView:tableView];
        cell.titleFontSize = self.titleFontSize;
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        cell.frameModel = self.frameArray[indexPath.row];
        return cell;
    }else if(indexPath.row > 0 && indexPath.row <= self.classModel.imagesArray.count){
        ClassImageViewTableViewCell *cell = [ClassImageViewTableViewCell cellWithTableView:tableView];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        cell.frameModel = self.frameArray[indexPath.row];
        cell.tapImage = ^(UITapGestureRecognizer *tap) {
            [self showZoomImageView:tap];
        };
        return cell;
    }else if(indexPath.row > self.classModel.imagesArray.count && (indexPath.row <= self.classModel.imagesArray.count + 1)){
        ClassAuditionTableViewCell *cell = [ClassAuditionTableViewCell cellWithTableView:tableView];
        if ([Exact_id isEqualToString:self.act_id] && _isPlaying) {
            cell.playingIndex = _playingIndex;
        }else{
            cell.playingIndex = -1;
        }
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        cell.frameModel = self.frameArray[indexPath.row];
//        [self.buttons removeAllObjects];
        self.buttons = cell.buttons;
        MJWeakSelf
        cell.playAudition = ^(UIButton *button, NSMutableArray *buttons) {
            //点击试听列表按钮
            [weakSelf playTestMp:button];
        };
        return cell;
    }else{
        PlayVCCommentTableViewCell *cell = [PlayVCCommentTableViewCell cellWithTableView:tableView];
        cell.isClassComment = YES;
        cell.hideZanBtn = YES;
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        PlayVCCommentFrameModel *frameModel = self.pinglunArr[indexPath.row - 2 - self.classModel.imagesArray.count];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        cell.frameModel = frameModel;
        MJWeakSelf;
        cell.zanClicked = ^(PinglundianzanCustomBtn *zanButton, PlayVCCommentFrameModel *frameModel) {
            [weakSelf pinglundianzanAction:zanButton frameModel:frameModel];
        };
        return cell;
    }
}

#pragma mark - UIScrollViewDelegate
- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    if (scrollView.contentOffset.y > 209.0 / 667 * SCREEN_HEIGHT) {
        [_leftBtn setImage:[UIImage imageNamed:@"back"] forState:UIControlStateNormal];
        _topView.backgroundColor = [UIColor whiteColor];
    }
    else{
        [_leftBtn setImage:[UIImage imageNamed:@"title_ic_white"] forState:UIControlStateNormal];
        _topView.backgroundColor = [UIColor clearColor];
    }
}


- (UITableView *)helpTableView{
    if (_helpTableView == nil) {
        _helpTableView = [[UITableView alloc]initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_HEIGHT - 49) style:UITableViewStylePlain];
        [_helpTableView setDelegate:self];
        [_helpTableView setDataSource:self];
        _helpTableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    }
    return _helpTableView;
}

- (NSMutableArray *)buttons{
    if (!_buttons)
    {
        _buttons = [NSMutableArray array];
    }
    return _buttons;
}

- (UIButton *)collectBtn{
    if (!_collectBtn) {
        _collectBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        [_collectBtn setFrame:CGRectMake(0, SCREEN_HEIGHT - 49, SCREEN_WIDTH / 4, 49)];
        [_collectBtn setImage:[UIImage imageNamed:@"home_news_collection"] forState:UIControlStateNormal];
        [_collectBtn addTarget:self action:@selector(collectBtnAction:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _collectBtn;
}

- (UIButton *)auditionnBtn{
    if (!_auditionnBtn) {
        _auditionnBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        [_auditionnBtn setFrame:CGRectMake(0, SCREEN_HEIGHT - 49, SCREEN_WIDTH / 4 *2, 49)];
        [_auditionnBtn setImage:[UIImage imageNamed:@"play"] forState:UIControlStateNormal];
        [_auditionnBtn setImage:[UIImage imageNamed:@"pause"] forState:UIControlStateSelected];
        _auditionnBtn.imageEdgeInsets = UIEdgeInsetsMake(0, 0, 0, 0);
        [_auditionnBtn setTitle:@"试听" forState:UIControlStateNormal];
        _auditionnBtn.titleEdgeInsets = UIEdgeInsetsMake(0, 15, 0, 0);
        [_auditionnBtn setTitleColor:nTextColorMain forState:UIControlStateNormal];
        [_auditionnBtn addTarget:self action:@selector(auditionnBtnAction:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _auditionnBtn;
}

-(UILabel *)priceLabel{
    if (!_priceLabel) {
        _priceLabel = [[UILabel alloc]initWithFrame:CGRectMake(SCREEN_WIDTH / 4, 5, SCREEN_WIDTH / 4, 25)];
        _priceLabel.font = [UIFont boldSystemFontOfSize:18];
        [_priceLabel setBackgroundColor:[UIColor clearColor]];
        [_priceLabel setTextColor:[UIColor whiteColor]];
    }
    return _priceLabel;
}

-(UILabel *)spriceLabel{
    if (!_spriceLabel) {
        _spriceLabel = [[UILabel alloc]initWithFrame:CGRectMake(SCREEN_WIDTH / 4, 22, SCREEN_WIDTH / 4, 24)];
        [_spriceLabel setBackgroundColor:[UIColor clearColor]];
        [_spriceLabel setTextColor:[UIColor whiteColor]];
        _spriceLabel.font = gFontMain14;
        UIView *line = [[UIView alloc] initWithFrame:CGRectMake(5, 12, SCREEN_WIDTH / 4 - 45, 1)];
        line.backgroundColor = [UIColor whiteColor];
        [_spriceLabel addSubview:line];
    }
    return _spriceLabel;
}

- (UIButton *)purchaseBtn{
    if (!_purchaseBtn) {
        _purchaseBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        [_purchaseBtn setFrame:CGRectMake(SCREEN_WIDTH / 2, SCREEN_HEIGHT - 49, SCREEN_WIDTH / 2, 49)];
        [_purchaseBtn setBackgroundColor:purchaseButtonColor];
        [_purchaseBtn setTitleEdgeInsets:UIEdgeInsetsMake(0, 0, 0, SCREEN_WIDTH / 4)];
        [_purchaseBtn setTitle:@"购买" forState:UIControlStateNormal];
        [_purchaseBtn.titleLabel setTextAlignment:NSTextAlignmentLeft];
        [_purchaseBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [_purchaseBtn addTarget:self action:@selector(purchaseBtnAction:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _purchaseBtn;
}

/**
 提交购买人信息弹窗view

 @return view
 */
- (UIView *)alertCommitBuyUserDataView
{
    if (_alertCommitBuyUserDataView == nil) {
        _alertCommitBuyUserDataView = [[UIView alloc] initWithFrame:CGRectMake((SCREEN_WIDTH - SCREEN_WIDTH * 0.7)*0.5, 0, SCREEN_WIDTH * 0.7, 0)];
        _alertCommitBuyUserDataView.backgroundColor = [UIColor whiteColor];
        _alertCommitBuyUserDataView.layer.cornerRadius = 5;
        _alertCommitBuyUserDataView.layer.borderWidth = 1;
        _alertCommitBuyUserDataView.layer.borderColor = [UIColor lightGrayColor].CGColor;
        
        UILabel *tipLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, _alertCommitBuyUserDataView.width, 40)];
        tipLabel.text = @"恭喜您，购买成功!";
        tipLabel.textColor = gMainColor;
        tipLabel.font = gFontMajor16;
        tipLabel.textAlignment = NSTextAlignmentCenter;
        [_alertCommitBuyUserDataView addSubview:tipLabel];
        
        UILabel *describeLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, CGRectGetMaxY(tipLabel.frame), _alertCommitBuyUserDataView.width, 40)];
        describeLabel.text = @"为了方便日后搭建学员与老师\n的社群,请您填写以下信息,谢谢！";
        describeLabel.textColor = [UIColor lightGrayColor];
        describeLabel.font = SCREEN_WIDTH == 375?gFontMain14:gFontMain12;
        describeLabel.numberOfLines = 0;
        describeLabel.textAlignment = NSTextAlignmentCenter;
        [_alertCommitBuyUserDataView addSubview:describeLabel];
        
        CGFloat height = 30;
        for (int i = 0; i<5; i++) {
            UIView *contentView = [[UIView alloc] initWithFrame:CGRectMake(0, CGRectGetMaxY(describeLabel.frame) + i * (height + 5), _alertCommitBuyUserDataView.width, height)];
            contentView.backgroundColor = [UIColor clearColor];
            [_alertCommitBuyUserDataView addSubview:contentView];
            
            UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(20,0,35, height)];
            label.textColor = [UIColor lightGrayColor];
            label.font = gFontMain15;
            label.textAlignment = NSTextAlignmentRight;
            [contentView addSubview:label];
            
            UITextField *textField = [[UITextField alloc] init];
            textField.delegate = self;
            textField.backgroundColor = [UIColor clearColor];
            textField.font = gFontMain15;
            textField.returnKeyType = UIReturnKeyNext;
            textField.textColor = [UIColor blackColor];
            textField.tintColor = [UIColor lightGrayColor];
            textField.frame = CGRectMake(CGRectGetMaxX(label.frame) + 5, 0, _alertCommitBuyUserDataView.width - label.width - 45, height-1);
            [contentView addSubview:textField];
            
            UIView *devider = [[UIView alloc] initWithFrame:CGRectMake(textField.x,height - 1, textField.width, 1)];
            devider.backgroundColor = [UIColor lightGrayColor];
            [contentView addSubview:devider];
            
            if (i == 0) {
                label.text = @"姓名:";
                nameTextField = textField;
            }else if (i == 1) {
                label.text = @"电话:";
                phoneTextField = textField;
            }else if (i == 2) {
                label.text = @"微信:";
                wxTextField = textField;
            }else if (i == 3) {
                label.text = @"城市:";
                cityTextField = textField;
            }else if (i == 4) {
                label.text = @"工作:";
                textField.returnKeyType = UIReturnKeyDone;
                jobTextField = textField;
            }
        }
        
        UIButton *cancleBtn = [[UIButton alloc] initWithFrame:CGRectMake(0, CGRectGetMaxY(describeLabel.frame) + 5 *(height + 5), _alertCommitBuyUserDataView.width * 0.5 - 0.5, 44)];
        [cancleBtn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        [cancleBtn setTitle:@"取消" forState:UIControlStateNormal];
        cancleBtn.titleLabel.font = gFontMain15;
        [cancleBtn addTarget:self action:@selector(cancelBtnClick:)];
        [_alertCommitBuyUserDataView addSubview:cancleBtn];
        
        UIView *devider = [[UIView alloc] initWithFrame:CGRectMake(_alertCommitBuyUserDataView.width * 0.5 - 0.5, cancleBtn.y + 10, 1, cancleBtn.height - 20)];
        devider.backgroundColor = [UIColor lightGrayColor];
        [_alertCommitBuyUserDataView addSubview:devider];
        
        UIButton *commitBtn = [[UIButton alloc] initWithFrame:CGRectMake(_alertCommitBuyUserDataView.width * 0.5 + 0.5, cancleBtn.y, _alertCommitBuyUserDataView.width * 0.5 - 0.5, 44)];
        [commitBtn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        [commitBtn setTitle:@"提交" forState:UIControlStateNormal];
        commitBtn.titleLabel.font = gFontMain15;
        [commitBtn addTarget:self action:@selector(commitClick)];
        [_alertCommitBuyUserDataView addSubview:commitBtn];
        
        _alertCommitBuyUserDataView.height = CGRectGetMaxY(commitBtn.frame);
        _alertCommitBuyUserDataView.y = (SCREEN_HEIGHT - _alertCommitBuyUserDataView.height) * 0.5;
    }
    return _alertCommitBuyUserDataView;
}
- (UIButton *)cover
{
    if (_cover == nil) {
        _cover = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_HEIGHT)];
        _cover.backgroundColor = [UIColor clearColor];
        [_cover addTarget:self action:@selector(cancelBtnClick:)];
    }
    return _cover;
}
- (void)cancelBtnClick:(UIButton *)button
{
    [UIView animateWithDuration:0.5 animations:^{
        _alertCommitBuyUserDataView.alpha = 0.;
    }completion:^(BOOL finished) {
        [_alertCommitBuyUserDataView removeFromSuperview];
        [_cover removeFromSuperview];
    }];
}
- (void)commitClick
{
    if ([nameTextField.text isEqualToString:@""]) {
        XWAlerLoginView *alert = [[XWAlerLoginView alloc] initWithTitle:@"请输入姓名"];
        [alert show];
        return;
    }else if ([phoneTextField.text isEqualToString:@""]) {
        XWAlerLoginView *alert = [[XWAlerLoginView alloc] initWithTitle:@"请输入手机号"];
        [alert show];
        return;
    }else if (phoneTextField.text.length != 11) {
        XWAlerLoginView *alert = [[XWAlerLoginView alloc] initWithTitle:@"请输入正确手机号"];
        [alert show];
        return;
    }else if ([wxTextField.text isEqualToString:@""]) {
        XWAlerLoginView *alert = [[XWAlerLoginView alloc] initWithTitle:@"请输入微信号"];
        [alert show];
        return;
    }else if ([cityTextField.text isEqualToString:@""]) {
        XWAlerLoginView *alert = [[XWAlerLoginView alloc] initWithTitle:@"请输入所在城市"];
        [alert show];
        return;
    }else if ([jobTextField.text isEqualToString:@""]) {
        XWAlerLoginView *alert = [[XWAlerLoginView alloc] initWithTitle:@"请输入工作名称"];
        [alert show];
        return;
    }
    [NetWorkTool get_userInfoWithaccessToken:AvatarAccessToken name:nameTextField.text phone:phoneTextField.text wx_num:wxTextField.text city:cityTextField.text job:jobTextField.text sccess:^(NSDictionary *responseObject) {
        if ([responseObject[status] intValue] == 1) {
            XWAlerLoginView *alert = [[XWAlerLoginView alloc] initWithTitle:@"恭喜您，信息提交成功"];
            [alert show];
            
            NSDictionary *userInfoDict = [CommonCode readFromUserD:@"dangqianUserInfo"];
            [userInfoDict setValue:@"1" forKey:@"is_record"];
            [CommonCode writeToUserD:userInfoDict andKey:@"dangqianUserInfo"];
        }else{
            XWAlerLoginView *alert = [[XWAlerLoginView alloc] initWithTitle:@"很抱歉，信息提交失败了"];
            [alert show];
        }
    } failure:^(NSError *error) {
        XWAlerLoginView *alert = [[XWAlerLoginView alloc] initWithTitle:@"网络错误"];
        [alert show];
    }];
}
- (void)show
{
    [self.navigationController.view addSubview:self.cover];
    [self.navigationController.view addSubview:self.alertCommitBuyUserDataView];
    
    [UIView animateWithDuration:0.5 // 动画时长
                     animations:^{
                         _alertCommitBuyUserDataView.alpha = 1.;
                     } completion:^(BOOL finished) {
                     }];
}

#pragma mark - textfieldDelegate
- (void)textFieldDidBeginEditing:(UITextField *)textField
{
    IQKeyboardManager *manager = [IQKeyboardManager sharedManager];
    if ([textField isEqual:nameTextField]) {
        [manager setKeyboardDistanceFromTextField:50 + 35*4];
    }else if ([textField isEqual:phoneTextField]) {
        [manager setKeyboardDistanceFromTextField:50 + 35*3];
    }else if ([textField isEqual:wxTextField]) {
        [manager setKeyboardDistanceFromTextField:50 + 35*2];
    }else if ([textField isEqual:cityTextField]) {
        [manager setKeyboardDistanceFromTextField:50 + 35];
    }else if ([textField isEqual:jobTextField]) {
        [manager setKeyboardDistanceFromTextField:50];
    }
}
- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    if ([textField isEqual:jobTextField]) {
        [textField resignFirstResponder];
    }else{
        if ([textField isEqual:nameTextField]) {
            [phoneTextField becomeFirstResponder];
        }else if ([textField isEqual:phoneTextField]) {
            [wxTextField becomeFirstResponder];
        }else if ([textField isEqual:wxTextField]) {
            [cityTextField becomeFirstResponder];
        }else if ([textField isEqual:cityTextField]) {
            [jobTextField becomeFirstResponder];
        }
    }
    return YES;
}

- (NSMutableArray *)dataSourceArr{
    if (!_dataSourceArr) {
        _dataSourceArr = [NSMutableArray array];
    }
    return _dataSourceArr;
}
- (NSMutableArray *)playShiTingListArr
{
    if (_playShiTingListArr == nil) {
        _playShiTingListArr = [NSMutableArray array];
    }
    return _playShiTingListArr;
}
- (NSMutableArray *)frameArray
{
    if (_frameArray == nil) {
        _frameArray = [NSMutableArray array];
    }
    return _frameArray;
}
#pragma mark - 支付结果通知方法
- (void)AliPayResults:(NSNotification *)notification {
    
    NSString* title=@"PaySuccess1",*msg=@"您已支付成功",*sureTitle=@"确定" , *cancelTitle=@"取消吧";
    AKAlertView* av;
    
    APPDELEGATE.isClassPay = NO;
    NSDictionary *resultDic = notification.object;
    if ([resultDic[@"resultStatus"]integerValue] == 9000) {
        //支付成功
//        title=@"PaySuccess1",msg=@"您已支付成功",sureTitle=@"确定";
//        av= [AKAlertView alertView:title des:msg  type:AKAlertFaild effect:AKAlertEffectDrop sureTitle:sureTitle cancelTitle:cancelTitle];
        //填写学员信息弹窗
        if ([[CommonCode readFromUserD:@"isLogin"]boolValue] == YES) {
            NSDictionary *userInfoDict = [CommonCode readFromUserD:@"dangqianUserInfo"];
            if ([userInfoDict[results][@"is_record"] intValue] == 0) {
                [self show];
            }
        }
        [[NSNotificationCenter defaultCenter] postNotificationName:ReloadClassList object:nil];
    }
    else if ([resultDic[@"resultStatus"]integerValue] == 8000){
        //正在处理中
        av= [AKAlertView alertView:title des:msg  type:AKAlertFaild effect:AKAlertEffectDrop sureTitle:sureTitle cancelTitle:cancelTitle];
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
    };
    [av show];
    //充值成功 --》 获取用户信息
    [[NSNotificationCenter defaultCenter] postNotificationName:@"updateUserInfo" object:nil];
}

- (void)WechatPayResults:(NSNotification *)notification {
    NSString* title=@"PaySuccess1",*msg=@"您已支付成功",*sureTitle=@"确定" , *cancelTitle=@"取消吧";
    APPDELEGATE.isClassPay = NO;
    AKAlertView* av;
    if ([notification.object integerValue] == 0) {
//        title=@"PaySuccess1",msg=@"您已支付成功",sureTitle=@"确定";
//        av= [AKAlertView alertView:title des:msg  type:AKAlertFaild effect:AKAlertEffectDrop sureTitle:sureTitle cancelTitle:cancelTitle];
        //填写学员信息弹窗
        if ([[CommonCode readFromUserD:@"isLogin"]boolValue] == YES) {
            NSDictionary *userInfoDict = [CommonCode readFromUserD:@"dangqianUserInfo"];
            if ([userInfoDict[results][@"is_record"] intValue] == 0) {
                [self show];
            }
        }
        [[NSNotificationCenter defaultCenter] postNotificationName:ReloadClassList object:nil];
//        [self back];
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
    };
    
    [av show];
    //充值成功 --》 获取用户信息
    [[NSNotificationCenter defaultCenter] postNotificationName:@"updateUserInfo" object:nil];
}
@end
