//
//  RecommendClassFrameModel.h
//  kuangjiaTingWen
//
//  Created by 泡果 on 2018/2/28.
//  Copyright © 2018年 zhimi. All rights reserved.
//

#import <Foundation/Foundation.h>

@class RecommendClassModel;
@interface RecommendClassFrameModel : NSObject

@property (strong, nonatomic) RecommendClassModel *model;

@property (assign, nonatomic) CGRect imgLeftF;
@property (assign, nonatomic) CGRect titleLabF;
@property (assign, nonatomic) CGRect labelF;
@property (assign, nonatomic) CGRect lineF;
@property (assign, nonatomic) CGFloat cellHeight;
@end
