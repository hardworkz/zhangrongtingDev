//
//  GZ_Cell.h
//  Heard the news
//
//  Created by Pop Web on 15/8/27.
//  Copyright (c) 2015年 泡果网络. All rights reserved.
//

#import <UIKit/UIKit.h>

@class UserClass,ZhuBoClass,XWAddView;

@interface GZ_Cell : UITableViewCell

@property (nonatomic) NSInteger type;
@property (nonatomic) BOOL isFen;
@property (weak, nonatomic) IBOutlet UIButton *usertypeButton;
@property (weak, nonatomic) IBOutlet XWAddView *buttonBacView;

- (void)setData:(UserClass *)user andType:(NSInteger)idx;
- (void)setData:(ZhuBoClass *)user;
- (void)setDataAddJieMu:(ZhuBoClass *)user;

@end
