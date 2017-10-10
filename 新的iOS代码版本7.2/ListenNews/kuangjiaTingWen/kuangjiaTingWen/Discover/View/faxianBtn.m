//
//  faxianBtn.m
//  reHeardTheNews
//
//  Created by 贺楠 on 16/5/30.
//  Copyright © 2016年 paoguo. All rights reserved.
//

#import "faxianBtn.h"
#import "UIImageView+WebCache.h"
@implementation faxianBtn

- (instancetype)initWithImageUrlStr:(NSString *)imageUrlStr andTitle:(NSString *)title andIndex_row:(NSInteger *)index_row  forzhubo:(BOOL)isZhuBo
{
    if (self = [super init])
    {
        
        self.isAccessibilityElement = YES;
        self.accessibilityLabel = title;
        UIImageView *imageView = [[UIImageView alloc]initWithFrame:CGRectMake(37.5 / 375 * IPHONE_W, 12.5 / 667 * IPHONE_H, 170.0 / 667 * IPHONE_H, 170.0 / 667 * IPHONE_H)];
        
        if([imageUrlStr rangeOfString:@"/data/upload/"].location !=NSNotFound){
            
            [imageView sd_setImageWithURL:[NSURL URLWithString:USERPHOTOHTTPSTRINGZhuBo(imageUrlStr)]];
            //placeholderImage:[UIImage imageNamed:@"tingwen_bg_square"]
        }
        else{
            [imageView sd_setImageWithURL:[NSURL URLWithString:USERPOTOAD(imageUrlStr)]];
        }
        
        imageView.contentMode = UIViewContentModeScaleToFill;
//        self.clipsToBounds = YES;
//        imageView.clipsToBounds = YES;
        imageView.center = self.center;
        imageView.tag = 1;
        
//        CALayer *layer = [imageView layer];
//        layer.borderColor = [[UIColor grayColor]CGColor];
//        layer.borderWidth = 0.4f;
        
        if (index_row != 0)
        {
            imageView.frame = CGRectMake(15.0 / 375 * IPHONE_W, 0 / 667 * IPHONE_H,105.0 / 667 * IPHONE_H, 105.0 / 667 * IPHONE_H);
            imageView.layer.masksToBounds = NO;
        }
        
        [self addSubview:imageView];
        
        UILabel *lab = [[UILabel alloc]initWithFrame:CGRectMake(imageView.frame.origin.x, CGRectGetMaxY(imageView.frame) + 8.0 / 667 * IPHONE_H, imageView.frame.size.width, 20.0 / 667 * IPHONE_H)];
        lab.text = title;
        lab.textColor = [UIColor blackColor];
        lab.font =[UIFont fontWithName:@"Courier" size:13.0];
        lab.textAlignment = NSTextAlignmentCenter;
        lab.tag = 2;
        if (title.length > 8)
        {
            [lab setNumberOfLines:2];
            lab.lineBreakMode = NSLineBreakByWordWrapping;
            CGSize size = [lab sizeThatFits:CGSizeMake(lab.frame.size.width, MAXFLOAT)];
            lab.frame = CGRectMake(lab.frame.origin.x, lab.frame.origin.y, lab.frame.size.width, size.height);
            lab.textAlignment = NSTextAlignmentLeft;
        }
        [self addSubview:lab];
        
        if (isZhuBo == YES)
        {
            imageView.frame = CGRectMake(6.25 / 375 * IPHONE_W, 6.25 / 667 * IPHONE_H, 70.0 / 667 * IPHONE_H, 70.0 / 667 * IPHONE_H);
//            imageView.layer.cornerRadius = 4.0;
//            imageView.layer.masksToBounds = YES;
//            imageView.contentMode = UIViewContentModeScaleAspectFit;
            lab.frame = CGRectMake(-15.0 / 375 * IPHONE_W, CGRectGetMaxY(imageView.frame) + 10.0 / 667 * IPHONE_H, 92.5 / 375 * IPHONE_W, 20.0 / 667 * IPHONE_H);
            lab.font =[UIFont fontWithName:@"Courier" size:13.0 ];
        }
        imageView.layer.cornerRadius = 4.0;
        imageView.layer.masksToBounds = YES;
    }
    return self;
}

@end
