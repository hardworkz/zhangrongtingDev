//
//  ClassImageViewCellFrameModel.h
//  kuangjiaTingWen
//
//  Created by 泡果 on 2017/6/2.
//  Copyright © 2017年 zhimi. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ClassImageViewCellFrameModel : NSObject
@property (copy, nonatomic) void (^downLoadImageSuccess)(UIImage *image);
@property (strong, nonatomic) NSString *imageUrl;
@property (strong, nonatomic) UIImage *image;
@property (assign, nonatomic) CGRect imageViewF;
@property (assign, nonatomic) CGFloat cellHeight;
@end
