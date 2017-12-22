//
//  MyClassroomTableViewCell.m
//  kuangjiaTingWen
//
//  Created by 泡果 on 2017/6/14.
//  Copyright © 2017年 zhimi. All rights reserved.
//

#import "MyClassroomTableViewCell.h"

@interface MyClassroomTableViewCell ()
{
    UIImageView *imgLeft;
    UILabel *titleLab;
    UILabel *price;
    UILabel *describe;
    UIView *line;
}
@end
@implementation MyClassroomTableViewCell
+ (NSString *)ID
{
    return @"MyClassroomTableViewCell";
}
+(MyClassroomTableViewCell *)cellWithTableView:(UITableView *)tableView
{
    MyClassroomTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:[MyClassroomTableViewCell ID]];
    if (cell == nil) {
        cell = [[MyClassroomTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:[MyClassroomTableViewCell ID]];
    }
    return cell;
}
- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        //图片
        imgLeft = [[UIImageView alloc]init];
        [imgLeft.layer setMasksToBounds:YES];
        [imgLeft.layer setCornerRadius:5.0];
        
        [self.contentView addSubview:imgLeft];
        imgLeft.contentMode = UIViewContentModeScaleAspectFill;
        imgLeft.clipsToBounds = YES;
        
        //标题
        titleLab = [[UILabel alloc]init];
        titleLab.textColor = [UIColor blackColor];
        titleLab.textAlignment = NSTextAlignmentLeft;
        titleLab.numberOfLines = 0;
        titleLab.font = [UIFont boldSystemFontOfSize:16.0f];
        [self.contentView addSubview:titleLab];
        
        //价钱
        price = [[UILabel alloc]init];
        price.font = gFontMain14;
        price.textColor = gMainColor;
        [self.contentView addSubview:price];
        
        //简介
        describe = [[UILabel alloc]init];
        describe.textColor = gTextColorSub;
        describe.numberOfLines = 0;
        describe.textAlignment = NSTextAlignmentLeft;
        describe.font = gFontMain14;
        [self.contentView addSubview:describe];
        
        
        line = [[UIView alloc]init];
        [line setBackgroundColor:nMineNameColor];
        [self.contentView addSubview:line];
    }
    return self;
}
- (void)setFrameModel:(MyClassroomListFrameModel *)frameModel
{
    _frameModel = frameModel;
    imgLeft.frame = frameModel.imgLeftF;
    titleLab.frame = frameModel.titleLabF;
    price.frame = frameModel.priceF;
    describe.frame = frameModel.describeF;\
//    if (!_hiddenDevider) {
        line.frame = frameModel.lineF;
//        line.hidden = NO;
//    }else{
//        line.hidden = YES;
//    }
    
    if ([NEWSSEMTPHOTOURL(frameModel.model.images)  rangeOfString:@"http"].location != NSNotFound){
        [imgLeft sd_setImageWithURL:[NSURL URLWithString:NEWSSEMTPHOTOURL(frameModel.model.images)]];
    }
    else{
        NSString *str = USERPOTOAD(NEWSSEMTPHOTOURL(frameModel.model.images));
        [imgLeft sd_setImageWithURL:[NSURL URLWithString:str]];
    }
    titleLab.text = frameModel.model.name;
    price.text = [NSString stringWithFormat:@"¥%@",[NetWorkTool formatFloat:[frameModel.model.price floatValue]]];
    price.hidden = self.hiddenPrice;
    
    describe.text = frameModel.model.Description;
}
@end
