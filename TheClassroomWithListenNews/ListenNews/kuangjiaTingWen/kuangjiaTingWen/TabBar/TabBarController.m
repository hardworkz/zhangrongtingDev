//
//  TabBarController.m
//  TabBar111
//
//  Created by mac on 16/7/18.
//  Copyright © 2016年 mac.IOS. All rights reserved.
//

#import "TabBarController.h"
#import "shouyeVC.h"
#import "dingyueVC.h"
#import "faxianVC.h"
#import "mineVC.h"
#import "bofangVC.h"
#import "navigationC.h"
#import "LoginNavC.h"
#import "LoginVC.h"
#import "AppDelegate.h"
#import "navigationC.h"
#import "HomePageViewController.h"

#import "TabbarView.h"

@interface TabBarController ()<TabbarViewDelegate>

@property (nonatomic, strong)NSMutableArray *itemArray;

@end

@implementation TabBarController

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    for (UIView *childView in self.tabBar.subviews) {
        if (![childView isKindOfClass:[TabbarView class]]) {
            // 移除添加到TabbarView之外的视图
            [childView removeFromSuperview];
        }
    }
    if ([bofangVC shareInstance].isPlay) {
        [[NSNotificationCenter defaultCenter] postNotificationName:@"startAnimate" object:nil];
    }
    else{
        [[NSNotificationCenter defaultCenter] postNotificationName:@"stopAnimate" object:nil];
    }
}

- (void)viewDidLoad{
    [super viewDidLoad];
    _itemArray = [NSMutableArray array];
//    shouyeVC *shouye = [[shouyeVC alloc]init];
    HomePageViewController *shouye =  [[HomePageViewController alloc]init];
    dingyueVC *dingyue = [[dingyueVC alloc]init];
    faxianVC *faxian = [[faxianVC alloc]init];
    mineVC *mine = [[mineVC alloc]init];
    
//    [self tabBarChildViewController:shouye tabBarTitle:@"听闻" norImage:[UIImage imageNamed:@"shouye_grey_new"] selImage:[UIImage imageNamed:@"shouye_blue_new"]];
//    [self tabBarChildViewController:dingyue tabBarTitle:@"订阅" norImage:[UIImage imageNamed:@"dingyue_grey_new"] selImage:[UIImage imageNamed:@"dingyue_blue_new"]];
//    [self tabBarChildViewController:faxian tabBarTitle:@"发现" norImage:[UIImage imageNamed:@"faxian_grey_new"] selImage:[self changColorXuanRan:@"faxian_blue_new"]];
//    [self tabBarChildViewController:mine tabBarTitle:@"我" norImage:[UIImage imageNamed:@"wo_grey_new"] selImage:[self changColorXuanRan:@"wo_blue_new"]];
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

- (void)setTatBar{
    TabbarView *tabBar = [[TabbarView alloc] init];
    tabBar.backgroundColor = [UIColor whiteColor];
    tabBar.frame = self.tabBar.bounds;
    tabBar.items = self.itemArray;
    tabBar.delegate = self;
    [self.tabBar addSubview:tabBar];
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
    // 获取点击的索引 --> 对应tabBar的索引
    self.selectedIndex = index;
    if (index == 3 && [[CommonCode readFromUserD:@"isLogin"]boolValue] == NO) {
//        [[NSNotificationCenter defaultCenter] postNotificationName:@"loginAlert" object:nil];
    }
}

@end
