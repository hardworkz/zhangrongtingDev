//
//  SearchLessonListTableViewCell.m
//  kuangjiaTingWen
//
//  Created by 泡果 on 2017/10/24.
//  Copyright © 2017年 zhimi. All rights reserved.
//

#import "SearchLessonListTableViewCell.h"

@interface SearchLessonListTableViewCell ()
{
    UILabel *nameLab;
    UIImageView *imgV;
    UILabel *neirongLab;
}
@end
@implementation SearchLessonListTableViewCell
+ (NSString *)ID
{
    return @"SearchLessonListTableViewCell";
}
+(SearchLessonListTableViewCell *)cellWithTableView:(UITableView *)tableView
{
    SearchLessonListTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:[SearchLessonListTableViewCell ID]];
    if (cell == nil) {
        cell = [[SearchLessonListTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:[SearchLessonListTableViewCell ID]];
        
        
    }
    return cell;
}
- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        
        imgV = [[UIImageView alloc]initWithFrame:CGRectMake(10.0 / 375 * IPHONE_W, 11, 45, 45)];
        imgV.layer.cornerRadius = 22.5f;
        imgV.layer.masksToBounds = YES;
        imgV.contentMode = UIViewContentModeScaleAspectFit;
        [self.contentView addSubview:imgV];
        
        nameLab = [[UILabel alloc]initWithFrame:CGRectMake(5.0 / 375 * IPHONE_W + 57 + 10.0 / 375 * IPHONE_W, 15, SCREEN_WIDTH - 45 - 30 - 10.0 / 375 * IPHONE_W, 15)];
        nameLab.numberOfLines = 0;
        nameLab.textColor = [UIColor blackColor];
        nameLab.textAlignment = NSTextAlignmentLeft;
        nameLab.font = [UIFont systemFontOfSize:16.0f];
        [self.contentView addSubview:nameLab];
        
        neirongLab = [[UILabel alloc]initWithFrame:CGRectMake(nameLab.frame.origin.x, 37.0 / 667 * SCREEN_HEIGHT, 250.0 / 375 * IPHONE_W, 15.0 / 667 * SCREEN_HEIGHT)];
        neirongLab.textColor = [UIColor grayColor];
        neirongLab.font = [UIFont systemFontOfSize:13.0f];
        neirongLab.textAlignment = NSTextAlignmentLeft;
        neirongLab.alpha = 0.7f;
        [self.contentView addSubview:neirongLab];
    }
    return self;
}
- (void)setDataDict:(NSMutableDictionary *)dataDict
{
    _dataDict = dataDict;
    
    if([dataDict[@"images"] rangeOfString:@"/data/upload/"].location !=NSNotFound)
    {
        [imgV sd_setImageWithURL:[NSURL URLWithString:USERPHOTOHTTPSTRINGZhuBo(dataDict[@"images"])] placeholderImage:[UIImage imageNamed:@"user-5"]];
    }
    else
    {
        [imgV sd_setImageWithURL:[NSURL URLWithString:USERPOTOAD(dataDict[@"images"])] placeholderImage:[UIImage imageNamed:@"user-5"]];
    }
    CGSize nameLabSize = [dataDict[@"name"] boundingRectWithSize:CGSizeMake(SCREEN_WIDTH - 45 - 30 - 10.0 / 375 * IPHONE_W, MAXFLOAT) options:NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName:[UIFont boldSystemFontOfSize:16.0]} context:nil].size;
    RTLog(@"nameLabSizeH:%f",nameLabSize.height);
    nameLab.frame = CGRectMake(5.0 / 375 * IPHONE_W + 57 + 10.0 / 375 * IPHONE_W, 15, nameLabSize.width, nameLabSize.height);
    nameLab.text = dataDict[@"name"];
    
    if (nameLabSize.height > 20) {
        neirongLab.hidden = YES;
    }else{
        neirongLab.hidden = NO;
        NSString *sigtStr = dataDict[@"description"];
        if (sigtStr.length == 0)
        {
            neirongLab.text = @"该用户没有什么想说的";
        }else
        {
            neirongLab.text = sigtStr;
        }
        if ([dataDict[@"price"] intValue] == 0) {
            neirongLab.width = 250.0 / 375 * IPHONE_W;
        }else{
            neirongLab.width = SCREEN_WIDTH - 45 - 30 - 10.0 / 375 * IPHONE_W;
            if (SCREEN_WIDTH == 320) {
                neirongLab.hidden = YES;
            }else{
                neirongLab.hidden = NO;
            }
        }

    }
    
}
@end
