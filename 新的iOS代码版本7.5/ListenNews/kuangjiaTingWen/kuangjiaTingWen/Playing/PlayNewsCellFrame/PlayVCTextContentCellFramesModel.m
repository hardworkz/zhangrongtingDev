//
//  PlayVCTextContentCellFramesModel.m
//  kuangjiaTingWen
//
//  Created by 泡果 on 2017/7/26.
//  Copyright © 2017年 zhimi. All rights reserved.
//

#import "PlayVCTextContentCellFramesModel.h"
#import "NSDate+TimeFormat.h"

@implementation PlayVCTextContentCellFramesModel
- (void)setExcerpt:(NSString *)excerpt
{
    _excerpt = excerpt;
    //计算文字的宽高
    //标题
    UILabel *titleLab = [[UILabel alloc] init];
    titleLab.textAlignment = NSTextAlignmentLeft;
    titleLab.textColor = nTextColorMain;
    titleLab.lineBreakMode = NSLineBreakByWordWrapping;
    titleLab.numberOfLines = 0;
    titleLab.frame = CGRectMake(20.0 / 375 * IPHONE_W, 20.0 / 667 * SCREEN_HEIGHT, IPHONE_W - 40.0 / 375 * IPHONE_W, 40.0 / 667 * IPHONE_H);
    titleLab.font = [UIFont boldSystemFontOfSize:self.titleFontSize];
    
    CGFloat titleHight = [self computeTextHeightWithString:self.title andWidth:(SCREEN_WIDTH-20) andFontSize:CUSTOM_FONT_TYPE(self.titleFontSize)];
    [titleLab setFrame:CGRectMake(20.0 / 375 * IPHONE_W, 20.0 / 667 * SCREEN_HEIGHT, IPHONE_W - 40.0 / 375 * IPHONE_W, (titleHight + 25) / 667 * IPHONE_H)];
    _titleLabelF = titleLab.frame;
    //日期
    CGFloat timeHight = [self computeTextHeightWithString:self.timeString andWidth:(SCREEN_WIDTH-20) andFontSize:CUSTOM_FONT_TYPE(self.dateFont)];
    _timeLabelF = CGRectMake(20.0 / 375 * IPHONE_W, CGRectGetMaxY(titleLab.frame) + 10.0 / 667 * IPHONE_H, IPHONE_W - 40.0 / 375 * IPHONE_W, timeHight);
    //新闻内容
    UITextView *zhengwenTextView = [[UITextView alloc]initWithFrame:CGRectMake(10.0 / 375 * IPHONE_W,CGRectGetMaxY(_timeLabelF) + 24.0 / 667 * IPHONE_H, IPHONE_W - 20.0 / 375 * IPHONE_W, 50.0 / 667 * IPHONE_H)];
    zhengwenTextView.scrollEnabled = NO;
    zhengwenTextView.editable = NO;
    zhengwenTextView.scrollsToTop = NO;
    NSString *str1 = [_excerpt stringByReplacingOccurrencesOfString:@"\r" withString:@""];
    zhengwenTextView.text = str1;
    zhengwenTextView.font = CUSTOM_FONT_TYPE(self.titleFontSize);
    NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle alloc]init];
    [paragraphStyle setLineSpacing:8.0];
    [paragraphStyle setAlignment:NSTextAlignmentLeft];
    [paragraphStyle setFirstLineHeadIndent:5.0];
    [paragraphStyle setLineBreakMode:NSLineBreakByCharWrapping];
    [zhengwenTextView sizeToFit];
    if (zhengwenTextView.text.length != 0){
        NSMutableAttributedString *attributedString =  [[NSMutableAttributedString alloc] initWithString:zhengwenTextView.text attributes:@{NSForegroundColorAttributeName : gTextDownload,NSFontAttributeName : CUSTOM_FONT_TYPE(self.titleFontSize)}];
        [attributedString addAttribute:NSParagraphStyleAttributeName value:paragraphStyle range:NSMakeRange(0, zhengwenTextView.text.length)];
        zhengwenTextView.attributedText = attributedString;
    }
    CGSize size = [zhengwenTextView sizeThatFits:CGSizeMake(zhengwenTextView.frame.size.width, MAXFLOAT)];
    
    _contentLabelF = CGRectMake(zhengwenTextView.x, zhengwenTextView.y, zhengwenTextView.width, size.height);
    
//    if (self.isHideReadOriginalEssay) {
//        _readOriginalEssayF = CGRectMake(20, CGRectGetMaxY(_contentLabelF) + 10, SCREEN_WIDTH - 40, 35.0 / 667 * IPHONE_H);
//    }else{
//        _readOriginalEssayF = CGRectMake(0, CGRectGetMaxY(_contentLabelF), SCREEN_WIDTH, 0);
//    }
    
    _cellHeight = CGRectGetMaxY(_contentLabelF) + 5;
}
#pragma mark - 工具方法
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
    
    CGRect rect  = [string boundingRectWithSize:CGSizeMake(width, MAXFLOAT)
                                        options: NSStringDrawingUsesFontLeading |NSStringDrawingUsesLineFragmentOrigin
                                     attributes:@{NSFontAttributeName:fontSize}
                                        context:nil];
    return ceil(rect.size.height);
}
@end
