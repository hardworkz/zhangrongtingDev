//
//  ClassAuditionCellFrameModel.m
//  kuangjiaTingWen
//
//  Created by 泡果 on 2017/6/2.
//  Copyright © 2017年 zhimi. All rights reserved.
//

#import "ClassAuditionCellFrameModel.h"

@implementation ClassAuditionCellFrameModel
- (NSMutableArray *)titlesFrameArray
{
    if (!_titlesFrameArray)
    {
        _titlesFrameArray = [NSMutableArray array];
    }
    return _titlesFrameArray;
}
- (NSMutableArray *)buttonsFrameArray
{
    if (!_buttonsFrameArray)
    {
        _buttonsFrameArray = [NSMutableArray array];
    }
    return _buttonsFrameArray;
}

- (void)setAuditionArray:(NSArray *)auditionArray
{
    _auditionArray = auditionArray;
    //计算frame
    _auditionLabelF = CGRectMake(10,10.0 / 667 * IPHONE_H,SCREEN_WIDTH - 10, 30);
    
    _topLineF = CGRectMake(0, CGRectGetMaxY(_auditionLabelF), IPHONE_W, 1);
    
    CGFloat ShitingContentHeight = 0;
    if ([_auditionArray count]) {
        for (int i= 0 ; i < _auditionArray.count; i++) {
            ClassAuditionListModel *model = _auditionArray[i];
            //试听标题
            CGRect titleLabF = CGRectMake(20.0 / 375 * IPHONE_W,CGRectGetMaxY(_topLineF) + ShitingContentHeight + 10.0 / 667 * SCREEN_HEIGHT, IPHONE_W - 70.0 / 375 * IPHONE_W, 40.0 / 667 * IPHONE_H);
            CGRect playTestMpF = CGRectMake(SCREEN_WIDTH - 50.0 / 375 * SCREEN_WIDTH, titleLabF.origin.y, 40, 40);
            
            CGFloat titleHight = [self computeTextHeightWithString:model.s_title andWidth:(SCREEN_WIDTH- 60.0 / 375 * IPHONE_W) andFontSize:gFontMain14];
            ShitingContentHeight += titleHight + 20.0 / 667 * SCREEN_HEIGHT;
            
            [self.titlesFrameArray addObject:[NSValue valueWithCGRect:titleLabF]];
            [self.buttonsFrameArray addObject:[NSValue valueWithCGRect:playTestMpF]];
        }
    }

    _CommentLabelF = CGRectMake(10, CGRectGetMaxY(_topLineF) + ShitingContentHeight + 20.0 / 667 * SCREEN_HEIGHT,SCREEN_WIDTH - 10, 30);
    _downLineF = CGRectMake(0, CGRectGetMaxY(_CommentLabelF), IPHONE_W, 1);
    _payTopLineF = CGRectMake(0, CGRectGetMaxY(_downLineF) , IPHONE_W, 5);
    
    _cellHeight = CGRectGetMaxY(_payTopLineF);
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

@end
