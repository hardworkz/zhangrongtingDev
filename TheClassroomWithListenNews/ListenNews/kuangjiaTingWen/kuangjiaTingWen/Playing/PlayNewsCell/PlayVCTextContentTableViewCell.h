//
//  PlayVCTextContentTableViewCell.h
//  kuangjiaTingWen
//
//  Created by 泡果 on 2017/7/26.
//  Copyright © 2017年 zhimi. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface PlayVCTextContentTableViewCell : UITableViewCell

@property (copy, nonatomic) void (^readOriginalEssay)(UIButton *item);

@property (strong, nonatomic) PlayVCTextContentCellFramesModel *frameModel;

+ (PlayVCTextContentTableViewCell *)cellWithTableView:(UITableView *)tableView;
@end
