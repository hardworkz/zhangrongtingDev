//
//  MultiImageView.h
//  zfbuser
//
//  Created by Eric on 15/7/17.
//  Copyright (c) 2015年 Eric. All rights reserved.
//

#import <UIKit/UIKit.h>

/**
 *  可以加载多个图片的View，能改变自身的大小来自动适应图片的数量(1~9 张)，基于 autolayout
 */
//TODO:  用 UICollectionView 替代，重写 intrinsicContentSize


@class MultiImageView;

@protocol MultiImageViewDelegate <NSObject>

/**
 *  点击图片代理
 *
 *  @param multView multImageView
 *  @param imgv     点击的那个图
 *  @param idx      点击的图的索引
 */
- (void)multiImageView:(MultiImageView *)multView
      didTapImageView:(UIImageView *)imgv
              AtIndex:(NSInteger)idx;

@end


typedef void(^ MultiImageViewTapBlock)(MultiImageView * view,UIImageView * imgv,NSInteger idx);


@interface MultiImageView : UIView{
    NSArray * _images;
    NSMutableArray * _subImageViews;// 考虑是否需要预先创建
    NSInteger _imageViewCount;//预先创建的imageview 数量,default 9
    BOOL _isDataLoaded;
}

// nsarray of NSURl
@property(nonatomic,retain)NSArray * images;

// default 10,10,10,10
@property(nonatomic,assign)UIEdgeInsets contentInset;

@property(nonatomic,weak)id<MultiImageViewDelegate> delegate;

/**
 *  当 该view没有在列表上展现的时候，取消图片下载，default yes
 */
@property(nonatomic,assign)BOOL cancelNetworkWhenReuse;

/**
 *  点击图片回调
 *
 *  @param doReport block
 */
- (void)setTapImageBlock:(MultiImageViewTapBlock)block;

- (void)prepareForReuse;

- (CGSize)sizeForContent:(NSArray *)images;

@end
