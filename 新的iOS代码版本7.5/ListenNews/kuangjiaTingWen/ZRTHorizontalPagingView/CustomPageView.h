//
//  CustomPageView.h
//  kuangjiaTingWen
//
//  Created by zhangrongting on 2017/6/18.
//  Copyright © 2017年 zhimi. All rights reserved.
//

#import <UIKit/UIKit.h>

@class CustomPageView;
@interface CustomPageView : UIView
/**
 *  segment据顶部的距离
 */
@property (nonatomic, assign) CGFloat segmentTopSpace;

/**
 *  自定义segmentButton的size
 */
@property (nonatomic, assign) CGSize segmentButtonSize;

/**
 *  下拉时如需要放大，则传入的图片的上边距约束，默认为不放大
 */
@property (nonatomic, strong) NSLayoutConstraint *magnifyTopConstraint;

/**
 *  切换视图容器
 */
@property (nonatomic, strong, readwrite) UIView  *segmentView;

/**
 *  视图切换的回调block
 */
@property (nonatomic, copy) void (^pagingViewSwitchBlock)(NSInteger switchIndex);

/**
 *  视图点击的回调block
 */
@property (nonatomic, copy) void (^clickEventViewsBlock)(UIView *eventView);

/**
 *  实例化横向分页控件
 *
 *  @param headerView     tableHeaderView
 *  @param headerHeight   tableHeaderView高度
 *  @param segmentButtons 切换按钮的数组
 *  @param segmentHeight  切换视图高度
 *  @param contentViews   内容视图的数组
 *
 *  @return  控件对象
 */
+ (CustomPageView *)pagingViewWithHeaderView:(UIView *)headerView
                                        headerHeight:(CGFloat)headerHeight
                                      segmentButtons:(NSArray *)segmentButtons
                                       segmentHeight:(CGFloat)segmentHeight
                                        contentViews:(NSArray *)contentViews;

/**
 设置按钮选中按钮方法
 
 @param index 选中按钮index
 */
- (void)pagingViewDidSelectedIndex:(NSInteger)index;
/**
 适配滚动过程中导致的横屏切换头部与分页内容出现空白部分,在分页tableview的scrollViewDidEndDecelerating代理方法中调用
 */
- (void)autoContentOffsetY;
@end
