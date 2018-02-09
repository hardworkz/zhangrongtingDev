//
//  titleImageVC.h
//  reHeardTheNews
//
//  Created by Pop Web on 16/3/17.
//  Copyright © 2016年 paoguo. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface titleImageVC : UIViewController

@property (copy, nonatomic) void (^updateSignature)(NSString *signature);
@end
