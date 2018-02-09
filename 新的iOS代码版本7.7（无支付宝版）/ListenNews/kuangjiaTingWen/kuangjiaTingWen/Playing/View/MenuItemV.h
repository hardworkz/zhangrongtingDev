//
//  MenuItemV.h
//  CommunityCourier
//
//  Created by 陈聪豪 on 16/6/12.
//  Copyright © 2016年 diyuanxinxi.com. All rights reserved.
//

#import <UIKit/UIKit.h>
typedef void (^chooseBtnBlock)(NSInteger);

@interface MenuItemV : UIView

@property(nonatomic, copy)chooseBtnBlock otherItemBlock; //功能区按钮事件代码块
/**
 *  生成功能区
 *
 *  @param frame    大小
 *  @param titleArr 标题
 *  @param imgArr   图片
 *  @param num      一行几个
 *
 *  @return 视图
 */
-(instancetype)initWithFrame:(CGRect)frame andTitleArr:(NSMutableArray *)titleArr andImgArr:(NSMutableArray *)imgArr andLineNum:(NSInteger)num;
@end
