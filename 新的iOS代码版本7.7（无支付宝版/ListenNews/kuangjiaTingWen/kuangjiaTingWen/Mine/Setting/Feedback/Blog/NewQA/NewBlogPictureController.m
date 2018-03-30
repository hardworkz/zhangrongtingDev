//
//  NewBlogPicController.m
//  KangShiFu_Elearnning
//
//  Created by Lin Yawen on 14-7-10.
//  Copyright (c) 2014年 Lin Yawen. All rights reserved.
//

#import "NewBlogPictureController.h"
#import "CTAssetsPickerController.h"
#import "NewBlogPictureCell.h"
#import "UIView+tap.h"
#import "UIImage+compress.h"
#import "NewQAController.h"

static NSString *const AddNewPicCellID = @"NewPicCell";

@interface NewBlogPictureController ()<UIGestureRecognizerDelegate>
@end

@implementation NewBlogPictureController
- (void)viewDidLoad{
    [super viewDidLoad];
    self.arrayOfPictures = [NSMutableArray array];
    self.arrayOfThumbnailPictures = [NSMutableArray array];
    
    [self.collectionView setUserInteractionEnabled:YES];
    
//    UISwipeGestureRecognizer *rightTapG = [[UISwipeGestureRecognizer alloc]initWithTarget:self.delegate action:@selector(tapPictureControllerG:)];
//    rightTapG.delegate = self;
//    [self.collectionView addGestureRecognizer:rightTapG];
//    [self.collectionView addTapGesWithTarget:self action:@selector(tapPictureControllerG:)];

}

-(void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    
}

#pragma mark - UICollectionViewDataSource

-(NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section{
    return [self.arrayOfThumbnailPictures count] + 1;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath{
    if (indexPath.row < [self.arrayOfThumbnailPictures count]) {
        NewBlogPictureCell * cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"NewBlogPictureCell" forIndexPath:indexPath];
        cell.iv.image = [self.arrayOfThumbnailPictures objectAtIndex:indexPath.row];
        cell.btnDelete.tag = indexPath.row;
        [cell.btnDelete addTarget:self action:@selector(delete:) forControlEvents:UIControlEventTouchUpInside];
        return cell;
    }
    else{
        UICollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:AddNewPicCellID forIndexPath:indexPath];
        return cell;
    }
}

- (UIEdgeInsets)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout insetForSectionAtIndex:(NSInteger)section{
    CGFloat leftWidth = SCREEN_WIDTH - (85 * 4 + 30);
    leftWidth = leftWidth > 0 ? leftWidth : 0;
    CGFloat margin = leftWidth / 2;
    return UIEdgeInsetsMake(5, 15 + margin, 0, 15 + margin);
}


- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath{
    if (indexPath.row < [self.arrayOfThumbnailPictures count]) {
        if(self.delegate && [self.delegate respondsToSelector:@selector(newBlogPictureController:didTapImageAtIndex:imageArry:)]){
            [self.delegate newBlogPictureController:self didTapImageAtIndex:indexPath.row imageArry:self.arrayOfPictures];
        }
    }
    else{
        [self.qaController.view endEditing:YES];
        [self.qaController actionSelectPhoto:nil];
    }
}

- (NSArray *)indexPathOfNewlyAddedAssets:(NSArray *)assets{
    NSMutableArray *indexPaths = [[NSMutableArray alloc] init];
    for (NSInteger i = self.arrayOfPictures.count; i < self.arrayOfPictures.count + assets.count ; i++){
        [indexPaths addObject:[NSIndexPath indexPathForItem:i inSection:0]];
    }
    return indexPaths;
}

-(void)loadAssets:(NSArray *)assets completion:(void (^)(void))completion{
    DefineWeakSelf;
    NSArray * indexpaths = [self indexPathOfNewlyAddedAssets:assets];
    __block void (^block)(void)  = completion;
    [self.collectionView performBatchUpdates:^{
        [weakSelf.collectionView insertItemsAtIndexPaths:indexpaths];
        for (ALAsset  * asset in assets) {
            //UIImage *img = [UIImage imageWithCGImage:asset.thumbnail];
            UIImage *img = [UIImage imageWithCGImage:asset.defaultRepresentation.fullScreenImage];
            if(img){
//                NSData * imageData = [img dataWithMaxFileSize:500*1024 maxSide:640.0];
//                [weakSelf.arrayOfPictures addObject:[UIImage imageWithData:imageData]];
                [weakSelf.arrayOfPictures addObject:img];
                [weakSelf.arrayOfThumbnailPictures addObject:[UIImage imageWithCGImage:asset.thumbnail]];
            }
        };
    } completion:^(BOOL finished) {
        if (block){
            block();
        };
    }];
}

-(void)addImage:(UIImage *)img completion:(void (^)(void)) completion;{
    DefineWeakSelf;
    NSMutableArray *indexPaths = [[NSMutableArray alloc] init];
    [indexPaths addObject:[NSIndexPath indexPathForItem:self.arrayOfPictures.count inSection:0]];
     __block void (^block)(void)  = completion;
    [self.collectionView performBatchUpdates:^{
        [weakSelf.collectionView insertItemsAtIndexPaths:indexPaths];
        
//        NSData * imageData = [img dataWithMaxFileSize:500 maxSide:640.0];
//        [weakSelf.arrayOfPictures addObject:[UIImage imageWithData:imageData]];
        [weakSelf.arrayOfPictures addObject:img];
        [weakSelf.arrayOfThumbnailPictures addObject:[img imageWithScaledToSize:CGSizeMake(1920, 1680)]];
    } completion:^(BOOL finished) {
        if (block){
            block();
        };
    }];
}

-(CGSize)contentSize{
    return self.collectionView.contentSize;
}

- (void)delete:(UIButton *)btn{
    [self.arrayOfPictures removeObjectAtIndex:btn.tag];
    [self.arrayOfThumbnailPictures removeObjectAtIndex:btn.tag];
    [self.collectionView reloadData];
}

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch{
    
    UICollectionViewCell *cell = [UICollectionViewCell new];
    if ([touch.view isKindOfClass:[cell.contentView class]] && [self.arrayOfThumbnailPictures count]) {
        //放过对单元格点击事件的拦截
        return NO;
    }else{
        return YES;
    }
    
}

- (void)tapPictureControllerG:(UITapGestureRecognizer *)tapGestureRecognizer{
    //TODO:发通知收起键盘
    [[NSNotificationCenter defaultCenter] postNotificationName:@"huishoujianpan" object:nil];
}
-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event{
    //TODO:发通知收起键盘
    [[NSNotificationCenter defaultCenter] postNotificationName:@"huishoujianpan" object:nil];
}


@end
