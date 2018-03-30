//
//  faxianMoreViewController.m
//  kuangjiaTingWen
//
//  Created by 泡果 on 2018/3/5.
//  Copyright © 2018年 zhimi. All rights reserved.
//

#import "faxianMoreViewController.h"
#import "zhuboXiangQingVCNewController.h"

@interface faxianMoreViewController ()<UIGestureRecognizerDelegate,UITableViewDataSource,UITableViewDelegate>
{
    NSMutableArray *isGuanZhuArr;
}
@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, strong) NSMutableArray *infoArr;
@end

@implementation faxianMoreViewController
#pragma mark - setter

- (UITableView *)tableView{
    if (!_tableView){
        _tableView = [[UITableView alloc]initWithFrame:CGRectMake(0, IS_IPHONEX?IPHONEX_TOP_H:64, IPHONE_W,IS_IPHONEX?SCREEN_HEIGHT - IPHONEX_TOP_H: SCREEN_HEIGHT - 64) style:UITableViewStylePlain];
        _tableView.delegate = self;
        _tableView.dataSource = self;
        _tableView.tableFooterView = [UIView new];
    }
    return _tableView;
}

- (NSMutableArray *)infoArr{
    if (!_infoArr){
        _infoArr = [NSMutableArray array];
    }
    return _infoArr;
}
- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    [self.navigationController setNavigationBarHidden:YES animated:YES];
}
- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self setUpView];
    [self refreshData];
    
    self.tableView.mj_header = [MJRefreshNormalHeader headerWithRefreshingBlock:^{
        [self refreshData];
    }];
}

- (void)refreshData{
    [NetWorkTool getPaoguoJieMuLieBiaoWithterm_id:self.term_id andaccessToken:[DSE encryptUseDES:ExdangqianUser] sccess:^(NSDictionary *responseObject) {
        if ([responseObject[@"results"] isKindOfClass:[NSArray class]]){
            [self.infoArr removeAllObjects];
            [self.infoArr addObjectsFromArray:responseObject[@"results"]];
        }
        isGuanZhuArr = [NSMutableArray array];
        for (int i = 0; i < self.infoArr.count; i ++ ){
            [isGuanZhuArr addObject:[NSString stringWithFormat:@"%@",self.infoArr[i][@"is_fan"]]];
        }
        [self.tableView reloadData];
        [self.tableView.mj_header endRefreshing];
    } failure:^(NSError *error) {
        NSLog(@"error = %@",error);
        [self.tableView reloadData];
        [self.tableView.mj_header endRefreshing];
    }];
}
- (void)setUpView{
    
    [self setTitle:self.titleText];
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
    topLab.text = self.titleText;
    topLab.backgroundColor = [UIColor clearColor];
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
    
    [self.view addSubview:self.tableView];
    
    UISwipeGestureRecognizer *rightSwipe = [[UISwipeGestureRecognizer alloc]initWithTarget:self action:@selector(back)];
    [rightSwipe setDirection:UISwipeGestureRecognizerDirectionRight];
    [self.tableView addGestureRecognizer:rightSwipe];
}

- (void)back {
    [self.navigationController popViewControllerAnimated:YES];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return self.infoArr.count;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    NSDictionary *dic = [[NSDictionary alloc]initWithDictionary:self.infoArr[indexPath.row]];
    
    zhuboXiangQingVCNewController *faxianzhuboVC = [[zhuboXiangQingVCNewController alloc] init];
    faxianzhuboVC.jiemuDescription = dic[@"description"];
    faxianzhuboVC.jiemuFan_num = dic[@"fan_num"];
    faxianzhuboVC.jiemuID = dic[@"id"];
    faxianzhuboVC.jiemuImages = dic[@"images"];
    faxianzhuboVC.jiemuIs_fan = dic[@"is_fan"];
    faxianzhuboVC.jiemuMessage_num = dic[@"message_num"];
    faxianzhuboVC.jiemuName = dic[@"name"];
    faxianzhuboVC.post_content = dic[@"post_content"];
    faxianzhuboVC.isfaxian = YES;
    self.hidesBottomBarWhenPushed=YES;
    [self.navigationController pushViewController:faxianzhuboVC animated:YES];
    self.hidesBottomBarWhenPushed=YES;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    static NSString *jiemuLieBiaoIdentify = @"jiemuLieBiaoIdentify";
    UITableViewCell *cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:jiemuLieBiaoIdentify];
    if (!cell){
        cell = [tableView dequeueReusableCellWithIdentifier:jiemuLieBiaoIdentify];
    }
    //头像
    UIImageView *imgV = [[UIImageView alloc]initWithFrame:CGRectMake(15.0 / 375 * IPHONE_W, 10, 75, 75)];
    if([self.infoArr[indexPath.row][@"images"] rangeOfString:@"/data/upload/"].location !=NSNotFound){
        [imgV sd_setImageWithURL:[NSURL URLWithString:USERPHOTOHTTPSTRINGZhuBo(self.infoArr[indexPath.row][@"images"])] placeholderImage:[UIImage imageNamed:@"user-5"]];
    }
    else{
        [imgV sd_setImageWithURL:[NSURL URLWithString:USERPOTOAD( self.infoArr[indexPath.row][@"images"])] placeholderImage:[UIImage imageNamed:@"user-5"]];
    }
    imgV.layer.cornerRadius = 5;
    imgV.layer.masksToBounds = YES;
    imgV.contentMode = UIViewContentModeScaleAspectFill;
    [cell.contentView addSubview:imgV];
    //名字
    UILabel *titleLab = [[UILabel alloc]initWithFrame:CGRectMake(CGRectGetMaxX(imgV.frame) + 15.0 / 375 * IPHONE_W, 10.0 / 667 * SCREEN_HEIGHT, 200.0 / 375 * IPHONE_W, 15)];
    titleLab.text = self.infoArr[indexPath.row][@"name"];
    titleLab.textColor = gTextDownload;
    titleLab.textAlignment = NSTextAlignmentLeft;
    //        titleLab.font = gFontMajor16;
    [titleLab setFont:[UIFont fontWithName:@"Helvetica-Bold" size:16]];
    [cell.contentView addSubview:titleLab];
    //粉丝数
    UILabel *neirongLab = [[UILabel alloc]initWithFrame:CGRectMake(titleLab.x, CGRectGetMaxY(titleLab.frame) + 15, 230.0 / 375 * IPHONE_W, 15)];
    neirongLab.text = [NSString stringWithFormat:@"粉丝:%@  ",self.infoArr[indexPath.row][@"fan_num"]];
    neirongLab.textColor = UIColorFromHex(0x999999);
    neirongLab.font = gFontMain12;
    neirongLab.textAlignment = NSTextAlignmentLeft;
    neirongLab.tag = indexPath.row + 2000;
    [cell.contentView addSubview:neirongLab];
    //关注
    UIButton *isSelectBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    isSelectBtn.frame = CGRectMake(IPHONE_W - 65.0 / 375 * IPHONE_W, 10, 50.0 / 375 * IPHONE_W, 25);
    isSelectBtn.contentMode = UIViewContentModeScaleAspectFit;
    isSelectBtn.backgroundColor = gMainColor;
    isSelectBtn.layer.masksToBounds = YES;
    isSelectBtn.layer.cornerRadius = 5.0f;
    isSelectBtn.titleLabel.font = [UIFont systemFontOfSize:13.0f];
    
    if ([isGuanZhuArr[indexPath.row] isEqualToString:@"0"]){
        [isSelectBtn setTitle:@"关注" forState:UIControlStateNormal];
        isSelectBtn.selected = YES;
    }
    else{
        [isSelectBtn setTitle:@"取消" forState:UIControlStateNormal];
        isSelectBtn.selected = NO;
    }
    [isSelectBtn addTarget:self action:@selector(attentionAction:) forControlEvents:UIControlEventTouchUpInside];
    [cell.contentView addSubview:isSelectBtn];
    
    if (self.isAchor) {
        //new1
        UILabel *newOne = [[UILabel alloc]initWithFrame:CGRectMake(titleLab.frame.origin.x, CGRectGetMaxY(imgV.frame) + 10.0 / 667 * SCREEN_HEIGHT, SCREEN_WIDTH - titleLab.frame.origin.x - 15.0 / 375 * IPHONE_W, 20)];
        newOne.text = self.infoArr[indexPath.row][@"description"] ;
        newOne.textColor = gTextDownload;
        newOne.font = gFontMain12;
        newOne.textAlignment = NSTextAlignmentLeft;
        newOne.numberOfLines = 2;
        newOne.tag = indexPath.row + 3000;
        CGSize size1 = [newOne sizeThatFits:CGSizeMake(newOne.frame.size.width, MAXFLOAT)];
        newOne.frame = CGRectMake(newOne.frame.origin.x, newOne.frame.origin.y, newOne.frame.size.width, size1.height);
        [cell.contentView addSubview:newOne];
    }
    else{
        //new1
        UILabel *newOne = [[UILabel alloc]initWithFrame:CGRectMake(imgV.x, CGRectGetMaxY(imgV.frame) + 10.0 / 667 * SCREEN_HEIGHT, SCREEN_WIDTH - 10.0 / 375 * IPHONE_W - 15.0 / 375 * IPHONE_W, 20)];
        newOne.text = self.infoArr[indexPath.row][@"description"] ;
        newOne.textColor = gTextDownload;
        newOne.font = gFontMain12;
        newOne.textAlignment = NSTextAlignmentLeft;
        newOne.numberOfLines = 2;
        newOne.tag = indexPath.row + 3000;
        CGSize size1 = [newOne sizeThatFits:CGSizeMake(newOne.frame.size.width, MAXFLOAT)];
        newOne.frame = CGRectMake(newOne.frame.origin.x, newOne.frame.origin.y, newOne.frame.size.width, size1.height);
        [cell.contentView addSubview:newOne];
    }
    
    
    cell.tag = indexPath.row + 1000;
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    
    return cell;
}
#pragma mark - UIButtonAction

- (void)attentionAction:(UIButton *)sender{
    if ([[CommonCode readFromUserD:@"isLogin"]boolValue] == YES) {
        UITableViewCell *cell = (UITableViewCell *)[[sender superview] superview];
        NSIndexPath *indexPath = [self.tableView indexPathForCell:cell];
        
        if (sender.selected == NO){
            [NetWorkTool postPaoGuoCancelJieMuGuanZhuWithaccessToken:[DSE encryptUseDES:ExdangqianUser] andAct_id:self.infoArr[indexPath.row][@"id"] sccess:^(NSDictionary *responseObject) {
                [SVProgressHUD showSuccessWithStatus:responseObject[@"msg"]];
                [self performSelector:@selector(SVPDismiss) withObject:nil afterDelay:1.0];
                [isGuanZhuArr replaceObjectAtIndex:indexPath.row withObject:@"0"];
                [sender setTitle:@"关注" forState:UIControlStateNormal];
                sender.selected = YES;
                [self refreshData];
            } failure:^(NSError *error) {
                NSLog(@"error = %@",error);
            }];
            
        }
        else{
            
            [NetWorkTool postPaoGuoAddJieMuGuanZhuWithaccessToken:[DSE encryptUseDES:ExdangqianUser] andAct_id:self.infoArr[indexPath.row][@"id"] sccess:^(NSDictionary *responseObject) {
                [SVProgressHUD showSuccessWithStatus:responseObject[@"msg"]];
                [self performSelector:@selector(SVPDismiss) withObject:nil afterDelay:1.0];
                NSLog(@"responseObject = %@",responseObject);
                [isGuanZhuArr replaceObjectAtIndex:indexPath.row withObject:@"1"];
                [sender setTitle:@"取消" forState:UIControlStateNormal];
                sender.selected = NO;
                [self refreshData];
            } failure:^(NSError *error) {
                NSLog(@"error = %@",error);
            }];
            
        }
    }
    else{
        UIAlertController *qingshuruyonghuming = [UIAlertController alertControllerWithTitle:@"温馨提示" message:@"您还没登录，请先登录后操作" preferredStyle:UIAlertControllerStyleAlert];
        [qingshuruyonghuming addAction:[UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        }]];
        [qingshuruyonghuming addAction:[UIAlertAction actionWithTitle:@"登录" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            //            LoginNavC *loginNavC = [LoginNavC new];
            LoginVC *loginFriVC = [LoginVC new];
            LoginNavC *loginNavC = [[LoginNavC alloc]initWithRootViewController:loginFriVC];
            [loginNavC.navigationBar setBackgroundColor:[UIColor whiteColor]];
            //        [loginNavC.navigationBar setBackgroundImage:[UIImage imageNamed:@"mian-1"] forBarMetrics:UIBarMetricsDefault];
            loginNavC.navigationBar.tintColor = [UIColor blackColor];
            [self presentViewController:loginNavC animated:YES completion:nil];
        }]];
        
        [self presentViewController:qingshuruyonghuming animated:YES completion:nil];
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    UITableViewCell *cell = (UITableViewCell *)[tableView viewWithTag:indexPath.row + 1000];
    UILabel *lab1 = (UILabel *)[cell viewWithTag:indexPath.row + 3000];
    return CGRectGetMaxY(lab1.frame) + 15.0 / 667 * IPHONE_H;
}
- (void)SVPDismiss {
    [SVProgressHUD dismiss];
}

@end
