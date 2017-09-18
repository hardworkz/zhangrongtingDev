//
//  gerenzhuyeVC.m
//  reHeardTheNews
//
//  Created by Pop Web on 16/3/18.
//  Copyright © 2016年 paoguo. All rights reserved.
//

#import "gerenzhuyeVC.h"
#import "titleImageVC.h"
#import "UIImageView+WebCache.h"
#import "wodeguanzhuVC.h"
#import "fensiliebiaoVC.h"
#import "MJRefresh.h"
#import "SDPhotoBrowser.h"
#import "NSDate+TimeFormat.h"
#import "BlobNewTableViewCell.h"
#import "bofangVC.h"
#import "LoginNavC.h"
#import "LoginVC.h"
#import "UIAlertView+MKBlockAdditions.h"
#import "PhotoBrowserController.h"
#import "UIView+AnimationOptionsForCurve.h"
#import "PersonalUnreadViewController.h"
#import "HelpCenterQAViewController.h"
#import "UIView+tap.h"
#import "SingleWebViewController.h"
#import "UIActionSheet+MKBlockAdditions.h"

#define IMAGEHEIGHT (273.0)
@interface gerenzhuyeVC ()<UITableViewDataSource,UITableViewDelegate,UITextViewDelegate,UITextFieldDelegate,TTTAttributedLabelDelegate,UIGestureRecognizerDelegate>
{
    NSMutableArray *arr;
    int numberPage;
    UIImageView *topBgView;
    UIImageView *titleImgV;
    UILabel *nameLab;
    UILabel *jianjieLab;
    UILabel *guanzhuLab;
    UILabel *fensiLab;
    UILabel *guanzhuNum;
    UILabel *fensiNum;
    UIView  *topBgCleanView;
    NSArray *guanzhuliebiao;
    NSArray *fensiliebiao;
    NSArray *wodepinglunliebiao;
    UIImageView *titleImg;
    UIView *HeaderViewBg;
    UIButton *topLeftBtn;       //顶栏左侧按钮
    UIButton *topRightBtn;      //顶栏右侧按钮
    UIView *topSlipLine;        //顶栏滑动线
    UIButton *attentionBtn;
}
@property (weak, nonatomic) UIScrollView *scrollView;
@property (weak, nonatomic) UIImageView *lastImageView;
@property (nonatomic)CGRect originalFrame;
@property (nonatomic)BOOL isDoubleTap;
@property(strong,nonatomic)UITableView *zhuyetableView;
@property(strong,nonatomic)NSMutableArray *infoArr;

@property (assign, nonatomic) NSInteger attentionCount;
@property (assign, nonatomic) NSInteger fanCount;

@property (strong, nonatomic) UIView *toolBarView;
@property (strong, nonatomic) UITextField *commentTextField;
@property (strong, nonatomic) UIButton *sentCommentButton;
@property (strong, nonatomic) NSString *commentTextStr;
@property (strong, nonatomic) UITableViewCell *commentCell;
@property (assign, nonatomic) BOOL isReplyComment;
@property (strong, nonatomic) NSString *replyComment_tuid;

@property (assign, nonatomic) BOOL isToEditInfomation;

@property (strong, nonatomic) UIButton *newMessageButton;
@property (strong, nonatomic) UIImageView *newMessageImage;
@property (strong, nonatomic) UILabel *newMessageTipsLabel;

@property (assign, nonatomic) BOOL isFan;

@property (strong, nonatomic) NSString *friendsLv;

//@property(strong,nonatomic)NSMutableArray *cellArr;
@end

@implementation gerenzhuyeVC
- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    [IQKeyboardManager sharedManager].enable = NO;
}
- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self setupData];
    [self setupView];
}


- (void)setupData {
    
    if (self.isMypersonalPage || self.isNewsComment) {
//        [self loadData];
    }
    _isFan = NO;
    _friendsLv = @"1";
    DefineWeakSelf;
    if (!self.isMypersonalPage) {
        //获取用户信息
        [NetWorkTool getMyuserinfoWithaccessToken:nil user_id:self.user_id sccess:^(NSDictionary *responseObject) {
            _friendsLv = responseObject[results][@"level"];
            [weakSelf TopUI];
            fensiNum.text = responseObject[results][@"fan_num"];
            guanzhuNum.text = responseObject[results][@"guan_num"];
            self.user_login = responseObject[results][@"user_login"];
            [self.zhuyetableView.mj_header beginRefreshing];
            
        } failure:^(NSError *error) {
            //
             [weakSelf TopUI];
            fensiNum.text = @"0";
            guanzhuNum.text = @"0";
        }];
        
        if ([[CommonCode readFromUserD:@"isLogin"]boolValue] == YES){
            [NetWorkTool getPaoGuoGuanZhuLieBiaoWithaccessToken:AvatarAccessToken andPage:@"1" andLimit:@"99999" sccess:^(NSDictionary *responseObject) {
                if ([responseObject[results] isKindOfClass:[NSArray class]]){
                    NSArray *resultArr = responseObject[results];
                    for (int i = 0 ; i < [resultArr count]; i ++) {
                        if ([resultArr[i][@"user_login"] isEqualToString:self.user_login]) {
                            _isFan = YES;
                            [attentionBtn setImage:[UIImage imageNamed:@"card_icon_unfollow_white"] forState:UIControlStateNormal];
                            break;
                        }
                        else{
                            continue;
                        }
                        _isFan = NO;
                        [attentionBtn setImage:[UIImage imageNamed:@"card_icon_addattention_white"] forState:UIControlStateNormal];
                    }
                }
                else{
                    //没有粉丝
                    _isFan = NO;
                    [attentionBtn setImage:[UIImage imageNamed:@"add_attention"] forState:UIControlStateNormal];
                }
                
            } failure:^(NSError *error) {
                NSLog(@"%@",error);
            }];
        }
        else{
            //没有登录
            _isFan = NO;
            [attentionBtn setImage:[UIImage imageNamed:@"add_attention"] forState:UIControlStateNormal];
        }
        
    }
    else{
        [weakSelf TopUI];
        self.user_login = ExdangqianUser;
        NSMutableDictionary *myUserInfo = [CommonCode readFromUserD:@"dangqianUserInfo"];
        fensiNum.text = myUserInfo[results][@"fan_num"];
        guanzhuNum.text = myUserInfo[results][@"guan_num"];
        [self refreshData];
        [self.zhuyetableView.mj_header beginRefreshing];
    }
    
    arr = [[NSMutableArray alloc]init];
    numberPage = 1;
    self.edgesForExtendedLayout = UIRectEdgeNone;
    
    wodepinglunliebiao = [NSArray arrayWithArray:[CommonCode readFromUserD:[NSString stringWithFormat:@"%@wodepinglun",ExdangqianUser]]];
    
    if ([[CommonCode readFromUserD:[NSString stringWithFormat:@"%@wodepinglun",ExdangqianUser]] isKindOfClass:[NSArray class]]){
        self.infoArr = [NSMutableArray arrayWithArray:[CommonCode readFromUserD:[NSString stringWithFormat:@"%@wodepinglun",ExdangqianUser]]];
    }
    
    if ([[CommonCode readFromUserD:[NSString stringWithFormat:@"%@wodepinglun",ExdangqianUser]] isKindOfClass:[NSArray class]]){
        
        [arr removeAllObjects];
        
        [arr addObjectsFromArray:[CommonCode readFromUserD:[NSString stringWithFormat:@"%@wodepinglun",ExdangqianUser]]];
    }
}

- (void)setupView {
    
//    [self TopUI];
    [self.view addSubview:self.zhuyetableView];
    
    UISwipeGestureRecognizer *rightSwipe = [[UISwipeGestureRecognizer alloc]initWithTarget:self action:@selector(rightSwipeAction)];
    [rightSwipe setDirection:UISwipeGestureRecognizerDirectionRight];
    [self.zhuyetableView addGestureRecognizer:rightSwipe];
    UISwipeGestureRecognizer *rightSwipe2 = [[UISwipeGestureRecognizer alloc]initWithTarget:self action:@selector(rightSwipeAction)];
    [rightSwipe2 setDirection:UISwipeGestureRecognizerDirectionRight];
    [topBgView addGestureRecognizer:rightSwipe2];
    
    DefineWeakSelf;
    weakSelf.zhuyetableView.mj_header = [MJRefreshNormalHeader headerWithRefreshingBlock:^{
        [weakSelf refreshData];
    }];
    weakSelf.zhuyetableView.mj_footer = [MJRefreshAutoStateFooter footerWithRefreshingBlock:^{
        [weakSelf shangLaJiaZai];
    }];
    
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    _isToEditInfomation = NO;
    [self.navigationController setNavigationBarHidden:YES animated:YES];
    self.hidesBottomBarWhenPushed = YES;
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(handleWillShowKeyboard:)
                                                 name:UIKeyboardWillShowNotification
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(handleWillHideKeyboard:)
                                                 name:UIKeyboardWillHideNotification
                                               object:nil];
    
    NSString *lastReadTime = [CommonCode readFromUserD:PERSONALLASTREAD];
    [NetWorkTool getAddcriticismNumWithaccessToken:AvatarAccessToken andpage:@"1" andlimit:@"100" anddate:lastReadTime sccess:^(NSDictionary *responseObject) {
        if ([responseObject[@"status"] integerValue] == 1) {
            if ([responseObject[results] isKindOfClass:[NSArray class]]){
                [CommonCode writeToUserD:responseObject[results] andKey:ADDCRITICISMNUMDATAKEY];
            }
            else{
                [CommonCode writeToUserD:nil andKey:ADDCRITICISMNUMDATAKEY];
            }
        }
        NSArray *Addcriticism = [CommonCode readFromUserD:ADDCRITICISMNUMDATAKEY];
        if ([Addcriticism count] && self.isMypersonalPage) {
            [self.newMessageButton setHidden:NO];
            [self.newMessageTipsLabel setText:[NSString stringWithFormat:@"%ld则新消息",[Addcriticism count]]];
            //头像url处理
            if ([NEWSSEMTPHOTOURL([Addcriticism firstObject][@"to_avatar"])  rangeOfString:@"http"].location != NSNotFound){
                [self.newMessageImage sd_setImageWithURL:[NSURL URLWithString:[Addcriticism firstObject][@"to_avatar"]] placeholderImage:AvatarPlaceHolderImage];
            }
            else{
                NSString *str = USERPHOTOHTTPSTRING([Addcriticism firstObject][@"to_avatar"]);
                [self.newMessageImage sd_setImageWithURL:[NSURL URLWithString:str] placeholderImage:AvatarPlaceHolderImage];
            }
        }
        else{
            self.zhuyetableView.tableHeaderView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, IMAGEHEIGHT / 667 * IPHONE_H )];
            [self.zhuyetableView.tableHeaderView addSubview:topBgView];
            [self.newMessageButton setHidden:YES];
            [self.zhuyetableView.tableHeaderView addSubview:self.newMessageButton];
        }
        [self.zhuyetableView reloadData];
        
    } failure:^(NSError *error) {
        
    }];
}

- (void)viewDidDisappear:(BOOL)animated{
    [super viewDidDisappear:animated];
    if (_isToEditInfomation){
        [self.navigationController setNavigationBarHidden:NO animated:YES];
    }
    else{
        [self.navigationController setNavigationBarHidden:YES animated:YES];
    }
}

- (void)TopUI {
    
    topBgView = [[UIImageView alloc]initWithFrame:CGRectMake(0, 0, IPHONE_W, IMAGEHEIGHT / 667 * IPHONE_H)];
//    topBgView.contentMode = UIViewContentModeScaleAspectFill;
//    //图片高斯模糊处理
//    CIContext *context = [CIContext contextWithOptions:nil];
//    CIImage *inputImage = [[CIImage alloc] initWithImage:[UIImage imageNamed:@"top_bg"]];
//    CIFilter *filter = [CIFilter filterWithName:@"CIGaussianBlur"];
//    [filter setValue:inputImage forKey:kCIInputImageKey];
//    [filter setValue:[NSNumber numberWithFloat:15.0] forKey:@"inputRadius"];
//    //        CIImage *result = [filter valueForKey:kCIOutputImageKey];
//    CIImage *result=[filter outputImage];
//    CGImageRef cgImage = [context createCGImage:result fromRect:[inputImage extent]];
//    UIImage *image = [UIImage imageWithCGImage:cgImage];
//    CGImageRelease(cgImage);
//    topBgView.image = image;
    UIImageView *shadowView = [[UIImageView alloc]initWithFrame:CGRectMake(0, 0, IPHONE_W,167.0 / 667 * IPHONE_H)];
    [shadowView setUserInteractionEnabled:YES];
    [shadowView setImage:[UIImage imageNamed:@"me_mypage_mettopbg"]];
    [topBgView addSubview:shadowView];
    UIView *markView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, topBgView.frame.size.width, topBgView.frame.size.height )];
    [markView setBackgroundColor:[UIColor clearColor]];
    [markView setUserInteractionEnabled:YES];
    [topBgView addSubview:markView];
    topBgView.userInteractionEnabled = YES;
    
    NSArray *Addcriticism = [CommonCode readFromUserD:ADDCRITICISMNUMDATAKEY];
    if ([Addcriticism count]) {
        self.zhuyetableView.tableHeaderView =  [[UIView alloc]initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, IMAGEHEIGHT / 667 * IPHONE_H + 50.0)];
        [self.newMessageButton setHidden:NO];
        [self.zhuyetableView.tableHeaderView addSubview:self.newMessageButton];
        [self.newMessageTipsLabel setText:[NSString stringWithFormat:@"%ld则新消息",[Addcriticism count]]];
        //头像url处理
        if ([NEWSSEMTPHOTOURL([Addcriticism firstObject][@"avatar"])  rangeOfString:@"http"].location != NSNotFound){
            [self.newMessageImage sd_setImageWithURL:[NSURL URLWithString:NEWSSEMTPHOTOURL([Addcriticism firstObject][@"avatar"])] placeholderImage:AvatarPlaceHolderImage];
        }
        else{
            NSString *str = USERPHOTOHTTPSTRING(NEWSSEMTPHOTOURL([Addcriticism firstObject][@"avatar"]));
            [self.newMessageImage sd_setImageWithURL:[NSURL URLWithString:str] placeholderImage:AvatarPlaceHolderImage];
        }
    }
    else{
        self.zhuyetableView.tableHeaderView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, IMAGEHEIGHT / 667 * IPHONE_H)];
        [self.newMessageButton setHidden:YES];
    }
    
//    self.zhuyetableView.tableHeaderView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, IMAGEHEIGHT / 667 * IPHONE_H)];
    [self.zhuyetableView.tableHeaderView addSubview:topBgView];
    [self.newMessageButton setHidden:YES];
    [self.zhuyetableView.tableHeaderView addSubview:self.newMessageButton];
    
    //返回按钮
    UIButton *leftBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    leftBtn.frame = CGRectMake(10, 25, 35, 35);
    [leftBtn setImageEdgeInsets:UIEdgeInsetsMake(5, 0, 5, 10)];
    [leftBtn setImage:[UIImage imageNamed:@"title_ic_back"] forState:UIControlStateNormal];
    [leftBtn addTarget:self action:@selector(backAction:) forControlEvents:UIControlEventTouchUpInside];
    leftBtn.accessibilityLabel = @"返回";
    [markView addSubview:leftBtn];
    //title
    UILabel *topLab = [[UILabel alloc]initWithFrame:CGRectMake(50, 30, IPHONE_W - 100, 30)];
    topLab.textColor = [UIColor blackColor];
    topLab.font = [UIFont boldSystemFontOfSize:17.0f];
    topLab.text = @"个人主页";
    topLab.backgroundColor = [UIColor clearColor];
    topLab.textAlignment = NSTextAlignmentCenter;
    [markView addSubview:topLab];
    if (self.isMypersonalPage) {
        //编辑按钮
        UIButton *rightBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        rightBtn.frame = CGRectMake(SCREEN_WIDTH - 45, 30, 25, 25);
//        [rightBtn setTitle:@"编辑" forState:UIControlStateNormal];
        [rightBtn setImage:[UIImage imageNamed:@"title_ic_edit"] forState:UIControlStateNormal];
        [rightBtn.titleLabel setFont:gFontMain14];
        [rightBtn addTarget:self action:@selector(rightbtnAction:) forControlEvents:UIControlEventTouchUpInside];
        [markView addSubview:rightBtn];
    }
    else{
        //关注/取消 按钮
        attentionBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        attentionBtn.frame = CGRectMake(SCREEN_WIDTH - 45, 30, 25, 25);
        if (_isFan) {
            [attentionBtn setImage:[UIImage imageNamed:@"card_icon_unfollow_white"] forState:UIControlStateNormal];
        }
        else{
            [attentionBtn setImage:[UIImage imageNamed:@"card_icon_addattention_white"] forState:UIControlStateNormal];
        }
        
        [attentionBtn.titleLabel setFont:gFontMain14];
        [attentionBtn addTarget:self action:@selector(attentionAction:) forControlEvents:UIControlEventTouchUpInside];
        [markView addSubview:attentionBtn];
    }
    
    UIView *imgBorderView = [[UIView alloc]initWithFrame:CGRectMake(30.0 / 667 * SCREEN_HEIGHT, 109.5 / 667 * SCREEN_HEIGHT, 95.0 / 667 * SCREEN_HEIGHT , 95.0 / 667 * SCREEN_HEIGHT)];
    [imgBorderView setBackgroundColor:gImageBorderColor];
    [imgBorderView setUserInteractionEnabled:YES];
    [imgBorderView.layer setMasksToBounds:YES];
    [imgBorderView.layer setCornerRadius:imgBorderView.frame.size.width / 2];
    [markView addSubview:imgBorderView];
    
    titleImgV = [[UIImageView alloc]initWithFrame:CGRectMake(2.5 / 667 * SCREEN_HEIGHT, 2.5 / 667 * SCREEN_HEIGHT, 90.0 / 667 * SCREEN_HEIGHT, 90.0 / 667 * SCREEN_HEIGHT)];
    if (self.isMypersonalPage) {
        titleImgV.image = [UIImage imageWithContentsOfFile:ExTouXiangPath];
    }
    else{
        //头像url处理
        if ([NEWSSEMTPHOTOURL(self.avatar)  rangeOfString:@"http"].location != NSNotFound){
            [titleImgV sd_setImageWithURL:[NSURL URLWithString:NEWSSEMTPHOTOURL(self.avatar)] placeholderImage:AvatarPlaceHolderImage];
        }
        else{
            NSString *str = USERPHOTOHTTPSTRING(NEWSSEMTPHOTOURL(self.avatar));
            [titleImgV sd_setImageWithURL:[NSURL URLWithString:str] placeholderImage:AvatarPlaceHolderImage];
        }
    }
    
    titleImgV.layer.masksToBounds = YES;
    titleImgV.layer.cornerRadius = titleImgV.frame.size.width / 2;
    [imgBorderView addSubview:titleImgV];
    
    titleImgV.userInteractionEnabled = YES;
    //添加单击手势
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(showZoomImageView:)];
    
    [titleImgV addGestureRecognizer:tap];
    
    CALayer *layer = [titleImgV layer];
    layer.borderColor = [gSubColor CGColor];
    layer.borderWidth = 0.0f;
    
    //    nameLab =  [[UILabel alloc]initWithFrame:CGRectMake(CGRectGetMaxX(imgBorderView.frame) + 12, imgBorderView.frame.origin.y + 20.0 / 667 * IPHONE_H, 150, 20.0 / 667 * IPHONE_H)];
    //    nameLab.textAlignment = NSTextAlignmentLeft;
    //    nameLab.textColor = nTextColorMain;
    //    if (self.isMypersonalPage) {
    //        if (self.user_nicename.length == 0){
    //            nameLab.text = self.user_login;
    //        }
    //        else{
    //            nameLab.text = self.user_nicename;
    //        }
    //    }
    //    else{
    //        nameLab.text = self.user_nicename;
    //    }
    //
    //    nameLab.font = [UIFont systemFontOfSize:16.0f];
    //    CGSize contentSize = [nameLab sizeThatFits:CGSizeMake(jianjieLab.frame.size.width, MAXFLOAT)];
    //    nameLab.frame = CGRectMake(nameLab.frame.origin.x, nameLab.frame.origin.y,contentSize.width, nameLab.frame.size.height);
    //    [markView addSubview:nameLab];
    //
    //     // ♂ ♀
    //    UIImageView *sexImage = [[UIImageView alloc]initWithFrame:CGRectMake(nameLab.frame.size.width + nameLab.frame.origin.x + 5, nameLab.frame.origin.y+3, 12, 12)];
    //    if ([self.sex isEqualToString:@"1"]) {
    //        //男
    //        [sexImage setImage:[UIImage imageNamed:@"user-7"]];
    //    }
    //    else if ([self.sex isEqualToString:@"2"]){
    //        //女
    //        [sexImage setImage:[UIImage imageNamed:@"user-6"]];
    //    }
    //    [markView addSubview:sexImage];
    
    //等级
    UIImageView *lvView = [[UIImageView alloc]initWithFrame:CGRectMake(CGRectGetMaxX(imgBorderView.frame) + 10, imgBorderView.frame.origin.y + 20.0 / 667 * IPHONE_H, 50, 20.0 / 667 * IPHONE_H)];
    [lvView setImage:[UIImage imageNamed:@"LV1~9"]];
    [lvView setUserInteractionEnabled:YES];
    [lvView addTapGesWithTarget:self action:@selector(lvQAButtonAction)];
    UILabel *lvLab = [[UILabel alloc]initWithFrame:CGRectMake(lvView.frame.size.width - 25, 0, 25, 20)];
    [lvLab setFont:gFontMain12];
    [lvLab setTextAlignment:NSTextAlignmentCenter];
    [lvLab setTextColor:[UIColor whiteColor]];
    [lvLab addTapGesWithTarget:self action:@selector(lvQAButtonAction)];
    [lvView addSubview:lvLab];
    
    UILabel *lvLabel = [[UILabel alloc]initWithFrame:CGRectMake(CGRectGetMaxX(lvView.frame) + 20, lvView.frame.origin.y - 2, 60, 16)];
    [lvLabel setTextColor:gTextColorSub];
    [lvLabel setFont:gFontMain12];
    [markView addSubview:lvLabel];
    [lvLabel addTapGesWithTarget:self action:@selector(lvQAButtonAction)];
    UIProgressView *lvProgress = [[UIProgressView alloc]initWithFrame:CGRectMake(CGRectGetMaxX(lvView.frame) - 8, CGRectGetMaxY(lvView.frame) - 4, 100, 3)];
    CGAffineTransform transform = CGAffineTransformMakeScale(1.0f, 3.0f);
    lvProgress.transform = transform;//设定宽高
    lvProgress.layer.cornerRadius = 1.0;//设定两端弧度
    lvProgress.layer.masksToBounds = YES;
    [lvProgress addTapGesWithTarget:self action:@selector(lvQAButtonAction)];
    [lvProgress setTrackTintColor:[UIColor whiteColor]];
    [markView addSubview:lvProgress];
    [markView addSubview:lvView];
    
    [lvLab setText:@"1"];
    NSInteger lv = 1;
    if (self.isMypersonalPage) {
        NSDictionary *userInfo = [CommonCode readFromUserD:@"dangqianUserInfo"];
        lv = [userInfo[results][@"level"] integerValue];
        [lvLab setText:userInfo[results][@"level"]];
    }
    else{
        lv = [_friendsLv integerValue];
        [lvLab setText:_friendsLv];
    }
    
    if (lv > 0 && lv < 10) {
        [lvView setImage:[UIImage imageNamed:@"LV1~9"]];
        [lvProgress setTintColor:[UIColor colorWithHue:0.53 saturation:0.55 brightness:0.94 alpha:1.00]];
        [lvProgress setProgress:1.0 * lv / 10];
        [lvLabel setText:[NSString stringWithFormat:@"%ld/10",(long)lv]];
    }
    else if (lv >= 10 && lv < 20){
        [lvView setImage:[UIImage imageNamed:@"LV10~19"]];
        [lvProgress setTintColor:[UIColor colorWithHue:0.47 saturation:0.59 brightness:0.85 alpha:1.00]];
        [lvProgress setProgress: 1.0 *(lv - 10) / 10];
        [lvLabel setText:[NSString stringWithFormat:@"%ld/20",(long)lv]];
    }
    else if (lv >= 20 && lv < 30){
        [lvView setImage:[UIImage imageNamed:@"LV20~29"]];
        [lvProgress setTintColor:[UIColor colorWithHue:0.35 saturation:0.79 brightness:0.83 alpha:1.00]];
        [lvProgress setProgress: 1.0 *(lv - 20) / 10];
        [lvLabel setText:[NSString stringWithFormat:@"%ld/30",(long)lv]];
    }
    else if (lv >= 30 && lv < 40){
        [lvView setImage:[UIImage imageNamed:@"LV30~39"]];
        [lvProgress setTintColor:[UIColor colorWithHue:0.20 saturation:0.78 brightness:0.87 alpha:1.00]];
        [lvProgress setProgress: 1.0 *(lv - 30) / 10];
        [lvLabel setText:[NSString stringWithFormat:@"%ld/40",(long)lv]];
    }
    else if (lv >= 40 && lv < 50){
        [lvView setImage:[UIImage imageNamed:@"LV40~49"]];
        [lvProgress setTintColor:[UIColor colorWithHue:0.14 saturation:0.79 brightness:0.95 alpha:1.00]];
        [lvProgress setProgress: 1.0 *(lv - 40) / 10];
        [lvLabel setText:[NSString stringWithFormat:@"%ld/50",(long)lv]];
    }
    else if (lv >= 50 && lv < 60){
        [lvView setImage:[UIImage imageNamed:@"LV50~59"]];
        [lvProgress setTintColor:[UIColor colorWithHue:0.08 saturation:0.82 brightness:0.97 alpha:1.00]];
        [lvProgress setProgress: 1.0 *(lv - 50) / 10];
        [lvLabel setText:[NSString stringWithFormat:@"%ld/60",(long)lv]];
    }
    else if (lv >= 60 && lv < 70){
        [lvView setImage:[UIImage imageNamed:@"LV60~69"]];
        [lvProgress setTintColor:[UIColor colorWithHue:1.00 saturation:0.78 brightness:0.96 alpha:1.00]];
        [lvProgress setProgress: 1.0 *(lv - 60) / 10];
        [lvLabel setText:[NSString stringWithFormat:@"%ld/70",(long)lv]];
    }
    else if (lv >= 70 && lv < 80){
        [lvView setImage:[UIImage imageNamed:@"LV70~79"]];
        [lvProgress setTintColor:[UIColor colorWithHue:0.91 saturation:0.88 brightness:0.89 alpha:1.00]];
        [lvProgress setProgress: 1.0 *(lv - 70) / 10];
        [lvLabel setText:[NSString stringWithFormat:@"%ld/80",(long)lv]];
    }
    else if (lv >= 80 && lv < 90){
        [lvView setImage:[UIImage imageNamed:@"LV80~89"]];
        [lvProgress setTintColor:[UIColor colorWithHue:0.75 saturation:0.80 brightness:0.82 alpha:1.00]];
        [lvProgress setProgress: 1.0 *(lv - 80) / 10];
        [lvLabel setText:[NSString stringWithFormat:@"%ld/90",(long)lv]];
    }
    else if (lv >= 90 && lv < 99){
        [lvView setImage:[UIImage imageNamed:@"LV90~99"]];
        [lvProgress setTintColor:[UIColor colorWithHue:0.61 saturation:0.81 brightness:0.88 alpha:1.00]];
        [lvProgress setProgress: 1.0 *(lv - 90) / 10];
        [lvLabel setText:[NSString stringWithFormat:@"%ld/100",(long)lv]];
    }
    else{
        [lvView setImage:[UIImage imageNamed:@"LV100"]];
        [lvProgress setTintColor:[UIColor colorWithHue:0.57 saturation:0.68 brightness:0.91 alpha:1.00]];
        [lvProgress setProgress: 1.0];
        [lvLabel setText:[NSString stringWithFormat:@"%ld/100",(long)lv]];
    }
    
    UIButton *lvQA = [UIButton buttonWithType:UIButtonTypeCustom];
    [lvQA setFrame:CGRectMake(CGRectGetMaxX(lvProgress.frame), lvView.frame.origin.y, 30, 30)];
    [lvQA setImage:[UIImage imageNamed:@"help2"] forState:UIControlStateNormal];
    [lvQA setImageEdgeInsets:UIEdgeInsetsMake(8, 0, 10, 18)];
    [lvQA addTarget:self action:@selector(lvQAButtonAction) forControlEvents:UIControlEventTouchUpInside];
    [markView addSubview:lvQA];
    
    
    jianjieLab = [[UILabel alloc]initWithFrame:CGRectMake(lvView.frame.origin.x,CGRectGetMaxY(imgBorderView.frame) - 25.0 / 667 *SCREEN_HEIGHT, SCREEN_WIDTH - lvView.frame.origin.x, 20.0 / 667 * IPHONE_H)];
    if (self.signature.length == 0){
        jianjieLab.text = @"该用户没有什么想说的";
    }
    else if ([self.signature isEqualToString:@"没有简介"]){
        jianjieLab.text = @"该用户没有什么想说的";
    }
    else if ([self.signature isEqualToString:@"暂无简介"]){
        jianjieLab.text = @"该用户没有什么想说的";
    }
    else{
        jianjieLab.text = [NSString stringWithFormat:@"简介：%@",self.signature];
    }
    
    jianjieLab.textColor = gTextColorSub;
    [jianjieLab setNumberOfLines:2];
    jianjieLab.lineBreakMode = NSLineBreakByWordWrapping;
    CGSize size = [jianjieLab sizeThatFits:CGSizeMake(jianjieLab.frame.size.width, MAXFLOAT)];
    jianjieLab.frame = CGRectMake(jianjieLab.frame.origin.x, jianjieLab.frame.origin.y, jianjieLab.frame.size.width, size.height);
    jianjieLab.textAlignment = NSTextAlignmentLeft;
    jianjieLab.font = [UIFont systemFontOfSize:14.0f];
    [markView addSubview:jianjieLab];
    
    
    //关注和粉丝背景
    UIView *bgView = [[UIView alloc]initWithFrame:CGRectMake(0, markView.frame.size.height - 50.0 / 667 *IPHONE_H, SCREEN_WIDTH, 50.0 / 667 *IPHONE_H)];
    [bgView setBackgroundColor:[UIColor whiteColor]];
    [bgView setUserInteractionEnabled:YES];
    [markView addSubview:bgView];
    
    guanzhuLab = [[UILabel alloc]initWithFrame:CGRectMake(0, 0, IPHONE_W / 2, 20.0 / 667 * IPHONE_H)];
    guanzhuLab.text = @"关注";
    guanzhuLab.textAlignment = NSTextAlignmentCenter;
    guanzhuLab.textColor = gTextColorSub;
    guanzhuLab.font = gFontMain12;
    [bgView addSubview:guanzhuLab];
    
    fensiLab = [[UILabel alloc]initWithFrame:CGRectMake(IPHONE_W / 2, 0, IPHONE_W / 2, 20.0 / 667 * IPHONE_H)];
    fensiLab.text = @"粉丝";
    fensiLab.textAlignment = NSTextAlignmentCenter;
    fensiLab.textColor = gTextColorSub;
    fensiLab.font = gFontMain12;
    [bgView addSubview:fensiLab];
    
    guanzhuNum = [[UILabel alloc]initWithFrame:CGRectMake(0, 20.0 / 667 * IPHONE_H, IPHONE_W / 2, 30.0 / 667 * IPHONE_H)];
    if (self.isMypersonalPage) {
        guanzhuNum.text = [CommonCode readFromUserD:@"guanzhuNum"];
    }
    else{
        guanzhuNum.text = self.guan_num;
    }
    guanzhuNum.textAlignment = NSTextAlignmentCenter;
    guanzhuNum.textColor = nTextColorMain;
    guanzhuNum.font = gFontMajor16;
    [bgView addSubview:guanzhuNum];
    
    fensiNum = [[UILabel alloc]initWithFrame:CGRectMake(IPHONE_W / 2, 20.0 / 667 * IPHONE_H, IPHONE_W / 2, 30.0 / 667 * IPHONE_H)];
    if (self.isMypersonalPage) {
        fensiNum.text = [CommonCode readFromUserD:@"fensiNum"];
    }
    else{
        fensiNum.text = self.fan_num;
    }
    fensiNum.textAlignment = NSTextAlignmentCenter;
    fensiNum.textColor = nTextColorMain;
    fensiNum.font = gFontMajor16;
    [bgView addSubview:fensiNum];
    
    
    UITapGestureRecognizer *guanzhuTap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(guanzhuAction)];
    guanzhuNum.userInteractionEnabled = YES;
    [guanzhuNum addGestureRecognizer:guanzhuTap];
    UITapGestureRecognizer *guanzhuTap2 = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(guanzhuAction)];
    guanzhuLab.userInteractionEnabled = YES;
    [guanzhuLab addGestureRecognizer:guanzhuTap2];
    
    UITapGestureRecognizer *fensiTap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(fensiAction)];
    fensiNum.userInteractionEnabled = YES;
    [fensiNum addGestureRecognizer:fensiTap];
    UITapGestureRecognizer *fensiTap2 = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(fensiAction)];
    fensiLab.userInteractionEnabled = YES;
    [fensiLab addGestureRecognizer:fensiTap2];
    
    UIView *line = [[UIView alloc]initWithFrame:CGRectMake(0, 49.0 / 667 *IPHONE_H, SCREEN_WIDTH,1.0)];
    [line setBackgroundColor:gThickLineColor];
    [bgView addSubview:line];
    
    [self.view addSubview:self.toolBarView];
    [self.toolBarView setHidden:YES];
    
}


- (UIView *)toolBarView {
    if (!_toolBarView) {
        _toolBarView = [[UIView alloc]initWithFrame:CGRectMake(0, SCREEN_HEIGHT - 46, SCREEN_WIDTH, 46)];
        [_toolBarView setBackgroundColor:[UIColor colorWithRed:0.98 green:0.98 blue:0.98 alpha:1.00]];
        [_toolBarView setUserInteractionEnabled:YES];
        UIView *toplineView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, 1)];
        [toplineView setBackgroundColor:gThickLineColor];
        [_toolBarView addSubview:toplineView];
        [_toolBarView addSubview:self.commentTextField];
        [_toolBarView addSubview:self.sentCommentButton];
    }
    return _toolBarView;
}
- (UITextField *)commentTextField {
    if (!_commentTextField ) {
        _commentTextField = [[UITextField alloc]initWithFrame:CGRectMake(10, 5, SCREEN_WIDTH - 70, 35)];
        _commentTextField.layer.borderWidth = 1;
        _commentTextField.layer.borderColor = UIColor.grayColor.CGColor;
        _commentTextField.layer.cornerRadius = 5;
        _commentTextField.layer.masksToBounds = YES;
        _commentTextField.delegate = self;
        // [_commentTextField setFont:[UIFont systemFontOfSize:17]];
        [_commentTextField setReturnKeyType:UIReturnKeyDone];
        [_commentTextField setAdjustsFontSizeToFitWidth:NO];
    }
    return _commentTextField;
}

- (UIButton *)sentCommentButton {
    if (!_sentCommentButton) {
        _sentCommentButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [_sentCommentButton setFrame:CGRectMake(IPHONE_W-50, 3, 40, 40)];
        [_sentCommentButton setTitle:@"发送" forState:UIControlStateNormal];
        [_sentCommentButton setTitleColor:gTextDownload forState:UIControlStateNormal];
        [_sentCommentButton addTarget:self action:@selector(sentCommentAction:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _sentCommentButton;
}


#pragma mark - UITableViewDelegate

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.infoArr.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    //mvc
    BlobNewTableViewCell *cell = [BlobNewTableViewCell cellWithTableView:tableView];
    cell.isFeebackBlog = NO;
    cell.isUnreadMessage = NO;
    cell.indexRow = indexPath.row;
    FeedBackAndListenFriendFrameModel *frameModel = self.infoArr[indexPath.row];
    cell.frameModel = frameModel;
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    
    DefineWeakSelf;
    [cell setAddFav:^(BlobNewTableViewCell *cell , int iszan) {
        [weakSelf addFavInTableViewCell:cell andIszan:iszan];
    }];
    [cell setAddComment:^(BlobNewTableViewCell *cell) {
        
        [weakSelf addCommentInTableViewCell:cell];
    }];
    [cell setAddReview:^(BlobNewTableViewCell *cell, child_commentModel *model) {
        [weakSelf reviewWithCell:cell andModel:model];
    }];
    [cell setDeleteBlog:^(BlobNewTableViewCell *cell) {
        [weakSelf deleteBlogIntableViewCell:cell];
    }];
    [cell setPlayVoice:^(BlobNewTableViewCell *cell) {
        [weakSelf playVoiceInTableViewCell:cell];
    }];
    [cell setUpdateVoiceAnimate:^(BlobNewTableViewCell *cell) {
        [weakSelf.zhuyetableView reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    }];
    [cell.photosImageView setTapImageBlock:^(MultiImageView *view, UIImageView *imgv, NSInteger idx) {
        [weakSelf showPhotos:view.images selectedIndex:idx];
    }];

    
    return cell;
    
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    FeedBackAndListenFriendFrameModel *frameModel = self.infoArr[indexPath.row];
    return frameModel.cellHeight;
}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    FeedBackAndListenFriendFrameModel *frameModel = self.infoArr[indexPath.row];
    FeedBackAndListenFriendModel *model = frameModel.model;
    if ([model.post_id isEqualToString:@"0"]) {
        return;
    }
    else{
        //TODO:跳转新闻详情
        NSDictionary *dict = [frameModel.model.post mj_keyValues];
        //设置频道类型
        [ZRT_PlayerManager manager].channelType = ChannelTypeMinePersonCenter;
        //设置播放器播放内容类型
        [ZRT_PlayerManager manager].playType = ZRTPlayTypeNews;
        //设置播放界面打赏view的状态
        [NewPlayVC shareInstance].rewardType = RewardViewTypeNone;
        //判断是否是点击当前正在播放的新闻，如果是则直接跳转
        if ([[CommonCode readFromUserD:@"dangqianbofangxinwenID"] isEqualToString:dict[@"id"]]){
            
            //设置播放器播放数组
            [ZRT_PlayerManager manager].songList = @[dict];
            [[NewPlayVC shareInstance] reloadInterface];
            [self.navigationController.navigationBar setHidden:YES];
            [self.navigationController pushViewController:[NewPlayVC shareInstance] animated:YES];
        }
        else{
            
            //设置播放器播放数组
            [ZRT_PlayerManager manager].songList = @[dict];
            //设置新闻ID
            [NewPlayVC shareInstance].post_id = dict[@"id"];
            //保存当前播放新闻Index
            ExcurrentNumber = 0;
            //调用播放对应Index方法
            [[NewPlayVC shareInstance] playFromIndex:ExcurrentNumber];
            //跳转播放界面
            [self.navigationController.navigationBar setHidden:YES];
            [self.navigationController pushViewController:[NewPlayVC shareInstance] animated:YES];
            [tableView reloadData];
        }
    }
}
#pragma mark - 回复评论
//点击回复评论
- (void)reviewWithCell:(BlobNewTableViewCell *)cell andModel:(child_commentModel *)model
{
    self.replyComment_tuid = model.uid;
    if ([[CommonCode readFromUserD:@"isLogin"]boolValue] == YES) {
        //获取当前登录用户ID
        ExdangqianUserUid = [CommonCode readFromUserD:@"dangqianUserUid"];
        //判断是否为自己的评论或者回复
        if ([model.uid isEqualToString:ExdangqianUserUid]) {
            
        }else{
            self.toolBarView.frame = CGRectMake(0, SCREEN_HEIGHT, SCREEN_WIDTH, 46);
            [[UIApplication sharedApplication].keyWindow addSubview:self.toolBarView];
            [self.toolBarView setHidden:NO];
            [self.commentTextField becomeFirstResponder];
            self.isReplyComment = YES;
            [self.commentTextField setPlaceholder:[NSString stringWithFormat:@"@%@",model.user.user_nicename]];
            NSIndexPath *indexPath = [self.zhuyetableView indexPathForCell:cell];
            [CommonCode writeToUserD:[NSString stringWithFormat:@"%ld",(long)indexPath.row] andKey:@"rowIndex"];
        }
    }
    else{
        [self loginFirst];
    }
    
}

#pragma mark - UIScrollViewDelegate

- (void)scrollViewDidScroll:(UIScrollView *)scrollView{
    
    [self.toolBarView setHidden:YES];
    [self.commentTextField resignFirstResponder];
    
}

#pragma mark - TTTAttributedLabelDelegate

- (void)attributedLabel:(TTTAttributedLabel *)label
didSelectLinkWithTransitInformation:(NSDictionary *)components {
    
    if ([components[@"isComment"] isEqualToString:@"1"]) {
        self.replyComment_tuid = components[@"comment_tuid"];
        if ([[CommonCode readFromUserD:@"isLogin"]boolValue] == YES) {
            self.toolBarView.frame = CGRectMake(0, SCREEN_HEIGHT, SCREEN_WIDTH, 46);
            [[UIApplication sharedApplication].keyWindow addSubview:self.toolBarView];
            [self.toolBarView setHidden:NO];
            [self.commentTextField becomeFirstResponder];
            self.isReplyComment = YES;
            [self.commentTextField setPlaceholder:[NSString stringWithFormat:@"@%@",components[@"user_nicename"]]];
            [CommonCode writeToUserD:components[@"rowIndex"] andKey:@"rowIndex"];
        }
        else{
            [self loginFirst];
        }
    }
    else{
        gerenzhuyeVC *gerenzhuye = [gerenzhuyeVC new];
        if ([components[@"user_login"] isEqualToString:ExdangqianUser] && [[CommonCode readFromUserD:@"isLogin"]boolValue] == YES) {
            gerenzhuye.isMypersonalPage = YES;
        }
        else{
            gerenzhuye.isMypersonalPage = NO;
        }
        gerenzhuye.isNewsComment = NO;
        gerenzhuye.user_nicename = components[@"user_nicename"];
        gerenzhuye.sex = components[@"sex"];
        gerenzhuye.signature = components[@"signature"];
        gerenzhuye.user_login = components[@"user_login"];
        gerenzhuye.avatar = components[@"avatar"];
        gerenzhuye.fan_num = components[@"fan_num"];
        gerenzhuye.guan_num = components[@"guan_num"];
        gerenzhuye.user_id = components[@"id"];
        self.hidesBottomBarWhenPushed=YES;
        [self.navigationController pushViewController:gerenzhuye animated:YES];
        self.hidesBottomBarWhenPushed=YES;
    }
}

#pragma mark - Keyboard notifications

- (void)handleWillShowKeyboard:(NSNotification *)notification{
    [self keyboardWillShowHide:notification];
}

- (void)handleWillHideKeyboard:(NSNotification *)notification{
    [self keyboardWillShowHide:notification];
}

- (void)keyboardWillShowHide:(NSNotification *)notification{
    
    NSDictionary *userInfo = [notification userInfo];
    NSValue *value = [userInfo objectForKey:UIKeyboardFrameEndUserInfoKey];
    CGFloat keyboardY = value.CGRectValue.origin.y;
    
    NSNumber *duration = [userInfo objectForKey:UIKeyboardAnimationDurationUserInfoKey];
    NSNumber *curve = [userInfo objectForKey:UIKeyboardAnimationCurveUserInfoKey];
    
    // 添加移动动画，使视图跟随键盘移动
    [UIView animateWithDuration:duration.doubleValue animations:^{
        [UIView setAnimationBeginsFromCurrentState:YES];
        [UIView setAnimationCurve:[curve intValue]];
        // keyBoardEndY的坐标包括了状态栏的高度，要减去
        self.toolBarView.center = CGPointMake(self.toolBarView.center.x, keyboardY  - self.toolBarView.bounds.size.height/2.0);
        
    }];
    
}

#pragma mark - UITextFieldDelegate

- (BOOL)textFieldShouldEndEditing:(UITextField *)textField{
    self.commentTextStr = textField.text;
    return YES;
}

#pragma mark - NSNotification
- (void)voicePlayedidEnd:(NSNotification *)notice {
    NSLog(@"voicePlaydidEnd");
    
//    if ([bofangVC shareInstance].isPlay) {
//        [[bofangVC shareInstance] doplay2];
//    }
    
    if ([ZRT_PlayerManager manager].isPlaying) {
        [[ZRT_PlayerManager manager] pausePlay];
    }
}

#pragma mark - Utilities

- (void)loadData {
    
    [NetWorkTool getPaoGuoSelfFenSiLieBiaoWithaccessToken:[DSE encryptUseDES:self.user_login] andPage:@"1" andLimit:@"99999" sccess:^(NSDictionary *responseObject) {
        if ([responseObject[results] isKindOfClass:[NSArray class]]){
            NSArray *fanListArr = responseObject[results];
            if ([fanListArr count]) {
                self.fanCount = [fanListArr count];
                fensiNum.text = [NSString stringWithFormat:@"%ld",self.fanCount];
            }
            else{
                self.fanCount = 0;
                fensiNum.text = [NSString stringWithFormat:@"%ld",self.fanCount];
            }
            
        }
        else{
            self.fanCount = 0;
            fensiNum.text = [NSString stringWithFormat:@"%ld",self.fanCount];
        }
        
    } failure:^(NSError *error) {
        NSLog(@"error = %@",error);
    }];
    
    
    [NetWorkTool getPaoGuoGuanZhuLieBiaoWithaccessToken:[DSE encryptUseDES:self.user_login] andPage:@"1" andLimit:@"99999" sccess:^(NSDictionary *responseObject) {
        if ([responseObject[results] isKindOfClass:[NSArray class]]){
            NSArray *attentionListArr = responseObject[results];
            if ([attentionListArr count]) {
                self.attentionCount = [attentionListArr count];
                guanzhuNum.text = [NSString stringWithFormat:@"%ld",self.attentionCount];
            }
            else{
                self.attentionCount = 0;
                guanzhuNum.text = [NSString stringWithFormat:@"%ld",self.attentionCount];
            }
            
        }
        else{
            self.attentionCount = 0;
            guanzhuNum.text = [NSString stringWithFormat:@"%ld",self.attentionCount];
        }
        
    } failure:^(NSError *error) {
        NSLog(@"%@",error);
    }];
  
}

- (void)rightSwipeAction {
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)shangLaJiaZai {
    numberPage++;
    [NetWorkTool getMyDynamicsListWithaccessToken:[DSE encryptUseDES:self.user_login] login_uid:ExdangqianUserUid andPage:[NSString stringWithFormat:@"%d",numberPage]  andLimit:@"10" sccess:^(NSDictionary *responseObject) {
        if ([responseObject[results] isKindOfClass:[NSArray class]]){
            NSMutableArray *array = [FeedBackAndListenFriendModel mj_objectArrayWithKeyValuesArray:responseObject[results]];
            [self.infoArr addObjectsFromArray:[self frameArrayWithDataArray:array]];
            if (array.count < 10) {
                [self.zhuyetableView.mj_footer endRefreshingWithNoMoreData];
            }else{
                [self.zhuyetableView.mj_footer endRefreshing];
            }
            [self.zhuyetableView reloadData];
        }else
        {
            [self.zhuyetableView.mj_footer endRefreshingWithNoMoreData];
        }
    } failure:^(NSError *error) {
        RTLog(@"error = %@",error);
        [self.zhuyetableView.mj_footer endRefreshing];
    }];

}
//转换数据模型数组为数据frame模型数组
- (NSMutableArray *)frameArrayWithDataArray:(NSMutableArray *)array
{
    NSMutableArray *frameModelArray = [NSMutableArray array];
    for (FeedBackAndListenFriendModel *model in array) {
        FeedBackAndListenFriendFrameModel *frameModel = [[FeedBackAndListenFriendFrameModel alloc] init];
        frameModel.isFeedbackVC = NO;
        frameModel.model = model;
        [frameModelArray addObject:frameModel];
    }
    return frameModelArray;
}

- (void)refreshData {
    
        [NetWorkTool getMyDynamicsListWithaccessToken:[DSE encryptUseDES:self.user_login] login_uid:ExdangqianUserUid andPage:@"1" andLimit:@"10" sccess:^(NSDictionary *responseObject) {
            if ([responseObject[results] isKindOfClass:[NSArray class]])
            {
                [self.infoArr removeAllObjects];
                NSMutableArray *array = [FeedBackAndListenFriendModel mj_objectArrayWithKeyValuesArray:responseObject[results]];
                [self.infoArr addObjectsFromArray:[self frameArrayWithDataArray:array]];
            }
            [self.zhuyetableView reloadData];
        } failure:^(NSError *error) {
            NSLog(@"error = %@",error);
        }];
        [self.zhuyetableView.mj_header endRefreshing];
}

- (void)showZoomImageView:(UITapGestureRecognizer *)tap{
    NSLog(@"点击头像");
    if (![(UIImageView *)tap.view image]) {
        return;
    }
    //scrollView作为背景
    UIScrollView *bgView = [[UIScrollView alloc] init];
    bgView.frame = [UIScreen mainScreen].bounds;
    bgView.backgroundColor = [UIColor blackColor];
    UITapGestureRecognizer *tapBg = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapBgView:)];
    [bgView addGestureRecognizer:tapBg];
    
    UIImageView *picView = (UIImageView *)tap.view;
    
    UIImageView *imageView = [[UIImageView alloc] init];
    imageView.image = picView.image;
    imageView.frame = [bgView convertRect:picView.frame fromView:self.view];
    [bgView addSubview:imageView];
    
    [[[UIApplication sharedApplication] keyWindow] addSubview:bgView];
    
    self.lastImageView = imageView;
    self.originalFrame = imageView.frame;
    self.scrollView = bgView;
    //最大放大比例
    self.scrollView.maximumZoomScale = 2.0f;
//    self.scrollView.delegate = self;
    self.scrollView.showsHorizontalScrollIndicator = NO;
    self.scrollView.showsVerticalScrollIndicator = NO;
    [UIView animateWithDuration:0.35 animations:^{
        CGRect frame = imageView.frame;
        frame.size.width = bgView.frame.size.width;
        frame.size.height = frame.size.width * (imageView.image.size.height / imageView.image.size.width);
        frame.origin.x = 0;
        frame.origin.y = (bgView.frame.size.height - frame.size.height) * 0.5;
        imageView.frame = frame;
    }];
//    self.scrollView.contentSize = imageView.frame.size;
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

//返回可缩放的视图
-(UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView{
    return self.lastImageView;
}

- (void)back{
    [self.navigationController popViewControllerAnimated:YES];
}

#pragma mark - tableCellBlockMethods
- (void)addFavInTableViewCell:(BlobNewTableViewCell *)cell andIszan:(int )iszan{
    
    NSIndexPath *indexPath = [self.zhuyetableView indexPathForCell:cell];
    FeedBackAndListenFriendFrameModel *blog = self.infoArr[indexPath.row];
    FeedBackAndListenFriendModel *model = blog.model;
    cell.praiseButton.userInteractionEnabled = NO;
//    DefineWeakSelf;
    [NetWorkTool addAndCancelPraiseWithaccessToken:[DSE encryptUseDES:ExdangqianUser] comments_id:model.ID sccess:^(NSDictionary *responseObject) {
//        [weakSelf refreshData];
        if (iszan == 0) {
            [cell.praiseButton setImage:[UIImage imageNamed:@"me_mypage_me_list_ic_liked"] forState:UIControlStateNormal];
            cell.frameModel.model.zan = @"1";
            cell.frameModel.model.praisenum = [NSString stringWithFormat:@"%d",[cell.frameModel.model.praisenum intValue] + 1];
            cell.favLabel.text = [NSString stringWithFormat:@"%@人点赞",cell.frameModel.model.praisenum];
        }
        else if (iszan == 1){
            [cell.praiseButton setImage:[UIImage imageNamed:@"me_mypage_me_list_ic_like"] forState:UIControlStateNormal];
            cell.frameModel.model.zan = @"0";
            cell.frameModel.model.praisenum = [NSString stringWithFormat:@"%d",[cell.frameModel.model.praisenum intValue] - 1];
            cell.favLabel.text = [NSString stringWithFormat:@"%@人点赞",cell.frameModel.model.praisenum];
        }

        cell.praiseButton.userInteractionEnabled = YES;
        if (iszan == 1) {
            XWAlerLoginView *xw = [[XWAlerLoginView alloc]initWithTitle:@"取消点赞成功"];
            [xw show];
        }else
        {
            XWAlerLoginView *xw = [[XWAlerLoginView alloc]initWithTitle:@"点赞成功"];
            [xw show];
        }
    } failure:^(NSError *error) {
        cell.praiseButton.userInteractionEnabled = YES;
        [SVProgressHUD showErrorWithStatus:@"网络请求失败"];
        [self performSelector:@selector(SVPDismiss) withObject:nil afterDelay:1.0];
    }];
}

- (void)addCommentInTableViewCell:(UITableViewCell *)cell{
    if ([[CommonCode readFromUserD:@"isLogin"]boolValue] == YES) {
        _commentCell = cell;
        self.toolBarView.frame = CGRectMake(0, SCREEN_HEIGHT, SCREEN_WIDTH, 46);
        [[UIApplication sharedApplication].keyWindow addSubview:self.toolBarView];
        
        [self.toolBarView setHidden:NO];
        [self.commentTextField becomeFirstResponder];
        self.isReplyComment = NO;
        [self.commentTextField setPlaceholder:@"评论"];
    }
    else{
        [self loginFirst];
    }
    
}

- (void)deleteBlogIntableViewCell:(UITableViewCell *)cell{
    NSIndexPath *indexPath = [self.zhuyetableView indexPathForCell:cell];
    //        BlogModel *blog = self.blogArray[indexPath.row];
    DefineWeakSelf;
    FeedBackAndListenFriendFrameModel *frameModel = self.infoArr[indexPath.row];
    [UIAlertView alertViewWithTitle:@"提示" message:@"确认删除吗？" cancelButtonTitle:@"取消" otherButtonTitles:@[@"删除"] onDismiss:^(int buttonIndex) {
        //            [weakSelf deleteBlog:blog];
        [NetWorkTool delCommentWithaccessToken:AvatarAccessToken comment_id:frameModel.model.post.i_id sccess:^(NSDictionary *responseObject) {
            //
            NSLog(@"delSuccess");
            [Explayer pause];
            [weakSelf refreshData];
        } failure:^(NSError *error) {
            //
            NSLog(@"%@",error);
        }];
    } onCancel:^{
    }];
}

- (void)playVoiceInTableViewCell:(UITableViewCell *)cell {
    NSIndexPath *indexPath = [self.zhuyetableView indexPathForCell:cell];
    NSMutableDictionary *blog = self.infoArr[indexPath.row];
    [Explayer replaceCurrentItemWithPlayerItem:[[AVPlayerItem alloc]initWithURL:[NSURL URLWithString:blog[@"mp3_url"]]]];
    [Explayer play];
    if (ExisRigester == NO){
        //添加观察者，用来监视播放器的状态变化
        [Explayer addObserver:self forKeyPath:@"status" options:NSKeyValueObservingOptionNew context:nil];
        //        //添加观察者，用来监听播放器的缓冲进度loadedTimeRanges属性
        //        [Explayer addObserver:self forKeyPath:@"loadedTimeRanges" options:NSKeyValueObservingOptionNew context:nil];
        ExisRigester = YES;
    }
    //播放完毕后发出通知
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(voicePlayedidEnd:) name:AVPlayerItemDidPlayToEndTimeNotification object:Explayer.currentItem];
    
}

-(void)showPhotos:(NSArray *)arrPhotos selectedIndex:(NSInteger)idx{
    PhotoBrowserController * photoBrowser = [PhotoBrowserController browserWithPhotos:arrPhotos];
    [photoBrowser setCurrentPhotoIndex:idx];
    [self.navigationController pushViewController:photoBrowser animated:YES];
    //        [self.rdv_tabBarController setTabBarHidden:YES animated:YES];
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

- (void)SVPDismiss {
    [SVProgressHUD dismiss];
}

#pragma mark - UIButtonAction 

- (void)fensiAction{
    self.hidesBottomBarWhenPushed=YES;
    fensiliebiaoVC *vc = [fensiliebiaoVC new];
    vc.user_login = self.user_login;
    _isToEditInfomation = YES;
    [self.navigationController pushViewController:vc animated:YES];
}

- (void)guanzhuAction{
    self.hidesBottomBarWhenPushed=YES;
    wodeguanzhuVC *vc = [wodeguanzhuVC new];
    vc.user_login = self.user_login;
    _isToEditInfomation = YES;
    [self.navigationController pushViewController:vc animated:YES];
}

- (void)rightbtnAction:(UIButton *)sender {
    self.hidesBottomBarWhenPushed=YES;
    _isToEditInfomation = YES;
    [self.navigationController pushViewController:[titleImageVC new] animated:YES];
}

- (void)attentionAction:(UIButton *)sender {
    //关注、取消
    if ([[CommonCode readFromUserD:@"isLogin"]boolValue] == YES){
        if (_isFan == NO){
            
            [NetWorkTool getPaoGuoAddFriendWithaccessToken:[DSE encryptUseDES:ExdangqianUser] anduid_2:self.user_id sccess:^(NSDictionary *responseObject) {
                _isFan = YES;
                [attentionBtn setImage:[UIImage imageNamed:@"card_icon_unfollow_white"] forState:UIControlStateNormal];

            } failure:^(NSError *error) {
                NSLog(@"error = %@",error);
            }];
            
        }
        else{
            [NetWorkTool getPaoGuoCancelFriendWithaccessToken:[DSE encryptUseDES:ExdangqianUser] anduid_2:self.user_id sccess:^(NSDictionary *responseObject) {
                _isFan = NO;
                [attentionBtn setImage:[UIImage imageNamed:@"card_icon_addattention_white"] forState:UIControlStateNormal];

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


- (void)bianji:(UIBarButtonItem *)sender{
    self.hidesBottomBarWhenPushed=YES;
    _isToEditInfomation = YES;
    [self.navigationController pushViewController:[titleImageVC new] animated:YES];
}

- (void)backAction:(UIButton *)sender {
    [self.toolBarView setHidden:YES];
    [self.commentTextField resignFirstResponder];
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)sentCommentAction:(UIButton *)sender {
    [self.commentTextField resignFirstResponder];
    if ([self.commentTextStr isEmpty]) {
        [SVProgressHUD showErrorWithStatus:@"评论内容不能为空"];
        [self performSelector:@selector(SVPDismiss) withObject:nil afterDelay:1.0];
    }
    else{
        //TODO:emoji解析上传
        self.commentTextStr = [CommonCode stringContainsEmoji:self.commentTextStr];
        
        NSIndexPath *indexPath;
        NSInteger row;
        if (self.isReplyComment) {
            row = [[CommonCode readFromUserD:@"rowIndex"] integerValue];
        }
        else{
            indexPath = [self.zhuyetableView indexPathForCell:_commentCell];
            row = indexPath.row;
        }
        NSString *tuid = @"0";
        NSString *to_comment_id = @"0";
        NSString *iscomment = @"0";
        DefineWeakSelf;
        [SVProgressHUD setDefaultMaskType:SVProgressHUDMaskTypeBlack];
        if (self.isReplyComment) {
            iscomment = @"1";
            to_comment_id = self.infoArr[row][@"id"];
            tuid = self.replyComment_tuid;
        }
        else{
            
            tuid = self.infoArr[row][@"uid"];
            to_comment_id = self.infoArr[row][@"id"];
        }
        FeedBackAndListenFriendFrameModel *frameModel = self.infoArr[indexPath.row];
        if ([frameModel.model.post_id isEqualToString:@"0"]) {
            [NetWorkTool addfriendDynamicsPingLunWithaccessToken:AvatarAccessToken
                                                         post_id:frameModel.model.post_id
                                                      comment_id:to_comment_id
                                                          to_uid:tuid
                                                         content:self.commentTextStr
                                                          sccess:^(NSDictionary *responseObject) {
                                                              if ([[NSString stringWithFormat:@"%@",responseObject[@"status"]] isEqualToString:@"0"]){
                                                                  
                                                                  [SVProgressHUD showErrorWithStatus:responseObject[@"msg"]];
                                                                  [self performSelector:@selector(SVPDismiss) withObject:nil afterDelay:1.0];
                                                              }
                                                              else{
                                                                  [self.toolBarView setHidden:YES];
                                                                  [self.view endEditing:YES];
                                                                  self.commentTextStr = @"";
                                                                  self.commentTextField.text = @"";
                                                                  [weakSelf refreshData];
                                                                  
                                                                  [SVProgressHUD showSuccessWithStatus:@"评论成功"];
                                                                  [self performSelector:@selector(SVPDismiss) withObject:nil afterDelay:1.0];
                                                              }
                                                          } failure:^(NSError *error) {
                                                              [SVProgressHUD dismiss];
                                                              NSLog(@"%@",error);
                                                          }];
        }
        else{
            [NetWorkTool postPaoGuoXinWenPingLunWithaccessToken:AvatarAccessToken
                                                      andto_uid:tuid
                                                     andpost_id:frameModel.model.post_id
                                                  andcomment_id:to_comment_id
                                                  andpost_table:@"posts"
                                                     andcontent:self.commentTextStr
                                                         sccess:^(NSDictionary *responseObject) {
                                                             
                                                             if ([[NSString stringWithFormat:@"%@",responseObject[@"status"]] isEqualToString:@"0"]){
                                                                 
                                                                 [SVProgressHUD showErrorWithStatus:responseObject[@"msg"]];
                                                                 [self performSelector:@selector(SVPDismiss) withObject:nil afterDelay:1.0];
                                                             }
                                                             else{
                                                                 [self.toolBarView setHidden:YES];
                                                                 [self.view endEditing:YES];
                                                                 self.commentTextStr = @"";
                                                                 self.commentTextField.text = @"";
                                                                 [weakSelf refreshData];
                                                                 
                                                                 [SVProgressHUD showSuccessWithStatus:@"评论成功"];
                                                                 [self performSelector:@selector(SVPDismiss) withObject:nil afterDelay:1.0];
                                                             }
                                                             
                                                         } failure:^(NSError *error) {
                                                             [SVProgressHUD dismiss];
                                                             NSLog(@"%@",error);
                                                         }];
        }
        
        
        
    }
}

- (void)delegateComment:(UIButton *)sender{
    UIAlertController *qingshuruyonghuming = [UIAlertController alertControllerWithTitle:@"删除这条评论" message:nil preferredStyle:UIAlertControllerStyleAlert];
    [qingshuruyonghuming addAction:[UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
    }]];
    [qingshuruyonghuming addAction:[UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        //
        [NetWorkTool delCommentWithaccessToken:AvatarAccessToken comment_id:self.infoArr[sender.tag - 100][@"comment_id"] sccess:^(NSDictionary *responseObject) {
            //
            NSLog(@"delSuccess");
            [self refreshData];
        } failure:^(NSError *error) {
            //
            NSLog(@"%@",error);
        }];
    }]];
    
    [self presentViewController:qingshuruyonghuming animated:YES completion:nil];
}

- (void)newMessageAction:(UIButton *)sender {
    //TODO:跳转未读消息
    self.hidesBottomBarWhenPushed=YES;
    _isToEditInfomation = YES;
    [self.navigationController pushViewController:[PersonalUnreadViewController new] animated:YES];
}

- (void)lvQAButtonAction{
    
//    self.hidesBottomBarWhenPushed=YES;
//    HelpCenterQAViewController *vc = [HelpCenterQAViewController new];
//    _isToEditInfomation = YES;
//    [self.navigationController pushViewController:vc animated:YES];
    _isToEditInfomation = YES;
    NSURL *url = [NSURL URLWithString:@"http://admin.tingwen.me/help/help_core.html"];
    SingleWebViewController *singleWebVC = [[SingleWebViewController alloc] initWithTitle:@"帮助中心" url:url];
    [self.navigationController pushViewController:singleWebVC animated:YES];
    
}

#pragma mark - setter

- (UITableView *)zhuyetableView{
    if (!_zhuyetableView)
    {
        _zhuyetableView = [[UITableView alloc]initWithFrame:CGRectMake(0, 0, IPHONE_W, IPHONE_H) style:UITableViewStylePlain];
        _zhuyetableView.delegate = self;
        _zhuyetableView.dataSource = self;
        _zhuyetableView.tag = 1;
        [_zhuyetableView setSeparatorStyle:UITableViewCellSeparatorStyleNone];
//        _zhuyetableView.tableHeaderView = HeaderViewBg;
    }
    return _zhuyetableView;
}

- (NSMutableArray *)infoArr
{
    if (!_infoArr)
    {
        _infoArr = [NSMutableArray array];
    }
    return _infoArr;
}

-(UIButton *)newMessageButton{
    if (!_newMessageButton) {
        _newMessageButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [_newMessageButton setFrame:CGRectMake((SCREEN_WIDTH - 170) / 2, 5 + IMAGEHEIGHT / 667 * IPHONE_H, 170, 40)];
        [_newMessageButton.layer setMasksToBounds:YES];
        [_newMessageButton.layer setCornerRadius:5.0];
        [_newMessageButton setBackgroundColor:[UIColor grayColor]];
        [_newMessageButton addSubview:self.newMessageImage];
        [_newMessageButton addSubview:self.newMessageTipsLabel];
        UIImageView *arrow = [[UIImageView alloc]initWithFrame:CGRectMake(170 - 30, 10, 20, 20)];
        [arrow setImage:[UIImage imageNamed:@"faxianjiantou"]];
        [_newMessageButton addSubview:arrow];
        [_newMessageButton addTarget:self action:@selector(newMessageAction:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _newMessageButton;
}

- (UIImageView *)newMessageImage {
    if (!_newMessageImage) {
        _newMessageImage = [[UIImageView alloc]initWithFrame:CGRectMake(5, 5, 30, 30)];
        [_newMessageImage.layer setMasksToBounds:YES];
        [_newMessageImage.layer setCornerRadius:5.0];
    }
    return _newMessageImage;
}

-(UILabel *)newMessageTipsLabel {
    if (!_newMessageTipsLabel) {
        _newMessageTipsLabel = [[UILabel alloc]initWithFrame:CGRectMake(40, 0, 170 - 80, 40)];
        [_newMessageTipsLabel setTextAlignment:NSTextAlignmentCenter];
        [_newMessageTipsLabel setTextColor:[UIColor whiteColor]];
        [_newMessageTipsLabel setFont:gFontMain15];
    }
    return _newMessageTipsLabel;
}
@end
