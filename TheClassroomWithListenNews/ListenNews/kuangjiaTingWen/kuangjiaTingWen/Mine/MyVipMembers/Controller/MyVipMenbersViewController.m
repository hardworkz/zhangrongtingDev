//
//  MyVipMenbersViewController.m
//  kuangjiaTingWen
//
//  Created by 泡果 on 2017/7/19.
//  Copyright © 2017年 zhimi. All rights reserved.
//

#import "MyVipMenbersViewController.h"

@interface MyVipMenbersViewController ()<UITableViewDelegate,UITableViewDataSource>
{
    NSInteger currentPage;
}
@property (strong, nonatomic) CustomAlertView *alertView;
@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, strong) NSMutableArray *dataSourceArr;
@property (strong, nonatomic) NSDictionary *user;

@property (strong, nonatomic) NSString *end_date;
@property (strong, nonatomic) NSString *is_member;

@property (assign, nonatomic) NSInteger currenPayMonth;
@end
static NSString *const VIPContent = @"普通会员:\n1.每日可收听新闻数不限\n2.可使用批量下载功能\n3.拥有尊贵VIP标识\n超级会员:\n1.享有普通会员全部特权\n2.可收听听闻课堂所有内容\n3.在听闻线下活动中拥有一次VIP席位\n温馨提示:\n1.会员服务一经开通后，不支持退款\n2.购买之后若还是无法正常使用，请尝试重启听闻客户端\n\n";/**<vip内容介绍*/

@implementation MyVipMenbersViewController
- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self setUpView];
    [self setUpData];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(AliPayResults:) name:AliPayResultsMembers object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(WechatPayResults:) name:WechatPayResultsMembers object:nil];
}
- (void)setUpView{
    
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
    topLab.text = @"听闻会员";
    topLab.backgroundColor = [UIColor clearColor];
    topLab.textAlignment = NSTextAlignmentCenter;
    [topView addSubview:topLab];
    UIView *seperatorLine = [[UIView alloc]initWithFrame:CGRectMake(0, 63.5, SCREEN_WIDTH, 0.5)];
    [seperatorLine setBackgroundColor:[UIColor lightGrayColor]];
    [topView addSubview:seperatorLine];
    
    [self.view addSubview:self.tableView];
    
    UISwipeGestureRecognizer *rightSwipe = [[UISwipeGestureRecognizer alloc]initWithTarget:self action:@selector(back)];
    [rightSwipe setDirection:UISwipeGestureRecognizerDirectionRight];
    [self.tableView addGestureRecognizer:rightSwipe];
    
    UIButton *call = [UIButton buttonWithType:UIButtonTypeCustom];
    [call setTitle:@"客服:0592-5962072"];
    call.titleLabel.font = [UIFont systemFontOfSize:12];
    [call setTitleColor:[UIColor lightGrayColor]];
    call.frame = CGRectMake(0, SCREEN_HEIGHT - 30, SCREEN_WIDTH, 30);
    [call addTarget:self action:@selector(call)];
    [self.view addSubview:call];
    
    CGSize size = [call.titleLabel.text boundingRectWithSize:CGSizeMake(MAXFLOAT, MAXFLOAT) options:NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName:call.titleLabel.font} context:nil].size;
    
    UIView *lineBottom = [[UIView alloc] init];
    lineBottom.backgroundColor = [UIColor lightGrayColor];
    lineBottom.frame = CGRectMake((SCREEN_WIDTH - size.width)*0.5, 20, size.width, 1);
    [call addSubview:lineBottom];
}
//呼叫客服
- (void)call
{
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"telprompt:0592-5962072"]];
}
- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    [self.navigationController setNavigationBarHidden:YES animated:YES];
}

- (void)setUpData{
    [NetWorkTool get_membersDataWithaccessToken:AvatarAccessToken sccess:^(NSDictionary *responseObject) {
        RTLog(@"%@",responseObject);
        if ([responseObject[status] intValue] == 1) {
            _end_date = responseObject[results][@"end_date"];
            _is_member = responseObject[results][@"is_member"];
            _user = responseObject[results][@"user"];
            NSArray *monthArray = [MembersDataModel mj_objectArrayWithKeyValuesArray:responseObject[results][@"memprcie"]];
            self.dataSourceArr = [monthArray mutableCopy];
            [self.tableView reloadData];
        }
    } failure:^(NSError *error) {
        
    }];
}


- (void)back
{
    [self.navigationController popViewControllerAnimated:YES];
}

#pragma mark - UITableViewDelegate

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    if (indexPath.row == 0) {
        return 90;
    }else if (indexPath.row == 1) {
        return 30;
    }else if (indexPath.row == 5) {
        return 30;
    }else if (indexPath.row == 7) {
        return SCREEN_HEIGHT - (90 + 60 + 4 * 44);
    }else{
        return 44;
    }
}


#pragma mark - UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    if (self.dataSourceArr.count) {
        return 8;
    }else{
        return 0;
    }
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    if (indexPath.row == 0) {
        MyUserVipTableViewCell *cell = [MyUserVipTableViewCell cellWithTableView:tableView];
        cell.end_date = _end_date;
        cell.is_member = self.is_member;
        cell.user = _user;
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        return cell;
    }else if (indexPath.row == 1) {
        MyVipSectionTableViewCell *cell = [MyVipSectionTableViewCell cellWithTableView:tableView];
        cell.content = @"普通会员:";
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        return cell;
    }else if (indexPath.row == 2||indexPath.row == 3||indexPath.row == 4) {
        MyVipMonthTableViewCell *cell = [MyVipMonthTableViewCell cellWithTableView:tableView];
        MembersDataModel *model = self.dataSourceArr[indexPath.row - 2];
        DefineWeakSelf
        cell.payBlock = ^(MyVipMonthTableViewCell *cell) {
            _currenPayMonth = [cell.model.monthes intValue];
            APPDELEGATE.payType = PayTypeMembers;
            _alertView = [[CustomAlertView alloc] initWithCustomView:[weakSelf setupPayAlert]];
            _alertView.alertHeight = 155;
            _alertView.alertDuration = 0.25;
            _alertView.coverAlpha = 0.6;
            [_alertView show];
        };
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        cell.is_member = _is_member;
        if (self.dataSourceArr.count) {
            cell.model = model;
        }
        return cell;
    }else if (indexPath.row == 5) {
        MyVipSectionTableViewCell *cell = [MyVipSectionTableViewCell cellWithTableView:tableView];
        cell.content = @"超级会员:";
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        return cell;
    }else if (indexPath.row == 6) {
        MyVipMonthTableViewCell *cell = [MyVipMonthTableViewCell cellWithTableView:tableView];
        DefineWeakSelf
        cell.payBlock = ^(MyVipMonthTableViewCell *cell) {
            _currenPayMonth = 20;
            APPDELEGATE.payType = PayTypeMembers;
            _alertView = [[CustomAlertView alloc] initWithCustomView:[weakSelf setupPayAlert]];
            _alertView.alertHeight = 155;
            _alertView.alertDuration = 0.25;
            _alertView.coverAlpha = 0.6;
            [_alertView show];
        };
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        cell.is_member = _is_member;
        if (self.dataSourceArr.count) {
            cell.model = self.dataSourceArr[indexPath.row - 3];
        }
        return cell;
    }else{
        MyVipPrivilegeTableViewCell *cell = [MyVipPrivilegeTableViewCell cellWithTableView:tableView];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        return cell;
    }
}
- (UITableView *)tableView{
    if (_tableView == nil) {
        _tableView = [[UITableView alloc]initWithFrame:CGRectMake(0, 64, SCREEN_WIDTH, SCREEN_HEIGHT - 64) style:UITableViewStylePlain];
        [_tableView setDelegate:self];
        [_tableView setDataSource:self];
        _tableView.backgroundColor = ColorWithRGBA(249, 247, 247, 1);
        [_tableView setSeparatorStyle:UITableViewCellSeparatorStyleNone];
    }
    return _tableView;
}

- (NSMutableArray *)dataSourceArr{
    if (!_dataSourceArr) {
        _dataSourceArr = [NSMutableArray array];
    }
    return _dataSourceArr;
}
#pragma mark - 支付弹窗模块
//创建支付弹窗view
- (UIView *)setupPayAlert
{
    UIView *bgView = [[UIView alloc] init];
    bgView.backgroundColor = HEXCOLOR(0xe3e3e3);
    bgView.frame = CGRectMake(0, 0, SCREEN_WIDTH, 155);
    
    UIButton *zhifubaoBtn = [[UIButton alloc] init];
    zhifubaoBtn.frame = CGRectMake(0, 0, SCREEN_WIDTH, 50);
    zhifubaoBtn.backgroundColor = [UIColor whiteColor];
    [zhifubaoBtn setImage:@"pay3"];
    zhifubaoBtn.imageEdgeInsets = UIEdgeInsetsMake(0, -20, 0, 0);
    [zhifubaoBtn setTitle:@"支付宝支付" forState:UIControlStateNormal];
    [zhifubaoBtn setTitleColor:gMainColor forState:UIControlStateNormal];
    zhifubaoBtn.titleLabel.font = [UIFont systemFontOfSize:17];
    [zhifubaoBtn addTarget:self action:@selector(zhifubaoBtnClicked)];
    [bgView addSubview:zhifubaoBtn];
    
    UIButton *weixinBtn = [[UIButton alloc] init];
    weixinBtn.frame = CGRectMake(0, 50, SCREEN_WIDTH, 50);
    weixinBtn.backgroundColor = [UIColor whiteColor];
    [weixinBtn setImage:@"pay4"];
    weixinBtn.imageEdgeInsets = UIEdgeInsetsMake(0, -20, 0, 0);
    [weixinBtn setTitle:@"微信支付" forState:UIControlStateNormal];
    [weixinBtn setTitleColor:gMainColor forState:UIControlStateNormal];
    weixinBtn.titleLabel.font = [UIFont systemFontOfSize:17];
    [weixinBtn addTarget:self action:@selector(weixinBtnClicked)];
    [bgView addSubview:weixinBtn];
    
    UIButton *cancelBtn = [[UIButton alloc] init];
    cancelBtn.frame = CGRectMake(0, 105, SCREEN_WIDTH, 50);
    cancelBtn.backgroundColor = [UIColor whiteColor];
    [cancelBtn setTitle:@"取消" forState:UIControlStateNormal];
    [cancelBtn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    cancelBtn.titleLabel.font = [UIFont systemFontOfSize:17];
    [cancelBtn addTarget:self action:@selector(cancelAlert)];
    [bgView addSubview:cancelBtn];
    
    return bgView;
}
//支付宝支付
- (void)zhifubaoBtnClicked
{
    [_alertView coverClick];
    [NetWorkTool AliPayWithaccessToken:AvatarAccessToken pay_type:@"2" act_id:nil money:nil mem_type:_currenPayMonth == 20?@"2":@"1" month:_currenPayMonth == 20?@"12":[NSString stringWithFormat:@"%ld",(long)_currenPayMonth] sccess:^(NSDictionary *responseObject) {
        RTLog(@"%@",responseObject);
        if ([responseObject[status] intValue] == 1) {
            // NOTE: 调用支付结果开始支付
            [[AlipaySDK defaultService] payOrder:responseObject[results][@"response"] fromScheme:appScheme callback:^(NSDictionary *resultDic) {
                switch (APPDELEGATE.payType) {
                    case PayTypeClassPay:
                        [[NSNotificationCenter defaultCenter] postNotificationName:AliPayResultsClass object:resultDic];
                        break;
                    case PayTypeReward:
                        [[NSNotificationCenter defaultCenter] postNotificationName:AliPayResultsReward object:resultDic];
                        break;
                    case PayTypeRecharge:
                        [[NSNotificationCenter defaultCenter] postNotificationName:AliPayResultsRecharge object:resultDic];
                        break;
                    case PayTypeMembers:
                        [[NSNotificationCenter defaultCenter] postNotificationName:AliPayResultsMembers object:resultDic];
                        break;
                        
                    default:
                        break;
                }
            }];

        }else{
            XWAlerLoginView *alert = [[XWAlerLoginView alloc] initWithTitle:responseObject[msg]];
            [alert show];
        }
    } failure:^(NSError *error) {
        XWAlerLoginView *alert = [[XWAlerLoginView alloc] initWithTitle:@"网络错误"];
        [alert show];
    }];
}
//微信支付
- (void)weixinBtnClicked
{
    [_alertView coverClick];
    [NetWorkTool WXPayWithaccessToken:AvatarAccessToken pay_type:@"2" act_id:nil money:nil mem_type:_currenPayMonth == 20?@"2":@"1" month:_currenPayMonth == 20?@"12":[NSString stringWithFormat:@"%ld",(long)_currenPayMonth] sccess:^(NSDictionary *responseObject) {
        RTLog(@"%@",responseObject);
        if ([responseObject[status] intValue] == 1) {
            NSDictionary *payDic = responseObject[results];
            //调起微信支付
            PayReq *req             = [[PayReq alloc] init];
            req.openID              = [payDic objectForKey:@"appid"];
            req.partnerId           = [payDic objectForKey:@"partnerid"];
            req.prepayId            = [payDic objectForKey:@"prepayid"];
            req.nonceStr            = [payDic objectForKey:@"noncestr"];
            NSMutableString *stamp  = [payDic objectForKey:@"timestamp"];
            req.timeStamp           = stamp.intValue;
            req.package             = [payDic objectForKey:@"package"];
            req.sign                = [payDic objectForKey:@"sign"];
            [WXApi sendReq:req];
        }else{
            XWAlerLoginView *alert = [[XWAlerLoginView alloc] initWithTitle:responseObject[msg]];
            [alert show];
        }
    } failure:^(NSError *error) {
        XWAlerLoginView *alert = [[XWAlerLoginView alloc] initWithTitle:@"网络错误"];
        [alert show];
    }];
}
//取消支付弹窗
- (void)cancelAlert
{
    APPDELEGATE.payType = PayTypeNone;
    [_alertView coverClick];
}
#pragma mark - 支付结果通知方法
- (void)AliPayResults:(NSNotification *)notification
{
    NSString* title=@"支付结果",*msg=@"您的会员已开通成功",*sureTitle=@"确定";
    NSDictionary *resultDic = notification.object;
    if ([resultDic[@"resultStatus"]integerValue] == 9000) {
        
        UIAlertController *qingshuruyonghuming = [UIAlertController alertControllerWithTitle:title message:msg preferredStyle:UIAlertControllerStyleAlert];
        [qingshuruyonghuming addAction:[UIAlertAction actionWithTitle:sureTitle style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            [self setUpData];
        }]];
        [self presentViewController:qingshuruyonghuming animated:YES completion:nil];

    }
    else if ([resultDic[@"resultStatus"]integerValue] == 8000){
        //正在处理中
        title=@"支付结果";msg=@"正在处理中";sureTitle=@"确定";
        UIAlertController *qingshuruyonghuming = [UIAlertController alertControllerWithTitle:title message:msg preferredStyle:UIAlertControllerStyleAlert];
        [qingshuruyonghuming addAction:[UIAlertAction actionWithTitle:sureTitle style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        }]];
        [self presentViewController:qingshuruyonghuming animated:YES completion:nil];
    }
    else if ([resultDic[@"resultStatus"]integerValue] == 4000){
        //订单支付失败
        title=@"支付结果";msg=@"返回信息错误，请稍后再试";sureTitle=@"确定";
        UIAlertController *qingshuruyonghuming = [UIAlertController alertControllerWithTitle:title message:msg preferredStyle:UIAlertControllerStyleAlert];
        [qingshuruyonghuming addAction:[UIAlertAction actionWithTitle:sureTitle style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        }]];
        [self presentViewController:qingshuruyonghuming animated:YES completion:nil];
    }
    else if ([resultDic[@"resultStatus"]integerValue] == 6001){
        //用户中途取消
        title=@"支付结果";msg=@"用户中途取消，请稍后再试";sureTitle=@"确定";
        UIAlertController *qingshuruyonghuming = [UIAlertController alertControllerWithTitle:title message:msg preferredStyle:UIAlertControllerStyleAlert];
        [qingshuruyonghuming addAction:[UIAlertAction actionWithTitle:sureTitle style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        }]];
        [self presentViewController:qingshuruyonghuming animated:YES completion:nil];
    }
    else if ([resultDic[@"resultStatus"]integerValue] == 6002){
        //网络连接出错
        title=@"支付结果";msg=@"网络连接出错，请稍后再试";sureTitle=@"确定";
        UIAlertController *qingshuruyonghuming = [UIAlertController alertControllerWithTitle:title message:msg preferredStyle:UIAlertControllerStyleAlert];
        [qingshuruyonghuming addAction:[UIAlertAction actionWithTitle:sureTitle style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        }]];
        [self presentViewController:qingshuruyonghuming animated:YES completion:nil];
    }
    else{
        //
        title=@"支付结果";msg=@"返回信息错误，请稍后再试";sureTitle=@"确定";
        UIAlertController *qingshuruyonghuming = [UIAlertController alertControllerWithTitle:title message:msg preferredStyle:UIAlertControllerStyleAlert];
        [qingshuruyonghuming addAction:[UIAlertAction actionWithTitle:sureTitle style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        }]];
        [self presentViewController:qingshuruyonghuming animated:YES completion:nil];
    }
    //充值成功 --》 获取用户信息
    [[NSNotificationCenter defaultCenter] postNotificationName:@"updateUserInfo" object:nil];
}

- (void)WechatPayResults:(NSNotification *)notification {
    NSString* title=@"支付结果",*msg=@"您的会员已开通成功",*sureTitle=@"确定";
    if ([notification.object integerValue] == 0) {
        UIAlertController *qingshuruyonghuming = [UIAlertController alertControllerWithTitle:title message:msg preferredStyle:UIAlertControllerStyleAlert];
        [qingshuruyonghuming addAction:[UIAlertAction actionWithTitle:sureTitle style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            [self setUpData];
        }]];
        [self presentViewController:qingshuruyonghuming animated:YES completion:nil];
    }
    else if ([notification.object integerValue] == -2){
        title=@"支付结果";msg=@"用户中途取消，请稍后再试";sureTitle=@"确定";
        UIAlertController *qingshuruyonghuming = [UIAlertController alertControllerWithTitle:title message:msg preferredStyle:UIAlertControllerStyleAlert];
        [qingshuruyonghuming addAction:[UIAlertAction actionWithTitle:sureTitle style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        }]];
        [self presentViewController:qingshuruyonghuming animated:YES completion:nil];
    }
    else{
        title=@"支付结果";msg=@"返回信息错误，请稍后再试";sureTitle=@"确定";
        UIAlertController *qingshuruyonghuming = [UIAlertController alertControllerWithTitle:title message:msg preferredStyle:UIAlertControllerStyleAlert];
        [qingshuruyonghuming addAction:[UIAlertAction actionWithTitle:sureTitle style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        }]];
        [self presentViewController:qingshuruyonghuming animated:YES completion:nil];
    }
    //充值成功 --》 获取用户信息
    [[NSNotificationCenter defaultCenter] postNotificationName:@"updateUserInfo" object:nil];
}

@end
