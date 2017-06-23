//
//  ClassViewController.h
//  kuangjiaTingWen
//
//  Created by Zhimi on 17/4/13.
//  Copyright © 2017年 zhimi. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ClassViewController : UIViewController

@property (strong, nonatomic) NSString *act_id;

/**
 单例模式创建

 @return 单例对象
 */
+ (instancetype)shareInstance;
@end
