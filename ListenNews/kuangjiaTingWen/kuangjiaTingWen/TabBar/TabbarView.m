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

@interface TabbarView ()

@property (nonatomic,strong) UIImageView  *btnImgView;
@property (nonatomic,weak) UIButton *seletBtn;

@property (nonatomic,strong) UIButton *rotationBarBtn;
@property (nonatomic,assign) NSInteger currentIdx;

@property (nonatomic,strong)CABasicAnimation* rotationAnimation;

@property (nonatomic,assign)BOOL isPushSkip;


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
        [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(startAnimate:) name:@"startAnimate" object:nil];
        [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(stopAnimate:) name:@"stopAnimate" object:nil];
        [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(dingyueSkipToshouyeVC:) name:@"dingyueSkipToshouyeVC" object:nil];
        [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(dingyueSkipTofaxianVC:) name:@"dingyueSkipTofaxianVC" object:nil];
        //推送跳转播放新闻
        [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(pushNewsDetail:) name:@"pushNewsDetail" object:nil];
        [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(backgroundToPushNews:) name:@"backgroundToPushNews" object:nil];
        [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(setMyunreadMessageTips:) name:@"setMyunreadMessageTips" object:nil];
        
    }
    return self;
}


- (void)setItems:(NSArray *)items{
    _items = items;
    // 进行遍历items -->> items里面是一个个的tabBar，
    [items enumerateObjectsUsingBlock:^(UITabBarItem * _Nonnull tabBarItem, NSUInteger idx, BOOL * _Nonnull stop) {
        //        // (自适应布局*********已取消***********)
        //        _btnImgView = [[UIImageView alloc] initWithImage:tabBarItem.image highlightedImage:tabBarItem.selectedImage];
        //        _btnImgView.center = CGPointMake(btnWidth/2, btnHeight/2-5);
        //        CGRect rect  = _btnImgView.frame;
        //        rect.size = CGSizeMake(21, 21);
        //        _btnImgView.frame = rect;
        
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
        titleLabel.font = [UIFont systemFontOfSize:10];
        titleLabel.text = tabBarItem.title;
        titleLabel.tag = 1000 + idx;
        titleLabel.textColor = nSubColor;
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
//    [_rotationBarBtn setBackgroundImage:[UIImage imageNamed:@"animate_r"] forState:UIControlStateNormal];
//    [_rotationBarBtn setBackgroundImage:[UIImage imageNamed:@"animate"] forState:UIControlStateSelected];
    [_rotationBarBtn setBackgroundImage:[UIImage imageNamed:@"home_tab_play"] forState:UIControlStateNormal];
    [_rotationBarBtn setBackgroundImage:[UIImage imageNamed:@"home_tab_play"] forState:UIControlStateSelected];
    
    [_rotationBarBtn addTarget:self action:@selector(rotationBarBtnAction:) forControlEvents:UIControlEventTouchUpInside];
    _rotationBarBtn.isAccessibilityElement = YES;
    _rotationBarBtn.accessibilityLabel = @"新闻详情";
    [self addSubview:_rotationBarBtn];
    
//    UIView *line = [[UIView alloc]initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, 0.3)];
//    [line setBackgroundColor:[UIColor lightGrayColor]];
//    [self addSubview:line];
    
    [self addSubview:self.newMessageButton];
    [self.newMessageButton setHidden:YES];
}

// 布局按钮(自适应布局*********已取消***********)
//- (void)layoutSubviews{
//    [super layoutSubviews];
//    CGFloat btnX = 0;
//    CGFloat btnY = 0;
//    for (int i = 2; i < self.subviews.count; i++) {
//        UIButton *btn = self.subviews[i];
//        btnX = (i - 2) * btnWidth;
//        btn.frame = CGRectMake(btnX, btnY, btnWidth, btnHeight);
//    }
//}

- (void)tabBarBtnClick:(UIButton *)btn{
    // 二次点击当前的tabBar，释放注释可(return)不再执行动画
//    if (btn == self.seletBtn) return;
        ((UIImageView *)self.seletBtn.subviews[0]).highlighted = NO;
        ((UIImageView *)btn.subviews[0]).highlighted = YES;
        ((UILabel *)self.seletBtn.subviews[1]).textColor = [UIColor grayColor];
//        ((UILabel *)btn.subviews[1]).textColor = gMainColor;
        ((UILabel *)btn.subviews[1]).textColor = nMainColor;
        self.seletBtn = btn;
        _currentIdx = btn.tag - 2000;
    
    // 获取点击的索引 --> 对应tabBar的索引
    if ([self.delegate respondsToSelector:@selector(LC_tabBar:didSelectItem:)]) {
        NSInteger index = btn.tag - 2000;
        [self.delegate LC_tabBar:self didSelectItem:index];
    }
}

- (void)rotationBarBtnAction:(UIButton *)sender{
    
    NSString *pushNewsID = @"";
    if (_isPushSkip) {
        pushNewsID = [[NSUserDefaults standardUserDefaults]valueForKey:@"pushNews"];
        [[NSUserDefaults standardUserDefaults] synchronize];
    }
    else{
        pushNewsID = @"NO";
    }
    
    if (ExIsKaiShiBoFang == YES){
        switch (_currentIdx) {
            case 0:
                if (APPDELEGATE.shouyeSkipToPlayingVC) {
                    APPDELEGATE.shouyeSkipToPlayingVC(pushNewsID);
                }
                break;
            case 1:
                if (APPDELEGATE.dingyueSkipToPlayingVC) {
                    APPDELEGATE.dingyueSkipToPlayingVC(pushNewsID);
                }
                break;
            case 2:
                if (APPDELEGATE.faxianSkipToPlayingVC) {
                    APPDELEGATE.faxianSkipToPlayingVC(pushNewsID);
                }
                break;
            case 3:
                if (APPDELEGATE.woSkipToPlayingVC) {
                    APPDELEGATE.woSkipToPlayingVC(pushNewsID);
                }
                break;
            default:
                break;
        }
        [_rotationBarBtn setSelected:YES];
        [CommonCode writeToUserD:@"NO" andKey:@"isPlayingGray"];
    }
    else{
        if (_isPushSkip) {
            //TODO:
            [_rotationBarBtn setSelected:YES];
            [CommonCode writeToUserD:@"NO" andKey:@"isPlayingGray"];
            switch (_currentIdx) {
                case 0:
                    
                    if (APPDELEGATE.shouyeSkipToPlayingVC) {
                        APPDELEGATE.shouyeSkipToPlayingVC(pushNewsID);
                    }
                    else{
                        //TODO:
                        [self performSelector:@selector(GoPushNews) withObject:nil afterDelay:1.0];
                    }
                    break;
                case 1:
                    if (APPDELEGATE.dingyueSkipToPlayingVC) {
                        APPDELEGATE.dingyueSkipToPlayingVC(pushNewsID);
                    }
                    break;
                case 2:
                    if (APPDELEGATE.faxianSkipToPlayingVC) {
                        APPDELEGATE.faxianSkipToPlayingVC(pushNewsID);
                    }
                    break;
                case 3:
                    if (APPDELEGATE.woSkipToPlayingVC) {
                        APPDELEGATE.woSkipToPlayingVC(pushNewsID);
                    }
                    break;
                default:
                    break;
            }
        }
        else{
            NSString *haveTheLastNewsData = [CommonCode readFromUserD:@"haveTheLastNewsData"];
            if ([haveTheLastNewsData isEqualToString:@"YES"]) {
                switch (_currentIdx) {
                    case 0:
                        if (APPDELEGATE.shouyeSkipToPlayingVC) {
                            APPDELEGATE.shouyeSkipToPlayingVC(pushNewsID);
                        }
                        break;
                    case 1:
                        if (APPDELEGATE.dingyueSkipToPlayingVC) {
                            APPDELEGATE.dingyueSkipToPlayingVC(pushNewsID);
                        }
                        break;
                    case 2:
                        if (APPDELEGATE.faxianSkipToPlayingVC) {
                            APPDELEGATE.faxianSkipToPlayingVC(pushNewsID);
                        }
                        break;
                    case 3:
                        if (APPDELEGATE.woSkipToPlayingVC) {
                            APPDELEGATE.woSkipToPlayingVC(pushNewsID);
                        }
                        break;
                    default:
                        break;
                }
                [_rotationBarBtn setSelected:YES];
                [CommonCode writeToUserD:@"NO" andKey:@"isPlayingGray"];
            
            }
            else{
                [SVProgressHUD showInfoWithStatus:@"请至少选择一条新闻"];
                [self performSelector:@selector(SVPDismiss) withObject:nil afterDelay:1.0];
                
            }
        }
        
    }
    _isPushSkip = NO;
}

- (void)imgAnimate:(UIButton*)btn
{
    _rotationAnimation = [CABasicAnimation animationWithKeyPath:@"transform.rotation.z"];
    _rotationAnimation.toValue = [NSNumber numberWithFloat: M_PI * 2.0 ];
    _rotationAnimation.duration = 2.0;
    _rotationAnimation.cumulative = YES;
    _rotationAnimation.repeatCount = HUGE_VALF;
    
    [btn.layer addAnimation:_rotationAnimation forKey:@"rotationAnimation"];  
}

- (void)stopAnimate {
    [_rotationBarBtn setSelected:YES];
    [_rotationBarBtn.layer removeAllAnimations];
}

- (void)SVPDismiss {
    [SVProgressHUD dismiss];
}

- (void)startAnimate:(NSNotification *)notification{
    [_rotationBarBtn setSelected:YES];
    [self imgAnimate:_rotationBarBtn];
}

- (void)stopAnimate:(NSNotification *)notification{
    [self stopAnimate];
}

- (void)dingyueSkipToshouyeVC:(NSNotification *)notification {
    UIButton *shouyeTabBarBtn = (UIButton *)[self viewWithTag:2000];
    [self tabBarBtnClick:shouyeTabBarBtn];
}
- (void)dingyueSkipTofaxianVC:(NSNotification *)notification {
    UIButton *faxianTabBarBtn = (UIButton *)[self viewWithTag:2002];
    [self tabBarBtnClick:faxianTabBarBtn];
}

- (void)GoPushNews {
    [[NSNotificationCenter defaultCenter] postNotificationName:@"backgroundToPushNews" object:nil];
}

- (void)pushNewsDetail:(NSNotification *)notification {
//    DefineWeakSelf;
//    [NetWorkTool getpostinfoWithpost_id:[[NSUserDefaults standardUserDefaults]valueForKey:@"pushNews"] andpage:nil andlimit:nil sccess:^(NSDictionary *responseObject) {
//        if ([responseObject[@"status"] integerValue] == 1) {
//            weakSelf.pushNewsInfo = [responseObject[@"results"] mutableCopy];
//            [NetWorkTool getAllActInfoListWithAccessToken:nil ac_id:weakSelf.pushNewsInfo[@"post_news"] keyword:nil andPage:nil andLimit:nil sccess:^(NSDictionary *responseObject) {
//                if ([responseObject[@"status"] integerValue] == 1){
//                    [weakSelf.pushNewsInfo setObject:[responseObject[@"results"] firstObject] forKey:@"post_act"];
//                    [weakSelf presentPushNews];
//                }
//                else{
//                    [SVProgressHUD showErrorWithStatus:responseObject[@"msg"]];
//                }
//            } failure:^(NSError *error) {
//                //
//                [SVProgressHUD showErrorWithStatus:@"网络请求失败"];
//            }];
//        }
//        else{
//            [SVProgressHUD showErrorWithStatus:responseObject[@"msg"]];
//        }
//        
//    } failure:^(NSError *error) {
//        [SVProgressHUD showErrorWithStatus:@"网络请求失败"];
//        NSLog(@"%@",error);
//    }];
    
    UIButton *playBtn = (UIButton *)[self viewWithTag:110];
    _isPushSkip = YES;
    [self rotationBarBtnAction:playBtn];
}

- (void)backgroundToPushNews:(NSNotification *)notification{
    UIButton *playBtn = (UIButton *)[self viewWithTag:110];
    _isPushSkip = YES;
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
