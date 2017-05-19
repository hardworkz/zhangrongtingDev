//
//  XWAddView.m
//  Heard the news
//
//  Created by 温仲斌 on 16/1/18.
//  Copyright © 2016年 泡果网络. All rights reserved.
//

#import "XWAddView.h"

@implementation XWAddView

- (instancetype)initWithCoder:(NSCoder *)coder
{
    self = [super initWithCoder:coder];
    if (self) {
        self.layer.cornerRadius = 5;
        self.layer.borderColor = [UIColor blackColor].CGColor;
        self.layer.borderWidth = 0.1;
    }
    return self;
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
