//
//  paixuColleCtionViewCell.m
//  kuangjiaTingWen
//
//  Created by 贺楠 on 16/6/20.
//  Copyright © 2016年 贺楠. All rights reserved.
//

#import "paixuColleCtionViewCell.h"

@implementation paixuColleCtionViewCell

-(id)initWithFrame:(CGRect)frame{
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor grayColor];
        
        self.lab = [[UILabel alloc]initWithFrame:CGRectMake(0, 0, frame.size.width, frame.size.height)];
        self.lab.textAlignment = NSTextAlignmentCenter;
        self.lab.backgroundColor = [UIColor whiteColor];
        self.lab.font = [UIFont boldSystemFontOfSize:15.0f];
        [self addSubview:self.lab];
        self.layer.masksToBounds = YES;
        self.layer.cornerRadius = 7.0;
        CALayer *layer = [self layer];
        layer.borderColor = [[UIColor blackColor]CGColor];
        layer.borderWidth = 0.5f;
    }
    
    return self;
}

@end
