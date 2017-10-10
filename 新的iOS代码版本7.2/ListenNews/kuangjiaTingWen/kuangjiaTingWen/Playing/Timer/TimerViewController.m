//
//  TimerViewController.m
//  Heard the news
//
//  Created by Pop Web on 15/8/17.
//  Copyright (c) 2015年 泡果网络. All rights reserved.
//

#import "TimerViewController.h"

#import "CommonCode.h"

@interface TimerViewController ()<UITableViewDelegate>

@property (nonatomic, strong) NSArray *timerArray;
@property (nonatomic, strong) UITableViewCell *selectCell;

@end

static NSInteger section = 2;
static NSInteger timer = 0;

@implementation TimerViewController

+ (instancetype)defaultTimerViewController {
    static TimerViewController *defaultTimerViewController = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        defaultTimerViewController = [[TimerViewController alloc]initWithStyle:UITableViewStyleGrouped];
    });
    return defaultTimerViewController;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"定时页面";
    [self enableAutoBack];
    [self.navigationController.navigationBar setHidden: NO];
//        UIView *view = [[UIView alloc]initWithFrame:CGRectMake(0, 0, IPHONE_W, 64)];
//        view.backgroundColor = ColorWithRGBA(0, 159, 240, 1);
//        self.tableView.tableHeaderView = view;
//        
//        UIButton *leftBtn = [UIButton buttonWithType:UIButtonTypeCustom];
//        leftBtn.frame = CGRectMake(8, 30, 25, 25);
//        [leftBtn setImage:[UIImage imageNamed:@"back"] forState:UIControlStateNormal];
//        [leftBtn addTarget:self action:@selector(back) forControlEvents:UIControlEventTouchUpInside];
//        [view addSubview:leftBtn];
//        UIView *tapView = [[UIView alloc]initWithFrame:CGRectMake(CGRectGetMaxX(leftBtn.frame), leftBtn.frame.origin.y, 40.0 / 375 * IPHONE_W, leftBtn.frame.size.height)];
//        [view addSubview:tapView];
//        UILabel *topLab = [[UILabel alloc]initWithFrame:CGRectMake(50, 30, IPHONE_W - 100, 30)];
//        topLab.textColor = [UIColor whiteColor];
//        topLab.font = [UIFont boldSystemFontOfSize:17.0f];
//        topLab.text = @"定时页面";
//        topLab.backgroundColor = [UIColor clearColor];
//        topLab.textAlignment = NSTextAlignmentCenter;
//        [view addSubview:topLab];
//        tapView.backgroundColor = ColorWithRGBA(0, 159, 240, 1);
//        
//        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(back)];
//        [tapView addGestureRecognizer:tap];
//    
    UISwipeGestureRecognizer *rightSwipe = [[UISwipeGestureRecognizer alloc]initWithTarget:self action:@selector(back)];
    [rightSwipe setDirection:UISwipeGestureRecognizerDirectionRight];
    [self.view addGestureRecognizer:rightSwipe];

    [self.tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:@"cellTimer"];
    _selectCell = [self.tableView dequeueReusableCellWithIdentifier:@"cell"];
    self.tableView.tableFooterView = [UIView new];
    _timerArray = @[@"10分钟后",@"20分钟后",@"30分钟后",@"60分钟后",@"90分钟后"];
    self.tableView.scrollEnabled = NO;
}

- (void)back {
    [self.navigationController popViewControllerAnimated:YES];
    
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)endUpdates {
    
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    // Return the number of sections.
    return section;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    // Return the number of rows in the section.
    if (section == 1) {
        return 5;
    }
    return 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cellTimer" forIndexPath:indexPath];
    if (indexPath.section == 0) {
        if (_sw == nil) {
           
//            if (!Greater_Than_IOS6) {
//                _sw = [[UISwitch alloc] init];
//                _sw.center = CGPointMake(IPHONE_W - 60, 22);
//                [_sw addTarget:self action:@selector(swithButton:) forControlEvents:UIControlEventValueChanged];
//                [cell.contentView insertSubview:_sw belowSubview:cell.textLabel];
//                [cell.contentView bringSubviewToFront:_sw];
//                _la = [[UILabel alloc]initWithFrame:CGRectMake(0, 0, 50, 20)];
//                _la.textAlignment = NSTextAlignmentCenter;
//                _la.center = CGPointMake(IPHONE_W - 125, 22);
//                _la.backgroundColor = [UIColor clearColor];
//                [cell.contentView addSubview:_la];
//                _sw.on = NO;
//            }else {
                _sw = [[UISwitch alloc] init];
                _sw.center = CGPointMake(IPHONE_W - 50, 22);
                [_sw addTarget:self action:@selector(swithButton:) forControlEvents:UIControlEventValueChanged];
                [cell.contentView insertSubview:_sw belowSubview:cell.textLabel];
                [cell.contentView bringSubviewToFront:_sw];
                _la = [[UILabel alloc]initWithFrame:CGRectMake(0, 0, 50, 20)];
                _la.textAlignment = NSTextAlignmentCenter;
                _la.center = CGPointMake(IPHONE_W - 125, 22);
                _la.backgroundColor = [UIColor clearColor];
                [cell.contentView addSubview:_la];
                _sw.on = NO;
        }
//
//        }
        cell.textLabel.text = @"开启定时";
    }else {
        cell.textLabel.text = _timerArray[indexPath.row];
    }
    
    if (indexPath.section == 1) {
        cell.frame = CGRectMake(-CGRectGetWidth(cell.bounds), cell.frame.origin.y, CGRectGetWidth(cell.bounds), CGRectGetHeight(cell.bounds));
        cell.alpha = 0.f;
    }
       // Configure the cell...
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    
    return cell;
}

- (void)prepareVisibleCellsForAnimation {
    for (int i = 0; i < [self.tableView.visibleCells count]; i++) {
        UITableViewCell * cell = (UITableViewCell *)[self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForItem:i inSection:1]];
        cell.frame = CGRectMake(-CGRectGetWidth(cell.bounds), cell.frame.origin.y, CGRectGetWidth(cell.bounds), CGRectGetHeight(cell.bounds));
        cell.alpha = 0.f;
    }
}

- (void)animateVisibleCells {
    for (int i = 0; i < [self.tableView.visibleCells count]; i++) {
        UITableViewCell * cell = (UITableViewCell *)[self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForItem:i inSection:1]];
        
        cell.alpha = 1.f;
        [UIView animateWithDuration:0.25f
                              delay:i * 0.1
                            options:UIViewAnimationOptionCurveEaseOut
                         animations:^{
                             cell.frame = CGRectMake(0.f, cell.frame.origin.y, CGRectGetWidth(cell.bounds), CGRectGetHeight(cell.bounds));
                         }
                         completion:nil];
    }
}

- (void)swithButton:(UISwitch *)sw1{
    if (sw1.on) {
        section = 2;
        _la.hidden = NO;
        [self animateVisibleCells];
    }else {
        section = 1;
        _la.hidden = YES;
        [self prepareVisibleCellsForAnimation];
    }
    
    if (_sw.on) {
        if (_timer == nil) {
            _timer = [NSTimer scheduledTimerWithTimeInterval:1 target:self selector:@selector(timerLable) userInfo:nil repeats:YES];
            [_timer setFireDate:[NSDate distantPast]];
        }else {
            [_timer setFireDate:[NSDate distantPast]];
        }
    }else {
        if (_timer == nil) {
            _timer = [NSTimer scheduledTimerWithTimeInterval:1 target:self selector:@selector(timerLable) userInfo:nil repeats:YES];
            [_timer setFireDate:[NSDate distantFuture]];
        }else {
            [_timer setFireDate:[NSDate distantFuture]];
        }
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == 1) {
        UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
        if (cell != _selectCell) {
            cell.accessoryType = UITableViewCellAccessoryCheckmark;
            
            _selectCell.accessoryType = UITableViewCellAccessoryNone;
            
            _selectCell = cell;
        }else {
            return;
        }

    }
    
    if (indexPath.section == 1 && indexPath.row == 0) {
        _la.text = @"10:00";
        timer = 600;
    }else if(indexPath.section == 1 && indexPath.row == 1){
        _la.text = @"20:00";
        timer = 1200;

    }else if(indexPath.section == 1 && indexPath.row == 2){
        _la.text = @"30:00";
        timer = 1800;

    }else if(indexPath.section == 1 && indexPath.row == 3){
        _la.text = @"60:00";
        timer = 3600;

    }else if(indexPath.section == 1 && indexPath.row == 4){
        _la.text = @"90:00";
        timer = 5400;
    }
    
    [_sw setOn:YES animated:YES];
    
    if (_timer == nil) {
        _timer = [NSTimer scheduledTimerWithTimeInterval:1 target:self selector:@selector(timerLable) userInfo:nil repeats:YES];
        [_timer setFireDate:[NSDate distantPast]];
    }else {
        [_timer setFireDate:[NSDate distantPast]];
    }
    
}

- (void)timerLable {
    if (!timer) {
        return;
    }
    NSInteger shi = timer / 60;
    NSInteger fen = timer % 60;
    if (shi < 10) {
        if (fen < 10) {
            _la.text = [NSString stringWithFormat:@"0%ld:0%ld", (long)shi,(long)fen];

        }else {
            _la.text = [NSString stringWithFormat:@"0%ld:%ld", (long)shi,(long)fen];
        }
    }else {
        if (fen < 10) {
            _la.text = [NSString stringWithFormat:@"%ld:0%ld", (long)shi,(long)fen];
            
        }else {
            _la.text = [NSString stringWithFormat:@"%ld:%ld", (long)shi,(long)fen];
        }
    }
    
    [[NSNotificationCenter defaultCenter]postNotificationName:@"changeTimer" object:_la.text];
    
    timer--;
    if (timer <= 0) {
        timer = 0;
        _la.text = @"00:00";
        [_timer setFireDate:[NSDate distantFuture]];
        [_sw setOn:NO];
        [[NSNotificationCenter defaultCenter] postNotificationName:@"timerStop" object:nil];
    }
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self prepareVisibleCellsForAnimation];
    [self.navigationController.navigationBar setHidden:NO];
    self.hidesBottomBarWhenPushed = YES;
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    if (_sw.on) {

//        [self animateVisibleCells];
    }
    [self.navigationController setNavigationBarHidden:NO animated:YES];
}

- (void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    [self.navigationController setNavigationBarHidden:YES animated:YES];
}

@end
