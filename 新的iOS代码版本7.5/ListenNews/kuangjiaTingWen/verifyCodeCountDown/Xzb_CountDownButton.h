//
//  Xzb_CountDownButton.h
//  xzb
//
//  Created by 张荣廷 on 16/9/8.
//  Copyright © 2016年 xuwk. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface Xzb_CountDownButton : UIButton
/**
 *  倒计时时间
 */
@property (nonatomic,assign)  NSInteger index;
/**
 *  启动倒计时
 */
- (void)attAction;
@end
