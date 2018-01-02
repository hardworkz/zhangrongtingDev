//
//  TBCircleScrollView.m
//  折点点
//
//  Created by 曲天白 on 15/12/3.
//  Copyright © 2015年 yike. All rights reserved.
//

#import "TBCircleScrollView.h"
#import "UIImageView+WebCache.h"
#import "UIButton+WebCache.h"
#import "ClassViewController.h"
#import "HomePageViewController.h"

#define c_width (self.bounds.size.width) //两张图片之前有10点的间隔
#define c_height (self.bounds.size.height)

@implementation TBCircleScrollView
{
    UIPageControl    *_pageControl; //分页控件
    NSMutableArray *_curImageArray; //当前显示的图片数组
    NSInteger          _curPage;    //当前显示的图片位置
    NSTimer           *_timer;      //定时器
    NSArray *newArr;//当前轮播图数据
    NSMutableArray *newsArr;//当前为新闻的数据：（轮播 图中包含课程，url）
    NSMutableArray *chuanchuquArr;  //要点击传出去的数组
    /** 图片下方的下划线  */
    UIView *lineView;
    //下划线的宽
    CGFloat w;
    
}
- (id)initWithFrame:(CGRect)frame andArr:(NSArray *)infoArr
{
    self = [super initWithFrame:frame];
    if (self) {
        //滚动视图
        self.scrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 0, c_width, c_height)];
        self.scrollView.contentSize = CGSizeMake(c_width*3, 0);
        self.scrollView.contentOffset = CGPointMake(c_width, 0);
        self.scrollView.pagingEnabled = YES;
        self.scrollView.showsHorizontalScrollIndicator = NO;
        self.scrollView.delegate = self;
        [self addSubview:self.scrollView];
        
        newArr = [NSArray arrayWithArray:infoArr];
        //筛选轮播图中是新闻的列表
        if (newsArr.count != 0) {
            [newsArr removeAllObjects];
        }else{
            newsArr = [NSMutableArray array];
        }
        for (int i = 0; i<newArr.count; i++) {
            if ([newArr[i][@"cate"] intValue] == 1) {
                [newsArr addObject:newArr[i][@"post_list"]];
            }
        }
        //分页控件
        _pageControl = [[UIPageControl alloc] initWithFrame:CGRectMake(self.scrollView.frame.size.width - 5.0 * infoArr.count, 10.0 , 5.0 , 5.0 )];
        _pageControl.userInteractionEnabled = NO;
        _pageControl.hidesForSinglePage = YES;
        _pageControl.currentPageIndicatorTintColor = ColorWithRGBA(0, 159, 240, 1);
        _pageControl.pageIndicatorTintColor = [UIColor whiteColor];
        //初始化数据，当前图片默认位置是0
        _curImageArray = [[NSMutableArray alloc] initWithCapacity:0];
        _curPage = 0;
        
        UIView *dibuLabView = [[UIView alloc]initWithFrame:CGRectMake(0, self.scrollView.frame.size.height - 22.0 , self.scrollView.frame.size.width , 20.0)];
        dibuLabView.backgroundColor = [[UIColor blackColor]colorWithAlphaComponent:0.5f];
        UIBezierPath *maskPath = [UIBezierPath bezierPathWithRoundedRect:dibuLabView.bounds byRoundingCorners:UIRectCornerBottomLeft | UIRectCornerBottomRight cornerRadii:CGSizeMake(4, 4)];
        CAShapeLayer *maskLayer = [[CAShapeLayer alloc] init];
        maskLayer.frame = dibuLabView.bounds;
        maskLayer.path = maskPath.CGPath;
        dibuLabView.layer.mask = maskLayer;
        w = self.bounds.size.width/infoArr.count;
        lineView = [[UIView alloc]initWithFrame:CGRectMake(3, self.bounds.size.height - 2, w - 6, 2)];
        [lineView setBackgroundColor:gTextColorAssist];
        [self addSubview:lineView];
        
        [self addSubview:dibuLabView];
        self.dibuLab = [[UILabel alloc]initWithFrame:CGRectMake(2.0 , 0 , self.bounds.size.width - 2.0 * (infoArr.count + 2), 20.0)];
        self.dibuLab.textColor = [UIColor whiteColor];
        self.dibuLab.textAlignment = NSTextAlignmentLeft;
        if (IS_IPAD) {
            self.dibuLab.font = [UIFont systemFontOfSize:15.0];
        }
        else{
            self.dibuLab.font = [UIFont systemFontOfSize:10.0];
        }
        self.dibuLab.text = [NSString stringWithFormat:@"%@",newArr[0][@"description"]];
        
        [self.dibuLab setNumberOfLines:1];
        self.dibuLab.lineBreakMode = NSLineBreakByWordWrapping;
        [self.dibuLab setTextAlignment:NSTextAlignmentLeft];
        CGSize size = [self.dibuLab sizeThatFits:CGSizeMake(self.dibuLab.frame.size.width, MAXFLOAT)];
        self.dibuLab.frame = CGRectMake(self.dibuLab.frame.origin.x, self.dibuLab.frame.origin.y, self.dibuLab.frame.size.width, size.height);
        [dibuLabView addSubview:self.dibuLab];
        
        chuanchuquArr = [[NSMutableArray alloc]init];
    }
    return self;
}

#pragma mark - UIScrollViewDelegate
- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    //如果scrollView当前偏移位置x大于等于两倍scrollView宽度
    if (scrollView.contentOffset.x >= c_width*2) {
        //当前图片位置+1
        _curPage++;
        //如果当前图片位置超过数组边界，则设置为0
        if (_curPage == [self.imageArray count]) {
            _curPage = 0;
        }
        //刷新图片
        [self reloadData];
        //设置scrollView偏移位置
        [scrollView setContentOffset:CGPointMake(c_width, 0)];
        [lineView setFrame:CGRectMake(w * _curPage + 3, self.bounds.size.height - 2, w - 6, 2)];
    }
    
    //如果scrollView当前偏移位置x小于等于0
    else if (scrollView.contentOffset.x <= 0) {
        //当前图片位置-1
        _curPage--;
        //如果当前图片位置小于数组边界，则设置为数组最后一张图片下标
        if (_curPage == -1) {
            _curPage = [self.imageArray count]-1;
        }
        //刷新图片
        [self reloadData];
        //设置scrollView偏移位置
        [scrollView setContentOffset:CGPointMake(c_width, 0)];
        [lineView setFrame:CGRectMake(w * _curPage + 3, self.bounds.size.height - 2, w - 6, 2)];
    }
}

//停止滚动的时候回调
- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
    //设置scrollView偏移位置
    [scrollView setContentOffset:CGPointMake(c_width, 0) animated:YES];
}

- (void)setImageArray:(NSMutableArray *)imageArray
{
    _imageArray = imageArray;
    //设置分页控件的总页数
    _pageControl.numberOfPages = imageArray.count;
    //刷新图片
    [self reloadData];
    
    //开启定时器，先清空之前的定时器
    [self removeTimer];
    
    //判断图片长度是否大于1，如果一张图片不开启定时器
    if ([imageArray count] > 1) {
        [self addTimer];
    }
    else{
        self.scrollView.scrollEnabled = NO;
    }
}
//添加定时器
- (void)addTimer
{
    self.scrollView.scrollEnabled = YES;
    _timer = [NSTimer timerWithTimeInterval:5 target:self selector:@selector(timerScrollImage) userInfo:nil repeats:YES];
    [[NSRunLoop currentRunLoop] addTimer:_timer forMode:NSDefaultRunLoopMode];
    [[NSRunLoop currentRunLoop] runMode:UITrackingRunLoopMode beforeDate:[NSDate date]];
}
//移除定时器
- (void)removeTimer{
    if (_timer) {
        [_timer invalidate];
        _timer = nil;
    }
}
#pragma mark - scrollViewDelegate
//设置当用户拖拽轮播图停止定时器，当用户停止拖拽轮播图启动定时器
- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate
{
    RTLog(@"addTimer");
    [self addTimer];
}
- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView
{
    RTLog(@"removeTimer");
    [self removeTimer];
}
- (void)reloadData{
    //设置页数
    _pageControl.currentPage = _curPage;
    self.dibuLab.text = [NSString stringWithFormat:@"%@",newArr[_curPage][@"description"]];
    [chuanchuquArr removeAllObjects];
    [chuanchuquArr addObjectsFromArray:[NSArray arrayWithObjects:newArr[_curPage], nil]];
    //根据当前页取出图片
    [self getDisplayImagesWithCurpage:_curPage];
    
    //从scrollView上移除所有的subview
    NSArray *subViews = [self.scrollView subviews];
    if ([subViews count] > 0) {
        [subViews makeObjectsPerformSelector:@selector(removeFromSuperview)];
    }
    
    //创建imageView
    for (int i = 0; i < 3; i++) {
        UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectMake(c_width*i, 0, self.bounds.size.width, c_height)];
        [imageView.layer setMasksToBounds:YES];
        [imageView.layer setCornerRadius:4.0];
        imageView.userInteractionEnabled = YES;
        [self.scrollView addSubview:imageView];
        imageView.contentMode = UIViewContentModeScaleAspectFill;
        imageView.clipsToBounds = YES;
        
        imageView.tag = i+20000;
        //设置网络图片
        if ([_curImageArray[i] rangeOfString:@"http"].location != NSNotFound){
            [imageView sd_setImageWithURL:[NSURL URLWithString:_curImageArray[i]] placeholderImage:[UIImage imageNamed:@"thumbnailsdefault"]];
        }
        else{
            NSString *str = USERPHOTOHTTPSTRINGZhuBo(_curImageArray[i]);
            [imageView sd_setImageWithURL:[NSURL URLWithString:str] placeholderImage:[UIImage imageNamed:@"thumbnailsdefault"]];
        }
        //tap手势
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapImage:)];
        [imageView addGestureRecognizer:tap];
    }
}
- (void)getDisplayImagesWithCurpage:(NSInteger)page{
    //取出开头和末尾图片在图片数组里的下标
    NSInteger front = page - 1;
    NSInteger last = page + 1;
    
    //如果当前图片下标是0，则开头图片设置为图片数组的最后一个元素
    if (page == 0) {
        front = [self.imageArray count]-1;
    }
    
    //如果当前图片下标是图片数组最后一个元素，则设置末尾图片为图片数组的第一个元素
    if (page == [self.imageArray count]-1) {
        last = 0;
    }
    
    //如果当前图片数组不为空，则移除所有元素
    if ([_curImageArray count] > 0) {
        [_curImageArray removeAllObjects];
    }
    
    //当前图片数组添加图片
    [_curImageArray addObject:self.imageArray[front]];
    [_curImageArray addObject:self.imageArray[page]];
    [_curImageArray addObject:self.imageArray[last]];
}
- (void)timerScrollImage
{
    //刷新图片
    [self reloadData];
    
    //设置scrollView偏移位置
    [self.scrollView setContentOffset:CGPointMake(c_width*2, 0) animated:YES];
}
//点击轮播图片
- (void)tapImage:(UITapGestureRecognizer *)tap
{
    if ([newArr[_curPage][@"cate"] intValue] == 1) {//当前为新闻，跳转新闻播放器页面
        id object = [self nextResponder];
        
        while (![object isKindOfClass:[UIViewController class]] &&
               object != nil) {
            object = [object nextResponder];
        }
        HomePageViewController *homePageVC = (HomePageViewController *)object;
        UINavigationController *nav = homePageVC.navigationController;
        //设置播放器播放内容类型
        [ZRT_PlayerManager manager].playType = ZRTPlayTypeNews;
        //设置播放界面打赏view的状态
        //遍历新闻数据列表，获取真正的index
        int index = 0;
        for (int i = 0 ; i<newsArr.count; i++) {
            if ([newArr[_curPage][@"post_list"][@"id"] isEqualToString:newsArr[i][@"id"]]){
                index = i;
                break;
            }
        }
        //设置打赏控件状态
        [NewPlayVC shareInstance].rewardType = RewardViewTypeNone;
        if ([[CommonCode readFromUserD:@"dangqianbofangxinwenID"] isEqualToString:newsArr[index][@"id"]])
        {
            //设置播放器播放数组
            [ZRT_PlayerManager manager].songList = newsArr;
//            [[NewPlayVC shareInstance] reloadInterface];
            [nav.navigationBar setHidden:YES];
            [nav pushViewController:[NewPlayVC shareInstance] animated:YES];
        }
        else{
            //设置播放器播放数组
            [ZRT_PlayerManager manager].songList = newsArr;
            //设置新闻ID
            [NewPlayVC shareInstance].post_id = newsArr[index][@"id"];
            //保存当前播放新闻Index
            ExcurrentNumber = index;
            //播放频道
            [ZRT_PlayerManager manager].channelType = ChannelTypeHomeChannelClassify;
            //调用播放对应Index方法
            [[NewPlayVC shareInstance] playFromIndex:ExcurrentNumber];
            //跳转播放界面
            [nav.navigationBar setHidden:YES];
            [nav pushViewController:[NewPlayVC shareInstance] animated:YES];
        }
    }else if ([newArr[_curPage][@"cate"] intValue] == 2) {//当前为URL，打开手机系统浏览器
        NSString *URLString = newArr[_curPage][@"url"];
        //调用系统浏览器
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:URLString]];
    }else if ([newArr[_curPage][@"cate"] intValue] == 3) {//当前为课堂，跳转课堂界面
        
        id object = [self nextResponder];
        while (![object isKindOfClass:[UIViewController class]] &&
               object != nil) {
            object = [object nextResponder];
        }
        HomePageViewController *homePageVC = (HomePageViewController *)object;
        UINavigationController *nav = homePageVC.navigationController;
        if ([[CommonCode readFromUserD:@"isLogin"]boolValue] == YES) {
            NSDictionary *userInfoDict = [CommonCode readFromUserD:@"dangqianUserInfo"];
            if ([newArr[_curPage][@"is_free"] isEqualToString:@"1"]||[userInfoDict[results][member_type] intValue] == 2) {
                zhuboXiangQingVCNewController *faxianzhuboVC = [[zhuboXiangQingVCNewController alloc]init];
                faxianzhuboVC.jiemuDescription = newArr[_curPage][@"des"];
                faxianzhuboVC.jiemuFan_num = newArr[_curPage][@"fan_num"];
                faxianzhuboVC.jiemuID = newArr[_curPage][@"url"];
                faxianzhuboVC.jiemuImages = newArr[_curPage][@"images"];
                faxianzhuboVC.jiemuIs_fan = newArr[_curPage][@"is_fan"];
                faxianzhuboVC.jiemuMessage_num = newArr[_curPage][@"message_num"];
                faxianzhuboVC.jiemuName = newArr[_curPage][@"name"];
                faxianzhuboVC.isfaxian = YES;
                faxianzhuboVC.isClass = YES;
                [nav pushViewController:faxianzhuboVC animated:YES];
            }else{
                ClassViewController *classVC = [ClassViewController shareInstance];
                classVC.jiemuDescription = newArr[_curPage][@"description"];
                classVC.jiemuFan_num = newArr[_curPage][@"fan_num"];
                classVC.jiemuID = newArr[_curPage][@"url"];
                classVC.jiemuImages = newArr[_curPage][@"images"];
                classVC.jiemuIs_fan = newArr[_curPage][@"is_fan"];
                classVC.jiemuMessage_num = newArr[_curPage][@"message_num"];
                classVC.jiemuName = newArr[_curPage][@"name"];
                classVC.act_id = newArr[_curPage][@"url"];
                [nav.navigationBar setHidden:YES];
                [nav pushViewController:classVC animated:YES];
            }
        }else{
            ClassViewController *classVC = [ClassViewController shareInstance];
            classVC.jiemuDescription = newArr[_curPage][@"description"];
            classVC.jiemuFan_num = newArr[_curPage][@"fan_num"];
            classVC.jiemuID = newArr[_curPage][@"url"];
            classVC.jiemuImages = newArr[_curPage][@"images"];
            classVC.jiemuIs_fan = newArr[_curPage][@"is_fan"];
            classVC.jiemuMessage_num = newArr[_curPage][@"message_num"];
            classVC.jiemuName = newArr[_curPage][@"name"];
            classVC.act_id = newArr[_curPage][@"url"];
            [nav.navigationBar setHidden:YES];
            [nav pushViewController:classVC animated:YES];
        }
    }
}
- (void)dealloc
{
    //代理指向nil，关闭定时器
    self.scrollView.delegate = nil;
    [_timer invalidate];
}
@end
