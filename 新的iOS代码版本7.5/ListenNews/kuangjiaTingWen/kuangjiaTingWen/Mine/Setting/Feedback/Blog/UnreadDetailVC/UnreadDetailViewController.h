//
//  UnreadDetailViewController.h
//  kuangjiaTingWen
//
//  Created by Zhimi on 16/11/29.
//  Copyright © 2016年 贺楠. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UnreadDetailViewController : UIViewController

@property (strong, nonatomic) NSString *parentid;

@property (strong, nonatomic) NSString *path;

@property (strong, nonatomic) NSString *feedback_id;

@property (assign, nonatomic) NSInteger pageSource;//0:个人主页 1:听友圈  2:意见反馈

@end
