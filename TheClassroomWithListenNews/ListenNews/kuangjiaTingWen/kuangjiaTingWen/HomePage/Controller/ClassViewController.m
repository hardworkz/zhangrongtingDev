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



@interface ClassViewController ()<UITableViewDelegate,UITableViewDataSource,UITextViewDelegate,TTTAttributedLabelDelegate>{
    UIView *xiangqingView;
    UILabel *PingLundianzanNumLab;
    NSInteger playIndex;
    NSString *currentClassID;
    UITextView *zhengwenTextView;
    NSString *rewardMoney;
    NSString *orderNum;
}
@property (strong, nonatomic) CustomAlertView *alertView;
@property (nonatomic, strong) UITableView *helpTableView;
@property (nonatomic, strong) NSMutableArray *buttons;
@property (nonatomic, strong) NSMutableArray *dataSourceArr;
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
@property (strong, nonatomic) AVPlayer *voicePlayer;
@property (strong, nonatomic) AVAudioSession *session;
@property (assign, nonatomic) BOOL isPlaying;
@property (assign, nonatomic) NSInteger playingIndex;

@end

@implementation ClassViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    currentClassID = [CommonCode readFromUserD:@"currentClassID"];
    if ([currentClassID isEqualToString:self.act_id]) {
        playIndex = [[CommonCode readFromUserD:@"playIndex"] integerValue];
    }else{
        playIndex = 0;
    }
    [self setUpData];
    [self setUpView];
}

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    self.hidesBottomBarWhenPushed = YES;
    [self.navigationController setNavigationBarHidden:YES animated:YES];
}

- (void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    [self.navigationController setNavigationBarHidden:NO animated:YES];
//    [Explayer pause];
    if (_isPlaying) {
        [self auditionnBtnAction:_auditionnBtn];
    }
}

- (void)setUpData{
    _pinglunArr = [NSMutableArray new];
    _dataSourceArr = [NSMutableArray new];
    _ImageSizeArr = [NSMutableArray new];
    [self loadData];
    
    _isPlaying = NO;
    _playingIndex = -1;
    ExisRigester = NO;
    //AudioSession负责应用音频的设置，比如支不支持后台，打断等等
    NSError *error;
    //设置音频会话
    self.session = [AVAudioSession sharedInstance];
    //AVAudioSessionCategoryPlayback一般用于支持后台播放
    [self.session setCategory:AVAudioSessionCategoryPlayback error:&error];
    //激活会话
    [self.session setActive:YES error:&error];
    //接收播放完毕后发出的通知
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(voicePlayEnd:) name:AVPlayerItemDidPlayToEndTimeNotification object:Explayer.currentItem];
    
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
    [self.view addSubview:self.collectBtn];
    UIView *verticalLine = [[UIView alloc]initWithFrame:CGRectMake(SCREEN_WIDTH/4, CGRectGetMaxY(self.helpTableView.frame) + 8, 1.0, 33)];
    [verticalLine setBackgroundColor:gThickLineColor];
    [self.view addSubview:verticalLine];
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
            ExisRigester = NO;
            self.classModel = [ClassModel mj_objectWithKeyValues:responseObject[@"results"]];
            self.frameArray = [self frameArrayWithClassModel:self.classModel];
            self.pinglunArr = [self pinglunFrameModelArrayWithModelArray:[PlayVCCommentModel mj_objectArrayWithKeyValuesArray:responseObject[@"results"][@"comments"]]];
            [self setTableHeadView];
            [self.helpTableView reloadData];
            
            NSString *textStr = [NSString stringWithFormat:@"￥%@ ",responseObject[@"results"][@"sprice"]];
            //中划线
            NSDictionary *attribtDic = @{NSStrikethroughStyleAttributeName: [NSNumber numberWithInteger:NSUnderlineStyleSingle]};
            NSMutableAttributedString *attribtStr = [[NSMutableAttributedString alloc]initWithString:textStr attributes:attribtDic];
            // 赋值
            self.spriceLabel.attributedText = attribtStr;
            self.priceLabel.text = [NSString stringWithFormat:@"￥%@",responseObject[@"results"][@"price"]];
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
    NSMutableArray *array = [NSMutableArray array];
    //课堂内容frame
    ClassContentCellFrameModel *contentFrameModel = [ClassContentCellFrameModel new];
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
//    [Explayer pause];
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
    titleLab.font = [UIFont fontWithName:@"Semibold" size:19];
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
        switch (Explayer.status) {
            case AVPlayerStatusUnknown:
                NSLog(@"KVO：未知状态，此时不能播放");
                break;
            case AVPlayerStatusReadyToPlay:
                NSLog(@"KVO：准备完毕，可以播放");
                //自动播放
                //                [Explayer play];
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
    if (_playingIndex < [self.classModel.shiting count] - 1) {
        UIButton *nextTextMPButton = self.buttons[_playingIndex + 1];
        [self playTestMp:nextTextMPButton];
    }
    else{
        [self performSelector:@selector(wanbi:) withObject:notice afterDelay:0.5f];
        _isPlaying = NO;
    }
}

- (void)wanbi:(NSNotification *)notice{
    
    if (ExisRigester == YES){
        //        [Explayer removeObserver:self forKeyPath:@"statu"];
        //        [Explayer removeObserver:self forKeyPath:@"loadedTimeRange"];
        ExisRigester = NO;
    }
    [Explayer pause];
    [CommonCode writeToUserD:@"YES" andKey:TINGYOUQUANBOFANGWANBI];
    _isPlaying = NO;
}

- (void)dealloc {
    [CommonCode writeToUserD:self.act_id andKey:@"currentClassID"];
    [CommonCode writeToUserD:[NSString stringWithFormat:@"%ld",playIndex] andKey:@"playIndex"];
}

#pragma mark - UIButtonAction
- (void)collectBtnAction:(UIButton *)sender{
    XWAlerLoginView *xw = [[XWAlerLoginView alloc]initWithTitle:@"购买了才能订阅哦~"];
    [xw show];
}
//点击底部试听按钮
- (void)auditionnBtnAction:(UIButton *)sender{
    [[NSNotificationCenter defaultCenter] postNotificationName:@"stopAnimate" object:nil];
    if (sender.selected == YES) {//选中状态，为播放状态,则将列表按钮设置全部设置为暂停
        sender.selected = NO;
        for ( int i = 0 ; i < self.buttons.count; i ++ ) {
                UIButton *anotherButton = self.buttons[i];
                anotherButton.selected = NO;
                continue;
        }
        [Explayer pause];
        _isPlaying = NO;
    }
    else{//未选中状态，为暂停状态,判断当前播放第几个按钮，设置播放状态
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
        [Explayer pause];
        if (Explayer == nil) {
            Explayer = [[AVPlayer alloc]init];
        }
        ClassAuditionListModel *auditionModel = [self.classModel.shiting firstObject];
        [Explayer replaceCurrentItemWithPlayerItem:[[AVPlayerItem alloc]initWithURL:[NSURL URLWithString:auditionModel.s_mpurl]]];
        
        [Explayer play];
        _isPlaying = YES;
        _playingIndex = 0;
        [CommonCode writeToUserD:@"YES" andKey:TINGYOUQUANBOFANGWANBI];
        if (ExisRigester == NO){
            ExisRigester = YES;
        }
    }
    
}
- (void)purchaseBtnAction:(UIButton *)sender{
    if ([[CommonCode readFromUserD:@"isLogin"]boolValue] == YES){
        if ([[CommonCode readFromUserD:@"isIAP"] boolValue] == YES)
        {//当前为内购路线
            
            _alertView = [[CustomAlertView alloc] initWithCustomView:[self setupPayAlertWithIAP:YES]];
            _alertView.alertHeight = 105;
            _alertView.alertDuration = 0.25;
            _alertView.coverAlpha = 0.6;
            [_alertView show];
        }
        else
        {//当前为支付宝，微信，听币支付路线
            [NetWorkTool get_orderWithaccessToken:AvatarAccessToken act_id:self.classModel.act_id sccess:^(NSDictionary *responseObject) {
                RTLog(@"%@",responseObject);
                if ([responseObject[@"status"] intValue] == 1) {
                    rewardMoney = responseObject[@"results"][@"money"];
                    orderNum = responseObject[@"results"][@"order_num"];
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
    }
    else{
        [self loginFirst];
    }
}
//创建支付弹窗view
- (UIView *)setupPayAlertWithIAP:(BOOL)iap
{
    if (iap) {
        UIView *bgView = [[UIView alloc] init];
        bgView.backgroundColor = HEXCOLOR(0xe3e3e3);
        bgView.frame = CGRectMake(0, 0, SCREEN_WIDTH, 105);
        
        UIButton *deleteBtn = [[UIButton alloc] init];
        deleteBtn.frame = CGRectMake(0, 0, SCREEN_WIDTH, 50);
        deleteBtn.backgroundColor = [UIColor whiteColor];
        [deleteBtn setTitle:@"听币支付" forState:UIControlStateNormal];
        [deleteBtn setTitleColor:gMainColor forState:UIControlStateNormal];
        deleteBtn.titleLabel.font = [UIFont systemFontOfSize:17];
        [deleteBtn addTarget:self action:@selector(tingbiBtnClicked)];
        [bgView addSubview:deleteBtn];
        
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
        [zhifubaoBtn setTitle:@"支付宝支付" forState:UIControlStateNormal];
        [zhifubaoBtn setTitleColor:gMainColor forState:UIControlStateNormal];
        zhifubaoBtn.titleLabel.font = [UIFont systemFontOfSize:17];
        [zhifubaoBtn addTarget:self action:@selector(zhifubaoBtnClicked)];
        [bgView addSubview:zhifubaoBtn];
        
        UIButton *weixinBtn = [[UIButton alloc] init];
        weixinBtn.frame = CGRectMake(0, 0, SCREEN_WIDTH, 50);
        weixinBtn.backgroundColor = [UIColor whiteColor];
        [weixinBtn setTitle:@"微信支付" forState:UIControlStateNormal];
        [weixinBtn setTitleColor:gMainColor forState:UIControlStateNormal];
        weixinBtn.titleLabel.font = [UIFont systemFontOfSize:17];
        [weixinBtn addTarget:self action:@selector(weixinBtnClicked)];
        [bgView addSubview:weixinBtn];
        
        UIButton *tingbiBtn = [[UIButton alloc] init];
        tingbiBtn.frame = CGRectMake(0, 0, SCREEN_WIDTH, 50);
        tingbiBtn.backgroundColor = [UIColor whiteColor];
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
    }
}
//支付宝支付
- (void)zhifubaoBtnClicked
{
    PayOnlineViewController *vc = [PayOnlineViewController new];
    vc.rewardCount = [rewardMoney floatValue];
    vc.uid = self.classModel.act_id;
    vc.post_id = self.classModel.ID;
    vc.isPayClass = YES;
    [vc AliPay];
}
//微信支付
- (void)weixinBtnClicked
{
    PayOnlineViewController *vc = [PayOnlineViewController new];
    vc.rewardCount = [rewardMoney floatValue];
    vc.uid = self.classModel.act_id;
    vc.post_id = self.classModel.ID;
    vc.isPayClass = YES;
    [vc WechatPay];
}
//听币支付
- (void)tingbiBtnClicked
{
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
                        [self.navigationController popViewControllerAnimated:YES];
                    }else{
                        XWAlerLoginView *xw = [[XWAlerLoginView alloc]initWithTitle:@"课程购买失败"];
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
    [_alertView coverClick];
}
//列表试听按钮点击
- (void)playTestMp:(UIButton *)sender{
    [[NSNotificationCenter defaultCenter] postNotificationName:@"stopAnimate" object:nil];
    BOOL isTestMpPlay = NO;//判断是否在试听列表里面有选中的按钮正在播放
    for ( int i = 0 ; i < self.buttons.count; i ++ ) {
        UIButton *allDoneButton = self.buttons[i];
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
    if (isTestMpPlay) {
        [self.auditionnBtn setSelected:YES];
    }
    else{
        [self.auditionnBtn setSelected:NO];
    }
    //播放试听音频
    if (_isPlaying && (_playingIndex == sender.tag)) {
        [Explayer pause];
        _isPlaying = NO;
    }
    else{
        if ([bofangVC shareInstance].isPlay) {
            [[bofangVC shareInstance] doplay2];
        }
        else{
            
        }
        [Explayer pause];
        if (Explayer == nil) {
            Explayer = [[AVPlayer alloc]init];
            //添加观察者，用来监视播放器的状态变化
//            [Explayer addObserver:self forKeyPath:@"statu" options:NSKeyValueObservingOptionNew context:nil];
            //添加观察者，用来监听播放器的缓冲进度loadedTimeRanges属性
            //            [Explayer addObserver:self forKeyPath:@"loadedTimeRanges" options:NSKeyValueObservingOptionNew context:nil];
        }
        
        ClassAuditionListModel *auditionModel = self.classModel.shiting[sender.tag];
        [Explayer replaceCurrentItemWithPlayerItem:[[AVPlayerItem alloc]initWithURL:[NSURL URLWithString:auditionModel.s_mpurl]]];
        [Explayer play];
        _isPlaying = YES;
        _playingIndex = sender.tag;
        [CommonCode writeToUserD:@"YES" andKey:TINGYOUQUANBOFANGWANBI];
        if (ExisRigester == NO){
            //添加观察者，用来监视播放器的状态变化
//            [Explayer addObserver:self forKeyPath:@"statu" options:NSKeyValueObservingOptionNew context:nil];
            //添加观察者，用来监听播放器的缓冲进度loadedTimeRanges属性
            //[Explayer addObserver:self forKeyPath:@"loadedTimeRange" options:NSKeyValueObservingOptionNew context:nil];
            ExisRigester = YES;
        }
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
        cell.playingIndex = _playingIndex;
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
        cell.isClassComment = YES;
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
        [_auditionnBtn setFrame:CGRectMake(SCREEN_WIDTH / 4, SCREEN_HEIGHT - 49, SCREEN_WIDTH / 4, 49)];
        [_auditionnBtn setImage:[UIImage imageNamed:@"classpause"] forState:UIControlStateNormal];
        [_auditionnBtn setImage:[UIImage imageNamed:@"classplay"] forState:UIControlStateSelected];
        [_auditionnBtn setTitle:@"试听" forState:UIControlStateNormal];
        [_auditionnBtn setTitleColor:nTextColorMain forState:UIControlStateNormal];
        [_auditionnBtn addTarget:self action:@selector(auditionnBtnAction:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _auditionnBtn;
}

-(UILabel *)priceLabel{
    if (!_priceLabel) {
        _priceLabel = [[UILabel alloc]initWithFrame:CGRectMake(SCREEN_WIDTH / 4, 0, SCREEN_WIDTH / 4, 25)];
        [_priceLabel setBackgroundColor:purchaseButtonColor];
        [_priceLabel setTextColor:[UIColor whiteColor]];
    }
    return _priceLabel;
}

-(UILabel *)spriceLabel{
    if (!_spriceLabel) {
        _spriceLabel = [[UILabel alloc]initWithFrame:CGRectMake(SCREEN_WIDTH / 4, 25, SCREEN_WIDTH / 4, 24)];
        [_spriceLabel setBackgroundColor:purchaseButtonColor];
        [_spriceLabel setTextColor:[UIColor whiteColor]];
        _spriceLabel.font = gFontMain14;
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

- (AVPlayer *)voicePlayer {
    if (!_voicePlayer) {
        _voicePlayer = [[AVPlayer alloc]init];
    }
    return _voicePlayer;
}

- (NSMutableArray *)dataSourceArr{
    if (!_dataSourceArr) {
        _dataSourceArr = [NSMutableArray array];
    }
    return _dataSourceArr;
}
- (NSMutableArray *)frameArray
{
    if (_frameArray == nil) {
        _frameArray = [NSMutableArray array];
    }
    return _frameArray;
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
@end
