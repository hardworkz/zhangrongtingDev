//
//  PlayVCCommentTableViewCell.h
//  kuangjiaTingWen
//
//  Created by 泡果 on 2017/5/17.
//  Copyright © 2017年 zhimi. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface PlayVCCommentTableViewCell : UITableViewCell
@property (strong, nonatomic) PlayVCCommentFrameModel *frameModel;

+ (NSString *)ID;

+(PlayVCCommentTableViewCell *)cellWithTableView:(UITableView *)tableView;
@end
