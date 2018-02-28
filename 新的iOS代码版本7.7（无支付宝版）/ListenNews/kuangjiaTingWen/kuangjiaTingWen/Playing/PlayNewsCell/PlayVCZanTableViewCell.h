//
//  PlayVCZanTableViewCell.h
//  kuangjiaTingWen
//
//  Created by 泡果 on 2018/2/11.
//  Copyright © 2018年 zhimi. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface PlayVCZanTableViewCell : UITableViewCell

@property (copy, nonatomic) void (^zanBtnClicked)(UIButton *zanBtn);

+(PlayVCZanTableViewCell *)cellWithTableView:(UITableView *)tableView;
@property (assign, nonatomic) BOOL hideDevider;
@property (strong, nonatomic) NSString *zanNum;
@property (strong, nonatomic) NSString *user_zan;
@end
