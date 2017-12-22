//
//  AutoImageViewHeightFrameModel.h
//  JiDing
//
//  Created by zhangrongting on 2017/6/17.
//  Copyright © 2017年 zhangrongting. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface AutoImageViewHeightFrameModel : NSObject
/**
 图片下载完成回调block
 */
@property (copy, nonatomic) void (^downLoadImageSuccess)(UIImage *image);

/**
 图片在cell上左右屏间隔距离，默认为5
 */
@property (assign, nonatomic) CGFloat leftRightMargin;

/**
 图片在cell上下间隔距离，默认为5
 */
@property (assign, nonatomic) CGFloat topBottomMargin;

/**
 图片URL地址
 */
@property (strong, nonatomic) NSString *imageUrl;

/**
 图片对象
 */
@property (strong, nonatomic,readonly) UIImage *image;

/**
 图片控件frame
 */
@property (assign, nonatomic,readonly) CGRect imageViewF;

/**
 返回cell高度
 */
@property (assign, nonatomic) CGFloat cellHeight;
/**
 调用该方法将图片数据数组转为图片frame模型数组

 @param imageUrlArray 图片数据数组
 @param tableView 当前图片tableView
 @param indexPath 当前起始图片的cell位置
 @return 返回frame模型数组
 */
+ (NSMutableArray *)frameArrayWithImageUrlArray:(NSMutableArray *)imageUrlArray tableView:(UITableView *)tableView indexPath:(NSIndexPath *)indexPath;
@end
