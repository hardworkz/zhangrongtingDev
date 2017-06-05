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

@interface CommentViewController ()<UITableViewDelegate,UITableViewDataSource,UITextFieldDelegate>
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
        RTLog(@"%@",responseObject[@"results"]);
        [weakSelf endRefreshing];
        if ([responseObject[@"results"] isKindOfClass:[NSArray class]]){
            if (weakSelf.commentIndex == 1) {
                [weakSelf.commentInfoArr removeAllObjects];
            }
            [weakSelf.commentInfoArr addObjectsFromArray:[PlayVCCommentModel mj_objectArrayWithKeyValuesArray:responseObject[@"results"]]];
            weakSelf.commentInfoArr = [[NSMutableArray alloc]initWithArray:[self pinglunFrameModelArrayWithModelArray:weakSelf.commentInfoArr]];
            [weakSelf.commentTableView reloadData];
            [weakSelf endRefreshing];
        }
    } failure:^(NSError *error) {
        [weakSelf endRefreshing];
    }];
}
///评论model转为frameModel
- (NSMutableArray *)pinglunFrameModelArrayWithModelArray:(NSArray *)array
{
    NSMutableArray *frameArray = [NSMutableArray array];
    for (PlayVCCommentModel *model in array) {
        PlayVCCommentFrameModel *frameModel = [[PlayVCCommentFrameModel alloc] init];
        frameModel.model = model;
        [frameArray addObject:frameModel];
    }
    return frameArray;
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
- (void)pinglundianzanAction:(PinglundianzanCustomBtn *)pinglundianzanBtn frameModel:(PlayVCCommentFrameModel *)frameModel
{
    PlayVCCommentModel *model = frameModel.model;
    UILabel *dianzanNumlab = pinglundianzanBtn.PingLundianzanNumLab;
    if (pinglundianzanBtn.selected == YES){
        [NetWorkTool postPaoGuoXinWenPingLunDianZanWithaccessToken:[DSE encryptUseDES:ExdangqianUser] andact_id:model.playCommentID sccess:^(NSDictionary *responseObject) {
            NSLog(@"responseObject = %@",responseObject);
            NSLog(@"针对评论取消点赞");
            dianzanNumlab.text = [NSString stringWithFormat:@"%d",[dianzanNumlab.text intValue] - 1];
            dianzanNumlab.textColor = [UIColor grayColor];
            dianzanNumlab.alpha = 0.7f;
            pinglundianzanBtn.selected = NO;
        } failure:^(NSError *error) {
            NSLog(@"error = %@",error);
        }];
    }
    else{
        [NetWorkTool postPaoGuoXinWenPingLunDianZanWithaccessToken:[DSE encryptUseDES:ExdangqianUser] andact_id:model.playCommentID sccess:^(NSDictionary *responseObject) {
            NSLog(@"responseObject = %@",responseObject);
            NSLog(@"针对评论点赞");
            dianzanNumlab.text = [NSString stringWithFormat:@"%d",[dianzanNumlab.text intValue] + 1];
            dianzanNumlab.textColor = ColorWithRGBA(0, 159, 240, 1);
            dianzanNumlab.alpha = 1.0f;
            pinglundianzanBtn.selected = YES;
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

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
   return  [self.commentInfoArr count];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    PlayVCCommentFrameModel *frameModel = self.commentInfoArr[indexPath.row];
    return frameModel.cellHeight;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    PlayVCCommentTableViewCell *cell = [PlayVCCommentTableViewCell cellWithTableView:tableView];
    cell.isClassComment = YES;
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    PlayVCCommentFrameModel *frameModel = self.commentInfoArr[indexPath.row];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    cell.frameModel = frameModel;
    MJWeakSelf;
    cell.zanClicked = ^(PinglundianzanCustomBtn *zanButton, PlayVCCommentFrameModel *frameModel) {
        [weakSelf pinglundianzanAction:zanButton frameModel:frameModel];
    };
    return cell;

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

@end
