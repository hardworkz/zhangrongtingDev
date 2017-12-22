//
//  TradingRecordTableViewCell.m
//  kuangjiaTingWen
//
//  Created by Zhimi on 17/2/17.
//  Copyright © 2017年 贺楠. All rights reserved.
//

#import "TradingRecordTableViewCell.h"

@interface TradingRecordTableViewCell ()

@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (weak, nonatomic) IBOutlet UILabel *dateLabel;
@property (weak, nonatomic) IBOutlet UILabel *numLabel;

@end

@implementation TradingRecordTableViewCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
    
}

- (void)updateCellWithDataDic:(NSDictionary *)DataDic andPageSource:(NSInteger )pageSource{
    
    [_titleLabel setText:@"赞赏主播KEVINWU"];
    [_dateLabel setText:@"2017-02-17 13:49"];
    [_numLabel setText:[NSString stringWithFormat:@"%d听币",50]];
    
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
