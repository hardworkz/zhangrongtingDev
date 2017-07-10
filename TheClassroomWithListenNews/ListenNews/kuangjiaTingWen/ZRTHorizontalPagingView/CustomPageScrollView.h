//
//  CustomPageScrollView.h
//  kuangjiaTingWen
//
//  Created by 泡果 on 2017/7/7.
//  Copyright © 2017年 zhimi. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ContentOffsetYDataModel.h"

@interface CustomPageScrollView : UITableView
/**
 保存tableview滚动数据的模型
 */
@property (strong, nonatomic) ContentOffsetYDataModel *dataModel;
@end
