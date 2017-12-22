//
//  PayOnlineViewController.m
//  kuangjiaTingWen
//
//  Created by Zhimi on 17/1/3.
//  Copyright © 2017年 贺楠. All rights reserved.
//

#import "PayOnlineViewController.h"
#import "TTTAttributedLabel.h"
#import <AlipaySDK/AlipaySDK.h>
#import "Order.h"
#import "APAuthV2Info.h"
#import "RSADataSigner.h"
#import "AppDelegate.h"
#import "PayViewController.h"
#import "LoginVC.h"
#import "LoginNavC.h"

@interface PayOnlineViewController ()<UITableViewDelegate,UITableViewDataSource>

@property (strong, nonatomic) UITableView *payOnlinetableView;

@property (strong, nonatomic) UIButton *tCoinPay;

@property (strong, nonatomic) UIButton *aliPay;

@property (strong, nonatomic) UIButton *wechatPay;

@property (strong, nonatomic) UILabel *payCountLabel;

@property (strong, nonatomic) UILabel *payCount;

@property (strong, nonatomic) UIButton *confirButton;

@property (assign, nonatomic) BOOL isIAP;



@end

@implementation PayOnlineViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setupData];
    [self setupView];
}

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    [self.navigationController setNavigationBarHidden:YES animated:YES];
}

- (void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    [self.navigationController setNavigationBarHidden:NO animated:YES];
}

- (void)setupData{
    
    _isIAP = NO;
    if ([CommonCode readFromUserD:@"isIAP"] == nil) {
        //是否内购
        [NetWorkTool getAppVersionSccess:^(NSDictionary *responseObject) {
            NSLog(@"%@",responseObject);
            //听闻电台
            if ([APPBUNDLEIDENTIFIER isEqualToString:@"com.popwcn.ListenNewsExploreVersion"]) {
                //当前版本号与提交审核时后台配置的一样说明正在审核
                if ([responseObject[@"results"][@"exploreVersion"] isEqualToString:APPVERSION]) {
                    _isIAP = YES;
                }
                else{
                    _isIAP = NO;
                }
            }
            //听闻FM
            else{
                if ([responseObject[@"results"][@"listenNews"] isEqualToString:APPVERSION]) {
                    _isIAP = YES;
                }
                else{
                    _isIAP = NO;
                }
            }
            
        } failure:^(NSError *error) {
            //
        }];
    }
    else{
        if ([[CommonCode readFromUserD:@"isIAP"] boolValue] == YES) {
            _isIAP = YES;
        }
        else{
            _isIAP = NO;
        }
    }

    [self.payCount setText:[NSString stringWithFormat:@"%.2f元",self.rewardCount]];
}

- (void)setupView {
    self.title = @"在线支付";
//    [self enableAutoBack];
    self.automaticallyAdjustsScrollViewInsets = NO;
    self.extendedLayoutIncludesOpaqueBars = NO;
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
    topLab.text = @"在线支付";
    topLab.backgroundColor = [UIColor clearColor];
    topLab.textAlignment = NSTextAlignmentCenter;
    [topView addSubview:topLab];
    UIView *seperatorLine = [[UIView alloc]initWithFrame:CGRectMake(0, 63.5, SCREEN_WIDTH, 0.5)];
    [seperatorLine setBackgroundColor:[UIColor lightGrayColor]];
    [topView addSubview:seperatorLine];
    [self.view addSubview:self.payOnlinetableView];
    [self.payOnlinetableView.tableFooterView setUserInteractionEnabled:YES];
    [self.payOnlinetableView.tableFooterView addSubview:self.confirButton];
    [self.payOnlinetableView.tableFooterView addSubview:self.payCountLabel];
    [self.payOnlinetableView.tableFooterView addSubview:self.payCount];
    UISwipeGestureRecognizer *rightSwipe = [[UISwipeGestureRecognizer alloc]initWithTarget:self action:@selector(back)];
    [rightSwipe setDirection:UISwipeGestureRecognizerDirectionRight];
    [self.payOnlinetableView addGestureRecognizer:rightSwipe];
    
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(AliPayResults:) name:AliPayResultsReward object:nil];
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(WechatPayResults:) name:WechatPayResultsReward object:nil];
}

- (UITableView *)payOnlinetableView {
    if (!_payOnlinetableView){
        _payOnlinetableView = [[UITableView alloc]initWithFrame:CGRectMake(0, 64, SCREEN_WIDTH, SCREEN_HEIGHT - 64) style:UITableViewStylePlain];
        _payOnlinetableView.delegate = self;
        _payOnlinetableView.dataSource = self;
        UIView *tableFooterView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, 85 + 15)];
        [tableFooterView setBackgroundColor:[UIColor clearColor]];
        _payOnlinetableView.tableFooterView = tableFooterView;
        _payOnlinetableView.backgroundColor = gSubColor;
        _payOnlinetableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    }
    return _payOnlinetableView;
}

- (UILabel *)payCountLabel {
    if (!_payCountLabel) {
        _payCountLabel = [[UILabel alloc]initWithFrame:CGRectMake(SCREEN_WIDTH - 140, 10, 65, 25)];
        [_payCountLabel setFont:gFontMain14];
        [_payCountLabel setText:@"支付金额:"];
    }
    return _payCountLabel;
}

- (UILabel *)payCount {
    if (!_payCount) {
        _payCount = [[UILabel alloc]initWithFrame:CGRectMake(SCREEN_WIDTH - 80, 10, 70, 25)];
        [_payCount setFont:gFontMajor17];
        [_payCount setTextColor:UIColorFromHex(0xf78540)];
    }
    return _payCount;
}

- (UIButton *)confirButton {
    if (!_confirButton) {
        _confirButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [_confirButton setFrame:CGRectMake(15,45, SCREEN_WIDTH - 30, 40)];
        [_confirButton setUserInteractionEnabled:YES];
        [_confirButton setTitle:@"立即支付" forState:UIControlStateNormal];
        [_confirButton.titleLabel setFont:gFontMajor17];
        [_confirButton setTitleColor:gTextColorMain forState:UIControlStateNormal];
        [_confirButton setBackgroundColor:gMainColor];
        [_confirButton.layer setMasksToBounds:YES];
        [_confirButton.layer setCornerRadius:5];
        [_confirButton addTarget:self action:@selector(payNowButtonAction:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _confirButton;
}

- (UIButton *)tCoinPay{
    if (!_tCoinPay) {
        _tCoinPay =  [UIButton buttonWithType:UIButtonTypeCustom];
        [_tCoinPay setFrame:CGRectMake(SCREEN_WIDTH - 42, 15, 20, 20)];
        [_tCoinPay setImage:[UIImage imageNamed:@"unselecte"] forState:UIControlStateNormal];
        [_tCoinPay setImage:[UIImage imageNamed:@"selected"] forState:UIControlStateSelected];
        [_tCoinPay addTarget:self action:@selector(tCoinPayAction:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _tCoinPay;
}

- (UIButton *)aliPay{
    if (!_aliPay) {
        _aliPay =  [UIButton buttonWithType:UIButtonTypeCustom];
        [_aliPay setFrame:CGRectMake(SCREEN_WIDTH - 42, 15, 20, 20)];
        [_aliPay setImage:[UIImage imageNamed:@"unselecte"] forState:UIControlStateNormal];
        [_aliPay setImage:[UIImage imageNamed:@"selected"] forState:UIControlStateSelected];
        [_aliPay addTarget:self action:@selector(aliPayAction:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _aliPay;
}

- (UIButton *)wechatPay{
    if (!_wechatPay) {
        _wechatPay =  [UIButton buttonWithType:UIButtonTypeCustom];
        [_wechatPay setFrame:CGRectMake(SCREEN_WIDTH - 42, 15, 20, 20)];
        [_wechatPay setImage:[UIImage imageNamed:@"unselecte"] forState:UIControlStateNormal];
        [_wechatPay setImage:[UIImage imageNamed:@"selected"] forState:UIControlStateSelected];
        [_wechatPay addTarget:self action:@selector(wechatPayAction:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _wechatPay;
}

#pragma mark - UIButtonAction

- (void)tCoinPayAction:(UIButton *)sender {
    
    sender.selected = YES;
    self.aliPay.selected = NO;
    self.wechatPay.selected = NO;
}

- (void)aliPayAction:(UIButton *)sender {
    sender.selected = YES;
    self.tCoinPay.selected = NO;
    self.wechatPay.selected = NO;
}

- (void)wechatPayAction:(UIButton *)sender {
    sender.selected = YES;
    self.aliPay.selected = NO;
    self.tCoinPay.selected = NO;
}
- (void)rechargeButtonAction:(UIButton *)sender {
    if ([[CommonCode readFromUserD:@"isLogin"]boolValue] == YES){
        self.hidesBottomBarWhenPushed=YES;
        [self.navigationController pushViewController:[PayViewController new] animated:YES];
        self.hidesBottomBarWhenPushed=YES;
    }
    else{
        if ([[CommonCode readFromUserD:@"isIAP"] boolValue] == YES) {
            UIAlertController *qingshuruyonghuming = [UIAlertController alertControllerWithTitle:@"温馨提示" message:@"您还没登录，如果不进行登录，则当前充值数据无法绑定账号，会丢失充值数据，确定前往充值？" preferredStyle:UIAlertControllerStyleAlert];
            [qingshuruyonghuming addAction:[UIAlertAction actionWithTitle:@"仍去充值" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
                
                self.hidesBottomBarWhenPushed=YES;
                [self.navigationController pushViewController:[PayViewController new] animated:YES];
                self.hidesBottomBarWhenPushed=YES;
            }]];
            [qingshuruyonghuming addAction:[UIAlertAction actionWithTitle:@"去登录" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
                LoginVC *loginFriVC = [LoginVC new];
                LoginNavC *loginNavC = [[LoginNavC alloc]initWithRootViewController:loginFriVC];
                [loginNavC.navigationBar setBackgroundColor:[UIColor whiteColor]];
                loginNavC.navigationBar.tintColor = [UIColor blackColor];
                [self presentViewController:loginNavC animated:YES completion:nil];
            }]];
            
            [self presentViewController:qingshuruyonghuming animated:YES completion:nil];
        }else{
            [self loginFirst];
        }
    }
}

- (void)payNowButtonAction:(UIButton *)sender {
    
    if (_isIAP && self.balanceCount < self.rewardCount) {
        [SVProgressHUD showInfoWithStatus:@"听币不足，请先充值"];
        [self performSelector:@selector(SVPDismiss) withObject:nil afterDelay:1.0];
    }else{
        APPDELEGATE.payType = PayTypeReward;
        if (self.balanceCount < self.rewardCount && self.aliPay.selected == NO && self.wechatPay.selected == NO){
            [SVProgressHUD showErrorWithStatus:@"请选择支付方式"];
            [self performSelector:@selector(SVPDismiss) withObject:nil afterDelay:1.0];
        }
        else{
            if (self.tCoinPay.selected) {
                [self TCoinPay];
            }
            else if (self.aliPay.selected){
                [self AliPayWithSubject:nil body:nil];
            }
            else{
                [self WechatPay];
            }
        }
    }
}

#pragma mark - Utilities

- (NSString *)generateTradeNO
{
    static int kNumber = 15;
    
    NSString *sourceStr = @"0123456789ABCDEFGHIJKLMNOPQRSTUVWXYZ";
    NSMutableString *resultStr = [[NSMutableString alloc] init];
    srand((unsigned)time(0));
    for (int i = 0; i < kNumber; i++)
    {
        unsigned index = rand() % [sourceStr length];
        NSString *oneStr = [sourceStr substringWithRange:NSMakeRange(index, 1)];
        [resultStr appendString:oneStr];
    }
    return resultStr;
}

- (void)TCoinPay{
    if (self.isPayClass) {
        //TODO:购买课堂
        
        
    }
    else{
        NSMutableDictionary *dic = [NSMutableDictionary new];
        [dic setObject:[NSString stringWithFormat:@"%.2f",self.rewardCount] forKey:@"listen_money"];
        [dic setObject:self.uid forKey:@"act_id"];
        [dic setObject:self.post_id forKey:@"post_id"];
        [dic setObject:@"1" forKey:@"type"];
        [CommonCode writeToUserD:dic andKey:REWARDINFODICTKEY];
        
        [NetWorkTool listenMoneyRechargeWithaccessToken:AvatarAccessToken listen_money:[NSString stringWithFormat:@"%.2f",self.rewardCount] act_id:self.uid post_id:self.post_id type:@"1" sccess:^(NSDictionary *responseObject) {
            NSLog(@"%@",responseObject);
            //TODO：赞赏成功
            [[NSNotificationCenter defaultCenter] postNotificationName:@"TcoinPayResultsBack" object:nil];
            [self back];
            
        } failure:^(NSError *error) {
            //
        }];
    }
}

- (void)AliPayWithSubject:(NSString *)subject body:(NSString *)body{
    
    [NetWorkTool AliPayWithaccessToken:AvatarAccessToken pay_type:@"3" act_id:self.act_id money:[NSString stringWithFormat:@"%.2f",self.rewardCount] mem_type:nil month:nil sccess:^(NSDictionary *responseObject) {
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
                //返回上一个控制器
                [self back];
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

- (void)WechatPay{
    if (![WXApi isWXAppInstalled]){
        UIAlertView *al = [[UIAlertView alloc]initWithTitle:@"提示" message:@"请安装微信" delegate:nil cancelButtonTitle:@"知道了" otherButtonTitles: nil];
        [al show];
        return;
    }
    [NetWorkTool WXPayWithaccessToken:AvatarAccessToken pay_type:@"3" act_id:self.act_id money:[NSString stringWithFormat:@"%.2f",self.rewardCount] mem_type:nil month:nil sccess:^(NSDictionary *responseObject) {
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

+ (NSString *)jumpToBizPay {
    
    //============================================================
    // V3&V4支付流程实现
    // 注意:参数配置请查看服务器端Demo
    // 更新时间：2015年11月20日
    //============================================================
    NSString *urlString   = @"http://wxpay.weixin.qq.com/pub_v2/app/app_pay.php?plat=ios";
    //解析服务端返回json数据
    NSError *error;
    //加载一个NSURL对象
    NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:urlString]];
    //将请求的url数据放到NSData对象中
    NSData *response = [NSURLConnection sendSynchronousRequest:request returningResponse:nil error:nil];
    if ( response != nil) {
        NSMutableDictionary *dict = NULL;
        //IOS5自带解析类NSJSONSerialization从response中解析出数据放到字典中
        dict = [NSJSONSerialization JSONObjectWithData:response options:NSJSONReadingMutableLeaves error:&error];
        
        NSLog(@"url:%@",urlString);
        if(dict != nil){
            NSMutableString *retcode = [dict objectForKey:@"retcode"];
            if (retcode.intValue == 0){
                NSMutableString *stamp  = [dict objectForKey:@"timestamp"];
                
                //调起微信支付
                PayReq* req             = [[PayReq alloc] init];
                req.partnerId           = [dict objectForKey:@"partnerid"];
                req.prepayId            = [dict objectForKey:@"prepayid"];
                req.nonceStr            = [dict objectForKey:@"noncestr"];
                req.timeStamp           = stamp.intValue;
                req.package             = [dict objectForKey:@"package"];
                req.sign                = [dict objectForKey:@"sign"];
                [WXApi sendReq:req];
                //日志输出
                NSLog(@"appid=%@\npartid=%@\nprepayid=%@\nnoncestr=%@\ntimestamp=%ld\npackage=%@\nsign=%@",[dict objectForKey:@"appid"],req.partnerId,req.prepayId,req.nonceStr,(long)req.timeStamp,req.package,req.sign );
                return @"";
            }else{
                return [dict objectForKey:@"retmsg"];
            }
        }else{
            return @"服务器返回错误，未获取到json对象";
        }
    }else{
        return @"服务器返回错误";
    }
}
- (void)SVPDismiss {
    [SVProgressHUD dismiss];
}

- (void)back {
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)AliPayResults:(NSNotification *)notification {
    if (self.isPayClass) {
        //
    }
    else{
        [[NSNotificationCenter defaultCenter] postNotificationName:@"PayResultsBack" object:notification.object];
        [self back];
    }
    
}

- (void)WechatPayResults:(NSNotification *)notification {
    if (self.isPayClass) {
        //
    }
    else{
        [[NSNotificationCenter defaultCenter] postNotificationName:@"WechatPayResultsBack" object:notification.object];
        [self back];
    }
   
}

- (NSString *)getCurrTime  {
    //实例化一个NSDateFormatter对象
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    //设定时间格式,这里可以设置成自己需要的格式
    [dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
    //用[NSDate date]可以获取系统当前时间
    NSString *currentDateStr = [dateFormatter stringFromDate:[NSDate date]];
    return currentDateStr;
}

- (void)alert:(NSString *)title msg:(NSString *)msg{
    UIAlertView *alter = [[UIAlertView alloc] initWithTitle:title message:msg delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
    
    [alter show];
}

- (void)loginFirst {
    
    UIAlertController *qingshuruyonghuming = [UIAlertController alertControllerWithTitle:@"温馨提示" message:@"您还没登录，请先登录后操作" preferredStyle:UIAlertControllerStyleAlert];
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

#pragma mark -UITableViewDelegate
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.row == 0){
        return 50.0 / 667 * IPHONE_H;
    }
    else if (indexPath.row == 1){
        return 10.0f / 667 * IPHONE_H;
    }
    else{
        return 50.0f / 667 * IPHONE_H;
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    switch (indexPath.row) {
        case 2:
        {
            if (self.balanceCount >= self.rewardCount){
                self.tCoinPay.selected = YES;
                self.aliPay.selected = NO;
                self.wechatPay.selected = NO;
            }
            
        }
            break;
        case 3:
        {
            self.tCoinPay.selected = NO;
            self.aliPay.selected = YES;
            self.wechatPay.selected = NO;
        }
            break;
        case 4:
        {
            self.tCoinPay.selected = NO;
            self.aliPay.selected = NO;
            self.wechatPay.selected = YES;
        }
            break;
            
        default:
            break;
    }
    
}

#pragma mark - UITableViewDataSource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    if (_isIAP) {
        return 3;
    }
    else{
        return 5;
    }
    
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    if (indexPath.row == 0){
        static NSString *wosixIdentify = @"wosixIdentify";
        UITableViewCell *cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:wosixIdentify];
        if (!cell){
            cell = [tableView dequeueReusableCellWithIdentifier:wosixIdentify];
        }
        UIImageView *img = [[UIImageView alloc]initWithFrame:CGRectMake(15.0 / 375 * IPHONE_W, 15.0 / 667 * IPHONE_H, 20.0 / 375 * IPHONE_W, 20.0 / 667 * IPHONE_H)];
        img.image = [UIImage imageNamed:@"pay1"];
        [cell.contentView addSubview:img];
        img.contentMode = UIViewContentModeScaleAspectFit;
        TTTAttributedLabel *lab = [[TTTAttributedLabel alloc]initWithFrame:CGRectMake(CGRectGetMaxX(img.frame) + 15.0 / 375 * IPHONE_W, 10.0 / 667 * IPHONE_H, 250.0 / 375 * IPHONE_W, 30.0 / 667 * IPHONE_H)];
        NSString *df = [NSString stringWithFormat:@"本次共消费%.2f听币",self.rewardCount];
        NSMutableAttributedString *attriString =[[NSMutableAttributedString alloc] initWithString:df attributes:@{NSForegroundColorAttributeName:gTextDownload,NSFontAttributeName:gFontMain14}];
        NSRange range2=[df rangeOfString:[NSString stringWithFormat:@"%.2f",self.rewardCount]];
        [attriString addAttributes:@{NSForegroundColorAttributeName:UIColorFromHex(0xf78540),NSFontAttributeName:gFontMajor17} range:range2];
        [lab addLinkToTransitInformation:nil withRange:range2];
        lab.attributedText = attriString;
        [cell.contentView addSubview:lab];
        
        UIView *bottomline = [[UIView alloc]initWithFrame:CGRectMake(0, 49.0 / 667 * IPHONE_H, SCREEN_WIDTH, 1)];
        [bottomline setBackgroundColor:gThinLineColor];
        [cell.contentView addSubview:bottomline];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        return cell;
    }
    else if (indexPath.row == 1){
        static NSString *wokongIdentify = @"subEmptyCellIdentify";
        UITableViewCell *cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:wokongIdentify];
        if (!cell){
            cell = [tableView dequeueReusableCellWithIdentifier:wokongIdentify];
        }
        cell.contentView.backgroundColor = gSubColor;
        UIView *bottomline = [[UIView alloc]initWithFrame:CGRectMake(0, 9.0 / 667 * IPHONE_H, SCREEN_WIDTH, 1)];
        [bottomline setBackgroundColor:gThinLineColor];
        [cell.contentView addSubview:bottomline];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        return cell;
    }
    else if (indexPath.row == 2){
        static NSString *wosixIdentify = @"wosixIdentify";
        UITableViewCell *cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:wosixIdentify];
        if (!cell){
            cell = [tableView dequeueReusableCellWithIdentifier:wosixIdentify];
        }
        UIImageView *img = [[UIImageView alloc]initWithFrame:CGRectMake(15.0 / 375 * IPHONE_W, 15.0 / 667 * IPHONE_H, 20.0 / 375 * IPHONE_W, 20.0 / 667 * IPHONE_H)];
        img.image = [UIImage imageNamed:@"pay2"];
        [cell.contentView addSubview:img];
        img.contentMode = UIViewContentModeScaleAspectFit;
        TTTAttributedLabel *lab = [[TTTAttributedLabel alloc]initWithFrame:CGRectMake(CGRectGetMaxX(img.frame) + 15.0 / 375 * IPHONE_W, 10.0 / 667 * IPHONE_H, 250.0 / 375 * IPHONE_W, 30.0 / 667 * IPHONE_H)];
        NSString *df = [NSString stringWithFormat:@"听币支付  (账户余额%.2f听币)",self.balanceCount];
        NSMutableAttributedString *attriString =[[NSMutableAttributedString alloc] initWithString:df attributes:@{NSForegroundColorAttributeName:gTextDownload,NSFontAttributeName:gFontMain14}];
        NSRange range2=[df rangeOfString:[NSString stringWithFormat:@"(账户余额%.2f听币)",self.balanceCount]];
        [attriString addAttribute:NSFontAttributeName value:gFontSub11 range:range2];
        [lab addLinkToTransitInformation:nil withRange:range2];
        lab.attributedText = attriString;
        [cell.contentView addSubview:lab];
        
        if (self.balanceCount >= self.rewardCount) {
            self.tCoinPay.selected = YES;
             [cell.contentView addSubview:self.tCoinPay];
        }
        else{
            self.aliPay.selected = YES;
            UIButton *recharge = [UIButton buttonWithType:UIButtonTypeCustom];
            [recharge setFrame:CGRectMake(SCREEN_WIDTH - 59, 13, 50, 25)];
            [recharge setTitle:@"去充值" forState:UIControlStateNormal];
            [recharge.layer setMasksToBounds:YES];
            [recharge.layer setCornerRadius:5.0];
            [recharge.titleLabel setFont:gFontSub11];
            [recharge setBackgroundColor:gMainColor];
            [recharge addTarget:self action:@selector(rechargeButtonAction:) forControlEvents:UIControlEventTouchUpInside];
            [cell.contentView addSubview:recharge];
        }
    
        UIView *bottomline = [[UIView alloc]initWithFrame:CGRectMake(0, 49.0 / 667 * IPHONE_H, SCREEN_WIDTH, 1)];
        [bottomline setBackgroundColor:gThinLineColor];
        [cell.contentView addSubview:bottomline];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        return cell;
    }
    else if (indexPath.row == 3){
        static NSString *wosixIdentify = @"wosixIdentify";
        UITableViewCell *cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:wosixIdentify];
        if (!cell){
            cell = [tableView dequeueReusableCellWithIdentifier:wosixIdentify];
        }
        UIImageView *img = [[UIImageView alloc]initWithFrame:CGRectMake(15.0 / 375 * IPHONE_W, 15.0 / 667 * IPHONE_H, 20.0 / 375 * IPHONE_W, 20.0 / 667 * IPHONE_H)];
        img.image = [UIImage imageNamed:@"pay3"];
        [cell.contentView addSubview:img];
        img.contentMode = UIViewContentModeScaleAspectFit;
        UILabel *lab = [[UILabel alloc]initWithFrame:CGRectMake(CGRectGetMaxX(img.frame) + 15.0 / 375 * IPHONE_W, 10.0 / 667 * IPHONE_H, 250.0 / 375 * IPHONE_W, 30.0 / 667 * IPHONE_H)];
        lab.text = @"支付宝支付";
        lab.textAlignment = NSTextAlignmentLeft;
        lab.textColor = gTextDownload;
        [cell.contentView addSubview:lab];
        lab.font = gFontMain14;
//        [self.aliPay setSelected:YES];
        [cell.contentView addSubview:self.aliPay];
        UIView *bottomline = [[UIView alloc]initWithFrame:CGRectMake(0, 49.0 / 667 * IPHONE_H, SCREEN_WIDTH, 1)];
        [bottomline setBackgroundColor:gThinLineColor];
        [cell.contentView addSubview:bottomline];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        return cell;
    }
    else{
        static NSString *wosixIdentify = @"wosixIdentify";
        UITableViewCell *cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:wosixIdentify];
        if (!cell){
            cell = [tableView dequeueReusableCellWithIdentifier:wosixIdentify];
        }
        UIImageView *img = [[UIImageView alloc]initWithFrame:CGRectMake(15.0 / 375 * IPHONE_W, 15.0 / 667 * IPHONE_H, 20.0 / 375 * IPHONE_W, 20.0 / 667 * IPHONE_H)];
        img.image = [UIImage imageNamed:@"pay4"];
        [cell.contentView addSubview:img];
        img.contentMode = UIViewContentModeScaleAspectFit;
        UILabel *lab = [[UILabel alloc]initWithFrame:CGRectMake(CGRectGetMaxX(img.frame) + 15.0 / 375 * IPHONE_W, 10.0 / 667 * IPHONE_H, 250.0 / 375 * IPHONE_W, 30.0 / 667 * IPHONE_H)];
        lab.text = @"微信支付";
        lab.textAlignment = NSTextAlignmentLeft;
        lab.textColor = gTextDownload;
        [cell.contentView addSubview:lab];
        lab.font = gFontMain14;
        cell.selectionStyle = YES;
        [cell.contentView addSubview:self.wechatPay];
        UIView *bottomline = [[UIView alloc]initWithFrame:CGRectMake(0, 49.0 / 667 * IPHONE_H, SCREEN_WIDTH, 1)];
        [bottomline setBackgroundColor:gThinLineColor];
        [cell.contentView addSubview:bottomline];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        return cell;
    }
}

@end
