//
//  CitySelectedViewController.m
//  kuangjiaTingWen
//
//  Created by Zhimi on 16/9/19.
//  Copyright © 2016年 贺楠. All rights reserved.
//

#import "CitySelectedViewController.h"

@interface CitySelectedViewController ()<UITableViewDelegate,UITableViewDataSource>

@property (strong, nonatomic) UITableView *cityListTableView;
@property (strong, nonatomic) NSMutableArray *cityList;

@end

@implementation CitySelectedViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self setupData];
    [self setupView];
}

-(void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self.navigationController setNavigationBarHidden:NO];
    self.hidesBottomBarWhenPushed = YES;
}

- (void)setupData {
    [self loadData];
}

- (void)setupView {
    [self enableAutoBack];
    [self setTitle:@"城市列表"];
    self.edgesForExtendedLayout = UIRectEdgeNone;
    self.view.backgroundColor = [UIColor whiteColor];
    self.navigationController.navigationBar.titleTextAttributes = @{NSForegroundColorAttributeName: [UIColor blackColor],
                                                                    NSFontAttributeName : [UIFont boldSystemFontOfSize:18]};
    UIButton *leftBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [leftBtn setBackgroundImage:[UIImage imageNamed:@"title_ic_back"] forState:UIControlStateNormal];
    leftBtn.bounds = CGRectMake(0, 0, 9, 15);
    leftBtn.accessibilityLabel = @"返回";
    UIBarButtonItem *back = [[UIBarButtonItem alloc]initWithCustomView:leftBtn];
    [leftBtn addTarget:self action:@selector(back) forControlEvents:UIControlEventTouchUpInside];
    self.navigationItem.leftBarButtonItem = back;
    [self.view addSubview:self.cityListTableView];
    
    UISwipeGestureRecognizer *rightSwipe = [[UISwipeGestureRecognizer alloc]initWithTarget:self action:@selector(back)];
    [rightSwipe setDirection:UISwipeGestureRecognizerDirectionRight];
    [self.view addGestureRecognizer:rightSwipe];
    
}

- (UITableView *)cityListTableView {
    if (!_cityListTableView) {
        _cityListTableView = [[UITableView alloc]initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_HEIGHT) style:UITableViewStylePlain];
        [_cityListTableView setDelegate:self];
        [_cityListTableView setDataSource:self];
        [_cityListTableView setSeparatorStyle:UITableViewCellSeparatorStyleNone];
    }
    return _cityListTableView;
}

- (NSMutableArray *)cityList {
    if (!_cityList) {
        _cityList = [NSMutableArray array];
    }
    return _cityList;
}


- (void)loadData{
    
    [NetWorkTool getPlaceListWithoutParameter:@"parameter" sccess:^(NSDictionary *responseObject) {
        if ([responseObject[@"results"] isKindOfClass:[NSArray class]]) {
            self.cityList = [responseObject[@"results"] mutableCopy];
            [self.cityListTableView reloadData];
        }
    } failure:^(NSError *error) {
        //
    }];
}

- (void)back {
    
    [self.navigationController popViewControllerAnimated:YES];
}
#pragma mark - UITableViewDelegate

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return [self.cityList count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    static NSString *identify = @"citylistidentify";
    UITableViewCell *cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identify];
    if (!cell){
        cell = [tableView dequeueReusableCellWithIdentifier:identify];
    }
    
    UILabel *city = [[UILabel alloc]initWithFrame:CGRectMake(10, 6, 50, 30)];
    [city setText:self.cityList[indexPath.row][@"type"]];
    [city setFont:gFontMain15];
    [cell.contentView addSubview:city];
    
    UIView *line = [[UIView alloc]initWithFrame:CGRectMake(0, 43, SCREEN_WIDTH, 1)];
    [line setBackgroundColor:gSubColor];
    [cell.contentView addSubview:line];
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 44.0;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    
    [[NSNotificationCenter defaultCenter] postNotificationName:@"selectedCity" object:self.cityList[indexPath.row]];
    [self.navigationController popViewControllerAnimated:YES];
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
