//
//  ClassAuditionTableViewCell.h
//  kuangjiaTingWen
//
//  Created by 泡果 on 2017/6/2.
//  Copyright © 2017年 zhimi. All rights reserved.
//

#import <UIKit/UIKit.h>

@class ClassAuditionCellFrameModel;
@interface ClassAuditionTableViewCell : UITableViewCell

@property (copy, nonatomic) void (^playAudition)(UIButton *button,NSMutableArray *buttons);
@property (assign, nonatomic) NSInteger playingIndex;//当前播放index
@property (strong, nonatomic) ClassAuditionCellFrameModel *frameModel;

@property (nonatomic, strong) NSMutableArray *buttons;
@property (nonatomic, strong) NSMutableArray *titles;
+(ClassAuditionTableViewCell *)cellWithTableView:(UITableView *)tableView;
@end
