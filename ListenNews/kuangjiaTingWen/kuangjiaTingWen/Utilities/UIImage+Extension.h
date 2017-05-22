//
//  UIImage+Extension.h
//  New
//
//  Created by Liao on 15/11/20.
//  Copyright © 2015年 Liao. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIImage (Extension)
+ (UIImage *)imageWithNamed:(NSString *)name;
+ (UIImage *)resizeImageWithNamed:(NSString *)name;
+ (UIImage *)imageWithColor:(UIColor *)color;
+ (UIImage *)resizableImage:(NSString *)name;
///* 让图片旋转回正确位置方法 */
//+ (UIImage *)fixOrientation:(UIImage *)aImage;
@end
