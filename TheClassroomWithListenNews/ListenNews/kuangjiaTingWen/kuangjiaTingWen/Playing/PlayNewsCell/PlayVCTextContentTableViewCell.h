//
//  PlayVCTextContentTableViewCell.h
//  kuangjiaTingWen
//
//  Created by 泡果 on 2017/7/26.
//  Copyright © 2017年 zhimi. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface PlayVCTextContentTableViewCell : UITableViewCell
/**
 正文字体大小
 */
@property(assign,nonatomic)CGFloat titleFontSize;
/**
 日期字体大小
 */
@property(assign,nonatomic)CGFloat dateFont;
@property (strong, nonatomic) NSString *time;/**<时间 */
@property (strong, nonatomic) NSString *post_lai;/**<新闻来源 */

@property (strong, nonatomic) PlayVCTextContentCellFramesModel *frameModel;
+ (PlayVCTextContentTableViewCell *)cellWithTableView:(UITableView *)tableView;
@end
