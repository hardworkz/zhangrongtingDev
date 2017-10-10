//
//  CommentAndReviewFrameModel.h
//  kuangjiaTingWen
//
//  Created by 泡果 on 2017/5/15.
//  Copyright © 2017年 zhimi. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface CommentAndReviewFrameModel : NSObject
@property (strong, nonatomic) child_commentModel *model;

@property (nonatomic,assign)  CGRect replyManF;
@property (nonatomic,assign)  CGRect beReplyManF;
@property (nonatomic,assign)  CGRect contentLabelF;
@property (nonatomic,assign)  CGRect labelF;
@property (nonatomic,strong) NSString *content;
@property (nonatomic,assign)  CGFloat cellHeight;
@end
