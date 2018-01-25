//
//  MyClassroomListFrameModel.m
//  kuangjiaTingWen
//
//  Created by 泡果 on 2017/6/14.
//  Copyright © 2017年 zhimi. All rights reserved.
//

#import "MyClassroomListFrameModel.h"

@implementation MyClassroomListFrameModel
- (void)setModel:(MyClassroomListModel *)model
{
    _model = model;
    if (IS_IPAD) {
        _imgLeftF = CGRectMake(15.0 / 375 * IPHONE_W, 15, 105.0 / 375 * IPHONE_W, 70.0 / 375 *IPHONE_W);
    }else{
        _imgLeftF = CGRectMake(15.0 / 375 * IPHONE_W, 15, 105.0 / 375 * IPHONE_W, 105.0 / 375 *IPHONE_W);
    }
    CGSize titleSize = [model.name boundingRectWithSize:CGSizeMake(SCREEN_WIDTH - CGRectGetMaxX(_imgLeftF) - 70.0 / 375 * IPHONE_W, MAXFLOAT) options:NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName:CUSTOM_FONT_TYPE(16.0)} context:nil].size;
    _titleLabF = CGRectMake(CGRectGetMaxX(_imgLeftF) + 5.0 / 375 * IPHONE_W, _imgLeftF.origin.y,  SCREEN_WIDTH - CGRectGetMaxX(_imgLeftF) - 70.0 / 375 * IPHONE_W, titleSize.height);
    _priceF = CGRectMake(CGRectGetMaxX(_titleLabF) + 10, _titleLabF.origin.y,40.0 / 375 * IPHONE_W, 21.0 / 667 *IPHONE_H);
    
    CGSize describeSize = [model.Description boundingRectWithSize:CGSizeMake(SCREEN_WIDTH - CGRectGetMaxX(_imgLeftF) - 20.0 / 375 * IPHONE_W, MAXFLOAT) options:NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName:CUSTOM_FONT_TYPE(14.0)} context:nil].size;
//    RTLog(@"%f",CGRectGetMaxY(_imgLeftF));
    _describeF = CGRectMake(_titleLabF.origin.x, CGRectGetMaxY(_imgLeftF) - (describeSize.height), SCREEN_WIDTH - CGRectGetMaxX(_imgLeftF) - 20.0 / 375 * IPHONE_W, describeSize.height);
    
    _lineF = CGRectMake(20.0 / 375 * SCREEN_WIDTH, CGRectGetMaxY(_imgLeftF) + 15, SCREEN_WIDTH - 40.0 / 375 * SCREEN_WIDTH, 0.5);
    
    _cellHeight = CGRectGetMaxY(_lineF);
}
@end
