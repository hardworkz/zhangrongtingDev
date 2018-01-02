//
//  DownloadCell.m
//  Heard the news
//
//  Created by Pop Web on 15/8/13.
//  Copyright (c) 2015年 泡果网络. All rights reserved.
//

#import "DownloadCell.h"

#import "CommonCode.h"

#import "UIImageView+WebCache.h"

#import "WHC_Download.h"

#import "NewObj.h"

@interface DownloadCell ()<WHCDownloadDelegate>

@property (weak, nonatomic) IBOutlet UILabel *wangsu;
@property (weak, nonatomic) IBOutlet UIProgressView *progressView;
@property (nonatomic, strong) WHC_Download *op;
@property (nonatomic) BOOL progressFlag;
@end

@implementation DownloadCell

- (instancetype)initWithCoder:(NSCoder *)coder
{
    self = [super initWithCoder:coder];
    if (self) {
        
    }
    return self;
}

- (void)awakeFromNib
{
    [super awakeFromNib];
}

- (void)displayCell:(WHC_Download *)object{
    self.op.delegate = nil;
    object.delegate = self;
    self.labelName.text = object.obj[@"post_title"];
    //新闻图片url处理
    NSString *finalURL;
    if ([NEWSSEMTPHOTOURL(object.obj[@"smeta"])  rangeOfString:@"http"].location != NSNotFound){
        finalURL = NEWSSEMTPHOTOURL(object.obj[@"smeta"]);
    }
    else{
        finalURL = USERPHOTOHTTPSTRINGZhuBo(NEWSSEMTPHOTOURL(object.obj[@"smeta"]));
    }
    [self.ImageNew sd_setImageWithURL:[NSURL URLWithString:finalURL] placeholderImage:[UIImage imageNamed:@"thumbnailsdefault"]];
    __weak __typeof(self) selfBlock = self;
    [selfBlock.button setTitle:@"等待" forState:UIControlStateNormal];
    [selfBlock.button setBackgroundColor:[UIColor redColor]];
    selfBlock.progressView.progress = 0.f;
    selfBlock.downloadDta.text = [NSString stringWithFormat:@"0%%"];
    selfBlock.wangsu.text = [NSString stringWithFormat:@"0kb"];
    self.op = object;
}

- (void)dealloc
{
    self.op.delegate = nil;
}

- (void)WHCDownload:(WHC_Download *)download didReceivedLen:(uint64_t)receivedLen totalLen:(uint64_t)totalLen networkSpeed:(NSString *)networkSpeed {
    [self.button setTitle:@"下载中" forState:UIControlStateNormal];
    [self.button setBackgroundColor:[UIColor lightGrayColor]];
    CGFloat progress = (float)receivedLen / totalLen;
    [_progressView setProgress:progress animated:YES];
    NSString *strText = [NSString stringWithFormat:@"%.f%%", progress * 100];
    self.downloadDta.text = strText;
    NSString *strW = [NSString stringWithFormat:@"%@", networkSpeed];
    self.wangsu.text = strW;
}

//下载出错
- (void)WHCDownload:(WHC_Download *)download error:(NSError *)error {
    [self.button setTitle:@"下载失败" forState:UIControlStateNormal];
}

//下载结束
- (void)WHCDownload:(WHC_Download *)download filePath:(NSString *)filePath isSuccess:(BOOL)success {

}

- (IBAction)clickDownBtn:(UIButton *)sender{
 }

@end
