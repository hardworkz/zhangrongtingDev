//
//  BlobNewTableViewCell.h
//  kuangjiaTingWen
//
//  Created by 泡果 on 2017/5/12.
//  Copyright © 2017年 zhimi. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef void (^addFavBlock)(NSInteger );

@class MultiImageView,TTTAttributedLabel,CommentAndReviewTableViewCell;
@interface BlobNewTableViewCell : UITableViewCell
@property (copy, nonatomic) void (^addFav)(BlobNewTableViewCell *cell,int iszan);
@property (copy, nonatomic) void (^addComment)(BlobNewTableViewCell *cell);
@property (copy, nonatomic) void (^addReview)(BlobNewTableViewCell *cell,child_commentModel *model);
@property (copy, nonatomic) void (^deleteBlog)(BlobNewTableViewCell *cell);
@property (copy, nonatomic) void (^clickHeadView)(BlobNewTableViewCell *cell);
@property (copy, nonatomic) void (^longPressHeadView)(BlobNewTableViewCell *cell);
@property (copy, nonatomic) void (^playVoice)(BlobNewTableViewCell *cell);
@property (copy, nonatomic) void (^updateVoiceAnimate)(BlobNewTableViewCell *cell);
@property (copy, nonatomic) void (^deleteComment)(BlobNewTableViewCell *cell,NSInteger indexRow,NSInteger commentIndexRow);

@property (copy, nonatomic) addFavBlock addFavorite;

@property (strong, nonatomic) FeedBackAndListenFriendFrameModel *frameModel;

@property (strong, nonatomic) UILabel *nameLabe;
@property (strong, nonatomic) MultiImageView *photosImageView;
@property (weak, nonatomic) UIButton *praiseButton;
@property (weak, nonatomic) UILabel *favLabel;
@property (weak, nonatomic) UIButton *voiceButton;

@property (assign, nonatomic) BOOL isFeebackBlog;
@property (assign, nonatomic) BOOL isUnreadMessage;

@property (assign, nonatomic) NSInteger indexRow;
@property (assign, nonatomic) NSInteger commentIndexRow;

+ (NSString *)ID;
+(BlobNewTableViewCell *)cellWithTableView:(UITableView *)tableView;
//点赞动画
- (void)addOneAnimation;
@end
