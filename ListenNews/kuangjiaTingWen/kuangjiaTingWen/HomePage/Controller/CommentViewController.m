//
//  CommentViewController.m
//  kuangjiaTingWen
//
//  Created by Zhimi on 17/4/18.
//  Copyright © 2017年 zhimi. All rights reserved.
//

#import "CommentViewController.h"
#import "UIActionSheet+MKBlockAdditions.h"
#import "LoginVC.h"
#import "LoginNavC.h"
#import "gerenzhuyeVC.h"

@interface CommentViewController ()<UITableViewDelegate,UITableViewDataSource,UITextFieldDelegate,TTTAttributedLabelDelegate>
{
    UILabel *PingLundianzanNumLab;
}


@property (strong,nonatomic) UITableView *commentTableView;
@property (strong,nonatomic) NSMutableArray *commentInfoArr;
@property (assign, nonatomic) NSInteger commentIndex;
@property (assign, nonatomic) NSInteger commentPageSize;

@property (strong, nonatomic) UIView *toolBarView;
@property (strong, nonatomic) UITextField *commentTextField;
@property (strong, nonatomic) UIButton *sentCommentButton;
@property (strong, nonatomic) NSString *commentTextStr;
@property (assign, nonatomic) BOOL isReplyComment;
@property (strong, nonatomic) NSString *replyTouid;
@property (strong, nonatomic) NSString *replyCommentid;

@end

@implementation CommentViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setUpData];
    [self setUpView];
}

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    [self.navigationController.navigationBar setHidden:YES];
//    IQKeyboardManager *manager = [IQKeyboardManager sharedManager];
//    manager.enable = YES;
//    manager.shouldResignOnTouchOutside = YES;
//    manager.shouldToolbarUsesTextFieldTintColor = NO;
//    manager.enableAutoToolbar = NO;
}

- (void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
//    [self.commentTextField resignFirstResponder];
}

- (void)setUpData{
    self.commentIndex = 1;
    self.commentPageSize = 15;
    _isReplyComment = NO;
    _commentInfoArr = [NSMutableArray new];
    [self loadData];
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
    topLab.text = @"评价";
    topLab.backgroundColor = [UIColor clearColor];
    topLab.textAlignment = NSTextAlignmentCenter;
    [topView addSubview:topLab];
    UIView *seperatorLine = [[UIView alloc]initWithFrame:CGRectMake(0, 63.5, SCREEN_WIDTH, 0.5)];
    [seperatorLine setBackgroundColor:[UIColor lightGrayColor]];
    [topView addSubview:seperatorLine];
    [self.view addSubview:self.commentTableView];
    UISwipeGestureRecognizer *rightSwipe = [[UISwipeGestureRecognizer alloc]initWithTarget:self action:@selector(back)];
    [rightSwipe setDirection:UISwipeGestureRecognizerDirectionRight];
    [self.commentTableView addGestureRecognizer:rightSwipe];
//    [self.view addSubview:self.toolBarView];
    self.commentTextStr = @"";
    DefineWeakSelf;
    self.commentTableView.mj_header = [MJRefreshNormalHeader headerWithRefreshingBlock:^{
        weakSelf.commentIndex = 1;
        [weakSelf loadData];
    }];
    self.commentTableView.mj_footer = [MJRefreshAutoNormalFooter footerWithRefreshingBlock:^{
        weakSelf.commentIndex ++;
        [weakSelf loadData];
    }];
}

- (UITableView *)commentTableView{
    if (!_commentTableView){
        _commentTableView = [[UITableView alloc]initWithFrame:CGRectMake(0, 64, SCREEN_WIDTH, SCREEN_HEIGHT - 64) style:UITableViewStylePlain];
//        [_commentTableView setSeparatorStyle:UITableViewCellSeparatorStyleNone];
        _commentTableView.delegate = self;
        _commentTableView.dataSource = self;
        _commentTableView.tableFooterView = [UIView new];
    }
    return _commentTableView;
}

- (UIView *)toolBarView {
    if (!_toolBarView) {
        _toolBarView = [[UIView alloc]initWithFrame:CGRectMake(0, SCREEN_HEIGHT - 46, SCREEN_WIDTH, 46)];
        [_toolBarView setBackgroundColor:[UIColor colorWithRed:0.98 green:0.98 blue:0.98 alpha:1.00]];
        [_toolBarView setUserInteractionEnabled:YES];
        UIView *toplineView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, 1)];
        [toplineView setBackgroundColor:gThickLineColor];
        [_toolBarView addSubview:toplineView];
        [_toolBarView addSubview:self.commentTextField];
        [_toolBarView addSubview:self.sentCommentButton];
    }
    return _toolBarView;
}


- (UITextField *)commentTextField {
    if (!_commentTextField ) {
        _commentTextField = [[UITextField alloc]initWithFrame:CGRectMake(10, 5, SCREEN_WIDTH - 70, 35)];
        _commentTextField.layer.borderWidth = 1;
        _commentTextField.layer.borderColor = UIColor.grayColor.CGColor;
        _commentTextField.layer.cornerRadius = 5;
        _commentTextField.layer.masksToBounds = YES;
        _commentTextField.placeholder = @"输入评论";
        _commentTextField.delegate = self;
        // [_commentTextField setFont:[UIFont systemFontOfSize:17]];
        [_commentTextField setReturnKeyType:UIReturnKeyDone];
        [_commentTextField setAdjustsFontSizeToFitWidth:NO];
    }
    return _commentTextField;
}

- (UIButton *)sentCommentButton {
    if (!_sentCommentButton) {
        _sentCommentButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [_sentCommentButton setFrame:CGRectMake(IPHONE_W-50, 3, 40, 40)];
        [_sentCommentButton setTitle:@"发送" forState:UIControlStateNormal];
        [_sentCommentButton setTitleColor:gTextDownload forState:UIControlStateNormal];
        [_sentCommentButton addTarget:self action:@selector(sentCommentAction:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _sentCommentButton;
}

#pragma mark - Utilities
- (void)loadData{
    DefineWeakSelf;
    [NetWorkTool getPaoguoJieMuOrZhuBoPingLunLieBiaoWithact_id:self.act_id andpage:[NSString stringWithFormat:@"%ld",(long)self.commentIndex] andlimit:[NSString stringWithFormat:@"%ld",(long)self.commentPageSize] sccess:^(NSDictionary *responseObject) {
        if ([responseObject[@"results"] isKindOfClass:[NSArray class]]){
            if (weakSelf.commentIndex == 1) {
                [weakSelf.commentInfoArr removeAllObjects];
            }
            else{
        
            }
            [weakSelf.commentInfoArr addObjectsFromArray:responseObject[@"results"]];
            weakSelf.commentInfoArr = [[NSMutableArray alloc]initWithArray:weakSelf.commentInfoArr];
            [weakSelf.commentTableView reloadData];
            [weakSelf endRefreshing];
        }
        else{
            [weakSelf endRefreshing];
        }
    } failure:^(NSError *error) {
        [weakSelf endRefreshing];
    }];
}

- (void)endRefreshing{
    [self.commentTableView.mj_header endRefreshing];
    [self.commentTableView.mj_footer endRefreshing];
}

- (void)back {
    [self.commentTextField resignFirstResponder];
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)SVPDismiss {
    [SVProgressHUD dismiss];
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

- (void)clickPinglunImgHead:(UITapGestureRecognizer *)tapG {
    NSDictionary *components = self.commentInfoArr[tapG.view.tag - 1000];
    [self skipToUserVCWihtcomponents:components];
}

- (void)skipToUserVCWihtcomponents:(NSDictionary *)components{
    gerenzhuyeVC *gerenzhuye = [gerenzhuyeVC new];
    if ([components[@"user_login"] isEqualToString:ExdangqianUser] && [[CommonCode readFromUserD:@"isLogin"]boolValue] == YES) {
        gerenzhuye.isMypersonalPage = YES;
    }
    else{
        gerenzhuye.isMypersonalPage = NO;
    }
    gerenzhuye.isNewsComment = NO;
    gerenzhuye.user_nicename = components[@"user_nicename"];
    gerenzhuye.sex = components[@"sex"];
    gerenzhuye.signature = components[@"signature"];
    gerenzhuye.user_login = components[@"user_login"];
    gerenzhuye.avatar = components[@"avatar"];
    gerenzhuye.user_id = components[@"uid"];
    self.hidesBottomBarWhenPushed = YES;
    [self.navigationController pushViewController:gerenzhuye animated:YES];
    self.hidesBottomBarWhenPushed = YES;
}

#pragma mark - UIButtonAction
- (void)pinglundianzanAction:(UIButton *)sender{
    UITableViewCell *cell = (UITableViewCell *)[[sender superview] superview];
    NSIndexPath *indexPath = [self.commentTableView indexPathForCell:cell];
    UILabel *dianzanNumlab = (UILabel *)[cell.contentView viewWithTag:indexPath.row + 2000];
    if (sender.selected == YES){
        [sender setBackgroundImage:[UIImage imageNamed:@"pinglun-10"] forState:UIControlStateNormal];
        dianzanNumlab.text = [NSString stringWithFormat:@"%d",[dianzanNumlab.text intValue] - 1];
        dianzanNumlab.textColor = [UIColor grayColor];
        dianzanNumlab.alpha = 0.7f;
        sender.selected = NO;
        [NetWorkTool postPaoGuoXinWenPingLunDianZanWithaccessToken:[DSE encryptUseDES:ExdangqianUser]
                                                         andact_id:self.commentInfoArr[indexPath.row][@"id"]
                                                            sccess:^(NSDictionary *responseObject) {
                                                                NSLog(@"responseObject = %@",responseObject);
                                                                NSLog(@"针对评论取消点赞");
                                                            }
                                                           failure:^(NSError *error) {
                                                               NSLog(@"error = %@",error);
                                                           }];
    }
    else{
        [sender setBackgroundImage:[UIImage imageNamed:@"pinglun-yizan"] forState:UIControlStateNormal];
        dianzanNumlab.text = [NSString stringWithFormat:@"%d",[dianzanNumlab.text intValue] + 1];
        dianzanNumlab.textColor = ColorWithRGBA(0, 159, 240, 1);
        dianzanNumlab.alpha = 1.0f;
        sender.selected = YES;
        [NetWorkTool postPaoGuoXinWenPingLunDianZanWithaccessToken:[DSE encryptUseDES:ExdangqianUser] andact_id:self.commentInfoArr[indexPath.row][@"id"] sccess:^(NSDictionary *responseObject) {
            NSLog(@"responseObject = %@",responseObject);
            NSLog(@"针对评论点赞");
        } failure:^(NSError *error) {
            NSLog(@"error = %@",error);
        }];
    }
}

- (void)sentCommentAction:(UIButton *)sender {
    XWAlerLoginView *xw = [[XWAlerLoginView alloc]initWithTitle:@"购买后才能评价哦~"];
    [xw show];
    
//    if ([[CommonCode readFromUserD:@"isLogin"]boolValue] == YES){
//        [self.commentTextField resignFirstResponder];
//        if ([self.commentTextStr isEmpty]) {
//            [SVProgressHUD showErrorWithStatus:@"评论内容不能为空"];
//            [self performSelector:@selector(SVPDismiss) withObject:nil afterDelay:1.0];
//        }
//        else{
//            self.commentTextStr = [CommonCode stringContainsEmoji:self.commentTextStr];
//            if (_isReplyComment) {
//                _isReplyComment = NO;
//                [self.commentTextField setPlaceholder:@"输入评论"];
//                [self.view endEditing:YES];
//                [NetWorkTool postPaoGuoZhuBoOrJieMuLiuYanWithaccessToken:[DSE encryptUseDES:ExdangqianUser] andto_uid:_replyTouid andact_id:self.act_id andcomment_id:_replyCommentid andact_table:@"act" andcontent:self.commentTextStr sccess:^(NSDictionary *responseObject) {
//                    [SVProgressHUD showWithStatus:responseObject[@"msg"]];
//                    [self performSelector:@selector(SVPDismiss) withObject:nil afterDelay:1.0];
//                    [self.commentTableView.mj_header beginRefreshing];
//                    [self.view endEditing:YES];
//                    self.commentTextField.text = @"";
//                } failure:^(NSError *error) {
//                    [SVProgressHUD dismiss];
//                    NSLog(@"error = %@",error);
//                }];
//            }
//            else{
//                [NetWorkTool postPaoGuoZhuBoOrJieMuLiuYanWithaccessToken:[DSE encryptUseDES:ExdangqianUser] andto_uid:@"0" andact_id:self.act_id andcomment_id:nil andact_table:@"act" andcontent:self.commentTextStr sccess:^(NSDictionary *responseObject) {
//                    [SVProgressHUD showWithStatus:responseObject[@"msg"]];
//                    [self performSelector:@selector(SVPDismiss) withObject:nil afterDelay:1.0];
//                    [self.commentTableView.mj_header beginRefreshing];
//                    [self.view endEditing:YES];
//                    self.commentTextField.text = @"";
//                    
//                } failure:^(NSError *error) {
//                    [SVProgressHUD dismiss];
//                    NSLog(@"error = %@",error);
//                }];
//            }
//        }
//    }
//    else{
//        [self loginFirst];
//    }
}

#pragma mark - UITableViewDelegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
//    NSDictionary *dic = self.commentInfoArr[indexPath.row];
//    if ([ExdangqianUser isEqualToString:dic[@"user_login"]]) {
//        [UIActionSheet actionSheetWithTitle:nil message:nil buttons:@[@"删除", @"复制"] showInView:self.view onDismiss:^(int buttonIndex) {
//            if (buttonIndex == 0) {
//                [NetWorkTool delActWithaccessToken:AvatarAccessToken act_id:dic[@"id"] sccess:^(NSDictionary *responseObject) {
//                    [self.commentTableView.mj_header beginRefreshing];
//                    
//                } failure:^(NSError *error) {
//                    //
//                    NSLog(@"delete error");
//                }];
//            }
//            else{
//                UIPasteboard *gr                             = [UIPasteboard generalPasteboard];
//                gr.string                                    = [NSString stringWithFormat:@"%@",dic[@"content"]];
//                XWAlerLoginView *xw = [[XWAlerLoginView alloc]initWithTitle:@"分享链接已复制到您的剪切板~~"];
//                [xw show];
//            }
//        } onCancel:^{
//            
//        }];
//        
//    }
//    else{
//        
//        [UIActionSheet actionSheetWithTitle:nil message:nil buttons:@[@"回复", @"复制"] showInView:self.view onDismiss:^(int buttonIndex) {
//            if (buttonIndex == 0) {
//                if ([[CommonCode readFromUserD:@"isLogin"]boolValue] == YES){
//                    //TODO:弹起键盘上方带@xxx
//                    _isReplyComment = YES;
//                    _replyTouid = self.commentInfoArr[indexPath.row][@"uid"];
//                    _replyCommentid = self.commentInfoArr[indexPath.row][@"id"];
//                    self.commentTextField.placeholder = [NSString stringWithFormat:@"@%@",self.commentInfoArr[indexPath.row][@"full_name"]];
//                    [self.commentTextField becomeFirstResponder];
//                }
//                else{
//                    [self loginFirst];
//                }
//            }
//            else{
//                UIPasteboard *gr                             = [UIPasteboard generalPasteboard];
//                gr.string                                    = [NSString stringWithFormat:@"%@",dic[@"content"]];
//                XWAlerLoginView *xw = [[XWAlerLoginView alloc]initWithTitle:@"分享链接已复制到您的剪切板~~"];
//                [xw show];
//            }
//        } onCancel:^{
//            
//        }];
//        
//    }
}

#pragma mark - UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    //    if (! [self.dataSourceArr count]) {
    //        if (!_label) {
    //            _label = [[UILabel alloc]initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, 20)];
    //            _label.textAlignment = NSTextAlignmentCenter;
    //            _label.text = @"暂无数据";
    //            _label.textColor = [UIColor lightGrayColor];
    //            _label.center = self.helpTableView.center;
    //            [self.helpTableView addSubview:_label];
    //        }else {
    //            [self.helpTableView addSubview:_label];
    //        }
    //    }
    //    else{
    //        [_label removeFromSuperview];
    //    }
   return  [self.commentInfoArr count];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    UITableViewCell *cell = (UITableViewCell *)[tableView viewWithTag:indexPath.row + 10];
    UILabel *lab = (UILabel *)[cell viewWithTag:indexPath.row + 11];
    return CGRectGetMaxY(lab.frame) + 10.0 / 667 * IPHONE_H;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    static NSString *pinglunIdentify = @"pinglunIdentify";
    UITableViewCell *cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:pinglunIdentify];
    if (!cell){
        cell = [tableView dequeueReusableCellWithIdentifier:pinglunIdentify];
    }
    //头像
    UIImageView *pinglunImg = [[UIImageView alloc]initWithFrame:CGRectMake(20.0 / 375 * IPHONE_W, 8.0 / 667 * IPHONE_H, 50.0 / 667 * IPHONE_H, 50.0 / 667 * IPHONE_H)];
    if ([self.commentInfoArr[indexPath.row][@"avatar"]  rangeOfString:@"http"].location != NSNotFound){
        [pinglunImg sd_setImageWithURL:[NSURL URLWithString:self.commentInfoArr[indexPath.row][@"avatar"]] placeholderImage:[UIImage imageNamed:@"right-1"]];
    }
    else{
        [pinglunImg sd_setImageWithURL:[NSURL URLWithString:USERPHOTOHTTPSTRING(self.commentInfoArr[indexPath.row][@"avatar"])] placeholderImage:[UIImage imageNamed:@"right-1"]];
    }
    pinglunImg.userInteractionEnabled = YES;
    pinglunImg.tag = 1000 + indexPath.row;
    UITapGestureRecognizer *TapG = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(clickPinglunImgHead:)];
    [pinglunImg addGestureRecognizer:TapG];
    pinglunImg.contentMode = UIViewContentModeScaleAspectFill;
    pinglunImg.layer.masksToBounds = YES;
    pinglunImg.layer.cornerRadius = 25.0 / 667 * IPHONE_H;
    [cell.contentView addSubview:pinglunImg];
    //
    UILabel *pinglunTitle = [[UILabel alloc]initWithFrame:CGRectMake(CGRectGetMaxX(pinglunImg.frame) + 8.0 / 375 * IPHONE_W, 10.0 / 667 * IPHONE_H, 200.0 / 375 * IPHONE_W, 20.0 / 667 * IPHONE_H)];
    pinglunTitle.text = self.commentInfoArr[indexPath.row][@"full_name"];
    pinglunTitle.textAlignment = NSTextAlignmentLeft;
    pinglunTitle.textColor = [UIColor blackColor];
    pinglunTitle.font = [UIFont systemFontOfSize:16.0f];
    [cell.contentView addSubview:pinglunTitle];
    //时间
    UILabel *pinglunshijian = [[UILabel alloc]initWithFrame:CGRectMake(CGRectGetMaxX(pinglunImg.frame) + 8.0 / 375 * IPHONE_W, CGRectGetMaxY(pinglunTitle.frame) + 5.0 / 667 * IPHONE_H, 200.0 / 375 * IPHONE_W, 20.0 / 667 * IPHONE_H)];
    pinglunshijian.text = self.commentInfoArr[indexPath.row][@"createtime"];
    pinglunshijian.textAlignment = NSTextAlignmentLeft;
    pinglunshijian.textColor = [UIColor grayColor];
    pinglunshijian.font = [UIFont systemFontOfSize:13.0f];
    [cell.contentView addSubview:pinglunshijian];
    //评论
    TTTAttributedLabel *pinglunLab = [[TTTAttributedLabel alloc]initWithFrame:CGRectMake(CGRectGetMaxX(pinglunImg.frame) - 3.0 / 375 * IPHONE_W, CGRectGetMaxY(pinglunshijian.frame) + 10.0 / 667 * IPHONE_H, IPHONE_W - 80.0 / 375 * IPHONE_W, 20.0 / 667 * IPHONE_H)];
    pinglunLab.text = self.commentInfoArr[indexPath.row][@"content"];
    pinglunLab.textColor = [UIColor blackColor];
    pinglunLab.font = [UIFont systemFontOfSize:16.0f];
    pinglunLab.textAlignment = NSTextAlignmentLeft;
    pinglunLab.tag = indexPath.row + 11;
    pinglunLab.numberOfLines = 0;
    pinglunLab.lineSpacing = 5;
    pinglunLab.fd_collapsed = NO;
    pinglunLab.lineBreakMode = NSLineBreakByWordWrapping;
    if ([self.commentInfoArr[indexPath.row][@"content"] rangeOfString:@"[e1]"].location != NSNotFound && [self.commentInfoArr[indexPath.row][@"content"] rangeOfString:@"[/e1]"].location != NSNotFound){
        if ([self.commentInfoArr[indexPath.row][@"to_user_login"] length]) {
            pinglunLab.text = [NSString stringWithFormat:@"回复@%@:%@",[self.commentInfoArr[indexPath.row][@"to_user_nicename"] length] ? self.commentInfoArr[indexPath.row][@"to_user_nicename"]:self.commentInfoArr[indexPath.row][@"to_user_login"],[CommonCode jiemiEmoji:self.commentInfoArr[indexPath.row][@"content"]]];
            NSMutableDictionary *to_user = [NSMutableDictionary new];
            [to_user setValue:self.commentInfoArr[indexPath.row][@"to_user_nicename"] forKey:@"user_nicename"];
            [to_user setValue:self.commentInfoArr[indexPath.row][@"to_sex"] forKey:@"sex"];
            [to_user setValue:self.commentInfoArr[indexPath.row][@"to_signature"] forKey:@"signature"];
            [to_user setValue:self.commentInfoArr[indexPath.row][@"to_user_login"] forKey:@"user_login"];
            [to_user setValue:self.commentInfoArr[indexPath.row][@"to_avatar"] forKey:@"avatar"];
            //        [to_user setValue:liuyanArr[indexPath.row][@"to_user_nicename"] forKey:@"fan_num"];
            //        [to_user setValue:liuyanArr[indexPath.row][@"to_user_nicename"] forKey:@"guan_num"];
            [to_user setValue:self.commentInfoArr[indexPath.row][@"to_uid"] forKey:@"id"];
            NSRange nameRange = NSMakeRange(2, [self.commentInfoArr[indexPath.row][@"to_user_nicename"] length] ? [self.commentInfoArr[indexPath.row][@"to_user_nicename"] length] + 1 : [self.commentInfoArr[indexPath.row][@"to_user_login"] length] + 1);
            [pinglunLab setLinkAttributes:@{NSForegroundColorAttributeName : gMainColor,NSFontAttributeName :gFontMajor16}];
            [pinglunLab setActiveLinkAttributes:@{NSForegroundColorAttributeName : gMainColor,NSFontAttributeName :gFontMajor16}];
            [pinglunLab addLinkToTransitInformation:to_user withRange:nameRange];
            [pinglunLab setDelegate:self];
            
        }
        else{
            pinglunLab.text = [CommonCode jiemiEmoji:self.commentInfoArr[indexPath.row][@"content"]];
        }
    }
    else{
        if ([self.commentInfoArr[indexPath.row][@"to_user_login"] length]) {
            pinglunLab.text = [NSString stringWithFormat:@"回复@%@:%@",[self.commentInfoArr[indexPath.row][@"to_user_nicename"] length] ? self.commentInfoArr[indexPath.row][@"to_user_nicename"]:self.commentInfoArr[indexPath.row][@"to_user_login"],self.commentInfoArr[indexPath.row][@"content"]];
            NSMutableDictionary *to_user = [NSMutableDictionary new];
            [to_user setValue:self.commentInfoArr[indexPath.row][@"to_user_nicename"] forKey:@"user_nicename"];
            [to_user setValue:self.commentInfoArr[indexPath.row][@"to_sex"] forKey:@"sex"];
            [to_user setValue:self.commentInfoArr[indexPath.row][@"to_signature"] forKey:@"signature"];
            [to_user setValue:self.commentInfoArr[indexPath.row][@"to_user_login"] forKey:@"user_login"];
            [to_user setValue:self.commentInfoArr[indexPath.row][@"to_avatar"] forKey:@"avatar"];
            //        [to_user setValue:liuyanArr[indexPath.row][@"to_user_nicename"] forKey:@"fan_num"];
            //        [to_user setValue:liuyanArr[indexPath.row][@"to_user_nicename"] forKey:@"guan_num"];
            [to_user setValue:self.commentInfoArr[indexPath.row][@"to_uid"] forKey:@"id"];
            NSRange nameRange = NSMakeRange(2,  [self.commentInfoArr[indexPath.row][@"to_user_nicename"] length] ? [self.commentInfoArr[indexPath.row][@"to_user_nicename"] length] + 1 : [self.commentInfoArr[indexPath.row][@"to_user_login"] length] + 1);
            [pinglunLab setLinkAttributes:@{NSForegroundColorAttributeName : gMainColor,NSFontAttributeName :gFontMajor16}];
            [pinglunLab setActiveLinkAttributes:@{NSForegroundColorAttributeName : gMainColor,NSFontAttributeName :gFontMajor16}];
            [pinglunLab addLinkToTransitInformation:to_user withRange:nameRange];
            [pinglunLab setDelegate:self];
        }
        else{
            pinglunLab.text = self.commentInfoArr[indexPath.row][@"content"];
        }
    }
    //获取tttLabel的高度
    //先通过NSMutableAttributedString设置和上面tttLabel一样的属性,例如行间距,字体
    NSMutableAttributedString *attrString = [[NSMutableAttributedString alloc] initWithString:pinglunLab.text];
    //自定义str和TTTAttributedLabel一样的行间距
    NSMutableParagraphStyle *paragrapStyle = [[NSMutableParagraphStyle alloc] init];
    [paragrapStyle setLineSpacing:5];
    //设置行间距
    [attrString addAttribute:NSParagraphStyleAttributeName value:paragrapStyle range:NSMakeRange(0, [pinglunLab.text length])];
    //设置字体
    [attrString addAttribute:NSFontAttributeName value:[UIFont systemFontOfSize:16] range:NSMakeRange(0, [pinglunLab.text length])];
    
    //得到自定义行间距的UILabel的高度
    //CGSizeMake(300,MAXFLOAt)中的300,代表是UILable控件的宽度,它和初始化TTTAttributedLabel的宽度是一样的.
    CGFloat height = [TTTAttributedLabel sizeThatFitsAttributedString:attrString withConstraints:CGSizeMake(pinglunLab.frame.size.width, MAXFLOAT) limitedToNumberOfLines:0].height;
    //重新改变tttLabel的frame高度
    CGRect rect = pinglunLab.frame;
    rect.size.height = height + 10 ;
    pinglunLab.frame = rect;
    [cell.contentView addSubview:pinglunLab];
    
    cell.tag = indexPath.row + 10;
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    UIButton *PingLundianzanBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    PingLundianzanBtn.frame = CGRectMake(IPHONE_W - 60.0 / 375 * IPHONE_W, 20.0 / 667 * IPHONE_H, 20.0 / 375 * IPHONE_W, 20.0 / 667 * IPHONE_H);
    [cell.contentView addSubview:PingLundianzanBtn];
    [PingLundianzanBtn addTarget:self action:@selector(pinglundianzanAction:) forControlEvents:UIControlEventTouchUpInside];
    
    PingLundianzanNumLab = [[UILabel alloc]initWithFrame:CGRectMake(CGRectGetMaxX(PingLundianzanBtn.frame) + 8.0 / 375 * IPHONE_W, PingLundianzanBtn.frame.origin.y + 1.0 / 667 * IPHONE_H, 20.0 / 375 * IPHONE_W, 20.0 / 667 * IPHONE_H)];
    PingLundianzanNumLab.text = self.commentInfoArr[indexPath.row][@"praisenum"];
    
    PingLundianzanNumLab.textAlignment = NSTextAlignmentCenter;
    PingLundianzanNumLab.font = [UIFont systemFontOfSize:16.0f / 375 * IPHONE_W];
    PingLundianzanNumLab.tag = indexPath.row + 2000;
    [cell.contentView addSubview:PingLundianzanNumLab];
    
    if ([[NSString stringWithFormat:@"%@",self.commentInfoArr[indexPath.row][@"praiseFlag"]] isEqualToString:@"1"]){
        [PingLundianzanBtn setBackgroundImage:[UIImage imageNamed:@"pinglun-10"] forState:UIControlStateNormal];
        PingLundianzanBtn.selected = NO;
        PingLundianzanNumLab.textColor = [UIColor grayColor];
        PingLundianzanNumLab.alpha = 0.7f;
    }
    else if([[NSString stringWithFormat:@"%@",self.commentInfoArr[indexPath.row][@"praiseFlag"]] isEqualToString:@"2"]){
        [PingLundianzanBtn setBackgroundImage:[UIImage imageNamed:@"pinglun-yizan"] forState:UIControlStateNormal];
        PingLundianzanBtn.selected = YES;
        PingLundianzanNumLab.textColor = ColorWithRGBA(0, 159, 240, 1);
        PingLundianzanNumLab.alpha = 1.0f;
    }
    else {
        [PingLundianzanBtn setBackgroundImage:[UIImage imageNamed:@"pinglun-10"] forState:UIControlStateNormal];
        PingLundianzanBtn.selected = NO;
        PingLundianzanNumLab.textColor = [UIColor grayColor];
        PingLundianzanNumLab.alpha = 0.7f;
    }
    return cell;
}

#pragma mark - TTTAttributedLabelDelegate

- (void)attributedLabel:(TTTAttributedLabel *)label
didSelectLinkWithTransitInformation:(NSDictionary *)components {
    gerenzhuyeVC *gerenzhuye = [gerenzhuyeVC new];
    if ([components[@"user_login"] isEqualToString:ExdangqianUser] && [[CommonCode readFromUserD:@"isLogin"]boolValue] == YES) {
        gerenzhuye.isMypersonalPage = YES;
    }
    else{
        gerenzhuye.isMypersonalPage = NO;
    }
    gerenzhuye.isNewsComment = NO;
    gerenzhuye.user_nicename = components[@"user_nicename"];
    gerenzhuye.sex = components[@"sex"];
    gerenzhuye.signature = components[@"signature"];
    gerenzhuye.user_login = components[@"user_login"];
    gerenzhuye.avatar = components[@"avatar"];
    gerenzhuye.user_id = components[@"id"];
    self.hidesBottomBarWhenPushed=YES;
    [self.navigationController pushViewController:gerenzhuye animated:YES];
    self.hidesBottomBarWhenPushed=YES;
}

#pragma mark - UITextFieldDelegate

- (BOOL)textFieldShouldEndEditing:(UITextField *)textField{
    self.commentTextStr = textField.text;
    return YES;
}

#pragma mark - UIScrollViewDelegate

- (void)scrollViewDidScroll:(UIScrollView *)scrollView{
    [self.view endEditing:YES];
    _isReplyComment = NO;
    self.commentTextField.placeholder = @"输入评论";
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
