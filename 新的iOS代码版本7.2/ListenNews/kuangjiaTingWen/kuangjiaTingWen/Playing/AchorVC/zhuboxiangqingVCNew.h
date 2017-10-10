//
//  zhuboxiangqingVCNew.h
//  reHeardTheNews
//
//  Created by 贺楠 on 16/5/27.
//  Copyright © 2016年 paoguo. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface zhuboxiangqingVCNew : UIViewController
@property(nonatomic)NSString *jiemuID;
@property(nonatomic)NSString *jiemuName;
@property(nonatomic)NSString *jiemuDescription;
@property(nonatomic)NSString *jiemuImages;
@property(nonatomic)NSString *jiemuFan_num;
@property(nonatomic)NSString *jiemuMessage_num;
@property(nonatomic)NSString *jiemuIs_fan;

//@property(nonatomic)NSString *act_table;
@property(nonatomic)BOOL isClass;/**<是否为课堂详情*/
@property(nonatomic)BOOL isbofangye;/**<是否从播放器进入主播详情*/
@property(nonatomic)BOOL isfaxian;/**<是否从发现页面进入*/
@end
