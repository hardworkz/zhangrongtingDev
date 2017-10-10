//
//  NewBlogPicController.h
//  KangShiFu_Elearnning
//
//  Created by Lin Yawen on 14-7-10.
//  Copyright (c) 2014年 Lin Yawen. All rights reserved.
//

#import <UIKit/UIKit.h>


@class NewBlogPictureController;

@protocol NewBlogPictureControllerDelegete <NSObject>

- (void)newBlogPictureController:(NewBlogPictureController *)controller didTapImageAtIndex:(NSInteger)idx imageArry:(NSArray *)imageArray;

@end

/**
 *
 *  [Tab] 同事圈模块 -- 发同事圈 -- 图片容器
 *
 */
@class NewQAController;

@interface NewBlogPictureController : UICollectionViewController
//图片  array of UIImage
@property(nonatomic,strong)NSMutableArray * arrayOfPictures;
//collection view cell使用缩略图显示
@property(nonatomic,strong)NSMutableArray * arrayOfThumbnailPictures;

@property(nonatomic,weak) NewQAController *qaController;

@property(nonatomic,weak) id<NewBlogPictureControllerDelegete> delegate;
/**
 *  从相册选图
 *
 *  @param assets array of ALAsset
 */
-(void)loadAssets:(NSArray *)assets completion:(void (^)(void)) completion;

/**
 *  加载单张图片，一般是拍照后
 *
 *  @param img 拍照取得的照片
 */
-(void)addImage:(UIImage *)img completion:(void (^)(void)) completion;

-(CGSize)contentSize;
@end
