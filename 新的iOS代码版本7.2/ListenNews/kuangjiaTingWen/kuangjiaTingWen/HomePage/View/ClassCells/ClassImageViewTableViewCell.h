//
//  ClassImageViewTableViewCell.h
//  kuangjiaTingWen
//
//  Created by 泡果 on 2017/6/2.
//  Copyright © 2017年 zhimi. All rights reserved.
//

#import <UIKit/UIKit.h>

@class ClassImageViewCellFrameModel;
@interface ClassImageViewTableViewCell : UITableViewCell

@property (copy, nonatomic) void (^tapImage)(UITapGestureRecognizer *tap);

@property (strong, nonatomic) ClassImageViewCellFrameModel *frameModel;
+(ClassImageViewTableViewCell *)cellWithTableView:(UITableView *)tableView;
@end
