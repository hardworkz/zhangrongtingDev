//
//  CustomPageView.m
//  kuangjiaTingWen
//
//  Created by zhangrongting on 2017/6/18.
//  Copyright © 2017年 zhimi. All rights reserved.
//

#import "CustomPageView.h"
#import "CustomPageScrollView.h"

@interface CustomPageView ()<UIScrollViewDelegate>
@property (nonatomic, weak)   UIView             *headerView;
@property (nonatomic, strong) NSArray            *segmentButtons;
@property (nonatomic, strong) NSArray            *contentViews;


@property (nonatomic, strong) UIScrollView   *horizontalScrollView;

@property (nonatomic, weak)   UIScrollView       *currentScrollView;
@property (nonatomic, strong) NSLayoutConstraint *headerOriginYConstraint;
@property (nonatomic, strong) NSLayoutConstraint *headerSizeHeightConstraint;
@property (nonatomic, assign) CGFloat            headerViewHeight;
@property (nonatomic, assign) CGFloat            segmentBarHeight;
@property (nonatomic, assign) BOOL               isSwitching;
@property (assign, nonatomic) BOOL scrollLeftOrRight;
@property (nonatomic, strong) NSMutableArray     *segmentButtonConstraintArray;


@property (nonatomic, strong) UIView             *currentTouchView;
@property (nonatomic, strong) UIButton           *currentTouchButton;

@property (assign, nonatomic) NSInteger currenPageIndex;
@end

@implementation CustomPageView

static void *CustomPageViewScrollContext = &CustomPageViewScrollContext;
static void *CustomPageViewPanContext    = &CustomPageViewPanContext;
static NSString *pagingCellIdentifier            = @"PagingCellIdentifier";
static NSInteger pagingButtonTag                 = 1000;

#pragma mark - CustomPageView
+ (CustomPageView *)pagingViewWithHeaderView:(UIView *)headerView
                                        headerHeight:(CGFloat)headerHeight
                                      segmentButtons:(NSArray *)segmentButtons
                                       segmentHeight:(CGFloat)segmentHeight
                                        contentViews:(NSArray *)contentViews {
    //创建容器view
    CustomPageView *pagingView = [[CustomPageView alloc] initWithFrame:CGRectMake(0., 0., [[UIScreen mainScreen] bounds].size.width, [[UIScreen mainScreen] bounds].size.height)];
    //创建滚动控件view
    pagingView.horizontalScrollView = [[UIScrollView alloc] initWithFrame:pagingView.bounds];
    pagingView.horizontalScrollView.backgroundColor                = [UIColor clearColor];
    pagingView.horizontalScrollView.delegate                       = pagingView;
    pagingView.horizontalScrollView.pagingEnabled                  = YES;
    pagingView.horizontalScrollView.showsHorizontalScrollIndicator = NO;
    pagingView.horizontalScrollView.showsVerticalScrollIndicator = NO;
    pagingView.horizontalScrollView.scrollEnabled = NO;
    pagingView.headerView                     = headerView;
    pagingView.segmentButtons                 = segmentButtons;
    pagingView.contentViews                   = contentViews;
    pagingView.headerViewHeight               = headerHeight;
    pagingView.segmentBarHeight               = segmentHeight;
    pagingView.segmentButtonConstraintArray   = [NSMutableArray array];
    
    [pagingView addSubview:pagingView.horizontalScrollView];
    [pagingView configureHeaderView];
    [pagingView configureSegmentView];
    [pagingView configureContentView];
    
    return pagingView;
}

- (void)configureHeaderView {
    if(self.headerView) {
        self.headerView.translatesAutoresizingMaskIntoConstraints = NO;
        [self addSubview:self.headerView];
        
        [self addConstraint:[NSLayoutConstraint constraintWithItem:self.headerView attribute:NSLayoutAttributeLeft relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeLeft multiplier:1 constant:0]];
        [self addConstraint:[NSLayoutConstraint constraintWithItem:self.headerView attribute:NSLayoutAttributeRight relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeRight multiplier:1 constant:0]];
        self.headerOriginYConstraint = [NSLayoutConstraint constraintWithItem:self.headerView attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeTop multiplier:1 constant:0];
        [self addConstraint:self.headerOriginYConstraint];
        
        self.headerSizeHeightConstraint = [NSLayoutConstraint constraintWithItem:self.headerView attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:nil attribute:0 multiplier:1 constant:self.headerViewHeight];
        [self.headerView addConstraint:self.headerSizeHeightConstraint];
    }
}

- (void)configureSegmentView {
    
    if(self.segmentView) {
        self.segmentView.translatesAutoresizingMaskIntoConstraints = NO;
        [self addSubview:self.segmentView];
        [self addConstraint:[NSLayoutConstraint constraintWithItem:self.segmentView attribute:NSLayoutAttributeLeft relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeLeft multiplier:1 constant:0]];
        [self addConstraint:[NSLayoutConstraint constraintWithItem:self.segmentView attribute:NSLayoutAttributeRight relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeRight multiplier:1 constant:0]];
        [self addConstraint:[NSLayoutConstraint constraintWithItem:self.segmentView attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:self.headerView ? : self attribute:self.headerView ? NSLayoutAttributeBottom : NSLayoutAttributeTop multiplier:1 constant:0]];
        [self.segmentView addConstraint:[NSLayoutConstraint constraintWithItem:self.segmentView attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:nil attribute:0 multiplier:1 constant:self.segmentBarHeight]];
    }
}

- (void)configureContentView {
    self.horizontalScrollView.contentSize = CGSizeMake(self.contentViews.count * SCREEN_WIDTH, 0);
    for(int i = 0 ;i<self.contentViews.count;i++) {
        CustomPageScrollView *v = self.contentViews[i];
        if (IS_IPHONEX) {
            [v setContentInset:UIEdgeInsetsMake(self.headerViewHeight+self.segmentBarHeight -45, 0., 0., 0.)];
        }else{
            [v setContentInset:UIEdgeInsetsMake(self.headerViewHeight+self.segmentBarHeight , 0., 0., 0.)];
        }
        v.alwaysBounceVertical = YES;
        v.showsVerticalScrollIndicator = NO;
        v.contentOffset = CGPointMake(0., -self.headerViewHeight-self.segmentBarHeight);
        [v.panGestureRecognizer addObserver:self forKeyPath:NSStringFromSelector(@selector(state)) options:NSKeyValueObservingOptionNew | NSKeyValueObservingOptionOld context:&CustomPageViewPanContext];
        [v addObserver:self forKeyPath:NSStringFromSelector(@selector(contentOffset)) options:NSKeyValueObservingOptionNew | NSKeyValueObservingOptionOld context:&CustomPageViewScrollContext];
        v.frame = CGRectMake(SCREEN_WIDTH * i, IS_IPHONEX?-45:0, SCREEN_WIDTH, IS_IPHONEX?v.frame.size.height+30:v.frame.size.height);
        [self.horizontalScrollView addSubview:v];
        
        ContentOffsetYDataModel *model = [[ContentOffsetYDataModel alloc] init];
        model.currentHeaderDisplayHeight = self.headerViewHeight;
        model.contentOffsetY = v.contentOffset.y;
        v.dataModel = model;
    }
    self.currentScrollView = [self.contentViews firstObject];
}

- (UIView *)segmentView {
    if(!_segmentView) {
        _segmentView = [[UIView alloc] init];
        [self configureSegmentButtonLayout];
    }
    return _segmentView;
}

- (void)configureSegmentButtonLayout {
    if([self.segmentButtons count] > 0) {
        
        CGFloat buttonTop    = 0.f;
        CGFloat buttonLeft   = 0.f;
        CGFloat buttonWidth  = 0.f;
        CGFloat buttonHeight = 0.f;
        if(CGSizeEqualToSize(self.segmentButtonSize, CGSizeZero)) {
            buttonWidth = [[UIScreen mainScreen] bounds].size.width/(CGFloat)[self.segmentButtons count];
            buttonHeight = self.segmentBarHeight;
        }else {
            buttonWidth = self.segmentButtonSize.width;
            buttonHeight = self.segmentButtonSize.height;
            buttonTop = (self.segmentBarHeight - buttonHeight)/2.f;
            buttonLeft = ([[UIScreen mainScreen] bounds].size.width - ((CGFloat)[self.segmentButtons count]*buttonWidth))/((CGFloat)[self.segmentButtons count]+1);
        }
        
        [_segmentView removeConstraints:self.segmentButtonConstraintArray];
        for(int i = 0; i < [self.segmentButtons count]; i++) {
            UIButton *segmentButton = self.segmentButtons[i];
            [segmentButton removeConstraints:self.segmentButtonConstraintArray];
            segmentButton.tag = pagingButtonTag+i;
            [segmentButton addTarget:self action:@selector(segmentButtonEvent:) forControlEvents:UIControlEventTouchUpInside];
            [_segmentView addSubview:segmentButton];
            
            if(i == [self.segmentButtons count] - 1) {
                UIView *devider = [[UIView alloc] initWithFrame:CGRectMake(0, self.segmentBarHeight - 0.5, SCREEN_WIDTH, 0.5)];
                devider.backgroundColor = [[UIColor grayColor] colorWithAlphaComponent:0.2];
                [_segmentView addSubview:devider];
                [segmentButton setSelected:YES];
            }
            
            segmentButton.translatesAutoresizingMaskIntoConstraints = NO;
            
            NSLayoutConstraint *topConstraint = [NSLayoutConstraint constraintWithItem:segmentButton attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:_segmentView attribute:NSLayoutAttributeTop multiplier:1 constant:buttonTop];
            NSLayoutConstraint *leftConstraint = [NSLayoutConstraint constraintWithItem:segmentButton attribute:NSLayoutAttributeLeft relatedBy:NSLayoutRelationEqual toItem:_segmentView attribute:NSLayoutAttributeLeft multiplier:1 constant:i*buttonWidth+buttonLeft*i+buttonLeft];
            NSLayoutConstraint *widthConstraint = [NSLayoutConstraint constraintWithItem:segmentButton attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationEqual toItem:nil attribute:0 multiplier:1 constant:buttonWidth];
            NSLayoutConstraint *heightConstraint = [NSLayoutConstraint constraintWithItem:segmentButton attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:nil attribute:0 multiplier:1 constant:buttonHeight];
            
            [self.segmentButtonConstraintArray addObject:topConstraint];
            [self.segmentButtonConstraintArray addObject:leftConstraint];
            [self.segmentButtonConstraintArray addObject:widthConstraint];
            [self.segmentButtonConstraintArray addObject:heightConstraint];
            
            [_segmentView addConstraint:topConstraint];
            [_segmentView addConstraint:leftConstraint];
            [segmentButton addConstraint:widthConstraint];
            [segmentButton addConstraint:heightConstraint];
        }
        
    }
}



- (BOOL)pointInside:(CGPoint)point withEvent:(nullable UIEvent *)event {
    if(point.x < 20) {
        return NO;
    }
    return YES;
}

- (UIView *)hitTest:(CGPoint)point withEvent:(UIEvent *)event {
    UIView *view = [super hitTest:point withEvent:event];
    if ([view isDescendantOfView:self.headerView] || [view isDescendantOfView:self.segmentView]) {
        self.horizontalScrollView.scrollEnabled = NO;
        
        self.currentTouchView = nil;
        self.currentTouchButton = nil;
        
        [self.segmentButtons enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            if(obj == view) {
                self.currentTouchButton = obj;
            }
        }];
        if(!self.currentTouchButton) {
            self.currentTouchView = view;
        }else {
            return view;
        }
        return self.currentScrollView;
    }
    return view;
}

#pragma mark - Setter
- (void)setSegmentTopSpace:(CGFloat)segmentTopSpace {
    if(segmentTopSpace > self.headerViewHeight) {
        _segmentTopSpace = self.headerViewHeight;
    }else {
        _segmentTopSpace = segmentTopSpace;
    }
}

- (void)setSegmentButtonSize:(CGSize)segmentButtonSize {
    _segmentButtonSize = segmentButtonSize;
    [self configureSegmentButtonLayout];
    
}
#pragma mark - Observer
- (void)observeValueForKeyPath:(NSString *)keyPath
                      ofObject:(__unused id)object
                        change:(NSDictionary *)change
                       context:(void *)context {
    
    if(context == &CustomPageViewPanContext) {
        
        if (IS_IPHONEX) {
            self.horizontalScrollView.scrollEnabled = NO;
        }else{
            self.horizontalScrollView.scrollEnabled = YES;
        }
        UIGestureRecognizerState state = [change[NSKeyValueChangeNewKey] integerValue];
        //        RTLog(@"observeValueForKeyPath--state%ld",(long)state);
        //failed说明是点击事件
        if(state == UIGestureRecognizerStateFailed) {
            if(self.currentTouchButton) {
                [self segmentButtonEvent:self.currentTouchButton];
            }else if(self.currentTouchView && self.clickEventViewsBlock) {
                self.clickEventViewsBlock(self.currentTouchView);
            }
            self.currentTouchView = nil;
            self.currentTouchButton = nil;
        }
        
    }else if (context == &CustomPageViewScrollContext) {
        self.currentTouchView = nil;
        self.currentTouchButton = nil;
        
        //判断如果当前对象不属于子页面中的一个并且不是当前选中的子页面，不往下执行
        BOOL isSubScrollView = NO;
        for (UIScrollView *Object in self.contentViews) {
            if ([object isEqual:Object] && [object isEqual:self.currentScrollView]) {
                isSubScrollView = YES;
                break;
            }
        }
        if (!isSubScrollView) {
            RTLog(@"isSubScrollView---return");
            return;
        }
        //判断是否正在切换子页面
        if (self.isSwitching) {
            RTLog(@"isSwitching---return");
            return;
        }
        CGFloat oldOffsetY          = [change[NSKeyValueChangeOldKey] CGPointValue].y;
        CGFloat newOffsetY          = [change[NSKeyValueChangeNewKey] CGPointValue].y;
        
        CGFloat deltaY              = newOffsetY - oldOffsetY;
        
        CGFloat headerViewHeight    = self.headerViewHeight;
        CGFloat headerDisplayHeight = self.headerViewHeight+self.headerOriginYConstraint.constant;
        
        //适配未显示子页面和头部的距离
        [self autoContentOffsetY];
        
        //保存当前子页面的滚动数据和头部变化高度
        CustomPageScrollView *view = object;
        view.dataModel.currentHeaderDisplayHeight = headerDisplayHeight;
        view.dataModel.contentOffsetY = newOffsetY;
        
        
        if(deltaY >= 0) {//向上滚动
            if(headerDisplayHeight - deltaY <= self.segmentTopSpace) {//判断是否到达悬停位置
                self.headerOriginYConstraint.constant = -headerViewHeight+self.segmentTopSpace;
            }else {//上拉约束
                self.headerOriginYConstraint.constant -= deltaY;
            }
            
            if (self.headerOriginYConstraint.constant >= 0 && self.magnifyTopConstraint) {
                self.magnifyTopConstraint.constant = -self.headerOriginYConstraint.constant;
            }
            
        }else {//向下滚动
            if (headerDisplayHeight+self.segmentBarHeight <= -newOffsetY) {//下拉约束
                self.headerOriginYConstraint.constant = -self.headerViewHeight-self.segmentBarHeight-self.currentScrollView.contentOffset.y;
            }
            
            if (self.headerOriginYConstraint.constant > 0 && self.magnifyTopConstraint) {
                self.magnifyTopConstraint.constant = -self.headerOriginYConstraint.constant;
            }
        }
    }
    
}
- (void)adjustContentViewOffset {//侧滑切换底部页面调用，适配页面空白区域
    self.isSwitching = YES;
    //头部view不可见高度值
    CGFloat headerViewDisplayHeight = self.headerViewHeight + self.headerView.frame.origin.y;
    [self.currentScrollView layoutIfNeeded];
    if(self.currentScrollView.contentOffset.y < -self.segmentBarHeight) {
        [self.currentScrollView setContentOffset:CGPointMake(0, -headerViewDisplayHeight-self.segmentBarHeight)];
    }else {
        [self.currentScrollView setContentOffset:CGPointMake(0, self.currentScrollView.contentOffset.y)];
    }
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0)), dispatch_get_main_queue(), ^{
        self.isSwitching = NO;
    });
}
/**
 适配滚动过程中导致的横屏切换头部与分页内容出现空白部分
 */
- (void)autoContentOffsetY
{
    CGFloat headerViewDisplayHeight = self.headerViewHeight + self.headerView.y;
    for (int i = 0;i<self.contentViews.count;i++) {
        CustomPageScrollView *v = self.contentViews[i];
        
        if (![v isEqual:self.currentScrollView]) {
            if(v.contentOffset.y <= -self.segmentBarHeight) {
                [v setContentOffset:CGPointMake(0, -headerViewDisplayHeight-self.segmentBarHeight)];
            }else {
                [v setContentOffset:CGPointMake(0, v.contentOffset.y - (headerViewDisplayHeight - v.dataModel.currentHeaderDisplayHeight))];
                v.dataModel.currentHeaderDisplayHeight = headerViewDisplayHeight;
            }
        }
    }
}
#pragma mark - UIScrollViewDelegate //侧滑切换底部多个View

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
    NSInteger currentPage = scrollView.contentOffset.x/[[UIScreen mainScreen] bounds].size.width;
    //判断当前是否为整数，减少回调次数
    if (currentPage == 0 ||currentPage == 1 ||currentPage == 2 ||currentPage == 3 ||currentPage == 4) {
        //判断是否为当前分页，如果是则不回调block
        if (self.currenPageIndex != currentPage) {
            for(UIButton *b in self.segmentButtons) {
                if(b.tag - pagingButtonTag == currentPage) {
                    [b setSelected:YES];
                }else {
                    [b setSelected:NO];
                }
            }
            
            [self segmentButtonEvent:self.segmentButtons[currentPage]];
            //保存当前分页
            self.currenPageIndex = currentPage;
        }
    }
}
- (void)segmentButtonEvent:(UIButton *)segmentButton {
    for(UIButton *b in self.segmentButtons) {
        [b setSelected:NO];
    }
    [segmentButton setSelected:YES];
    RTLog(@"segmentButton.tag:%ld",segmentButton.tag);
    NSInteger clickIndex = segmentButton.tag-pagingButtonTag;
    
    if (clickIndex <3) {
        [self.horizontalScrollView setContentOffset:CGPointMake(clickIndex * SCREEN_WIDTH, self.horizontalScrollView.contentOffset.y) animated:NO];
        if(self.currentScrollView.contentOffset.y<-(self.headerViewHeight+self.segmentBarHeight)) {
            [self.currentScrollView setContentOffset:CGPointMake(self.currentScrollView.contentOffset.x, -(self.headerViewHeight+self.segmentBarHeight)) animated:NO];
        }else {
            [self.currentScrollView setContentOffset:self.currentScrollView.contentOffset animated:NO];
        }
        self.currentScrollView = self.contentViews[clickIndex];
        
    }
    
    if(self.pagingViewSwitchBlock) {
        self.pagingViewSwitchBlock(clickIndex);
    }
}

- (void)dealloc {
    for(UIScrollView *v in self.contentViews) {
        [v.panGestureRecognizer removeObserver:self forKeyPath:NSStringFromSelector(@selector(state)) context:&CustomPageViewPanContext];
        [v removeObserver:self forKeyPath:NSStringFromSelector(@selector(contentOffset)) context:&CustomPageViewScrollContext];
    }
}
- (void)pagingViewDidSelectedIndex:(NSInteger)index
{
    [self segmentButtonEvent:self.segmentButtons[index]];
}
@end
