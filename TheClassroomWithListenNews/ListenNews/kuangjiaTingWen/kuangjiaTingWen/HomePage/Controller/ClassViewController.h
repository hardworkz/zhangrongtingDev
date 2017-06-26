//
//  ClassViewController.h
//  kuangjiaTingWen
//
//  Created by Zhimi on 17/4/13.
//  Copyright © 2017年 zhimi. All rights reserved.
//

#import <UIKit/UIKit.h>

@class ClassModel;
@interface ClassViewController : UIViewController
/**
 课堂ID
 */
@property (strong, nonatomic) NSString *act_id;
/**
 标题字体大小
 */
@property(assign,nonatomic)CGFloat titleFontSize;
/*
 * 设置frameArray数组
 */
- (NSMutableArray *)frameArrayWithClassModel:(ClassModel *)classModel;
/**
 当前页面tableview
 */
@property (nonatomic, strong) UITableView *helpTableView;
/**
 试听课堂是否播放
 */
@property (assign, nonatomic) BOOL isPlaying;
/**
 单例模式创建

 @return 单例对象
 */
+ (instancetype)shareInstance;
@end
