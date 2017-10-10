//
//  AutoImageViewHeightFrameModel.m
//  JiDing
//
//  Created by zhangrongting on 2017/6/17.
//  Copyright © 2017年 zhangrongting. All rights reserved.
//

#import "AutoImageViewHeightFrameModel.h"
#import "UIImageView+WebCache.h"

@implementation AutoImageViewHeightFrameModel
- (void)setImageUrl:(NSString *)imageUrl
{
    _imageUrl = imageUrl;
    //判断图片URL获取的图片是否在缓存中，如果已经缓存，则直接获取如果未缓存，则进行下载
    if([[SDWebImageManager sharedManager] cachedImageExistsForURL:[NSURL URLWithString:imageUrl]]){
        UIImage* img = [[SDWebImageManager sharedManager].imageCache imageFromMemoryCacheForKey:[[SDWebImageManager sharedManager] cacheKeyForURL:[NSURL URLWithString:imageUrl]]];
        
        if(!img)
            img = [[SDWebImageManager sharedManager].imageCache imageFromDiskCacheForKey:[[SDWebImageManager sharedManager] cacheKeyForURL:[NSURL URLWithString:imageUrl]]];
        _image = img;
        _imageViewF = CGRectMake(_leftRightMargin?_leftRightMargin:5, _topBottomMargin?_topBottomMargin:5, SCREEN_WIDTH - 10, (SCREEN_WIDTH - 10)/img.size.width * img.size.height);
        _cellHeight = CGRectGetMaxY(_imageViewF) + 2* _topBottomMargin?_topBottomMargin:5;
        RTLog(@"%f",_cellHeight);
        
    }else{
        [[SDWebImageManager sharedManager] downloadImageWithURL:[NSURL URLWithString:imageUrl] options:SDWebImageRetryFailed|SDWebImageLowPriority progress:nil completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, BOOL finished, NSURL *imageURL) {
            if (image) {
                _image = image;
                _imageViewF = CGRectMake(_leftRightMargin?_leftRightMargin:5, _topBottomMargin?_topBottomMargin:5, SCREEN_WIDTH - 10, (SCREEN_WIDTH - 10)/image.size.width * image.size.height);
                _cellHeight = CGRectGetMaxY(_imageViewF) + 2* _topBottomMargin?_topBottomMargin:5;
                RTLog(@"%f",_cellHeight);
                //block通知界面刷新对应行cell
                if (self.downLoadImageSuccess) {
                    self.downLoadImageSuccess(image);
                }
            }
        }];
    }
}
/**
 调用该方法将图片数据数组转为图片frame模型数组
 
 @param imageUrlArray 图片数据数组
 @param tableView 当前图片tableView
 @param indexPath 当前起始图片的cell位置
 @return 返回frame模型数组
 */
+ (NSMutableArray *)frameArrayWithImageUrlArray:(NSMutableArray *)imageUrlArray tableView:(UITableView *)tableView indexPath:(NSIndexPath *)indexPath
{
    NSMutableArray *array = [NSMutableArray array];
    for (int i = 0; i<imageUrlArray.count; i++) {
        AutoImageViewHeightFrameModel *imageFrameModel = [[AutoImageViewHeightFrameModel alloc] init];
        imageFrameModel.downLoadImageSuccess = ^(UIImage *image) {
            //刷新对应行的cell
            [tableView reloadRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:indexPath.row + i inSection:indexPath.section]] withRowAnimation:UITableViewRowAnimationNone];
        };
        imageFrameModel.imageUrl = imageUrlArray[i];
        [array addObject:imageFrameModel];
    }
    return array;
}

@end
