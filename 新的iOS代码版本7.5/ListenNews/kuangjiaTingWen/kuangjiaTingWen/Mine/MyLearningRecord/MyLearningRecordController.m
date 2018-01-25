//
//  MyLearningRecordController.m
//  kuangjiaTingWen
//
//  Created by 泡果 on 2018/1/3.
//  Copyright © 2018年 zhimi. All rights reserved.
//

#import "MyLearningRecordController.h"

@interface MyLearningRecordController ()
{
    UILabel *totalTime;
    UILabel *dateLabel;
}
@property (strong,nonatomic)BezierCurveView *bezierView;
@property (strong,nonatomic)NSMutableArray *x_names;
@property (strong,nonatomic)NSMutableArray *targets;
@end

@implementation MyLearningRecordController
/**
 *  X轴值
 */
-(NSMutableArray *)x_names{
    if (!_x_names) {
        _x_names = [NSMutableArray array];
    }
    return _x_names;
}
/**
 *  Y轴值
 */
-(NSMutableArray *)targets{
    if (!_targets) {
        _targets = [NSMutableArray array];
    }
    return _targets;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self setUpView];
    [self setupDataView];
    [self setupData];
}
- (void)setupData
{
    [NetWorkTool postPaoGuoGetStudyRecordWithUser_id:ExdangqianUserUid sccess:^(NSDictionary *responseObject) {
        RTLog(@"%@",responseObject);
        if ([responseObject[status] intValue] == 1||[responseObject[status] intValue] == 0) {
            NSArray *dataArray = responseObject[results][@"time"];
            for (int i = 6;i>=0;i--) {
                NSDictionary *dict = dataArray[i];
                [self.x_names addObject:dict[@"date"]];
                [self.targets addObject:@([dict[@"study_time"] intValue]/60)];
            }
            //1.初始化
            _bezierView = [BezierCurveView initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, 60)];
            _bezierView.center = self.view.center;
            [self.view addSubview:_bezierView];
            
            //2.折线图
            [self drawLineChart];
            
            //设置数据
            if ([responseObject[results][@"totaltime"] intValue]/60 < 60) {
                totalTime.text = [NSString stringWithFormat:@"%d分钟",[responseObject[results][@"totaltime"] intValue]/60];
            }else{
                totalTime.text = [NSString stringWithFormat:@"%d小时%d分钟",[responseObject[results][@"totaltime"] intValue]/3600,[responseObject[results][@"totaltime"] intValue]%60];
            }
            dateLabel.text = [NSString stringWithFormat:@"%@天",responseObject[results][@"keepdays"]];
        }
        
    } failure:^(NSError *error) {
        
    }];
}
- (void)setupDataView
{
    totalTime = [[UILabel alloc]initWithFrame:CGRectMake(0, IPHONEX_TOP_H, IPHONE_W * 0.5, 30)];
    totalTime.textColor = [UIColor blackColor];
    totalTime.font = [UIFont boldSystemFontOfSize:15.0f];
    totalTime.text = @"0分钟";
    totalTime.backgroundColor = [UIColor clearColor];
    totalTime.textAlignment = NSTextAlignmentCenter;
    [self.view addSubview:totalTime];
    
    UILabel *totalTimeTextLabel = [[UILabel alloc]initWithFrame:CGRectMake(0, CGRectGetMaxY(totalTime.frame), IPHONE_W * 0.5, 25)];
    totalTimeTextLabel.textColor = [UIColor grayColor];
    totalTimeTextLabel.font = [UIFont boldSystemFontOfSize:13.0f];
    totalTimeTextLabel.text = @"学习时长";
    totalTimeTextLabel.backgroundColor = [UIColor clearColor];
    totalTimeTextLabel.textAlignment = NSTextAlignmentCenter;
    [self.view addSubview:totalTimeTextLabel];
    
    dateLabel = [[UILabel alloc]initWithFrame:CGRectMake(IPHONE_W * 0.5, IPHONEX_TOP_H, IPHONE_W * 0.5, 30)];
    dateLabel.textColor = [UIColor blackColor];
    dateLabel.font = [UIFont boldSystemFontOfSize:15.0f];
    dateLabel.text = @"0天";
    dateLabel.backgroundColor = [UIColor clearColor];
    dateLabel.textAlignment = NSTextAlignmentCenter;
    [self.view addSubview:dateLabel];
    
    UILabel *dateTextLabel = [[UILabel alloc]initWithFrame:CGRectMake(IPHONE_W * 0.5, CGRectGetMaxY(dateLabel.frame), IPHONE_W * 0.5, 25)];
    dateTextLabel.textColor = [UIColor grayColor];
    dateTextLabel.font = [UIFont boldSystemFontOfSize:13.0f];
    dateTextLabel.text = @"连续学习";
    dateTextLabel.backgroundColor = [UIColor clearColor];
    dateTextLabel.textAlignment = NSTextAlignmentCenter;
    [self.view addSubview:dateTextLabel];
    
    UILabel *unitTextLabel = [[UILabel alloc]initWithFrame:CGRectMake(30, CGRectGetMaxY(totalTimeTextLabel.frame) + 10, IPHONE_W, 20)];
    unitTextLabel.textColor = [UIColor grayColor];
    unitTextLabel.font = [UIFont boldSystemFontOfSize:13.0f];
    unitTextLabel.text = @"最近七天的学习时长/单位:分钟";
    unitTextLabel.backgroundColor = [UIColor clearColor];
    unitTextLabel.textAlignment = NSTextAlignmentLeft;
    [self.view addSubview:unitTextLabel];
    
    UIView *devider = [[UIView alloc] initWithFrame:CGRectMake(0, CGRectGetMaxY(dateTextLabel.frame) + 2.5 - 0.5, SCREEN_WIDTH, 0.5)];
    devider.backgroundColor = [UIColor lightGrayColor];
    devider.alpha = 0.2;
    [self.view addSubview:devider];
    
    UIView *deviderView = [[UIView alloc] initWithFrame:CGRectMake(0, CGRectGetMaxY(dateTextLabel.frame) + 2.5, SCREEN_WIDTH, 5)];
    deviderView.backgroundColor = [UIColor lightGrayColor];
    deviderView.alpha = 0.1;
    [self.view addSubview:deviderView];
    
    UIView *deviderThree = [[UIView alloc] initWithFrame:CGRectMake(0, CGRectGetMaxY(deviderView.frame) + 0.5, SCREEN_WIDTH, 0.5)];
    deviderThree.backgroundColor = [UIColor lightGrayColor];
    deviderThree.alpha = 0.2;
    [self.view addSubview:deviderThree];
    
    UIView *deviderTwo = [[UIView alloc] initWithFrame:CGRectMake(0, CGRectGetMaxY(unitTextLabel.frame) + 10 + 190, SCREEN_WIDTH, 0.5)];
    deviderTwo.backgroundColor = [UIColor lightGrayColor];
    deviderTwo.alpha = 0.5;
    [self.view addSubview:deviderTwo];
    
    UIView *bgView = [[UIView alloc] initWithFrame:CGRectMake(0, CGRectGetMaxY(deviderTwo.frame), SCREEN_WIDTH, SCREEN_HEIGHT)];
    bgView.backgroundColor = [UIColor lightGrayColor];
    bgView.alpha = 0.2;
    [self.view addSubview:bgView];
    
//    UILabel *addressLabel = [[UILabel alloc]initWithFrame:CGRectMake(IPHONE_W * 0.5 - 30, IS_IPHONEX?SCREEN_HEIGHT - IPHONEX_BOTTOM_H:SCREEN_HEIGHT - 20, IPHONE_W * 0.5, 20)];
//    addressLabel.textColor = [UIColor whiteColor];
//    addressLabel.font = [UIFont boldSystemFontOfSize:13.0f];
//    addressLabel.text = @"www.tingwen.me";
//    addressLabel.backgroundColor = [UIColor clearColor];
//    addressLabel.textAlignment = NSTextAlignmentRight;
//    [self.view addSubview:addressLabel];
}
- (void)setUpView
{
    self.automaticallyAdjustsScrollViewInsets = NO;
    self.extendedLayoutIncludesOpaqueBars = NO;
    [self.view setBackgroundColor:[UIColor whiteColor]];
    UIView *topView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, IPHONE_W, 64)];
    [topView setUserInteractionEnabled:YES];
    topView.backgroundColor = [UIColor whiteColor];
    [self.view addSubview:topView];
    
    UIButton *leftBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    leftBtn.frame = CGRectMake(10, 25, 35, 35);
    [leftBtn setImageEdgeInsets:UIEdgeInsetsMake(5, 0, 5, 10)];
    [leftBtn setImage:[UIImage imageNamed:@"back"] forState:UIControlStateNormal];
    leftBtn.accessibilityLabel = @"返回";
    [leftBtn addTarget:self action:@selector(back) forControlEvents:UIControlEventTouchUpInside];
    [topView addSubview:leftBtn];
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(back)];
    [topView addGestureRecognizer:tap];
    
    UILabel *topLab = [[UILabel alloc]initWithFrame:CGRectMake(50, 30, IPHONE_W - 100, 30)];
    topLab.textColor = [UIColor blackColor];
    topLab.font = [UIFont boldSystemFontOfSize:17.0f];
    topLab.text = @"听闻学习记录";
    topLab.backgroundColor = [UIColor whiteColor];
    topLab.textAlignment = NSTextAlignmentCenter;
    [topView addSubview:topLab];
    
    UIView *seperatorLine = [[UIView alloc]initWithFrame:CGRectMake(0, 63.5, SCREEN_WIDTH, 0.5)];
    [seperatorLine setBackgroundColor:[UIColor lightGrayColor]];
    [topView addSubview:seperatorLine];
    
    //适配iPhoneX导航栏
    if (IS_IPHONEX) {
        topView.frame = CGRectMake(0, 0, IPHONE_W, 88);
        leftBtn.frame = CGRectMake(10, 25 + 24, 35, 35);
        topLab.frame = CGRectMake(50, 30 + 24, IPHONE_W - 100, 30);
        seperatorLine.frame = CGRectMake(0, 63.5 + 24, SCREEN_WIDTH, 0.5);
    }else{
        topView.frame = CGRectMake(0, 0, IPHONE_W, 64);
        leftBtn.frame = CGRectMake(10, 25, 35, 35);
        topLab.frame = CGRectMake(50, 30, IPHONE_W - 100, 30);
        seperatorLine.frame = CGRectMake(0, 63.5, SCREEN_WIDTH, 0.5);
    }
    
    UISwipeGestureRecognizer *rightSwipe = [[UISwipeGestureRecognizer alloc]initWithTarget:self action:@selector(back)];
    [rightSwipe setDirection:UISwipeGestureRecognizerDirectionRight];
    [self.view addGestureRecognizer:rightSwipe];
}
- (void)back
{
    [self.navigationController popViewControllerAnimated:YES];
}
//画折线图
-(void)drawLineChart
{
    //曲线
    [_bezierView drawLineChartViewWithX_Value_Names:self.x_names TargetValues:self.targets LineType:LineType_Curve];
}

@end
