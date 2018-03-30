//
//  PhotoBrowserController.h
//  zfbuser
//
//  Created by Eric Wang on 15/7/17.
//  Copyright (c) 2015年 Eric. All rights reserved.
//

#import "MWPhotoBrowser.h"

/**
 *  二次封装了 MWPhotoBrowser,便于使用
 */
@interface PhotoBrowserController : MWPhotoBrowser<MWPhotoBrowserDelegate>

+ (instancetype)browserWithPhotos:(NSArray *)photos;

/**
 *  加载图片
 *
 *  @param phs 图片数组
 */
- (void)openPhotos:(NSArray *)phs;

@end
