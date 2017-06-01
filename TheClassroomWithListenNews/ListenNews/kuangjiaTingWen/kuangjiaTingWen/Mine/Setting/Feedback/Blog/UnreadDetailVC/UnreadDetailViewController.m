//
//  UnreadDetailViewController.m
//  kuangjiaTingWen
//
//  Created by Zhimi on 16/11/29.
//  Copyright © 2016年 贺楠. All rights reserved.
//

#import "UnreadDetailViewController.h"

#import "BlogTableViewCell.h"
#import "bofangVC.h"
#import "UIAlertView+MKBlockAdditions.h"
#import "PhotoBrowserController.h"
#import "UIView+AnimationOptionsForCurve.h"
#import "gerenzhuyeVC.h"

@interface UnreadDetailViewController ()<UITableViewDataSource,UITableViewDelegate,UITextFieldDelegate,TTTAttributedLabelDelegate>

@property (strong, nonatomic) UITableView *unreadTableview;
@property(strong,nonatomic)NSMutableArray *infoArr;
@property (strong, nonatomic) UIView *toolBarView;
@property (strong, nonatomic) UITextField *commentTextField;
@property (strong, nonatomic) UIButton *sentCommentButton;
@property (strong, nonatomic) NSString *commentTextStr;
@property (strong, nonatomic) UITableViewCell *commentCell;
@property (assign, nonatomic) BOOL isReplyComment;
@property (strong, nonatomic) NSString *replyComment_tuid;

@property (strong, nonatomic) AVPlayer *voicePlayer;

@property (strong,nonatomic)AVAudioPlayer *player;
@property (strong, nonatomic) AVAudioSession *session;
@property(strong,nonatomic)UIImageView *voiceImgV;

@end

@implementation UnreadDetailViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self setupData];
    [self setupView];
}

- (void)setupData{
    
    [self.unreadTableview registerNib:[UINib nibWithNibName:BlogTableViewCellID bundle:nil] forCellReuseIdentifier:BlogTableViewCellID];
    
    [self loadData];
    
}

- (void)setupView{
    [self enableAutoBack];
    self.title = @"消息详情";
    [self.view addSubview:self.unreadTableview];
    [self.view addSubview:self.toolBarView];
    [self.toolBarView setHidden:YES];
    self.commentTextStr = @"";
    
    UISwipeGestureRecognizer *rightSwipe = [[UISwipeGestureRecognizer alloc]initWithTarget:self action:@selector(back)];
    [rightSwipe setDirection:UISwipeGestureRecognizerDirectionRight];
    [self.unreadTableview addGestureRecognizer:rightSwipe];
}

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    [self.navigationController setNavigationBarHidden:NO animated:YES];
    self.hidesBottomBarWhenPushed = YES;
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(handleWillShowKeyboard:)
                                                 name:UIKeyboardWillShowNotification
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(handleWillHideKeyboard:)
                                                 name:UIKeyboardWillHideNotification
                                               object:nil];
    
}

- (void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    [IQKeyboardManager sharedManager].enable = NO;
    [self.voiceImgV removeFromSuperview];
    [self.toolBarView setHidden:YES];
    [self.commentTextField resignFirstResponder];
    [self.player stop];
    [self.voicePlayer pause];
    
}

#pragma mark - Getter

- (UITableView *)unreadTableview {
    if (!_unreadTableview) {
        _unreadTableview = [[UITableView alloc]initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_HEIGHT - 64) style:UITableViewStylePlain];
        [_unreadTableview setDelegate:self];
        [_unreadTableview setDataSource:self];
        _unreadTableview.tableFooterView =  [UIView new];
        //        [_blogTableview setContentOffset:CGPointMake(SCREEN_WIDTH, SCREEN_HEIGHT - 64)];
        //        [_blogTableview setContentSize:CGSizeMake(SCREEN_WIDTH, SCREEN_HEIGHT - 64)];
        //        [_blogTableview setContentInset:UIEdgeInsetsMake(0, 0, 0, 150)];
    }
    return  _unreadTableview;
}

- (NSMutableArray *)infoArr{
    if (!_infoArr){
        _infoArr = [NSMutableArray array];
    }
    return _infoArr;
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

- (AVPlayer *)voicePlayer {
    if (!_voicePlayer) {
        _voicePlayer = [[AVPlayer alloc]init];
    }
    return _voicePlayer;
}

-(UIImageView *)voiceImgV
{
    if ( _voiceImgV == nil) {
        _voiceImgV = [[UIImageView alloc]initWithFrame:CGRectMake(10, 10, 20, 20)];
        [_voiceImgV setImage:[UIImage imageNamed:@"v_anim4"]];
        
    }
    return _voiceImgV;
}

#pragma mark - UtilityMethod

- (void)loadData{
    DefineWeakSelf;
     weakSelf.infoArr = [NSMutableArray array];
    switch (self.pageSource) {
        case 1:{
            //听友圈
            [NetWorkTool newPromptGetOneWithaccessToken:AvatarAccessToken parentid:self.parentid path:self.path sccess:^(NSDictionary *responseObject) {
                
                NSLog(@"%@",responseObject[@"results"]);
                
                if ([[responseObject[@"results"][@"user"] allKeys] containsObject:@"user_login"]) {
                    [weakSelf.infoArr addObject:responseObject[@"results"]];
                    [weakSelf.unreadTableview reloadData];
                }
                else{
                    //提示数据不存在，返回上一级菜单
                    [self back];
//                    [SVProgressHUD showErrorWithStatus:@"您要查看的数据不存在"];
//                    [self performSelector:@selector(SVPDismiss) withObject:nil afterDelay:1.0];
                }
                
            } failure:^(NSError *error) {
                //
            }];
        }
            break;
        case 2:{
            //意见反馈
            [NetWorkTool feedbackGetOneWithaccessToken:AvatarAccessToken feedback_id:self.feedback_id sccess:^(NSDictionary *responseObject) {
                //
                NSLog(@"%@",responseObject[@"results"]);
                if ([responseObject[@"status"] integerValue] == 1) {
                   [weakSelf.infoArr addObject:responseObject[@"results"]];
                    [weakSelf.unreadTableview reloadData];
                }
                else{
                    //提示数据不存在，返回上一级菜单
                    [self back];
//                    [SVProgressHUD showErrorWithStatus:@"您要查看的数据不存在"];
//                    [self performSelector:@selector(SVPDismiss) withObject:nil afterDelay:1.0];

                }
            } failure:^(NSError *error) {
                //
            }];
        }
            break;
            
        default:
            break;
    }
}

- (void)SVPDismiss {
    [SVProgressHUD dismiss];
}

- (void)addFavInTableViewCell:(BlogTableViewCell *)cell andIszan:(int )iszan{
    NSIndexPath *indexPath = [self.unreadTableview indexPathForCell:cell];
    NSMutableDictionary *blog = self.infoArr[indexPath.row];
    cell.praiseButton.userInteractionEnabled = NO;
    DefineWeakSelf;
    switch (self.pageSource) {
        case 1:{
            [NetWorkTool addAndCancelPraiseWithaccessToken:[DSE encryptUseDES:ExdangqianUser] comments_id:blog[@"id"] sccess:^(NSDictionary *responseObject) {
                [weakSelf loadData];
                //            [weakSelf.blogTableview reloadData];
                cell.praiseButton.userInteractionEnabled = YES;
            } failure:^(NSError *error) {
                cell.praiseButton.userInteractionEnabled = YES;
                [SVProgressHUD showErrorWithStatus:@"网络请求失败"];
                [self performSelector:@selector(SVPDismiss) withObject:nil afterDelay:1.0];
            }];
        }
            break;
        case 2:{
            if (iszan == 1){
                [NetWorkTool delFeedbackZanWithaccessToken:[DSE encryptUseDES:ExdangqianUser] feedback_id:blog[@"id"] sccess:^(NSDictionary *responseObject) {
                    //                没有重新获取列表数据
                    [weakSelf.infoArr[indexPath.row] setValue:@"0" forKey:@"is_zan"];
                    [weakSelf.infoArr[indexPath.row] setValue:[NSString stringWithFormat:@"%d",[weakSelf.infoArr[indexPath.row][@"zan_num"] intValue] - 1] forKey:@"zan_num"];
                    //                [weakSelf.tableView reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
                    [weakSelf.unreadTableview reloadData];
                    //                [weakSelf loadData];
                    cell.praiseButton.userInteractionEnabled = YES;
                    
                } failure:^(NSError *error) {
                    cell.praiseButton.userInteractionEnabled = YES;
                    [SVProgressHUD showErrorWithStatus:@"网络请求失败"];
                    [self performSelector:@selector(SVPDismiss) withObject:nil afterDelay:1.0];
                }];
            }
            else {
                [NetWorkTool addFeedbackZanWithaccessToken:[DSE encryptUseDES:ExdangqianUser] feedback_id:blog[@"id"] sccess:^(NSDictionary *responseObject) {
                    //                 没有重新获取列表数据
                    [weakSelf.infoArr[indexPath.row] setValue:@"1" forKey:@"is_zan"];
                    [weakSelf.infoArr[indexPath.row] setValue:[NSString stringWithFormat:@"%d",[weakSelf.infoArr[indexPath.row][@"zan_num"] intValue] + 1] forKey:@"zan_num"];
                    [weakSelf.unreadTableview reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
                    //                [weakSelf loadData];
                    cell.praiseButton.userInteractionEnabled = YES;
                } failure:^(NSError *error) {
                    cell.praiseButton.userInteractionEnabled = YES;
                    [SVProgressHUD showErrorWithStatus:@"网络请求失败"];
                    [self performSelector:@selector(SVPDismiss) withObject:nil afterDelay:1.0];
                }];
            }
        }
            break;
        default:
            break;
    }

    
}

- (void)deleteBlogIntableViewCell:(BlogTableViewCell *)cell{
    NSIndexPath *indexPath = [self.unreadTableview indexPathForCell:cell];
    //        BlogModel *blog = self.blogArray[indexPath.row];
    DefineWeakSelf;
    [UIAlertView alertViewWithTitle:@"提示" message:@"确认删除吗？" cancelButtonTitle:@"取消" otherButtonTitles:@[@"删除"] onDismiss:^(int buttonIndex) {
        //            [weakSelf deleteBlog:blog];
        [NetWorkTool delCommentWithaccessToken:AvatarAccessToken comment_id:self.infoArr[indexPath.row][@"id"] sccess:^(NSDictionary *responseObject) {
            //
            NSLog(@"delSuccess");
            [self.player stop];
            [self.voicePlayer pause];
            [self.voiceImgV removeFromSuperview];
            [weakSelf loadData];
        } failure:^(NSError *error) {
            //
            NSLog(@"%@",error);
        }];
    } onCancel:^{
    }];
}

- (void)addCommentInTableViewCell:(BlogTableViewCell *)cell{
        
    NSIndexPath *indexPath = [self.unreadTableview indexPathForCell:cell];
    _commentCell = cell;
    self.toolBarView.frame = CGRectMake(0, SCREEN_HEIGHT, SCREEN_WIDTH, 46);
    [[UIApplication sharedApplication].keyWindow addSubview:self.toolBarView];
    self.isReplyComment = NO;
    [self.commentTextField setPlaceholder:@"评论"];
    self.unreadTableview.delegate = nil;
    [self.unreadTableview scrollToRowAtIndexPath:indexPath atScrollPosition:UITableViewScrollPositionTop animated:NO];
    //        CGRect rectintableview=[self.blogTableview rectForRowAtIndexPath:indexPath];
    //        [self.blogTableview setContentOffset:CGPointMake(self.blogTableview.contentOffset.x,(rectintableview.origin.y-self.blogTableview.contentOffset.y)+self.blogTableview.contentOffset.y + 20) animated:YES];
    self.unreadTableview.delegate = self;
    [self.toolBarView setHidden:NO];
    [self.commentTextField becomeFirstResponder];

}

- (void)playVoiceInTableViewCell:(BlogTableViewCell *)cell {
    [self.unreadTableview addSubview:self.voiceImgV];
    [self.voiceImgV startAnimating];
    NSIndexPath *indexPath = [self.unreadTableview indexPathForCell:cell];
    NSMutableDictionary *blog = self.infoArr[indexPath.row];
    if ([bofangVC shareInstance].isPlay) {
        [[bofangVC shareInstance] doplay2];
    }
    else{
        
    }
    //用一个uiimageview 盖住原来的再添加动画效果
    CGRect  frame  = [cell.voiceButton convertRect:self.voiceImgV.bounds toView:self.unreadTableview];
    CGRect finalFrame = CGRectMake(frame.origin.x + 10, frame.origin.y + 10, frame.size.width, frame.size.height);
    [self.voiceImgV setFrame:finalFrame];
    [self.voiceImgV setBackgroundColor:[UIColor colorWithRed:0.07 green:0.72 blue:0.96 alpha:1.00]];
    [self.unreadTableview addSubview:self.voiceImgV];
    [self.player stop];
    [self.voicePlayer pause];
    
    if ([blog[@"mp3_url"] rangeOfString:@"mp3"].location != NSNotFound) {
        NSString *urlStr = blog[@"mp3_url"];
        NSURL *url = [[NSURL alloc]initWithString:urlStr];
        NSData * audioData = [NSData dataWithContentsOfURL:url];
        //将数据保存到本地指定位置
        NSString *docDirPath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
        NSString *filePath = [NSString stringWithFormat:@"%@/%@.aac", docDirPath , @"temp"];
        [audioData writeToFile:filePath atomically:YES];
        //播放本地音乐
        //获取单例
        AVAudioSession *avSession = [AVAudioSession sharedInstance];
        //重新设置策略，不然播放的声音会很小
        [avSession setCategory:AVAudioSessionCategoryPlayback error:nil];
        //重新设置为活动状态
        [avSession setActive:YES error:nil];
        NSError *error = nil;
        NSURL *fileURL = [NSURL fileURLWithPath:filePath];
        //        _player = [[AVAudioPlayer alloc] initWithContentsOfURL:fileURL error:&error];
        NSData *data = [NSData dataWithContentsOfURL:fileURL];
        self.player = [[AVAudioPlayer alloc] initWithData:data fileTypeHint:AVFileTypeWAVE error:&error];
        self.player.volume = 1;
        if (error) {
            NSLog(@"error:%@",[error description]);
            return;
        }
        [self.player prepareToPlay];
        [self.player play];
        //动画开启
        [self voicePlayWithAnimateTime:[self.infoArr[indexPath.row][@"play_time"] integerValue]];
        
    }
    else{
        if (self.voicePlayer == nil) {
            self.voicePlayer = [[AVPlayer alloc]init];
            //添加观察者，用来监视播放器的状态变化
            [self.voicePlayer addObserver:self forKeyPath:@"statu" options:NSKeyValueObservingOptionNew context:nil];
            //添加观察者，用来监听播放器的缓冲进度loadedTimeRanges属性
            //            [Explayer addObserver:self forKeyPath:@"loadedTimeRanges" options:NSKeyValueObservingOptionNew context:nil];
        }
        [self.voicePlayer replaceCurrentItemWithPlayerItem:[[AVPlayerItem alloc]initWithURL:[NSURL URLWithString:blog[@"mp3_url"]]]];
        //播放完毕后发出通知
//        [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(voicePlayEnd:) name:AVPlayerItemDidPlayToEndTimeNotification object:self.voicePlayer.currentItem];
//        [[NSNotificationCenter defaultCenter] postNotificationName:AVPlayerItemDidPlayToEndTimeNotification object:self.voicePlayer.currentItem];
        [self.voicePlayer play];
        //动画开启
        [self voicePlayWithAnimateTime:[self.infoArr[indexPath.row][@"play_time"] integerValue]];
        if (ExisRigester == NO){
            //添加观察者，用来监视播放器的状态变化
            [self.voicePlayer addObserver:self forKeyPath:@"statu" options:NSKeyValueObservingOptionNew context:nil];
            //        //添加观察者，用来监听播放器的缓冲进度loadedTimeRanges属性
            //            [Explayer addObserver:self forKeyPath:@"loadedTimeRange" options:NSKeyValueObservingOptionNew context:nil];
            ExisRigester = YES;
        }
        
    }
    
    
}

- (void)replayBlogWithContent:(NSString *)content{
    if ([[CommonCode readFromUserD:@"isLogin"]boolValue] == YES) {
        //        DefineWeakSelf;
        //    UserModel *user = [AuthorManager currentLoginUser];
        //
        //    [APPRequest commentBlogWithBlogUserID:@(user.user_id).stringValue blogID:@(self.toReplyBlog.id).stringValue content:content successBlock:^(BlogReplyModel *reply) {
        //        NSMutableArray *replys = [[NSMutableArray alloc] initWithArray:weakSelf.toReplyBlog.list_wt_elite_reply];
        //        [replys addObject:reply];
        //        weakSelf.toReplyBlog.list_wt_elite_reply = replys;
        //        [weakSelf.tableView reloadData];
        //        [weakSelf dissmissKeyboard];
        //    } errorBlock:^(NSURLSessionDataTask *dataTask, FailureResponseModel *failureResponse) {
        //        [SVProgressHUD showErrorWithStatus:failureResponse.errorMessage];
        //    }];
    }
    
}

/**
 *  显示图片浏览器
 *
 *  @param arrPhotos 图片数组
 *  @param idx       当前展示的图片索引
 */
-(void)showPhotos:(NSArray *)arrPhotos selectedIndex:(NSInteger)idx{
    PhotoBrowserController * photoBrowser = [PhotoBrowserController browserWithPhotos:arrPhotos];
    [photoBrowser setCurrentPhotoIndex:idx];
    [self.navigationController pushViewController:photoBrowser animated:YES];
    //        [self.rdv_tabBarController setTabBarHidden:YES animated:YES];
}

- (void)voicePlayWithAnimateTime:(NSInteger )time{
    //设置帧动画的图片数组
    self.voiceImgV.animationImages = [NSArray arrayWithObjects:
                                      [UIImage imageNamed:@"v_anim2"],
                                      [UIImage imageNamed:@"v_anim3"],
                                      [UIImage imageNamed:@"v_anim4"],nil];
    //设置帧动画播放时长
    [self.voiceImgV setAnimationDuration:1.0];
    //设置帧动画播放次数
    [self.voiceImgV setAnimationRepeatCount:time + 0.5];
    
    //如果动画正在播放就不会继续播放下一个动画
    if (self.voiceImgV.isAnimating) {
        return;
    }
    else{
        [self.voiceImgV startAnimating];
    }
}

- (void)skipToUserVCWihtcomponents:(NSDictionary *)components{
    gerenzhuyeVC *gerenzhuye = [gerenzhuyeVC new];
    if ([components[@"user_login"] isEqualToString:ExdangqianUser] && [[CommonCode readFromUserD:@"isLogin"]boolValue] == YES) {
        gerenzhuye.isMypersonalPage = YES;
    }
    else{
        gerenzhuye.isMypersonalPage = NO;
    }
    gerenzhuye.user_nicename = components[@"user_nicename"];
    gerenzhuye.sex = components[@"sex"];
    gerenzhuye.signature = components[@"signature"];
    gerenzhuye.user_login = components[@"user_login"];
    gerenzhuye.user_id = components[@"id"];
    
    
    //头像url处理
    NSString *imgUrl = [NSString stringWithFormat:@"%@",[components[@"avatar"] stringByReplacingOccurrencesOfString:@"\\" withString:@""]];
    NSString *imgUrl1 = [imgUrl stringByReplacingOccurrencesOfString:@"\"" withString:@""];
    NSString *imgUrl2 = [imgUrl1 stringByReplacingOccurrencesOfString:@"thumb:" withString:@""];
    NSString *imgUrl3 = [imgUrl2 stringByReplacingOccurrencesOfString:@"{" withString:@""];
    NSString *imgUrl4 = [imgUrl3 stringByReplacingOccurrencesOfString:@"}" withString:@""];
    gerenzhuye.avatar = imgUrl4;
    gerenzhuye.fan_num = components[@"fan_num"];
    gerenzhuye.guan_num = components[@"guan_num"];
    self.hidesBottomBarWhenPushed = YES;
    [self.navigationController pushViewController:gerenzhuye animated:YES];
    self.hidesBottomBarWhenPushed = YES;
}

- (void)back {
    [self.navigationController popViewControllerAnimated:YES];
}

#pragma mark - Keyboard notifications

- (void)handleWillShowKeyboard:(NSNotification *)notification{
    [self keyboardWillShowHide:notification];
    
}

- (void)handleWillHideKeyboard:(NSNotification *)notification{
    [self keyboardWillShowHide:notification];
}

- (void)keyboardWillShowHide:(NSNotification *)notification{
    
    NSDictionary *userInfo = [notification userInfo];
    NSValue *value = [userInfo objectForKey:UIKeyboardFrameEndUserInfoKey];
    CGFloat keyboardY = value.CGRectValue.origin.y;
    
    NSNumber *duration = [userInfo objectForKey:UIKeyboardAnimationDurationUserInfoKey];
    NSNumber *curve = [userInfo objectForKey:UIKeyboardAnimationCurveUserInfoKey];
    
    // 添加移动动画，使视图跟随键盘移动
    [UIView animateWithDuration:duration.doubleValue animations:^{
        [UIView setAnimationBeginsFromCurrentState:YES];
        [UIView setAnimationCurve:[curve intValue]];
        // keyBoardEndY的坐标包括了状态栏的高度，要减去
        self.toolBarView.center = CGPointMake(self.toolBarView.center.x, keyboardY  - self.toolBarView.bounds.size.height/2.0);
        
    }];
}

#pragma mark - UIButtonAction

- (void)sentCommentAction:(UIButton *)sender {
    
    [self.commentTextField resignFirstResponder];
    if ([self.commentTextStr isEmpty]) {
        [SVProgressHUD showErrorWithStatus:@"评论内容不能为空"];
        [self performSelector:@selector(SVPDismiss) withObject:nil afterDelay:1.0];
    }
    else{
        //TODO:emoji解析上传
        self.commentTextStr = [CommonCode stringContainsEmoji:self.commentTextStr];
        
        NSIndexPath *indexPath;
        NSInteger row;
        if (self.isReplyComment) {
            row = [[CommonCode readFromUserD:@"rowIndex"] integerValue];
        }
        else{
            indexPath = [self.unreadTableview indexPathForCell:_commentCell];
            row = indexPath.row;
        }
        NSString *tuid = @"0";
        NSString *to_comment_id = @"0";
        NSString *iscomment = @"0";
        DefineWeakSelf;
        [SVProgressHUD setDefaultMaskType:SVProgressHUDMaskTypeBlack];
        if (self.isReplyComment) {
            iscomment = @"1";
            to_comment_id = self.infoArr[row][@"id"];
            tuid = self.replyComment_tuid;
        }
        else{
            
            tuid = self.infoArr[row][@"uid"];
            to_comment_id = self.infoArr[row][@"id"];
        }
        switch (self.pageSource) {
            case 1:{
                if ([self.infoArr[indexPath.row][@"post_id"] isEqualToString:@"0"]) {
                    [NetWorkTool addfriendDynamicsPingLunWithaccessToken:AvatarAccessToken
                                                                 post_id:self.infoArr[indexPath.row][@"post_id"]
                                                              comment_id:to_comment_id
                                                                  to_uid:tuid
                                                                 content:self.commentTextStr
                                                                  sccess:^(NSDictionary *responseObject) {
                                                                      if ([[NSString stringWithFormat:@"%@",responseObject[@"status"]] isEqualToString:@"0"]){
                                                                          
                                                                          [SVProgressHUD showErrorWithStatus:responseObject[@"msg"]];
                                                                          [self performSelector:@selector(SVPDismiss) withObject:nil afterDelay:1.0];
                                                                      }
                                                                      else{
                                                                          [self.toolBarView setHidden:YES];
                                                                          [self.view endEditing:YES];
                                                                          self.commentTextStr = @"";
                                                                          self.commentTextField.text = @"";
                                                                          [weakSelf loadData];
                                                                          
                                                                          [SVProgressHUD showSuccessWithStatus:@"评论成功"];
                                                                          [self performSelector:@selector(SVPDismiss) withObject:nil afterDelay:1.0];
                                                                      }
                                                                  } failure:^(NSError *error) {
                                                                      [SVProgressHUD dismiss]
                                                                      ;                                                                  NSLog(@"%@",error);
                                                                  }];
                }
                else{
                    [NetWorkTool postPaoGuoXinWenPingLunWithaccessToken:AvatarAccessToken
                                                              andto_uid:tuid
                                                             andpost_id:self.infoArr[indexPath.row][@"post_id"]
                                                          andcomment_id:to_comment_id
                                                          andpost_table:@"posts"
                                                             andcontent:self.commentTextStr
                                                                 sccess:^(NSDictionary *responseObject) {
                                                                     
                                                                     if ([[NSString stringWithFormat:@"%@",responseObject[@"status"]] isEqualToString:@"0"]){
                                                                         
                                                                         [SVProgressHUD showErrorWithStatus:responseObject[@"msg"]];
                                                                         [self performSelector:@selector(SVPDismiss) withObject:nil afterDelay:1.0];
                                                                     }
                                                                     else{
                                                                         [self.toolBarView setHidden:YES];
                                                                         [self.view endEditing:YES];
                                                                         self.commentTextStr = @"";
                                                                         self.commentTextField.text = @"";
                                                                         [weakSelf loadData];
                                                                         
                                                                         [SVProgressHUD showSuccessWithStatus:@"评论成功"];
                                                                         [self performSelector:@selector(SVPDismiss) withObject:nil afterDelay:1.0];
                                                                     }
                                                                     
                                                                 } failure:^(NSError *error) {
                                                                     //
                                                                     NSLog(@"%@",error);
                                                                 }];
                }
                
            }
                break;
            case 2:{
                [NetWorkTool addfeedBackWithaccessToken:AvatarAccessToken
                                                   tuid:tuid
                                          to_comment_id:to_comment_id
                                                comment:self.commentTextStr
                                                 images:nil
                                             is_comment:iscomment
                                                 sccess:^(NSDictionary *responseObject) {
                                                     if ([responseObject[@"status"] integerValue] == 1) {
                                                         NSLog(@"blogArray==%@",self.infoArr[row]);
                                                         [self.toolBarView setHidden:YES];
                                                         [self.view endEditing:YES];
                                                         //                if ([self.blogArray[indexPath.row][@"child_comment"] count]) {
                                                         //
                                                         //                }
                                                         //                else{
                                                         //                    NSArray *commentArr = @[@{@"id":@"123"}];
                                                         //                    NSMutableDictionary *commentDic = [NSMutableDictionary dictionary];
                                                         //                    [commentDic setValue:self.blogArray[indexPath.row][@"user"] forKey:@"user"];
                                                         //
                                                         //                    NSArray *arr = [NSArray arrayWithObject:commentDic];
                                                         //                    [self.blogArray[indexPath.row] setObject: @"1" forKey:@"child_comment"];
                                                         //
                                                         //
                                                         //                }
                                                         //TODO:重新计算行高
                                                         
                                                         self.commentTextStr = @"";
                                                         self.commentTextField.text = @"";
                                                         [weakSelf loadData];
                                                         [SVProgressHUD showSuccessWithStatus:@"评论成功"];
                                                         [self performSelector:@selector(SVPDismiss) withObject:nil afterDelay:1.0];
                                                     }
                                                     else{
                                                         [SVProgressHUD showErrorWithStatus:[NSString stringWithFormat:@"%@",responseObject[@"msg"]]];
                                                         [self performSelector:@selector(SVPDismiss) withObject:nil afterDelay:1.0];
                                                     }
                                                     
                                                 } failure:^(NSError *error) {
                                                     //
                                                     [SVProgressHUD dismiss];
                                                     [self.toolBarView setHidden:YES];
                                                     [self.view endEditing:YES];
                                                     NSLog(@"%@",error);
                                                     
                                                 }];
            }
                break;
                
            default:
                break;
        }
    
    }
}


#pragma mark - UIScrollViewDelegate
    
- (void)scrollViewDidScroll:(UIScrollView *)scrollView{
    [self.toolBarView setHidden:YES];
    [self.commentTextField resignFirstResponder];
}

#pragma mark - UITextFieldDelegate

- (BOOL)textFieldShouldEndEditing:(UITextField *)textField{
    self.commentTextStr = textField.text;
    return YES;
}

#pragma mark - TTTAttributedLabelDelegate

- (void)attributedLabel:(TTTAttributedLabel *)label
didSelectLinkWithTransitInformation:(NSDictionary *)components {
    
    if ([components[@"isComment"] isEqualToString:@"1"]) {
        self.replyComment_tuid = components[@"comment_tuid"];
        self.toolBarView.frame = CGRectMake(0, SCREEN_HEIGHT, SCREEN_WIDTH, 46);
        [[UIApplication sharedApplication].keyWindow addSubview:self.toolBarView];
        [self.toolBarView setHidden:NO];
        [self.commentTextField becomeFirstResponder];
        self.isReplyComment = YES;
        [self.commentTextField setPlaceholder:[NSString stringWithFormat:@"@%@",components[@"user_nicename"]]];
        [CommonCode writeToUserD:components[@"rowIndex"] andKey:@"rowIndex"];
    }
    else{
        gerenzhuyeVC *gerenzhuye = [gerenzhuyeVC new];
        if ([components[@"user_login"] isEqualToString:ExdangqianUser] && [[CommonCode readFromUserD:@"isLogin"]boolValue] == YES) {
            gerenzhuye.isMypersonalPage = YES;
        }
        else{
            gerenzhuye.isMypersonalPage = NO;
        }
        gerenzhuye.user_nicename = components[@"user_nicename"];
        gerenzhuye.sex = components[@"sex"];
        gerenzhuye.signature = components[@"signature"];
        gerenzhuye.user_login = components[@"user_login"];
        gerenzhuye.avatar = components[@"avatar"];
        gerenzhuye.fan_num = components[@"fan_num"];
        gerenzhuye.guan_num = components[@"guan_num"];
        gerenzhuye.user_id = components[@"id"];
        self.hidesBottomBarWhenPushed=YES;
        [self.navigationController pushViewController:gerenzhuye animated:YES];
        self.hidesBottomBarWhenPushed=YES;
    }
    
}


#pragma mark - UITableViewDelegate

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.infoArr.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    BlogTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:BlogTableViewCellID];
    
    NSMutableDictionary *blog = [self.infoArr firstObject];
    switch (self.pageSource) {
        case 1:
            [cell updateCellWithBlog:blog andisFeebackBlog:NO andisUnreadMessage:YES];
            break;
        case 2:
            [cell updateCellWithBlog:blog andisFeebackBlog:YES andisUnreadMessage:NO];
            break;
            
        default:
            break;
    }
    
    [cell.nameLabe setDelegate:self];
    [cell.commentLabel setDelegate:self];
    NSDictionary *user = self.infoArr[indexPath.row][@"user"];
    NSRange nameRange = NSMakeRange(0, [user[@"user_nicename"] length]);
    [cell.nameLabe setLinkAttributes:@{NSForegroundColorAttributeName : gMainColor,NSFontAttributeName :gFontMajor16}];
    [cell.nameLabe setActiveLinkAttributes:@{NSForegroundColorAttributeName : gMainColor,NSFontAttributeName :gFontMajor16}];
    [cell.nameLabe addLinkToTransitInformation:user withRange:nameRange];
    NSString *CommenStr = @"";
    if ([self.infoArr[indexPath.row][@"child_comment"] isKindOfClass:[NSArray class]]) {
        for (int i = 0 ; i < [blog[@"child_comment"] count]; i ++) {
            NSMutableDictionary *commentDic = blog[@"child_comment"][i];
            NSMutableDictionary *user = commentDic[@"user"];
            NSDictionary *to_user = commentDic[@"to_user"];
            NSString *lastString =  @"\n";
            if (i == [blog[@"child_comment"] count] - 1) {
                lastString = @"";
            }
            NSString *content = @"";
            if ( (self.pageSource == 2) ? [commentDic[@"is_comment"] isEqualToString:@"0"] : ![[to_user allKeys] containsObject:@"id"]) {
                content = [NSString stringWithFormat:@"%@:%@%@", [user[@"user_nicename"] length] ? user[@"user_nicename"] : user[@"user_login"], commentDic[@"comment"], lastString];
                if ([content rangeOfString:@"[e1]"].location != NSNotFound && [content rangeOfString:@"[/e1]"].location != NSNotFound){
                    content = [CommonCode jiemiEmoji:content];
                }
            }
            else if ((self.pageSource == 2) ? [commentDic[@"is_comment"] isEqualToString:@"1"] : [[to_user allKeys] containsObject:@"id"]){
                content = [NSString stringWithFormat:@"%@回复%@:%@%@", user[@"user_nicename"],[to_user[@"user_nicename"] length]? to_user[@"user_nicename"]:to_user[@"user_login"], commentDic[@"comment"], lastString];
                if ([content rangeOfString:@"[e1]"].location != NSNotFound && [content rangeOfString:@"[/e1]"].location != NSNotFound){
                    content = [CommonCode jiemiEmoji:content];
                }
            }
            CommenStr = [CommenStr stringByAppendingString:content];
            
            NSRange user1 = NSMakeRange(([CommenStr length] - [content length]), [user[@"user_nicename"] length] ? [user[@"user_nicename"] length] : [user[@"user_login"] length]);
            [cell.commentLabel setLinkAttributes:@{NSForegroundColorAttributeName : gMainColor,NSFontAttributeName : gFontMain13}];
            [cell.commentLabel setActiveLinkAttributes:@{NSForegroundColorAttributeName : gMainColor,NSFontAttributeName : gFontMain13}];
            [cell.commentLabel addLinkToTransitInformation:user withRange:user1];
            NSRange comment;
            if ((self.pageSource == 2) ? [commentDic[@"is_comment"] isEqualToString:@"1"] : [[to_user allKeys] containsObject:@"id"]) {
                NSRange user2 = NSMakeRange(([CommenStr length] - [content length] +([user[@"user_nicename"] length] ? [user[@"user_nicename"] length] : [user[@"user_login"] length] ) + 2), [to_user[@"user_nicename"] length] ? [to_user[@"user_nicename"] length] : [to_user[@"user_login"] length]);
                [cell.commentLabel setLinkAttributes:@{NSForegroundColorAttributeName : gMainColor,NSFontAttributeName : gFontMain13}];
                [cell.commentLabel setActiveLinkAttributes:@{NSForegroundColorAttributeName : gMainColor,NSFontAttributeName : gFontMain13}];
                [cell.commentLabel addLinkToTransitInformation:to_user withRange:user2];
                comment = NSMakeRange(([CommenStr length] - [content length] + [user[@"user_nicename"] length] + 2 + ([to_user[@"user_nicename"] length] ? [to_user[@"user_nicename"] length] : [to_user[@"user_login"] length]))  , [content length] - ([user[@"user_nicename"] length] ? [user[@"user_nicename"] length] : [user[@"user_login"] length]) - 2 - ([to_user[@"user_nicename"] length] ? [to_user[@"user_nicename"] length] : [to_user[@"user_login"] length]));
                
            }else {
                comment = NSMakeRange(([CommenStr length] - [content length] + ([user[@"user_nicename"] length] ? [user[@"user_nicename"] length] : [user[@"user_login"] length] )), [content length] -([user[@"user_nicename"] length] ? [user[@"user_nicename"] length] : [user[@"user_login"] length] ));
            }
            
            [cell.commentLabel setLinkAttributes:@{NSForegroundColorAttributeName : [UIColor blackColor],NSFontAttributeName : gFontMain13}];
            NSMutableDictionary *CommentInformationDic = [NSMutableDictionary new];
            CommentInformationDic = [user mutableCopy];
            [CommentInformationDic setObject:@"1" forKey:@"isComment"];
            [CommentInformationDic setObject:[NSString stringWithFormat:@"%ld",(long)indexPath.row] forKey:@"rowIndex"];
            [CommonCode writeToUserD:[NSString stringWithFormat:@"%ld",(long)indexPath.row] andKey:@"rowIndex"];
            [CommentInformationDic setObject:commentDic[@"uid"] forKey:@"comment_tuid"];
            [cell.commentLabel setActiveLinkAttributes:@{NSForegroundColorAttributeName : [UIColor blackColor],NSFontAttributeName : gFontMain13}];
            [cell.commentLabel addLinkToTransitInformation:CommentInformationDic withRange:comment];
        }
        cell.commentLabel.lineSpacing = 15;
        
    }
    
    DefineWeakSelf;
        [cell setClickHeadView:^(BlogTableViewCell *cell) {
            [weakSelf skipToUserVCWihtcomponents:self.infoArr[indexPath.row][@"user"]];
        }];
    [cell setAddFav:^(BlogTableViewCell *cell , int iszan) {
        [weakSelf addFavInTableViewCell:cell andIszan:iszan];
    }];
    [cell setAddComment:^(BlogTableViewCell *cell) {
        [weakSelf addCommentInTableViewCell:cell];
    }];
    [cell setDeleteBlog:^(BlogTableViewCell *cell) {
        [weakSelf deleteBlogIntableViewCell:cell];
    }];
    [cell setPlayVoice:^(BlogTableViewCell *cell) {
        [weakSelf playVoiceInTableViewCell:cell];
    }];
    
    [cell.photosImageView setTapImageBlock:^(MultiImageView *view, UIImageView *imgv, NSInteger idx) {
        [weakSelf showPhotos:view.images selectedIndex:idx];
    }];
    
    return cell;
    
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    return [tableView fd_heightForCellWithIdentifier:BlogTableViewCellID cacheByIndexPath:indexPath configuration:^(id cell) {
        NSMutableDictionary *blog = [self.infoArr firstObject];
        switch (self.pageSource) {
            case 1:
                [cell updateCellWithBlog:blog andisFeebackBlog:NO andisUnreadMessage:YES];
                break;
            case 2:
                [cell updateCellWithBlog:blog andisFeebackBlog:YES andisUnreadMessage:NO];
                break;
                
            default:
                break;
        }
    }];
    
//    return [tableView fd_heightForCellWithIdentifier:BlogTableViewCellID cacheByKey:[NSString stringWithFormat:@"%ld",(long)indexPath.row] configuration:^(id cell) {
//        NSMutableDictionary *blog = [self.infoArr firstObject];
//        [cell updateCellWithBlog:blog andisFeebackBlog:NO];
//    }];
}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    if ([self.infoArr[indexPath.row][@"post_id"] isEqualToString:@"0"]||self.infoArr[indexPath.row][@"post_id"] == [NSNull null]||self.infoArr[indexPath.row][@"post_id"] == nil) {
        return;
    }
    else{
        //TODO:跳转新闻详情
        if ([[CommonCode readFromUserD:@"dangqianbofangxinwenID"] isEqualToString:self.infoArr[indexPath.row][@"post"][@"id"]]){
            self.hidesBottomBarWhenPushed = YES;
            [self.navigationController.navigationBar setHidden:YES];
            [self.navigationController pushViewController:[bofangVC shareInstance] animated:YES];
            [[bofangVC shareInstance].tableView reloadData];
            self.hidesBottomBarWhenPushed = YES;
            if ([bofangVC shareInstance].isPlay) {
                
            }
            else{
                [[bofangVC shareInstance] doplay2];
            }
        }
        else{
            [bofangVC shareInstance].newsModel.jiemuID = self.infoArr[indexPath.row][@"post"][@"id"];
            [bofangVC shareInstance].newsModel.Titlejiemu = self.infoArr[indexPath.row][@"post"][@"post_title"];
            [bofangVC shareInstance].newsModel.RiQijiemu = self.infoArr[indexPath.row][@"post"][@"post_date"];
            [bofangVC shareInstance].newsModel.ImgStrjiemu = self.infoArr[indexPath.row][@"post"][@"smeta"];
            [bofangVC shareInstance].newsModel.post_lai = self.infoArr[indexPath.row][@"post"][@"post_lai"];
            [bofangVC shareInstance].newsModel.post_news = self.infoArr[indexPath.row][@"post"][@"post_news"];
            //获取主播信息
            [[NSNotificationCenter defaultCenter] postNotificationName:@"getActInfoNotification" object:self.infoArr[indexPath.row][@"post"][@"post_news"]];
            [bofangVC shareInstance].newsModel.jiemuName = nil;
            [bofangVC shareInstance].newsModel.jiemuDescription = nil;
            [bofangVC shareInstance].newsModel.jiemuImages = nil;
            [bofangVC shareInstance].newsModel.jiemuFan_num = nil;
            [bofangVC shareInstance].newsModel.jiemuMessage_num = nil;
            [bofangVC shareInstance].newsModel.jiemuIs_fan = nil;
            [bofangVC shareInstance].newsModel.post_mp = self.infoArr[indexPath.row][@"post"][@"post_mp"];
            [bofangVC shareInstance].newsModel.post_time = self.infoArr[indexPath.row][@"post"][@"post_time"];
            [bofangVC shareInstance].iszhuboxiangqing = NO;
            [bofangVC shareInstance].newsModel.post_keywords = self.infoArr[indexPath.row][@"post"][@"post_keywords"];
            [bofangVC shareInstance].newsModel.url = self.infoArr[indexPath.row][@"post"][@"url"];
            if ([self.infoArr[indexPath.row][@"post"][@"post_time"] intValue] / 1000 / 60)
            {
                if ([self.infoArr[indexPath.row][@"post"][@"post_time"] intValue] / 1000 / 60 > 9)
                {
                    [bofangVC shareInstance].yinpinzongTime.text = [NSString stringWithFormat:@"%d:%d",[self.infoArr[indexPath.row][@"post"][@"post_time"] intValue] / 1000 / 60,[self.infoArr[indexPath.row][@"post"][@"post_time"] intValue] / 1000 % 60];
                }
                else{
                    if ([self.infoArr[indexPath.row][@"post"][@"post_time"] intValue] / 1000 % 60 < 10)
                    {
                        [bofangVC shareInstance].yinpinzongTime.text = [NSString stringWithFormat:@"0%d:0%d",[self.infoArr[indexPath.row][@"post"][@"post_time"] intValue] / 1000 / 60,[self.infoArr[indexPath.row][@"post"][@"post_time"] intValue] / 1000 % 60];
                    }else
                    {
                        [bofangVC shareInstance].yinpinzongTime.text = [NSString stringWithFormat:@"0%d:%d",[self.infoArr[indexPath.row][@"post"][@"post_time"] intValue] / 1000 / 60,[self.infoArr[indexPath.row][@"post"][@"post_time"] intValue] / 1000 % 60];
                    }
                }
            }else
            {
                if ([self.infoArr[indexPath.row][@"post"][@"post_time"] intValue] / 1000 > 10)
                {
                    [bofangVC shareInstance].yinpinzongTime.text = [NSString stringWithFormat:@"00:%d",[self.infoArr[indexPath.row][@"post"][@"post_time"] intValue] / 1000 % 60];
                }else
                {
                    [bofangVC shareInstance].yinpinzongTime.text = [NSString stringWithFormat:@"00:0%d",[self.infoArr[indexPath.row][@"post"][@"post_time"] intValue] / 1000 % 60];
                }
            }
            ExcurrentNumber = (int)indexPath.row;
            NSString *imgUrl = [NSString stringWithFormat:@"%@",[self.infoArr[indexPath.row][@"post"][@"smeta"] stringByReplacingOccurrencesOfString:@"\\" withString:@""]];
            NSString *imgUrl1 = [imgUrl stringByReplacingOccurrencesOfString:@"\"" withString:@""];
            NSString *imgUrl2 = [imgUrl1 stringByReplacingOccurrencesOfString:@"thumb:" withString:@""];
            NSString *imgUrl3 = [imgUrl2 stringByReplacingOccurrencesOfString:@"{" withString:@""];
            NSString *imgUrl4 = [imgUrl3 stringByReplacingOccurrencesOfString:@"}" withString:@""];
            [bofangVC shareInstance].newsModel.ImgStrjiemu = imgUrl4;
            [bofangVC shareInstance].newsModel.ZhengWenjiemu = self.infoArr[indexPath.row][@"post"][@"post_excerpt"];
            [bofangVC shareInstance].newsModel.praisenum = self.infoArr[indexPath.row][@"post"][@"praisenum"];
            [[bofangVC shareInstance].tableView reloadData];
            //        Explayer = [[AVPlayer alloc]initWithPlayerItem:[[AVPlayerItem alloc]initWithURL:[NSURL URLWithString:arr[indexPath.row][@"post_mp"]]]];
            [Explayer replaceCurrentItemWithPlayerItem:[[AVPlayerItem alloc]initWithURL:[NSURL URLWithString:self.infoArr[indexPath.row][@"post"][@"post_mp"]]]];
            if ([bofangVC shareInstance].isPlay || ExIsKaiShiBoFang == NO) {
                
            }
            else{
                [[bofangVC shareInstance] doplay2];
            }
            ExisRigester = YES;
            ExIsKaiShiBoFang = YES;
            ExwhichBoFangYeMianStr = @"shouyebofang";
            self.hidesBottomBarWhenPushed = YES;
            [self.navigationController.navigationBar setHidden:YES];
            [self.navigationController pushViewController:[bofangVC shareInstance] animated:YES];
            [[bofangVC shareInstance].tableView reloadData];
            //        [self.navigationController.navigationBar setHidden:NO];
            self.hidesBottomBarWhenPushed = YES;
            [[NSNotificationCenter defaultCenter] postNotificationName:@"yuanpanzhuan" object:nil];
            [[NSNotificationCenter defaultCenter] postNotificationName:@"qiehuanxinwen" object:nil];
            //            [CommonCode writeToUserD:self.blogArray andKey:@"zhuyeliebiao"];
            [CommonCode writeToUserD:self.infoArr[indexPath.row][@"post"][@"id"] andKey:@"dangqianbofangxinwenID"];
            if ([[CommonCode readFromUserD:@"yitingguoxinwenID"] isKindOfClass:[NSArray class]])
            {
                NSMutableArray *yitingguoArr = [NSMutableArray arrayWithArray:[CommonCode readFromUserD:@"yitingguoxinwenID"]];
                [yitingguoArr addObject:self.infoArr[indexPath.row][@"post"][@"id"]];
                [CommonCode writeToUserD:yitingguoArr andKey:@"yitingguoxinwenID"];
            }else
            {
                NSMutableArray *yitingguoArr = [NSMutableArray array];
                [yitingguoArr addObject:self.infoArr[indexPath.row][@"post"][@"id"]];
                [CommonCode writeToUserD:yitingguoArr andKey:@"yitingguoxinwenID"];
            }
            [tableView reloadData];
        }
        
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
