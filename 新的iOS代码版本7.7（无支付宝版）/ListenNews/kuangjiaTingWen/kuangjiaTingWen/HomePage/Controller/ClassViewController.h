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

@property(nonatomic)NSString *jiemuID;
@property(nonatomic)NSString *jiemuName;
@property(nonatomic)NSString *jiemuDescription;
@property(nonatomic)NSString *jiemuImages;
@property(nonatomic)NSString *jiemuFan_num;
@property(nonatomic)NSString *jiemuMessage_num;
@property(nonatomic)NSString *jiemuIs_fan;
/**
 隐藏购买按钮
 */
@property (assign, nonatomic) BOOL hidePayBtn;
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

@property (strong, nonatomic) UIViewController *listVC;/**<外层列表页面控制器*/
/**
 单例模式创建

 @return 单例对象
 */
+ (instancetype)shareInstance;
@end
