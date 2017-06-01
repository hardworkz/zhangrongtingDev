//
//  jiemuLieBiaoVC.m
//  reHeardTheNews
//
//  Created by Pop Web on 16/3/25.
//  Copyright © 2016年 paoguo. All rights reserved.
//

#import "jiemuLieBiaoVC.h"
#import "UIImageView+WebCache.h"
#import "zhuboxiangqingVCNew.h"
@interface jiemuLieBiaoVC ()<UITableViewDataSource,UITableViewDelegate>
{
    NSString *selfGuanZhuId;
    NSMutableArray *isGuanZhuArr;
}
/* 本页面主TableView */
@property(strong,nonatomic)UITableView *tableView;
/* 主数据源 */
@property(strong,nonatomic)NSArray *infoArr;

@end

@implementation jiemuLieBiaoVC

- (void)viewDidLoad {
    [super viewDidLoad];
    [self enableAutoBack];
    isGuanZhuArr = [NSMutableArray array];
//    self.edgesForExtendedLayout = UIRectEdgeNone;
    self.title = @"订阅列表";
//    self.navigationController.navigationBar.titleTextAttributes = @{NSForegroundColorAttributeName: [UIColor blackColor],
//                                                                    NSFontAttributeName : [UIFont boldSystemFontOfSize:18]};
//    UIButton *leftBtn = [UIButton buttonWithType:UIButtonTypeCustom];
//    [leftBtn setBackgroundImage:[UIImage imageNamed:@"back"] forState:UIControlStateNormal];
//    leftBtn.accessibilityLabel = @"返回";
//    leftBtn.bounds = CGRectMake(0, 0, 9, 15);
//    UIBarButtonItem *back = [[UIBarButtonItem alloc]initWithCustomView:leftBtn];
//    [leftBtn addTarget:self action:@selector(back) forControlEvents:UIControlEventTouchUpInside];
//    self.navigationItem.leftBarButtonItem = back;
    
    self.view.backgroundColor = [UIColor whiteColor];
    
//    if ([[CommonCode readFromUserD:@"jiemuliebiao"] isKindOfClass:[NSArray class]])
//    {
//        self.infoArr = [NSArray arrayWithArray:[CommonCode readFromUserD:@"jiemuliebiao"]];
//        [self.tableView reloadData];
//    }
    
    
//    [NetWorkTool postPaoGuoJieMuLieBiaoWithaccessToken:[DSE encryptUseDES:ExdangqianUser] sccess:^(NSDictionary *responseObject) {
//        if ([responseObject[@"results"] isKindOfClass:[NSArray class]])
//        {
//            self.infoArr = [NSArray arrayWithArray:responseObject[@"results"]];
//            [CommonCode writeToUserD:self.infoArr andKey:@"jiemuliebiao"];
//        }
//        for (int i = 0; i < self.infoArr.count; i ++ ){
//            [isGuanZhuArr addObject:[NSString stringWithFormat:@"%@",self.infoArr[i][@"is_fan"]]];
//        }
//        
//        [self.tableView reloadData];
//    } failure:^(NSError *error) {
//        NSLog(@"error = %@",error);
//    }];
    
    [NetWorkTool getMySubscribeWithaccessToken:[DSE encryptUseDES:ExdangqianUser] limit:@"1000" sccess:^(NSDictionary *responseObject) {
        if ([responseObject[@"results"] isKindOfClass:[NSArray class]])
        {
            self.infoArr = [NSArray arrayWithArray:responseObject[@"results"]];
            [CommonCode writeToUserD:self.infoArr andKey:@"jiemuliebiao"];
        }
        for (int i = 0; i < self.infoArr.count; i ++ ){
            [isGuanZhuArr addObject:[NSString stringWithFormat:@"%@",self.infoArr[i][@"is_fan"]]];
        }
        
        [self.tableView reloadData];
    } failure:^(NSError *error) {
         NSLog(@"error = %@",error);
    }];
    
    
    
    [self.view addSubview:self.tableView];
    
    UISwipeGestureRecognizer *rightSwipe = [[UISwipeGestureRecognizer alloc]initWithTarget:self action:@selector(rightSwipeAction)];
    [rightSwipe setDirection:UISwipeGestureRecognizerDirectionRight];
    [self.tableView addGestureRecognizer:rightSwipe];
    
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self.navigationController setNavigationBarHidden:NO animated:YES];
    self.hidesBottomBarWhenPushed = YES;
}


#pragma mark --- 手势事件
- (void)rightSwipeAction{
    [self.navigationController popViewControllerAnimated:YES];
}

#pragma mark --- tableView代理事件

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 67;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return self.infoArr.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    static NSString *jiemuLieBiaoIdentify = @"jiemuLieBiaoIdentify";
    UITableViewCell *cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:jiemuLieBiaoIdentify];
    if (!cell)
    {
        cell = [tableView dequeueReusableCellWithIdentifier:jiemuLieBiaoIdentify];
    }
    UIImageView *imgV = [[UIImageView alloc]initWithFrame:CGRectMake(5.0 / 375 * IPHONE_W, 5, 57, 57)];

    if([self.infoArr[indexPath.row][@"images"] rangeOfString:@"/data/upload/"].location !=NSNotFound){
        IMAGEVIEWHTTP(imgV, self.infoArr[indexPath.row][@"images"]);
    }
    else{
        IMAGEVIEWHTTP2(imgV, self.infoArr[indexPath.row][@"images"]);
    }
    imgV.layer.cornerRadius = 28.5f;
    imgV.layer.masksToBounds = YES;
    imgV.contentMode = UIViewContentModeScaleAspectFill;
    [cell.contentView addSubview:imgV];
    
    UILabel *titleLab = [[UILabel alloc]initWithFrame:CGRectMake(5.0 / 375 * IPHONE_W + 57 + 10.0 / 375 * IPHONE_W, 7, 200.0 / 375 * IPHONE_W, 15)];
    titleLab.text = self.infoArr[indexPath.row][@"name"];
    titleLab.textColor = [UIColor blackColor];
    titleLab.textAlignment = NSTextAlignmentLeft;
    titleLab.font = [UIFont systemFontOfSize:16.0f];
    [cell.contentView addSubview:titleLab];
    
    UILabel *neirongLab = [[UILabel alloc]initWithFrame:CGRectMake(5.0 / 375 * IPHONE_W + 57 + 15.0 / 375 * IPHONE_W, 37, 235.0 / 375 * IPHONE_W, 15)];
    neirongLab.text = self.infoArr[indexPath.row][@"description"];
    neirongLab.textColor = [UIColor grayColor];
    neirongLab.font = [UIFont systemFontOfSize:13.0f];
    neirongLab.textAlignment = NSTextAlignmentLeft;
    neirongLab.alpha = 0.7f;
    [cell.contentView addSubview:neirongLab];
    
    UIButton *isSelectBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    isSelectBtn.frame = CGRectMake(IPHONE_W - 60.0 / 375 * IPHONE_W, 18.5, 50, 30);
    [cell.contentView addSubview:isSelectBtn];
    isSelectBtn.contentMode = UIViewContentModeScaleAspectFit;
    isSelectBtn.backgroundColor = gMainColor;
    isSelectBtn.layer.masksToBounds = YES;
    isSelectBtn.layer.cornerRadius = 5.0f;
    isSelectBtn.titleLabel.font = [UIFont systemFontOfSize:13.0f];
    
    [isSelectBtn setTitle:@"关注" forState:UIControlStateNormal];
    if (isGuanZhuArr.count > 0 && indexPath.row < isGuanZhuArr.count){
        if ([isGuanZhuArr[indexPath.row] isEqualToString:@"0"]){
            [isSelectBtn setTitle:@"关注" forState:UIControlStateNormal];
            isSelectBtn.selected = YES;
        }
        else{
            [isSelectBtn setTitle:@"取消" forState:UIControlStateNormal];
            isSelectBtn.selected = NO;
        }
    }
    [isSelectBtn addTarget:self action:@selector(guanzhuAction:) forControlEvents:UIControlEventTouchUpInside];
    
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    
    return cell;
}
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    NSDictionary *dic = [[NSDictionary alloc]initWithDictionary:self.infoArr[indexPath.row]];
    
    zhuboxiangqingVCNew *faxianzhuboVC = [[zhuboxiangqingVCNew alloc]init];
    faxianzhuboVC.jiemuDescription = dic[@"description"];
    faxianzhuboVC.jiemuFan_num = dic[@"fan_num"];
    faxianzhuboVC.jiemuID = dic[@"id"];
    faxianzhuboVC.jiemuImages = dic[@"images"];
    faxianzhuboVC.jiemuIs_fan = dic[@"is_fan"];
    faxianzhuboVC.jiemuMessage_num = dic[@"news_num"];
    faxianzhuboVC.jiemuName = dic[@"name"];
    self.hidesBottomBarWhenPushed=YES;
    [self.navigationController pushViewController:faxianzhuboVC animated:YES];
    self.hidesBottomBarWhenPushed=YES;
}

#pragma mark --- 按钮点击事件

- (void)guanzhuAction:(UIButton *)sender{
    
    UITableViewCell *cell = (UITableViewCell *)[[sender superview] superview];
    NSIndexPath *indexPath = [self.tableView indexPathForCell:cell];
    
    if (sender.selected == NO){
        [NetWorkTool postPaoGuoCancelJieMuGuanZhuWithaccessToken:[DSE encryptUseDES:ExdangqianUser] andAct_id:self.infoArr[indexPath.row][@"id"] sccess:^(NSDictionary *responseObject) {
            [isGuanZhuArr replaceObjectAtIndex:indexPath.row withObject:@"0"];
        } failure:^(NSError *error) {
            NSLog(@"error = %@",error);
        }];
        [sender setTitle:@"关注" forState:UIControlStateNormal];
        sender.selected = YES;
    }
    else{

        [NetWorkTool postPaoGuoAddJieMuGuanZhuWithaccessToken:[DSE encryptUseDES:ExdangqianUser] andAct_id:self.infoArr[indexPath.row][@"id"] sccess:^(NSDictionary *responseObject) {
            [isGuanZhuArr replaceObjectAtIndex:indexPath.row withObject:@"1"];
        } failure:^(NSError *error) {
            NSLog(@"error = %@",error);
        }];
        [sender setTitle:@"取消" forState:UIControlStateNormal];
        sender.selected = NO;
    }
}
- (void)back
{
    [self.navigationController popViewControllerAnimated:YES];
}

#pragma mark --- 懒加载
- (UITableView *)tableView
{
    if (!_tableView)
    {
        _tableView = [[UITableView alloc]initWithFrame:CGRectMake(0, 0, IPHONE_W, IPHONE_H) style:UITableViewStylePlain];
        _tableView.delegate = self;
        _tableView.dataSource = self;
    }
    return _tableView;
}

- (NSArray *)infoArr
{
    if (!_infoArr)
    {
        _infoArr = [NSArray array];
    }
    return _infoArr;
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter]removeObserver:self];
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
