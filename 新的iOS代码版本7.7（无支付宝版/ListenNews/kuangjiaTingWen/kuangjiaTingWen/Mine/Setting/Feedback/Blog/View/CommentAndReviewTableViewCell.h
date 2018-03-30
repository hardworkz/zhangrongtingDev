//
//  CommentAndReviewTableViewCell.h
//  kuangjiaTingWen
//
//  Created by 泡果 on 2017/5/15.
//  Copyright © 2017年 zhimi. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CommentAndReviewTableViewCell : UITableViewCell
@property (strong, nonatomic) CommentAndReviewFrameModel *frameModel;

@property (copy, nonatomic) void (^clickRowCellWithReview)(CommentAndReviewTableViewCell *cell,child_commentModel *model);

+(CommentAndReviewTableViewCell *)cellWithTableView:(UITableView *)tableView;
+ (NSString *)ID;
@end
