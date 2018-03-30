//
//  RecommendClassTableViewCell.h
//  kuangjiaTingWen
//
//  Created by 泡果 on 2018/2/28.
//  Copyright © 2018年 zhimi. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface RecommendClassTableViewCell : UITableViewCell
@property (strong, nonatomic) RecommendClassFrameModel *frameModel;
+(RecommendClassTableViewCell *)cellWithTableView:(UITableView *)tableView;
@end
