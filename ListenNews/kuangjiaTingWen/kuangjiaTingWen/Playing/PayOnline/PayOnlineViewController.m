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
    // Do any additional setup after loading the view.
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
    
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(AliPayResults:) name:@"AliPayResults" object:nil];
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(WechatPayResults:) name:@"WechatPayResults" object:nil];
    
    
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
        [self loginFirst];
    }
}

- (void)payNowButtonAction:(UIButton *)sender {
    
    if (_isIAP && self.balanceCount < self.rewardCount) {
        [SVProgressHUD showInfoWithStatus:@"听币不足，请先充值"];
        [self performSelector:@selector(SVPDismiss) withObject:nil afterDelay:1.0];
    }else{
        APPDELEGATE.isReward = YES;
        if (self.balanceCount < self.rewardCount && self.aliPay.selected == NO && self.wechatPay.selected == NO){
            [SVProgressHUD showErrorWithStatus:@"请选择支付方式"];
            [self performSelector:@selector(SVPDismiss) withObject:nil afterDelay:1.0];
        }
        else{
            if (self.tCoinPay.selected) {
                [self TCoinPay];
            }
            else if (self.aliPay.selected){
                [self AliPay];
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

- (void)AliPay{
    
    NSMutableDictionary *dic = [NSMutableDictionary new];
    [dic setObject:[NSString stringWithFormat:@"%.2f",self.rewardCount] forKey:@"listen_money"];
    [dic setObject:self.uid forKey:@"act_id"];
    [dic setObject:self.post_id forKey:@"post_id"];
    [dic setObject:@"2" forKey:@"type"];
    [CommonCode writeToUserD:dic andKey:REWARDINFODICTKEY];
    
    //重要说明
    //这里只是为了方便直接向商户展示支付宝的整个支付流程；所以Demo中加签过程直接放在客户端完成；
    //真实App里，privateKey等数据严禁放在客户端，加签过程务必要放在服务端完成；
    //防止商户私密数据泄露，造成不必要的资金损失，及面临各种安全风险；
    
    //需要填写商户app申请的
    NSString *appID;
    //听闻电台
    if ([APPBUNDLEIDENTIFIER isEqualToString:@"com.popwcn.ListenNewsExploreVersion"]){
        appID = @"2017010904944479";
    }
    //FM
    else{
        appID = @"2017010904942523";
    }
    
    // 如下私钥，rsa2PrivateKey 或者 rsaPrivateKey 只需要填入一个
    // 如果商户两个都设置了，优先使用 rsa2PrivateKey
    // rsa2PrivateKey 可以保证商户交易在更加安全的环境下进行，建议使用 rsa2PrivateKey
    // 获取 rsa2PrivateKey，建议使用支付宝提供的公私钥生成工具生成，
    // 工具地址：https://doc.open.alipay.com/docs/doc.htm?treeId=291&articleId=106097&docType=1
    NSString *rsaPrivateKey = @"tingwenapp@163.com";
    
    NSString *rsa2PrivateKey;
    //听闻电台
    if ([APPBUNDLEIDENTIFIER isEqualToString:@"com.popwcn.ListenNewsExploreVersion"]){
        rsa2PrivateKey = @"MIIEowIBAAKCAQEAsGRGCpQZ5TCYryINQe+UraneSTF9oCOEQ0QqmqJ70pALy3mGxDLywbty7dJiwFYo95AbhWzJSDzNUD8IjDZpJVm/LftXfm/Vssgj3rmie2xt2YDz0ixvJhiXEsU36z7X2WpI74wl+yt9HgWOBisqKzEfVSU70Nfd/6CS/pJScXWN2rvhFNpGcXwpu+GabbbnQttwjHEX3k5JydYxYNK0cX5wdlH9LGFKD1wbRfnNIk0DWyrjL8IHWxPzrVK/f//sUuVhwoJYo0dgJQVTUJpldE7dJwuyZt4GiqHST7d1mFJQIzivkj1DcMwlGDzNrqbmBpCGjMkAS1dRnlcT1DCO9QIDAQABAoIBAQCq7vElDTIu9LHxfWkljVsiE6wyd8BKsEBawzMaGP0vJqIXc1QSy2CONu1/49IImzYl+cOBv9Mqqqk3622IGq44IMlwcNHv18ZZ8zM3geMgAgpNrXYaJS8s1sWHzhCLaqHXsfSuFr0zsogT0MQ53BiINJktdOCLWLVsJBpukjNMeEcxepHAYo61SisVKCXLegfEKlYvgz5u7fBfy+iTgWkern5sZV/INyCXltfCrXLyMGGCuxrOOSjnM4cOyCqyQ9CRp9mnH1Zb/OFF5vJPgMkindHqWHsbvnLfoCpUem3kcWVg+tk7DiE09zF1ssQH9XLzUy7ZS1sNg/1BQHYIxwxdAoGBAN+7ZT6OVCr0fT/oviwALf66YqFomOlo31DFqc3PMMnEhbPHMqEyrs6/4ky0INKFIH/Jgi4a5WnWrHRiGT8dfJXIgP6unLxuv2XXn31xGJ11VMqx1Txi9J8OlBAp13028ikMqGiLI2uTCVOz4f0jgE96Ftn6VM60Qavd2Hvn//3/AoGBAMnU/CTJ/gLJkVTItqg0YpLBFPEKa3B/JYIFO33GulZp8myYFSHRoEp4CIEX3vZd6D5OHk6y3sFVpNGTa+4zm21ySh/SZPkuYxb2jPZ4J1Y4tkMBcm9vl3P66zvTrmeMvTciPHlC8lbP0QFMzA992MR1NVAd60UVkRZf/9TxGVsLAoGAciUNdmjvECtEa4K244QD813sTCUtPog+xtrR0yrN3WLiQ+JxNkTBYsILFs8fn8hD2G5aeGNIgEMCIS6batQEZ/avuUAkvw5RoAfuWvWEdXETHYa1H+Xsn+m0KLrwMfYCfmby1MOIAq41p/qyZY/jOqkzV2qcMglNJ/47IJwwwskCgYBKZHK7rKgvptQmiASrYwOiTADIB6sqP/M3RW50Ibe0+kAcvsGrQXTvfebEjmPkMyDTNj/9ifiJEmQ5yzjRB7yWTrX7nLUTE4H6iM3UWt1E7opfkDz5zgvo9+eUmaWDDWEA3WGk4IQqc1b6P7BHVX98iicobJ63TAe6U5AckPFjmQKBgDr/lv0Xby7c1GsxrJ9CKaHOao+xunGeLn3ZejpfvTihYMKfrQKFUfspbSYq+49+8RNstLbiqdb4H49VjB8gD11FIJwjxcdOd5dstGYsn760Ts7cflukWY3lZM7N+V9jFyHGpq9uZZZqFiPd5sHZbZU5tXtzDBZFtPdIvlKEI3Il";
    }
    //FM
    else{
        rsa2PrivateKey = @"MIIEpAIBAAKCAQEAweGk+FTCAJLcvPKcMEf0fJEO6UpjJfUM1RwKNJ1Q2E9cbGAmgSoJyLOV4ciro7KGrAFMCWZXXEa9pOye4xF1J+mrK4HccEt7LuGN60oXNpq5dtwLf3s9oGptnCWzlAkGzL5Db/bVEJeiOI3DkUBThqBMiv6Z15NeUXHsyso9wg/rUL/8JXkVp21e/JchSX3sCW0EUtJUhDHA/+uXAC7emGd7arWAEULIKIY0xqHaV/Ci/78PU4V/zcZZ8QPzerE8EG4iEcqNw7Xudy3b+ECDYRMDAUFcGm9m4AL+zbNWHKk8HiNAhlbNnBW5Ngsj+oO//WtBYxaMA2EBsvxKicPATwIDAQABAoIBAHN5KiFBkf53egMLWF0lLgdW+hOWW3EK/2aZ+bYWkEUVF03xAl3hpMwlsbo1I40u0ij16MycaKGr/F2TFJrXFfj8ohcalClJu4dTjYw6p5K9GoMhUbPOugil+ryKc+dSbPtawp2X3JSyS0r1nCoRru264XvTYdtUiVNm0AqD476FZRKJfVyfLLxi8zzEiJc3LwJGMByN5gupqtSpv0dstIZAO3J2PQuJ5rWWg1J9NBP0meG2s2VGv1ahV2PKU5I8vJT/2FR7EmBX4eaj5oLalm27KrR3AtEE0aDnYa6jJufu2dWQCoIX8sN9iSKKVP0jkrnvjOzpIkxEJs7D656y4TECgYEA6Qet+/dL4MJFykibo6JdYsSCIiKK6zfhc4HBkpGkg2TWkCEzW6t7UkEWrjjVJuSCDaqFIXNbLCUBbUS/Nq9PkoQY21C20YV7Pim7xZG82IEJWYy7gbWbuvRDY4ZXhnZfY3v4mTuhA01si1YOyuYz1VIsUJmywvQ2PZwFF4mCApcCgYEA1P4VK01Yiw7G+dFwN7Uf4P5QOveDvVDoE9dKg+whWqn2co2AwUeVe5ZMX1IUnkxsfgI1+vDAQFQnI4IURiIn2zzNIbxQHULTOdT6vZKxLOjUL+vJE5CHZC9tFT9++yiQBjZzI12b3y4l7OLAGP4dRbzXNHESaXxCUuVskY01vwkCgYEAh7mEWXwowqkEcxQlKoKX973SucT6upOaiWcq8o5Hjov9+IaN3jebpUXpyuGpLHTtVr5ZuijxEl4fXaAr6tLi+shbnel+AbzIEmXGSwVeQ4+sfW7di2fWY2Z/lYkak2OAnXYITl+PoVfH/8PI6952lCm/S9apaqlIqkukH5hkk9MCgYEAigXA6BeuKibAUEElbCQmbWG/0gZ1S2gzjC/2bLjHAH6lYqRJ7HYb60OBaD/DdrVllN6P5na+zrD5z+vKgYw+sbab46GpdNzKDm7ysYhu4gBbCFbOLax54DVPhfZorg8iDbSZNjDCAoVgNDrYaxm5FGkEOEqRuOO6AwgDK+sLCikCgYBXw1g4m+ixLoUmOvaWFBTCpHsTwOIm6NyZMjQcoM/U6ybKk9pQKUQ9flfFzDiESu42sp2ZvOlqAexo9BwDfg03kgNNq016Qh/UX5wVtnn6ME50c5/TRmePyp++4i4h6kla0hb00fcF4dHYAX865UJ9FZ5Eih8TEQ470S18Cr6+BA==";
    }
    
    //partner和seller获取失败,提示
    if ([appID length] == 0 ||
        ([rsa2PrivateKey length] == 0 && [rsaPrivateKey length] == 0))
    {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"提示"
                                                        message:@"缺少appId或者私钥。"
                                                       delegate:self
                                              cancelButtonTitle:@"确定"
                                              otherButtonTitles:nil];
        [alert show];
        return;
    }
    
    /*
     *生成订单信息及签名
     */
    //将商品信息赋予AlixPayOrder的成员变量
    Order* order = [Order new];
    
    // NOTE: app_id设置
    order.app_id = appID;
    
    // NOTE: 支付接口名称
    order.method = @"alipay.trade.app.pay";
    
    // NOTE: 参数编码格式
    order.charset = @"utf-8";
    
    // NOTE: 当前时间点
    NSDateFormatter* formatter = [NSDateFormatter new];
    [formatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
    order.timestamp = [formatter stringFromDate:[NSDate date]];
    
    // NOTE: 支付版本
    order.version = @"1.0";
    
    // NOTE: (非必填项)支付宝服务器主动通知商户服务器里指定的页面http路径
    order.notify_url = @"http://admin.tingwen.me/index.php/api/Alipay/notifyurl";
    
    // NOTE: sign_type 根据商户设置的私钥来决定
    order.sign_type = (rsa2PrivateKey.length > 1)?@"RSA2":@"RSA";
    
    // NOTE: 商品数据
    order.biz_content = [BizContent new];
    order.biz_content.body = @"0.0";
    order.biz_content.subject = @"听闻打赏";
    order.biz_content.out_trade_no = [self generateTradeNO]; //订单ID（由商家自行制定）
    order.biz_content.timeout_express = @"30m"; //超时时间设置
    order.biz_content.total_amount = [NSString stringWithFormat:@"%.2f", self.rewardCount]; //商品价格
    
    //将商品信息拼接成字符串
    NSString *orderInfo = [order orderInfoEncoded:NO];
    NSString *orderInfoEncoded = [order orderInfoEncoded:YES];
    // NOTE: 获取私钥并将商户信息签名，外部商户的加签过程请务必放在服务端，防止公私钥数据泄露；
    //       需要遵循RSA签名规范，并将签名字符串base64编码和UrlEncode
    NSString *signedString = nil;
    RSADataSigner* signer = [[RSADataSigner alloc] initWithPrivateKey:((rsa2PrivateKey.length > 1)?rsa2PrivateKey:rsaPrivateKey)];
    if ((rsa2PrivateKey.length > 1)) {
        signedString = [signer signString:orderInfo withRSA2:YES];
    } else {
        signedString = [signer signString:orderInfo withRSA2:NO];
    }
    
    // NOTE: 如果加签成功，则继续执行支付
    if (signedString != nil) {
        //应用注册scheme,在AliSDKDemo-Info.plist定义URL types
        NSString *appScheme = @"zhiFuBzo";
        
        // NOTE: 将签名成功字符串格式化为订单字符串,请严格按照该格式
        NSString *orderString = [NSString stringWithFormat:@"%@&sign=%@",
                                 orderInfoEncoded, signedString];
        
        // NOTE: 调用支付结果开始支付
        [[AlipaySDK defaultService] payOrder:orderString fromScheme:appScheme callback:^(NSDictionary *resultDic) {
            
            [[NSNotificationCenter defaultCenter] postNotificationName:@"PayResultsBack" object:resultDic];
            [self back];
            
        }];
    }
    
}

- (void)WechatPay{
    if (![WXApi isWXAppInstalled]){
        UIAlertView *al = [[UIAlertView alloc]initWithTitle:@"提示" message:@"请安装微信" delegate:nil cancelButtonTitle:@"知道了" otherButtonTitles: nil];
        [al show];
        return;
    }
    NSMutableDictionary *dic = [NSMutableDictionary new];
    [dic setObject:[NSString stringWithFormat:@"%.2f",self.rewardCount] forKey:@"listen_money"];
    [dic setObject:self.uid forKey:@"act_id"];
    [dic setObject:self.post_id forKey:@"post_id"];
    [dic setObject:@"2" forKey:@"type"];
    [CommonCode writeToUserD:dic andKey:REWARDINFODICTKEY];
    //注册微信
    [WXApi registerApp:kAppId_WeiXin];

    [NetWorkTool netwokingPostZhiFu:@"http://admin.tingwen.me/weixin/example/app.php" andParameters:@{@"total_fees" : @(self.rewardCount * 100)} success:^(id obj) {
        
        //微信
        //创建支付签名对象
//        payRequsestHandler *req = [payRequsestHandler alloc];
//        
//        //初始化支付签名对象
//        [req init:APP_ID mch_id:MCH_ID];
//        //            设置密钥
//        [req setKey:PARTNER_ID];
        //获取到实际调起微信支付的参数后，在app端调起支付
        //            DingDanObj *ticketNum = [DingDanObj new];
        //            ticketNum.orderPrice = _money;
        //            ticketNum.orderNum = obj[@"prepayid"];
        //            NSMutableDictionary *dict = [req sendPay_demo:ticketNum];
        if(obj == nil){
            //错误提示
            //            NSString *debug = [req getDebugifo];
            [self alert:@"提示信息" msg:@"交易失败"];
        }else{
            NSMutableString *stamp  = [obj objectForKey:@"timestamp"];
            //调起微信支付
            PayReq *req             = [[PayReq alloc] init];
            req.openID              = [obj objectForKey:@"appid"];
            req.partnerId           = [obj objectForKey:@"partnerid"];
            req.prepayId            = [obj objectForKey:@"prepayid"];
            req.nonceStr            = [obj objectForKey:@"noncestr"];
            req.timeStamp           = stamp.intValue;
            req.package             = [obj objectForKey:@"package"];
            req.sign                = [obj objectForKey:@"sign"];
//            TheThirdPartyManager *manager = [TheThirdPartyManager singleWeiBoManager];
//            manager.statue = XWTingWenWeiXinStatuePay;
//            manager.uid = _zhuBo.i_id;
//            //            manager.trade_id =
//            manager.total_fees = _money;
            [WXApi sendReq:req];
        }
    } failure:^{
        [self alert:@"提示信息" msg:@"交易失败"];
    }];
//            //微信
//            //创建支付签名对象
//            payRequsestHandler *req = [payRequsestHandler alloc];
//    
//            //初始化支付签名对象
//            [req init:APP_ID mch_id:MCH_ID];
//    
//            //设置密钥
//            [req setKey:PARTNER_ID];
//            //获取到实际调起微信支付的参数后，在app端调起支付
//            DingDanObj *ticketNum = [DingDanObj new];
//    
//            ticketNum.orderPrice = _money;
//    
//            NSMutableDictionary *dict = [req sendPay_demo:ticketNum];
//            if(dict == nil){
//                //错误提示
//                //            NSString *debug = [req getDebugifo];
//    
//                [self alert:@"提示信息" msg:@"交易失败"];
//    
//            }else{
//    
//    
//                NSMutableString *stamp  = [dict objectForKey:@"timestamp"];
//    
//                //调起微信支付
//                PayReq *req             = [[PayReq alloc] init];
//                req.openID              = [dict objectForKey:@"appid"];
//                req.partnerId           = [dict objectForKey:@"partnerid"];
//                req.prepayId            = [dict objectForKey:@"prepayid"];
//                req.nonceStr            = [dict objectForKey:@"noncestr"];
//                req.timeStamp           = stamp.intValue;
//                req.package             = [dict objectForKey:@"package"];
//                req.sign                = [dict objectForKey:@"sign"];
//    
//                [WXApi sendReq:req];
//            }
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
