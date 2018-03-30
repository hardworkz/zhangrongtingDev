//
//  ClassAuditionCellFrameModel.h
//  kuangjiaTingWen
//
//  Created by 泡果 on 2017/6/2.
//  Copyright © 2017年 zhimi. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ClassAuditionCellFrameModel : NSObject

@property (strong, nonatomic) NSArray *auditionArray;

@property (assign, nonatomic) CGRect auditionLabelF;
@property (assign, nonatomic) CGRect topLineF;
@property (assign, nonatomic) CGRect CommentLabelF;
@property (assign, nonatomic) CGRect downLineF;
@property (assign, nonatomic) CGRect payTopLineF;
@property (strong, nonatomic) NSMutableArray *titlesFrameArray;
@property (strong, nonatomic) NSMutableArray *buttonsFrameArray;
@property (assign, nonatomic) CGFloat cellHeight;
@end
