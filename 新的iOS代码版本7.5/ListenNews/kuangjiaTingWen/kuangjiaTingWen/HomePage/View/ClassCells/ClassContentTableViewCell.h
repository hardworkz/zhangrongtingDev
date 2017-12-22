//
//  ClassContentTableViewCell.h
//  kuangjiaTingWen
//
//  Created by 泡果 on 2017/6/2.
//  Copyright © 2017年 zhimi. All rights reserved.
//

#import <UIKit/UIKit.h>

@class ClassContentCellFrameModel;
@interface ClassContentTableViewCell : UITableViewCell
/**
 正文字体大小
 */
@property(assign,nonatomic)CGFloat titleFontSize;

@property (strong, nonatomic) ClassContentCellFrameModel *frameModel;
+(ClassContentTableViewCell *)cellWithTableView:(UITableView *)tableView;
@end
