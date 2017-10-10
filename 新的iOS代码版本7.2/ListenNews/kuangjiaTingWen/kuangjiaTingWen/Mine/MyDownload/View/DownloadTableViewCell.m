//
//  DownloadTableViewCell.m
//  kuangjiaTingWen
//
//  Created by 泡果 on 16/7/21.
//  Copyright © 2016年 贺楠. All rights reserved.
//

#import "DownloadTableViewCell.h"
#import "NSDate+TimeFormat.h"

@interface DownloadTableViewCell ()

@property (strong, nonatomic) UIImageView *smetaImageView;
@property (strong, nonatomic) UILabel *titleLabel;
@property (strong, nonatomic) UILabel *sizeTitleLabel;
@property (strong, nonatomic) UILabel *sizeLabel;
@property (strong,nonatomic) UILabel *modifiedTimeLabel;

@end

@implementation DownloadTableViewCell


- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier{
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]){
        
        [self.contentView addSubview:self.smetaImageView];
        [self.contentView addSubview:self.titleLabel];
//        [self.contentView addSubview:self.sizeTitleLabel];
        [self.contentView addSubview:self.sizeLabel];
        [self.contentView addSubview:self.modifiedTimeLabel];
        
    }
    return self;
}

- (UIImageView *)smetaImageView{
    if (!_smetaImageView) {
        _smetaImageView = [[UIImageView alloc]initWithFrame:CGRectMake(5.0 / 375 * SCREEN_WIDTH, 19.0 / 667 * SCREEN_HEIGHT, 112.0 / 375 * IPHONE_W, 62.72 / 375 *IPHONE_W)];
    }
    return _smetaImageView;
}

- (UILabel *)titleLabel{
    if (!_titleLabel) {
        _titleLabel = [[UILabel alloc]initWithFrame:CGRectMake(123.0 / 375 * IPHONE_W, 11.0 / 667 * SCREEN_HEIGHT, 215.0 / 375 * IPHONE_W, 63.0 / 667 * SCREEN_HEIGHT)];
        [_titleLabel setTextColor:[UIColor blackColor]];
        [_titleLabel setNumberOfLines:3];
        [_titleLabel setFont:[UIFont systemFontOfSize:17.0]];
    }
    return _titleLabel;
}

- (UILabel *)sizeTitleLabel {
    if (!_sizeTitleLabel) {
        _sizeTitleLabel = [[UILabel alloc]initWithFrame:CGRectMake(250.0 / 375 * IPHONE_W, 74.0 / 667 * SCREEN_HEIGHT, 26.0 / 375 * IPHONE_W, 14.0 / 667 * SCREEN_HEIGHT)];
        _sizeTitleLabel.text = @"大小";
        _sizeTitleLabel.font = [UIFont systemFontOfSize:13.0f];
        _sizeTitleLabel.textColor = [UIColor whiteColor];
        _sizeTitleLabel.textAlignment = NSTextAlignmentCenter;
        _sizeTitleLabel.backgroundColor = gMainColor;
    }
    return _sizeTitleLabel;
}

- (UILabel *)sizeLabel {
    if (!_sizeLabel) {
        _sizeLabel = [[UILabel alloc]initWithFrame:CGRectMake(265.0 / 375 * IPHONE_W, 74.0 / 667 * SCREEN_HEIGHT, 50.0 / 375 * IPHONE_W, 14.0 / 667 * SCREEN_HEIGHT)];
        _sizeLabel.textColor = gTextColorSub;
        _sizeLabel.font = [UIFont systemFontOfSize:13.0f];
        _sizeLabel.textAlignment = NSTextAlignmentCenter;
    }
    return _sizeLabel;
}

- (UILabel *)modifiedTimeLabel{
    if (!_modifiedTimeLabel) {
        _modifiedTimeLabel = [[UILabel alloc]initWithFrame:CGRectMake(125.0 / 375 * IPHONE_W, 71.0 / 667 * SCREEN_HEIGHT, 135.0 / 375 * IPHONE_W, 21.0 / 667 * SCREEN_HEIGHT)];
        _modifiedTimeLabel.textColor = gTextColorSub;
        _modifiedTimeLabel.font = [UIFont systemFontOfSize:13.0f];
    }
    return _modifiedTimeLabel;
}


- (void)updateCellValueWithDict:(NSMutableDictionary *)mdic {
    
    if ([NEWSSEMTPHOTOURL(mdic[@"smeta"])  rangeOfString:@"http"].location != NSNotFound)
    {
        [self.smetaImageView sd_setImageWithURL:[NSURL URLWithString:NEWSSEMTPHOTOURL(mdic[@"smeta"])] placeholderImage:[UIImage imageNamed:@"thumbnailsdefault"]];
    }else
    {
        NSString *str = USERPHOTOHTTPSTRINGZhuBo(NEWSSEMTPHOTOURL(mdic[@"smeta"]));
        [self.smetaImageView sd_setImageWithURL:[NSURL URLWithString:str] placeholderImage:[UIImage imageNamed:@"thumbnailsdefault"]];
    }
    [self.titleLabel setText:mdic[@"post_title"]];
    self.titleLabel.textColor = [[ZRT_PlayerManager manager] textColorFormID:mdic[@"id"]];
    
//    NSString *str = [NSString stringWithFormat:@"%.1lf%@",[mdic[@"post_size"] intValue] / 1024.0 / 1024.0,@"M"];
//    if (str.length > 5)
//    {
//        self.sizeLabel.frame = CGRectMake(self.sizeLabel.frame.origin.x, self.sizeLabel.frame.origin.y, (str.length - 1) * 9.2 / 375 * IPHONE_W, 14);
//    }else
//    {
//        self.sizeLabel.frame = CGRectMake(self.sizeLabel.frame.origin.x, self.sizeLabel.frame.origin.y, (str.length - 1) * 10.0 / 375 * IPHONE_W, 14);
//    }
    [self.sizeLabel setText:[NSString stringWithFormat:@"%.1lf%@",[mdic[@"post_size"] intValue] / 1024.0 / 1024.0,@"M"]];
    NSDate *date = [NSDate dateFromString:mdic[@"post_modified"]];
    [self.modifiedTimeLabel setText:[date showTimeByTypeA]];
}


- (void)awakeFromNib {
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
