//
//  DownloadViewController.m
//  kuangjiaTingWen
//
//  Created by 泡果 on 16/8/8.
//  Copyright © 2016年 贺楠. All rights reserved.
//

#import "DownloadViewController.h"
#import "BatchdownloadViewController.h"
#import "DownLoadLiftViewController.h"
#import "DownLoadRigthViewController.h"
#import "ProjiectDownLoadManager.h"

#define downManager [ProjiectDownLoadManager defaultProjiectDownLoadManager]

static CGFloat const titleH = 50;/** 文字高度  */
static CGFloat const MaxScale = 1.0;/** 选中文字放大  */

@interface DownloadViewController () <UIScrollViewDelegate>

/** 文字scrollView  */
@property (nonatomic, strong) UIScrollView *titleScrollView;
/** 控制器scrollView  */
@property (nonatomic, strong) UIScrollView *contentScrollView;
/** 标签文字  */
@property (nonatomic ,strong) NSArray * titlesArr;
/** 标签按钮  */
@property (nonatomic, strong) NSMutableArray *buttons;
/** 选中的按钮  */
@property (nonatomic ,strong) UIButton * selectedBtn;
/** 选中的按钮背景图  */
@property (nonatomic ,strong) UIImageView * imageBackView;
/** 按钮下方的下划线  */
@property (nonatomic ,strong) UIView *lineView;

@property (strong, nonatomic) UIButton *downloadingCountButton;

@property (assign, nonatomic) BOOL isShowVipTips;

@property (assign, nonatomic) BOOL isShowVipTipsFromLogin;
@end

@implementation DownloadViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self setupData];
    [self setupView];
    
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
//    self.hidesBottomBarWhenPushed = YES;
    [self.navigationController setNavigationBarHidden:YES animated:YES];
    
    [self click:self.buttons[1]];
    
    if (_isShowVipTipsFromLogin && [[CommonCode readFromUserD:@"isLogin"] boolValue] == YES) {
        UIAlertController *qingshuruyonghuming = [UIAlertController alertControllerWithTitle:@"温馨提示" message:@"您还不是会员，无法使用批量下载功能，是否前往开通会员" preferredStyle:UIAlertControllerStyleAlert];
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

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [[NSNotificationCenter defaultCenter] postNotificationName:@"removeAllDeleteButton" object:nil];
}

- (void)setupData {
    
     [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(changeNumber:) name:@"changeNumber" object:nil];
}

- (void)setupView {
    
//    [self enableAutoBack];
    self.title = @"我的下载";
    self.automaticallyAdjustsScrollViewInsets = NO;
    self.extendedLayoutIncludesOpaqueBars = NO;
    UIView *topView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, IPHONE_W, 64)];
    [topView setUserInteractionEnabled:YES];
    topView.backgroundColor = [UIColor whiteColor];
    [self.view addSubview:topView];
    
    UIButton *leftBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    leftBtn.frame = CGRectMake(10, 25, 35, 35);
    [leftBtn setImageEdgeInsets:UIEdgeInsetsMake(5, 0, 5, 10)];
    [leftBtn setImage:[UIImage imageNamed:@"back"] forState:UIControlStateNormal];
    leftBtn.accessibilityLabel = @"返回";
    [leftBtn addTarget:self action:@selector(back) forControlEvents:UIControlEventTouchUpInside];
    [topView addSubview:leftBtn];
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(back)];
    [topView addGestureRecognizer:tap];
    
    UILabel *topLab = [[UILabel alloc]initWithFrame:CGRectMake(50, 30, IPHONE_W - 100, 30)];
    topLab.textColor = [UIColor blackColor];
    topLab.font = [UIFont boldSystemFontOfSize:17.0f];
    topLab.text = @"我的下载";
    topLab.backgroundColor = [UIColor clearColor];
    topLab.textAlignment = NSTextAlignmentCenter;
    [topView addSubview:topLab];
    
    UIView *seperatorLine = [[UIView alloc]initWithFrame:CGRectMake(0, 63.5, SCREEN_WIDTH, 0.5)];
    [seperatorLine setBackgroundColor:[UIColor lightGrayColor]];
    [topView addSubview:seperatorLine];
    
    //适配iPhoneX导航栏
    if (IS_IPHONEX) {
        topView.frame = CGRectMake(0, 0, IPHONE_W, 88);
        leftBtn.frame = CGRectMake(10, 25 + 24, 35, 35);
        topLab.frame = CGRectMake(50, 30 + 24, IPHONE_W - 100, 30);
        seperatorLine.frame = CGRectMake(0, 63.5 + 24, SCREEN_WIDTH, 0.5);
    }else{
        topView.frame = CGRectMake(0, 0, IPHONE_W, 64);
        leftBtn.frame = CGRectMake(10, 25, 35, 35);
        topLab.frame = CGRectMake(50, 30, IPHONE_W - 100, 30);
        seperatorLine.frame = CGRectMake(0, 63.5, SCREEN_WIDTH, 0.5);
    }

    [self addChildViewController];    /** 添加子控制器视图  */
    
    [self setTitleScrollView];        /** 添加文字标签  */
    
    [self setContentScrollView];      /** 添加scrollView  */
    
    [self setupTitle];                /** 设置标签按钮 文字 背景图  */
    
    self.automaticallyAdjustsScrollViewInsets = NO;
    
    self.contentScrollView.contentSize = CGSizeMake(self.titlesArr.count * SCREEN_WIDTH, 0);
    self.contentScrollView.pagingEnabled = YES;
    self.contentScrollView.showsHorizontalScrollIndicator  = NO;
    self.contentScrollView.userInteractionEnabled = YES;
    self.contentScrollView.delegate = self;
    NSDictionary *userInfoDict = [CommonCode readFromUserD:@"dangqianUserInfo"];
    if ([userInfoDict[results][member_type] intValue] == 0) {
        self.contentScrollView.scrollEnabled = NO;
    }
    
    [self.view addSubview:self.downloadingCountButton];
    [self.downloadingCountButton setHidden:YES];
    [self.downloadingCountButton setTitle:@"0" forState:UIControlStateNormal];
    
//    NSArray *downloadingArr = [downManager.downLoadQueue.operations mutableCopy];
//    if ([downloadingArr count]) {
//        [self.downloadingCountButton setHidden:NO];
//        [self.downloadingCountButton setTitle:[NSString stringWithFormat:@"%lu",[downloadingArr count]] forState:UIControlStateNormal];
//    }
//    else{
//        [self.downloadingCountButton setHidden:YES];
//    }
    
}

- (UIButton *)downloadingCountButton {
    if (!_downloadingCountButton ) {
        _downloadingCountButton  = [UIButton buttonWithType:UIButtonTypeCustom];
        [_downloadingCountButton setFrame:CGRectMake(SCREEN_WIDTH - 25, 69, 20, 20)];
        [_downloadingCountButton.layer setMasksToBounds:YES];
        [_downloadingCountButton.layer setCornerRadius:10.0];
        [_downloadingCountButton setBackgroundColor:UIColorFromHex(0xf23131)];
        [_downloadingCountButton.titleLabel setFont:[UIFont systemFontOfSize:11.0]];
    }
    return _downloadingCountButton;
}

- (NSMutableArray *)buttons{
    if (!_buttons)
    {
        _buttons = [NSMutableArray array];
    }
    return _buttons;
}


-(NSArray *)titlesArr{
    
    if (!_titlesArr) {
        _titlesArr  = [NSArray arrayWithObjects:@"批量下载",@"已下载",@"正在下载",nil];
    }
    return _titlesArr;
}

#pragma mark - Utilities

- (void)menuButton:(UIBarButtonItem *)sender{
    
    [self.navigationController popToRootViewControllerAnimated:YES];
    
}

- (void)addChildViewController{
    
    BatchdownloadViewController *batchDownVC = [[BatchdownloadViewController alloc] init];
    DownLoadLiftViewController *downloadHisVC = [[DownLoadLiftViewController alloc]init];
    DownLoadRigthViewController *downloadingVC = [[DownLoadRigthViewController alloc]init];
    [batchDownVC setTitle:self.titlesArr[0]];
    [downloadHisVC setTitle:self.titlesArr[1]];
    [downloadingVC setTitle:self.titlesArr[2]];
    [self addChildViewController:batchDownVC];
    [self addChildViewController:downloadHisVC];
    [self addChildViewController:downloadingVC];
}

- (void)setTitleScrollView{
    
    CGRect rect  = CGRectMake(0,IS_IPHONEX?IPHONEX_TOP_H:64, SCREEN_WIDTH, titleH);
    self.titleScrollView = [[UIScrollView alloc] initWithFrame:rect];
    [self.view addSubview:self.titleScrollView];
    
}
- (void)setContentScrollView{
    
    CGFloat y  = CGRectGetMaxY(self.titleScrollView.frame);
    CGRect rect  = CGRectMake(0, y+2, SCREEN_WIDTH, SCREEN_HEIGHT - titleH - 2);
    self.contentScrollView = [[UIScrollView alloc] initWithFrame:rect];
    [self.view addSubview:self.contentScrollView];

}

- (void)setupTitle{
    NSUInteger count = self.childViewControllers.count;
    
    CGFloat x = 0;
    CGFloat w = SCREEN_WIDTH/self.titlesArr.count;
    CGFloat h = titleH;
    self.lineView = [[UIView alloc]initWithFrame:CGRectMake(0, titleH - 2, w, 2)];
    [self.lineView setBackgroundColor:gMainColor];
    [self.titleScrollView addSubview:self.lineView];
    
    for (int i = 0; i < count; i++){
        UIViewController *vc = self.childViewControllers[i];
        x = i * w;
        CGRect rect = CGRectMake(x, 0, w, h);
        UIButton *btn = [[UIButton alloc] initWithFrame:rect];
        btn.tag = i;
        [btn setTitle:vc.title forState:UIControlStateNormal];
        [btn setTitleColor:gTextDownload forState:UIControlStateNormal];
        [btn.titleLabel setTextAlignment:NSTextAlignmentCenter];
        btn.titleLabel.font = CUSTOM_FONT_TYPE(15.0);
        [btn addTarget:self action:@selector(click:) forControlEvents:UIControlEventTouchDown];
        
        [self.buttons addObject:btn];
        [self.titleScrollView addSubview:btn];
        
            ProjiectDownLoadManager *manager = [ProjiectDownLoadManager defaultProjiectDownLoadManager];
            NSArray *arr = [manager downloadAllNewObjArrar];
        
        if (i == 0){
            [self click:btn];
        }
        else
            if ( i == 1 && [arr count] > 0){
            [self click:btn];
        }
        
    }
    self.titleScrollView.contentSize = CGSizeMake(count * w, titleH);
    self.titleScrollView.showsHorizontalScrollIndicator = NO;
    
}
-(void)click:(UIButton *)sender{
    
    NSDictionary *userInfoDict = [CommonCode readFromUserD:@"dangqianUserInfo"];
    NSInteger i = sender.tag;
    if ([userInfoDict[results][member_type] intValue] == 0 && i == 0) {
        if (_isShowVipTips) {
            UIAlertController *qingshuruyonghuming = [UIAlertController alertControllerWithTitle:@"温馨提示" message:@"您还不是会员，无法使用批量下载功能，是否前往开通会员" preferredStyle:UIAlertControllerStyleAlert];
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
        _isShowVipTips = YES;
        return;
    }
    CGFloat x  = i *SCREEN_WIDTH;
    self.contentScrollView.contentOffset = CGPointMake(x, 0);
    [sender setTitleColor:gMainColor forState:UIControlStateSelected];
    [self selectTitleBtn:sender];
    [self setUpOneChildController:i];
    [self.lineView setFrame:CGRectMake(sender.frame.origin.x + 10, titleH - 2, (SCREEN_WIDTH - 60)/self.titlesArr.count, 2)];
    
}

- (void)selectTitleBtn:(UIButton *)btn{
    
    self.selectedBtn.transform = CGAffineTransformIdentity;
    [self.lineView setFrame:CGRectMake(self.selectedBtn.frame.origin.x+10, titleH - 2, SCREEN_WIDTH/self.titlesArr.count, 2)];
    
    [btn setTitleColor:gMainColor forState:UIControlStateSelected];
    btn.transform = CGAffineTransformMakeScale(MaxScale, MaxScale);
    self.selectedBtn = btn;
    [self setupTitleCenter:btn];
    
    for (UIButton *btn in self.buttons) {
        if (btn.tag == self.selectedBtn.tag) {
            [btn setTitleColor:gMainColor forState:UIControlStateNormal];
        }
        else{
            [btn setTitleColor:gTextDownload forState:UIControlStateNormal];
        }
    }
    
}

- (void)setupTitleCenter:(UIButton *)sender{
    
    CGFloat offset = sender.center.x - SCREEN_WIDTH * 0.5;
    if (offset < 0) {
        offset = 0;
    }
    CGFloat maxOffset  = self.titleScrollView.contentSize.width - SCREEN_WIDTH;
    if (offset > maxOffset) {
        offset = maxOffset;
    }
    [self.titleScrollView setContentOffset:CGPointMake(offset, 0) animated:YES];
    [self.lineView setFrame:CGRectMake(sender.frame.origin.x + 10, titleH - 2, (SCREEN_WIDTH - 60)/self.titlesArr.count, 2)];
    
}

- (void)setUpOneChildController:(NSInteger)index{
    
    CGFloat x  = index * SCREEN_WIDTH;
    UIViewController *vc  =  self.childViewControllers[index];
    if (vc.view.superview) {
        return;
    }
    vc.view.frame = CGRectMake(x, 0, SCREEN_WIDTH, SCREEN_HEIGHT - self.contentScrollView.frame.origin.y);
    [self.contentScrollView addSubview:vc.view];
    
}


- (void)changeNumber:(NSNotification *)nitification  {
    ProjiectDownLoadManager *p = [ProjiectDownLoadManager defaultProjiectDownLoadManager];
    if (p.downLoadQueue.operationCount) {
        [self.downloadingCountButton setHidden:NO];
        [self.downloadingCountButton setTitle:[NSString stringWithFormat:@"%@", @(p.downLoadQueue.operationCount)] forState:UIControlStateNormal];
    }
    else{
        [self.downloadingCountButton setHidden:YES];
        [self.downloadingCountButton setTitle:[NSString stringWithFormat:@"%@", @(p.downLoadQueue.operationCount)] forState:UIControlStateNormal];
    }
    
}

- (void)back{
    
    [self.navigationController popViewControllerAnimated:YES];
}

#pragma mark - UIScrollView  delegate

-(void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView{
    NSInteger i  = self.contentScrollView.contentOffset.x / SCREEN_WIDTH;
    [self selectTitleBtn:self.buttons[i]];
    [self setUpOneChildController:i];
    if (i != 1) {
        [[NSNotificationCenter defaultCenter] postNotificationName:@"removeAllDeleteButton" object:nil];
    }
}


-(void)scrollViewDidScroll:(UIScrollView *)scrollView{
    if (scrollView.contentOffset.x < 0) {
        [self.navigationController popViewControllerAnimated:YES];
    }
    CGFloat offsetX  = scrollView.contentOffset.x;
    NSInteger leftIndex  = offsetX / SCREEN_WIDTH;
    NSInteger rightIdex  = leftIndex + 1;
    UIButton *leftButton = self.buttons[leftIndex];
    UIButton *rightButton  = nil;
    if (rightIdex < self.buttons.count) {
        rightButton  = self.buttons[rightIdex];
    }
    CGFloat scaleR  = offsetX / SCREEN_WIDTH - leftIndex;
    CGFloat scaleL  = 1 - scaleR;
    CGFloat transScale = MaxScale - 1;
    self.lineView.transform = CGAffineTransformMakeTranslation((offsetX*(self.titleScrollView.contentSize.width / self.contentScrollView.contentSize.width)), 0);
//    CGFloat w = SCREEN_WIDTH/self.titlesArr.count / 2;
//    [self.lineView setFrame:CGRectMake((offsetX*(self.titleScrollView.contentSize.width / self.contentScrollView.contentSize.width)), titleH - 2, w, 2)];
    
    leftButton.transform = CGAffineTransformMakeScale(scaleL * transScale + 1, scaleL * transScale + 1);
    rightButton.transform = CGAffineTransformMakeScale(scaleR * transScale + 1, scaleR * transScale + 1);
    UIColor *rightColor = gMainColor;
    UIColor *leftColor = gTextDownload;
    [leftButton setTitleColor:leftColor forState:UIControlStateNormal];
    [rightButton setTitleColor:rightColor forState:UIControlStateNormal];
    
}
@end
