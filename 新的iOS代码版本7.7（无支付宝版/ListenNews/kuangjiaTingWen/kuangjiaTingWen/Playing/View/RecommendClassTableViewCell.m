//
//  RecommendClassTableViewCell.m
//  kuangjiaTingWen
//
//  Created by 泡果 on 2018/2/28.
//  Copyright © 2018年 zhimi. All rights reserved.
//

#import "RecommendClassTableViewCell.h"

@interface RecommendClassTableViewCell ()
{
    UIImageView *imgLeft;
    UILabel *titleLab;
    UILabel *label;
    UIView *line;
}
@end
@implementation RecommendClassTableViewCell
+ (NSString *)ID
{
    return @"RecommendClassTableViewCell";
}
+(RecommendClassTableViewCell *)cellWithTableView:(UITableView *)tableView
{
    RecommendClassTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:[RecommendClassTableViewCell ID]];
    if (cell == nil) {
        cell = [[RecommendClassTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:[RecommendClassTableViewCell ID]];
    }
    return cell;
}
- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        self.selectionStyle = UITableViewCellSelectionStyleNone;
        //图片
        imgLeft = [[UIImageView alloc]init];
        [imgLeft.layer setMasksToBounds:YES];
        [imgLeft.layer setCornerRadius:5.0];
        imgLeft.contentMode = UIViewContentModeScaleAspectFill;
        imgLeft.clipsToBounds = YES;
        [self.contentView addSubview:imgLeft];
        
        //标题
        titleLab = [[UILabel alloc]init];
        titleLab.backgroundColor = [UIColor redColor];
        titleLab.textColor = [UIColor blackColor];
        titleLab.textAlignment = NSTextAlignmentLeft;
        titleLab.numberOfLines = 0;
        titleLab.font = CUSTOM_FONT_TYPE(16.0);
        [self.contentView addSubview:titleLab];
        
        //标签
        label = [[UILabel alloc] init];
        label.text = @"推荐";
        label.backgroundColor = gMainColor;
        label.textColor = [UIColor whiteColor];
        label.font = CUSTOM_FONT_TYPE(14.0);
        label.textAlignment = NSTextAlignmentCenter;
//        label.layer.borderWidth = 0.5;
//        label.layer.borderColor = gMainColor.CGColor;
        label.layer.cornerRadius = 5;
        label.clipsToBounds = YES;
        [self.contentView addSubview:label];
        
        line = [[UIView alloc]init];
        [line setBackgroundColor:nMineNameColor];
        [self.contentView addSubview:line];
    }
    return self;
}
- (void)setFrameModel:(RecommendClassFrameModel *)frameModel
{
    _frameModel = frameModel;
    
    imgLeft.frame = frameModel.imgLeftF;
    titleLab.frame = frameModel.titleLabF;
    label.frame = frameModel.labelF;
    line.frame = frameModel.lineF;
    
    if ([NEWSSEMTPHOTOURL(frameModel.model.images)  rangeOfString:@"http"].location != NSNotFound){
        [imgLeft sd_setImageWithURL:[NSURL URLWithString:NEWSSEMTPHOTOURL(frameModel.model.images)]];
    }
    else{
        NSString *str = USERPOTOAD(NEWSSEMTPHOTOURL(frameModel.model.images));
        [imgLeft sd_setImageWithURL:[NSURL URLWithString:str]];
    }
    titleLab.text = frameModel.model.name;
}
@end
