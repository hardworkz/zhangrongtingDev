//
//  DownloadingTableViewCell.m
//  kuangjiaTingWen
//
//  Created by 泡果 on 16/7/25.
//  Copyright © 2016年 贺楠. All rights reserved.
//

#import "DownloadingTableViewCell.h"

@interface DownloadingTableViewCell ()

@property (strong, nonatomic) UIImageView *smetaImageView;
@property (strong, nonatomic) UILabel *titleLabel;
@property (strong, nonatomic) UILabel *sizeTitleLabel;
@property (strong, nonatomic) UILabel *sizeLabel;


@end

@implementation DownloadingTableViewCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier{
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]){
        
        [self.contentView addSubview:self.smetaImageView];
        [self.contentView addSubview:self.titleLabel];
        [self.contentView addSubview:self.progressView];
        [self.contentView addSubview:self.sizeTitleLabel];
        [self.contentView addSubview:self.sizeLabel];
        [self.contentView addSubview:self.progressLabel];
        [self.contentView addSubview:self.statusButton];
        
    }
    return self;
}


- (UIImageView *)smetaImageView{
    if (!_smetaImageView) {
        _smetaImageView = [[UIImageView alloc]initWithFrame:CGRectMake(5, 19.0 / 667 * SCREEN_HEIGHT, 112.0 / 375 * IPHONE_W, 62.72 / 375 *IPHONE_W)];
    }
    return _smetaImageView;
}

- (UILabel *)titleLabel{
    if (!_titleLabel) {
        _titleLabel = [[UILabel alloc]initWithFrame:CGRectMake(123.0 / 375 * IPHONE_W, 11, 224.0 / 375 * IPHONE_W, 21 * 3)];
        [_titleLabel setTextColor:[UIColor blackColor]];
        [_titleLabel setNumberOfLines:3];
        [_titleLabel setFont:[UIFont systemFontOfSize:17.0]];
    }
    return _titleLabel;
}

- (UIProgressView *)progressView {
    if (!_progressView) {
        _progressView = [[UIProgressView alloc]initWithProgressViewStyle:UIProgressViewStyleDefault];
        [_progressView setFrame:CGRectMake(123.0 / 375 *SCREEN_WIDTH, 78,224.0 / 375 * IPHONE_W,5)];
        [_progressView setTintColor:gMainColor];
    }
    return _progressView;
}
- (UILabel *)sizeTitleLabel {
    if (!_sizeTitleLabel) {
        _sizeTitleLabel = [[UILabel alloc]initWithFrame:CGRectMake(125.0 / 375 * IPHONE_W, 84, 26.0 / 375 * IPHONE_W, 14)];
        _sizeTitleLabel.text = @"大小";
        _sizeTitleLabel.font = [UIFont systemFontOfSize:13.0f / 375 * IPHONE_W];
        _sizeTitleLabel.textColor = [UIColor whiteColor];
        _sizeTitleLabel.textAlignment = NSTextAlignmentCenter;
        _sizeTitleLabel.backgroundColor = gMainColor;
    }
    return _sizeTitleLabel;
}

- (UILabel *)sizeLabel {
    if (!_sizeLabel) {
        _sizeLabel = [[UILabel alloc]initWithFrame:CGRectMake(151.0 / 375 * IPHONE_W, 84, 40.0 / 375 * IPHONE_W, 14)];
        _sizeLabel.textColor = [UIColor whiteColor];
        _sizeLabel.backgroundColor = [UIColor grayColor];
        _sizeLabel.font = [UIFont systemFontOfSize:13.0f / 375 * IPHONE_W];
        _sizeLabel.textAlignment = NSTextAlignmentCenter;
    }
    return _sizeLabel;
}

- (UILabel *)progressLabel{
    if (!_progressLabel) {
        _progressLabel = [[UILabel alloc]initWithFrame:CGRectMake(SCREEN_WIDTH - 120, 84, 60.0, 21)];
        _progressLabel.textColor = ColorWithRGBA(170, 170, 170, 1);
        _progressLabel.font = [UIFont systemFontOfSize:13.0f / 375 * IPHONE_W];
    }
    return _progressLabel;
}

- (UIButton *)statusButton {
    if (!_statusButton) {
        _statusButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [_statusButton setFrame:CGRectMake(SCREEN_WIDTH - 50, 84, 40, 21)];
        [_statusButton setTitle:@"等待" forState:UIControlStateNormal];
        [_statusButton setBackgroundColor:[UIColor redColor]];
        [_statusButton.titleLabel setFont:[UIFont systemFontOfSize:13.0f / 375 * IPHONE_W]];
        [_statusButton addTarget:self action:@selector(statusButtonAction:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _statusButton;
}

- (void)statusButtonAction:(UIButton *)sender {
    
    if (self.deleteDownloadingNew) {
        self.deleteDownloadingNew();
    }
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
    NSString *str = [NSString stringWithFormat:@"%.2lf%@",[mdic[@"post_size"] intValue] / 1024.0 / 1024.0,@"M"];
    if (str.length > 5)
    {
        self.sizeLabel.frame = CGRectMake(self.sizeLabel.frame.origin.x, self.sizeLabel.frame.origin.y, (str.length - 1) * 9.2 / 375 * IPHONE_W, 14);
    }else
    {
        self.sizeLabel.frame = CGRectMake(self.sizeLabel.frame.origin.x, self.sizeLabel.frame.origin.y, (str.length - 1) * 10.0 / 375 * IPHONE_W, 14);
    }
    [self.sizeLabel setText:[NSString stringWithFormat:@"%.2lf%@",[mdic[@"post_size"] intValue] / 1024.0 / 1024.0,@"M"]];
    [self.progressLabel setText:@"下载0.0%"];
    [self.progressView setProgress:0.0 animated:YES];
    
}

- (void)awakeFromNib {
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
