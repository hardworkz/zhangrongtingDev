//
//  yingyongtuijianVC.m
//  reHeardTheNews
//
//  Created by Pop Web on 16/3/18.
//  Copyright © 2016年 paoguo. All rights reserved.
//

#import "yingyongtuijianVC.h"
#import "UIImageView+WebCache.h"
@interface yingyongtuijianVC ()<UITableViewDataSource,UITableViewDelegate>
/* 本页面主tableView */
@property(strong,nonatomic)UITableView *tableView;
/* 本页面主数据arr */
@property(strong,nonatomic)NSArray *infoArr;

@property (nonatomic, strong) UILabel *label;

@end

@implementation yingyongtuijianVC

- (void)viewDidLoad {
    [super viewDidLoad];
    self.edgesForExtendedLayout = UIRectEdgeNone;
    self.title = @"应用推荐";
    self.navigationController.navigationBar.titleTextAttributes = @{NSForegroundColorAttributeName: [UIColor blackColor],
                                                                    NSFontAttributeName : [UIFont boldSystemFontOfSize:18]};
    UIButton *leftBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [leftBtn setBackgroundImage:[UIImage imageNamed:@"back"] forState:UIControlStateNormal];
    leftBtn.accessibilityLabel = @"返回";
    leftBtn.bounds = CGRectMake(0, 0, 9, 15);
    UIBarButtonItem *back = [[UIBarButtonItem alloc]initWithCustomView:leftBtn];
    [leftBtn addTarget:self action:@selector(back) forControlEvents:UIControlEventTouchUpInside];
    self.navigationItem.leftBarButtonItem = back;
    
    self.view.backgroundColor = [UIColor whiteColor];
    
    [self.view addSubview:self.tableView];
    
    UISwipeGestureRecognizer *rightSwipe = [[UISwipeGestureRecognizer alloc]initWithTarget:self action:@selector(rightSwipeAction)];
    [rightSwipe setDirection:UISwipeGestureRecognizerDirectionRight];
    [self.tableView addGestureRecognizer:rightSwipe];
    
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    self.hidesBottomBarWhenPushed = YES;
    [self.navigationController setNavigationBarHidden:NO animated:YES];
}

#pragma mark --- tableView代理
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    if (!self.infoArr.count) {
        if (!_label) {
            _label = [[UILabel alloc]initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, 20)];
            _label.textAlignment = NSTextAlignmentCenter;
            _label.text = @"暂无数据";
            _label.textColor = [UIColor lightGrayColor];
            _label.center = self.tableView.center;
            [self.tableView addSubview:_label];
        }else {
            [self.tableView addSubview:_label];
        }
    }else {
        [_label removeFromSuperview];
    }
    
    return self.infoArr.count / 2;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *yingyongtuijianIdentify = @"identify";
    UITableViewCell *cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:yingyongtuijianIdentify];
    if (!cell)
    {
        cell = [tableView dequeueReusableCellWithIdentifier:yingyongtuijianIdentify];
    }
    UIImageView *imgView = [[UIImageView alloc]initWithFrame:CGRectMake(7, 7, 55, 55)];
    IMAGEVIEWHTTP2(imgView, self.infoArr[1][@"thumb"]);
    [cell.contentView addSubview:imgView];
    UILabel *appName = [[UILabel alloc]initWithFrame:CGRectMake(76, 5, 175, 25)];
    appName.text = self.infoArr[1][@"y_title"];
    appName.textColor = [UIColor blackColor];
    appName.textAlignment = NSTextAlignmentLeft;
    [cell.contentView addSubview:appName];
    appName.font = [UIFont systemFontOfSize:17.0f];
    UILabel *appJJ = [[UILabel alloc]initWithFrame:CGRectMake(76, 30, 189, 25)];
    appJJ.text = self.infoArr[1][@"y_intro"];
    appJJ.textColor = [UIColor grayColor];
    appJJ.alpha = 0.6f;
    [cell.contentView addSubview:appJJ];
    appJJ.font = [UIFont systemFontOfSize:15.0f];
    
    UIImageView *rightV = [[UIImageView alloc]initWithFrame:CGRectMake(320.0 / 375 * IPHONE_W, 22, 25, 25)];
    rightV.image = [UIImage imageNamed:@"iconfont-iconfontunie122"];
    [cell.contentView addSubview:rightV];
    rightV.contentMode = UIViewContentModeScaleToFill;
    
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (self.infoArr[1][@"y_url"])
    {
        [[UIApplication sharedApplication]openURL:[NSURL URLWithString:self.infoArr[1][@"y_url"]]];
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 69;
}

#pragma mark - Utilities
- (void)back {
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)rightSwipeAction {
    [self.navigationController popViewControllerAnimated:YES];
}

#pragma mark - Setter
- (UITableView *)tableView
{
    if (!_tableView)
    {
        _tableView = [[UITableView alloc]initWithFrame:CGRectMake(0, 0, IPHONE_W, IPHONE_H - 64) style:UITableViewStylePlain];
        _tableView.delegate = self;
        _tableView.dataSource = self;
        _tableView.tableFooterView = [UIView new];
    }
    return _tableView;
}

- (NSArray *)infoArr
{
    if (!_infoArr)
    {
        _infoArr = [NSArray array];
        [NetWorkTool getPaoGuoYingYongTuiJianWithaccessToken:nil sccess:^(NSDictionary *responseObject) {
            if ([responseObject[@"results"] integerValue] == 1) {
                if ([responseObject[@"results"] isKindOfClass:[NSArray class]]){
                    _infoArr = responseObject[@"results"];
                }
                else{
                    _infoArr = [NSArray array];
                }
                
            }
            [self.tableView reloadData];
        } failure:^(NSError *error) {
            NSLog(@"error = %@",error);
        }];
    }
    return _infoArr;
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
