//
//  TBCircleScrollView.h
//  折点点
//
//  Created by 曲天白 on 15/12/3.
//  Copyright © 2015年 yike. All rights reserved.
//

#import <UIKit/UIKit.h>
//@class TBCircleScrollView;
//@protocol CycleScrollViewDelegate<NSObject>
//- (void)cycleScrollView:(TBCircleScrollView *)cycleScrollView didSelectImageView:(NSInteger)index;
//@end
@interface TBCircleScrollView : UIView<UIScrollViewDelegate>
@property (nonatomic, strong) NSArray *imageArray;
@property (nonatomic, strong) UIScrollView *scrollView;
@property (nonatomic, strong) UILabel *dibuLab;
@property (nonatomic, assign) NSInteger *ztADCount;
//@property (nonatomic, weak) id<CycleScrollViewDelegate> delegate;
@property (nonatomic,strong)NSString *biaozhiStr;
- (id)initWithFrame:(CGRect)frame andArr:(NSArray *)infoArr;
//@property (nonatomic, strong) NSArray *infoArr;

@end
