//
//  PlayVCTextContentCellFramesModel.h
//  kuangjiaTingWen
//
//  Created by 泡果 on 2017/7/26.
//  Copyright © 2017年 zhimi. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface PlayVCTextContentCellFramesModel : NSObject
/**
 正文字体大小
 */
@property(assign,nonatomic)CGFloat titleFontSize;
/**
 日期字体大小
 */
@property(assign,nonatomic)CGFloat dateFont;

@property (strong, nonatomic) NSString *title;/**<标题内容 */
@property (strong, nonatomic) NSString *timeString;/**<日期字符串 */
@property (strong, nonatomic) NSString *excerpt;/**<正文内容 */
@property (assign, nonatomic) CGRect titleLabelF;
@property (assign, nonatomic) CGRect timeLabelF;
@property (assign, nonatomic) CGRect contentLabelF;
@property (assign, nonatomic) CGFloat cellHeight;
@end
