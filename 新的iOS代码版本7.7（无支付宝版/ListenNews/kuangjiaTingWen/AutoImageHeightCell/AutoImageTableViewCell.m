//
//  AutoImageTableViewCell.m
//  JiDing
//
//  Created by zhangrongting on 2017/6/17.
//  Copyright © 2017年 zhangrongting. All rights reserved.
//

#import "AutoImageTableViewCell.h"
#import "AutoImageViewHeightFrameModel.h"

@interface AutoImageTableViewCell ()
{
    UIImageView *autoImageView;
}
@end
@implementation AutoImageTableViewCell
+ (NSString *)ID
{
    return @"AutoImageTableViewCell";
}
+(AutoImageTableViewCell *)cellWithTableView:(UITableView *)tableView
{
    AutoImageTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:[AutoImageTableViewCell ID]];
    if (cell == nil) {
        cell = [[AutoImageTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:[AutoImageTableViewCell ID]];
    }
    return cell;
}
- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        autoImageView = [[UIImageView alloc] init];
        autoImageView.contentMode = UIViewContentModeScaleAspectFit;
        autoImageView.clipsToBounds = YES;
        autoImageView.userInteractionEnabled = YES;
        [autoImageView addTapGesWithTarget:self action:@selector(showZoomImageView:)];
        [self.contentView addSubview:autoImageView];
    }
    return self;
}
- (void)setFrameModel:(AutoImageViewHeightFrameModel *)frameModel
{
    _frameModel = frameModel;
    
    autoImageView.frame = frameModel.imageViewF;
    autoImageView.image = frameModel.image;
}
- (void)showZoomImageView:(UITapGestureRecognizer *)tap
{
    if (self.tapImage) {
        self.tapImage(tap);
    }
}
@end
