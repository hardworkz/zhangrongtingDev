//
//  MyImageBrowser.m
//  WeChat
//
//  Created by Mac on 16/2/6.
//  Copyright © 2016年 Mac. All rights reserved.
//

#import "YJImageBrowserView.h"

static const CGFloat kanimateTime = 0.25f;
@interface YJImageBrowserView ()<UIScrollViewDelegate>
@property(nonatomic,assign)CGRect originFrame;
@property(nonatomic,weak)UIImageView *nowImageView;
@property(nonatomic,weak)UIScrollView *scrollView;
@property(nonatomic,weak)UIButton *saveBtn;
@end

static UIWindow  *win;
@implementation YJImageBrowserView
+ (void)showWithImageView:(UIImageView *)imageView
{
    if (imageView.image == nil) return;
    win = [[UIWindow alloc]initWithFrame:[UIScreen mainScreen].bounds];
    win.windowLevel = UIWindowLevelAlert;
    win.hidden = NO;
    win.backgroundColor = [UIColor clearColor];
    YJImageBrowserView *containView = [[self alloc]initWithFrame:win.bounds];
    containView.backgroundColor = [UIColor clearColor];
    [win addSubview:containView];
    [containView createScaleImageView:imageView];
}

- (void)createScaleImageView:(UIImageView *)imageView
{
    
    UIButton *saveBtn = [[UIButton alloc]init];
    saveBtn.backgroundColor = [[UIColor blackColor]colorWithAlphaComponent:0.5];
    [saveBtn setTitle:@"保存" forState:UIControlStateNormal];
    [saveBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [saveBtn addTarget:self action:@selector(saveImageBtnClick) forControlEvents:UIControlEventTouchUpInside];
    saveBtn.width = 70;
    saveBtn.height = 40;
    saveBtn.x = win.width - saveBtn.width - 10;
    saveBtn.y = win.height - saveBtn.height - 30;
    _saveBtn = saveBtn;
    
    CGFloat w = win.width;
    CGFloat h = (imageView.image.size.height/imageView.image.size.width) * win.width;
    self.scrollView.contentSize = CGSizeMake(w, h);

    UIImageView *nowImageView = [[UIImageView alloc]initWithImage:imageView.image];
    nowImageView.contentMode = UIViewContentModeScaleAspectFill;
    nowImageView.clipsToBounds = YES;
    nowImageView.userInteractionEnabled = YES;
    _nowImageView = nowImageView;

    self.originFrame = [imageView convertRect:imageView.bounds toView:win];
    nowImageView.frame = self.originFrame;
    [self.scrollView addSubview:nowImageView];
    [UIView animateWithDuration:kanimateTime animations:^{
        
        nowImageView.frame = CGRectMake(0, 0, w, h);
        nowImageView.height = h;
        nowImageView.width = w;
        if (h > [UIScreen mainScreen].bounds.size.height)
        {
            nowImageView.x = 0;
            nowImageView.y = 0;
            
        }else
          nowImageView.center = win.center;
        [win addSubview:saveBtn];
        self.backgroundColor = [UIColor blackColor];
    }];
}

- (UIScrollView *)scrollView
{
    if (_scrollView == nil)
    {
        UIScrollView *scrollView = [[UIScrollView alloc]initWithFrame:win.bounds];
        scrollView.userInteractionEnabled = YES;
        scrollView.backgroundColor = [UIColor clearColor];
        scrollView.delegate = self;
        scrollView.minimumZoomScale = 1;
        scrollView.maximumZoomScale = 2.5;
        scrollView.multipleTouchEnabled = YES;
        _scrollView = scrollView;
        //单击手势
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(hidenImageView:)];
        [_scrollView addGestureRecognizer:tap];
        UITapGestureRecognizer *doubleTap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(doubleTapAction:)];
        //双击，默认一个手指
        doubleTap.numberOfTapsRequired = 2;
        [_scrollView addGestureRecognizer:doubleTap];
        //单击手势与双击手势共存,优先处理双击
        [tap requireGestureRecognizerToFail:doubleTap];
        [self addSubview:scrollView];
    }
    return _scrollView;
}

- (void)doubleTapAction:(UITapGestureRecognizer *)doubleTap
{
    UIScrollView *scrollView = (UIScrollView*)doubleTap.view;
    //获取当前放大倍数
    CGFloat currentZoomScale = scrollView.zoomScale;
    //若没放大，则进行放大，已放大，则进行还原
    CGFloat newScale = currentZoomScale == 1.0?currentZoomScale * 2:1.0;
    //计算需要缩放的区域
    CGRect zoomRect = [self zoomRectForScale:newScale  inView:scrollView withCenter:[doubleTap locationInView:doubleTap.view]];
//    把从scrollView里截取的矩形区域缩放到整个scrollView当前可视的frame里面。所以如果截取的区域大于scrollView的frame时，图片缩小，如果截取区域小于frame，会看到图片放大。一般情况下rect需要自己计算出来。
    [scrollView zoomToRect:zoomRect animated:YES];
}

- (CGRect)zoomRectForScale:(float)scale inView:(UIScrollView*)scrollView withCenter:(CGPoint)center {
    
    CGRect zoomRect;
    zoomRect.size.height = scrollView.frame.size.height / scale;
    zoomRect.size.width  = scrollView.frame.size.width  / scale;
    zoomRect.origin.x    = center.x - (zoomRect.size.width  / 2.0);
    zoomRect.origin.y    = center.y - (zoomRect.size.height / 2.0);
    return zoomRect;
}

- (UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView
{
    return _nowImageView;
}

-(void)scrollViewDidZoom:(UIScrollView *)scrollView
{
    //若放大的imageVIew没超过屏幕，则让imageView居中于正屏幕，若放大的imageView有超出屏幕部分，则让imageView的中心与contentSize的中心一致，这样才能使得图片有一种始终处于中间的感觉
    CGFloat offsetX = (scrollView.bounds.size.width > scrollView.contentSize.width)?
    (scrollView.bounds.size.width - scrollView.contentSize.width) * 0.5 : 0.0;
    CGFloat offsetY = (scrollView.bounds.size.height > scrollView.contentSize.height)?
    (scrollView.bounds.size.height - scrollView.contentSize.height) * 0.5 : 0.0;
    _nowImageView.center = CGPointMake(scrollView.contentSize.width * 0.5 + offsetX,
    scrollView.contentSize.height * 0.5 + offsetY);
}

-(void)hidenImageView:(UITapGestureRecognizer *)recognizer
{
    [self.saveBtn removeFromSuperview];
    [UIView animateWithDuration:kanimateTime animations:^{
        //防止放大情况下，frame位置不对
        self.scrollView.contentOffset = CGPointMake(0, 0);
        _nowImageView.frame = _originFrame;
        self.backgroundColor = [UIColor clearColor];
    } completion:^(BOOL finished) {
        [_nowImageView removeFromSuperview];
        [recognizer.view removeFromSuperview];
        [self removeFromSuperview];
        win = nil;
    }];
}

- (void)saveImageBtnClick
{
    if (self.nowImageView.image == nil)
    {
        [SVProgressHUD showErrorWithStatus:@"当前没有图片！"];
        return;
    }
    
    UIImageWriteToSavedPhotosAlbum(self.nowImageView.image, self, @selector(image:didFinishSavingWithError:contextInfo:), nil);
}

- (void)image:(UIImage *)image didFinishSavingWithError:(NSError *)error contextInfo:(void *)contextInfo
{
    if (error)
    {
//        [SVProgressHUD showErrorWithStatus:@"保存失败"];
        XWAlerLoginView *xw = [[XWAlerLoginView alloc]initWithTitle:@"保存失败"];
        [xw show];
    }else
    {
//        [SVProgressHUD showSuccessWithStatus:@"保存成功"];
        XWAlerLoginView *xw = [[XWAlerLoginView alloc]initWithTitle:@"保存成功"];
        [xw show];
    }
}

- (void)longPressAction:(UILongPressGestureRecognizer *)longGes
{
//    MyLogFunc
//    UIAlertController *alertC = [UIAlertController alertControllerWithTitle:nil message:nil preferredStyle:UIAlertControllerStyleActionSheet];
//    UIAlertAction *actionSave = [UIAlertAction actionWithTitle:@"" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
//        
//    }];
//    UIAlertAction *cancel = [UIAlertAction actionWithTitle:@"" style:UIAlertActionStyleCancel handler:nil];
//    [alertC addAction:actionSave];
//    [alertC addAction:cancel];
//    [[UIApplication sharedApplication].keyWindow.rootViewController presentViewController:alertC animated:YES completion:nil];
}

@end
