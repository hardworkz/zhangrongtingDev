//
//  TabbarView.m
//  TabBar111
//
//  Created by mac on 16/7/18.
//  Copyright © 2016年 mac.IOS. All rights reserved.
//


#define ScreenWidth     [UIScreen mainScreen].bounds.size.width

#define btnWidth        (ScreenWidth/(self.items.count + 1))
#define btnHeight       49
#define imageSize       21

#import "TabbarView.h"
#import "AppDelegate.h"
#import "ClassViewController.h"

@interface TabbarView ()

@property (nonatomic,strong) UIImageView  *btnImgView;
@property (nonatomic,weak) UIButton *seletBtn;


@property (nonatomic,strong)CABasicAnimation* rotationAnimation;

//@property (nonatomic,assign)BOOL isPushSkip;


@property (nonatomic,strong) UIButton *newMessageButton;

@end

@implementation TabbarView

- (instancetype)initWithFrame:(CGRect)frame{
    if (self = [super initWithFrame:frame]) {
        UIButton *btn111 = [UIButton buttonWithType:UIButtonTypeCustom];
        [self addSubview:btn111];
        UIButton *btn222 = [UIButton buttonWithType:UIButtonTypeCustom];
        [self addSubview:btn222];
        _currentIdx = 0;
        //选中首页
        [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(dingyueSkipToshouyeVC:) name:@"dingyueSkipToshouyeVC" object:nil];
        //选中发现
        [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(dingyueSkipTofaxianVC:) name:@"dingyueSkipTofaxianVC" object:nil];
        //推送跳转播放新闻
        [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(pushNewsDetail:) name:@"pushNewsDetail" object:nil];
        [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(backgroundToPushNews:) name:@"backgroundToPushNews" object:nil];
        [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(setMyunreadMessageTips:) name:@"setMyunreadMessageTips" object:nil];
        
        
        //播放器状态改变
        RegisterNotify(SONGPLAYSTATUSCHANGE, @selector(playStatusChange:))
    }
    return self;
}

- (void)startAnimate:(NSNotification *)notification{
    [_rotationBarBtn setSelected:YES];
    [self imgAnimate:_rotationBarBtn];
}

- (void)stopAnimate:(NSNotification *)notification{
    [self stopAnimate];
}
- (void)setItems:(NSArray *)items{
    _items = items;
    // 进行遍历items -->> items里面是一个个的tabBar，
    [items enumerateObjectsUsingBlock:^(UITabBarItem * _Nonnull tabBarItem, NSUInteger idx, BOOL * _Nonnull stop) {
        
        // 透明Btn
        UIButton *tabBarBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        if (idx > 1) {
            tabBarBtn.frame = CGRectMake(ScreenWidth/(items.count + 1)*(idx + 1), 0, btnWidth, btnHeight);
        }
        else{
            tabBarBtn.frame = CGRectMake(ScreenWidth/(items.count + 1)*idx, 0, btnWidth, btnHeight);
        }
        tabBarBtn.isAccessibilityElement = YES;
        if (idx == 3) {
            tabBarBtn.accessibilityLabel = @"我的";
        }
        else{
            tabBarBtn.accessibilityLabel = tabBarItem.title;
        }
        
        // tabBar图片
        _btnImgView = [[UIImageView alloc] initWithImage:tabBarItem.image highlightedImage:tabBarItem.selectedImage];
        [_btnImgView setContentMode:UIViewContentModeScaleToFill];
        _btnImgView.isAccessibilityElement = YES;
        _btnImgView.frame = CGRectMake(btnWidth/2-imageSize/2, 6, imageSize, imageSize);
        // tabBar标题
        UILabel *titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, CGRectGetMaxY(_btnImgView.frame) + 5, ScreenWidth/(items.count + 1), 11)];
        titleLabel.textAlignment = NSTextAlignmentCenter;
        titleLabel.font = CUSTOM_FONT_TYPE(10.0);
        titleLabel.text = tabBarItem.title;
        titleLabel.tag = 1000 + idx;
        titleLabel.textColor = TITLE_COLOR_HEX;
        tabBarBtn.tag = idx + 2000;
        [tabBarBtn addSubview:_btnImgView];
        [tabBarBtn addSubview:titleLabel];
        if (!idx) [self tabBarBtnClick:tabBarBtn];// 默认第0个
        
        [tabBarBtn addTarget:self action:@selector(tabBarBtnClick:) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:tabBarBtn];
    }];
    //转盘按钮
    _rotationBarBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    _rotationBarBtn.frame = CGRectMake(ScreenWidth/(items.count + 1) * 2 + btnWidth/2 -21, 2.5, 42, 42);
    [_rotationBarBtn setSelected:NO];
    [_rotationBarBtn setTag:110];
    [_rotationBarBtn setBackgroundImage:[UIImage imageNamed:@"home_tab_play"] forState:UIControlStateNormal];
    [_rotationBarBtn setBackgroundImage:[UIImage imageNamed:@"home_tab_play"] forState:UIControlStateSelected];
    
    [_rotationBarBtn addTarget:self action:@selector(rotationBarBtnAction:) forControlEvents:UIControlEventTouchUpInside];
    _rotationBarBtn.isAccessibilityElement = YES;
    _rotationBarBtn.accessibilityLabel = @"新闻详情";
    [self addSubview:_rotationBarBtn];
    
    [self addSubview:self.newMessageButton];
    [self.newMessageButton setHidden:YES];
}

- (void)tabBarBtnClick:(UIButton *)btn{
    // 二次点击当前的tabBar，释放注释可(return)不再执行动画
//    if (btn == self.seletBtn) return;
    ((UIImageView *)self.seletBtn.subviews[0]).highlighted = NO;
    ((UIImageView *)btn.subviews[0]).highlighted = YES;
    ((UILabel *)self.seletBtn.subviews[1]).textColor = TITLE_COLOR_HEX;
    ((UILabel *)btn.subviews[1]).textColor = nMainColor;
    self.seletBtn = btn;
    _currentIdx = btn.tag - 2000;
    
    // 获取点击的索引 --> 对应tabBar的索引
    if ([self.delegate respondsToSelector:@selector(LC_tabBar:didSelectItem:)]) {
        NSInteger index = btn.tag - 2000;
        [self.delegate LC_tabBar:self didSelectItem:index];
    }
}

- (void)rotationBarBtnAction:(UIButton *)sender
{
    //点击中心按钮调用block
    if (self.rotationBarBtnAction) {
        self.rotationBarBtnAction(sender,_currentIdx);
    }
}

- (void)imgAnimate:(UIButton*)btn{
    
    _rotationAnimation = [CABasicAnimation animationWithKeyPath:@"transform.rotation.z"];
    if (![_rotationAnimation isKindOfClass:[CABasicAnimation class]]) return;
    _rotationAnimation.toValue = [NSNumber numberWithFloat:M_PI * 2.f];
//    _rotationAnimation.toValue = [[NSNumber numberWithFloat:M_PI * 2.f] isKindOfClass:[NSNumber class]]?[NSNumber numberWithFloat:M_PI * 2.f]:[NSNumber numberWithFloat:0.f];//bug:-[__NSCFNumber setToValue:]: unrecognized selector sent to instance 0x170629f80
    _rotationAnimation.duration = 2.0;
    _rotationAnimation.cumulative = YES;
    _rotationAnimation.repeatCount = MAXFLOAT;
    _rotationAnimation.removedOnCompletion = NO;
    
    [btn.layer addAnimation:_rotationAnimation forKey:@"rotationAnimation"];
}

- (void)stopAnimate {
    [_rotationBarBtn setSelected:YES];
    [_rotationBarBtn.layer removeAllAnimations];
}

- (void)SVPDismiss {
    [SVProgressHUD dismiss];
}
#pragma mark -通知- 播放状态改变
- (void)playStatusChange:(NSNotification *)note
{
    switch ([ZRT_PlayerManager manager].status) {
        case ZRTPlayStatusPlay:
            [_rotationBarBtn setSelected:YES];
            [self imgAnimate:_rotationBarBtn];
            break;
            
        case ZRTPlayStatusPause:
            [self stopAnimate];
            break;
        case ZRTPlayStatusStop:
            [self stopAnimate];
            break;
        default:
            break;
    }
}
/**
 设置选中首页
 */
- (void)dingyueSkipToshouyeVC:(NSNotification *)notification {
    UIButton *shouyeTabBarBtn = (UIButton *)[self viewWithTag:2000];
    [self tabBarBtnClick:shouyeTabBarBtn];
}
/**
 设置选中发现
 */
- (void)dingyueSkipTofaxianVC:(NSNotification *)notification {
    UIButton *faxianTabBarBtn = (UIButton *)[self viewWithTag:2002];
    [self tabBarBtnClick:faxianTabBarBtn];
}

- (void)GoPushNews {
    [[NSNotificationCenter defaultCenter] postNotificationName:@"backgroundToPushNews" object:nil];
}
/**
 接收到推送通知点击打开播放器
 */
- (void)pushNewsDetail:(NSNotification *)notification {
    
    UIButton *playBtn = (UIButton *)[self viewWithTag:110];
//    _isPushSkip = YES;
    UITabBarController *tab = (UITabBarController *)APPDELEGATE.window.rootViewController;
    UINavigationController *nav = tab.viewControllers[tab.selectedIndex];
    if (nav != nil) {
        [nav popToRootViewControllerAnimated:NO];
    }
    
    UIButton *shouyeTabBarBtn = (UIButton *)[self viewWithTag:2000];
    [self tabBarBtnClick:shouyeTabBarBtn];
//    if ([self.delegate respondsToSelector:@selector(LC_tabBar:didSelectItem:)]) {
//        NSInteger index = 2000;
//        [self.delegate LC_tabBar:self didSelectItem:index];
//    }
    [self rotationBarBtnAction:playBtn];
}

- (void)backgroundToPushNews:(NSNotification *)notification{
    UIButton *playBtn = (UIButton *)[self viewWithTag:110];
//    _isPushSkip = YES;
    
    if ([self.delegate respondsToSelector:@selector(LC_tabBar:didSelectItem:)]) {
        NSInteger index = 2000;
        [self.delegate LC_tabBar:self didSelectItem:index];
    }
    [self rotationBarBtnAction:playBtn];
}

- (void)setMyunreadMessageTips:(NSNotification *)notification{
    NSArray *addcriticsm = [CommonCode readFromUserD:ADDCRITICISMNUMDATAKEY];
    NSArray *feedback = [CommonCode readFromUserD:FEEDBACKFORMEDATAKEY];
    NSArray *newprompt = [CommonCode readFromUserD:NEWPROMPTFORMEDATAKEY];
    if (([addcriticsm count]) || ([feedback count] && [[CommonCode readFromUserD:FEEDBACKYMESSAGEREAD] isEqualToString:@"NO"])|| ([newprompt count]&& [[CommonCode readFromUserD:TINGYOUQUANMESSAGEREAD] isEqualToString:@"NO"] )) {
        [self.newMessageButton setHidden:NO];
    }
    else{
        [self.newMessageButton setHidden:YES];
    }
}

- (UIButton *)newMessageButton {
    if (!_newMessageButton ) {
        _newMessageButton  = [UIButton buttonWithType:UIButtonTypeCustom];
        [_newMessageButton setFrame:CGRectMake(btnWidth * 4 +btnWidth/2 + imageSize/2 - 3,5, 6, 6)];
        [_newMessageButton.layer setMasksToBounds:YES];
        [_newMessageButton.layer setCornerRadius:3.0];
        [_newMessageButton setBackgroundColor:UIColorFromHex(0xf23131)];
        [_newMessageButton.titleLabel setFont:[UIFont systemFontOfSize:11.0]];
    }
    return _newMessageButton;
}
@end
