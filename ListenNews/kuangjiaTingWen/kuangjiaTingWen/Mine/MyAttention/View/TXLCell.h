//
//  TXLCell.h
//  Heard the news
//
//  Created by 温仲斌 on 15/12/2.
//  Copyright © 2015年 泡果网络. All rights reserved.
//

#import <UIKit/UIKit.h>
IB_DESIGNABLE
@class UserClass;
@interface TXLCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UILabel *nameL;
@property (weak, nonatomic) IBOutlet UIButton *button;
@property (nonatomic) IBInspectable CGFloat cornerRadius;

@property (copy, nonatomic) void (^inviteFriend)(TXLCell *cell,NSString *user_phone,NSString *user_nickname);

- (void)setData:(UserClass *)userObject;

@end
