//
//  TradingRecordViewController.m
//  kuangjiaTingWen
//
//  Created by Zhimi on 17/2/17.
//  Copyright © 2017年 贺楠. All rights reserved.
//

#import "TradingRecordViewController.h"
#import "HMSegmentedControl.h"
#import "TradingRecordTableViewCell.h"

@interface TradingRecordViewController ()<UIScrollViewDelegate,UITableViewDelegate,UITableViewDataSource>

@property (nonatomic, strong) UIScrollView *scrollView;
@property (nonatomic, strong) HMSegmentedControl *segmentedControl;

@property (nonatomic, strong) UITableView *consumeRecordTableView;
@property (nonatomic, strong) UITableView *reChargeRecordTableView;

@property (nonatomic, strong) NSArray *consumeDataArr;
@property (nonatomic, strong) NSArray *reChargeDataArr;

@property (nonatomic, strong) UILabel *noConsumeDatalabel;
@property (nonatomic, strong) UILabel *noReChargeDatalabel;

@end

@implementation TradingRecordViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setupData];
    [self setupView];
    
}

- (void)setupData{
    self.consumeDataArr = nil;
    self.reChargeDataArr = nil;
    [self loadData];
}

- (void)setupView{
    [self setTitle:@"交易记录"];
    [self enableAutoBack];
    self.extendedLayoutIncludesOpaqueBars = YES;
    [self.view setBackgroundColor:[UIColor whiteColor]];
    UISwipeGestureRecognizer *rightSwipe = [[UISwipeGestureRecognizer alloc]initWithTarget:self action:@selector(back)];
    [rightSwipe setDirection:UISwipeGestureRecognizerDirectionRight];
    [self.view addGestureRecognizer:rightSwipe];
    
    self.segmentedControl = [[HMSegmentedControl alloc] initWithSectionTitles:@[@"消费记录", @"充值记录"]];
    self.segmentedControl.autoresizingMask = UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleWidth;
    self.segmentedControl.frame = CGRectMake(0,IS_IPHONEX?88:64, SCREEN_WIDTH, 40);
    self.segmentedControl.backgroundColor = gSubColor;
    self.segmentedControl.segmentEdgeInset = UIEdgeInsetsMake(0, 10, 0, 10);
    self.segmentedControl.selectionStyle = HMSegmentedControlSelectionStyleFullWidthStripe;
    self.segmentedControl.selectionIndicatorLocation = HMSegmentedControlSelectionIndicatorLocationDown;
    self.segmentedControl.verticalDividerEnabled = YES;
    self.segmentedControl.verticalDividerColor = gTextColorSub;
    self.segmentedControl.selectionIndicatorColor = gMainColor;
    self.segmentedControl.selectionIndicatorBoxColor = [UIColor whiteColor];
    self.segmentedControl.selectionIndicatorHeight = 3.0;
    self.segmentedControl.verticalDividerWidth = 1.0f;
    [self.segmentedControl setTitleFormatter:^NSAttributedString *(HMSegmentedControl *segmentedControl, NSString *title, NSUInteger index, BOOL selected) {
        if (selected) {
            NSAttributedString *attString = [[NSAttributedString alloc] initWithString:title attributes:@{NSForegroundColorAttributeName :gMainColor}];
            return attString;
        }
        else{
            NSAttributedString *attString = [[NSAttributedString alloc] initWithString:title attributes:@{NSForegroundColorAttributeName :gTextDownload}];
            return attString;
        }
        
    }];
    [self.segmentedControl addTarget:self action:@selector(segmentedControlChangedValue:) forControlEvents:UIControlEventValueChanged];
    DefineWeakSelf;
    [self.segmentedControl setIndexChangeBlock:^(NSInteger index) {
        [weakSelf.scrollView scrollRectToVisible:CGRectMake(SCREEN_WIDTH * index, 0, SCREEN_WIDTH,SCREEN_HEIGHT) animated:YES];
    }];
    [self.view addSubview:self.segmentedControl];
    
    self.scrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0,IS_IPHONEX?128:104, SCREEN_WIDTH, SCREEN_HEIGHT - 104)];
    self.scrollView.backgroundColor = [UIColor whiteColor];
    self.scrollView.pagingEnabled = YES;
    self.scrollView.showsHorizontalScrollIndicator = NO;
    self.scrollView.contentSize = CGSizeMake(SCREEN_WIDTH * 2, SCREEN_HEIGHT - 104);
    self.scrollView.delegate = self;
    [self.scrollView scrollRectToVisible:CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_HEIGHT - 104) animated:NO];
    [self.view addSubview:self.scrollView];
    
    
    self.consumeRecordTableView = [[UITableView alloc]initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, self.scrollView.frame.size.height) style:UITableViewStylePlain];
    [self.consumeRecordTableView setDelegate:self];
    [self.consumeRecordTableView setDataSource:self];
    [self.consumeRecordTableView setSeparatorStyle:UITableViewCellSeparatorStyleNone];
    [self.scrollView addSubview:self.consumeRecordTableView];
    
    self.reChargeRecordTableView = [[UITableView alloc]initWithFrame:CGRectMake(SCREEN_WIDTH, 0, SCREEN_WIDTH, self.scrollView.frame.size.height) style:UITableViewStylePlain];
    [self.reChargeRecordTableView setDelegate:self];
    [self.reChargeRecordTableView setDataSource:self];
    [self.reChargeRecordTableView setSeparatorStyle:UITableViewCellSeparatorStyleNone];
    [self.scrollView addSubview:self.reChargeRecordTableView];
    
}

- (void)segmentedControlChangedValue:(HMSegmentedControl *)segmentedControl {
    NSLog(@"Selected index %ld (via UIControlEventValueChanged)", (long)segmentedControl.selectedSegmentIndex);
}

- (void)loadData{
    
    [NetWorkTool use_recordWithaccessToken:AvatarAccessToken sccess:^(NSDictionary *responseObject) {
        if ([responseObject[@"status"] integerValue] == 1) {
            NSLog(@"%@",responseObject);
            if ([responseObject[@"results"] isKindOfClass:[NSArray class]]) {
                self.consumeDataArr = responseObject[@"results"];
            }
            else{
                self.consumeDataArr = nil;
            }
            
            [self.consumeRecordTableView reloadData];
        }
    } failure:^(NSError *error) {
        //
    }];
    
    [NetWorkTool recharge_recordWithaccessToken:AvatarAccessToken sccess:^(NSDictionary *responseObject) {
        if ([responseObject[@"status"] integerValue] == 1) {
            NSLog(@"%@",responseObject);
            if ([responseObject[@"results"] isKindOfClass:[NSArray class]]) {
                self.reChargeDataArr = responseObject[@"results"];
            }
            else{
                self.reChargeDataArr = nil;
            }
            [self.reChargeRecordTableView reloadData];
        }
    } failure:^(NSError *error) {
        //
    }];
    
    
}

- (void)back{
    [self.navigationController popViewControllerAnimated:YES];
}

#pragma mark - UIScrollViewDelegate

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
    CGFloat pageWidth = self.scrollView.frame.size.width;
    NSInteger page = self.scrollView.contentOffset.x / pageWidth;
    
    [self.segmentedControl setSelectedSegmentIndex:page animated:YES];
}

#pragma mark - UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 1;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 76.0;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    if (tableView == self.consumeRecordTableView) {
        if (!self.consumeDataArr.count) {
            if (!_noConsumeDatalabel) {
                _noConsumeDatalabel = [[UILabel alloc]initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, 20)];
                _noConsumeDatalabel.textAlignment = NSTextAlignmentCenter;
                _noConsumeDatalabel.text = @"暂无消费记录";
                _noConsumeDatalabel.textColor = [UIColor lightGrayColor];
                _noConsumeDatalabel.center = self.consumeRecordTableView.center;
            
                [self.consumeRecordTableView addSubview:_noConsumeDatalabel];
            }else {
                [self.consumeRecordTableView addSubview:_noConsumeDatalabel];
            }
        }else {
            [_noConsumeDatalabel removeFromSuperview];
        }
        return self.consumeDataArr.count;
    }
    else if (tableView == self.reChargeRecordTableView){
        if (!self.reChargeDataArr.count) {
            if (!_noReChargeDatalabel) {
                _noReChargeDatalabel = [[UILabel alloc]initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, 20)];
                _noReChargeDatalabel.textAlignment = NSTextAlignmentCenter;
                _noReChargeDatalabel.text = @"无充值记录";
                _noReChargeDatalabel.textColor = [UIColor lightGrayColor];
                _noReChargeDatalabel.center = self.reChargeRecordTableView.center;
                [self.reChargeRecordTableView addSubview:_noReChargeDatalabel];
            }else {
                [self.reChargeRecordTableView addSubview:_noReChargeDatalabel];
            }
        }else {
            [_noReChargeDatalabel removeFromSuperview];
        }
        return self.reChargeDataArr.count;
    }
    else{
        return 0;
    }
    
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    if (tableView == self.consumeRecordTableView) {
        static NSString *identifier = @"consumeRecordTableViewCell";
        UITableViewCell *cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identifier];
        if (!cell){
            cell = [tableView dequeueReusableCellWithIdentifier:identifier];
        }
        UILabel *titleLabel = [[UILabel alloc]initWithFrame:CGRectMake(10, 15, SCREEN_WIDTH - 100, 20)];
        [titleLabel setFont:gFontMain14];
        [titleLabel setTextAlignment:NSTextAlignmentLeft];
        [titleLabel setTextColor:gTextColorBackground];
        [cell.contentView addSubview:titleLabel];
        
        UILabel *dateLabel = [[UILabel alloc]initWithFrame:CGRectMake(10, 50, 200, 20)];
        [dateLabel setFont:gFontSub11];
        [dateLabel setTextColor:UIColorFromHex(0x999999)];
        [cell.contentView addSubview:dateLabel];
        
        UILabel *countLabel = [[UILabel alloc]initWithFrame:CGRectMake(SCREEN_WIDTH - 80, 23, 70, 30)];
        [countLabel setFont:gFontMain14];
        [countLabel setTextColor:UIColorFromHex(0xF67824)];
        [cell.contentView addSubview:countLabel];
        
        if ([self.consumeDataArr count]) {
            [titleLabel setText:[NSString stringWithFormat:@"赞赏%@",self.consumeDataArr[indexPath.row][@"name"]]];
            //时间戳转时间
            NSDateFormatter* formatter = [[NSDateFormatter alloc] init];
            [formatter setDateFormat:@"yyyy-MM-dd HH:mm"];
            NSString *timeStr = [self stringWithTime:[(self.consumeDataArr[indexPath.row][@"date"]) integerValue]];
            [dateLabel setText:timeStr];
            [countLabel setText:[NSString stringWithFormat:@"%@听币",self.consumeDataArr[indexPath.row][@"money"]]];
        }
        UIView *line = [[UIView alloc]initWithFrame:CGRectMake(0,75, SCREEN_WIDTH,0.5)];
        [line setBackgroundColor:nMineNameColor];
        [cell.contentView addSubview:line];
        
    return cell;
    }
    else{
        static NSString *shezhiidentify = @"reChargeRecordTableViewCell";
        UITableViewCell *cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:shezhiidentify];
        if (!cell){
            cell = [tableView dequeueReusableCellWithIdentifier:shezhiidentify];
        }
        UILabel *titleLabel = [[UILabel alloc]initWithFrame:CGRectMake(10, 15, SCREEN_WIDTH - 100, 20)];
         [titleLabel setTextAlignment:NSTextAlignmentLeft];
        [titleLabel setFont:gFontMain14];
        [titleLabel setTextColor:gTextColorBackground];
        [cell.contentView addSubview:titleLabel];
        
        UILabel *dateLabel = [[UILabel alloc]initWithFrame:CGRectMake(10, 50, 200, 20)];
        [dateLabel setFont:gFontSub11];
        [dateLabel setTextColor:UIColorFromHex(0x999999)];
        [cell.contentView addSubview:dateLabel];
        
        UILabel *countLabel = [[UILabel alloc]initWithFrame:CGRectMake(SCREEN_WIDTH - 80, 23, 70, 30)];
        [countLabel setFont:gFontMain14];
        [countLabel setTextColor:UIColorFromHex(0xF67824)];
        [cell.contentView addSubview:countLabel];
        if ([self.reChargeDataArr count]) {
            [titleLabel setText:self.reChargeDataArr[indexPath.row][@"method"]];
            [dateLabel setText:self.reChargeDataArr[indexPath.row][@"date"]];
            [countLabel setText:[NSString stringWithFormat:@"%@听币",self.reChargeDataArr[indexPath.row][@"money"]]];
        }
        UIView *line = [[UIView alloc]initWithFrame:CGRectMake(0,75, SCREEN_WIDTH,0.5)];
        [line setBackgroundColor:nMineNameColor];
        [cell.contentView addSubview:line];
        
        return cell;
    }
}

- (NSString *)stringWithTime:(NSTimeInterval)timestamp {
    //设置时间显示格式
    NSDateFormatter *formatter = [[NSDateFormatter alloc]init];
    [formatter setDateStyle:NSDateFormatterMediumStyle];
    [formatter setTimeStyle:NSDateFormatterShortStyle];
    //先设置好dateStyle、timeStyle,再设置格式
    [formatter setDateFormat:@"YYYY-MM-dd HH:mm"];
    NSDate *date = [NSDate dateWithTimeIntervalSince1970:timestamp];
    //将NSDate按格式转化为对应的时间格式字符串
    NSString *timesString = [formatter stringFromDate:date];
    
    return timesString;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
