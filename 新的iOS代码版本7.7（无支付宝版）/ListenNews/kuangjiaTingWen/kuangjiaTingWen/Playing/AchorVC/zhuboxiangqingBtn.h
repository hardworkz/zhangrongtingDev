//
//  zhuboxiangqingBtn.h
//  kuangjiaTingWen
//
//  Created by 贺楠 on 16/7/6.
//  Copyright © 2016年 贺楠. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface zhuboxiangqingBtn : UIButton
@property (assign, nonatomic) BOOL isClass;
- (instancetype)initWithImage:(UIImage *)image andTitle:(NSString *)title;

- (void)ChangeBlueToBlack:(UIImage *)image;
- (void)ChangeBlackToBlue:(UIImage *)image;
@end
