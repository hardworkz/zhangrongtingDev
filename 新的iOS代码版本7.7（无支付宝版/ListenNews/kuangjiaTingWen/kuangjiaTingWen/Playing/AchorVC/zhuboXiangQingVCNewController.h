//
//  zhuboXiangQingVCNewController.h
//  kuangjiaTingWen
//
//  Created by 泡果 on 2017/6/16.
//  Copyright © 2017年 zhimi. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface zhuboXiangQingVCNewController : UIViewController

@property(nonatomic)NSString *jiemuID;
@property(nonatomic)NSString *jiemuName;
@property(nonatomic)NSString *jiemuDescription;
@property(nonatomic)NSString *jiemuImages;
@property(nonatomic)NSString *jiemuFan_num;
@property(nonatomic)NSString *jiemuMessage_num;
@property(nonatomic)NSString *jiemuIs_fan;
/**
 <p><img src="http://admin.tingwen.me/data/upload/ueditor/20170302/58b79cdd44006.JPG" title="crop_579eb4995b499.JPG" alt="crop_579eb4995b499.JPG"/></p>
 */
@property(nonatomic)NSString *post_content;

//@property(nonatomic)NSString *act_table;
@property(nonatomic)BOOL isClass;/**<是否为课堂详情*/
@property(nonatomic)BOOL isbofangye;/**<是否从播放器进入主播详情*/
@property(nonatomic)BOOL isfaxian;/**<是否从发现页面进入*/

@property (strong, nonatomic) UIViewController *listVC;/**<外层列表页面控制器*/
@end
