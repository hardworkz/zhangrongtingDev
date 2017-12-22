//
//  BatchdownloadViewController.m
//  kuangjiaTingWen
//
//  Created by 泡果 on 16/8/8.
//  Copyright © 2016年 贺楠. All rights reserved.
//

#import "BatchdownloadViewController.h"
#import "UIView+tap.h"
#import "AIDatePickerController.h"
#import "SelectedNewsTypeView.h"
#import "AppDelegate.h"
#import "BatchDownloadTableTableViewController.h"

@interface BatchdownloadViewController ()

@property (strong, nonatomic) UIView *topbgView;
@property (strong, nonatomic) UIButton *confirButton;
@property (strong, nonatomic) UIButton *startDateButton;
@property (strong, nonatomic) UIButton *endDateButton;
@property (strong, nonatomic) UIButton *newsTypeButton;
@property (strong, nonatomic) NSDate *startDate;
@property (strong, nonatomic) NSDate *endDate;
@property (strong, nonatomic) NSString *newsType;


@end

@implementation BatchdownloadViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self setupData];
    [self setupView];
    
}

- (void)setupData {
    
    self.startDate = nil;
    self.endDate = nil;
    self.newsType = nil;
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(addDownload:) name:@"addDownload" object:nil];
    
}

- (void)setupView {
    
    [self.view setBackgroundColor:gSubColor];
    [self.view addSubview:self.topbgView];
    [self.view addSubview:self.confirButton];
}

- (void)SVPDismiss {
    [SVProgressHUD dismiss];
}


#pragma mark - NSNotification
- (void)addDownload:(NSNotification *)notification {
    [self setupData];
}

#pragma mark - Setter

- (void)setStartDate:(NSDate *)startDate{
    _startDate = startDate;
    if (startDate == nil) {
        [self.startDateButton setTitle:@"点击选择" forState:UIControlStateNormal];
    }
    else{
        [self.startDateButton setTitle:[_startDate stringWithFormat:@"yyyy-MM-dd"] forState:UIControlStateNormal];
    }
}

- (void)setnewsType:(NSString *)newsType{
    _newsType = newsType;
    if (newsType == nil) {
        [self.newsTypeButton setTitle:@"点击选择" forState:UIControlStateNormal];
    }
    else{
        [self.newsTypeButton setTitle:_newsType forState:UIControlStateNormal];
    }
}

- (void)setEndDate:(NSDate *)endDate{
    _endDate = endDate;
    if (endDate == nil) {
        [self.endDateButton setTitle:@"点击选择" forState:UIControlStateNormal];
    }
    else{
        [self.endDateButton setTitle:[_endDate stringWithFormat:@"yyyy-MM-dd"] forState:UIControlStateNormal];
    }
}

#pragma mark - getter

- (UIView *)topbgView {
    if (!_topbgView) {
        _topbgView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, 130)];
        [_topbgView setBackgroundColor:[UIColor whiteColor]];
        [_topbgView setUserInteractionEnabled:YES];
        NSArray *titleArr = @[@"起始时间:",@"结束时间:",@"新闻分类:"];
        for (int i = 0 ; i < 3 ; i ++ ) {
            UILabel *titleLabel = [[UILabel alloc]initWithFrame:CGRectMake(15, 40 * i + 5, 80, 40)];
            [titleLabel setText:titleArr[i]];
            [_topbgView addSubview:titleLabel];
        }
        if (!_startDateButton) {
            _startDateButton = [UIButton buttonWithType:UIButtonTypeCustom];
            [_startDateButton setFrame:CGRectMake(100, 5, 100, 40)];
            [_startDateButton.titleLabel setFont:gFontMain14];
            [_startDateButton setTitleColor:gTextColorSub forState:UIControlStateNormal];
            [_startDateButton setTitle:@"点击选择" forState:UIControlStateNormal];
            [_startDateButton setTag:100 ];
            [_startDateButton addTarget:self action:@selector(selectedAction:) forControlEvents:UIControlEventTouchUpInside];
        }
        if (!_endDateButton) {
            _endDateButton = [UIButton buttonWithType:UIButtonTypeCustom];
            [_endDateButton setFrame:CGRectMake(100, 5 + 40, 100, 40)];
            [_endDateButton.titleLabel setFont:gFontMain14];
            [_endDateButton setTitleColor:gTextColorSub forState:UIControlStateNormal];
            [_endDateButton setTitle:@"点击选择" forState:UIControlStateNormal];
            [_endDateButton setTag:101 ];
            [_endDateButton addTarget:self action:@selector(selectedAction:) forControlEvents:UIControlEventTouchUpInside];
        }
        if (!_newsTypeButton) {
            _newsTypeButton = [UIButton buttonWithType:UIButtonTypeCustom];
            [_newsTypeButton setFrame:CGRectMake(100, 5 + 80, SCREEN_WIDTH - 120, 40)];
            [_newsTypeButton.titleLabel setFont:gFontMain14];
            [_newsTypeButton setTitleColor:gTextColorSub forState:UIControlStateNormal];
            [_newsTypeButton setTitle:@"点击选择" forState:UIControlStateNormal];
            _newsTypeButton.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;
            _newsTypeButton.titleEdgeInsets = UIEdgeInsetsMake(0, 21, 0, 0);
            [_newsTypeButton setTag:102 ];
            [_newsTypeButton addTarget:self action:@selector(selectedAction:) forControlEvents:UIControlEventTouchUpInside];
        }
        
        [_topbgView addSubview:self.startDateButton];
        [_topbgView addSubview:self.endDateButton];
        [_topbgView addSubview:self.newsTypeButton];
    }
    return _topbgView;
}

- (UIButton *)confirButton {
    if (!_confirButton) {
        _confirButton = [UIButton buttonWithType:UIButtonTypeCustom];
        CGFloat yy  = CGRectGetMaxY(self.topbgView.frame);
        [_confirButton setFrame:CGRectMake(15, yy + 10, SCREEN_WIDTH - 30, 40)];
        [_confirButton setTitle:@"确定" forState:UIControlStateNormal];
        [_confirButton setTitleColor:gTextColorMain forState:UIControlStateNormal];
        [_confirButton setBackgroundColor:gMainColor];
        [_confirButton.layer setMasksToBounds:YES];
        [_confirButton.layer setCornerRadius:5];
        [_confirButton addTarget:self action:@selector(confirButtonAction:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _confirButton;
}

//批量下载条件选择
- (void)selectedAction:(UIButton *)sender {
    
    //开始时间
    if (sender.tag == 100) {
        DefineWeakSelf;
        AIDatePickerController *datePickerViewController = [AIDatePickerController pickerWithDate:[NSDate date] selectedBlock:^(NSDate *selectedDate) {
            if ([selectedDate isEqualToDateIgnoringTime:weakSelf.endDate]) {
                weakSelf.startDate = selectedDate;
                weakSelf.endDate = weakSelf.endDate;
                [weakSelf dismissViewControllerAnimated:YES completion:nil];
            }
            else if ([weakSelf.endDate compare:selectedDate] == NSOrderedAscending) {
                [SVProgressHUD showErrorWithStatus:@"结束时间不能够小于开始时间"];
            }
            else{
                weakSelf.startDate = selectedDate;
                [weakSelf dismissViewControllerAnimated:YES completion:nil];
            }
        } cancelBlock:^{
            [weakSelf dismissViewControllerAnimated:YES completion:nil];
        }];
        [self presentViewController:datePickerViewController animated:YES completion:nil];
    }
    //结束时间
    else if (sender.tag == 101){
        DefineWeakSelf;
        AIDatePickerController *datePickerViewController = [AIDatePickerController pickerWithDate:[NSDate date] selectedBlock:^(NSDate *selectedDate) {
            if ([selectedDate isEqualToDateIgnoringTime:weakSelf.endDate]) {
                weakSelf.endDate = selectedDate;
                weakSelf.startDate = weakSelf.startDate;
                [weakSelf dismissViewControllerAnimated:YES completion:nil];
            }
            else if ([selectedDate compare:weakSelf.startDate] == NSOrderedAscending  ) {
                //|| [selectedDate isEqualToDateIgnoringTime:weakSelf.startDate]
                [SVProgressHUD showErrorWithStatus:@"结束时间不能够小于开始时间"];
            }
            else{
                weakSelf.startDate = weakSelf.startDate;
                weakSelf.endDate = selectedDate;
                [weakSelf dismissViewControllerAnimated:YES completion:nil];
            }
        } cancelBlock:^{
            [weakSelf dismissViewControllerAnimated:YES completion:nil];
        }];
        [self presentViewController:datePickerViewController animated:YES completion:nil];
        
    }
    else if (sender.tag == 102) {
        [NetWorkTool getPaoGuoFenLeiLieBiaoWithWhateverSomething:@"q" sccess:^(NSDictionary *responseObject) {
            RTLog(@"%@",responseObject[@"results"]);
            if ([responseObject[status] intValue] == 1) {
                SelectedNewsTypeView *selectedNewsTypeView = [[SelectedNewsTypeView alloc]init];
                AppDelegate *appDelegate = (AppDelegate *)[UIApplication sharedApplication].delegate;
                [appDelegate.window addSubview:selectedNewsTypeView];
                
                NSMutableArray *itemArr = responseObject[results];
                if ([itemArr count]) {
                    
                }
                else{
                    itemArr = [CommonCode readFromUserD:@"topNameArr"];
                }
                
                NSMutableArray *selecteArr = [NSMutableArray array];
                for ( int i = 0 ; i < [itemArr count]; i ++) {
                    if ([itemArr[i][@"type"] isEqualToString:@"推荐"]) {
                        
                    }
                    else{
                        [selecteArr addObject:itemArr[i][@"type"]];
                    }
                }
                [selectedNewsTypeView setSelectItemWithTitleArr:selecteArr];
                DefineWeakSelf;
                selectedNewsTypeView.selectedTypeBlock = ^ (NSString *selectedStr) {
                    NSLog(@"selectedStr=%@",selectedStr);
                    if ([selectedStr length]) {
                        self.newsType = selectedStr;
                        [weakSelf.newsTypeButton setTitle:selectedStr forState:UIControlStateNormal];
                    }
                    else{
                        self.newsType = nil;
                        [weakSelf.newsTypeButton setTitle:@"点击选择" forState:UIControlStateNormal];
                    }
                    
                };
            }else{
                XWAlerLoginView *alert = [[XWAlerLoginView alloc] initWithTitle:responseObject[msg]];
                [alert show];
            }
        } failure:^(NSError *error) {
            XWAlerLoginView *alert = [[XWAlerLoginView alloc] initWithTitle:@"网络错误~"];
            [alert show];
        }];
    }
    
}

- (void)confirButtonAction:(UIButton *)sender {
    
    [SVProgressHUD setDefaultMaskType:SVProgressHUDMaskTypeBlack];
    [SVProgressHUD showWithStatus:@"正在请求..."];
    if (self.startDate == nil) {
        [SVProgressHUD showErrorWithStatus:@"请选择开始时间"];
        [self performSelector:@selector(SVPDismiss) withObject:nil afterDelay:1.0];
    }
    else if (self.endDate == nil){
        [SVProgressHUD showErrorWithStatus:@"请选择结束时间"];
        [self performSelector:@selector(SVPDismiss) withObject:nil afterDelay:1.0];
    }
    else if (self.newsType == nil){
        [SVProgressHUD showErrorWithStatus:@"请选择新闻分类"];
        [self performSelector:@selector(SVPDismiss) withObject:nil afterDelay:1.0];
    }
    else {
        
        NSString *finalStartStr = [NSString stringWithFormat:@"%@",self.startDate];
        NSString *finalEndStr = [NSString stringWithFormat:@"%@",self.endDate];
        //开始时间和结束时间同一天
        if ([self.startDate isEqualToDateIgnoringTime:self.endDate] ) {
            NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
            [dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
            NSString *starDateStr = [dateFormatter stringFromDate:self.startDate];
            NSString *endDateStr = [dateFormatter stringFromDate:self.endDate];
            finalStartStr = [[starDateStr substringToIndex:11] stringByAppendingString:@"00:00:01"];
            finalEndStr = [[endDateStr substringToIndex:11] stringByAppendingString:@"23:59:59"];
        }
        
        //匹配分类的id
        NSString *numberkey = @"";
        NSMutableArray *commonlistArr = [CommonCode readFromUserD:@"commonListArr"];
         NSArray *array = [self.newsType componentsSeparatedByString:@","];
        for (int i = 0 ; i < array.count; i ++) {
            for (int j = 0 ; j < [commonlistArr count]; j ++ ) {
                if ([commonlistArr[j][@"type"] isEqualToString:array[i]]) {
                    numberkey = [NSString stringWithFormat:@"%@%@,",numberkey,commonlistArr[j][@"numberkey"]];
                    break;
                }
            }
        }
       
        [NetWorkTool getDownloadNewsListWithterm_id:numberkey
                                         start_time:finalStartStr
                                           end_time:finalEndStr
                                             sccess:^(NSDictionary *response) {
                                                 
                                                 if ([response[@"results"] isKindOfClass:[NSArray class] ]) {
                                                     
                                                     self.hidesBottomBarWhenPushed=YES;
                                                     BatchDownloadTableTableViewController *vc = [BatchDownloadTableTableViewController new];
                                                     vc.newsListArr = [response[@"results"] mutableCopy];
                                                     vc.headTitleStr = [NSString stringWithFormat:@"%@(%@至%@",self.newsType,[self.startDate stringWithFormat:@"yyyy-MM-dd"],[self.endDate stringWithFormat:@"yyyy-MM-dd"]];
                                                     [self.navigationController pushViewController:vc animated:YES];
                                                     [SVProgressHUD dismiss];
                                                     self.hidesBottomBarWhenPushed=YES;
                                                 }
                                                 else{
                                                     [SVProgressHUD showErrorWithStatus:@"无搜索内容"];
                                                     [self performSelector:@selector(SVPDismiss) withObject:nil afterDelay:1.0];
                                                 }
                                                 
                                             } failure:^(NSError *error) {
                                                 NSLog(@"%@",error);
                                             }];
    
    }
    
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
