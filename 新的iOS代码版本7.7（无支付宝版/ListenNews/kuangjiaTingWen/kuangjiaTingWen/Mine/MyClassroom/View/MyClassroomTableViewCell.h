//
//  MyClassroomTableViewCell.h
//  kuangjiaTingWen
//
//  Created by 泡果 on 2017/6/14.
//  Copyright © 2017年 zhimi. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface MyClassroomTableViewCell : UITableViewCell
@property (assign, nonatomic) BOOL hiddenPrice;
@property (assign, nonatomic) BOOL hiddenDevider;
@property (assign, nonatomic) BOOL isRecommended;
@property (strong, nonatomic) MyClassroomListFrameModel *frameModel;
+(MyClassroomTableViewCell *)cellWithTableView:(UITableView *)tableView;
@end
