//
//  UIImage+compress.h
//  DDMenuController
//
//  Created by Lin Yawen on 13-3-27.
//
//

#import <UIKit/UIKit.h>

@interface UIImage (compress)

/**
 *  限制图片的最大分辨率和最大文件大小
 *
 *  @param fileSize 文件的大小，eg: 压缩图片到 100 KB，则为100*YWIMAGECOMPRESS_KB
 *  @param maxSide  最长边的分辨率
 *
 *  @return 压缩后的图片NSData
 */
-(NSData *)dataWithMaxFileSize:(CGFloat)fileSize maxSide:(CGFloat)maxSide;

//压缩图片, 0 最高压缩率，质量低,   1 基本不压缩
-(NSData *)dataWithCompressQuality:(CGFloat)compressionQuality;

//压缩图片到指定length, 单位: Byte
//eg: 压缩图片到 100 KB
// [imgObj dataWithCompressLength:100]
//降低质量，不改变分辨
-(NSData *)dataWithCompressLength:(CGFloat)length;

//降低分辨率，不改质量
-(NSData *)imageWithScaledToLength:(CGFloat)length;

//压缩图片到指定的 size
- (UIImage *)imageWithScaledToSize:(CGSize)newSize;

//图片等比拉伸至充满整个屏幕，一般是 把超大图 缩小成 屏幕一样大小时用。
-(UIImage *)imageBespreadFullScreen;


@end
