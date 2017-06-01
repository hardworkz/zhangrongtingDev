//
//  TabbarView.h
//  TabBar111
//
//  Created by mac on 16/7/18.
//  Copyright © 2016年 mac.IOS. All rights reserved.
//

#import <UIKit/UIKit.h>
@class TabbarView;
@protocol TabbarViewDelegate <NSObject>

// 声明代理方法
- (void)LC_tabBar:(TabbarView *_Nonnull)tabBar didSelectItem:(NSInteger)index;

@end

@interface TabbarView : UIView

@property(nullable,nonatomic,assign) id<TabbarViewDelegate> delegate;
@property(nullable,nonatomic,copy) NSArray *items;

// 取消动画
@property (nonatomic,assign) BOOL cancelAnimation;

@end
