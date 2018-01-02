//
//  NewsCell.m
//  kuangjiaTingWen
//
//  Created by 泡果 on 2017/8/21.
//  Copyright © 2017年 zhimi. All rights reserved.
//

#import "NewsCell.h"

@interface NewsCell ()<WHCDownloadDelegate>
{
    UIImageView *imgLeft;
    UILabel *titleLab;
    UILabel *detailNews;
    UILabel *riqiLab;
    UILabel *dataLab;
    UIButton *downloadBtn;
    UIView *line;
}
@end
@implementation NewsCell

+ (NSString *)ID
{
    return @"NewsCell";
}
+(NewsCell *)cellWithTableView:(UITableView *)tableView
{
    NewsCell *cell = [tableView dequeueReusableCellWithIdentifier:[NewsCell ID]];
    if (cell == nil) {
        cell = [[NewsCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:[NewsCell ID]];
    }
    return cell;
}
- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        self.selectionStyle = UITableViewCellSelectionStyleNone;
        
        CGFloat offsetY = 0;
        //图片
        imgLeft = [[UIImageView alloc]initWithFrame:CGRectMake(SCREEN_WIDTH - 120.0 / 375 * IPHONE_W, 19 + offsetY, 105.0 / 375 * IPHONE_W, 84.72 / 375 *IPHONE_W)];
        if (IS_IPAD) {
            [imgLeft setFrame:CGRectMake(SCREEN_WIDTH - 125.0 / 375 * IPHONE_W, 19 + offsetY, 105.0 / 375 * IPHONE_W, 70.0 / 375 *IPHONE_W)];
        }else if (IS_IPHONEX){
            [imgLeft setFrame:CGRectMake(SCREEN_WIDTH - 125.0, 19 + offsetY, 105.0, 84.72)];
        }
        imgLeft.contentMode = UIViewContentModeScaleAspectFill;
        imgLeft.clipsToBounds = YES;
        [self.contentView addSubview:imgLeft];
        
        //标题
        titleLab = [[UILabel alloc]initWithFrame:CGRectMake(15.0 / 375 * IPHONE_W, 16.0 / 667 * IPHONE_H + offsetY,  SCREEN_WIDTH - 155.0 / 375 * IPHONE_W, 21.0 / 667 *IPHONE_H)];
        if (IS_IPHONEX){
            [titleLab setFrame:CGRectMake(15.0, 16.0 + offsetY, SCREEN_WIDTH - 155.0, 21.0)];
        }
        titleLab.textAlignment = NSTextAlignmentLeft;
        titleLab.font = CUSTOM_FONT_TYPE(17.0);
        titleLab.lineBreakMode = NSLineBreakByWordWrapping;
        titleLab.textColor = TITLE_COLOR_HEX;
        [titleLab setNumberOfLines:3];
//        titleLab.backgroundColor = [UIColor blueColor];
        [self.contentView addSubview:titleLab];
        
        if (IS_IPAD) {
            //正文
            detailNews = [[UILabel alloc]initWithFrame:CGRectMake(15.0 / 375 * IPHONE_W, titleLab.frame.origin.y + titleLab.frame.size.height + 20.0 , titleLab.frame.size.width, 40.0)];
            detailNews.numberOfLines = 0;
            detailNews.textColor = gTextColorSub;
//            detailNews.backgroundColor = [UIColor redColor];
            detailNews.font = CUSTOM_FONT_TYPE(15.0);
            [self.contentView addSubview:detailNews];
        }
        
        //日期
        riqiLab = [[UILabel alloc]initWithFrame:CGRectMake(15.0 / 375 * IPHONE_W, 86.0 / 667 *IPHONE_H + offsetY, 135.0 / 375 * IPHONE_W, 21.0 / 667 *IPHONE_H)];
        if (IS_IPHONEX){
            [riqiLab setFrame:CGRectMake(15.0, 86.0 + offsetY, 135.0, 21.0)];
        }
        riqiLab.textColor = nSubColor;
        riqiLab.font = CUSTOM_FONT_TYPE(13.0);
        [self.contentView addSubview:riqiLab];
        //大小
        dataLab = [[UILabel alloc]initWithFrame:CGRectMake(SCREEN_WIDTH - 213.0 / 375 * IPHONE_W, 86.0 / 667 *IPHONE_H + offsetY, 45.0 / 375 * IPHONE_W, 21.0 / 667 *IPHONE_H)];
        if (IS_IPHONEX){
            [dataLab setFrame:CGRectMake(SCREEN_WIDTH - 213.0, 86.0 + offsetY, 45.0, 21.0)];
        }
        dataLab.textColor = nSubColor;
        dataLab.font = CUSTOM_FONT_TYPE(13.0);
        dataLab.textAlignment = NSTextAlignmentCenter;
        [self.contentView addSubview:dataLab];
        //下载
        downloadBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        [downloadBtn setFrame:CGRectMake(CGRectGetMaxX(dataLab.frame), 86.0 / 667 *IPHONE_H + offsetY, 30.0 / 667 *IPHONE_H, 30.0 / 667 *IPHONE_H)];
        if (IS_IPHONEX){
            [downloadBtn setFrame:CGRectMake(CGRectGetMaxX(dataLab.frame), 86.0 + offsetY, 30.0, 30.0)];
        }
        [downloadBtn setImage:[UIImage imageNamed:@"download_grey"] forState:UIControlStateNormal];
        [downloadBtn setImage:[UIImage imageNamed:@"download_finish"] forState:UIControlStateDisabled];
        [downloadBtn setImageEdgeInsets:UIEdgeInsetsMake(0, 0, 10, 10)];
        [downloadBtn addTarget:self action:@selector(downloadColumnNewsAction:) forControlEvents:UIControlEventTouchUpInside];
        downloadBtn.accessibilityLabel = @"下载";
        [self.contentView addSubview:downloadBtn];
        
        line = [[UIView alloc]initWithFrame:CGRectMake(15.0 / 375 * SCREEN_WIDTH, CGRectGetMaxY(dataLab.frame) + 12.0 / 667 * SCREEN_HEIGHT, SCREEN_WIDTH - 30.0 / 375 * SCREEN_WIDTH, 0.5)];
        if (IS_IPHONEX){
            [line setFrame:CGRectMake(15.0, CGRectGetMaxY(dataLab.frame) + 12.0, SCREEN_WIDTH - 30.0, 0.5)];
        }
        [line setBackgroundColor:nMineNameColor];
        [self.contentView addSubview:line];
        
    }
    return self;
}
- (void)setDataDict:(NSDictionary *)dataDict
{
    _dataDict = dataDict;
    
    //图片
    if ([NEWSSEMTPHOTOURL(dataDict[@"smeta"])  rangeOfString:@"http"].location != NSNotFound){
        [imgLeft sd_setImageWithURL:[NSURL URLWithString:NEWSSEMTPHOTOURL(dataDict[@"smeta"])]];
    }
    else{
        NSString *str = USERPHOTOHTTPSTRINGZhuBo(NEWSSEMTPHOTOURL(dataDict[@"smeta"]));
        [imgLeft sd_setImageWithURL:[NSURL URLWithString:str]];
    }
    //标题
    titleLab.text = dataDict[@"post_title"];
    titleLab.textColor = [[ZRT_PlayerManager manager] textColorFormID:dataDict[@"id"]];
    CGSize size = [titleLab sizeThatFits:CGSizeMake(titleLab.frame.size.width, MAXFLOAT)];
    titleLab.frame = CGRectMake(titleLab.frame.origin.x, titleLab.frame.origin.y, titleLab.frame.size.width, size.height);
    //正文
    if (IS_IPAD) {
        detailNews.text = dataDict[@"post_excerpt"];
    }
    //日期
    NSDate *date = [NSDate dateFromString:dataDict[@"post_modified"]];
    riqiLab.text = [date showTimeByTypeA];
    //大小
    dataLab.text = [NSString stringWithFormat:@"%.1lf%@",[dataDict[@"post_size"] intValue] / 1024.0 / 1024.0,@"M"];
    //是否已下载
    if ([[ZRT_PlayerManager manager] post_mpWithDownloadNewsID:dataDict[@"id"]] != nil) {
        downloadBtn.enabled = NO;
    }else{
        downloadBtn.enabled = YES;
    }
}
- (void)downloadColumnNewsAction:(UIButton *)button
{
    if ([[ZRT_PlayerManager manager] limitPlayStatusWithAdd:NO]) {
        [self alertMessageWithVipLimit];
        return;
    }
    if ([[ZRT_PlayerManager manager] post_mpWithDownloadNewsID:_dataDict[@"id"]] != nil) {
        XWAlerLoginView *alert = [XWAlerLoginView alertWithTitle:@"该新闻已下载过"];
        [alert show];
        return;
    }
    [SVProgressHUD showInfoWithStatus:@"开始下载"];
    [self performSelector:@selector(SVPDismiss) withObject:nil afterDelay:1.0];
    NSMutableDictionary *dic = (NSMutableDictionary *)_dataDict;
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        ProjiectDownLoadManager *manager = [ProjiectDownLoadManager defaultProjiectDownLoadManager];
        [manager insertSevaDownLoadArray:dic];
        WHC_Download *op = [[WHC_Download alloc]initStartDownloadWithURL:[NSURL URLWithString:dic[@"post_mp"]] savePath:manager.userDownLoadPath savefileName:[dic[@"post_mp"] stringByReplacingOccurrencesOfString:@"/" withString:@""] withObj:dic  isSingleDownload:YES delegate:nil];
        op.delegate = self;
        [manager.downLoadQueue addOperation:op];
    });
}
- (void)SVPDismiss
{
    [SVProgressHUD dismiss];
}
/**
 弹窗提示已听完每日限制，需要购买会员才能继续收听
 */
- (void)alertMessageWithVipLimit
{
    id object = [self nextResponder];
    
    while (![object isKindOfClass:[UIViewController class]] &&
           object != nil) {
        object = [object nextResponder];
    }
    UIViewController *alertVC = (UIViewController *)object;

    UIAlertController *qingshuruyonghuming = [UIAlertController alertControllerWithTitle:@"温馨提示" message:[NSString stringWithFormat:@"您还不是会员，每日可收听(或下载)的%@条已听完，是否前往开通会员，收听更多资讯",[CommonCode readFromUserD:[NSString stringWithFormat:@"%@",limit_num]]] preferredStyle:UIAlertControllerStyleAlert];
    [qingshuruyonghuming addAction:[UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
    }]];
    [qingshuruyonghuming addAction:[UIAlertAction actionWithTitle:@"前往开通会员" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        if ([[CommonCode readFromUserD:@"isLogin"] boolValue] == YES) {
            MyVipMenbersViewController *MyVip = [MyVipMenbersViewController new];
            [alertVC.navigationController pushViewController:MyVip animated:YES];
        }else{
            LoginVC *loginFriVC = [LoginVC new];
            loginFriVC.isFormDownload = YES;
            LoginNavC *loginNavC = [[LoginNavC alloc]initWithRootViewController:loginFriVC];
            [loginNavC.navigationBar setBackgroundColor:[UIColor whiteColor]];
            loginNavC.navigationBar.tintColor = [UIColor blackColor];
            [alertVC presentViewController:loginNavC animated:YES completion:nil];
        }
    }]];
    
    [alertVC presentViewController:qingshuruyonghuming animated:YES completion:nil];
}
- (void)WHCDownload:(WHC_Download *)download filePath:(NSString *)filePath isSuccess:(BOOL)success
{
    if ([_dataDict[@"post_mp"] isEqualToString:download.downUrl.absoluteString]) {
        downloadBtn.enabled = NO;
    }
}
@end
