//
//  zhuboXiangQingTabelView.h
//  reHeardTheNews
//
//  Created by 贺楠 on 16/5/27.
//  Copyright © 2016年 paoguo. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface zhuboXiangQingTabelView : UITableViewController
@property (nonatomic ) NSInteger itemNum;
@property (nonatomic ) NSInteger page;
@property (nonatomic) BOOL isNeedRefresh;
@property (nonatomic) NSString *jiemuID;
@end
