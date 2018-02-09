//
//  ClassContentCellFrameModel.h
//  kuangjiaTingWen
//
//  Created by 泡果 on 2017/6/2.
//  Copyright © 2017年 zhimi. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ClassContentCellFrameModel : NSObject
/**
 正文字体大小
 */
@property(assign,nonatomic)CGFloat titleFontSize;
@property (strong, nonatomic) NSString *excerpt;/**<正文内容 */
@property (assign, nonatomic) CGRect contentLabelF;
@property (assign, nonatomic) CGFloat cellHeight;
@end
