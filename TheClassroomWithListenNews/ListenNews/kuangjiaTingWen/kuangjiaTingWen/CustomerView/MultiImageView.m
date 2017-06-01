//
//  MultiImageView.m
//  zfbuser
//
//  Created by Lin Eric on 15/7/17.
//  Copyright (c) 2015年 Eric. All rights reserved.
//

#import "MultiImageView.h"
#import "UIImageView+WebCache.h"
#import "UIView+tap.h"
#import "UIImage+compress.h"

//TODO:  把各种参数 用delegate 剥离逻辑
// 图片之间的横向间隔
#define kSpaceCells 5
// 图片之间的纵向
#define kSpaceLines 5

//每张图片的宽度
#define kImageWidht 75
//每张图片的高度
#define kImageHeight 75

// 每行 3 个 cell
#define kCellPerLine 3

//1张图片的最大宽度
#define OneImageMaxWidht 200
//1张图片的最大高度
#define OneImageMaxHeight 200


// 内边距
//#define kDefaultContentInset  UIEdgeInsetsMake(10, 10, 10, 10)
// debug 方便
#define Debug_MultiImageView 0

@interface MultiImageView(){
    
}

@property(nonatomic,copy) MultiImageViewTapBlock doImageTap;

@property(nonatomic,strong)UIView * containerView;

@property(nonatomic,assign) CGFloat width;
@property(nonatomic,assign)CGFloat height;

@end

@implementation MultiImageView

- (id)initWithFrame:(CGRect)frame{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        [self setupContainer];
        [self setupSubViews];
        [self setupParam];
    }
    return self;
}

- (void)awakeFromNib{
    [super awakeFromNib];
    [self setupContainer];
    [self setupSubViews];
    [self setupParam];
    if (Debug_MultiImageView){
        self.backgroundColor = [UIColor greenColor];
        self.containerView.backgroundColor = [UIColor redColor];
    }else self.backgroundColor = [UIColor clearColor];
}

- (void)setupParam{
    self.cancelNetworkWhenReuse = YES;
}

- (void)setupSubViews{
    _imageViewCount = 9;
    _subImageViews = [NSMutableArray array];
    for (int i =0; i<_imageViewCount; i++){
        UIImageView * imgv = [[UIImageView alloc] initWithFrame:CGRectZero];
        imgv.contentMode = UIViewContentModeScaleAspectFill;
        imgv.clipsToBounds = YES;
        imgv.userInteractionEnabled = YES;
        [imgv addTapGesWithTarget:self action:@selector(actionTapImage:)];
    
        imgv.tag = i;
        [self.containerView addSubview:imgv];
        [_subImageViews addObject:imgv];
    }
}

- (void)setupContainer{
    self.containerView = [[UIView alloc] init];
    [self addSubview:self.containerView];
    self.containerView.clipsToBounds = YES;
}

- (UIImageView *)dequeueImageView:(NSInteger)idx{
    return [_subImageViews objectAtIndex:idx];
}

- (void)setImages:(NSArray *)images{
    if (_images == images)
        return;
    if (images.count > 9) {
        _images = [images subarrayWithRange:NSMakeRange(0, 9)];
    }
    else {
        _images = images;
    }
    
    [self clearImages];
    [self setNeedsLayout];
}

- (void)clearImages{
    for (UIImageView *imgv in _subImageViews) {
        imgv.image = nil;
    }
    _isDataLoaded = NO;
}

- (void)cancelImageDownload{
    for (NSUInteger i = 0; i < _subImageViews.count; i++){
        UIImageView * imgv = _subImageViews[i];
        [imgv sd_cancelCurrentImageLoad];
    }
}

-(void)prepareForReuse{
    if (self.cancelNetworkWhenReuse) {
        [self cancelImageDownload];
    }
    [self clearImages];
}

-(void)layoutSubviews{
    [super layoutSubviews];
    [self layoutContainer];
    [self loadImages];
}

-(void)layoutContainer{
    UIEdgeInsets inset = self.contentInset;
    self.containerView.frame = CGRectMake(inset.left,inset.top , self.frame.size.width-inset.left -inset.right, self.frame.size.height - inset.top -inset.bottom);
}

#define URL(httpurl) [NSURL URLWithString:httpurl]

- (void)loadImages{
    NSInteger lineIdx = 0;
    NSInteger lineNo = 0;
    if ([_images count] == 1) {
        UIImageView * imgv = [self dequeueImageView:0];
        imgv.hidden = NO;
        NSString *pat = [NSString stringWithFormat:@"%@", [_images firstObject]];
        NSURL *url = URL(pat);
        [[SDWebImageDownloader sharedDownloader]downloadImageWithURL:url options:SDWebImageDownloaderUseNSURLCache progress:^(NSInteger receivedSize, NSInteger expectedSize) {
            
        } completed:^(UIImage *image, NSData *data, NSError *error, BOOL finished) {
            //这边就能拿到图片了
            imgv.frame = CGRectMake(0,0, image.size.width > SCREEN_WIDTH - 100 ? SCREEN_WIDTH - 100 :image.size.width , image.size.height > 150 ? 150 :image.size.height);
            
            RTLog(@"imageW:%f ---iamgeH:%f",image.size.width,image.size.height);
            
            imgv.contentMode = UIViewContentModeScaleAspectFit;
            if (image.size.width >= image.size.height) {
                imgv.frame = CGRectMake(0,0, (OneImageMaxWidht * image.size.width/image.size.height) >= (SCREEN_WIDTH - 80)?(SCREEN_WIDTH - 80):(OneImageMaxWidht * image.size.width/image.size.height), OneImageMaxHeight);
//                [imgv setImage:[image imageWithScaledToSize:CGSizeMake(imgv.frame.size.width, OneImageMaxHeight)]];
                [imgv setImage:image];
            }else if(image.size.width < image.size.height){
                imgv.frame = CGRectMake(0,0, OneImageMaxWidht * image.size.width / image.size.height, OneImageMaxHeight);
//                [imgv setImage:[image imageWithScaledToSize:CGSizeMake(OneImageMaxWidht * image.size.width / image.size.height, OneImageMaxHeight)]];
                [imgv setImage:image];
            }
        }];
        
    }
    else{
        for (NSInteger i = 0; i < _images.count; i++){
            lineIdx = i % kCellPerLine;
            lineNo = i / kCellPerLine;
            
            UIImageView * imgv = [self dequeueImageView:i];
            imgv.contentMode = UIViewContentModeScaleAspectFill;
            imgv.hidden = NO;
            imgv.frame = CGRectMake(lineIdx * (kImageWidht + kSpaceCells),lineNo* (kImageHeight + kSpaceLines), kImageWidht, kImageHeight);

            if (!_isDataLoaded ){
                NSString *pat = [NSString stringWithFormat:@"%@", _images[i]];
                NSURL *url = URL(pat);
                if ([url isFileURL]){
                    NSString * path = [_images[i] relativePath];
                    __block UIImage *img = nil;
                    
                    img = [[UIImage alloc] initWithContentsOfFile:path];
                    [imgv setImage: img];
                }
                else{
                    [imgv sd_setImageWithURL:url placeholderImage:nil];
                }
            }
        }
    }
    
    for (NSUInteger i = _images.count; i < 9; i++) {
        UIImageView *imgv = [self dequeueImageView:i];
        imgv.hidden = YES;
    }
}

- (CGSize)sizeForContent:(NSArray *)images{
    CGSize size = [self sizeForContainer:images];
    if (CGSizeEqualToSize(size, CGSizeZero)) {
        return CGSizeZero;
    }
    return  CGSizeMake(size.width + _contentInset.left + self.contentInset.right, size.height + _contentInset.top + _contentInset.bottom);
}

- (CGSize)sizeForContainer:(NSArray *)images{
    NSInteger count = images.count; // raw
    if (count > 9) {
        count = 9;
    }
    //    NSInteger count = self.count;//test
    _width = 0;
    _height = 0;
    if (count == 1) {
        _width = SCREEN_WIDTH - 80 ;
        _height = OneImageMaxHeight;
    }
    else if (1 < count && count <= 3){
        // 此时布局只需要一行
        _width = kImageWidht * count + kSpaceCells * (count-1);
        _height = kImageHeight;
    }
    else if (3<count && count <= 6){
        //  此时布局需要两行
        _width = kImageWidht * 3 + kSpaceCells *2;
        _height = kImageHeight * 2 + kSpaceLines;
    }
    else if (6 < count && count <= 9){
        // 此时布局需要三行
        _width = kImageWidht * 3 + kSpaceCells *2;
        _height = kImageHeight * 3 + kSpaceLines * 2;
    }
    return CGSizeMake(_width, _height);
}

- (void)setTapImageBlock:(MultiImageViewTapBlock)block{
    self.doImageTap = block;
}

- (void)actionTapImage:(UITapGestureRecognizer *)tap{
    //delegate callback
    __weak UIImageView * imgv = (UIImageView *)tap.view;
    if (self.delegate &&[self.delegate respondsToSelector:@selector(multiImageView:didTapImageView:AtIndex:)]){
        [self.delegate multiImageView:self didTapImageView:imgv AtIndex:imgv.tag];
    }
    //block callback
    DefineWeakSelf;
    if (self.doImageTap) {
        self.doImageTap(weakSelf,imgv,imgv.tag);
    }
}


#pragma mark - Setter

- (void)setContentInset:(UIEdgeInsets)contentInset{
    _contentInset = contentInset;
    [self layoutContainer];
}

@end
