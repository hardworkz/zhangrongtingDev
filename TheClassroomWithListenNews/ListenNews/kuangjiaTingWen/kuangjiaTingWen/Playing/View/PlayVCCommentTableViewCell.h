//
//  PlayVCCommentTableViewCell.h
//  kuangjiaTingWen
//
//  Created by 泡果 on 2017/5/17.
//  Copyright © 2017年 zhimi. All rights reserved.
//

#import <UIKit/UIKit.h>

@class PinglundianzanCustomBtn;
@interface PlayVCCommentTableViewCell : UITableViewCell
@property (copy, nonatomic) void (^zanClicked)(PinglundianzanCustomBtn *zanButton,PlayVCCommentFrameModel *frameModel);
@property (strong, nonatomic) PlayVCCommentFrameModel *frameModel;
@property (assign, nonatomic) BOOL isClassComment;
@property (assign, nonatomic) BOOL hideZanBtn;
+ (NSString *)ID;

+(PlayVCCommentTableViewCell *)cellWithTableView:(UITableView *)tableView;
@end
