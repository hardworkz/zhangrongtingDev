//
//  ClassImageViewTableViewCell.m
//  kuangjiaTingWen
//
//  Created by 泡果 on 2017/6/2.
//  Copyright © 2017年 zhimi. All rights reserved.
//

#import "ClassImageViewTableViewCell.h"

@interface ClassImageViewTableViewCell ()
{
    UIImageView *image;
}
@end
@implementation ClassImageViewTableViewCell
+ (NSString *)ID
{
    return @"ClassImageViewTableViewCell";
}
+(ClassImageViewTableViewCell *)cellWithTableView:(UITableView *)tableView
{
    ClassImageViewTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:[ClassImageViewTableViewCell ID]];
    if (cell == nil) {
        cell = [[ClassImageViewTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:[ClassImageViewTableViewCell ID]];
    }
    return cell;
}
- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        image = [[UIImageView alloc] init];
        image.contentMode = UIViewContentModeScaleAspectFit;
        image.clipsToBounds = YES;
        image.userInteractionEnabled = YES;
        [image addTapGesWithTarget:self action:@selector(showZoomImageView:)];
        [self.contentView addSubview:image];
    }
    return self;
}
- (void)setFrameModel:(ClassImageViewCellFrameModel *)frameModel
{
    _frameModel = frameModel;
    
    image.frame = frameModel.imageViewF;
    image.image = frameModel.image;
}
- (void)showZoomImageView:(UITapGestureRecognizer *)tap
{
    if (self.tapImage) {
        self.tapImage(tap);
    }
}
@end
