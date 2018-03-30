//
//  RecommendClassFrameModel.m
//  kuangjiaTingWen
//
//  Created by 泡果 on 2018/2/28.
//  Copyright © 2018年 zhimi. All rights reserved.
//

#import "RecommendClassFrameModel.h"

@implementation RecommendClassFrameModel
- (void)setModel:(RecommendClassModel *)model
{
    _model = model;
    if (IS_IPAD) {
        _imgLeftF = CGRectMake(SCREEN_WIDTH - 120.0 / 375 * IPHONE_W, 15, 105.0 / 375 * IPHONE_W, 70.0 / 375 *IPHONE_W);
    }else{
        _imgLeftF = CGRectMake(SCREEN_WIDTH - 120.0 / 375 * IPHONE_W, 15, 105.0 / 375 * IPHONE_W, 105.0 / 375 *IPHONE_W);
    }
    CGSize titleSize = [model.name boundingRectWithSize:CGSizeMake(SCREEN_WIDTH -  - _imgLeftF.size.width - 45.0 / 375 * IPHONE_W , MAXFLOAT) options:NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName:CUSTOM_FONT_TYPE(16.0)} context:nil].size;
    _titleLabF = CGRectMake(15.0 / 375 * IPHONE_W, _imgLeftF.origin.y, titleSize.width, titleSize.height);
    
    _labelF = CGRectMake(15.0 / 375 * SCREEN_WIDTH, CGRectGetMaxY(_imgLeftF) - 20, 40, 20);
    
    _lineF = CGRectMake(20.0 / 375 * SCREEN_WIDTH, CGRectGetMaxY(_imgLeftF) + 15, SCREEN_WIDTH - 40.0 / 375 * SCREEN_WIDTH, 0.5);
    
    _cellHeight = CGRectGetMaxY(_lineF);
}
@end
