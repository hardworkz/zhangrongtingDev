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
    UILabel *PingLundianzanNumLab;
    NSInteger playIndex;
//    NSString *currentClassID;
    UITextView *zhengwenTextView;
    NSString *rewardMoney;
    NSString *orderNum;
    
    UILabel *classPriceLabel;
    UIButton *VipSelected;
    UILabel *vipPriceLabel;
    
    //提交信息输入框
    UITextField *nameTextField;
    UITextField *phoneTextField;
    UITextField *wxTextField;
    UITextField *cityTextField;
    UITextField *jobTextField;
    UITextField *selectedTextField;
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
//@property (strong, nonatomic) AVAudioSession *session;
@property (assign, nonatomic) NSInteger playingIndex;
//@property (assign, nonatomic) BOOL isVoicePlayEnd;//判断是否是播放完成回调
//@property (strong, nonatomic) AVPlayer *Player;
@property (assign, nonatomic) NSInteger commentIndex;
@property (assign, nonatomic) NSInteger commentPageSize;
/**
 Vip购买选择表格
 */
@property (strong, nonatomic) UIView *alertVipSelectedView;
@property (strong, nonatomic) UIButton *cover;

/**
 tableviewHeader控件
 */
@property (strong, nonatomic) UIView *xiangqingView;
@property (strong, nonatomic) UIImageView *zhengwenImg;
@property (strong, nonatomic) UILabel *titleLab;
@property (strong, nonatomic) UIView *seperatorLine;
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
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(AliPayResults:) name:AliPayResultsClass object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(WechatPayResults:) name:WechatPayResultsClass object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(AliPayResultsMembers:) name:AliPayResultsMembers object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(WechatPayResultsMembers:) name:WechatPayResultsMembers object:nil];
    
    DefineWeakSelf
    [ZRT_PlayerManager manager].playDidEndReload = ^(NSInteger currentSongIndex) {
        if (currentSongIndex == weakSelf.playShiTingListArr.count - 1) {
            _auditionnBtn.selected = [ZRT_PlayerManager manager].isPlaying;
            for (UIButton *playBtn in weakSelf.buttons) {
                playBtn.selected = [ZRT_PlayerManager manager].isPlaying;
            }
        }
    };
    self.commentIndex = 2;
    self.commentPageSize = 5;
    self.helpTableView.mj_footer = [MJRefreshAutoNormalFooter footerWithRefreshingBlock:^{
        [weakSelf loadCommentData];
    }];
}

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    
    [self.navigationController setNavigationBarHidden:YES animated:YES];
    
    //单例模式刷新数据
    if (![Exact_id isEqualToString:self.act_id]) {//当前为不同页面，需要重新初始化控件状态
        
        playIndex = -1;
        [self.helpTableView setContentOffset:CGPointZero animated:NO];
    }
    //清空上一个页面图片数据
    if (self.zhengwenImg) {
        [_zhengwenImg sd_setImageWithURL:[NSURL URLWithString:@""] placeholderImage:[UIImage imageNamed:@"thumbnailsdefault"]];
        _titleLab.text = @"";
    }
    [self loadData];
    
    if ([Exact_id isEqualToString:self.act_id] && [ZRT_PlayerManager manager].isPlaying)
    {
        self.auditionnBtn.selected = YES;
    }else{
        self.auditionnBtn.selected = NO;
    }
    //保存跳转已经购买课堂界面数据，tabbar中心按钮点击需要使用
    if (self.jiemuID) {
        NSMutableDictionary *dict = [NSMutableDictionary dictionary];
        [dict setObject:self.jiemuID forKey:@"jiemuID"];
        [dict setObject:self.jiemuName forKey:@"jiemuName"];
        [dict setObject:self.jiemuImages forKey:@"jiemuImages"];
        [dict setObject:self.jiemuDescription forKey:@"jiemuDescription"];
        [dict setObject:self.jiemuFan_num forKey:@"jiemuFan_num"];
        [dict setObject:self.jiemuIs_fan forKey:@"jiemuIs_fan"];
        [dict setObject:self.jiemuMessage_num forKey:@"jiemuMessage_num"];
        [CommonCode writeToUserD:dict andKey:@"is_free_data"];
    }
    DefineWeakSelf
    [ZRT_PlayerManager manager].playDidEnd = ^(NSInteger currentSongIndex) {
        if ([ZRT_PlayerManager manager].playType == ZRTPlayTypeClassroomTry) {
            weakSelf.playingIndex = currentSongIndex;
            [weakSelf playTestMp:weakSelf.buttons[weakSelf.playingIndex]];
        }
    };
}

- (void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    [self.navigationController setNavigationBarHidden:NO animated:YES];
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
    
    _playingIndex = -1;
    
//    _isPlaying = NO;
//    ExisRigester = NO;
    //AudioSession负责应用音频的设置，比如支不支持后台，打断等等
//    NSError *error;
    //设置音频会话
//    self.session = [AVAudioSession sharedInstance];
    //AVAudioSessionCategoryPlayback一般用于支持后台播放
//    [self.session setCategory:AVAudioSessionCategoryPlayback error:&error];
    //激活会话
//    [self.session setActive:YES error:&error];
    //接收播放完毕后发出的通知
//    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(voicePlayEnd:) name:AVPlayerItemDidPlayToEndTimeNotification object:ExclassPlayer.currentItem];
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
    //刷新评论页面的index
    self.commentIndex = 2;
    
    NSString *accessToken;
    if (ExdangqianUser.length == 0 || ExdangqianUser == nil){
        accessToken = nil;
    }
    else{
        accessToken = [DSE encryptUseDES:ExdangqianUser];
    }
    DefineWeakSelf;
    [NetWorkTool getAuditionListWithaccessToken:AvatarAccessToken act_id:self.act_id sccess:^(NSDictionary *responseObject) {
        if ([responseObject[status] integerValue] == 1) {
            if ([responseObject[results][@"shiting"] isKindOfClass:[NSArray class]]) {
                weakSelf.playShiTingListArr = responseObject[results][@"shiting"];
                for (NSMutableDictionary *dict in weakSelf.playShiTingListArr) {
                    [dict setObject:responseObject[results][@"lai"] forKey:@"name"];
                    [dict setObject:responseObject[results][@"smeta"] forKey:@"smeta"];
                }
            }
            _classModel = [ClassModel mj_objectWithKeyValues:responseObject[results]];
            weakSelf.frameArray = [self frameArrayWithClassModel:self.classModel];
            weakSelf.pinglunArr = [self pinglunFrameModelArrayWithModelArray:[PlayVCCommentModel mj_objectArrayWithKeyValuesArray:responseObject[results][@"comments"]]];
            if (weakSelf.pinglunArr.count < self.commentPageSize) {
                [weakSelf.helpTableView.mj_footer endRefreshingWithNoMoreData];
            }else{
                [weakSelf.helpTableView.mj_footer resetNoMoreData];
            }
            [weakSelf setTableHeadView];
            [weakSelf.helpTableView reloadData];
            
            //判断是否是纯数字
            NSString *textStr = [NSString stringWithFormat:@" ￥%@ ",[NetWorkTool formatFloat:[responseObject[results][@"sprice"] floatValue]]];
            //中划线
            NSDictionary *attribtDic = @{NSStrikethroughStyleAttributeName: [NSNumber numberWithInteger:NSUnderlineStyleSingle]};
            NSMutableAttributedString *attribtStr = [[NSMutableAttributedString alloc]initWithString:textStr attributes:attribtDic];
            // 赋值
            weakSelf.spriceLabel.attributedText = attribtStr;
            weakSelf.priceLabel.text = [NSString stringWithFormat:@" ￥%@",[NetWorkTool formatFloat:[responseObject[results][@"price"] floatValue]]];
            rewardMoney = responseObject[results][@"price"];
            
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
/**
 获取评论数据
 */
- (void)loadCommentData
{
    DefineWeakSelf;
    [NetWorkTool getPaoguoJieMuOrZhuBoPingLunLieBiaoWithact_id:self.act_id accessToken:ExdangqianUserUid andpage:[NSString stringWithFormat:@"%ld",(long)self.commentIndex] andlimit:[NSString stringWithFormat:@"%ld",(long)self.commentPageSize] sccess:^(NSDictionary *responseObject) {
        [weakSelf endRefreshing];
        if ([responseObject[results] isKindOfClass:[NSArray class]]){
            weakSelf.commentIndex++;
            NSArray *array = responseObject[results];
            [weakSelf.pinglunArr addObjectsFromArray:[self pinglunFrameModelArrayWithModelArray:[PlayVCCommentModel mj_objectArrayWithKeyValuesArray:array]]];
            weakSelf.pinglunArr = [[NSMutableArray alloc] initWithArray:weakSelf.pinglunArr];
            [weakSelf.helpTableView reloadData];
            if (array.count < weakSelf.commentPageSize) {
//                [weakSelf.helpTableView.mj_header endRefreshing];
                [weakSelf.helpTableView.mj_footer endRefreshingWithNoMoreData];
            }else{
                [weakSelf.helpTableView.mj_footer endRefreshing];
                [weakSelf.helpTableView.mj_footer resetNoMoreData];
            }
        }else{
            [weakSelf.helpTableView.mj_footer endRefreshingWithNoMoreData];
        }
    } failure:^(NSError *error) {
        [weakSelf endRefreshing];
    }];
}

/**
 评论model转为frameModel
 */
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

- (void)endRefreshing{
    [self.helpTableView.mj_header endRefreshing];
    [self.helpTableView.mj_footer endRefreshing];
}

- (void)back {
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
    
    [self.xiangqingView addSubview:self.zhengwenImg];
    //设置图片
    if ([NEWSSEMTPHOTOURL(self.classModel.smeta) rangeOfString:@"userDownLoadPathImage"].location != NSNotFound) {
        [_zhengwenImg sd_setImageWithURL:[NSURL fileURLWithPath:NEWSSEMTPHOTOURL(self.classModel.smeta)] placeholderImage:[UIImage imageNamed:@"thumbnailsdefault"]];
    }
    else if ([NEWSSEMTPHOTOURL(self.classModel.smeta) rangeOfString:@"http"].location != NSNotFound)
    {
        [_zhengwenImg sd_setImageWithURL:[NSURL URLWithString:NEWSSEMTPHOTOURL(self.classModel.smeta)] placeholderImage:[UIImage imageNamed:@"thumbnailsdefault"]];
    }
    else{
        NSString *str = USERPHOTOHTTPSTRINGZhuBo(NEWSSEMTPHOTOURL(self.classModel.smeta));
        [_zhengwenImg sd_setImageWithURL:[NSURL URLWithString:str] placeholderImage:[UIImage imageNamed:@"thumbnailsdefault"]];
    }
    
    _titleLab.text = self.classModel.title;
    CGFloat titleHight = [self computeTextHeightWithString:self.classModel.title andWidth:(SCREEN_WIDTH-20) andFontSize:gFontMain14];
    [_titleLab setFrame:CGRectMake(20.0 / 375 * IPHONE_W, CGRectGetMaxY(_zhengwenImg.frame) + 20.0 / 667 * SCREEN_HEIGHT, IPHONE_W - 40.0 / 375 * IPHONE_W, (titleHight + 20) / 667 * IPHONE_H)];
    
    [_xiangqingView addSubview:self.titleLab];
    
    _seperatorLine.frame = CGRectMake(20.0 / 375 * SCREEN_WIDTH, CGRectGetMaxY(_titleLab.frame) +  12.0 / 667 * SCREEN_HEIGHT, SCREEN_WIDTH - 40.0 / 375 * SCREEN_WIDTH, 1.0);
    
    [_xiangqingView addSubview:self.seperatorLine];
    
    _xiangqingView.frame = CGRectMake(_xiangqingView.frame.origin.x, _xiangqingView.frame.origin.y, _xiangqingView.frame.size.width, CGRectGetMaxY(_seperatorLine.frame));
    self.helpTableView.tableHeaderView = _xiangqingView;
    
    //footer
//    if (self.helpTableView.tableFooterView == nil) {
//        UIButton *moreComment = [UIButton buttonWithType:UIButtonTypeCustom];
//        [moreComment setFrame:CGRectMake(0, 0, SCREEN_WIDTH, 44)];
//        [moreComment setTitle:@"查看更多评价" forState:UIControlStateNormal];
//        [moreComment.titleLabel setFont:gFontMain14];
//        [moreComment setTitleColor:gTextColorSub forState:UIControlStateNormal];
//        [moreComment addTarget:self action:@selector(morecommetAction:) forControlEvents:UIControlEventTouchUpInside];
//        self.helpTableView.tableFooterView = moreComment;
//    }
    
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
        loginNavC.navigationBar.tintColor = [UIColor blackColor];
        [self presentViewController:loginNavC animated:YES completion:nil];
    }]];
    
    [self presentViewController:qingshuruyonghuming animated:YES completion:nil];
}

#pragma mark - KVO
//观察者方法，用来监听播放状态
//- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSString *,id> *)change context:(void *)context{
//    //当播放器状态（status）改变时，会进入此判断
//    if ([keyPath isEqualToString:@"statu"]){
//        switch (ExclassPlayer.status) {
//            case AVPlayerStatusUnknown:
//                NSLog(@"KVO：未知状态，此时不能播放");
//                break;
//            case AVPlayerStatusReadyToPlay:
//                NSLog(@"KVO：准备完毕，可以播放");
//                //自动播放
//                //                [ExclassPlayer play];
//                break;
//            case AVPlayerStatusFailed:
//                NSLog(@"KVO：加载失败，网络或者服务器出现问题");
//                break;
//            default:
//                break;
//        }
//    }
//}

#pragma mark - NSNotification
//- (void)voicePlayEnd:(NSNotification *)notice {
//    if (!ExIsClassVCPlay) {
//        return;
//    }
//    NSArray *shitingArray = [CommonCode readFromUserD:playList];
//    if (_playingIndex < [shitingArray count] - 1) {
//        _isVoicePlayEnd = YES;
//        if (self.buttons.count != 0) {
//            UIButton *nextTextMPButton = self.buttons[_playingIndex + 1];
//            [self playTestMp:nextTextMPButton];
//        }else{
//            [self playTestMpWithIndex:_playingIndex + 1];
//        }
//    }
//    else{
//        [self performSelector:@selector(wanbi:) withObject:notice afterDelay:0.5f];
//        _isPlaying = NO;
//    }
//}

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
    }
//    [ExclassPlayer pause];
//    [CommonCode writeToUserD:@"YES" andKey:TINGYOUQUANBOFANGWANBI];
//    _isPlaying = NO;
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
    
    [self show];
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
        
        //购买会员不用听币
//        if (![VipSelected.accessibilityIdentifier isEqualToString:@"vip"]) {
//            UIButton *tingbiBtn = [[UIButton alloc] init];
//            tingbiBtn.frame = CGRectMake(0, 100, SCREEN_WIDTH, 50);
//            tingbiBtn.backgroundColor = [UIColor whiteColor];
//            [tingbiBtn setImage:@"pay2"];
//            tingbiBtn.imageEdgeInsets = UIEdgeInsetsMake(0, -20, 0, 0);
//            [tingbiBtn setTitle:@"听币支付" forState:UIControlStateNormal];
//            [tingbiBtn setTitleColor:gMainColor forState:UIControlStateNormal];
//            tingbiBtn.titleLabel.font = [UIFont systemFontOfSize:17];
//            [tingbiBtn addTarget:self action:@selector(tingbiBtnClicked)];
//            [bgView addSubview:tingbiBtn];
//        }
        
        UIButton *cancelBtn = [[UIButton alloc] init];
        cancelBtn.frame = CGRectMake(0,105, SCREEN_WIDTH, 50);
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
//    APPDELEGATE.payType = PayTypeClassPay;
    //判断是选择购买vip，还是购买课程
    if ([VipSelected.accessibilityIdentifier isEqualToString:@"vip"]) {
        [NetWorkTool AliPayWithaccessToken:AvatarAccessToken pay_type:@"2" act_id:nil money:nil mem_type:@"2" month:@"12" sccess:^(NSDictionary *responseObject) {
            RTLog(@"%@",responseObject);
            if ([responseObject[status] intValue] == 1) {
                // NOTE: 调用支付结果开始支付
                [[AlipaySDK defaultService] payOrder:responseObject[results][@"response"] fromScheme:appScheme callback:^(NSDictionary *resultDic) {
                    switch (APPDELEGATE.payType) {
                        case PayTypeClassPay:
                            [[NSNotificationCenter defaultCenter] postNotificationName:AliPayResultsClass object:resultDic];
                            break;
                        case PayTypeReward:
                            [[NSNotificationCenter defaultCenter] postNotificationName:AliPayResultsReward object:resultDic];
                            break;
                        case PayTypeRecharge:
                            [[NSNotificationCenter defaultCenter] postNotificationName:AliPayResultsRecharge object:resultDic];
                            break;
                        case PayTypeMembers:
                            [[NSNotificationCenter defaultCenter] postNotificationName:AliPayResultsMembers object:resultDic];
                            break;
                            
                        default:
                            break;
                    }
                }];
                
            }else{
                XWAlerLoginView *alert = [[XWAlerLoginView alloc] initWithTitle:responseObject[msg]];
                [alert show];
            }
        } failure:^(NSError *error) {
            XWAlerLoginView *alert = [[XWAlerLoginView alloc] initWithTitle:@"网络错误"];
            [alert show];
        }];
    }else{
        [NetWorkTool AliPayWithaccessToken:AvatarAccessToken pay_type:@"1" act_id:self.classModel.act_id money:nil mem_type:nil month:nil sccess:^(NSDictionary *responseObject) {
            if ([responseObject[status] intValue] == 1) {
                // NOTE: 调用支付结果开始支付
                [[AlipaySDK defaultService] payOrder:responseObject[results][@"response"] fromScheme:appScheme callback:^(NSDictionary *resultDic) {
                    switch (APPDELEGATE.payType) {
                        case PayTypeClassPay:
                            [[NSNotificationCenter defaultCenter] postNotificationName:AliPayResultsClass object:resultDic];
                            break;
                        case PayTypeReward:
                            [[NSNotificationCenter defaultCenter] postNotificationName:AliPayResultsReward object:resultDic];
                            break;
                        case PayTypeRecharge:
                            [[NSNotificationCenter defaultCenter] postNotificationName:AliPayResultsRecharge object:resultDic];
                            break;
                        case PayTypeMembers:
                            [[NSNotificationCenter defaultCenter] postNotificationName:AliPayResultsMembers object:resultDic];
                            break;
                            
                        default:
                            break;
                    }
                }];
                
            }else{
                XWAlerLoginView *alert = [[XWAlerLoginView alloc] initWithTitle:responseObject[msg]];
                [alert show];
            }
        } failure:^(NSError *error) {
            XWAlerLoginView *alert = [[XWAlerLoginView alloc] initWithTitle:@"网络错误"];
            [alert show];
        }];
    }
}
//微信支付
- (void)weixinBtnClicked
{
    [_alertView coverClick];
//    APPDELEGATE.payType = PayTypeClassPay;
    //判断是选择购买vip，还是购买课程
    if ([VipSelected.accessibilityIdentifier isEqualToString:@"vip"]) {
        [NetWorkTool WXPayWithaccessToken:AvatarAccessToken pay_type:@"2" act_id:nil money:nil mem_type:@"2" month:@"12" sccess:^(NSDictionary *responseObject) {
            RTLog(@"%@",responseObject);
            if ([responseObject[status] intValue] == 1) {
                NSDictionary *payDic = responseObject[results];
                //调起微信支付
                PayReq *req             = [[PayReq alloc] init];
                req.openID              = [payDic objectForKey:@"appid"];
                req.partnerId           = [payDic objectForKey:@"partnerid"];
                req.prepayId            = [payDic objectForKey:@"prepayid"];
                req.nonceStr            = [payDic objectForKey:@"noncestr"];
                NSMutableString *stamp  = [payDic objectForKey:@"timestamp"];
                req.timeStamp           = stamp.intValue;
                req.package             = [payDic objectForKey:@"package"];
                req.sign                = [payDic objectForKey:@"sign"];
                [WXApi sendReq:req];
            }else{
                XWAlerLoginView *alert = [[XWAlerLoginView alloc] initWithTitle:responseObject[msg]];
                [alert show];
            }
        } failure:^(NSError *error) {
            XWAlerLoginView *alert = [[XWAlerLoginView alloc] initWithTitle:@"网络错误"];
            [alert show];
        }];
    }else{
        [NetWorkTool WXPayWithaccessToken:AvatarAccessToken pay_type:@"1" act_id:self.classModel.act_id money:nil mem_type:nil month:nil sccess:^(NSDictionary *responseObject) {
            if ([responseObject[status] intValue] == 1) {
                NSDictionary *payDic = responseObject[results];
                //调起微信支付
                PayReq *req             = [[PayReq alloc] init];
                req.openID              = [payDic objectForKey:@"appid"];
                req.partnerId           = [payDic objectForKey:@"partnerid"];
                req.prepayId            = [payDic objectForKey:@"prepayid"];
                req.nonceStr            = [payDic objectForKey:@"noncestr"];
                NSMutableString *stamp  = [payDic objectForKey:@"timestamp"];
                req.timeStamp           = stamp.intValue;
                req.package             = [payDic objectForKey:@"package"];
                req.sign                = [payDic objectForKey:@"sign"];
                [WXApi sendReq:req];
            }else{
                XWAlerLoginView *alert = [[XWAlerLoginView alloc] initWithTitle:responseObject[msg]];
                [alert show];
            }
        } failure:^(NSError *error) {
            XWAlerLoginView *alert = [[XWAlerLoginView alloc] initWithTitle:@"网络错误"];
            [alert show];
        }];
    }
}
//听币支付
- (void)tingbiBtnClicked
{
    XWAlerLoginView *alert = [[XWAlerLoginView alloc] initWithTitle:@"您的听币不足，请先前往充值"];
    [alert show];
    [_alertView coverClick];
}
//取消支付弹窗
- (void)cancelAlert
{
    APPDELEGATE.payType = PayTypeNone;
    [_alertView coverClick];
}
//点击底部试听按钮
- (void)auditionnBtnAction:(UIButton *)sender
{
    _playingIndex = [Exact_id isEqualToString:self.act_id]?_playingIndex:-1;
    Exact_id = self.act_id;
    [CommonCode writeToUserD:Exact_id andKey:@"Exact_id"];
    
    //设置播放类型
    [ZRT_PlayerManager manager].channelType = ChannelTypeClassroomTryList;
    [ZRT_PlayerManager manager].playType = ZRTPlayTypeClassroomTry;
    //设置试听列表数据
    [ZRT_PlayerManager manager].songList = self.playShiTingListArr;

    if ([ZRT_PlayerManager manager].isPlaying) {//选中状态，为播放状态,则将列表按钮设置全部设置为暂停
        [[ZRT_PlayerManager manager] pausePlay];
        sender.selected = NO;
        for ( int i = 0 ; i < self.buttons.count; i ++ ) {
            UIButton *anotherButton = self.buttons[i];
            anotherButton.selected = NO;
        }
    }
    else{//未选中状态，为暂停状态,判断当前播放第一个按钮，设置播放状态
        [[ZRT_PlayerManager manager] startPlay];
        sender.selected = YES;
        if (_playingIndex < 0) {
            _playingIndex = 0;
            for ( int i = 0 ; i < self.buttons.count; i ++ ) {
                if (i == 0) {
                    UIButton *allDoneButton = [self.buttons objectAtIndex:_playingIndex];
                    allDoneButton.selected = YES;
                }
                else{
                    UIButton *anotherButton = self.buttons[i];
                    anotherButton.selected = NO;
                }
            }
        }else{
            for ( int i = 0 ; i < self.buttons.count; i ++ ) {
                if (i == _playingIndex) {
                    UIButton *allDoneButton = [self.buttons objectAtIndex:_playingIndex];
                    allDoneButton.selected = YES;
                }
                else{
                    UIButton *anotherButton = self.buttons[i];
                    anotherButton.selected = NO;
                }
            }
        }
        //设置播放的index
        [[ZRT_PlayerManager manager] loadSongInfoFromIndex:_playingIndex];
    }
    [APPDELEGATE configNowPlayingCenter];
}
//列表试听按钮点击
- (void)playTestMp:(UIButton *)sender
{
    Exact_id = self.act_id;
    [CommonCode writeToUserD:Exact_id andKey:@"Exact_id"];
    
    //设置播放类型
    [ZRT_PlayerManager manager].channelType = ChannelTypeClassroomTryList;
    [ZRT_PlayerManager manager].playType = ZRTPlayTypeClassroomTry;
    //设置试听列表数据
    [ZRT_PlayerManager manager].songList = self.playShiTingListArr;
    //播放试听音频
    if ([ZRT_PlayerManager manager].isPlaying && sender.selected == YES) {//如果为点击当前正在播放按钮则暂停
        [[ZRT_PlayerManager manager] pausePlay];
    }
    else{
        //设置播放的index
        [[ZRT_PlayerManager manager] loadSongInfoFromIndex:sender.tag];
        
        _playingIndex = sender.tag;
    }
    
    [APPDELEGATE configNowPlayingCenter];
    
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
    //设置底部按钮状态
    if (isTestMpPlay) {
        [self.auditionnBtn setSelected:YES];
    }
    else{
        [self.auditionnBtn setSelected:NO];
    }
}
- (void)pinglundianzanAction:(PinglundianzanCustomBtn *)pinglundianzanBtn frameModel:(PlayVCCommentFrameModel *)frameModel
{
    PlayVCCommentModel *model = frameModel.model;
    UILabel *dianzanNumlab = pinglundianzanBtn.PingLundianzanNumLab;
    pinglundianzanBtn.enabled = NO;
    if (pinglundianzanBtn.selected == YES){
        [NetWorkTool postPaoGuoXinWenPingLunDianZanWithaccessToken:[DSE encryptUseDES:ExdangqianUser] andact_id:model.playCommentID sccess:^(NSDictionary *responseObject) {
            pinglundianzanBtn.enabled = YES;
            if ([responseObject[msg] isEqualToString:@"取消成功!"]) {
                //设置点赞按钮状态
                dianzanNumlab.text = [NSString stringWithFormat:@"%d",[dianzanNumlab.text intValue] - 1];
                dianzanNumlab.textColor = [UIColor grayColor];
                dianzanNumlab.alpha = 0.7f;
                pinglundianzanBtn.selected = NO;
                //设置模型数据状态
                frameModel.model.praisenum = dianzanNumlab.text;
                frameModel.model.praiseFlag = @"1";
            }
        } failure:^(NSError *error) {
            pinglundianzanBtn.enabled = YES;
            NSLog(@"error = %@",error);
        }];
    }
    else{
        [NetWorkTool postPaoGuoXinWenPingLunDianZanWithaccessToken:[DSE encryptUseDES:ExdangqianUser] andact_id:model.playCommentID sccess:^(NSDictionary *responseObject) {
            pinglundianzanBtn.enabled = YES;
            NSLog(@"responseObject = %@",responseObject);
            NSLog(@"针对评论点赞");
            if ([responseObject[msg] isEqualToString:@"点赞成功!"]) {
                //设置取消点赞按钮状态
                dianzanNumlab.text = [NSString stringWithFormat:@"%d",[dianzanNumlab.text intValue] + 1];
                dianzanNumlab.textColor = ColorWithRGBA(0, 159, 240, 1);
                dianzanNumlab.alpha = 1.0f;
                pinglundianzanBtn.selected = YES;
                //设置模型数据状态
                frameModel.model.praisenum = dianzanNumlab.text;
                frameModel.model.praiseFlag = @"2";
            }
            
        } failure:^(NSError *error) {
            pinglundianzanBtn.enabled = YES;
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
    if (self.classModel != nil) {
        if ([self.classModel.comments isKindOfClass:[NSArray class]]){
            if ([self.classModel.comments count] != 0) {
                return self.pinglunArr.count + 2 + self.classModel.imagesArray.count;
            }
            else{
                return self.classModel.imagesArray.count + 2;
            }
        }
        else{
            return self.classModel.imagesArray.count + 2;
        }
    }else{
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
        if ([Exact_id isEqualToString:self.act_id] && [ZRT_PlayerManager manager].isPlaying) {
            cell.playingIndex = _playingIndex;
        }else{
            cell.playingIndex = -1;
        }
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        cell.frameModel = self.frameArray[indexPath.row];
        self.buttons = cell.buttons;
        MJWeakSelf
        cell.playAudition = ^(UIButton *button, NSMutableArray *buttons) {
            //点击试听列表按钮
            [weakSelf playTestMp:button];
        };
        return cell;
    }else{
        PlayVCCommentTableViewCell *cell = [PlayVCCommentTableViewCell cellWithTableView:tableView];
//        cell.hideZanBtn = YES;
        cell.commentCellType = CommentCellTypeClassroom;
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
 tableViewHeader控件懒加载

 @return zhengwenImg
 */
- (UIView *)xiangqingView
{
    if (_xiangqingView == nil) {
        _xiangqingView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, IPHONE_W, IPHONE_H)];
        _xiangqingView.backgroundColor = [UIColor whiteColor];
    }
    return _xiangqingView;
}
- (UIImageView *)zhengwenImg
{
    if (_zhengwenImg == nil) {
        //新闻图片
        _zhengwenImg = [[UIImageView alloc] initWithFrame:CGRectMake(0, -20, IPHONE_W, 209.0 / 667 * SCREEN_HEIGHT)];
        [_zhengwenImg setUserInteractionEnabled:YES];
        
        UIBezierPath *maskPath = [UIBezierPath bezierPathWithRoundedRect:_zhengwenImg.bounds byRoundingCorners:UIRectCornerBottomRight cornerRadii:CGSizeMake(160.0 / 667 * SCREEN_HEIGHT, 160.0 / 667 * SCREEN_HEIGHT)];
        CAShapeLayer *maskLayer = [[CAShapeLayer alloc] init];
        maskLayer.frame = _zhengwenImg.bounds;
        maskLayer.path = maskPath.CGPath;
        _zhengwenImg.layer.mask = maskLayer;

        //添加单击手势
        UITapGestureRecognizer *tapZhengwenImg = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(showZoomImageView:)];
        [_zhengwenImg addGestureRecognizer:tapZhengwenImg];
        _zhengwenImg.contentMode = UIViewContentModeScaleAspectFill;
        _zhengwenImg.clipsToBounds = YES;
    }
    return _zhengwenImg;
}
- (UILabel *)titleLab
{
    if (_titleLab == nil) {
        //课堂标题
        _titleLab = [[UILabel alloc] initWithFrame:CGRectMake(20.0 / 375 * IPHONE_W,CGRectGetMaxY(_zhengwenImg.frame) + 20.0 / 667 * SCREEN_HEIGHT, IPHONE_W - 40.0 / 375 * IPHONE_W, 40.0 / 667 * IPHONE_H)];
        _titleLab.textAlignment = NSTextAlignmentCenter;
        _titleLab.textColor = nTextColorMain;
        _titleLab.font = [UIFont boldSystemFontOfSize:self.titleFontSize];
        [_titleLab setNumberOfLines:0];
        _titleLab.lineBreakMode = NSLineBreakByWordWrapping;

    }
    return _titleLab;
}
- (UIView *)seperatorLine
{
    if (_seperatorLine == nil) {
        //分割线
        _seperatorLine = [[UIView alloc] initWithFrame:CGRectMake(20.0 / 375 * SCREEN_WIDTH, CGRectGetMaxY(_titleLab.frame) +  12.0 / 667 * SCREEN_HEIGHT, SCREEN_WIDTH - 40.0 / 375 * SCREEN_WIDTH, 1.0)];
        [_seperatorLine setBackgroundColor:gThickLineColor];
    }
    return _seperatorLine;
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
#pragma mark - 课程支付结果通知方法
- (void)AliPayResults:(NSNotification *)notification
{
    NSString* title=@"支付结果",*msg=@"您的课程购买成功",*sureTitle=@"确定";
    NSDictionary *resultDic = notification.object;
    if ([resultDic[@"resultStatus"]integerValue] == 9000) {
        
        zhuboXiangQingVCNewController *faxianzhuboVC = [[zhuboXiangQingVCNewController alloc]init];
        faxianzhuboVC.jiemuDescription = self.jiemuDescription;
        faxianzhuboVC.jiemuFan_num = self.jiemuFan_num;
        faxianzhuboVC.jiemuID = self.jiemuID;
        faxianzhuboVC.jiemuImages = self.jiemuImages;
        faxianzhuboVC.jiemuIs_fan = self.jiemuIs_fan;
        faxianzhuboVC.jiemuMessage_num = self.jiemuMessage_num;
        faxianzhuboVC.jiemuName = self.jiemuName;
        faxianzhuboVC.isfaxian = YES;
        faxianzhuboVC.isClass = YES;
        faxianzhuboVC.listVC = self.listVC;
        [self.navigationController pushViewController:faxianzhuboVC animated:YES];
        [[NSNotificationCenter defaultCenter] postNotificationName:ReloadClassList object:nil];
    }
    else if ([resultDic[@"resultStatus"]integerValue] == 8000){
        //正在处理中
        title=@"支付结果";msg=@"正在处理中";sureTitle=@"确定";
        UIAlertController *qingshuruyonghuming = [UIAlertController alertControllerWithTitle:title message:msg preferredStyle:UIAlertControllerStyleAlert];
        [qingshuruyonghuming addAction:[UIAlertAction actionWithTitle:sureTitle style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        }]];
        [self presentViewController:qingshuruyonghuming animated:YES completion:nil];
    }
    else if ([resultDic[@"resultStatus"]integerValue] == 4000){
        //订单支付失败
        title=@"支付结果";msg=@"返回信息错误，请稍后再试";sureTitle=@"确定";
        UIAlertController *qingshuruyonghuming = [UIAlertController alertControllerWithTitle:title message:msg preferredStyle:UIAlertControllerStyleAlert];
        [qingshuruyonghuming addAction:[UIAlertAction actionWithTitle:sureTitle style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        }]];
        [self presentViewController:qingshuruyonghuming animated:YES completion:nil];
    }
    else if ([resultDic[@"resultStatus"]integerValue] == 6001){
        //用户中途取消
        title=@"支付结果";msg=@"用户中途取消，请稍后再试";sureTitle=@"确定";
        UIAlertController *qingshuruyonghuming = [UIAlertController alertControllerWithTitle:title message:msg preferredStyle:UIAlertControllerStyleAlert];
        [qingshuruyonghuming addAction:[UIAlertAction actionWithTitle:sureTitle style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        }]];
        [self presentViewController:qingshuruyonghuming animated:YES completion:nil];
    }
    else if ([resultDic[@"resultStatus"]integerValue] == 6002){
        //网络连接出错
        title=@"支付结果";msg=@"网络连接出错，请稍后再试";sureTitle=@"确定";
        UIAlertController *qingshuruyonghuming = [UIAlertController alertControllerWithTitle:title message:msg preferredStyle:UIAlertControllerStyleAlert];
        [qingshuruyonghuming addAction:[UIAlertAction actionWithTitle:sureTitle style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        }]];
        [self presentViewController:qingshuruyonghuming animated:YES completion:nil];
    }
    else{
        //
        title=@"支付结果";msg=@"返回信息错误，请稍后再试";sureTitle=@"确定";
        UIAlertController *qingshuruyonghuming = [UIAlertController alertControllerWithTitle:title message:msg preferredStyle:UIAlertControllerStyleAlert];
        [qingshuruyonghuming addAction:[UIAlertAction actionWithTitle:sureTitle style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        }]];
        [self presentViewController:qingshuruyonghuming animated:YES completion:nil];
    }
    //充值成功 --》 获取用户信息
    [[NSNotificationCenter defaultCenter] postNotificationName:@"updateUserInfo" object:nil];

}

- (void)WechatPayResults:(NSNotification *)notification
{
    NSString* title=@"支付结果",*msg=@"您的课程购买成功",*sureTitle=@"确定";
    if ([notification.object integerValue] == 0) {
        zhuboXiangQingVCNewController *faxianzhuboVC = [[zhuboXiangQingVCNewController alloc]init];
        faxianzhuboVC.jiemuDescription = self.jiemuDescription;
        faxianzhuboVC.jiemuFan_num = self.jiemuFan_num;
        faxianzhuboVC.jiemuID = self.jiemuID;
        faxianzhuboVC.jiemuImages = self.jiemuImages;
        faxianzhuboVC.jiemuIs_fan = self.jiemuIs_fan;
        faxianzhuboVC.jiemuMessage_num = self.jiemuMessage_num;
        faxianzhuboVC.jiemuName = self.jiemuName;
        faxianzhuboVC.isfaxian = YES;
        faxianzhuboVC.isClass = YES;
        faxianzhuboVC.listVC = self.listVC;
        [self.navigationController pushViewController:faxianzhuboVC animated:YES];
        
        [[NSNotificationCenter defaultCenter] postNotificationName:ReloadClassList object:nil];
    }
    else if ([notification.object integerValue] == -2){
        title=@"支付结果";msg=@"用户中途取消，请稍后再试";sureTitle=@"确定";
        UIAlertController *qingshuruyonghuming = [UIAlertController alertControllerWithTitle:title message:msg preferredStyle:UIAlertControllerStyleAlert];
        [qingshuruyonghuming addAction:[UIAlertAction actionWithTitle:sureTitle style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        }]];
        [self presentViewController:qingshuruyonghuming animated:YES completion:nil];
    }
    else{
        title=@"支付结果";msg=@"返回信息错误，请稍后再试";sureTitle=@"确定";
        UIAlertController *qingshuruyonghuming = [UIAlertController alertControllerWithTitle:title message:msg preferredStyle:UIAlertControllerStyleAlert];
        [qingshuruyonghuming addAction:[UIAlertAction actionWithTitle:sureTitle style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        }]];
        [self presentViewController:qingshuruyonghuming animated:YES completion:nil];
    }
    //充值成功 --》 获取用户信息
    [[NSNotificationCenter defaultCenter] postNotificationName:@"updateUserInfo" object:nil];
}
#pragma mark - 课程购买弹窗
- (UIButton *)cover
{
    if (_cover == nil) {
        _cover = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_HEIGHT)];
        _cover.backgroundColor = [UIColor clearColor];
        [_cover addTarget:self action:@selector(hide)];
    }
    return _cover;
}
- (UIView *)alertVipSelected
{
    UIView *contentView = [[UIView alloc] initWithFrame:CGRectMake(5, 0, SCREEN_WIDTH - 10, 0)];
    contentView.layer.cornerRadius = 10,
    contentView.layer.borderColor = [UIColor lightGrayColor].CGColor;
    contentView.layer.borderWidth = 0.5;
    contentView.backgroundColor = [UIColor whiteColor];
    
    //九宫格
    // 一行的最大列数
    int maxColsPerRow = 6;
    
    
    NSMutableArray *arrayHeight = [NSMutableArray array];
    //行高
    CGFloat rowH1 = 40;
    CGFloat rowH2 = 60;
    CGFloat rowH3 = 60;
    arrayHeight = [@[@(rowH1),@(rowH2),@(rowH3)] mutableCopy];
    
    NSMutableArray *array = [NSMutableArray array];
    //列宽
    CGFloat colW1 = 30;
    CGFloat colW2 = 70;
    CGFloat colW3 = 45;
    CGFloat colW4 = 70;
    CGFloat colW5 = 80;
    CGFloat colW6 = 45;
    array = [@[@(colW1),@(colW2),@(colW3),@(colW4),@(colW5),@(colW6)] mutableCopy];
    
    UIScrollView *tableView = [[UIScrollView alloc] initWithFrame:CGRectMake(10, 10, SCREEN_WIDTH - 30, [self rowYWithIndex:3])];
    tableView.backgroundColor = [UIColor whiteColor];
    tableView.scrollEnabled = YES;
    tableView.layer.borderWidth = 0.5;
    tableView.layer.borderColor = [UIColor blackColor].CGColor;
    [contentView addSubview:tableView];
    
    for (int i = 0; i<18; i++) {
        // 行号
        int row = i / maxColsPerRow;
        // 列号
        int col = i % maxColsPerRow;
        
        UIView *view = [[UIView alloc] initWithFrame:CGRectMake([self colXWithIndex:col], [self rowYWithIndex:row], [array[col] intValue], [arrayHeight[row] intValue])];
        view.backgroundColor = [UIColor whiteColor];
        view.layer.borderWidth = 0.25;
        view.layer.borderColor = [UIColor lightGrayColor].CGColor;
        [tableView addSubview:view];
        
        UILabel *label = [[UILabel alloc] initWithFrame:view.frame];
        label.numberOfLines = 0;
        label.textAlignment = NSTextAlignmentCenter;
        label.textColor = [UIColor grayColor];
        label.font = [UIFont systemFontOfSize:13.];
        [tableView addSubview:label];
        
        if (i == 6) {
            UIButton *selected = [[UIButton alloc] initWithFrame:view.frame];
            [selected setImage:[UIImage imageNamed:@"vip_noselected"] forState:UIControlStateNormal];
            selected.selected = YES;
            selected.imageView.contentMode = UIViewContentModeCenter;
            selected.accessibilityIdentifier = @"vip";
            [selected setImage:[UIImage imageNamed:@"vip_selected"] forState:UIControlStateSelected];
            [selected addTarget:self action:@selector(vipSelected:)];
            [tableView addSubview:selected];
            VipSelected = selected;
        }else if (i == 12) {
            UIButton *selected = [[UIButton alloc] initWithFrame:view.frame];
            [selected setImage:[UIImage imageNamed:@"vip_noselected"] forState:UIControlStateNormal];
            [selected setImage:[UIImage imageNamed:@"vip_selected"] forState:UIControlStateSelected];
            selected.imageView.contentMode = UIViewContentModeCenter;
            selected.accessibilityIdentifier = @"class";
            [selected addTarget:self action:@selector(vipSelected:)];
            [tableView addSubview:selected];
        }else if (i == 1) {
            label.text = @"名称";
        }else if (i == 2) {
            label.text = @"费用";
        }else if (i == 3) {
            label.text = @"赠送";
        }else if (i == 4) {
            label.text = @"课程内容";
        }else if (i == 5) {
            label.text = @"活动";
        }else if (i == 7) {
            label.text = @"超级会员";
        }else if (i == 8) {
            label.text = @"¥1980";
        }else if (i == 9) {
            label.font = [UIFont systemFontOfSize:12.];
            label.text = @"有声资讯会员\n价值99元";
        }else if (i == 10) {
            label.font = [UIFont systemFontOfSize:12.];
            NSMutableAttributedString *str = [[NSMutableAttributedString alloc] initWithString:@"所有课程免费听\n价值>210234" attributes:@{NSForegroundColorAttributeName:[UIColor lightGrayColor]}];
            [str setAttributes:@{NSForegroundColorAttributeName:ColorWithRGBA(229, 127, 83, 1)} range:NSMakeRange(0, 7)];
            label.attributedText = str;
        }else if (i == 11) {
            label.text = @"VIP席位";
        }else if (i == 13) {
            label.text = @"单个课程";
        }else if (i == 14) {
            label.text = _priceLabel.text;
        }else if (i == 15) {
            label.text = @"无";
        }else if (i == 16) {
            label.font = [UIFont systemFontOfSize:12.];
            label.text = self.classModel.title;
        }else if (i == 17) {
            label.text = @"无";
        }
    }
    
    vipPriceLabel = [[UILabel alloc] initWithFrame:CGRectMake(SCREEN_WIDTH - 15 - 60, CGRectGetMaxY(tableView.frame) + 10, 60, 20)];
    vipPriceLabel.numberOfLines = 0;
    vipPriceLabel.text = @"¥1980";
    vipPriceLabel.textAlignment = NSTextAlignmentCenter;
    vipPriceLabel.textColor = gMainColor;
    vipPriceLabel.font = [UIFont systemFontOfSize:15];
    [contentView addSubview:vipPriceLabel];

    UIButton *commit = [[UIButton alloc] initWithFrame:CGRectMake(SCREEN_WIDTH - 10 - 10 - 50, CGRectGetMaxY(vipPriceLabel.frame) + 5, 50, 25)];
    commit.layer.cornerRadius = commit.height * 0.5;
    commit.layer.borderWidth = 0.5;
    [commit setTitle:@"提交"];
    [commit setTitleColor:[UIColor lightGrayColor]];
    commit.titleLabel.font = [UIFont systemFontOfSize:15];
    commit.layer.borderColor = [UIColor lightGrayColor].CGColor;
    [commit addTarget:self action:@selector(commitSelected)];
    [contentView addSubview:commit];
    
    contentView.height = CGRectGetMaxY(commit.frame) + 10;
    contentView.y = (SCREEN_HEIGHT - contentView.height) * 0.5;
    tableView.contentSize = CGSizeMake([self colXWithIndex:6], 0);
    
    return contentView;
}
- (void)show
{
    [self.navigationController.view addSubview:self.cover];
    _alertVipSelectedView = [self alertVipSelected];
    _alertVipSelectedView.alpha = 0.;
    [self.navigationController.view addSubview:_alertVipSelectedView];
    
    [UIView animateWithDuration:0.5 // 动画时长
                     animations:^{
                         _alertVipSelectedView.alpha = 1.;
                     } completion:^(BOOL finished) {
                     }];
}
- (void)hide{
    [UIView animateWithDuration:0.5 animations:^{
        _alertVipSelectedView.alpha = 0.;
    }completion:^(BOOL finished) {
        [_alertVipSelectedView removeFromSuperview];
        [_cover removeFromSuperview];
    }];
}
/**
 选择购买类型
 */
- (void)vipSelected:(UIButton *)button
{
    VipSelected.selected = NO;
    button.selected = YES;
    VipSelected = button;
    
    vipPriceLabel.text = [VipSelected.accessibilityIdentifier isEqualToString:@"vip"]?@"¥1980":_priceLabel.text;
}

/**
 提交按钮点击
 */
- (void)commitSelected
{
    [self hide];
    _purchaseBtn.enabled = NO;
    if ([[CommonCode readFromUserD:@"isIAP"] boolValue] == YES)
    {//当前为内购路线
        
        APPDELEGATE.payType = PayTypeClassPay;
        [CommonCode writeToUserD:orderNum andKey:@"orderNumber"];
        _alertView = [[CustomAlertView alloc] initWithCustomView:[self setupPayAlertWithIAP:YES]];
        _alertView.alertHeight = 105;
        _alertView.alertDuration = 0.25;
        _alertView.coverAlpha = 0.6;
        [_alertView show];
        _purchaseBtn.enabled = YES;
        
    }
    else
    {//当前为支付宝，微信，支付路线
        if ([[CommonCode readFromUserD:@"isLogin"]boolValue] == YES){
            if ([VipSelected.accessibilityIdentifier isEqualToString:@"vip"]) {
                APPDELEGATE.payType = PayTypeMembers;
                _alertView = [[CustomAlertView alloc] initWithCustomView:[self setupPayAlertWithIAP:NO]];
                _alertView.alertHeight = 155;
                _alertView.alertDuration = 0.25;
                _alertView.coverAlpha = 0.6;
                [_alertView show];
                _purchaseBtn.enabled = YES;
            }else{
                APPDELEGATE.payType = PayTypeClassPay;
                _alertView = [[CustomAlertView alloc] initWithCustomView:[self setupPayAlertWithIAP:NO]];
                _alertView.alertHeight = 155;
                _alertView.alertDuration = 0.25;
                _alertView.coverAlpha = 0.6;
                [_alertView show];
                _purchaseBtn.enabled = YES;
            }
        }
        else{
            _purchaseBtn.enabled = YES;
            [self loginFirst];
        }
    }
}
- (CGFloat)rowYWithIndex:(int)index
{
    CGFloat Y = 0;
    NSMutableArray *array = [NSMutableArray array];
    //行高
    CGFloat rowH1 = 40;
    CGFloat rowH2 = 60;
    CGFloat rowH3 = 60;
    array = [@[@(rowH1),@(rowH2),@(rowH3)] mutableCopy];
    for (int i = 0; i<index; i++) {
        Y += [array[i] intValue];
    }
    return Y;
}
- (CGFloat)colXWithIndex:(int)index
{
    CGFloat X = 0;
    NSMutableArray *array = [NSMutableArray array];
    //列宽
    CGFloat colW1 = 30;
    CGFloat colW2 = 70;
    CGFloat colW3 = 45;
    CGFloat colW4 = 70;
    CGFloat colW5 = 80;
    CGFloat colW6 = 45;
    array = [@[@(colW1),@(colW2),@(colW3),@(colW4),@(colW5),@(colW6)] mutableCopy];
    for (int i = 0; i<index; i++) {
        X += [array[i] intValue];
    }
    return X;
}
#pragma mark - 会员支付结果通知方法
- (void)AliPayResultsMembers:(NSNotification *)notification
{
    NSString* title=@"支付结果",*msg=@"您的会员已开通成功",*sureTitle=@"确定";
    NSDictionary *resultDic = notification.object;
    if ([resultDic[@"resultStatus"]integerValue] == 9000) {
        
        UIAlertController *qingshuruyonghuming = [UIAlertController alertControllerWithTitle:title message:msg preferredStyle:UIAlertControllerStyleAlert];
        [qingshuruyonghuming addAction:[UIAlertAction actionWithTitle:sureTitle style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            zhuboXiangQingVCNewController *faxianzhuboVC = [[zhuboXiangQingVCNewController alloc]init];
            faxianzhuboVC.jiemuDescription = self.jiemuDescription;
            faxianzhuboVC.jiemuFan_num = self.jiemuFan_num;
            faxianzhuboVC.jiemuID = self.jiemuID;
            faxianzhuboVC.jiemuImages = self.jiemuImages;
            faxianzhuboVC.jiemuIs_fan = self.jiemuIs_fan;
            faxianzhuboVC.jiemuMessage_num = self.jiemuMessage_num;
            faxianzhuboVC.jiemuName = self.jiemuName;
            faxianzhuboVC.isfaxian = YES;
            faxianzhuboVC.isClass = YES;
            faxianzhuboVC.listVC = self.listVC;
            [self.navigationController pushViewController:faxianzhuboVC animated:YES];
            [[NSNotificationCenter defaultCenter] postNotificationName:ReloadClassList object:nil];

        }]];
        [self presentViewController:qingshuruyonghuming animated:YES completion:nil];
        
    }
    else if ([resultDic[@"resultStatus"]integerValue] == 8000){
        //正在处理中
        title=@"支付结果";msg=@"正在处理中";sureTitle=@"确定";
        UIAlertController *qingshuruyonghuming = [UIAlertController alertControllerWithTitle:title message:msg preferredStyle:UIAlertControllerStyleAlert];
        [qingshuruyonghuming addAction:[UIAlertAction actionWithTitle:sureTitle style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        }]];
        [self presentViewController:qingshuruyonghuming animated:YES completion:nil];
    }
    else if ([resultDic[@"resultStatus"]integerValue] == 4000){
        //订单支付失败
        title=@"支付结果";msg=@"返回信息错误，请稍后再试";sureTitle=@"确定";
        UIAlertController *qingshuruyonghuming = [UIAlertController alertControllerWithTitle:title message:msg preferredStyle:UIAlertControllerStyleAlert];
        [qingshuruyonghuming addAction:[UIAlertAction actionWithTitle:sureTitle style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        }]];
        [self presentViewController:qingshuruyonghuming animated:YES completion:nil];
    }
    else if ([resultDic[@"resultStatus"]integerValue] == 6001){
        //用户中途取消
        title=@"支付结果";msg=@"用户中途取消，请稍后再试";sureTitle=@"确定";
        UIAlertController *qingshuruyonghuming = [UIAlertController alertControllerWithTitle:title message:msg preferredStyle:UIAlertControllerStyleAlert];
        [qingshuruyonghuming addAction:[UIAlertAction actionWithTitle:sureTitle style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        }]];
        [self presentViewController:qingshuruyonghuming animated:YES completion:nil];
    }
    else if ([resultDic[@"resultStatus"]integerValue] == 6002){
        //网络连接出错
        title=@"支付结果";msg=@"网络连接出错，请稍后再试";sureTitle=@"确定";
        UIAlertController *qingshuruyonghuming = [UIAlertController alertControllerWithTitle:title message:msg preferredStyle:UIAlertControllerStyleAlert];
        [qingshuruyonghuming addAction:[UIAlertAction actionWithTitle:sureTitle style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        }]];
        [self presentViewController:qingshuruyonghuming animated:YES completion:nil];
    }
    else{
        //
        title=@"支付结果";msg=@"返回信息错误，请稍后再试";sureTitle=@"确定";
        UIAlertController *qingshuruyonghuming = [UIAlertController alertControllerWithTitle:title message:msg preferredStyle:UIAlertControllerStyleAlert];
        [qingshuruyonghuming addAction:[UIAlertAction actionWithTitle:sureTitle style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        }]];
        [self presentViewController:qingshuruyonghuming animated:YES completion:nil];
    }
    //充值成功 --》 获取用户信息
    [[NSNotificationCenter defaultCenter] postNotificationName:@"updateUserInfo" object:nil];
}

- (void)WechatPayResultsMembers:(NSNotification *)notification
{
    NSString* title=@"支付结果",*msg=@"您的会员已开通成功",*sureTitle=@"确定";
    if ([notification.object integerValue] == 0) {
        UIAlertController *qingshuruyonghuming = [UIAlertController alertControllerWithTitle:title message:msg preferredStyle:UIAlertControllerStyleAlert];
        [qingshuruyonghuming addAction:[UIAlertAction actionWithTitle:sureTitle style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            zhuboXiangQingVCNewController *faxianzhuboVC = [[zhuboXiangQingVCNewController alloc]init];
            faxianzhuboVC.jiemuDescription = self.jiemuDescription;
            faxianzhuboVC.jiemuFan_num = self.jiemuFan_num;
            faxianzhuboVC.jiemuID = self.jiemuID;
            faxianzhuboVC.jiemuImages = self.jiemuImages;
            faxianzhuboVC.jiemuIs_fan = self.jiemuIs_fan;
            faxianzhuboVC.jiemuMessage_num = self.jiemuMessage_num;
            faxianzhuboVC.jiemuName = self.jiemuName;
            faxianzhuboVC.isfaxian = YES;
            faxianzhuboVC.isClass = YES;
            faxianzhuboVC.listVC = self.listVC;
            [self.navigationController pushViewController:faxianzhuboVC animated:YES];
            [[NSNotificationCenter defaultCenter] postNotificationName:ReloadClassList object:nil];
        }]];
        [self presentViewController:qingshuruyonghuming animated:YES completion:nil];
    }
    else if ([notification.object integerValue] == -2){
        title=@"支付结果";msg=@"用户中途取消，请稍后再试";sureTitle=@"确定";
        UIAlertController *qingshuruyonghuming = [UIAlertController alertControllerWithTitle:title message:msg preferredStyle:UIAlertControllerStyleAlert];
        [qingshuruyonghuming addAction:[UIAlertAction actionWithTitle:sureTitle style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        }]];
        [self presentViewController:qingshuruyonghuming animated:YES completion:nil];
    }
    else{
        title=@"支付结果";msg=@"返回信息错误，请稍后再试";sureTitle=@"确定";
        UIAlertController *qingshuruyonghuming = [UIAlertController alertControllerWithTitle:title message:msg preferredStyle:UIAlertControllerStyleAlert];
        [qingshuruyonghuming addAction:[UIAlertAction actionWithTitle:sureTitle style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        }]];
        [self presentViewController:qingshuruyonghuming animated:YES completion:nil];
    }
    //充值成功 --》 获取用户信息
    [[NSNotificationCenter defaultCenter] postNotificationName:@"updateUserInfo" object:nil];
}
@end
