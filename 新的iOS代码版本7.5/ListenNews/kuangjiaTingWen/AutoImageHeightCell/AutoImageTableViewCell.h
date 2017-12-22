//
//  AutoImageTableViewCell.h
//  JiDing
//
//  Created by zhangrongting on 2017/6/17.
//  Copyright © 2017年 zhangrongting. All rights reserved.
//

#import <UIKit/UIKit.h>

@class AutoImageViewHeightFrameModel;
@interface AutoImageTableViewCell : UITableViewCell
/**
 图片控件点击回调block，在cellForRow方法中使用YJImageBrowserView进行单张图片显示
 */
@property (copy, nonatomic) void (^tapImage)(UITapGestureRecognizer *tap);
/**
 图片的frame模型
 */
@property (strong, nonatomic) AutoImageViewHeightFrameModel *frameModel;
/**
 *  cell对象的创建类方法
 *
 *  @param tableView tableView
 *
 *  @return AutoImageTableViewCell
 */
+(AutoImageTableViewCell *)cellWithTableView:(UITableView *)tableView;

@end
