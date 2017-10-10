//
//  tianjiaGuanZhuVC.m
//  kuangjiaTingWen
//
//  Created by 贺楠 on 16/6/30.
//  Copyright © 2016年 贺楠. All rights reserved.
//

#import "tianjiaGuanZhuVC.h"
#import "UIImageView+WebCache.h"
#import "MJRefresh.h"
#import "gerenzhuyeVC.h"
#import "AddBookViewController.h"
@interface tianjiaGuanZhuVC ()<UITableViewDataSource,UITableViewDelegate,UISearchBarDelegate>
{
    int numberPage;
}
@property(strong,nonatomic)NSMutableArray *infoArr;
@property(strong,nonatomic)UITableView *tableView;
@property(strong,nonatomic)UISearchBar *searchBar;
@end

@implementation tianjiaGuanZhuVC

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.title = @"添加关注";
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
    
    UIView *headerView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, IPHONE_W, 107)];
    headerView.backgroundColor = [UIColor whiteColor];
    UIView *downView = [[UIView alloc]initWithFrame:CGRectMake(0, 40, IPHONE_W, 67)];
    downView.backgroundColor = [UIColor whiteColor];
    downView.userInteractionEnabled = YES;
    [headerView addSubview:downView];
    
    UIImageView *imgV = [[UIImageView alloc]initWithFrame:CGRectMake(10.0 / 375 * IPHONE_W, 11, 45, 45)];
    imgV.image = [UIImage imageNamed:@"ic_phonebook_light"];
    imgV.layer.cornerRadius = 22.5f;
    imgV.layer.masksToBounds = YES;
    imgV.contentMode = UIViewContentModeScaleAspectFit;
    [downView addSubview:imgV];
    UILabel *lab = [[UILabel alloc]initWithFrame:CGRectMake(5.0 / 375 * IPHONE_W + 67.0 / 375 * IPHONE_W, 13.5, IPHONE_W - 30, 40)];
    [downView addSubview:lab];
    lab.text = @"匹配通讯录";
    lab.textColor = [UIColor blackColor];
    lab.font = [UIFont systemFontOfSize:17.0f];
    UIImageView *jiantouImgV = [[UIImageView alloc]initWithFrame:CGRectMake(IPHONE_W - 30, 23.5, 20, 20)];
    jiantouImgV.image = [UIImage imageNamed:@"tongxunluJianTou"];
    [downView addSubview:jiantouImgV];
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(pipeitongxunlu:)];
    [downView addGestureRecognizer:tap];
    jiantouImgV.userInteractionEnabled = YES;
    lab.userInteractionEnabled = YES;
    [headerView addSubview:self.searchBar];
    UIView *downLine = [[UIView alloc]initWithFrame:CGRectMake(15, 66, IPHONE_W, 1)];
    downLine.backgroundColor = gSubColor;
    [downView addSubview:downLine];
    self.tableView.tableHeaderView = headerView;
    
    UISwipeGestureRecognizer *rightSwipe = [[UISwipeGestureRecognizer alloc]initWithTarget:self action:@selector(back)];
    [rightSwipe setDirection:UISwipeGestureRecognizerDirectionRight];
    [self.tableView addGestureRecognizer:rightSwipe];
    
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self.tableView.mj_header beginRefreshing];
    [self.navigationController setNavigationBarHidden:NO animated:YES];
    self.hidesBottomBarWhenPushed = YES;
}

#pragma mark --- 搜索框代理
//将要开始编辑时的回调
- (void)searchBarTextDidBeginEditing:(UISearchBar *)searchBar
{
    [searchBar setShowsCancelButton:YES animated:YES];
    [self.infoArr removeAllObjects];
    [self.tableView reloadData];
}
//点击取消按钮时的回调
- (void)searchBarCancelButtonClicked:(UISearchBar *)searchBar
{
    [searchBar setShowsCancelButton:NO animated:YES];
    [searchBar resignFirstResponder];

}
//将要结束编辑时的回调
- (void)searchBarTextDidEndEditing:(UISearchBar *)searchBar
{
    [searchBar setShowsCancelButton:NO animated:YES];
    [searchBar resignFirstResponder];
    
    NSLog(@"搜索的为 = %@",searchBar.text);
}
//搜索按钮点击的回调
- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar
{
    [searchBar setShowsCancelButton:NO animated:YES];
    [searchBar resignFirstResponder];
    
    [NetWorkTool getPaoGuosousuoYongHuXinXiLieBiaoWithaccessToken:[DSE encryptUseDES:ExdangqianUser] andkeywords:searchBar.text sccess:^(NSDictionary *responseObject) {
        [self.infoArr removeAllObjects];
        if ([responseObject[@"results"] isKindOfClass:[NSArray class]])
        {
            [self.infoArr addObjectsFromArray:responseObject[@"results"]];
        }
        [self.tableView reloadData];
    } failure:^(NSError *error) {
        NSLog(@"error = %@",error);
    }];
}

//输入文本实时更新时调用
- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText

{
    
    if (searchText.length == 0)
    {
        return;
    }else
    {
        [NetWorkTool getPaoGuosousuoYongHuXinXiLieBiaoWithaccessToken:[DSE encryptUseDES:ExdangqianUser] andkeywords:searchText sccess:^(NSDictionary *responseObject) {
            [self.infoArr removeAllObjects];
            if ([responseObject[@"results"] isKindOfClass:[NSArray class]])
            {
                [self.infoArr addObjectsFromArray:responseObject[@"results"]];
            }
            [self.tableView reloadData];
        } failure:^(NSError *error) {
            NSLog(@"error = %@",error);
        }];
    }
    
}

#pragma mark --- tableView代理事件
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.infoArr.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *guanzhuliebiaoIdentify = @"guanzhuliebiaoIdentify";
    UITableViewCell *cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:guanzhuliebiaoIdentify];
    
    if (!cell)
    {
        cell = [tableView dequeueReusableCellWithIdentifier:guanzhuliebiaoIdentify];
    }
    UIImageView *imgV = [[UIImageView alloc]initWithFrame:CGRectMake(10.0 / 375 * IPHONE_W, 11, 45, 45)];
    if ([self.infoArr isKindOfClass:[NSArray class]])
    {
        if ([self.infoArr[indexPath.row][@"avatar"]  rangeOfString:@"http"].location != NSNotFound)
        {
            [imgV sd_setImageWithURL:[NSURL URLWithString:self.infoArr[indexPath.row ][@"avatar"]] placeholderImage:[UIImage imageNamed:@"user-5"]];
        }else
        {
            [imgV sd_setImageWithURL:[NSURL URLWithString:USERPHOTOHTTPSTRING(self.infoArr[indexPath.row][@"avatar"])] placeholderImage:[UIImage imageNamed:@"user-5"]];
        }
    }
        
    imgV.layer.cornerRadius = 22.5f;
    imgV.layer.masksToBounds = YES;
    imgV.contentMode = UIViewContentModeScaleAspectFit;
    [cell.contentView addSubview:imgV];
    
    UILabel *titleLab = [[UILabel alloc]initWithFrame:CGRectMake(5.0 / 375 * IPHONE_W + 57 + 10.0 / 375 * IPHONE_W, 15, 200.0 / 375 * IPHONE_W, 15)];
    if ([self.infoArr isKindOfClass:[NSArray class]])
    {
        if (self.infoArr.count)
        {
            titleLab.text = self.infoArr[indexPath.row][@"user_nicename"];
        }
    }
    
    titleLab.textColor = [UIColor blackColor];
    titleLab.textAlignment = NSTextAlignmentLeft;
    titleLab.font = [UIFont systemFontOfSize:16.0f];
    [cell.contentView addSubview:titleLab];
        
    UILabel *neirongLab = [[UILabel alloc]initWithFrame:CGRectMake(5.0 / 375 * IPHONE_W + 67.0 / 375 * IPHONE_W, 37, 230.0 / 375 * IPHONE_W, 15)];
        
    NSString *sigtStr = self.infoArr[indexPath.row][@"signature"];
        
    if (sigtStr.length == 0)
    {
        neirongLab.text = @"该用户没有什么想说的";
    }else
    {
        neirongLab.text = sigtStr;
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

    [isSelectBtn setTitle:@"关注" forState:UIControlStateNormal];
    isSelectBtn.selected = NO;
    isSelectBtn.backgroundColor = gMainColor;
    isSelectBtn.layer.masksToBounds = YES;
    isSelectBtn.layer.cornerRadius = 5.0f;
    isSelectBtn.titleLabel.font = [UIFont systemFontOfSize:13.0f];
        
    [isSelectBtn addTarget:self action:@selector(tapAction:) forControlEvents:UIControlEventTouchUpInside];
    
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    return cell;

}
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    gerenzhuyeVC *gerenzhuye = [gerenzhuyeVC new];
    gerenzhuye.isMypersonalPage = NO;
    gerenzhuye.user_nicename = self.infoArr[indexPath.row][@"user_nicename"];
    gerenzhuye.sex = [NSString stringWithFormat:@"%@",self.infoArr[indexPath.row][@"sex"]];
    gerenzhuye.signature = self.infoArr[indexPath.row][@"signature"];
    gerenzhuye.user_login = self.infoArr[indexPath.row][@"user_login"];
    gerenzhuye.avatar = self.infoArr[indexPath.row][@"avatar"];
    gerenzhuye.fan_num = [NSString stringWithFormat:@"%@",self.infoArr[indexPath.row][@"fan_num"]];
    gerenzhuye.guan_num = [NSString stringWithFormat:@"%@",self.infoArr[indexPath.row][@"guan_num"]];
    gerenzhuye.user_id = self.infoArr[indexPath.row][@"id"];
    self.hidesBottomBarWhenPushed=NO;
    [self.navigationController pushViewController:gerenzhuye animated:YES];
}
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 67;
}
#pragma mark --- 点击事件
- (void)pipeitongxunlu:(UITapGestureRecognizer *)tap{
    
    AddBookViewController *tongxunlu = [[AddBookViewController alloc]init];
    self.hidesBottomBarWhenPushed=YES;
    [self.navigationController pushViewController:tongxunlu animated:YES];
    
}
- (void)tapAction:(UIButton *)sender {
    UITableViewCell *cell = (UITableViewCell *)[[sender superview] superview];
    NSIndexPath *indexPath = [self.tableView indexPathForCell:cell];
    [NetWorkTool getPaoGuoAddFriendWithaccessToken:[DSE encryptUseDES:ExdangqianUser] anduid_2:self.infoArr[indexPath.row][@"id"] sccess:^(NSDictionary *responseObject) {
        if ([[NSString stringWithFormat:@"%@",responseObject[@"status"]] isEqualToString:@"0"]){
            UIAlertController *qingshuruyonghuming = [UIAlertController alertControllerWithTitle:responseObject[@"msg"] message:nil preferredStyle:UIAlertControllerStyleAlert];
            [qingshuruyonghuming addAction:[UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
                [self.tableView reloadData];
            }]];
            [self presentViewController:qingshuruyonghuming animated:YES completion:nil];
        }
        else{
            [self.infoArr removeObjectAtIndex:indexPath.row];
            [self.tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationLeft];
//            [self.tableView reloadData];
        }
    } failure:^(NSError *error) {
        NSLog(@"error = %@",error);
    }];
}

#pragma mark --- 刷新加载
- (void)refreshData
{
    [NetWorkTool getPaoGuoSuiJiYongHuXinXiWithaccessToken:[DSE encryptUseDES:ExdangqianUser] andPage:@"1" andLimit:@"10" sccess:^(NSDictionary *responseObject) {
        if ([responseObject[@"results"] isKindOfClass:[NSArray class]])
        {
            [self.infoArr removeAllObjects];
            [self.infoArr addObjectsFromArray:responseObject[@"results"]];
            [self.tableView reloadData];
            numberPage = 1;
            
        }
        [self.tableView.mj_header endRefreshing];
    } failure:^(NSError *error) {
        NSLog(@"error = %@",error);
        [self.tableView.mj_header endRefreshing];
    }];
}
- (void)shanglajiazai
{
    numberPage ++;
    NSString *StrPage = [NSString stringWithFormat:@"%d",numberPage];
    
    [NetWorkTool getPaoGuoSuiJiYongHuXinXiWithaccessToken:[DSE encryptUseDES:ExdangqianUser] andPage:StrPage andLimit:@"10" sccess:^(NSDictionary *responseObject) {
        if ([responseObject[@"results"] isKindOfClass:[NSArray class]])
        {
            [self.infoArr addObjectsFromArray:responseObject[@"results"]];
            [self.tableView reloadData];
            
        }
        [self.tableView.mj_footer endRefreshing];
    } failure:^(NSError *error) {
        NSLog(@"error = %@",error);
        [self.tableView.mj_footer endRefreshing];
    }];
}
#pragma mark --- 按钮事件
- (void)back
{
    [self.navigationController popViewControllerAnimated:YES];
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark --- 懒加载
- (UITableView *)tableView
{
    if (!_tableView)
    {
        _tableView = [[UITableView alloc]initWithFrame:CGRectMake(0, 0, IPHONE_W, IPHONE_H) style:UITableViewStylePlain];
        _tableView.delegate = self;
        _tableView.dataSource = self;
        _tableView.tableFooterView = [UIView new];
        _tableView.mj_header = [MJRefreshNormalHeader headerWithRefreshingBlock:^{
            [self refreshData];
        }];
        _tableView.mj_footer = [MJRefreshAutoStateFooter footerWithRefreshingBlock:^{
            [self shanglajiazai];
        }];
    }
    return _tableView;
}

- (NSMutableArray *)infoArr
{
    if (!_infoArr)
    {
        _infoArr = [[NSMutableArray alloc]init];
    }
    return _infoArr;
}

- (UISearchBar *)searchBar
{
    if (!_searchBar)
    {
        _searchBar = [[UISearchBar alloc]initWithFrame:CGRectMake(0, 0, IPHONE_W, 40)];
        _searchBar.placeholder = @"用户名称";
        _searchBar.delegate = self;
    }
    return _searchBar;
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
