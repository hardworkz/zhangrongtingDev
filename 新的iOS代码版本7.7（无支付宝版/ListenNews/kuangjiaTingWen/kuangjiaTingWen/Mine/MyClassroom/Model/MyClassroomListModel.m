//
//  MyClassroomListModel.m
//  kuangjiaTingWen
//
//  Created by 泡果 on 2017/6/14.
//  Copyright © 2017年 zhimi. All rights reserved.
//

#import "MyClassroomListModel.h"

@implementation MyClassroomListModel
+ (void)load
{
    [MyClassroomListModel mj_setupReplacedKeyFromPropertyName:^NSDictionary *{
        return @{@"ID":@"id",@"Description":@"description"};
    }];
}
@end
