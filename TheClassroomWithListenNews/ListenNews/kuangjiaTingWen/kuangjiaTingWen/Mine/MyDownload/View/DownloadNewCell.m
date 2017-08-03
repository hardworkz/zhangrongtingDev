//
//  DownloadNewCell.m
//  Heard the news
//
//  Created by Pop Web on 15/10/29.
//  Copyright © 2015年 泡果网络. All rights reserved.
//

#import "DownloadNewCell.h"

#import "CommonCode.h"

#import "NewObj.h"

//#import "CellIshide.h"

#import "ProjiectDownLoadManager.h"

//#import "ZhuBoClass.h"

#import "UIImageView+WebCache.h"

//#import "SQLClass.h"

@interface DownloadNewCell ()
@property (weak, nonatomic) IBOutlet UIImageView *imageV;
@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (weak, nonatomic) IBOutlet UILabel *sizeLabel;
@property (weak, nonatomic) IBOutlet UILabel *timerLabel;

@property (nonatomic, strong) UIImageView *bigView;

@end

@implementation DownloadNewCell

- (instancetype)initWithCoder:(NSCoder *)coder
{
    self = [super initWithCoder:coder];
//    if (self) {
//        self.titleLabel.highlightedTextColor = [UIColor colorWithRed:38.0 / 255. green:191.0 / 255. blue:252.0 / 255. alpha:1.0];
//    }
    return self;
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter]removeObserver:self];
}

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

#pragma mark - 加载数据
- (void)setNewData:(NewObj *)newobj {
    if (!Greater_Than_IOS6) {
        self.titleLabel.preferredMaxLayoutWidth = SCREEN_WIDTH - 135;
    }
    self.obj = newobj;
    _titleLabel.text = newobj.post_title;
    _titleLabel.textColor = [[ZRT_PlayerManager manager] textColorFormID:self.obj.i_id];
    @autoreleasepool {
        UIImage *ima = [UIImage imageWithContentsOfFile:newobj.smeta];
        if (ima) {
            _imageV.image = ima;
        }else {
            UIImage *imaD = [UIImage imageNamed:@"thumbnailsdefault"];
            _imageV.image = imaD;
        }
        _sizeLabel.text = [NSString stringWithFormat:@"%@", newobj.post_size];
        //    NSLog(@"%@", newobj.smeta);
        NSMutableString *dateString;
        if (SCREEN_WIDTH < 350) {
            dateString = [[[newobj.post_date componentsSeparatedByString:@" "]firstObject]mutableCopy];
        }else {
            dateString = [newobj.post_date mutableCopy];
        }
        _timerLabel.text = dateString;
    }
 }

#pragma mark - 加载数据
- (void)setNewDataZhuBo:(NewObj *)newobj {
    if (!Greater_Than_IOS6) {
        self.titleLabel.preferredMaxLayoutWidth = SCREEN_WIDTH - 135;
    }
    self.obj = newobj;
    _titleLabel.text = newobj.post_title;
//    [SQLClass getClickWithString:newobj.i_id withExistenceBlock:^(bool isClick) {
//        if (isClick) {
//            _titleLabel.textColor = [UIColor lightGrayColor];
//        }else {
//            _titleLabel.textColor = [UIColor blackColor];
//        }
//    }];
    @autoreleasepool {
        UIImage *imaD = [UIImage imageNamed:@"thumbnailsdefault"];

        [_imageV sd_setImageWithURL:[NSURL URLWithString:newobj.smeta] placeholderImage:imaD];
        _sizeLabel.text = [NSString stringWithFormat:@"%@", newobj.post_size];
        NSMutableString *dateString;
        if (SCREEN_WIDTH < 350) {
            dateString = [[[newobj.post_date componentsSeparatedByString:@" "]firstObject]mutableCopy];
        }else {
            dateString = [newobj.post_date mutableCopy];
        }
        _timerLabel.text = dateString;
    }
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    //如果菜单隐藏，则可以选择
//    if (selected) {
//        _titleLabel.textColor = [UIColor lightGrayColor];
//        self.titleLabel.highlighted = YES;
//        [super setSelected:selected animated:animated];
//    }else{
//        self.titleLabel.highlighted = NO;
//    }
    // Configure the view for the selected state
}

@end
