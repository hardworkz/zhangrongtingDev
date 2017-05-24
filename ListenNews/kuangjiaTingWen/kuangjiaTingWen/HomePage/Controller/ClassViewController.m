//
//  ClassViewController.m
//  kuangjiaTingWen
//
//  Created by Zhimi on 17/4/13.
//  Copyright © 2017年 zhimi. All rights reserved.
//

#import "ClassViewController.h"
#import "UIView+tap.h"
#import "gerenzhuyeVC.h"
#import "UIActionSheet+MKBlockAdditions.h"
#import "bofangVC.h"
#import "YJImageBrowserView.h"
#import "LoginVC.h"
#import "LoginNavC.h"
#import "PayOnlineViewController.h"
#import "CommentViewController.h"



@interface ClassViewController ()<UITableViewDelegate,UITableViewDataSource,UITextViewDelegate,TTTAttributedLabelDelegate>{
    UIView *xiangqingView;
    UITextView *zhengwenTextView;
    UILabel *PingLundianzanNumLab;
}

@property (nonatomic, strong) UITableView *helpTableView;
@property (nonatomic, strong) NSMutableArray *buttons;
@property (nonatomic, strong) NSMutableArray *dataSourceArr;
@property (nonatomic, strong) NSMutableArray *pinglunArr;
@property (nonatomic, strong) NSMutableDictionary *auditionResult;
@property (nonatomic, strong) UILabel *label;
@property (strong, nonatomic) UIView *topView;
@property (strong, nonatomic) UIButton *leftBtn;
@property (strong, nonatomic) UIButton *collectBtn;
@property (strong, nonatomic) UIButton *auditionnBtn;
@property (strong, nonatomic) UIButton *purchaseBtn;
@property (strong, nonatomic) UILabel *priceLabel;
@property (strong, nonatomic) UILabel *spriceLabel;
@property (strong, nonatomic) NSMutableArray *ImageSizeArr;
@property (weak, nonatomic) UIScrollView *scrollView;
@property (weak, nonatomic) UIImageView *lastImageView;
@property (assign, nonatomic) CGRect originalFrame;
@property (strong, nonatomic) AVPlayer *voicePlayer;
@property (strong, nonatomic) AVAudioSession *session;
@property (assign, nonatomic) BOOL isPlaying;
@property (assign, nonatomic) NSInteger playingIndex;

@end

@implementation ClassViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setUpData];
    [self setUpView];
}

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    self.hidesBottomBarWhenPushed = YES;
    [self.navigationController setNavigationBarHidden:YES animated:YES];
}

- (void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    [self.navigationController setNavigationBarHidden:NO animated:YES];
//    [Explayer pause];
}

- (void)setUpData{
    _pinglunArr = [NSMutableArray new];
    _dataSourceArr = [NSMutableArray new];
    _auditionResult = [NSMutableDictionary new];
    _ImageSizeArr = [NSMutableArray new];
    [self loadData];
    
    _isPlaying = NO;
    _playingIndex = -1;
    ExisRigester = NO;
    //AudioSession负责应用音频的设置，比如支不支持后台，打断等等
    NSError *error;
    //设置音频会话
    self.session = [AVAudioSession sharedInstance];
    //AVAudioSessionCategoryPlayback一般用于支持后台播放
    [self.session setCategory:AVAudioSessionCategoryPlayback error:&error];
    //激活会话
    [self.session setActive:YES error:&error];
    //添加观察者，用来监视播放器的状态变化
//    [Explayer addObserver:self forKeyPath:@"statu" options:NSKeyValueObservingOptionNew context:nil];
    //播放完毕后发出通知
//    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(voicePlayEnd:) name:AVPlayerItemDidPlayToEndTimeNotification object:Explayer.currentItem];
     
}

- (void)setUpView{
    
    [self.view setBackgroundColor:[UIColor whiteColor]];
    [self.view addSubview:self.helpTableView];
    _topView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, IPHONE_W, 64)];
    _topView.backgroundColor = [UIColor clearColor];
    _topView.hidden = NO;
    [self.view addSubview:_topView];
    
    _leftBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    _leftBtn.frame = CGRectMake(10, 25, 35, 35);
    [_leftBtn setImageEdgeInsets:UIEdgeInsetsMake(5, 0, 5, 10)];
    [_leftBtn setImage:[UIImage imageNamed:@"title_ic_white"] forState:UIControlStateNormal];
    _leftBtn.accessibilityLabel = @"返回";
    [_leftBtn addTarget:self action:@selector(back) forControlEvents:UIControlEventTouchUpInside];
    [_topView addSubview:_leftBtn];
    
    UISwipeGestureRecognizer *rightSwipe = [[UISwipeGestureRecognizer alloc]initWithTarget:self action:@selector(back)];
    [rightSwipe setDirection:UISwipeGestureRecognizerDirectionRight];
    [self.helpTableView addGestureRecognizer:rightSwipe];
    UIView *seperatorLine = [[UIView alloc]initWithFrame:CGRectMake(0, CGRectGetMaxY(self.helpTableView.frame), SCREEN_WIDTH, 1.0)];
    [seperatorLine setBackgroundColor:gThickLineColor];
    [self.view addSubview:seperatorLine];
    [self.view addSubview:self.collectBtn];
    UIView *verticalLine = [[UIView alloc]initWithFrame:CGRectMake(SCREEN_WIDTH/4, CGRectGetMaxY(self.helpTableView.frame) + 8, 1.0, 33)];
    [verticalLine setBackgroundColor:gThickLineColor];
    [self.view addSubview:verticalLine];
    [self.view addSubview:self.auditionnBtn];
    [self.purchaseBtn addSubview:self.priceLabel];
    [self.purchaseBtn addSubview:self.spriceLabel];
    [self.view addSubview:self.purchaseBtn];
    
}

#pragma mark - Unitilities
- (void)loadData{
    NSString *accessToken;
    if (ExdangqianUser.length == 0 || ExdangqianUser == nil){
        accessToken = nil;
    }
    else{
        accessToken = [DSE encryptUseDES:ExdangqianUser];
    }
    DefineWeakSelf;
    [NetWorkTool getAuditionListWithaccessToken:accessToken act_id:self.act_id sccess:^(NSDictionary *responseObject) {
        if ([responseObject[@"status"] integerValue] == 1) {
            ExisRigester = NO;
            self.auditionResult = [responseObject[@"results"] mutableCopy];
            self.pinglunArr = [responseObject[@"results"][@"comments"] mutableCopy];
            [self handleResultData];
            [self.helpTableView reloadData];
            
            NSString *textStr = [NSString stringWithFormat:@"￥%@ ",responseObject[@"results"][@"sprice"]];
            //中划线
            NSDictionary *attribtDic = @{NSStrikethroughStyleAttributeName: [NSNumber numberWithInteger:NSUnderlineStyleSingle]};
            NSMutableAttributedString *attribtStr = [[NSMutableAttributedString alloc]initWithString:textStr attributes:attribtDic];
            // 赋值
            self.spriceLabel.attributedText = attribtStr;
            self.priceLabel.text = [NSString stringWithFormat:@"￥%@",responseObject[@"results"][@"price"]];
        }
    } failure:^(NSError *error) {
        //
        [weakSelf loadData];
    }];
}

- (void)back {
//    [Explayer pause];
    [self.navigationController popViewControllerAnimated:YES];
}

/**
 *  计算文本高度
 *
 *  @param string   要计算的文本
 *  @param width    单行文本的宽度
 *  @param fontSize 文本的字体size
 *
 *  @return 返回文本高度
 */
- (CGFloat)computeTextHeightWithString:(NSString *)string andWidth:(CGFloat)width andFontSize:(UIFont *)fontSize{
    
    CGRect rect  = [string boundingRectWithSize:CGSizeMake(width, 10000)
                                        options: NSStringDrawingUsesFontLeading |NSStringDrawingUsesLineFragmentOrigin
                                     attributes:@{NSFontAttributeName:fontSize}
                                        context:nil];
    return ceil(rect.size.height);
}

- (void)handleResultData{
    //缓存图片的高度
    NSMutableArray *urls = [NSMutableArray new];
    if (![self.auditionResult[@"images"] isEqualToString:@""]){
        NSArray *array = [self.auditionResult[@"images"] componentsSeparatedByString:@","];
        for (int i = 0 ; i < array.count ; i ++ ) {
            [urls addObject:[NSURL URLWithString:array[i]]];
        }
    }
    NSArray *photos = urls;
    _ImageSizeArr = [NSMutableArray new];
    for (int i = 0; i < [photos count]; i ++) {
        NSString *pat = [NSString stringWithFormat:@"%@", photos[i]];
        NSURL *url = URL(pat);
        [[SDWebImageDownloader sharedDownloader]downloadImageWithURL:url options:SDWebImageDownloaderUseNSURLCache progress:^(NSInteger receivedSize, NSInteger expectedSize) {
        } completed:^(UIImage *image, NSData *data, NSError *error, BOOL finished) {
            //这边就能拿到图片了
            NSDictionary *dic = @{@"width":@(image.size.width),@"height":@(image.size.height)};
            [_ImageSizeArr addObject:dic];
            if (i == ([photos count] -1)) {
//                [self.helpTableView reloadData];
                //                [self performSelector:@selector(reloadData) withObject:nil afterDelay:1.0];
                [self setTableHeadView];
            }
        }];
    }
}

- (void)setTableHeadView{
    xiangqingView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, IPHONE_W, IPHONE_H)];
    xiangqingView.backgroundColor = [UIColor whiteColor];
    //新闻图片
    UIImageView *zhengwenImg = [[UIImageView alloc]initWithFrame:CGRectMake(0, -20, IPHONE_W, 209.0 / 667 * SCREEN_HEIGHT)];
    [zhengwenImg setUserInteractionEnabled:YES];
    
    UIBezierPath *maskPath = [UIBezierPath bezierPathWithRoundedRect:zhengwenImg.bounds byRoundingCorners:UIRectCornerBottomRight cornerRadii:CGSizeMake(160.0 / 667 * SCREEN_HEIGHT, 160.0 / 667 * SCREEN_HEIGHT)];
    CAShapeLayer *maskLayer = [[CAShapeLayer alloc] init];
    maskLayer.frame = zhengwenImg.bounds;
    maskLayer.path = maskPath.CGPath;
    zhengwenImg.layer.mask = maskLayer;
    
    //生成图片
    if ([NEWSSEMTPHOTOURL(self.auditionResult[@"smeta"]) rangeOfString:@"userDownLoadPathImage"].location != NSNotFound) {
        [zhengwenImg sd_setImageWithURL:[NSURL fileURLWithPath:NEWSSEMTPHOTOURL(self.auditionResult[@"smeta"])] placeholderImage:[UIImage imageNamed:@"thumbnailsdefault"]];
    }
    else if ([NEWSSEMTPHOTOURL(self.auditionResult[@"smeta"])  rangeOfString:@"http"].location != NSNotFound)
    {
        [zhengwenImg sd_setImageWithURL:[NSURL URLWithString:NEWSSEMTPHOTOURL(self.auditionResult[@"smeta"])] placeholderImage:[UIImage imageNamed:@"thumbnailsdefault"]];
    }
    else{
        NSString *str = USERPHOTOHTTPSTRINGZhuBo(NEWSSEMTPHOTOURL(self.auditionResult[@"smeta"]));
        [zhengwenImg sd_setImageWithURL:[NSURL URLWithString:str] placeholderImage:[UIImage imageNamed:@"thumbnailsdefault"]];
    }
    
    //添加单击手势
    UITapGestureRecognizer *tapZhengwenImg = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(showZoomImageView:)];
    [zhengwenImg addGestureRecognizer:tapZhengwenImg];
    zhengwenImg.contentMode = UIViewContentModeScaleAspectFill;
    zhengwenImg.clipsToBounds = YES;
    [xiangqingView addSubview:zhengwenImg];
    
    //标题
    UILabel *titleLab = [[UILabel alloc]initWithFrame:CGRectMake(20.0 / 375 * IPHONE_W,CGRectGetMaxY(zhengwenImg.frame) + 20.0 / 667 * SCREEN_HEIGHT, IPHONE_W - 40.0 / 375 * IPHONE_W, 40.0 / 667 * IPHONE_H)];
    titleLab.text = self.auditionResult[@"title"];
    titleLab.textAlignment = NSTextAlignmentCenter;
    titleLab.textColor = nTextColorMain;
    titleLab.font = [UIFont fontWithName:@"Semibold" size:19];
    CGFloat titleHight = [self computeTextHeightWithString:self.auditionResult[@"title"] andWidth:(SCREEN_WIDTH-20) andFontSize:gFontMain14];
    [titleLab setFrame:CGRectMake(20.0 / 375 * IPHONE_W, CGRectGetMaxY(zhengwenImg.frame) + 20.0 / 667 * SCREEN_HEIGHT, IPHONE_W - 40.0 / 375 * IPHONE_W, (titleHight + 20) / 667 * IPHONE_H)];
    [titleLab setNumberOfLines:0];
    titleLab.lineBreakMode = NSLineBreakByWordWrapping;
    [xiangqingView addSubview:titleLab];
    
    //分割线
    UIView *seperatorLine = [[UIView alloc]initWithFrame:CGRectMake(20.0 / 375 * SCREEN_WIDTH, CGRectGetMaxY(titleLab.frame) +  12.0 / 667 * SCREEN_HEIGHT, SCREEN_WIDTH - 40.0 / 375 * SCREEN_WIDTH, 1.0)];
    [seperatorLine setBackgroundColor:gThickLineColor];
    [xiangqingView addSubview:seperatorLine];
    dispatch_async(dispatch_get_main_queue(), ^{
        //新闻内容
        zhengwenTextView = [[UITextView alloc]initWithFrame:CGRectMake(20.0 / 375 * IPHONE_W, CGRectGetMaxY(seperatorLine.frame) + 24.0 / 667 * IPHONE_H, IPHONE_W - 40.0 / 375 * IPHONE_W, 50.0 / 667 * IPHONE_H)];
        zhengwenTextView.scrollEnabled = NO;
        zhengwenTextView.editable = NO;
        zhengwenTextView.scrollsToTop = NO;
        zhengwenTextView.delegate = self;
        NSString *str1 = [self.auditionResult[@"excerpt"] stringByReplacingOccurrencesOfString:@"\r" withString:@""];
        zhengwenTextView.text = str1;
        zhengwenTextView.font = gFontMain14;
        NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle alloc]init];
        [paragraphStyle setLineSpacing:8.0];
        [paragraphStyle setAlignment:NSTextAlignmentLeft];
        [paragraphStyle setFirstLineHeadIndent:5.0];
        [paragraphStyle setLineBreakMode:NSLineBreakByCharWrapping];
        [zhengwenTextView sizeToFit];
        if (zhengwenTextView.text.length != 0){
            NSMutableAttributedString *attributedString =  [[NSMutableAttributedString alloc] initWithString:zhengwenTextView.text attributes:@{NSForegroundColorAttributeName : gTextDownload,NSFontAttributeName : gFontMain14}];
            [attributedString addAttribute:NSParagraphStyleAttributeName value:paragraphStyle range:NSMakeRange(0, zhengwenTextView.text.length)];
            zhengwenTextView.attributedText = attributedString;
        }
        CGSize size2 = [zhengwenTextView sizeThatFits:CGSizeMake(zhengwenTextView.frame.size.width, MAXFLOAT)];
        zhengwenTextView.frame = CGRectMake(zhengwenTextView.frame.origin.x, zhengwenTextView.frame.origin.y, zhengwenTextView.frame.size.width, size2.height);
        [xiangqingView addSubview:zhengwenTextView];
        
        //images
        CGFloat imageContentHeight = 0;
        NSMutableArray *urls = [NSMutableArray new];
        if (![self.auditionResult[@"images"] isEqualToString:@""]){
            NSArray *array = [self.auditionResult[@"images"] componentsSeparatedByString:@","];
            for (int i = 0 ; i < array.count ; i ++ ) {
                [urls addObject:[NSURL URLWithString:array[i]]];
            }
        }
        NSArray *photos = urls;
        CGFloat IMAGEWIDTH = zhengwenTextView.frame.size.width;
        if ([_ImageSizeArr count]) {
            if ([photos count]) {
                for (int i = 0; i < [_ImageSizeArr count]; i ++) {
                    CGFloat imageHeight = ([_ImageSizeArr[i][@"height"] floatValue] * IMAGEWIDTH ) / ([_ImageSizeArr[i][@"width"] floatValue]);
                    UIImageView *image = [UIImageView new];
                    [image setFrame:CGRectMake(zhengwenTextView.frame.origin.x, CGRectGetMaxY(zhengwenTextView.frame) + (imageContentHeight + 5) + 5.0 *667.0 / SCREEN_HEIGHT , IMAGEWIDTH, imageHeight)];
                    imageContentHeight += imageHeight;
                    image.contentMode = UIViewContentModeScaleAspectFit;
                    image.clipsToBounds = YES;
                    [image sd_setImageWithURL:photos[i] placeholderImage:[UIImage imageNamed:@"thumbnailsdefault"]];
                    [image addTapGesWithTarget:self action:@selector(showZoomImageView:)];
                    [xiangqingView addSubview:image];
                }
            }
        }
        else{
            if ([photos count]) {
                CGFloat imageHeight = 200.0;
                imageContentHeight = imageHeight * [photos count];
                for (int i = 0; i < [photos count]; i ++) {
                    UIImageView *image = [UIImageView new];
                    [image setFrame:CGRectMake(zhengwenTextView.frame.origin.x, CGRectGetMaxY(zhengwenTextView.frame) +  i * (imageHeight + 5) + 5.0 *667.0 / SCREEN_HEIGHT , IMAGEWIDTH, imageHeight)];
                    image.contentMode = UIViewContentModeScaleAspectFit;
                    image.clipsToBounds = YES;
                    [image sd_setImageWithURL:photos[i] placeholderImage:[UIImage imageNamed:@"thumbnailsdefault"]];
                    [xiangqingView addSubview:image];
                }
            }
        }
        
        //免费试听
        UILabel *auditionLabel = [[UILabel alloc]initWithFrame:CGRectMake(zhengwenTextView.frame.origin.x,CGRectGetMaxY(zhengwenTextView.frame) + imageContentHeight + 15.0 / 667 * IPHONE_H,zhengwenTextView.frame.size.width, 30)];
        [auditionLabel setText:@"免费试听"];
        [auditionLabel setTextColor:nTextColorMain];
        [auditionLabel setTextAlignment:NSTextAlignmentLeft];
        [xiangqingView addSubview:auditionLabel];
        UIView *topLine = [[UIView alloc]initWithFrame:CGRectMake(0, CGRectGetMaxY(auditionLabel.frame), IPHONE_W, 1)];
        topLine.backgroundColor = [UIColor lightGrayColor];
        topLine.alpha = 0.5f;
        [xiangqingView addSubview:topLine];
        
        if ([self.buttons count]) {
            [self.buttons removeAllObjects];
        }
        CGFloat ShitingContentHeight = 0;
        if ([self.auditionResult[@"shiting"] count]) {
            for (int i= 0 ; i < [self.auditionResult[@"shiting"] count]; i++) {
                //试听标题
                UILabel *titleLab = [[UILabel alloc]initWithFrame:CGRectMake(20.0 / 375 * IPHONE_W,CGRectGetMaxY(topLine.frame) + ShitingContentHeight + 20.0 / 667 * SCREEN_HEIGHT, IPHONE_W - 70.0 / 375 * IPHONE_W, 40.0 / 667 * IPHONE_H)];
                titleLab.text = self.auditionResult[@"shiting"][i][@"s_title"];
                titleLab.textAlignment = NSTextAlignmentLeft;
                titleLab.textColor = nTextColorMain;
                //  titleLab.font = [UIFont fontWithName:@"Semibold" size:14];
                titleLab.font = gFontMain14;
                CGFloat titleHight = [self computeTextHeightWithString:self.self.auditionResult[@"shiting"][i][@"s_title"] andWidth:(SCREEN_WIDTH- 60.0 / 375 * IPHONE_W) andFontSize:gFontMain14];
                [titleLab setFrame:CGRectMake(20.0 / 375 * IPHONE_W, CGRectGetMaxY(topLine.frame) + ShitingContentHeight + 10.0 / 667 * SCREEN_HEIGHT, IPHONE_W - 70.0 / 375 * IPHONE_W, (titleHight + 20) / 667 * IPHONE_H)];
                [titleLab setNumberOfLines:0];
                ShitingContentHeight += titleHight + 20.0 / 667 * SCREEN_HEIGHT;
                titleLab.lineBreakMode = NSLineBreakByWordWrapping;
                [xiangqingView addSubview:titleLab];
                
                UIButton *playTestMp = [UIButton buttonWithType:UIButtonTypeCustom];
                [playTestMp setFrame:CGRectMake(SCREEN_WIDTH - 50.0 / 375 * SCREEN_WIDTH, titleLab.frame.origin.y, 40, 40)];
                [playTestMp setImage:[UIImage imageNamed:@"classplay"] forState:UIControlStateNormal];
                [playTestMp setImage:[UIImage imageNamed:@"classpause"] forState:UIControlStateSelected];
                [playTestMp setTag:(100+ i)];
                [playTestMp setSelected:NO];
                [self.buttons addObject:playTestMp];
                [playTestMp addTarget:self action:@selector(playTestMp:) forControlEvents:UIControlEventTouchUpInside];
                [xiangqingView addSubview:playTestMp];
            }
        }
        //用户评价
        UILabel *CommentLabel = [[UILabel alloc]initWithFrame:CGRectMake(zhengwenTextView.frame.origin.x, CGRectGetMaxY(topLine.frame) + ShitingContentHeight + 20.0 / 667 * SCREEN_HEIGHT,zhengwenTextView.frame.size.width, 30)];
        [CommentLabel setText:@"用户评价"];
        [CommentLabel setTextColor:nTextColorMain];
        [CommentLabel setTextAlignment:NSTextAlignmentLeft];
        [xiangqingView addSubview:CommentLabel];
        UIView *downLine = [[UIView alloc]initWithFrame:CGRectMake(0, CGRectGetMaxY(CommentLabel.frame), IPHONE_W, 1)];
        downLine.backgroundColor = [UIColor lightGrayColor];
        downLine.alpha = 0.5f;
        [xiangqingView addSubview:downLine];
        
        UIView *payTopLine = [[UIView alloc]initWithFrame:CGRectMake(0, CGRectGetMaxY(downLine.frame) , IPHONE_W, 5)];
        payTopLine.backgroundColor = [UIColor colorWithRed:0.95 green:0.96 blue:0.98 alpha:1.00];
        payTopLine.alpha = 0.5f;
        [xiangqingView addSubview:payTopLine];
        xiangqingView.frame = CGRectMake(xiangqingView.frame.origin.x, xiangqingView.frame.origin.y, xiangqingView.frame.size.width, CGRectGetMaxY(payTopLine.frame));
        self.helpTableView.tableHeaderView = xiangqingView;
        [self.helpTableView reloadData];
    });
}

- (void)reloadData{
    [self.helpTableView reloadData];
}

- (void)showZoomImageView:(UITapGestureRecognizer *)tap{
    if (![(UIImageView *)tap.view image]) {
        return;
    }
    [YJImageBrowserView showWithImageView:(UIImageView *)tap.view];
//    UIScrollView *bgView = [[UIScrollView alloc] init];
//    bgView.frame = [UIScreen mainScreen].bounds;
//    bgView.backgroundColor = [UIColor blackColor];
//    UITapGestureRecognizer *tapBg = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapBgView:)];
//    [bgView addGestureRecognizer:tapBg];
//    UIImageView *picView = (UIImageView *)tap.view;
//    UIImageView *imageView = [[UIImageView alloc] init];
//    imageView.image = picView.image;
//    imageView.frame = [bgView convertRect:picView.frame fromView:self.view];
//    imageView.userInteractionEnabled = YES;
//    UILongPressGestureRecognizer *longtapImage = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(longtapImage:)];
//    [imageView addGestureRecognizer:longtapImage];
//    [bgView addSubview:imageView];
//    [[[UIApplication sharedApplication] keyWindow] addSubview:bgView];
//    self.lastImageView = imageView;
//    self.originalFrame = imageView.frame;
//    self.scrollView = bgView;
//    self.scrollView.scrollEnabled = YES;
//    //最大放大比例
//    self.scrollView.maximumZoomScale = 2.0f;
//    self.scrollView.showsHorizontalScrollIndicator = NO;
//    self.scrollView.showsVerticalScrollIndicator = YES;
//    [UIView animateWithDuration:0.35 animations:^{
//        CGRect frame = imageView.frame;
//        frame.size.width = bgView.frame.size.width;
//        frame.size.height = frame.size.width * (imageView.image.size.height / imageView.image.size.width);
//        frame.origin.x = 0;
//        frame.origin.y = (bgView.frame.size.height - frame.size.height) * 0.5;
//        imageView.frame = frame;
//    }];
}

- (void)longtapImage:(UILongPressGestureRecognizer *)longtapImageReconizer{
    if (longtapImageReconizer.state == UIGestureRecognizerStateEnded) {
        DefineWeakSelf;
        [UIActionSheet actionSheetWithTitle:nil message:nil buttons:@[@"存储照片"] showInView:self.view onDismiss:^(int buttonIndex) {
            UIImageView *picView = (UIImageView *)longtapImageReconizer.view;
            [weakSelf loadImageFinished:picView.image];
        } onCancel:^{
            
        }];
    }
}

//图片保存到本地
- (void)loadImageFinished:(UIImage *)image{
    UIImageWriteToSavedPhotosAlbum(image, self, @selector(image:didFinishSavingWithError:contextInfo:), (__bridge void *)self);
}

- (void)image:(UIImage *)image didFinishSavingWithError:(NSError *)error contextInfo:(void *)contextInfo{
    XWAlerLoginView *xw = [[XWAlerLoginView alloc]initWithTitle:@"图片存储成功!"];
    [xw show];
}

-(void)tapBgView:(UITapGestureRecognizer *)tapBgRecognizer{
    self.scrollView.contentOffset = CGPointZero;
    [UIView animateWithDuration:0.35 animations:^{
        self.lastImageView.frame = self.originalFrame;
        tapBgRecognizer.view.backgroundColor = [UIColor clearColor];
    } completion:^(BOOL finished) {
        [tapBgRecognizer.view removeFromSuperview];
        self.scrollView = nil;
        self.lastImageView = nil;
    }];
}

-(UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView{
    return self.lastImageView;
}

- (void)clickPinglunImgHead:(UITapGestureRecognizer *)tapG {
    NSDictionary *components = self.pinglunArr[tapG.view.tag - 1000];
    [self skipToUserVCWihtcomponents:components];
}

- (void)skipToUserVCWihtcomponents:(NSDictionary *)components{
    gerenzhuyeVC *gerenzhuye = [gerenzhuyeVC new];
    if ([components[@"user_login"] isEqualToString:ExdangqianUser] && [[CommonCode readFromUserD:@"isLogin"]boolValue] == YES) {
        gerenzhuye.isMypersonalPage = YES;
    }
    else{
        gerenzhuye.isMypersonalPage = NO;
    }
    gerenzhuye.isNewsComment = YES;
    gerenzhuye.user_nicename = components[@"user_nicename"];
    gerenzhuye.sex = components[@"sex"];
    gerenzhuye.signature = components[@"signature"];
    gerenzhuye.user_login = components[@"user_login"];
    gerenzhuye.avatar = components[@"avatar"];
    gerenzhuye.fan_num = components[@"fan_num"];
    gerenzhuye.guan_num = components[@"guan_num"];
    gerenzhuye.user_id = components[@"uid"];
    self.hidesBottomBarWhenPushed = YES;
    [self.navigationController pushViewController:gerenzhuye animated:YES];
    self.hidesBottomBarWhenPushed = YES;
}

- (void)loginFirst {
    UIAlertController *qingshuruyonghuming = [UIAlertController alertControllerWithTitle:@"温馨提示" message:@"您还没登录，请先登录后操作" preferredStyle:UIAlertControllerStyleAlert];
    [qingshuruyonghuming addAction:[UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
    }]];
    [qingshuruyonghuming addAction:[UIAlertAction actionWithTitle:@"登录" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        LoginVC *loginFriVC = [LoginVC new];
        LoginNavC *loginNavC = [[LoginNavC alloc]initWithRootViewController:loginFriVC];
        [loginNavC.navigationBar setBackgroundColor:[UIColor whiteColor]];
        //        [loginNavC.navigationBar setBackgroundImage:[UIImage imageNamed:@"mian-1"] forBarMetrics:UIBarMetricsDefault];
        loginNavC.navigationBar.tintColor = [UIColor blackColor];
        [self presentViewController:loginNavC animated:YES completion:nil];
    }]];
    
    [self presentViewController:qingshuruyonghuming animated:YES completion:nil];
}

#pragma mark - KVO
//观察者方法，用来监听播放状态
- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSString *,id> *)change context:(void *)context{
    //当播放器状态（status）改变时，会进入此判断
    if ([keyPath isEqualToString:@"statu"]){
        switch (Explayer.status) {
            case AVPlayerStatusUnknown:
                NSLog(@"KVO：未知状态，此时不能播放");
                break;
            case AVPlayerStatusReadyToPlay:
                NSLog(@"KVO：准备完毕，可以播放");
                //自动播放
                //                [Explayer play];
                break;
            case AVPlayerStatusFailed:
                NSLog(@"KVO：加载失败，网络或者服务器出现问题");
                break;
            default:
                break;
        }
    }
}

#pragma mark - NSNotification
- (void)voicePlayEnd:(NSNotification *)notice {
    if (_playingIndex < [self.auditionResult[@"shiting"] count] - 1) {
        UIButton *nextTextMPButton = self.buttons[_playingIndex + 1];
        [self playTestMp:nextTextMPButton];
    }
    else{
        [self performSelector:@selector(wanbi:) withObject:notice afterDelay:0.5f];
        _isPlaying = NO;
    }
}

- (void)wanbi:(NSNotification *)notice{
    
    if (ExisRigester == YES){
        //        [Explayer removeObserver:self forKeyPath:@"statu"];
        //        [Explayer removeObserver:self forKeyPath:@"loadedTimeRange"];
        ExisRigester = NO;
    }
    [Explayer pause];
    [CommonCode writeToUserD:@"YES" andKey:TINGYOUQUANBOFANGWANBI];
    _isPlaying = NO;
}

- (void)dealloc {
//    [Explayer removeObserver:self forKeyPath:@"statu"];
}

#pragma mark - UIButtonAction
- (void)collectBtnAction:(UIButton *)sender{
    XWAlerLoginView *xw = [[XWAlerLoginView alloc]initWithTitle:@"购买了才能订阅哦~"];
    [xw show];
}

- (void)auditionnBtnAction:(UIButton *)sender{
    if (self.auditionnBtn.selected) {
        sender.selected = NO;
        [self.auditionnBtn setImage:[UIImage imageNamed:@"classplay"] forState:UIControlStateNormal];
        for ( int i = 0 ; i < self.buttons.count; i ++ ) {
                UIButton *anotherButton = self.buttons[i];
                anotherButton.selected = NO;
                [anotherButton setImage:[UIImage imageNamed:@"classplay"] forState:UIControlStateNormal];
                continue;
        }
        [Explayer pause];
        _isPlaying = NO;
    }
    else{
        sender.selected = YES;
        [self.auditionnBtn setImage:[UIImage imageNamed:@"classpause"] forState:UIControlStateNormal];
        for ( int i = 0 ; i < self.buttons.count; i ++ ) {
            if (i == 0) {
                UIButton *allDoneButton = [self.buttons firstObject];
                allDoneButton.selected = YES;
                [allDoneButton setImage:[UIImage imageNamed:@"classpause"] forState:UIControlStateNormal];
                continue;
            }
            else{
                UIButton *anotherButton = self.buttons[i];
                anotherButton.selected = NO;
                [anotherButton setImage:[UIImage imageNamed:@"classplay"] forState:UIControlStateNormal];
                continue;
            }
        }
        
        if ([bofangVC shareInstance].isPlay) {
            [[bofangVC shareInstance] doplay2];
        }
        else{
            
        }
        [Explayer pause];
        if (Explayer == nil) {
            Explayer = [[AVPlayer alloc]init];
            //添加观察者，用来监视播放器的状态变化
//            [Explayer addObserver:self forKeyPath:@"statu" options:NSKeyValueObservingOptionNew context:nil];
            //添加观察者，用来监听播放器的缓冲进度loadedTimeRanges属性
            //            [Explayer addObserver:self forKeyPath:@"loadedTimeRanges" options:NSKeyValueObservingOptionNew context:nil];
        }
        [Explayer replaceCurrentItemWithPlayerItem:[[AVPlayerItem alloc]initWithURL:[NSURL URLWithString:[self.auditionResult[@"shiting"] firstObject][@"s_mpurl"]]]];
        //播放完毕后发出通知
        [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(voicePlayEnd:) name:AVPlayerItemDidPlayToEndTimeNotification object:Explayer.currentItem];
        [Explayer play];
        _isPlaying = YES;
        _playingIndex = 0;
        [CommonCode writeToUserD:@"YES" andKey:TINGYOUQUANBOFANGWANBI];
        if (ExisRigester == NO){
            //添加观察者，用来监视播放器的状态变化
//            [Explayer addObserver:self forKeyPath:@"statu" options:NSKeyValueObservingOptionNew context:nil];
            //添加观察者，用来监听播放器的缓冲进度loadedTimeRanges属性
            //[Explayer addObserver:self forKeyPath:@"loadedTimeRange" options:NSKeyValueObservingOptionNew context:nil];
            ExisRigester = YES;
        }
    }
    
}

- (void)purchaseBtnAction:(UIButton *)sender{
    if ([[CommonCode readFromUserD:@"isLogin"]boolValue] == YES){
        XWAlerLoginView *xw = [[XWAlerLoginView alloc]initWithTitle:@"正在努力开发中~"];
        [xw show];
//        PayOnlineViewController *vc = [PayOnlineViewController new];
//        NSString *accesstoken = nil;
//        accesstoken = AvatarAccessToken;
//        [NetWorkTool getListenMoneyWithaccessToken:accesstoken sccess:^(NSDictionary *responseObject) {
//            NSLog(@"%@",responseObject);
//            if ([responseObject[@"status"] integerValue] == 1) {
//                vc.balanceCount = [responseObject[@"results"][@"listen_money"] doubleValue];
//                vc.rewardCount = [self.auditionResult[@"price"] floatValue];
//                vc.uid = self.auditionResult[@"act_id"];
////                vc.post_id = self.jiemuID;
//                vc.isPayClass = YES;
//                self.hidesBottomBarWhenPushed = YES;
//                [self.navigationController pushViewController:vc animated:YES];
//            }
//        } failure:^(NSError *error) {
//            
//        }];
    }
    else{
        [self loginFirst];
    }
}

- (void)playTestMp:(UIButton *)sender{
    BOOL isTestMpPlay = NO;
    for ( int i = 0 ; i < self.buttons.count; i ++ ) {
        if (i == sender.tag - 100 ) {
            UIButton *allDoneButton = self.buttons[i];
            if (allDoneButton.selected) {
                allDoneButton.selected = NO;
                [allDoneButton setImage:[UIImage imageNamed:@"classplay"] forState:UIControlStateNormal];
            }
            else{
                allDoneButton.selected = YES;
                [allDoneButton setImage:[UIImage imageNamed:@"classpause"] forState:UIControlStateNormal];
                isTestMpPlay = YES;
            }
            continue;
        }
        else{
            UIButton *anotherButton = self.buttons[i];
            anotherButton.selected = NO;
            [anotherButton setImage:[UIImage imageNamed:@"classplay"] forState:UIControlStateNormal];
            continue;
        }
    }
    if (isTestMpPlay) {
        [self.auditionnBtn setImage:[UIImage imageNamed:@"classpause"] forState:UIControlStateNormal];
    }
    else{
        [self.auditionnBtn setImage:[UIImage imageNamed:@"classplay"] forState:UIControlStateNormal];
    }
    //播放试听音频
    if (_isPlaying && (_playingIndex == sender.tag -100)) {
        [Explayer pause];
        _isPlaying = NO;
    }
    else{
        if ([bofangVC shareInstance].isPlay) {
            [[bofangVC shareInstance] doplay2];
        }
        else{
            
        }
        [Explayer pause];
        if (Explayer == nil) {
            Explayer = [[AVPlayer alloc]init];
            //添加观察者，用来监视播放器的状态变化
//            [Explayer addObserver:self forKeyPath:@"statu" options:NSKeyValueObservingOptionNew context:nil];
            //添加观察者，用来监听播放器的缓冲进度loadedTimeRanges属性
            //            [Explayer addObserver:self forKeyPath:@"loadedTimeRanges" options:NSKeyValueObservingOptionNew context:nil];
        }
        [Explayer replaceCurrentItemWithPlayerItem:[[AVPlayerItem alloc]initWithURL:[NSURL URLWithString:self.auditionResult[@"shiting"][sender.tag - 100][@"s_mpurl"]]]];
        //播放完毕后发出通知
        [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(voicePlayEnd:) name:AVPlayerItemDidPlayToEndTimeNotification object:Explayer.currentItem];
        [Explayer play];
        _isPlaying = YES;
        _playingIndex = sender.tag - 100;
        [CommonCode writeToUserD:@"YES" andKey:TINGYOUQUANBOFANGWANBI];
        if (ExisRigester == NO){
            //添加观察者，用来监视播放器的状态变化
//            [Explayer addObserver:self forKeyPath:@"statu" options:NSKeyValueObservingOptionNew context:nil];
            //添加观察者，用来监听播放器的缓冲进度loadedTimeRanges属性
            //[Explayer addObserver:self forKeyPath:@"loadedTimeRange" options:NSKeyValueObservingOptionNew context:nil];
            ExisRigester = YES;
        }
    }
}

- (void)pinglundianzanAction:(UIButton *)sender{
    UITableViewCell *cell = (UITableViewCell *)[[sender superview] superview];
    NSIndexPath *indexPath = [self.helpTableView indexPathForCell:cell];
    UILabel *dianzanNumlab = (UILabel *)[cell.contentView viewWithTag:indexPath.row + 2000];
    if (sender.selected == YES){
        [sender setImage:[UIImage imageNamed:@"pinglun-10"] forState:UIControlStateNormal];
        dianzanNumlab.text = [NSString stringWithFormat:@"%d",[dianzanNumlab.text intValue] - 1];
        dianzanNumlab.textColor = [UIColor grayColor];
        dianzanNumlab.alpha = 0.7f;
        sender.selected = NO;
        [NetWorkTool postPaoGuoXinWenPingLunDianZanWithaccessToken:[DSE encryptUseDES:ExdangqianUser]
                                                         andact_id:self.pinglunArr[indexPath.row][@"id"]
                                                            sccess:^(NSDictionary *responseObject) {
                                                                NSLog(@"responseObject = %@",responseObject);
                                                                NSLog(@"针对评论取消点赞");
                                                            }
                                                           failure:^(NSError *error) {
                                                               NSLog(@"error = %@",error);
                                                           }];
    }
    else{
        [sender setImage:[UIImage imageNamed:@"pinglun-yizan"] forState:UIControlStateNormal];
        dianzanNumlab.text = [NSString stringWithFormat:@"%d",[dianzanNumlab.text intValue] + 1];
        dianzanNumlab.textColor = ColorWithRGBA(0, 159, 240, 1);
        dianzanNumlab.alpha = 1.0f;
        sender.selected = YES;
        [NetWorkTool postPaoGuoXinWenPingLunDianZanWithaccessToken:[DSE encryptUseDES:ExdangqianUser] andact_id:self.pinglunArr[indexPath.row][@"id"] sccess:^(NSDictionary *responseObject) {
            NSLog(@"responseObject = %@",responseObject);
            NSLog(@"针对评论点赞");
        } failure:^(NSError *error) {
            NSLog(@"error = %@",error);
        }];
    }
}

-(void)morecommetAction:(UIButton *)sender{
    CommentViewController *vc = [CommentViewController new];
    vc.act_id = self.auditionResult[@"act_id"];
    self.hidesBottomBarWhenPushed = YES;
    [self.navigationController pushViewController:vc animated:YES];
}

#pragma mark - TTTAttributedLabelDelegate

- (void)attributedLabel:(TTTAttributedLabel *)label
didSelectLinkWithTransitInformation:(NSDictionary *)components {
    gerenzhuyeVC *gerenzhuye = [gerenzhuyeVC new];
    if ([components[@"user_login"] isEqualToString:ExdangqianUser] && [[CommonCode readFromUserD:@"isLogin"]boolValue] == YES) {
        gerenzhuye.isMypersonalPage = YES;
    }
    else{
        gerenzhuye.isMypersonalPage = NO;
    }
    gerenzhuye.isNewsComment = NO;
    gerenzhuye.user_nicename = components[@"user_nicename"];
    gerenzhuye.sex = components[@"sex"];
    gerenzhuye.signature = components[@"signature"];
    gerenzhuye.user_login = components[@"user_login"];
    gerenzhuye.avatar = components[@"avatar"];
    gerenzhuye.user_id = components[@"id"];
    self.hidesBottomBarWhenPushed=YES;
    [self.navigationController pushViewController:gerenzhuye animated:YES];
    self.hidesBottomBarWhenPushed=YES;
}


#pragma mark - UITableViewDelegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    
}

#pragma mark - UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    //    if (! [self.dataSourceArr count]) {
    //        if (!_label) {
    //            _label = [[UILabel alloc]initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, 20)];
    //            _label.textAlignment = NSTextAlignmentCenter;
    //            _label.text = @"暂无数据";
    //            _label.textColor = [UIColor lightGrayColor];
    //            _label.center = self.helpTableView.center;
    //            [self.helpTableView addSubview:_label];
    //        }else {
    //            [self.helpTableView addSubview:_label];
    //        }
    //    }
    //    else{
    //        [_label removeFromSuperview];
    //    }
    if ([self.auditionResult[@"comments"] isKindOfClass:[NSArray class]]){
        if ([self.auditionResult[@"comments"] count] >= 3) {
            return 4;
        }
        else{
            return  [self.auditionResult[@"comments"] count];
        }
    }
    else{
        return 0;
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    UITableViewCell *cell = (UITableViewCell *)[tableView viewWithTag:indexPath.row + 10];
    UILabel *lab = (UILabel *)[cell viewWithTag:indexPath.row + 11];
    if (indexPath.row == 3) {
        return 44;
    }
    else{
        return CGRectGetMaxY(lab.frame) + 10.0 / 667 * IPHONE_H;
    }
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    static NSString *pinglunIdentify = @"pinglunIdentify";
    UITableViewCell *cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:pinglunIdentify];
    if (!cell){
        cell = [tableView dequeueReusableCellWithIdentifier:pinglunIdentify];
    }
    
    if (indexPath.row == 3) {
        UIButton *moreComment = [UIButton buttonWithType:UIButtonTypeCustom];
        [moreComment setFrame:CGRectMake(0, 0, SCREEN_WIDTH, 44)];
        [moreComment setTitle:@"查看更多评价" forState:UIControlStateNormal];
        [moreComment.titleLabel setFont:gFontMain14];
        [moreComment setTitleColor:gTextColorSub forState:UIControlStateNormal];
        [moreComment addTarget:self action:@selector(morecommetAction:) forControlEvents:UIControlEventTouchUpInside];
        [cell.contentView addSubview:moreComment];
    }
    else{
        //头像
        UIImageView *pinglunImg = [[UIImageView alloc]initWithFrame:CGRectMake(20.0 / 375 * IPHONE_W, 8.0 / 667 * IPHONE_H, 50.0 / 667 * IPHONE_H, 50.0 / 667 * IPHONE_H)];
        if ([self.pinglunArr[indexPath.row][@"avatar"]  rangeOfString:@"http"].location != NSNotFound){
            [pinglunImg sd_setImageWithURL:[NSURL URLWithString:self.pinglunArr[indexPath.row][@"avatar"]] placeholderImage:[UIImage imageNamed:@"right-1"]];
        }
        else{
            [pinglunImg sd_setImageWithURL:[NSURL URLWithString:USERPHOTOHTTPSTRING(self.pinglunArr[indexPath.row][@"avatar"])] placeholderImage:[UIImage imageNamed:@"right-1"]];
        }
        pinglunImg.userInteractionEnabled = YES;
        pinglunImg.tag = 1000 + indexPath.row;
        UITapGestureRecognizer *TapG = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(clickPinglunImgHead:)];
        [pinglunImg addGestureRecognizer:TapG];
        pinglunImg.contentMode = UIViewContentModeScaleAspectFill;
        pinglunImg.layer.masksToBounds = YES;
        pinglunImg.layer.cornerRadius = 25.0 / 667 * IPHONE_H;
        [cell.contentView addSubview:pinglunImg];
        //
        UILabel *pinglunTitle = [[UILabel alloc]initWithFrame:CGRectMake(CGRectGetMaxX(pinglunImg.frame) + 8.0 / 375 * IPHONE_W, 10.0 / 667 * IPHONE_H, 200.0 / 375 * IPHONE_W, 20.0 / 667 * IPHONE_H)];
        pinglunTitle.text = self.pinglunArr[indexPath.row][@"full_name"];
        pinglunTitle.textAlignment = NSTextAlignmentLeft;
        pinglunTitle.textColor = [UIColor blackColor];
        pinglunTitle.font = [UIFont systemFontOfSize:16.0f];
        [cell.contentView addSubview:pinglunTitle];
        //时间
        UILabel *pinglunshijian = [[UILabel alloc]initWithFrame:CGRectMake(CGRectGetMaxX(pinglunImg.frame) + 8.0 / 375 * IPHONE_W, CGRectGetMaxY(pinglunTitle.frame) + 5.0 / 667 * IPHONE_H, 200.0 / 375 * IPHONE_W, 20.0 / 667 * IPHONE_H)];
        pinglunshijian.text = self.pinglunArr[indexPath.row][@"createtime"];
        pinglunshijian.textAlignment = NSTextAlignmentLeft;
        pinglunshijian.textColor = [UIColor grayColor];
        pinglunshijian.font = [UIFont systemFontOfSize:13.0f];
        [cell.contentView addSubview:pinglunshijian];
        //评论
        TTTAttributedLabel *pinglunLab = [[TTTAttributedLabel alloc]initWithFrame:CGRectMake(CGRectGetMaxX(pinglunImg.frame) - 3.0 / 375 * IPHONE_W, CGRectGetMaxY(pinglunshijian.frame) + 10.0 / 667 * IPHONE_H, IPHONE_W - 80.0 / 375 * IPHONE_W, 20.0 / 667 * IPHONE_H)];
        pinglunLab.text = self.pinglunArr[indexPath.row][@"content"];
        pinglunLab.textColor = [UIColor blackColor];
        pinglunLab.font = [UIFont systemFontOfSize:16.0f];
        pinglunLab.textAlignment = NSTextAlignmentLeft;
        pinglunLab.tag = indexPath.row + 11;
        pinglunLab.numberOfLines = 0;
        pinglunLab.lineSpacing = 5;
        pinglunLab.fd_collapsed = NO;
        pinglunLab.lineBreakMode = NSLineBreakByWordWrapping;
        if ([self.pinglunArr[indexPath.row][@"content"] rangeOfString:@"[e1]"].location != NSNotFound && [self.pinglunArr[indexPath.row][@"content"] rangeOfString:@"[/e1]"].location != NSNotFound){
            if ([self.pinglunArr[indexPath.row][@"to_user_login"] length]) {
                pinglunLab.text = [NSString stringWithFormat:@"回复@%@:%@",[self.pinglunArr[indexPath.row][@"to_user_nicename"] length] ? self.pinglunArr[indexPath.row][@"to_user_nicename"]:self.pinglunArr[indexPath.row][@"to_user_login"],[CommonCode jiemiEmoji:self.pinglunArr[indexPath.row][@"content"]]];
                NSMutableDictionary *to_user = [NSMutableDictionary new];
                [to_user setValue:self.pinglunArr[indexPath.row][@"to_user_nicename"] forKey:@"user_nicename"];
                [to_user setValue:self.pinglunArr[indexPath.row][@"to_sex"] forKey:@"sex"];
                [to_user setValue:self.pinglunArr[indexPath.row][@"to_signature"] forKey:@"signature"];
                [to_user setValue:self.pinglunArr[indexPath.row][@"to_user_login"] forKey:@"user_login"];
                [to_user setValue:self.pinglunArr[indexPath.row][@"to_avatar"] forKey:@"avatar"];
                //        [to_user setValue:liuyanArr[indexPath.row][@"to_user_nicename"] forKey:@"fan_num"];
                //        [to_user setValue:liuyanArr[indexPath.row][@"to_user_nicename"] forKey:@"guan_num"];
                [to_user setValue:self.pinglunArr[indexPath.row][@"to_uid"] forKey:@"id"];
                NSRange nameRange = NSMakeRange(2, [self.pinglunArr[indexPath.row][@"to_user_nicename"] length] ? [self.pinglunArr[indexPath.row][@"to_user_nicename"] length] + 1 : [self.pinglunArr[indexPath.row][@"to_user_login"] length] + 1);
                [pinglunLab setLinkAttributes:@{NSForegroundColorAttributeName : gMainColor,NSFontAttributeName :gFontMajor16}];
                [pinglunLab setActiveLinkAttributes:@{NSForegroundColorAttributeName : gMainColor,NSFontAttributeName :gFontMajor16}];
                [pinglunLab addLinkToTransitInformation:to_user withRange:nameRange];
                [pinglunLab setDelegate:self];
                
            }
            else{
                pinglunLab.text = [CommonCode jiemiEmoji:self.pinglunArr[indexPath.row][@"content"]];
            }
        }
        else{
            if ([self.pinglunArr[indexPath.row][@"to_user_login"] length]) {
                pinglunLab.text = [NSString stringWithFormat:@"回复@%@:%@",[self.pinglunArr[indexPath.row][@"to_user_nicename"] length] ? self.pinglunArr[indexPath.row][@"to_user_nicename"]:self.pinglunArr[indexPath.row][@"to_user_login"],self.pinglunArr[indexPath.row][@"content"]];
                NSMutableDictionary *to_user = [NSMutableDictionary new];
                [to_user setValue:self.pinglunArr[indexPath.row][@"to_user_nicename"] forKey:@"user_nicename"];
                [to_user setValue:self.pinglunArr[indexPath.row][@"to_sex"] forKey:@"sex"];
                [to_user setValue:self.pinglunArr[indexPath.row][@"to_signature"] forKey:@"signature"];
                [to_user setValue:self.pinglunArr[indexPath.row][@"to_user_login"] forKey:@"user_login"];
                [to_user setValue:self.pinglunArr[indexPath.row][@"to_avatar"] forKey:@"avatar"];
                //        [to_user setValue:liuyanArr[indexPath.row][@"to_user_nicename"] forKey:@"fan_num"];
                //        [to_user setValue:liuyanArr[indexPath.row][@"to_user_nicename"] forKey:@"guan_num"];
                [to_user setValue:self.pinglunArr[indexPath.row][@"to_uid"] forKey:@"id"];
                NSRange nameRange = NSMakeRange(2,  [self.pinglunArr[indexPath.row][@"to_user_nicename"] length] ? [self.pinglunArr[indexPath.row][@"to_user_nicename"] length] + 1 : [self.pinglunArr[indexPath.row][@"to_user_login"] length] + 1);
                [pinglunLab setLinkAttributes:@{NSForegroundColorAttributeName : gMainColor,NSFontAttributeName :gFontMajor16}];
                [pinglunLab setActiveLinkAttributes:@{NSForegroundColorAttributeName : gMainColor,NSFontAttributeName :gFontMajor16}];
                [pinglunLab addLinkToTransitInformation:to_user withRange:nameRange];
                [pinglunLab setDelegate:self];
            }
            else{
                pinglunLab.text = self.pinglunArr[indexPath.row][@"content"];
            }
        }
        //获取tttLabel的高度
        //先通过NSMutableAttributedString设置和上面tttLabel一样的属性,例如行间距,字体
        NSMutableAttributedString *attrString = [[NSMutableAttributedString alloc] initWithString:pinglunLab.text];
        //自定义str和TTTAttributedLabel一样的行间距
        NSMutableParagraphStyle *paragrapStyle = [[NSMutableParagraphStyle alloc] init];
        [paragrapStyle setLineSpacing:5];
        //设置行间距
        [attrString addAttribute:NSParagraphStyleAttributeName value:paragrapStyle range:NSMakeRange(0, [pinglunLab.text length])];
        //设置字体
        [attrString addAttribute:NSFontAttributeName value:[UIFont systemFontOfSize:16] range:NSMakeRange(0, [pinglunLab.text length])];
        
        //得到自定义行间距的UILabel的高度
        //CGSizeMake(300,MAXFLOAt)中的300,代表是UILable控件的宽度,它和初始化TTTAttributedLabel的宽度是一样的.
        CGFloat height = [TTTAttributedLabel sizeThatFitsAttributedString:attrString withConstraints:CGSizeMake(pinglunLab.frame.size.width, MAXFLOAT) limitedToNumberOfLines:0].height;
        //重新改变tttLabel的frame高度
        CGRect rect = pinglunLab.frame;
        rect.size.height = height + 10 ;
        pinglunLab.frame = rect;
        [cell.contentView addSubview:pinglunLab];
        
        cell.tag = indexPath.row + 10;
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        UIButton *PingLundianzanBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        PingLundianzanBtn.frame = CGRectMake(IPHONE_W - 60.0 / 375 * IPHONE_W, 20.0 / 667 * IPHONE_H, 20.0 / 375 * IPHONE_W, 20.0 / 667 * IPHONE_H);
        [cell.contentView addSubview:PingLundianzanBtn];
        [PingLundianzanBtn addTarget:self action:@selector(pinglundianzanAction:) forControlEvents:UIControlEventTouchUpInside];
        
        PingLundianzanNumLab = [[UILabel alloc]initWithFrame:CGRectMake(CGRectGetMaxX(PingLundianzanBtn.frame) + 8.0 / 375 * IPHONE_W, PingLundianzanBtn.frame.origin.y + 1.0 / 667 * IPHONE_H, 20.0 / 375 * IPHONE_W, 20.0 / 667 * IPHONE_H)];
        PingLundianzanNumLab.text = self.pinglunArr[indexPath.row][@"praisenum"];
        
        PingLundianzanNumLab.textAlignment = NSTextAlignmentCenter;
        PingLundianzanNumLab.font = [UIFont systemFontOfSize:16.0f / 375 * IPHONE_W];
        PingLundianzanNumLab.tag = indexPath.row + 2000;
        [cell.contentView addSubview:PingLundianzanNumLab];
        
        if ([[NSString stringWithFormat:@"%@",self.pinglunArr[indexPath.row][@"praiseFlag"]] isEqualToString:@"1"]){
            [PingLundianzanBtn setBackgroundImage:[UIImage imageNamed:@"pinglun-10"] forState:UIControlStateNormal];
            PingLundianzanBtn.selected = NO;
            PingLundianzanNumLab.textColor = [UIColor grayColor];
            PingLundianzanNumLab.alpha = 0.7f;
        }
        else if([[NSString stringWithFormat:@"%@",self.pinglunArr[indexPath.row][@"praiseFlag"]] isEqualToString:@"2"]){
            [PingLundianzanBtn setBackgroundImage:[UIImage imageNamed:@"pinglun-yizan"] forState:UIControlStateNormal];
            PingLundianzanBtn.selected = YES;
            PingLundianzanNumLab.textColor = ColorWithRGBA(0, 159, 240, 1);
            PingLundianzanNumLab.alpha = 1.0f;
        }
        else {
            [PingLundianzanBtn setBackgroundImage:[UIImage imageNamed:@"pinglun-10"] forState:UIControlStateNormal];
            PingLundianzanBtn.selected = NO;
            PingLundianzanNumLab.textColor = [UIColor grayColor];
            PingLundianzanNumLab.alpha = 0.7f;
        }

    }
        return cell;
}

#pragma mark - UIScrollViewDelegate
- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    if (scrollView.contentOffset.y > 209.0 / 667 * SCREEN_HEIGHT) {
        [_leftBtn setImage:[UIImage imageNamed:@"back"] forState:UIControlStateNormal];
        _topView.backgroundColor = [UIColor whiteColor];
    }
    else{
        [_leftBtn setImage:[UIImage imageNamed:@"title_ic_white"] forState:UIControlStateNormal];
        _topView.backgroundColor = [UIColor clearColor];
    }
}


- (UITableView *)helpTableView{
    if (_helpTableView == nil) {
        _helpTableView = [[UITableView alloc]initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_HEIGHT - 49) style:UITableViewStylePlain];
        [_helpTableView setDelegate:self];
        [_helpTableView setDataSource:self];
    }
    return _helpTableView;
}

- (NSMutableArray *)buttons{
    if (!_buttons)
    {
        _buttons = [NSMutableArray array];
    }
    return _buttons;
}

- (UIButton *)collectBtn{
    if (!_collectBtn) {
        _collectBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        [_collectBtn setFrame:CGRectMake(0, SCREEN_HEIGHT - 49, SCREEN_WIDTH / 4, 49)];
        [_collectBtn setImage:[UIImage imageNamed:@"home_news_collection"] forState:UIControlStateNormal];
        [_collectBtn addTarget:self action:@selector(collectBtnAction:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _collectBtn;
}

- (UIButton *)auditionnBtn{
    if (!_auditionnBtn) {
        _auditionnBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        [_auditionnBtn setFrame:CGRectMake(SCREEN_WIDTH / 4, SCREEN_HEIGHT - 49, SCREEN_WIDTH / 4, 49)];
        [_auditionnBtn setImage:[UIImage imageNamed:@"classplay"] forState:UIControlStateNormal];
        [_auditionnBtn setSelected:NO];
        [_auditionnBtn setTitle:@"试听" forState:UIControlStateNormal];
        [_auditionnBtn setTitleColor:nTextColorMain forState:UIControlStateNormal];
        [_auditionnBtn addTarget:self action:@selector(auditionnBtnAction:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _auditionnBtn;
}

-(UILabel *)priceLabel{
    if (!_priceLabel) {
        _priceLabel = [[UILabel alloc]initWithFrame:CGRectMake(SCREEN_WIDTH / 4, 0, SCREEN_WIDTH / 4, 25)];
        [_priceLabel setBackgroundColor:purchaseButtonColor];
        [_priceLabel setTextColor:[UIColor whiteColor]];
    }
    return _priceLabel;
}

-(UILabel *)spriceLabel{
    if (!_spriceLabel) {
        _spriceLabel = [[UILabel alloc]initWithFrame:CGRectMake(SCREEN_WIDTH / 4, 25, SCREEN_WIDTH / 4, 24)];
        [_spriceLabel setBackgroundColor:purchaseButtonColor];
        [_spriceLabel setTextColor:[UIColor whiteColor]];
        _spriceLabel.font = gFontMain14;
    }
    return _spriceLabel;
}

- (UIButton *)purchaseBtn{
    if (!_purchaseBtn) {
        _purchaseBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        [_purchaseBtn setFrame:CGRectMake(SCREEN_WIDTH / 2, SCREEN_HEIGHT - 49, SCREEN_WIDTH / 2, 49)];
        [_purchaseBtn setBackgroundColor:purchaseButtonColor];
        [_purchaseBtn setTitleEdgeInsets:UIEdgeInsetsMake(0, 0, 0, SCREEN_WIDTH / 4)];
        [_purchaseBtn setTitle:@"购买" forState:UIControlStateNormal];
        [_purchaseBtn.titleLabel setTextAlignment:NSTextAlignmentLeft];
        [_purchaseBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [_purchaseBtn addTarget:self action:@selector(purchaseBtnAction:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _purchaseBtn;
}

- (AVPlayer *)voicePlayer {
    if (!_voicePlayer) {
        _voicePlayer = [[AVPlayer alloc]init];
    }
    return _voicePlayer;
}

- (NSMutableArray *)dataSourceArr{
    if (!_dataSourceArr) {
        _dataSourceArr = [NSMutableArray array];
    }
    return _dataSourceArr;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
