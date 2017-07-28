//
//  PlayVCTextContentTableViewCell.m
//  kuangjiaTingWen
//
//  Created by 泡果 on 2017/7/26.
//  Copyright © 2017年 zhimi. All rights reserved.
//

#import "PlayVCTextContentTableViewCell.h"
#import "NSDate+TimeFormat.h"

@interface PlayVCTextContentTableViewCell()
{
    UILabel *titleLab;
    UILabel *riqiLab;
    UITextView *zhengwenTextView;
    UIButton *readOriginalEssay;
}
@end
@implementation PlayVCTextContentTableViewCell
+ (NSString *)ID
{
    return @"ClassContentTableViewCell";
}
+(PlayVCTextContentTableViewCell *)cellWithTableView:(UITableView *)tableView
{
    PlayVCTextContentTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:[PlayVCTextContentTableViewCell ID]];
    if (cell == nil) {
        cell = [[PlayVCTextContentTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:[PlayVCTextContentTableViewCell ID]];
    }
    return cell;
}
- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        //标题
        titleLab = [[UILabel alloc] init];
        titleLab.textAlignment = NSTextAlignmentLeft;
        titleLab.textColor = nTextColorMain;
        titleLab.lineBreakMode = NSLineBreakByWordWrapping;
        titleLab.numberOfLines = 0;
        titleLab.frame = CGRectMake(20.0 / 375 * IPHONE_W, 20.0 / 667 * SCREEN_HEIGHT, IPHONE_W - 40.0 / 375 * IPHONE_W, 40.0 / 667 * IPHONE_H);
        [self.contentView addSubview:titleLab];
        
        //日期
        riqiLab = [[UILabel alloc] init];
        riqiLab.textAlignment = NSTextAlignmentCenter;
        riqiLab.textColor = nTextColorSub;
        [self.contentView addSubview:riqiLab];

        //新闻内容
        zhengwenTextView = [[UITextView alloc]initWithFrame:CGRectMake(20.0 / 375 * IPHONE_W, 0 + 24.0 / 667 * IPHONE_H, IPHONE_W - 40.0 / 375 * IPHONE_W, 50.0 / 667 * IPHONE_H)];
        zhengwenTextView.scrollEnabled = NO;
        zhengwenTextView.editable = NO;
        zhengwenTextView.scrollsToTop = NO;
        [self.contentView addSubview:zhengwenTextView];
        
        //阅读原文
        readOriginalEssay = [UIButton buttonWithType:UIButtonTypeCustom];
        readOriginalEssay.backgroundColor = gMainColor;
        [readOriginalEssay setTitle:@"阅读原文" forState:UIControlStateNormal];
        [readOriginalEssay.layer setMasksToBounds:YES];
        [readOriginalEssay.layer setCornerRadius:5.0f];
        readOriginalEssay.userInteractionEnabled = YES;
        [readOriginalEssay addTarget:self action:@selector(readOriginalEssay:) forControlEvents:UIControlEventTouchUpInside];
        [self.contentView addSubview:readOriginalEssay];

    }
    return self;
}
- (void)setFrameModel:(PlayVCTextContentCellFramesModel *)frameModel
{
    _frameModel = frameModel;
    titleLab.frame = frameModel.titleLabelF;
    riqiLab.frame = frameModel.timeLabelF;
    
    titleLab.font = [UIFont boldSystemFontOfSize:frameModel.titleFontSize];
    titleLab.text = frameModel.title;
    
    riqiLab.font = [UIFont systemFontOfSize:frameModel.dateFont];
    riqiLab.text = frameModel.timeString;
    
    //设置文本内容和frame
    NSString *str1 = [frameModel.excerpt stringByReplacingOccurrencesOfString:@"\r" withString:@""];
    zhengwenTextView.text = str1;
    zhengwenTextView.font = [UIFont systemFontOfSize:frameModel.titleFontSize];
    NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle alloc]init];
    [paragraphStyle setLineSpacing:8.0];
    [paragraphStyle setAlignment:NSTextAlignmentLeft];
    [paragraphStyle setFirstLineHeadIndent:5.0];
    [paragraphStyle setLineBreakMode:NSLineBreakByCharWrapping];
    [zhengwenTextView sizeToFit];
    if (zhengwenTextView.text.length != 0){
        NSMutableAttributedString *attributedString =  [[NSMutableAttributedString alloc] initWithString:zhengwenTextView.text attributes:@{NSForegroundColorAttributeName : HEXCOLOR(0x505050),NSFontAttributeName : [UIFont systemFontOfSize:frameModel.titleFontSize]}];
        [attributedString addAttribute:NSParagraphStyleAttributeName value:paragraphStyle range:NSMakeRange(0, zhengwenTextView.text.length)];
        zhengwenTextView.attributedText = attributedString;
    }
    zhengwenTextView.frame = frameModel.contentLabelF;
}
- (void)readOriginalEssay:(UIButton *)item
{
    if (self.readOriginalEssay) {
        self.readOriginalEssay(item);
    }
}
@end
