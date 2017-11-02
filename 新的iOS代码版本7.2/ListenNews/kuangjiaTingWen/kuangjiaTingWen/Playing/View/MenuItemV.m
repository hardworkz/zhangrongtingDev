//
//  MenuItemV.m
//  CommunityCourier
//
//  Created by 陈聪豪 on 16/6/12.
//  Copyright © 2016年 diyuanxinxi.com. All rights reserved.
//

#import "MenuItemV.h"
#import "OtherItem.h"
#import "UIImage+CH.h"
#import "UIButton+WebCache.h"
#define AdaptiveScale_W (SCREEN_WIDTH/375.0)

@implementation MenuItemV

-(instancetype)initWithFrame:(CGRect)frame andTitleArr:(NSMutableArray *)titleArr andImgArr:(NSMutableArray *)imgArr andLineNum:(NSInteger)num{
    if (self = [super initWithFrame:frame]) {
        [self setBackgroundColor:[UIColor redColor]];
        for (int i = 0; i < titleArr.count; i++) {
            UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
            //            btn.backgroundColor = [UIColor orangeColor];
            if (num - 1 == 0) {
                btn.frame = CGRectMake(i%num*(20 * AdaptiveScale_W + (self.frame.size.width - 40 * AdaptiveScale_W - 20 * num * AdaptiveScale_W)),IS_IPAD?5:i/num*(20 * AdaptiveScale_W + 10 * AdaptiveScale_W) + 10 * AdaptiveScale_W ,
                                       IS_IPAD?30:20*AdaptiveScale_W ,
                                       IS_IPAD?30:20*AdaptiveScale_W );
            }
            else{
                btn.frame = CGRectMake(i%num*(20 * AdaptiveScale_W + (self.frame.size.width - 40 * AdaptiveScale_W - 20 * num * AdaptiveScale_W)/(num - 1)),IS_IPAD?5:i/num*(20 * AdaptiveScale_W + 10 * AdaptiveScale_W) + 10 * AdaptiveScale_W ,
                                       IS_IPAD?30:20*AdaptiveScale_W  ,
                                       IS_IPAD?30:20*AdaptiveScale_W );
            }
            
            if ([imgArr[i]  rangeOfString:@"http"].location != NSNotFound){
                [btn sd_setImageWithURL:[NSURL URLWithString:imgArr[i] ]forState:UIControlStateNormal placeholderImage:AvatarPlaceHolderImage];
            }
            else{
                [btn sd_setImageWithURL:[NSURL URLWithString:USERPHOTOHTTPSTRING(imgArr[i]) ]forState:UIControlStateNormal placeholderImage:AvatarPlaceHolderImage];
            }
            [btn.layer setMasksToBounds:YES];
            [btn.layer setCornerRadius:IS_IPAD?30/2:20*AdaptiveScale_W/2];
            btn.tag = 10+i;
            [self addSubview:btn];
            
            UIButton *tipbtn = [UIButton buttonWithType:UIButtonTypeCustom];
            tipbtn.frame = CGRectMake(btn.frame.origin.x - 5, CGRectGetMaxY(btn.frame) + 5, btn.frame.size.width + 10, 8);
            [tipbtn setTitle:titleArr[i] forState:UIControlStateNormal];
            [tipbtn setTitleColor:[UIColor colorWithWhite:0.400 alpha:1.000] forState:UIControlStateNormal];
            [tipbtn.titleLabel setFont:[UIFont systemFontOfSize:9.0]];
            [self addSubview:tipbtn];
            
        }
        self.backgroundColor = [UIColor whiteColor];
    }
    return self;
}

//选择
-(void)btnAction:(UIButton *)sender{
    
    self.otherItemBlock(sender.tag);
}

@end
