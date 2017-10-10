//
//  PlayVCThreeBtnTableViewCell.m
//  kuangjiaTingWen
//
//  Created by 泡果 on 2017/7/26.
//  Copyright © 2017年 zhimi. All rights reserved.
//

#import "PlayVCThreeBtnTableViewCell.h"

@interface PlayVCThreeBtnTableViewCell()
@end
@implementation PlayVCThreeBtnTableViewCell
+ (NSString *)ID
{
    return @"PlayVCThreeBtnTableViewCell";
}
+(PlayVCThreeBtnTableViewCell *)cellWithTableView:(UITableView *)tableView
{
    PlayVCThreeBtnTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:[PlayVCThreeBtnTableViewCell ID]];
    if (cell == nil) {
        cell = [[PlayVCThreeBtnTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:[PlayVCThreeBtnTableViewCell ID]];
    }
    return cell;
}
- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        UIView *topLine = [[UIView alloc]initWithFrame:CGRectMake(0, 0, IPHONE_W, 1)];
        topLine.backgroundColor = [UIColor lightGrayColor];
        topLine.alpha = 0.5f;
        [self.contentView addSubview:topLine];
        
        //下载、投金币、评论
        NSMutableArray *itemArr = [NSMutableArray array];
        
        NSDictionary *dic0 = @{@"image":@"home_news_download",@"title":@"下载"};
        [itemArr addObject:dic0];
        NSDictionary *dic1 = @{@"image":@"tb",@"title":@"投金币"};
        [itemArr addObject:dic1];
        NSDictionary *dic2 = @{@"image":@"iconfont_pinglun",@"title":@"评论"};
        [itemArr addObject:dic2];
        for (int i = 0; i < [itemArr count]; i ++) {
            CGFloat w = (SCREEN_WIDTH - 30 * itemArr.count) / (itemArr.count * 2);
            UIButton *itemImgBtn = [UIButton buttonWithType:UIButtonTypeCustom];
            [itemImgBtn setFrame:CGRectMake(i % itemArr.count * (2 * w + 30) + w , CGRectGetMaxY(topLine.frame) + 10, 30, 30)];
            [itemImgBtn setImage:[UIImage imageNamed:itemArr[i][@"image"]] forState:UIControlStateNormal];
            [itemImgBtn setTag:(10 + i)];
            [itemImgBtn addTarget:self action:@selector(selecteItemAction:) forControlEvents:UIControlEventTouchUpInside];
            [self.contentView addSubview:itemImgBtn];
            
            UIButton *itemBtn = [UIButton buttonWithType:UIButtonTypeCustom];
            [itemBtn setFrame:CGRectMake(itemImgBtn.frame.origin.x - 5, itemImgBtn.frame.origin.y + itemImgBtn.frame.size.height, 40, 20)];
            [itemBtn setTitle:itemArr[i][@"title"] forState:UIControlStateNormal];
            [itemBtn setTitleColor:gTextDownload forState:UIControlStateNormal];
            [itemBtn.titleLabel setFont:gFontMain12];
            [itemBtn setTag:(10 + i)];
            [itemBtn addTarget:self action:@selector(selecteItemAction:) forControlEvents:UIControlEventTouchUpInside];
            [self.contentView addSubview:itemBtn];
            if (i == 1) {
                [self.appreciateNum setFrame:CGRectMake(CGRectGetMaxX(itemImgBtn.frame) - 10, itemImgBtn.frame.origin.y, 20, 10)];
                [self.contentView addSubview:self.appreciateNum];
            }
            else if (i == 2){
                [self.commentNum setFrame:CGRectMake(CGRectGetMaxX(itemImgBtn.frame) - 10, itemImgBtn.frame.origin.y, 20, 10)];
                [self.contentView addSubview:self.commentNum];
            }
        }
        
        UIView *downLine = [[UIView alloc]initWithFrame:CGRectMake(0, CGRectGetMaxY(topLine.frame) + 70, IPHONE_W, 1)];
        downLine.backgroundColor = [UIColor lightGrayColor];
        downLine.alpha = 0.5f;
        [self.contentView addSubview:downLine];

    }
    return self;
}
- (UILabel *)appreciateNum{
    if (!_appreciateNum) {
        _appreciateNum = [[UILabel alloc]init];
        [_appreciateNum setTextAlignment:NSTextAlignmentLeft];
        [_appreciateNum setFont:gFontSub11];
        [_appreciateNum setTextColor:[UIColor colorWithHue:0.12 saturation:0.78 brightness:0.98 alpha:1.00]];
    }
    return _appreciateNum;
    
}
- (UILabel *)commentNum{
    if (!_commentNum) {
        _commentNum = [[UILabel alloc]init];
        [_commentNum setTextAlignment:NSTextAlignmentLeft];
        [_commentNum setFont:gFontSub11];
        [_commentNum setTextColor:[UIColor colorWithHue:0.01 saturation:0.57 brightness:0.93 alpha:1.00]];
    }
    return _commentNum;
}
- (void)selecteItemAction:(UIButton *)sender {
    if (self.selectedItem) {
        self.selectedItem(sender);
    }
}
@end
