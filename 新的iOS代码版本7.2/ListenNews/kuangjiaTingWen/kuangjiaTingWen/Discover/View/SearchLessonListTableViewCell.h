//
//  SearchLessonListTableViewCell.h
//  kuangjiaTingWen
//
//  Created by 泡果 on 2017/10/24.
//  Copyright © 2017年 zhimi. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SearchLessonListTableViewCell : UITableViewCell
@property (strong, nonatomic) NSMutableDictionary *dataDict;
+(SearchLessonListTableViewCell *)cellWithTableView:(UITableView *)tableView;
@end
