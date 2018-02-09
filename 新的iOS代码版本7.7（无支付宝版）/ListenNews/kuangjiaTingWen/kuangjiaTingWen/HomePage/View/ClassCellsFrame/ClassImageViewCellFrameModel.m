//
//  ClassImageViewCellFrameModel.m
//  kuangjiaTingWen
//
//  Created by 泡果 on 2017/6/2.
//  Copyright © 2017年 zhimi. All rights reserved.
//

#import "ClassImageViewCellFrameModel.h"
#import "UIImageView+WebCache.h"

@implementation ClassImageViewCellFrameModel
- (void)setImageUrl:(NSString *)imageUrl
{
    _imageUrl = imageUrl;
    
    if([[SDWebImageManager sharedManager] cachedImageExistsForURL:[NSURL URLWithString:imageUrl]]){
        UIImage* img = [[SDWebImageManager sharedManager].imageCache imageFromMemoryCacheForKey:[[SDWebImageManager sharedManager] cacheKeyForURL:[NSURL URLWithString:imageUrl]]];
        
        if(!img)
            img = [[SDWebImageManager sharedManager].imageCache imageFromDiskCacheForKey:[[SDWebImageManager sharedManager] cacheKeyForURL:[NSURL URLWithString:imageUrl]]];
        _image = img;
        _imageViewF = CGRectMake(5, 5, SCREEN_WIDTH - 10, (SCREEN_WIDTH - 10)/img.size.width * img.size.height);
        _cellHeight = CGRectGetMaxY(_imageViewF) + 5;
        
    }else{
        [[SDWebImageManager sharedManager] downloadImageWithURL:[NSURL URLWithString:imageUrl] options:SDWebImageRetryFailed|SDWebImageLowPriority progress:nil completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, BOOL finished, NSURL *imageURL) {
            if (image) {
                _image = image;
                _imageViewF = CGRectMake(5, 5, SCREEN_WIDTH - 10, (SCREEN_WIDTH - 10)/image.size.width * image.size.height);
                _cellHeight = CGRectGetMaxY(_imageViewF) + 5;
                //block通知界面刷新对应行cell
                if (self.downLoadImageSuccess) {
                    self.downLoadImageSuccess(image);
                }
            }
        }];
    }
}
@end
