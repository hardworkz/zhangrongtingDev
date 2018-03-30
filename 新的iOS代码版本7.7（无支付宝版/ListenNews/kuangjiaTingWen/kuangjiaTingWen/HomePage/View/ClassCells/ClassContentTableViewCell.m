//
//  ClassContentTableViewCell.m
//  kuangjiaTingWen
//
//  Created by 泡果 on 2017/6/2.
//  Copyright © 2017年 zhimi. All rights reserved.
//

#import "ClassContentTableViewCell.h"

@interface ClassContentTableViewCell()
{
    UITextView *zhengwenTextView;
}
@end
@implementation ClassContentTableViewCell
+ (NSString *)ID
{
    return @"ClassContentTableViewCell";
}
+(ClassContentTableViewCell *)cellWithTableView:(UITableView *)tableView
{
    ClassContentTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:[ClassContentTableViewCell ID]];
    if (cell == nil) {
        cell = [[ClassContentTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:[ClassContentTableViewCell ID]];
    }
    return cell;
}
- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        //新闻内容
        zhengwenTextView = [[UITextView alloc]initWithFrame:CGRectMake(20.0 / 375 * IPHONE_W, 0 + 24.0 / 667 * IPHONE_H, IPHONE_W - 40.0 / 375 * IPHONE_W, 50.0 / 667 * IPHONE_H)];
        zhengwenTextView.scrollEnabled = NO;
        zhengwenTextView.editable = NO;
        zhengwenTextView.scrollsToTop = NO;
        [self.contentView addSubview:zhengwenTextView];

    }
    return self;
}
- (void)setFrameModel:(ClassContentCellFrameModel *)frameModel
{
    _frameModel = frameModel;
    //设置文本内容和frame
    NSString *str1 = [frameModel.excerpt stringByReplacingOccurrencesOfString:@"\r" withString:@""];
    zhengwenTextView.text = str1;
    zhengwenTextView.font = [UIFont systemFontOfSize:self.titleFontSize];
    NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle alloc]init];
    [paragraphStyle setLineSpacing:8.0];
    [paragraphStyle setAlignment:NSTextAlignmentLeft];
    [paragraphStyle setFirstLineHeadIndent:5.0];
    [paragraphStyle setLineBreakMode:NSLineBreakByCharWrapping];
    [zhengwenTextView sizeToFit];
    if (zhengwenTextView.text.length != 0){
        NSMutableAttributedString *attributedString =  [[NSMutableAttributedString alloc] initWithString:zhengwenTextView.text attributes:@{NSForegroundColorAttributeName : HEXCOLOR(0x505050),NSFontAttributeName : [UIFont systemFontOfSize:self.titleFontSize]}];
        [attributedString addAttribute:NSParagraphStyleAttributeName value:paragraphStyle range:NSMakeRange(0, zhengwenTextView.text.length)];
        zhengwenTextView.attributedText = attributedString;
    }
    zhengwenTextView.frame = frameModel.contentLabelF;
}
@end
