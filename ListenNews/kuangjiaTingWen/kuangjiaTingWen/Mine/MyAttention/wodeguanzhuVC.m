//
//  wodeguanzhuVC.m
//  reHeardTheNews
//
//  Created by Pop Web on 16/3/18.
//  Copyright © 2016年 paoguo. All rights reserved.
//

#import "wodeguanzhuVC.h"
#import "MJRefresh.h"
#import "UIImageView+WebCache.h"
#import "jiemuLieBiaoVC.h"
#import "tianjiaGuanZhuVC.h"
#import "gerenzhuyeVC.h"
#import "LoginVC.h"
#import "LoginNavC.h"
@interface wodeguanzhuVC ()<UITableViewDataSource,UITableViewDelegate>
{
    int numberPage;
    NSMutableArray *signatureArr;
    BOOL isJiaZaiWanCheng;
    NSMutableArray *isGuanZhuArr;
}
/* 主TableView */
@property(strong,nonatomic)UITableView *tableView;
/* 主信息arr */
@property(strong,nonatomic)NSMutableArray *infoArr;
@end

@implementation wodeguanzhuVC

- (void)viewDidLoad {
    [super viewDidLoad];
    self.edgesForExtendedLayout = UIRectEdgeNone;
    numberPage = 1;
    isJiaZaiWanCheng = NO;
    self.title = @"关注列表";
    self.navigationController.navigationBar.titleTextAttributes = @{NSForegroundColorAttributeName: [UIColor blackColor],
                                                                    NSFontAttributeName : [UIFont boldSystemFontOfSize:18]};
    [self enableAutoBack];
    
    self.view.backgroundColor = [UIColor whiteColor];
    
    UIButton *bu = [UIButton buttonWithType:UIButtonTypeCustom];
    bu.bounds = CGRectMake(0, 0, 30, 30);
    [bu setBackgroundImage:[UIImage imageNamed:@"add_attention"] forState:UIControlStateNormal];
    bu.accessibilityLabel = @"添加关注";
    [bu addTarget:self action:@selector(addUser) forControlEvents:UIControlEventTouchUpInside];
    
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc]initWithCustomView:bu];
    
    [self.view addSubview:self.tableView];
    
    UISwipeGestureRecognizer *rightSwipe = [[UISwipeGestureRecognizer alloc]initWithTarget:self action:@selector(rightSwipeAction)];
    [rightSwipe setDirection:UISwipeGestureRecognizerDirectionRight];
    [self.tableView addGestureRecognizer:rightSwipe];
    
    if ([[CommonCode readFromUserD:@"guanzhuliebiao"] isKindOfClass:[NSArray class]]){
        self.infoArr = [NSMutableArray arrayWithArray:[CommonCode readFromUserD:@"guanzhuliebiao"]];
    }
    else {
        self.infoArr = [NSMutableArray array];
    }
    
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self.tableView.mj_header beginRefreshing];
    [self.navigationController setNavigationBarHidden:NO animated:YES];
    self.hidesBottomBarWhenPushed = YES;
}

#pragma mark --- 手势事件
- (void)rightSwipeAction {
    [self.navigationController popViewControllerAnimated:YES];
}

#pragma mark - UITableViewDelegate

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if ([self.infoArr isKindOfClass:[NSArray class]]){
        return self.infoArr.count;
    }
    else{
        return 0;
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *guanzhuliebiaoIdentify = @"guanzhuliebiaoIdentify";
    UITableViewCell *cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:guanzhuliebiaoIdentify];
    
    if (!cell)
    {
        cell = [tableView dequeueReusableCellWithIdentifier:guanzhuliebiaoIdentify];
    }
    UIImageView *imgV = [[UIImageView alloc]initWithFrame:CGRectMake(10.0 / 375 * IPHONE_W, 11, 45, 45)];
    
    
    if ([self.infoArr isKindOfClass:[NSArray class]]){
        if ([self.infoArr[indexPath.row ][@"avatar"]  rangeOfString:@"http"].location != NSNotFound)
        {
            [imgV sd_setImageWithURL:[NSURL URLWithString:self.infoArr[indexPath.row][@"avatar"]] placeholderImage:[UIImage imageNamed:@"user-5"]];
        }else
        {
            [imgV sd_setImageWithURL:[NSURL URLWithString:USERPHOTOHTTPSTRING(self.infoArr[indexPath.row ][@"avatar"])] placeholderImage:[UIImage imageNamed:@"user-5"]];
        }
        
        imgV.layer.cornerRadius = 22.5f;
        imgV.layer.masksToBounds = YES;
        imgV.contentMode = UIViewContentModeScaleAspectFit;
        [cell.contentView addSubview:imgV];
        
        UILabel *titleLab = [[UILabel alloc]initWithFrame:CGRectMake(5.0 / 375 * IPHONE_W + 57 + 10.0 / 375 * IPHONE_W, 15, 200.0 / 375 * IPHONE_W, 15)];
        if (self.infoArr.count)
        {
            titleLab.text = self.infoArr[indexPath.row ][@"user_nicename"];
        }
        titleLab.textColor = [UIColor blackColor];
        titleLab.textAlignment = NSTextAlignmentLeft;
        titleLab.font = [UIFont systemFontOfSize:16.0f];
        [cell.contentView addSubview:titleLab];
        
        UILabel *neirongLab = [[UILabel alloc]initWithFrame:CGRectMake(5.0 / 375 * IPHONE_W + 67.0 / 375 * IPHONE_W, 37, 230.0 / 375 * IPHONE_W, 15)];
        NSString *sigtStr;
        if ([self.infoArr[indexPath.row][@"signature"] length]){
            sigtStr = self.infoArr[indexPath.row][@"signature"];
            neirongLab.text = sigtStr;
            
        }else {
            sigtStr = @"";
            neirongLab.text = @"该用户没有什么想说的";
        }
        
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
        
        [isSelectBtn setTitle:@"取消" forState:UIControlStateNormal];
        isSelectBtn.selected = YES;
        
        //            if ([[CommonCode readFromUserD:@"isLogin"]boolValue] == YES){
        //                isSelectBtn.enabled = YES;
        //            }
        //            else{
        //                isSelectBtn.enabled = NO;
        //            }
        if ([isGuanZhuArr[indexPath.row] isEqualToString:@"1"]){
            [isSelectBtn setTitle:@"取消" forState:UIControlStateNormal];
            isSelectBtn.selected = NO;
        }
        else{
            [isSelectBtn setTitle:@"关注" forState:UIControlStateNormal];
            isSelectBtn.selected = YES;
        }
        
        [isSelectBtn addTarget:self action:@selector(tapAction:) forControlEvents:UIControlEventTouchUpInside];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        
    }
    else {
        return cell;
    }
    
    
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 67;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    gerenzhuyeVC *gerenzhuye = [gerenzhuyeVC new];
    if ([[CommonCode readFromUserD:@"dangqianUserUid"] isEqualToString:self.infoArr[indexPath.row][@"friend_id"]] && [[CommonCode readFromUserD:@"isLogin"]boolValue] == YES) {
        gerenzhuye.isMypersonalPage = YES;
    }
    else{
        gerenzhuye.isMypersonalPage = NO;
    }
    gerenzhuye.user_nicename = self.infoArr[indexPath.row][@"user_nicename"];
    gerenzhuye.sex = [NSString stringWithFormat:@"%@",self.infoArr[indexPath.row][@"sex"]];
    gerenzhuye.signature = self.infoArr[indexPath.row][@"signature"];
    gerenzhuye.user_login = self.infoArr[indexPath.row][@"user_login"];
    gerenzhuye.avatar = self.infoArr[indexPath.row][@"avatar"];
    gerenzhuye.user_id = self.infoArr[indexPath.row][@"friend_id"];
    gerenzhuye.fan_num = [NSString stringWithFormat:@"%@",self.infoArr[indexPath.row][@"fan_num"]];
    gerenzhuye.guan_num = [NSString stringWithFormat:@"%@",self.infoArr[indexPath.row][@"guan_num"]];
    self.hidesBottomBarWhenPushed=YES;
    [self.navigationController pushViewController:gerenzhuye animated:YES];
    self.hidesBottomBarWhenPushed=YES;
}

#pragma mark - UIButtonAction 

- (void)tapAction:(UIButton *)sender {
    if ([[CommonCode readFromUserD:@"isLogin"]boolValue] == YES){
        UITableViewCell *cell = (UITableViewCell *)[[sender superview] superview];
        NSIndexPath *indexPath = [self.tableView indexPathForCell:cell];
        //    DefineWeakSelf;
        if (sender.selected == NO){
            [NetWorkTool getPaoGuoCancelFriendWithaccessToken:[DSE encryptUseDES:ExdangqianUser] anduid_2:self.infoArr[indexPath.row][@"friend_id"] sccess:^(NSDictionary *responseObject) {
                NSLog(@"取消关注成功");
                [isGuanZhuArr replaceObjectAtIndex:indexPath.row withObject:@"0"];
                //            [weakSelf refreshData];
            } failure:^(NSError *error) {
                NSLog(@"error = %@",error);
            }];
            [sender setTitle:@"关注" forState:UIControlStateNormal];
            sender.selected = YES;
        }
        else{
            
            [NetWorkTool getPaoGuoAddFriendWithaccessToken:[DSE encryptUseDES:ExdangqianUser] anduid_2:self.infoArr[indexPath.row][@"friend_id"] sccess:^(NSDictionary *responseObject) {
                [isGuanZhuArr replaceObjectAtIndex:indexPath.row withObject:@"1"];
                //            [weakSelf refreshData];
            } failure:^(NSError *error) {
                NSLog(@"error = %@",error);
            }];
            [sender setTitle:@"取消" forState:UIControlStateNormal];
            sender.selected = NO;
        }
    }
    else{
        [self loginFirst];
    }
}

- (void)loginFirst {
    
    UIAlertController *qingshuruyonghuming = [UIAlertController alertControllerWithTitle:@"温馨提示\n 您还没登录，请先登录后操作" message:nil preferredStyle:UIAlertControllerStyleAlert];
    qingshuruyonghuming.accessibilityLabel = @"温馨提示 您还没登录，请先登录后操作 取消、登录";
    [qingshuruyonghuming addAction:[UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
    }]];
    [qingshuruyonghuming addAction:[UIAlertAction actionWithTitle:@"登录" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        LoginVC *loginFriVC = [LoginVC new];
        LoginNavC *loginNavC = [[LoginNavC alloc]initWithRootViewController:loginFriVC];
        [loginNavC.navigationBar setBackgroundColor:[UIColor whiteColor]];
        //        [loginNavC.navigationBar setBackgroundImage:[UIImage imageNamed:@"mian-1"] forBarMetrics:UIBarMetricsDefault];
        loginNavC.navigationBar.tintColor = [UIColor blackColor];
        [self presentViewController:loginNavC animated:YES completion:nil];
    }]];
    
    [self presentViewController:qingshuruyonghuming animated:YES completion:nil];
}


- (void)addUser{
    NSLog(@"添加关注");
    tianjiaGuanZhuVC *tianjiaguanzhu = [tianjiaGuanZhuVC new];
    
    self.hidesBottomBarWhenPushed=YES;
    [self.navigationController pushViewController:tianjiaguanzhu animated:YES];
    //    self.hidesBottomBarWhenPushed=NO;
    
    
    
}
- (void)back
{
    [self.navigationController popViewControllerAnimated:YES];
}
- (void)refreshData{
    numberPage = 1;
    DefineWeakSelf;
    [NetWorkTool getPaoGuoGuanZhuLieBiaoWithaccessToken:[DSE encryptUseDES:self.user_login] andPage:@"1" andLimit:@"99999" sccess:^(NSDictionary *responseObject) {
        if ([responseObject[@"results"] isKindOfClass:[NSArray class]]) {
            self.infoArr = responseObject[@"results"];
            
            //已登录 -->请求自己的关注列表然后比较
            if ([[CommonCode readFromUserD:@"isLogin"]boolValue] == YES){
                [NetWorkTool getPaoGuoGuanZhuLieBiaoWithaccessToken:AvatarAccessToken andPage:@"1" andLimit:@"99999" sccess:^(NSDictionary *responseObject) {
                    isGuanZhuArr = [NSMutableArray array];
                    if ([responseObject[@"results"] isKindOfClass:[NSArray class]]){
                        NSArray *MyAttentionList = responseObject[@"results"];
                        BOOL isFans = NO;
                        for (int i = 0; i < self.infoArr.count; i ++ ){
                            for (int j = 0 ; j < MyAttentionList.count; j ++ ) {
                                if ([self.infoArr[i][@"friend_id"] isEqualToString:MyAttentionList[j][@"friend_id"]]) {
                                    isFans = YES;
                                    break;
                                }
                                else{
                                    isFans = NO;
                                    continue;
                                }
                                
                            }
                            if (isFans) {
                                [isGuanZhuArr addObject:@"1"];
                                
                            }
                            else{
                                [isGuanZhuArr addObject:@"0"];
                            }
                        }
                    }
                    else{
                        for (int i = 0; i < self.infoArr.count; i ++ ){
                            [isGuanZhuArr addObject:@"0"];
                        }
                    }
                    dispatch_async(dispatch_get_main_queue(), ^{
                        [weakSelf.tableView reloadData];
                    });
                    //        }
                    //        else {
                    //            self.infoArr = [NSMutableArray array];
                    //        }
                    //        isGuanZhuArr = [NSMutableArray array];
                    //        for (int i = 0; i < self.infoArr.count; i ++ ){
                    //            [isGuanZhuArr addObject:[NSString stringWithFormat:@"%@",self.infoArr[i][@"is_fan"]]];
                    //        }
                    //
                    //        [self.tableView reloadData];
                    [self.tableView.mj_header endRefreshing];
                } failure:^(NSError *error) {
                    dispatch_async(dispatch_get_main_queue(), ^{
                        [weakSelf.tableView reloadData];
                    });
                }];
            }
            else{
                isGuanZhuArr = [NSMutableArray array];
                for (int i = 0; i < self.infoArr.count; i ++ ){
                    [isGuanZhuArr addObject:@"0"];
                }
                dispatch_async(dispatch_get_main_queue(), ^{
                    [weakSelf.tableView reloadData];
                });
            }
            
        }
        else{
            self.infoArr = [NSMutableArray array];
        }
        [weakSelf.tableView reloadData];
        
    } failure:^(NSError *error) {
        NSLog(@"error = %@",error);
        [self.tableView.mj_header endRefreshing];
    }];
    
}

- (void)shangLaJiaZai{
    
    numberPage ++;
    [NetWorkTool getPaoGuoGuanZhuLieBiaoWithaccessToken:[DSE encryptUseDES:self.user_login] andPage:[NSString stringWithFormat:@"%d",numberPage] andLimit:@"10" sccess:^(NSDictionary *responseObject) {
        if ([responseObject[@"results"] isKindOfClass:[NSArray class]])
        {
            [self.infoArr addObjectsFromArray:responseObject[@"results"]];
            isGuanZhuArr = [NSMutableArray array];
            for (int i = 10; i < self.infoArr.count; i ++ ){
                [isGuanZhuArr addObject:[NSString stringWithFormat:@"%@",self.infoArr[i][@"is_fan"]]];
                NSString *name = self.infoArr[i][@"user_login"];
                
                [NetWorkTool getPaoGuoMoreUserInfoWithuser_login:[DSE encryptUseDES:name] sccess:^(NSDictionary *responseObject2){
                    NSMutableDictionary *dic = [[NSMutableDictionary alloc]init];
                    
                    if ([responseObject2[@"results"][@"signature"] isEqualToString:@""])
                    {
                        [dic setValue:@"没有简介" forKey:@"signature"];
                    }else
                    {
                        [dic setValue:responseObject2[@"results"][@"signature"] forKey:@"signature"];
                    }
                    [signatureArr addObject:dic];
                    
                    [self.tableView reloadData];
                    
                } failure:^(NSError *error2)
                 {
                     NSLog(@"error = %@",error2);
                 }];
            }
        }
        else{
            NSLog(@"没有更多数据了");
        }
        
        [self.tableView reloadData];
        [self.tableView.mj_footer endRefreshing];
        
    } failure:^(NSError *error) {
        NSLog(@"error = %@",error);
        [self.tableView.mj_footer endRefreshing];
        
    }];
    
}

#pragma mark --- 懒加载
- (UITableView *)tableView
{
    if (!_tableView){
        _tableView = [[UITableView alloc]initWithFrame:CGRectMake(0, 0, IPHONE_W, IPHONE_H - 64) style:UITableViewStylePlain];
        _tableView.delegate = self;
        _tableView.dataSource = self;
        _tableView.tableFooterView = [UIView new];
        DefineWeakSelf;
        _tableView.mj_header = [MJRefreshNormalHeader headerWithRefreshingBlock:^{
            [weakSelf refreshData];
        }];
        _tableView.mj_footer = [MJRefreshAutoStateFooter footerWithRefreshingBlock:^{
            [self shangLaJiaZai];
        }];
    }
    return _tableView;
}

- (NSMutableArray *)infoArr{
    if (!_infoArr){
        [NetWorkTool getPaoGuoGuanZhuLieBiaoWithaccessToken:[DSE encryptUseDES:self.user_login] andPage:@"1" andLimit:@"99999" sccess:^(NSDictionary *responseObject) {
            if ([responseObject[@"results"] isKindOfClass:[NSArray class]])
            {
                _infoArr = responseObject[@"results"];
            }
            else{
                _infoArr = [NSMutableArray array];
            }
            [CommonCode writeToUserD:_infoArr andKey:@"guanzhuliebiao"];
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
