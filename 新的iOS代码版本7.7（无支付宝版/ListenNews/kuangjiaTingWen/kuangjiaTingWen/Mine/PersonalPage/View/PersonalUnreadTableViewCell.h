//
//  PersonalUnreadTableViewCell.h
//  kuangjiaTingWen
//
//  Created by Zhimi on 16/12/19.
//  Copyright © 2016年 贺楠. All rights reserved.
//

#import <UIKit/UIKit.h>

static NSString *const PersonalUnreadTableViewCellID = @"PersonalUnreadTableViewCell";

@interface PersonalUnreadTableViewCell : UITableViewCell

- (void)updateCellWithUnreadMessageDic:(NSDictionary *)unreadMessage;

@end
