//
//  UnreadMessageTableViewCell.h
//  kuangjiaTingWen
//
//  Created by Zhimi on 16/11/28.
//  Copyright © 2016年 贺楠. All rights reserved.
//

#import <UIKit/UIKit.h>

static NSString *const UnreadMessageTableViewCellID = @"UnreadMessageTableViewCell";

@interface UnreadMessageTableViewCell : UITableViewCell

- (void)updateCellWithUnreadMessageDic:(NSDictionary *)unreadMessage andPageSource:(NSInteger )pageSource;

@end
