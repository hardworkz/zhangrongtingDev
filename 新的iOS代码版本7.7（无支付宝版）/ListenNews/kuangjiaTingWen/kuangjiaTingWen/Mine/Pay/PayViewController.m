//
//  PayViewController.m
//  kuangjiaTingWen
//
//  Created by Zhimi on 17/2/13.
//  Copyright © 2017年 贺楠. All rights reserved.
//

#import "PayViewController.h"
#import "UIBarButtonItem+Utility.h"
#import "WBPopOverView.h"
#import "BYGraphicsView.h"
#import "UIActionSheet+MKBlockAdditions.h"
#import "AppDelegate.h"
#import "TradingRecordViewController.h"
#import "IAPHelper.h"
#import "IAPShare.h"


@interface PayViewController ()<UIPopoverPresentationControllerDelegate>

@property (strong, nonatomic) UILabel *balanceLabel;
@property (strong, nonatomic) UILabel *descpripeLabel;

@property (nonatomic, strong) NSMutableArray *buttons;
@property (nonatomic, strong) NSMutableArray *itemArr;
@property (assign, nonatomic) float rewardCount;

@property (strong, nonatomic) BYGraphicsView *tipsView;
@property (strong, nonatomic) UILabel *tips;
@property (strong, nonatomic) NSArray *zsInfo;

@property (assign, nonatomic) BOOL isIAP;

@end

@implementation PayViewController
- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    [self.navigationController setNavigationBarHidden:NO animated:YES];
}
- (void)viewDidLoad {
    [super viewDidLoad];
   
    [self setupData];
    [self setupView];
}

- (void)setupData{
    
    NSDictionary *userInfo = [CommonCode readFromUserD:@"dangqianUserInfo"];
    [self.balanceLabel setText:userInfo[@"results"][@"listen_money"]];
    
    _isIAP = YES;
    if ([CommonCode readFromUserD:@"isIAP"] == nil) {
        //是否内购
        [NetWorkTool getAppVersionSccess:^(NSDictionary *responseObject) {
            NSLog(@"%@",responseObject);
            //听闻电台
            if ([APPBUNDLEIDENTIFIER isEqualToString:@"com.popwcn.ListenNewsExploreVersion"]) {
                //当前版本号与提交审核时后台配置的一样说明正在审核
                if ([responseObject[@"results"][@"exploreVersion"] isEqualToString:APPVERSION]) {
                    [CommonCode writeToUserD:@(YES) andKey:@"isIAP"];
                    _isIAP = YES;
                }
                else{
                    _isIAP = NO;
                    [CommonCode writeToUserD:@(NO) andKey:@"isIAP"];
                }
            }
            //听闻FM
            else{
                if ([responseObject[@"results"][@"listenNews"] isEqualToString:APPVERSION]) {
                    _isIAP = YES;
                    [CommonCode writeToUserD:@(YES) andKey:@"isIAP"];
                }
                else{
                    _isIAP = NO;
                    [CommonCode writeToUserD:@(NO) andKey:@"isIAP"];
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
    
    [self.itemArr removeAllObjects];

    if (_isIAP) {
        NSDictionary *dic0 = @{@"title":@"6听币\n￥6"};
        [self.itemArr addObject:dic0];
        NSDictionary *dic1 = @{@"title":@"12听币\n￥12"};
        [self.itemArr addObject:dic1];
        NSDictionary *dic2 = @{@"title":@"30听币\n￥30"};
        [self.itemArr addObject:dic2];
        NSDictionary *dic3 = @{@"title":@"108听币\n￥108"};
        [self.itemArr addObject:dic3];
        NSDictionary *dic4 = @{@"title":@"208听币\n￥208"};
        [self.itemArr addObject:dic4];
        NSDictionary *dic5 = @{@"title":@"588听币\n￥588"};
        [self.itemArr addObject:dic5];
    }
    else{
        NSDictionary *dic0 = @{@"title":@"5听币\n￥5"};
        [self.itemArr addObject:dic0];
        NSDictionary *dic1 = @{@"title":@"10听币\n￥10"};
        [self.itemArr addObject:dic1];
        NSDictionary *dic2 = @{@"title":@"20听币\n￥20"};
        [self.itemArr addObject:dic2];
        NSDictionary *dic3 = @{@"title":@"50听币\n￥50"};
        [self.itemArr addObject:dic3];
        NSDictionary *dic4 = @{@"title":@"100听币\n￥100"};
        [self.itemArr addObject:dic4];
        NSDictionary *dic5 = @{@"title":@"500听币\n￥500"};
        [self.itemArr addObject:dic5];
    }

    
    //赠送的数量
    [NetWorkTool getZs_lisMoneySccess:^(NSDictionary *responseObject) {
        if ([responseObject[@"results"] isKindOfClass:[NSArray class]]) {
            if (_isIAP) {
                _zsInfo = nil;
            }
            else{
               _zsInfo = responseObject[@"results"];
            }
        }
        else{
            _zsInfo = nil;
        }
        
    } failure:^(NSError *error) {
        //
    }];

}

- (void)setupView{
    self.navBarBgAlpha = @"1.0";
    [self setTitle:@"听币充值"];
    [self enableAutoBack];
    self.extendedLayoutIncludesOpaqueBars = YES;
    [self.view setBackgroundColor:gSubColor];
    
    UIBarButtonItem *barItem = [UIBarButtonItem barButtonItemWithTitle:@"充值记录" font:gFontMain15 color:gTextDownload target:self selector:@selector(rightBarButton)];
    self.navigationItem.rightBarButtonItem = barItem;
    
    UISwipeGestureRecognizer *rightSwipe = [[UISwipeGestureRecognizer alloc]initWithTarget:self action:@selector(back)];
    [rightSwipe setDirection:UISwipeGestureRecognizerDirectionRight];
    [self.view addGestureRecognizer:rightSwipe];
    
    UIImageView *topBgView = [[UIImageView alloc] initWithFrame:CGRectMake(0,IS_IPHONEX?88:64, SCREEN_WIDTH, 80.0)];
    [topBgView setImage:[UIImage imageNamed:@"pay_bg"]];
    [self.view addSubview:topBgView];
    
    UILabel *titleLab = [[UILabel alloc]initWithFrame:CGRectMake((SCREEN_WIDTH - 72) / 2,15, 72, 15)];
    [titleLab setText:@"账户余额"];
    [titleLab setFont:gFontMain12];
    [titleLab setTextAlignment:NSTextAlignmentCenter];
    [titleLab setTextColor:[UIColor whiteColor]];
    [topBgView addSubview:titleLab];
    
    UIImageView *topTitleView = [[UIImageView alloc]initWithFrame:CGRectMake((SCREEN_WIDTH - 110) / 2,35, 30, 30)];
    [topTitleView setImage:[UIImage imageNamed:@"pay2"]];
    [topBgView addSubview:topTitleView];
    
    [self.balanceLabel setFrame:CGRectMake(CGRectGetMaxX(topTitleView.frame), topTitleView.frame.origin.y, 120, 30)];
    [topBgView addSubview:self.balanceLabel];
    
    UIView *tcoinBgView = [[UIView alloc]initWithFrame:CGRectMake(0, CGRectGetMaxY(topBgView.frame), SCREEN_WIDTH, 200)];
    [tcoinBgView setBackgroundColor:[UIColor whiteColor]];
    [self.view addSubview:tcoinBgView];
    
    UILabel *payCountLab = [[UILabel alloc]initWithFrame:CGRectMake(10, 5, 70, 20)];
    [payCountLab setText:@"充值金额："];
    [payCountLab setFont:gFontMain12];
    [payCountLab setTextAlignment:NSTextAlignmentCenter];
    [payCountLab setTextColor:gTextDownload];
    [tcoinBgView addSubview:payCountLab];
    
    if (self.itemArr.count) {
        //
    }
    else{
        NSDictionary *dic0 = @{@"title":@"5听币\n￥5"};
        [self.itemArr addObject:dic0];
        NSDictionary *dic1 = @{@"title":@"10听币\n￥10"};
        [self.itemArr addObject:dic1];
        NSDictionary *dic2 = @{@"title":@"20听币\n￥20"};
        [self.itemArr addObject:dic2];
        NSDictionary *dic3 = @{@"title":@"50听币\n￥50"};
        [self.itemArr addObject:dic3];
        NSDictionary *dic4 = @{@"title":@"100听币\n￥100"};
        [self.itemArr addObject:dic4];
        NSDictionary *dic5 = @{@"title":@"500听币\n￥500"};
        [self.itemArr addObject:dic5];

    }
    if ([self.buttons count]) {
        [self.buttons removeAllObjects];
    }
    for (int i = 0 ; i < 2 * 3; i ++) {
        CGFloat w = (tcoinBgView.frame.size.width - 240) / 4;
        CGFloat h = (tcoinBgView.frame.size.height - 90)/3 - 20;
        UIButton *itemImgBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        [itemImgBtn setFrame:CGRectMake(i % 3 * (w + 80) + w , i / 3 *(50 + h)+ h + 20, 80, 50)];
        [itemImgBtn setTitle:self.itemArr[i][@"title"] forState:UIControlStateNormal];
        [itemImgBtn setTitleColor:gTextDownload forState:UIControlStateNormal];
        [itemImgBtn.layer setBorderWidth:0.8];
        [itemImgBtn.layer setBorderColor:gTextRewardColor.CGColor];
        [itemImgBtn.layer setMasksToBounds:YES];
        [itemImgBtn.layer setCornerRadius:5.0];
        [itemImgBtn.titleLabel setFont:gFontSub11];
        [itemImgBtn.titleLabel setNumberOfLines:0];
        [itemImgBtn setTag:(100 + i)];
        [itemImgBtn setImage:[UIImage imageNamed:@"tcoin"] forState:UIControlStateNormal];
        [itemImgBtn addTarget:self action:@selector(selecteRewardCountAction:) forControlEvents:UIControlEventTouchUpInside];
        [self.buttons addObject:itemImgBtn];
        [tcoinBgView addSubview:itemImgBtn];
        if (i == 1) {
            [self selecteRewardCountAction:itemImgBtn];
        }
    }
    [self.view addSubview:self.tipsView];
    
    UIButton *payButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [payButton setFrame:CGRectMake(10, CGRectGetMaxY(tcoinBgView.frame) + 20, SCREEN_WIDTH - 20, 30)];
    [payButton setTitle:@"充值" forState:UIControlStateNormal];
    [payButton.layer setMasksToBounds:YES];
    [payButton.layer setCornerRadius:5.0];
    [payButton setBackgroundColor:gButtonRewardColor];
    [payButton addTarget:self action:@selector(payAction:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:payButton];
    
    UILabel *tipsLabel = [[UILabel alloc]initWithFrame:CGRectMake(10, SCREEN_HEIGHT - 100, SCREEN_WIDTH - 20, 100)];
    [tipsLabel setText:@"注意事项：\n \n1.听币与人民币充值比例为1:1\n2.充值成功后不可退款\n3.如充值遇到问题请拨打客服电话0592-5962072"];
    [tipsLabel setTextAlignment:NSTextAlignmentLeft];
    [tipsLabel setNumberOfLines:0];
    [tipsLabel setFont:gFontMain12];
    [tipsLabel setTextColor:gTextColorSub];
    [self.view addSubview:tipsLabel];
    
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(RechargeAliPayResults:) name:AliPayResultsRecharge object:nil];
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(RechargeWechatPayResults:) name:WechatPayResultsRecharge object:nil];
}

#pragma mark - NSNotification

- (void)RechargeAliPayResults:(NSNotification *)notification {

    NSDictionary *resultDic = notification.object;
    if ([resultDic[@"resultStatus"]integerValue] == 9000){
        //支付成功
        [self listenMoneyRechargeWithTpye:@"2"];
//        [self alert:@"提示信息" msg:@"支付成功"];
        
        //返回上一个控制器
//        [self back];
    }
    else if ([resultDic[@"resultStatus"]integerValue] == 8000){
        //正在处理中
         [self alert:@"提示信息" msg:@"正在处理中"];
    }
    else if ([resultDic[@"resultStatus"]integerValue] == 4000){
        //订单支付失败
         [self alert:@"提示信息" msg:@"订单支付失败"];
    }
    else if ([resultDic[@"resultStatus"]integerValue] == 6001){
        //用户中途取消
         [self alert:@"提示信息" msg:@"用户中途取消"];
    }
    else if ([resultDic[@"resultStatus"]integerValue] == 6002){
        //网络连接出错
         [self alert:@"提示信息" msg:@"网络连接出错"];
    }
    else{
         [self alert:@"提示信息" msg:@"交易失败"];
    }
}

- (void)RechargeWechatPayResults:(NSNotification *)notification {

    if ([notification.object integerValue] == 0) {
        //成功
        [self listenMoneyRechargeWithTpye:@"1"];
        //         [self alert:@"提示信息" msg:@"交易成功"];
        //返回上一个控制器
//        [self back];
    }
    else if ([notification.object integerValue] == -2){
        //取消
         [self alert:@"提示信息" msg:@"用户取消"];
    }
    else{
        //失败
         [self alert:@"提示信息" msg:@"交易失败"];
    }
//    [self back];
}

#pragma mark - UIBttonAction

- (void)payAction:(UIButton *)sender{
    
    if (_isIAP) {
        [self IAP];
    }
    else{
        [self WechatAndAliPay];
    }

}

- (void)selecteRewardCountAction:(UIButton *)sender {
    
    for ( int i = 0 ; i < self.buttons.count; i ++ ) {
        if (i == sender.tag - 100 ) {
            UIButton *allDoneButton = self.buttons[i];
            [allDoneButton.layer setBorderColor:[UIColor colorWithHue:0.04 saturation:0.88 brightness:0.99 alpha:1.00].CGColor];
            continue;
        }
        else{
            UIButton *anotherButton = self.buttons[i];
            [anotherButton.layer setBorderColor:gTextRewardColor.CGColor];
            continue;
        }
    }
    [self.tipsView setFrame:CGRectMake(sender.frame.origin.x, sender.frame.origin.y  + 120, sender.frame.size.width, 20)];
    [self.tips setFrame:CGRectMake(0, 0, sender.frame.size.width, 15)];
    [self.tipsView setViewToBottomTriangleWithWidth:10 height:5 offsetX:sender.frame.size.width / 2 - 5 backgroundImage:nil backgroundColor:[UIColor colorWithHue:0.00 saturation:0.70 brightness:0.97 alpha:1.00]];
    
    switch (sender.tag - 100) {
        case 0:{
            self.rewardCount = 5;
            if ( _zsInfo == nil || [[_zsInfo firstObject][@"zs_money"] isEqualToString:@"0"]) {
                [self.tipsView setHidden:YES];
            }
            else{
                [self.tipsView setHidden:NO];
                [self.tips setText:[NSString stringWithFormat:@"加送%@听币",[_zsInfo firstObject][@"zs_money"]]];
            }
            
        }break;
        case 1:{
            self.rewardCount = 10;
            if ( _zsInfo == nil || [_zsInfo[1][@"zs_money"] isEqualToString:@"0"]) {
                [self.tipsView setHidden:YES];
            }
            else{
                [self.tipsView setHidden:NO];
                [self.tips setText:[NSString stringWithFormat:@"加送%@听币",_zsInfo[1][@"zs_money"]]];
            }
        }break;
        case 2:{
            self.rewardCount = 20;
            if ( _zsInfo == nil || [_zsInfo[2][@"zs_money"] isEqualToString:@"0"]) {
                [self.tipsView setHidden:YES];
            }
            else{
                [self.tipsView setHidden:NO];
                [self.tips setText:[NSString stringWithFormat:@"加送%@听币",_zsInfo[2][@"zs_money"]]];
            }
        }break;
        case 3:{
            self.rewardCount = 50;
            if ( _zsInfo == nil || [_zsInfo[3][@"zs_money"] isEqualToString:@"0"]) {
                [self.tipsView setHidden:YES];
            }
            else{
                [self.tipsView setHidden:NO];
                [self.tips setText:[NSString stringWithFormat:@"加送%@听币",_zsInfo[3][@"zs_money"]]];
            }
        }break;
        case 4:{
            self.rewardCount = 100;
            if ( _zsInfo == nil || [_zsInfo[4][@"zs_money"] isEqualToString:@"0"]) {
                [self.tipsView setHidden:YES];
            }
            else{
                [self.tipsView setHidden:NO];
                [self.tips setText:[NSString stringWithFormat:@"加送%@听币",_zsInfo[4][@"zs_money"]]];
            }
        }break;
        case 5:{
            self.rewardCount = 500;
            if ( _zsInfo == nil || [_zsInfo[5][@"zs_money"] isEqualToString:@"0"]) {
                [self.tipsView setHidden:YES];
            }
            else{
                [self.tipsView setHidden:NO];
                [self.tips setText:[NSString stringWithFormat:@"加送%@听币",_zsInfo[5][@"zs_money"]]];
            }
        }break;
        default:break;
    }
}

- (void)rightBarButton{
    
    [self.navigationController pushViewController:[TradingRecordViewController new] animated:YES];
}

- (void)back{
    [self.navigationController popViewControllerAnimated:YES];
}

#pragma mark - Utilities

- (void)WechatAndAliPay{
    APPDELEGATE.payType = PayTypeRecharge;
    [UIActionSheet actionSheetWithTitle:nil message:nil buttons:@[@"微信支付", @"支付宝支付"] showInView:self.view onDismiss:^(int buttonIndex) {
        if (buttonIndex == 0) {
            [self WechatPay];
        }
        else{
//            [self AliPay];
        }
    } onCancel:^{
        
    }];
}



- (void)IAP{
    
    if(![IAPShare sharedHelper].iap) {
        // 我这里是6个内购的商品
        NSSet* dataSet;
        //听闻电台
        if ([APPBUNDLEIDENTIFIER isEqualToString:@"com.popwcn.ListenNewsExploreVersion"]){
           dataSet = [[NSSet alloc] initWithObjects:@"6TCoins",@"12TCoins",@"30TCoins",@"108TCoins",@"208Tcoins",@"588TCoins", nil];
        }
        else{
            dataSet = [[NSSet alloc] initWithObjects:@"6tCoins",@"12tCoins",@"30tCoins",@"108tCoins",@"208tCoins",@"588tCoins", nil];
        }
        
        [IAPShare sharedHelper].iap = [[IAPHelper alloc] initWithProductIdentifiers:dataSet];
    }
    //TODO:IAP yes为生产环境  no为沙盒测试模式
    // 客户端做收据校验有用  服务器做收据校验忽略...
    [IAPShare sharedHelper].iap.production = YES;
    // 请求商品信息
    [[IAPShare sharedHelper].iap requestProductsWithCompletion:^(SKProductsRequest* request,SKProductsResponse* response)
     {
         if(response > 0 ) {

             NSUInteger index = 0;
             if (self.rewardCount == 5.00) {
                 index = 5;
             }
             else if (self.rewardCount == 10.00){
                 index = 1;
             }
             else if (self.rewardCount == 20.00){
                 index = 3;
             }
             else if (self.rewardCount == 50.00){
                 index = 0;
             }
             else if (self.rewardCount == 100.00){
                 index = 2;
             }
             else if (self.rewardCount == 500.00){
                 index = 4;
             }
             SKProduct* product =[[IAPShare sharedHelper].iap.products objectAtIndex:index];
             
             NSLog(@"Price: %@",[[IAPShare sharedHelper].iap getLocalePrice:product]);
             NSLog(@"Title: %@",product.localizedTitle);
             
             [[IAPShare sharedHelper].iap buyProduct:product
                                        onCompletion:^(SKPaymentTransaction* trans){
                                            
                                            if(trans.error)
                                            {
                                                NSLog(@"Fail %@",[trans.error localizedDescription]);
                                                //失败：
                                                XWAlerLoginView *xw = [[XWAlerLoginView alloc]initWithTitle:[trans.error localizedDescription]];
                                                [xw show];
                                            }
                                            else if(trans.transactionState == SKPaymentTransactionStatePurchased) {
                                                
                                                [[IAPShare sharedHelper].iap checkReceipt:[NSData dataWithContentsOfURL:[[NSBundle mainBundle] appStoreReceiptURL]] AndSharedSecret:@"2c3f92ac3ba3421eaa58ab79c908c687" onCompletion:^(NSString *response, NSError *error) {
                                                    
                                                    //Convert JSON String to NSDictionary
                                                    NSDictionary* rec = [IAPShare toJSON:response];
                                                    
                                                    if([rec[@"status"] integerValue]==0)
                                                    {
                                                        
                                                        [[IAPShare sharedHelper].iap provideContentWithTransaction:trans];
                                                        NSLog(@"SUCCESS %@",response);
                                                        NSLog(@"Pruchases %@",[IAPShare sharedHelper].iap.purchasedProducts);
                                                        //成功：
                                                        XWAlerLoginView *xw = [[XWAlerLoginView alloc]initWithTitle:@"充值成功"];
                                                        [xw show];
                                                        [self listenMoneyRechargeWithTpye:@"3"];
                                                        
                                                    }
                                                    else {
                                                        NSLog(@"Fail");
                                                        //失败：
                                                        XWAlerLoginView *xw = [[XWAlerLoginView alloc]initWithTitle:@"充值失败，请重试"];
                                                        [xw show];
                                                        
                                                    }
                                                }];
                                            }
                                            else if(trans.transactionState == SKPaymentTransactionStateFailed) {
                                                NSLog(@"Fail");
                                                XWAlerLoginView *xw = [[XWAlerLoginView alloc]initWithTitle:@"充值失败，请重试"];
                                                [xw show];
                                            }
                                        }];//end of buy product
         }
     }];
}

- (void)listenMoneyRechargeWithTpye:(NSString *)type{
    if (_isIAP) {
        //
        NSString *listenMoney;
        if (self.rewardCount == 5.00) {
            listenMoney = @"6.00";
        }
        else if (self.rewardCount == 10.00){
            listenMoney = @"12.00";
        }
        else if (self.rewardCount == 20.00){
            listenMoney = @"30.00";
        }
        else if (self.rewardCount == 50.00){
            listenMoney = @"108.00";
        }
        else if (self.rewardCount == 100.00){
            listenMoney = @"208.00";
        }
        else if (self.rewardCount == 500.00){
            listenMoney = @"588.00";
        }
        [NetWorkTool listenMoneyRechargeWithaccessToken:AvatarAccessToken listen_money:listenMoney type:type sccess:^(NSDictionary *responseObject) {
            NSLog(@"%@",responseObject);
            if ([responseObject[@"status"] integerValue] == 1) {
                //充值成功 --》 获取用户信息
                [[NSNotificationCenter defaultCenter] postNotificationName:@"updateUserInfo" object:nil];
            }
        } failure:^(NSError *error) {
            //
        }];
    }
    else{
        [NetWorkTool listenMoneyRechargeWithaccessToken:AvatarAccessToken listen_money:[NSString stringWithFormat:@"%.2f",self.rewardCount] type:type sccess:^(NSDictionary *responseObject) {
            NSLog(@"%@",responseObject);
            if ([responseObject[@"status"] integerValue] == 1) {
                //充值成功 --》 获取用户信息
                [[NSNotificationCenter defaultCenter] postNotificationName:@"updateUserInfo" object:nil];
            }
        } failure:^(NSError *error) {
            //
        }];
    }
    
}

- (NSString *)generateTradeNO{
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

//- (void)AliPay{
//    [NetWorkTool AliPayWithaccessToken:AvatarAccessToken pay_type:@"4" act_id:nil money:[NSString stringWithFormat:@"%.2f",self.rewardCount] mem_type:nil month:nil sccess:^(NSDictionary *responseObject) {
//        if ([responseObject[status] intValue] == 1) {
//            // NOTE: 调用支付结果开始支付
//            [[AlipaySDK defaultService] payOrder:responseObject[results][@"response"] fromScheme:appScheme callback:^(NSDictionary *resultDic) {
//                switch (APPDELEGATE.payType) {
//                    case PayTypeClassPay:
//                        [[NSNotificationCenter defaultCenter] postNotificationName:AliPayResultsClass object:resultDic];
//                        break;
//                    case PayTypeReward:
//                        [[NSNotificationCenter defaultCenter] postNotificationName:AliPayResultsReward object:resultDic];
//                        break;
//                    case PayTypeRecharge:
//                        [[NSNotificationCenter defaultCenter] postNotificationName:AliPayResultsRecharge object:resultDic];
//                        break;
//                    case PayTypeMembers:
//                        [[NSNotificationCenter defaultCenter] postNotificationName:AliPayResultsMembers object:resultDic];
//                        break;
//
//                    default:
//                        break;
//                }
//                //返回上一个控制器
//                [self back];
//            }];
//
//        }else{
//            XWAlerLoginView *alert = [[XWAlerLoginView alloc] initWithTitle:responseObject[msg]];
//            [alert show];
//        }
//    } failure:^(NSError *error) {
//        XWAlerLoginView *alert = [[XWAlerLoginView alloc] initWithTitle:@"网络错误"];
//        [alert show];
//    }];
//}

- (void)WechatPay{
    if (![WXApi isWXAppInstalled]){
        UIAlertView *al = [[UIAlertView alloc]initWithTitle:@"提示" message:@"请安装微信" delegate:nil cancelButtonTitle:@"知道了" otherButtonTitles: nil];
        [al show];
        return;
    }
    [NetWorkTool WXPayWithaccessToken:AvatarAccessToken pay_type:@"4" act_id:nil money:[NSString stringWithFormat:@"%.2f",self.rewardCount] mem_type:nil month:nil sccess:^(NSDictionary *responseObject) {
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

- (void)alert:(NSString *)title msg:(NSString *)msg{
    UIAlertView *alter = [[UIAlertView alloc] initWithTitle:title message:msg delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
    
    [alter show];
}

#pragma mark  - setter

- (UILabel *)balanceLabel{
    if (!_balanceLabel) {
        _balanceLabel = [[UILabel alloc]initWithFrame:CGRectMake(0, 30, SCREEN_WIDTH, 30)];
        [_balanceLabel setFont:gFontSelected34];
        [_balanceLabel setTextAlignment:NSTextAlignmentLeft];
        [_balanceLabel setTextColor:[UIColor whiteColor]];
        [_balanceLabel setTextAlignment:NSTextAlignmentCenter];
    }
    return _balanceLabel;
}

- (UILabel *)tips{
    if (!_tips) {
        _tips = [[UILabel alloc]init];
        [_tips setBackgroundColor:[UIColor colorWithHue:0.00 saturation:0.70 brightness:0.97 alpha:1.00]];
        [_tips setFrame:CGRectMake(0, 0, 100, 15)];
        [_tips setFont:gFontMain12];
        [_tips setTextColor:[UIColor whiteColor]];
        [_tips setTextAlignment:NSTextAlignmentCenter];
    }
    return _tips;
}

- (BYGraphicsView *)tipsView{
    if (!_tipsView) {
        _tipsView = [[BYGraphicsView alloc] initWithFrame:CGRectMake(20, 64, 260, 300)];
        [_tipsView setBackgroundColor:[UIColor whiteColor]];
        [_tipsView setViewToBottomTriangleWithWidth:20 height:10 offsetX:260/2 - 20/2 backgroundImage:nil backgroundColor:[UIColor colorWithHue:0.00 saturation:0.70 brightness:0.97 alpha:1.00]];
        [_tipsView addSubview:self.tips];
    }
    return _tipsView;
}

- (NSMutableArray *)buttons{
    if (!_buttons)
    {
        _buttons = [NSMutableArray array];
    }
    return _buttons;
}

- (NSMutableArray *)itemArr{
    if (!_itemArr) {
        _itemArr = [NSMutableArray array];
    }
    return _itemArr;
}

@end
