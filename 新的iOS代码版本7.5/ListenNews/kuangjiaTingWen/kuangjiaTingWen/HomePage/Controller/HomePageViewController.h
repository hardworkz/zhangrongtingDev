//
//  HomePageViewController.h
//  kuangjiaTingWen
//
//  Created by Zhimi on 17/3/20.
//  Copyright © 2017年 zhimi. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef NS_ENUM(NSInteger, LoadType) {
    LoadTypeNewData = 0,//刷新
    LoadTypeMoreData,//加载更多
    LoadTypeNotData,//无数据时加载
};
@interface HomePageViewController : UIViewController

@end
