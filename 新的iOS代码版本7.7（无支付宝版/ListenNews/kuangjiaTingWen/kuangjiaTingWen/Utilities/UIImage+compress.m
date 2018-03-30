//
//  UIImage+compress.m
//  DDMenuController
//
//  Created by Lin Yawen on 13-3-27.
//
//

#import "UIImage+compress.h"

@implementation UIImage (compress)

//压缩图片, 0 最高压缩率，质量低,   1 基本不压缩
-(NSData *)dataWithCompressQuality:(CGFloat)compressionQuality
{
    NSData *imgData = UIImageJPEGRepresentation(self, compressionQuality);
    return imgData;
}

//压缩图片到指定length


//降低质量，不改变分辨
-(NSData *)dataWithCompressLength:(CGFloat)length
{
    length = length * 1024;
    CGFloat quality = 1;
    NSData * imgData = UIImageJPEGRepresentation(self, quality);
    while (imgData.length > length) {
        quality -= 0.1;
        imgData = UIImageJPEGRepresentation(self,quality);
        if (quality <0.2)
            break;
    };
    return imgData;
}

//限制图片的最大分辨率和最大文件大小
-(NSData *)dataWithMaxFileSize:(CGFloat)fileSize maxSide:(CGFloat)maxSide{
    CGFloat quality = 1;
    NSData * imgData = [self limitImageToMaxSize:maxSide];
    
    while (imgData.length > fileSize) {
        quality -= 0.1;
        imgData = UIImageJPEGRepresentation(self,quality);
        if (quality <0.2)
            break;
    };
    return imgData;
}


- (NSData *)limitImageToMaxSize:(CGFloat)maxSide {
    NSData * imgData = UIImageJPEGRepresentation(self, 0.8);

    CGFloat original_width  = self.size.width;
    CGFloat original_height = self.size.height;
    if(original_width>maxSide || original_height>maxSide){
        CGFloat scale = original_width>original_height?(maxSide/original_width):(maxSide/original_height);
        CGSize newSize = CGSizeMake(original_width*scale, round(original_height * scale));
        CGRect scaleRect =  CGRectMake(0, 0, newSize.width, newSize.height );
        UIGraphicsBeginImageContext(CGSizeMake(original_width*scale, original_height*scale));
        [self drawInRect:scaleRect];
        UIImage* newImage = UIGraphicsGetImageFromCurrentImageContext();
        imgData = UIImageJPEGRepresentation(newImage, 0.8);
        UIGraphicsEndImageContext();

    }
    return imgData;
}

//降低分辨率，不改变质量
- (NSData *)imageWithScaledToLength:(CGFloat)length{
    NSData * imgData = UIImageJPEGRepresentation(self, 0.8);
    CGFloat scale = 1.0;
    CGFloat stepping = 0.2;//步进缩小0.2
    while (imgData.length > length) {
        if(scale > stepping*2){
            scale -= stepping;
        }else{
            break;
        }
        //NSLog(@"imageWithScaledToLength,scale: %f",scale);
        CGFloat original_width  = self.size.width;
        CGFloat original_height = self.size.height;
        CGSize newSize = CGSizeMake(original_width*scale, round(original_height * scale));
        CGRect scaleRect =  CGRectMake(0, 0, newSize.width, newSize.height );
        UIGraphicsBeginImageContext(CGSizeMake(original_width*scale, original_height*scale));
        [self drawInRect:scaleRect];
        UIImage* newImage = UIGraphicsGetImageFromCurrentImageContext();
        imgData = UIImageJPEGRepresentation(newImage, 0.8);
        UIGraphicsEndImageContext();
    };
    return imgData;
}

- (UIImage *)imageWithScaledToSize:(CGSize)newSize
{
    UIGraphicsBeginImageContext(newSize);
    [self drawInRect:CGRectMake(0,0,newSize.width,newSize.height)];
    UIImage* newImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return newImage;
}

-(UIImage *)imageBespreadFullScreen
{
    UIImage * ret = nil;
    UIScreen * screen = [UIScreen mainScreen];
    float imageWidth = self.size.width;
    float imageHeight = self.size.height;
    float width = 0;
    float height = 0;
    if (imageWidth < imageHeight)
    {
        //竖长图
        width = screen.applicationFrame.size.width * screen.scale;
        height = imageHeight/(imageWidth/width);
    }else
    {
        //横长图
        height = screen.applicationFrame.size.height * screen.scale;
        width = imageWidth/(imageHeight/height);
    }
    width = 640;
    height = 640;
    
    UIGraphicsBeginImageContext(CGSizeMake(width, height));
    [self drawInRect:CGRectMake(0, 0, width , height)];
    // 从当前context中创建一个改变大小后的图片
    ret = UIGraphicsGetImageFromCurrentImageContext();
    // 使当前的context出堆栈
    UIGraphicsEndImageContext();
    
    return ret;
}

@end
