//
//  guanggaoVC.m
//  reHeardTheNews
//
//  Created by Pop Web on 16/3/21.
//  Copyright © 2016年 paoguo. All rights reserved.
//

#import "guanggaoVC.h"
#import "UIImageView+WebCache.h"
#import "AppDelegate.h"
@interface guanggaoVC ()

@end

@implementation guanggaoVC

- (void)viewDidLoad {
    [super viewDidLoad];
    
    UIImageView *imgV = [[UIImageView alloc]initWithFrame:[UIScreen mainScreen].bounds];
    [self.view addSubview:imgV];
    
    imgV.userInteractionEnabled = YES;
    
    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
    [button setTitle:@"跳过" forState:UIControlStateNormal];
    button.layer.cornerRadius = 20;
    button.clipsToBounds = YES;
    button.titleLabel.font = [UIFont systemFontOfSize:13];
    [button addTarget:self action:@selector(tiaoguo) forControlEvents:UIControlEventTouchUpInside];
    button.frame = CGRectMake(0,0, 40, 40);
    button.center = CGPointMake(IPHONE_W - 40, 54);
    [button setBackgroundColor:[UIColor colorWithRed:0.0 green:0.0 blue:0.0 alpha:0.46]];
    [self.view addSubview:button];
    
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(tapAction)];
    [imgV addGestureRecognizer:tap];
    
    [NetWorkTool getIntoAppGuangGaoPage:@"1" andLimit:@"10" sccess:^(NSDictionary *responseObject) {
        if (TARGETED_DEVICE_IS_IPHONE_480){
            self.urlStr = [NSString stringWithFormat:@"%@%@",APPHostAds,responseObject[@"results"][0][@"ad_content"]];
            self.tapUrlStr = responseObject[@"results"][0][@"ad_name"];
            [imgV sd_setImageWithURL:[NSURL URLWithString:self.urlStr]];
            [self performSelector:@selector(afterAction) withObject:nil afterDelay:3.0f];
        }
        else if (TARGETED_DEVICE_IS_IPHONE_568){
            NSLog(@"IPHONE6");
            self.urlStr = [NSString stringWithFormat:@"%@%@",APPHostAds,responseObject[@"results"][1][@"ad_content"]];
            self.tapUrlStr = responseObject[@"results"][1][@"ad_name"];
            [imgV sd_setImageWithURL:[NSURL URLWithString:self.urlStr]];
            [self performSelector:@selector(afterAction) withObject:nil afterDelay:3.0f];
        }
        else if (TARGETED_DEVICE_IS_IPHONE_667){
            NSLog(@"IPHONE6P");
            self.urlStr = [NSString stringWithFormat:@"%@%@",APPHostAds,responseObject[@"results"][2][@"ad_content"]];
            self.tapUrlStr = responseObject[@"results"][2][@"ad_name"];
            [imgV sd_setImageWithURL:[NSURL URLWithString:self.urlStr]];
            [self performSelector:@selector(afterAction) withObject:nil afterDelay:3.0f];
        }
        else if (TARGETED_DEVICE_IS_IPHONE_736){
            self.urlStr = [NSString stringWithFormat:@"%@%@",APPHostAds,responseObject[@"results"][3][@"ad_content"]];
            self.tapUrlStr = responseObject[@"results"][3][@"ad_name"];
            [imgV sd_setImageWithURL:[NSURL URLWithString:self.urlStr]];
            [self performSelector:@selector(afterAction) withObject:nil afterDelay:3.0f];
        }
        else if (IS_IPAD){
            self.urlStr = [NSString stringWithFormat:@"%@%@",APPHostAds,responseObject[@"results"][3][@"ad_content"]];
            self.tapUrlStr = responseObject[@"results"][3][@"ad_name"];
            [imgV sd_setImageWithURL:[NSURL URLWithString:self.urlStr]];
            [self performSelector:@selector(afterAction) withObject:nil afterDelay:3.0f];
        }else if (TARGETED_DEVICE_IS_IPHONE_812 &&  [responseObject[@"results"][10][@"status"] isEqualToString:@"1"]){
            self.urlStr = [NSString stringWithFormat:@"%@%@",APPHostAds,responseObject[@"results"][3][@"ad_content"]];
            self.tapUrlStr = responseObject[@"results"][3][@"ad_name"];
            [imgV sd_setImageWithURL:[NSURL URLWithString:self.urlStr]];
            [self performSelector:@selector(afterAction) withObject:nil afterDelay:3.0f];
        }
        
    } failure:^(NSError *error)
     {
         NSLog(@"error = %@",error);
         [self performSelector:@selector(afterAction) withObject:nil];

     }];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    ExisFristOpenApp = YES;
}

- (void)tapAction {
    [[UIApplication sharedApplication]openURL:[NSURL URLWithString:self.tapUrlStr]];
//    [[UIApplication sharedApplication]openURL:[NSURL URLWithString:@"http://tingwen.me"]];
}

- (void)afterAction {
    [self.navigationController popViewControllerAnimated:NO];
    
}

- (void)tiaoguo {
    [self.navigationController popViewControllerAnimated:NO];
    NSLog(@"跳过");
}
@end
