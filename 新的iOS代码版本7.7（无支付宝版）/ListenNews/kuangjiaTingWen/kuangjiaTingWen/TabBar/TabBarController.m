//
//  TabBarController.m
//  TabBar111
//
//  Created by mac on 16/7/18.
//  Copyright © 2016年 mac.IOS. All rights reserved.
//

#import "TabBarController.h"
#import "dingyueVC.h"
#import "faxianVC.h"
#import "mineVC.h"
#import "navigationC.h"
#import "LoginNavC.h"
#import "LoginVC.h"
#import "AppDelegate.h"
#import "navigationC.h"
#import "HomePageViewController.h"

#import "TabbarView.h"

@interface TabBarController ()<TabbarViewDelegate>

@property (nonatomic, strong)NSMutableArray *itemArray;

@property (strong, nonatomic) NSMutableDictionary *pushNewsInfo;

@property (strong, nonatomic) navigationC *navigationVC;

@property (strong, nonatomic) TabbarView *customTabBar;
@end

@implementation TabBarController
//防止使用 popToViewController 或者 popToRootViewControllerAnimated 导致自定义tabbar出现重复tabbarItem 移除系统自带按钮，使用该方法还能防止popToViewController调用后到导致按钮状态无法改变的奇怪问题，所以不放在viewWillAppear 方法调用
-(void)viewWillLayoutSubviews{
    [super viewWillLayoutSubviews];
    for (UIView *child in self.tabBar.subviews) {
        if ([child isKindOfClass:NSClassFromString(@"UITabBarButton")]) {
            [child removeFromSuperview];
        }
    }
}
- (void)viewWillAppear:(BOOL)animated{
    
    [super viewWillAppear:animated];
}
- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
//    [self getPushNewsDetail];
}
- (void)viewDidLoad{
    [super viewDidLoad];
    _itemArray = [NSMutableArray array];
    HomePageViewController *shouye =  [[HomePageViewController alloc]init];
    dingyueVC *dingyue = [[dingyueVC alloc]init];
    faxianVC *faxian = [[faxianVC alloc]init];
    mineVC *mine = [[mineVC alloc]init];
    
    [self tabBarChildViewController:shouye tabBarTitle:@"听闻" norImage:[UIImage imageNamed:@"home_tab_home"] selImage:[UIImage imageNamed:@"home_tab_home_select"]];
    [self tabBarChildViewController:dingyue tabBarTitle:@"订阅" norImage:[UIImage imageNamed:@"home_tab_subscribe"] selImage:[UIImage imageNamed:@"home_tab_subscribe_select"]];
    [self tabBarChildViewController:faxian tabBarTitle:@"发现" norImage:[UIImage imageNamed:@"home_tab_find"] selImage:[self changColorXuanRan:@"home_tab_find_select"]];
    [self tabBarChildViewController:mine tabBarTitle:@"我" norImage:[UIImage imageNamed:@"home_tab_me"] selImage:[self changColorXuanRan:@"home_tab_me_select"]];
    
    // 自定义TatBar
    [self setTatBar];
}
- (UIImage *)changColorXuanRan:(NSString *)img{
    UIImage *imgName = [[UIImage imageNamed:img] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
    return imgName;
}

- (void)setTatBar
{
    TabbarView *tabBar = [[TabbarView alloc] init];
    tabBar.backgroundColor = [UIColor whiteColor];
    tabBar.frame = self.tabBar.bounds;
//    tabBar.frame = CGRectMake(0, 0, SCREEN_WIDTH, 49);
    tabBar.items = self.itemArray;
    tabBar.delegate = self;
    _customTabBar = tabBar;
    //点击中心圆按钮调用block
    DefineWeakSelf
    tabBar.rotationBarBtnAction = ^(UIButton *sender,NSInteger selectedIndex) {
        //获取当前tabbar控制器选中的分页面导航栏控制器
        _navigationVC = weakSelf.childViewControllers[selectedIndex];
        
        //判断是否是课堂试听界面跳转
        if ([ZRT_PlayerManager manager].playType == ZRTPlayTypeClassroomTry && Exact_id != nil) {
            NSMutableDictionary *dict = [CommonCode readFromUserD:@"is_free_data"];
            ClassViewController *vc = [ClassViewController shareInstance];
            vc.jiemuDescription = dict[@"jiemuDescription"];
            vc.jiemuFan_num = dict[@"jiemuFan_num"];
            vc.jiemuID = dict[@"jiemuID"];
            vc.jiemuImages = dict[@"jiemuImages"];
            vc.jiemuIs_fan = dict[@"jiemuIs_fan"];
            vc.jiemuMessage_num = dict[@"jiemuMessage_num"];
            vc.jiemuName = dict[@"jiemuName"];
            vc.act_id = Exact_id;
            vc.listVC = _navigationVC.topViewController;
            vc.hidePayBtn = NO;
            [_navigationVC.navigationBar setHidden:YES];
            [_navigationVC pushViewController:vc animated:YES];
            return;
        }
        
        //判断是否是推送跳转
        NSString *pushNewsID = [CommonCode readFromUserD:pushNews];//获取推送ID
        if (pushNewsID) {//存在推送新闻ID
            //推送新闻是当前播放新闻
            if ([[CommonCode readFromUserD:@"dangqianbofangxinwenID"] isEqualToString:pushNewsID]){
                //如果没有跳转到新闻详情界面，跳转进去
                if (![_navigationVC.topViewController isKindOfClass:[NewPlayVC class]]) {
                    [_navigationVC pushViewController:[NewPlayVC shareInstance] animated:YES];
                    //如果播放暂停，开始播放
                    if (![ZRT_PlayerManager manager].isPlaying) {
                        [[ZRT_PlayerManager manager] startPlay];
                    }
                }
                //如果播放暂停，开始播放
                if (![ZRT_PlayerManager manager].isPlaying) {
                    [[ZRT_PlayerManager manager] startPlay];
                }
            }
            else{
                //获取推送新闻数据并跳转进入
                [weakSelf getPushNewsDetail];
            }
        }else{
            //判断是否是正在播放新闻跳转
            if ([ZRT_PlayerManager manager].currentSong) {
                [_navigationVC pushViewController:[NewPlayVC shareInstance] animated:YES];
            }
            else{//判断是否是新闻播放记录跳转
                if ([CommonCode readFromUserD:NewPlayVC_THELASTNEWSDATA]) {
                    //跳转上一次播放的新闻
                    [weakSelf skipToLastNews];
                }
                else{
                    [SVProgressHUD showInfoWithStatus:@"请至少选择一条新闻或者课堂"];
                    [self performSelector:@selector(SVPDismiss) withObject:nil afterDelay:1.0];
                    
                }
            }
        }
    };
    [self.tabBar addSubview:tabBar];
}
- (void)SVPDismiss {
    [SVProgressHUD dismiss];
}
/**
 点击中心按钮跳转上一次记录新闻详情界面播放
 */
- (void)skipToLastNews
{
    [ZRT_PlayerManager manager].songList = [CommonCode readFromUserD:NewPlayVC_PLAYLIST];
    [ZRT_PlayerManager manager].currentSong = [CommonCode readFromUserD:NewPlayVC_THELASTNEWSDATA];
    //设置播放器播放内容类型
    [ZRT_PlayerManager manager].playType = ZRTPlayTypeNews;
    [NewPlayVC shareInstance].rewardType = RewardViewTypeNone;
    [ZRT_PlayerManager manager].channelType = [[CommonCode readFromUserD:NewPlayVC_PLAY_CHANNEL] intValue];
    [[NewPlayVC shareInstance] playFromIndex:[[CommonCode readFromUserD:NewPlayVC_PLAY_INDEX] integerValue]];
    [_navigationVC.navigationBar setHidden:YES];
    [_navigationVC pushViewController:[NewPlayVC shareInstance] animated:YES];
}

/**
 根据推送ID获取新闻详情数据
 */
- (void)getPushNewsDetail{
    _pushNewsInfo = [NSMutableDictionary new];
    DefineWeakSelf;
    RTLog(@"%@",[CommonCode readFromUserD:pushNews]);
    [NetWorkTool getpostinfoWithpost_id:@"70520" andpage:nil andlimit:nil sccess:^(NSDictionary *responseObject) {
        if ([responseObject[status] integerValue] == 1) {
            weakSelf.pushNewsInfo = [responseObject[results] mutableCopy];
            [weakSelf.pushNewsInfo setObject:weakSelf.pushNewsInfo[@"act"] forKey:@"post_act"];
            [weakSelf presentPushNews];
        }
        else{
            [SVProgressHUD showErrorWithStatus:responseObject[msg]];
        }
        
    } failure:^(NSError *error) {
        [SVProgressHUD showErrorWithStatus:@"网络请求失败"];
        NSLog(@"%@",error);
    }];
}
/**
 通知消息点击跳转新闻详情界面播放
 */
- (void)presentPushNews
{
    [ZRT_PlayerManager manager].songList = @[self.pushNewsInfo];
    [ZRT_PlayerManager manager].currentSong = self.pushNewsInfo;
    //设置新闻ID
    [NewPlayVC shareInstance].post_id = self.pushNewsInfo[@"post_id"];
    //设置播放器播放内容类型
    [ZRT_PlayerManager manager].playType = ZRTPlayTypeNews;
    [NewPlayVC shareInstance].rewardType = RewardViewTypeNone;
    [ZRT_PlayerManager manager].channelType = ChannelTypeChannelNone;
    [[NewPlayVC shareInstance] playFromIndex:0];
    [_navigationVC.navigationBar setHidden:YES];
    [_navigationVC pushViewController:[NewPlayVC shareInstance] animated:YES];
    //清空获取的推送新闻数据
    self.pushNewsInfo = nil;
}


- (void)tabBarChildViewController:(UIViewController *)vc tabBarTitle:(NSString *)title norImage:(UIImage *)norImage selImage:(UIImage *)selImage{
    // 添加导航
    UINavigationController *nav = [[navigationC alloc] initWithRootViewController:vc];
    UITabBarItem *tabBarItem = [[UITabBarItem alloc] init];
    tabBarItem.image = norImage;// 正常状态
    tabBarItem.title = title;
    tabBarItem.selectedImage = selImage;// 高亮状态
    
    // 添加到数组
    [self.itemArray addObject:tabBarItem];
    [self addChildViewController:nav];
}

#pragma mark TabbarViewDelegate
- (void)LC_tabBar:(TabbarView *)tabBar didSelectItem:(NSInteger)index{
    
    if (self.selectedIndex == index && index == 0) {
        RTLog(@"self.selectedIndex:0");
        
        SendNotify(ReloadHomeSelectPageData, nil)
    }
    // 获取点击的索引 --> 对应tabBar的索引
    self.selectedIndex = index;
    if (index == 3 && [[CommonCode readFromUserD:@"isLogin"]boolValue] == NO) {
//        [[NSNotificationCenter defaultCenter] postNotificationName:@"loginAlert" object:nil];
    }
}

@end
