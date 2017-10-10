//
//  MyClassroomListFrameModel.h
//  kuangjiaTingWen
//
//  Created by 泡果 on 2017/6/14.
//  Copyright © 2017年 zhimi. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface MyClassroomListFrameModel : NSObject
@property (strong, nonatomic) MyClassroomListModel *model;

@property (assign, nonatomic) CGRect imgLeftF;
@property (assign, nonatomic) CGRect titleLabF;
@property (assign, nonatomic) CGRect priceF;
@property (assign, nonatomic) CGRect describeF;
@property (assign, nonatomic) CGRect lineF;
@property (assign, nonatomic) CGFloat cellHeight;
@end
