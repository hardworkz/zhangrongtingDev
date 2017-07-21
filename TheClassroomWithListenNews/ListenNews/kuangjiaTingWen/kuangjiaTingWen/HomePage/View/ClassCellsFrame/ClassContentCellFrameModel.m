//
//  ClassContentCellFrameModel.m
//  kuangjiaTingWen
//
//  Created by 泡果 on 2017/6/2.
//  Copyright © 2017年 zhimi. All rights reserved.
//

#import "ClassContentCellFrameModel.h"

@implementation ClassContentCellFrameModel
- (void)setExcerpt:(NSString *)excerpt
{
    _excerpt = excerpt;
    RTLog(@"%@",excerpt);
    //计算文字的宽高
    //新闻内容
    UITextView *zhengwenTextView = [[UITextView alloc]initWithFrame:CGRectMake(10.0 / 375 * IPHONE_W, 24.0 / 667 * IPHONE_H, IPHONE_W - 20.0 / 375 * IPHONE_W, 50.0 / 667 * IPHONE_H)];
    zhengwenTextView.scrollEnabled = NO;
    zhengwenTextView.editable = NO;
    zhengwenTextView.scrollsToTop = NO;
    NSString *str1 = [_excerpt stringByReplacingOccurrencesOfString:@"\r" withString:@""];
    zhengwenTextView.text = str1;
    zhengwenTextView.font = [UIFont systemFontOfSize:self.titleFontSize];
    NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle alloc]init];
    [paragraphStyle setLineSpacing:8.0];
    [paragraphStyle setAlignment:NSTextAlignmentLeft];
    [paragraphStyle setFirstLineHeadIndent:5.0];
    [paragraphStyle setLineBreakMode:NSLineBreakByCharWrapping];
    [zhengwenTextView sizeToFit];
    if (zhengwenTextView.text.length != 0){
        NSMutableAttributedString *attributedString =  [[NSMutableAttributedString alloc] initWithString:zhengwenTextView.text attributes:@{NSForegroundColorAttributeName : gTextDownload,NSFontAttributeName : [UIFont systemFontOfSize:self.titleFontSize]}];
        [attributedString addAttribute:NSParagraphStyleAttributeName value:paragraphStyle range:NSMakeRange(0, zhengwenTextView.text.length)];
        zhengwenTextView.attributedText = attributedString;
    }
    CGSize size = [zhengwenTextView sizeThatFits:CGSizeMake(zhengwenTextView.frame.size.width, MAXFLOAT)];

    _contentLabelF = CGRectMake(zhengwenTextView.x, zhengwenTextView.y, zhengwenTextView.width, size.height);
    _cellHeight = CGRectGetMaxY(_contentLabelF) + 5;
}
@end
