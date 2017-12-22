//
//  ClassCommentTableViewCell.m
//  kuangjiaTingWen
//
//  Created by 泡果 on 2017/6/2.
//  Copyright © 2017年 zhimi. All rights reserved.
//

#import "ClassCommentTableViewCell.h"

@implementation ClassCommentTableViewCell
+ (NSString *)ID
{
    return @"ClassCommentTableViewCell";
}
+(ClassCommentTableViewCell *)cellWithTableView:(UITableView *)tableView
{
    ClassCommentTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:[ClassCommentTableViewCell ID]];
    if (cell == nil) {
        cell = [[ClassCommentTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:[ClassCommentTableViewCell ID]];
    }
    return cell;
}
- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
    }
    return self;
}
@end
