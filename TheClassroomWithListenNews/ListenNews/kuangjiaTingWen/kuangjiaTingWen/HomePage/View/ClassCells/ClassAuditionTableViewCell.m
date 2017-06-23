//
//  ClassAuditionTableViewCell.m
//  kuangjiaTingWen
//
//  Created by 泡果 on 2017/6/2.
//  Copyright © 2017年 zhimi. All rights reserved.
//

#import "ClassAuditionTableViewCell.h"

@interface ClassAuditionTableViewCell ()
{
    UILabel *auditionLabel;
    UIView *topLine;
    UILabel *CommentLabel;
    UIView *downLine;
    UIView *payTopLine;
}
@end
@implementation ClassAuditionTableViewCell
- (NSMutableArray *)buttons
{
    if (!_buttons)
    {
        _buttons = [NSMutableArray array];
    }
    return _buttons;
}
- (NSMutableArray *)titles
{
    if (!_titles)
    {
        _titles = [NSMutableArray array];
    }
    return _titles;
}
+ (NSString *)ID
{
    return @"ClassAuditionTableViewCell";
}
+(ClassAuditionTableViewCell *)cellWithTableView:(UITableView *)tableView
{
    ClassAuditionTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:[ClassAuditionTableViewCell ID]];
    if (cell == nil) {
        cell = [[ClassAuditionTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:[ClassAuditionTableViewCell ID]];
    }
    return cell;
}
- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        //免费试听
        auditionLabel = [[UILabel alloc]init];
        [auditionLabel setText:@"免费试听"];
        [auditionLabel setTextColor:nTextColorMain];
        [auditionLabel setTextAlignment:NSTextAlignmentLeft];
        [self.contentView addSubview:auditionLabel];
        
        topLine = [[UIView alloc]init];
        topLine.backgroundColor = [UIColor lightGrayColor];
        topLine.alpha = 0.5f;
        [self.contentView addSubview:topLine];
        
        //用户评价
        CommentLabel = [[UILabel alloc]init];
        [CommentLabel setText:@"用户评价"];
        [CommentLabel setTextColor:nTextColorMain];
        [CommentLabel setTextAlignment:NSTextAlignmentLeft];
        [self.contentView addSubview:CommentLabel];
        
        downLine = [[UIView alloc]init];
        downLine.backgroundColor = [UIColor lightGrayColor];
        downLine.alpha = 0.5f;
        [self.contentView addSubview:downLine];
        
        payTopLine = [[UIView alloc]init];
        payTopLine.backgroundColor = [UIColor colorWithRed:0.95 green:0.96 blue:0.98 alpha:1.00];
        payTopLine.alpha = 0.5f;
        [self.contentView addSubview:payTopLine];
        
        for (int i = 0; i<3; i++) {
            UILabel *titleLab = [[UILabel alloc]init];
            titleLab.textAlignment = NSTextAlignmentLeft;
            titleLab.textColor = nTextColorMain;
            titleLab.font = gFontMain14;
            [titleLab setNumberOfLines:0];
            titleLab.lineBreakMode = NSLineBreakByWordWrapping;
            [self.contentView addSubview:titleLab];
            [self.titles addObject:titleLab];
            
            UIButton *playTestMp = [UIButton buttonWithType:UIButtonTypeCustom];
            [playTestMp setImage:[UIImage imageNamed:@"classpause"] forState:UIControlStateNormal];
            [playTestMp setImage:[UIImage imageNamed:@"classplay"] forState:UIControlStateSelected];
            playTestMp.tag = i;
            [playTestMp addTarget:self action:@selector(playTestMp:) forControlEvents:UIControlEventTouchUpInside];
            [self.contentView addSubview:playTestMp];
            [self.buttons addObject:playTestMp];
        }
    }
    return self;
}
- (void)setFrameModel:(ClassAuditionCellFrameModel *)frameModel
{
    _frameModel = frameModel;
    
    if ([frameModel.auditionArray count]) {
        for (int i= 0 ; i < frameModel.auditionArray.count; i++) {
            ClassAuditionListModel *model = frameModel.auditionArray[i];
            //试听标题
            UILabel *titleLab;
            UIButton *playTestMp;
            if (i>self.titles.count-1) {
                titleLab = [[UILabel alloc]init];
                titleLab.textAlignment = NSTextAlignmentLeft;
                titleLab.textColor = nTextColorMain;
                titleLab.font = gFontMain14;
                [titleLab setNumberOfLines:0];
                titleLab.lineBreakMode = NSLineBreakByWordWrapping;
                [self.contentView addSubview:titleLab];
                [self.titles addObject:titleLab];
                
                playTestMp = [UIButton buttonWithType:UIButtonTypeCustom];
                [playTestMp setImage:[UIImage imageNamed:@"classpause"] forState:UIControlStateNormal];
                [playTestMp setImage:[UIImage imageNamed:@"classplay"] forState:UIControlStateSelected];
                playTestMp.tag = i;
                [self.buttons addObject:playTestMp];
                [playTestMp addTarget:self action:@selector(playTestMp:) forControlEvents:UIControlEventTouchUpInside];
                [self.contentView addSubview:playTestMp];
            }else{
                titleLab = self.titles[i];
                playTestMp = self.buttons[i];
            }
            if (_playingIndex == i) {
                playTestMp.selected = YES;
            }
            
            titleLab.text = model.s_title;
            titleLab.frame = [frameModel.titlesFrameArray[i] CGRectValue];
            [playTestMp setFrame:[frameModel.buttonsFrameArray[i] CGRectValue]];
        }
    }
    for (int i = 0; i<self.buttons.count; i++) {
        UILabel *titleLab;
        UIButton *playTestMp;
        titleLab = self.titles[i];
        playTestMp = self.buttons[i];
        if (i<frameModel.auditionArray.count) {
            titleLab.hidden = NO;
            playTestMp.hidden = NO;
        }else{
            titleLab.hidden = YES;
            playTestMp.hidden = YES;
        }
    }
    auditionLabel.frame = frameModel.auditionLabelF;
    topLine.frame = frameModel.topLineF;
    CommentLabel.frame = frameModel.CommentLabelF;
    downLine.frame = frameModel.downLineF;
    
    payTopLine.frame = frameModel.payTopLineF;
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
    
    CGRect rect  = [string boundingRectWithSize:CGSizeMake(width, MAXFLOAT)
                                        options: NSStringDrawingUsesFontLeading |NSStringDrawingUsesLineFragmentOrigin
                                     attributes:@{NSFontAttributeName:fontSize}
                                        context:nil];
    return ceil(rect.size.height);
}
- (void)playTestMp:(UIButton *)button
{
    if (self.playAudition) {
        self.playAudition(button, self.buttons);
    }
}
- (void)dealloc
{
    RTLog(@"dealloc");
}
@end
