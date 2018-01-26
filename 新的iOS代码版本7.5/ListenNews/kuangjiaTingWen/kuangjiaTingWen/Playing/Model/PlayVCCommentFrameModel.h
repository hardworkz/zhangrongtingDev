//
//  PlayVCCommentFrameModel.h
//  kuangjiaTingWen
//
//  Created by 泡果 on 2017/5/17.
//  Copyright © 2017年 zhimi. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface PlayVCCommentFrameModel : NSObject
@property (strong, nonatomic) PlayVCCommentModel *model;

@property (assign, nonatomic) CGRect pinglunImgF;
@property (assign, nonatomic) CGRect pinglunTitleF;
@property (assign, nonatomic) CGRect pinglunshijianF;
@property (assign, nonatomic) CGRect pinglunLabF;
@property (assign, nonatomic) CGRect pingLundianzanBtnF;
@property (assign, nonatomic) CGRect pingLundianzanNumLabF;
@property (assign, nonatomic) CGRect commenterF;
@property (assign, nonatomic) CGRect contentF;
@property (assign, nonatomic) CGRect deviderF;
@property (assign, nonatomic) CGRect topDeviderF;
@property (assign, nonatomic) CGFloat cellHeight;

@property (strong, nonatomic) NSString *content;
@end
