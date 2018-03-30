//
//  ContentOffsetYDataModel.h
//  kuangjiaTingWen
//
//  Created by 泡果 on 2017/7/7.
//  Copyright © 2017年 zhimi. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ContentOffsetYDataModel : NSObject
/**
 *  tableView的contentOffsetY的值
 */
@property (nonatomic, assign) CGFloat contentOffsetY;
/**
 *  当前头部view显示高度
 */
@property (nonatomic, assign) CGFloat currentHeaderDisplayHeight;
@end
