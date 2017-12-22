//
//  PlayVCCommentTableViewCell.h
//  kuangjiaTingWen
//
//  Created by 泡果 on 2017/5/17.
//  Copyright © 2017年 zhimi. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef NS_ENUM(NSInteger, CommentCellType) {
    CommentCellTypeNewsDetail = 0,//新闻详情评论cell
    CommentCellTypeClassroom,//课堂试听界面评论cell
    CommentCellTypeAchorCommentList,//主播或者频道详情评论cell
};
@class PinglundianzanCustomBtn;
@interface PlayVCCommentTableViewCell : UITableViewCell
@property (copy, nonatomic) void (^zanClicked)(PinglundianzanCustomBtn *zanButton,PlayVCCommentFrameModel *frameModel);
@property (copy, nonatomic) void (^achorVCZanClicked)(PinglundianzanCustomBtn *zanButton,PlayVCCommentFrameModel *frameModel);
@property (strong, nonatomic) PlayVCCommentFrameModel *frameModel;
@property (assign, nonatomic) CommentCellType commentCellType;
@property (assign, nonatomic) BOOL hideZanBtn;
+ (NSString *)ID;

+(PlayVCCommentTableViewCell *)cellWithTableView:(UITableView *)tableView;
@end
