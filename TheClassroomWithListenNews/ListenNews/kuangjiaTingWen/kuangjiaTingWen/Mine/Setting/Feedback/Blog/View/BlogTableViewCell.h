//
//  BlogTableViewCell.h
//  Broker
//
//  Created by Eric Wang on 15/10/11.
//  Copyright (c) 2015年 Eric. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MultiImageView.h"
#import "TTTAttributedLabel.h"

static NSString *const BlogTableViewCellID = @"BlogTableViewCell";

typedef void (^addFavBlock)(NSInteger );

@interface BlogTableViewCell : UITableViewCell

@property (copy, nonatomic) void (^addFav)(BlogTableViewCell *cell,int iszan);
@property (copy, nonatomic) void (^addComment)(BlogTableViewCell *cell);
@property (copy, nonatomic) void (^deleteBlog)(BlogTableViewCell *cell);
@property (copy, nonatomic) void (^clickHeadView)(BlogTableViewCell *cell);
@property (copy, nonatomic) void (^longPressHeadView)(BlogTableViewCell *cell);
@property (copy, nonatomic) void (^playVoice)(BlogTableViewCell *cell);
@property (copy, nonatomic) void (^updateVoiceAnimate)(BlogTableViewCell *cell);

@property (copy, nonatomic) addFavBlock addFavorite;

@property (weak, nonatomic) IBOutlet TTTAttributedLabel *nameLabe;
@property (weak, nonatomic) IBOutlet TTTAttributedLabel *commentLabel;
@property (weak, nonatomic) IBOutlet MultiImageView *photosImageView;
@property (weak, nonatomic) IBOutlet UIButton *praiseButton;
@property (weak, nonatomic) IBOutlet UIButton *voiceButton;

- (void)updateCellWithBlog:(NSMutableDictionary *)blog andisFeebackBlog:(BOOL )isFeebackBlog andisUnreadMessage:(BOOL )isUnreadMessage;


@end
