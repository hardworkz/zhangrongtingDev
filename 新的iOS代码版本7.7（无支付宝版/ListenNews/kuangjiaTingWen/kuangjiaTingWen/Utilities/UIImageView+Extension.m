//
//  UIImageView+Extension.m
//  xzb
//
//  Created by 张荣廷 on 16/8/3.
//  Copyright © 2016年 xuwk. All rights reserved.
//

#import "UIImageView+Extension.h"

@implementation UIImageView (Extension)
- (void)changeImageWithAnimation:(NSString *)imageName
{
    [UIView animateWithDuration:1.0 animations:^{
        self.alpha = 0;
    }completion:^(BOOL finished) {
        self.image = [UIImage imageNamed:imageName];
        [UIView animateWithDuration:1.0 animations:^{
            self.alpha = 1;
        }];
    }];
}
@end
