//
//  BlogTableViewController.m
//  Broker
//
//  Created by Eric Wang on 15/10/13.
//  Copyright (c) 2015年 Eric. All rights reserved.
//

#import "BlogViewController.h"

#import "BlogTableViewCell.h"
#import "MJRefresh.h"
#import "UITableView+FDTemplateLayoutCell.h"
#import "UITableView+FDKeyedHeightCache.h"
#import "AppDelegate.h"
#import "UIBarButtonItem+Utility.h"
#import "LoginNavC.h"
#import "LoginVC.h"
#import "NewQAController.h"
#import "AFHTTPRequestOperationManager.h"
#import "UIView+AnimationOptionsForCurve.h"
#import "PhotoBrowserController.h"
#import "UIActionSheet+MKBlockAdditions.h"
#import "TTTAttributedLabel.h"
#import "gerenzhuyeVC.h"
#import "bofangVC.h"
#import "FMActionSheet.h"
#import "UIColor+HexString.h"
#import "pinglunyeVC.h"
#import "UnreadMessageViewController.h"

@interface BlogViewController ()<NewQAControllerDelegate,UITextViewDelegate,UITextFieldDelegate,TTTAttributedLabelDelegate,UIGestureRecognizerDelegate,UITableViewDelegate,UITableViewDataSource,AVAudioPlayerDelegate>

@property (strong, nonatomic) UITableView *blogTableview;
@property (assign, nonatomic) NSUInteger page;
@property (strong, nonatomic) NSMutableArray *blogArray;
@property (weak, nonatomic) NSMutableDictionary *toReplyBlog;
@property (assign, nonatomic) BOOL isMyself;

@property (strong, nonatomic) UIView *toolBarView;
@property (strong, nonatomic) UITextField *commentTextField;
@property (strong, nonatomic) UIButton *sentCommentButton;
@property (strong, nonatomic) NSString *commentTextStr;
@property (strong, nonatomic) UITableViewCell *commentCell;
@property (assign, nonatomic) BOOL isReplyComment;
@property (strong, nonatomic) NSString *replyComment_tuid;

@property (strong, nonatomic) NSMutableString *mp3_url;
@property (strong, nonatomic) NSMutableString *playtime;

@property (strong, nonatomic) UIButton *newMessageButton;
@property (strong, nonatomic) UIImageView *newMessageImage;
@property (strong, nonatomic) UILabel *newMessageTipsLabel;
//mp3格式的语音播放器
@property (strong, nonatomic) AVPlayer *voicePlayer;
//非mp3格式的语音播放器
@property (strong, nonatomic) AVAudioPlayer *player;

@property (strong, nonatomic) AVAudioSession *session;
@property (strong, nonatomic) UIImageView *voiceImgV;

@property (assign, nonatomic) BOOL isPlaying;


@end

@implementation BlogViewController
- (void)viewDidLoad{
    [super viewDidLoad];
//    self.navBarBgAlpha = @"0.0";
    [self setupData];
    [self setupView];
}
- (void)setupData{
    self.blogArray = [NSMutableArray new];
    self.isReplyComment = NO;
    self.replyComment_tuid = @"0";
    self.mp3_url = nil;
    self.playtime = nil;
    _isPlaying = NO;
}

- (void)setupView{
    [self enableAutoBack];
    self.title = self.isFeedbackVC ? @"意见反馈" : @"听友圈";
    self.navigationController.navigationBar.titleTextAttributes = @{NSForegroundColorAttributeName: [UIColor blackColor],
                                                                    NSFontAttributeName : [UIFont boldSystemFontOfSize:18]};
    [self.view addSubview:self.blogTableview];
    UIButton *AddNewBlogImage = [UIButton buttonWithType:UIButtonTypeCustom];
    [AddNewBlogImage setFrame:CGRectMake(0, 0, 44, 30)];
    AddNewBlogImage.contentEdgeInsets = UIEdgeInsetsMake(0, 20, 0, 0);
    [AddNewBlogImage setImage:[UIImage imageNamed:@"iconfont_photo_gray"] forState:UIControlStateNormal];
    [AddNewBlogImage addTarget:self action:@selector(tapAddNewBlog) forControlEvents:UIControlEventTouchUpInside];
    AddNewBlogImage.accessibilityLabel = self.isFeedbackVC ? @"新建意见反馈" : @"新建听友圈";
    UILongPressGestureRecognizer *LongPress = [[UILongPressGestureRecognizer alloc]initWithTarget:self action:@selector(actionAddNewBlog:)];
    [AddNewBlogImage addGestureRecognizer:LongPress];
    UIBarButtonItem *barItem = [[UIBarButtonItem alloc] initWithCustomView:AddNewBlogImage];
    self.navigationItem.rightBarButtonItem = barItem;
    
    UIButton *backImage = [UIButton buttonWithType:UIButtonTypeCustom];
    [backImage setFrame:CGRectMake(0, 0, 44, 30)];
    backImage.contentEdgeInsets = UIEdgeInsetsMake(0, 0, 0, 20);
    [backImage setImage:[UIImage imageNamed:@"back"] forState:UIControlStateNormal];
    [backImage addTarget:self action:@selector(back) forControlEvents:UIControlEventTouchUpInside];
    
    UIBarButtonItem *backItem = [[UIBarButtonItem alloc] initWithCustomView:backImage];
    self.navigationItem.leftBarButtonItem = backItem;
    
    UISwipeGestureRecognizer *rightSwipe = [[UISwipeGestureRecognizer alloc]initWithTarget:self action:@selector(back)];
    [rightSwipe setDirection:UISwipeGestureRecognizerDirectionRight];
    [self.blogTableview addGestureRecognizer:rightSwipe];
    
    [self.view addSubview:self.toolBarView];
    [self.toolBarView setHidden:YES];
    self.commentTextStr = @"";
    
    self.blogTableview.tableHeaderView =  [[UIView alloc]initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, 0)];
    [self.blogTableview.tableHeaderView setBackgroundColor:[UIColor whiteColor]];
    [self.newMessageButton setHidden:YES];
    [self.blogTableview.tableHeaderView addSubview:self.newMessageButton];
    
    self.blogTableview.tableFooterView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, 1)];
    self.blogTableview.separatorStyle = UITableViewCellSeparatorStyleNone;
    DefineWeakSelf;;
    self.blogTableview.mj_header = [MJRefreshNormalHeader headerWithRefreshingBlock:^{
        weakSelf.page = 1;
        [weakSelf loadData];
    }];
    self.blogTableview.mj_footer = [MJRefreshAutoNormalFooter footerWithRefreshingBlock:^{
        weakSelf.page ++;
        [weakSelf loadData];
    }];
    self.blogTableview.mj_footer.automaticallyHidden = YES;
    [self.blogTableview.mj_header beginRefreshing];
    self.automaticallyAdjustsScrollViewInsets = NO;
    self.navigationController.navigationBar.translucent = NO;
    
    
    ExisRigester = NO;
    //AudioSession负责应用音频的设置，比如支不支持后台，打断等等
    NSError *error;
    //设置音频会话
    self.session = [AVAudioSession sharedInstance];
    //AVAudioSessionCategoryPlayback一般用于支持后台播放
    [self.session setCategory:AVAudioSessionCategoryPlayback error:&error];
    //激活会话
    [self.session setActive:YES error:&error];
    //添加观察者，用来监视播放器的状态变化
    [self.voicePlayer addObserver:self forKeyPath:@"statu" options:NSKeyValueObservingOptionNew context:nil];
    //添加观察者，用来监听播放器的缓冲进度loadedTimeRanges属性
//    [Explayer addObserver:self forKeyPath:@"loadedTimeRange" options:NSKeyValueObservingOptionNew context:nil];
    //播放完毕后发出通知
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(voicePlayEnd:) name:AVPlayerItemDidPlayToEndTimeNotification object:nil];
    
}

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    [self.navigationController setNavigationBarHidden:NO animated:YES];
    self.navigationController.navigationBar.titleTextAttributes = @{NSForegroundColorAttributeName: [UIColor blackColor],
                                                                    NSFontAttributeName : [UIFont boldSystemFontOfSize:18]};
    self.hidesBottomBarWhenPushed = YES;
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(handleWillShowKeyboard:)
                                                 name:UIKeyboardWillShowNotification
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(handleWillHideKeyboard:)
                                                 name:UIKeyboardWillHideNotification
                                               object:nil];
    
    //未读消息处理
    if (self.isFeedbackVC) {
        NSArray *feedback = [CommonCode readFromUserD:FEEDBACKFORMEDATAKEY];
        if ([feedback count] && [[CommonCode readFromUserD:FEEDBACKYMESSAGEREAD] isEqualToString:@"NO"]) {
            self.blogTableview.tableHeaderView =  [[UIView alloc]initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, 50)];
            [self.newMessageButton setHidden:NO];
            [self.blogTableview.tableHeaderView addSubview:self.newMessageButton];
            [self.newMessageTipsLabel setText:[NSString stringWithFormat:@"%ld则新消息",[feedback count]]];
            //头像url处理
            if ([NEWSSEMTPHOTOURL([feedback firstObject][@"user"][@"avatar"])  rangeOfString:@"http"].location != NSNotFound){
                [self.newMessageImage sd_setImageWithURL:[NSURL URLWithString:NEWSSEMTPHOTOURL([feedback firstObject][@"user"][@"avatar"])] placeholderImage:AvatarPlaceHolderImage];
            }
            else{
                NSString *str = USERPHOTOHTTPSTRING(NEWSSEMTPHOTOURL([feedback firstObject][@"user"][@"avatar"]));
                [self.newMessageImage sd_setImageWithURL:[NSURL URLWithString:str] placeholderImage:AvatarPlaceHolderImage];
            }
        }
        else{
            self.blogTableview.tableHeaderView =  [[UIView alloc]initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, 0)];
            [self.newMessageButton setHidden:YES];
        }
    }
    else{
        NSArray *newprompt = [CommonCode readFromUserD:NEWPROMPTFORMEDATAKEY];
        if ([newprompt count] && [[CommonCode readFromUserD:TINGYOUQUANMESSAGEREAD] isEqualToString:@"NO"]) {
            self.blogTableview.tableHeaderView =  [[UIView alloc]initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, 50)];
            [self.newMessageButton setHidden:NO];
            [self.blogTableview.tableHeaderView addSubview:self.newMessageButton];
            [self.newMessageTipsLabel setText:[NSString stringWithFormat:@"%ld则新消息",[newprompt count]]];
            //头像url处理
            if ([NEWSSEMTPHOTOURL([newprompt firstObject][@"user"][@"avatar"])  rangeOfString:@"http"].location != NSNotFound){
                [self.newMessageImage sd_setImageWithURL:[NSURL URLWithString:NEWSSEMTPHOTOURL([newprompt firstObject][@"user"][@"avatar"])] placeholderImage:AvatarPlaceHolderImage];
            }
            else{
                NSString *str = USERPHOTOHTTPSTRING(NEWSSEMTPHOTOURL([newprompt firstObject][@"user"][@"avatar"]));
                [self.newMessageImage sd_setImageWithURL:[NSURL URLWithString:str] placeholderImage:AvatarPlaceHolderImage];
            }
        }
        else{
            self.blogTableview.tableHeaderView =  [[UIView alloc]initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, 0)];
            [self.newMessageButton setHidden:YES];
        }
    }
    
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    [IQKeyboardManager sharedManager].enable = NO;
}

- (void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self name:AVPlayerItemDidPlayToEndTimeNotification object:nil];
    [CommonCode writeToUserD:@"NO" andKey:TINGYOUQUANBOFANGWANBI];
    
    [IQKeyboardManager sharedManager].enable = NO;
    [self dissmissKeyboard];
    [self.voiceImgV removeFromSuperview];
    [self.toolBarView setHidden:YES];
    [self.commentTextField resignFirstResponder];
    [self.player stop];
    [self.voicePlayer pause];
}

- (void)viewDidDisappear:(BOOL)animated{
    [super viewDidDisappear:animated];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillHideNotification object:nil];
}
#pragma mark - Getter

- (UITableView *)blogTableview {
    if (!_blogTableview) {
        _blogTableview = [[UITableView alloc]initWithFrame:CGRectMake(0, 64, SCREEN_WIDTH, SCREEN_HEIGHT - 64) style:UITableViewStylePlain];
        [_blogTableview setDelegate:self];
        [_blogTableview setDataSource:self];
        _blogTableview.tableFooterView =  [UIView new];
//        [_blogTableview setContentOffset:CGPointMake(SCREEN_WIDTH, SCREEN_HEIGHT - 64)];
//        [_blogTableview setContentSize:CGSizeMake(SCREEN_WIDTH, SCREEN_HEIGHT - 64)];
//        [_blogTableview setContentInset:UIEdgeInsetsMake(0, 0, 0, 150)];
    }
    return  _blogTableview;
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

-(UIButton *)newMessageButton{
    if (!_newMessageButton) {
        _newMessageButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [_newMessageButton setFrame:CGRectMake((SCREEN_WIDTH - 170) / 2, 5, 170, 40)];
        [_newMessageButton.layer setMasksToBounds:YES];
        [_newMessageButton.layer setCornerRadius:5.0];
        [_newMessageButton setBackgroundColor:[UIColor grayColor]];
        [_newMessageButton addSubview:self.newMessageImage];
        [_newMessageButton addSubview:self.newMessageTipsLabel];
        UIImageView *arrow = [[UIImageView alloc]initWithFrame:CGRectMake(170 - 30, 10, 20, 20)];
        [arrow setImage:[UIImage imageNamed:@"faxianjiantou"]];
        [_newMessageButton addSubview:arrow];
        [_newMessageButton addTarget:self action:@selector(newMessageAction:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _newMessageButton;
}

- (UIImageView *)newMessageImage {
    if (!_newMessageImage) {
        _newMessageImage = [[UIImageView alloc]initWithFrame:CGRectMake(5, 5, 30, 30)];
        [_newMessageImage.layer setMasksToBounds:YES];
        [_newMessageImage.layer setCornerRadius:5.0];
    }
    return _newMessageImage;
}

-(UILabel *)newMessageTipsLabel {
    if (!_newMessageTipsLabel) {
        _newMessageTipsLabel = [[UILabel alloc]initWithFrame:CGRectMake(40, 0, 170 - 80, 40)];
        [_newMessageTipsLabel setTextAlignment:NSTextAlignmentCenter];
        [_newMessageTipsLabel setTextColor:[UIColor whiteColor]];
        [_newMessageTipsLabel setFont:gFontMain15];
    }
    return _newMessageTipsLabel;
}

- (AVPlayer *)voicePlayer {
    if (!_voicePlayer) {
        _voicePlayer = [[AVPlayer alloc]init];
    }
    return _voicePlayer;
}

-(UIImageView *)voiceImgV{
    if ( _voiceImgV == nil) {
        _voiceImgV = [[UIImageView alloc]initWithFrame:CGRectMake(10, 10, 20, 20)];
        [_voiceImgV setImage:[UIImage imageNamed:@"v_anim4"]];
        [_voiceImgV setBackgroundColor:[UIColor colorWithRed:0.07 green:0.72 blue:0.96 alpha:1.00]];
        
    }
    return _voiceImgV;
}

#pragma mark - UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return [self.blogArray count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    //mvc
    BlobNewTableViewCell *cell = [BlobNewTableViewCell cellWithTableView:tableView];
    cell.isFeebackBlog = self.isFeedbackVC;
    cell.isUnreadMessage = NO;
    cell.indexRow = indexPath.row;
    FeedBackAndListenFriendFrameModel *frameModel = self.blogArray[indexPath.row];
    cell.frameModel = frameModel;
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    
    DefineWeakSelf;
    [cell setClickHeadView:^(BlobNewTableViewCell *cell) {
        [weakSelf skipToUserVCWihtcomponents:[frameModel.model.user mj_keyValues]];
    }];

    if (self.isFeedbackVC == NO) {
        [cell setLongPressHeadView:^(BlobNewTableViewCell *cell) {
            [UIActionSheet actionSheetWithTitle:nil message:nil buttons:@[@"投诉", @"屏蔽"] showInView:self.view onDismiss:^(int buttonIndex) {
                if (buttonIndex == 0) {
                    [weakSelf tousuLinsteningCircleWitnTouid:frameModel.model.user.ID andCommentid:frameModel.model.ID];
                }
                else{
                    [weakSelf pingbiLinsteningCircleWithTouid:frameModel.model.user.ID];
                }
                
            }onCancel:^{
                
            }];
        }];
        
    }

    [cell setAddFav:^(BlobNewTableViewCell *cell , int iszan) {
        [weakSelf addFavInTableViewCell:cell andIszan:iszan];
    }];
    [cell setAddComment:^(BlobNewTableViewCell *cell) {
        
        [weakSelf addCommentInTableViewCell:cell];
    }];
    [cell setAddReview:^(BlobNewTableViewCell *cell, child_commentModel *model) {
        [weakSelf reviewWithCell:cell andModel:model];
    }];
    [cell setDeleteBlog:^(BlobNewTableViewCell *cell,FeedBackAndListenFriendFrameModel *frameModel) {
        [weakSelf deleteBlogIntableViewCell:cell frameModel:frameModel];
    }];
    [cell setPlayVoice:^(BlobNewTableViewCell *cell) {
        [weakSelf playVoiceInTableViewCell:cell];
    }];
    [cell setUpdateVoiceAnimate:^(BlobNewTableViewCell *cell) {
        [weakSelf.blogTableview reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    }];
    [cell.photosImageView setTapImageBlock:^(MultiImageView *view, UIImageView *imgv, NSInteger idx) {
        [weakSelf showPhotos:view.images selectedIndex:idx];
    }];
    [cell setDeleteComment:^(BlobNewTableViewCell *cell,NSInteger index,NSInteger commentIndex){
        [weakSelf reloadFrameArrayWithIndex:index commnetIndex:commentIndex];
    }];

    return cell;
}

#pragma mark - UITableViewDelegate

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    FeedBackAndListenFriendFrameModel *frameModel = self.blogArray[indexPath.row];
    return frameModel.cellHeight;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    FeedBackAndListenFriendFrameModel *frameModel = self.blogArray[indexPath.row];
    if (self.isFeedbackVC || [frameModel.model.post_id isEqualToString:@"0"]) {
        return;
    }
    else{
        //TODO:跳转新闻详情
        NSDictionary *dict = [frameModel.model.post mj_keyValues];
        //设置频道类型
        [ZRT_PlayerManager manager].channelType = ChannelTypeMineCircleListen;
        //设置播放器播放内容类型
        [ZRT_PlayerManager manager].playType = ZRTPlayTypeNews;
        //设置播放界面打赏view的状态
        [NewPlayVC shareInstance].rewardType = RewardViewTypeNone;
        //判断是否是点击当前正在播放的新闻，如果是则直接跳转
        if ([[CommonCode readFromUserD:@"dangqianbofangxinwenID"] isEqualToString:dict[@"id"]]){
            
            //设置播放器播放数组
            [ZRT_PlayerManager manager].songList = @[dict];
            [[NewPlayVC shareInstance] reloadInterface];
            [self.navigationController.navigationBar setHidden:YES];
            [self.navigationController pushViewController:[NewPlayVC shareInstance] animated:YES];
        }
        else{
            
            //设置播放器播放数组
            [ZRT_PlayerManager manager].songList = @[dict];
            //设置新闻ID
            [NewPlayVC shareInstance].post_id = dict[@"id"];
            //保存当前播放新闻Index
            ExcurrentNumber = 0;
            //调用播放对应Index方法
            [[NewPlayVC shareInstance] playFromIndex:ExcurrentNumber];
            //跳转播放界面
            [self.navigationController.navigationBar setHidden:YES];
            [self.navigationController pushViewController:[NewPlayVC shareInstance] animated:YES];
            [tableView reloadData];
        }
    }
}

#pragma mark - UIScrollViewDelegate

- (void)scrollViewDidScroll:(UIScrollView *)scrollView{
    
    [self.toolBarView setHidden:YES];
    [self.commentTextField resignFirstResponder];
    
    if (self.toReplyBlog) {
        [self dissmissKeyboard];
    }
}

#pragma mark - DZNEmptyDataSetSource

//- (UIImage *)imageForEmptyDataSet:(UIScrollView *)scrollView{
//    return [UIImage imageNamed:@"bg_no_blog"];
//}
//
//- (NSAttributedString *)titleForEmptyDataSet:(UIScrollView *)scrollView{
//    NSAttributedString *attString = [[NSAttributedString alloc] initWithString:@"还没有机构动态"
//                                                                    attributes:@{NSFontAttributeName: gFontSelected18,
//                                                                                 NSForegroundColorAttributeName: gMainColor}];
//    return attString;
//}
//
//
//- (NSAttributedString *)descriptionForEmptyDataSet:(UIScrollView *)scrollView{
//    NSAttributedString *attString;
//    attString = [[NSAttributedString alloc] initWithString:@"创建动态后老师跟家长们都可以看到哦"
//                                                attributes:@{NSFontAttributeName: gFontMain15,
//                                                             NSForegroundColorAttributeName: gTextColorSub}];
//    return attString;
//}
//
//- (CGFloat)verticalOffsetForEmptyDataSet:(UIScrollView *)scrollView{
//    return 25.0f;
//}
//
//- (NSAttributedString *)buttonTitleForEmptyDataSet:(UIScrollView *)scrollView forState:(UIControlState)state{
//    NSString *text = @"创建动态";
//    UIFont *font = gFontMain15;
//    UIColor *textColor = [UIColor whiteColor];
//    NSMutableDictionary *attributes = [NSMutableDictionary new];
//    if (font) [attributes setObject:font forKey:NSFontAttributeName];
//    if (textColor) [attributes setObject:textColor forKey:NSForegroundColorAttributeName];
//    return [[NSAttributedString alloc] initWithString:text attributes:attributes];
//}
//
//- (UIImage *)buttonBackgroundImageForEmptyDataSet:(UIScrollView *)scrollView forState:(UIControlState)state{
//    UIEdgeInsets capInsets = UIEdgeInsetsMake(22.0, 22.0, 22.0, 22.0);
//    UIEdgeInsets rectInsets = UIEdgeInsetsMake(0.0, -20, 0.0, -20);;
//    return [[[UIImage imageNamed:@"bg_emptyButton"] resizableImageWithCapInsets:capInsets resizingMode:UIImageResizingModeStretch] imageWithAlignmentRectInsets:rectInsets];
//}


//#pragma mark - DZNEmptyDataSetDelegate
//
//- (void)emptyDataSet:(UIScrollView *)scrollView didTapButton:(UIButton *)button{
//    [self actionAddNewBlog];
//}
//
//#pragma mark - EMChatToolbarDelegate
//
//- (void)chatToolbarDidChangeFrameToHeight:(CGFloat)toHeight{
//    //    [UIView animateWithDuration:0.3 animations:^{
//    //        CGRect rect = self.tableView.frame;
//    //        rect.origin.y = 0;
//    //        rect.size.height = self.view.frame.size.height - toHeight;
//    //        self.tableView.frame = rect;
//    //    }];
//    [self _scrollViewToBottom:NO];
//}

- (void)didSendText:(NSString *)text{
    [self replayBlogWithContent:text];
}

#pragma mark - NewQAControllerDelegate

- (void)newQAController:(NewQAController *)qaController
              sendNewQA:(NSString *)content
            attachments:(NSArray *)attachments
               location:(NSString *)location
                address:(NSString *)address
             MpvoiceURL:(NSURL *)tmpfile
        MpvoicePlaytime:(NSString *)playtime{
    DefineWeakSelf;
    self.playtime = [playtime mutableCopy];
//    [SVProgressHUD showWithMaskType:SVProgressHUDMaskTypeClear];
    if (tmpfile != nil) {
        NSMutableDictionary *dic = [[NSMutableDictionary alloc]initWithCapacity:1];
        dic[@"accessToken"] = [DSE encryptUseDES:ExdangqianUser];
        dic[@"playtime"] = playtime;
        AFHTTPRequestOperationManager *manager = [[AFHTTPRequestOperationManager alloc] initWithBaseURL:[NSURL URLWithString:uploadMpVoiceURLStr]];
        manager.responseSerializer = [AFJSONResponseSerializer serializer];
        manager.responseSerializer.acceptableContentTypes = [NSSet setWithObjects:@"text/html",nil];
        
        manager.requestSerializer.timeoutInterval = 30.0;
        
        [manager POST:uploadMpVoiceURLStr parameters:dic constructingBodyWithBlock:^(id<AFMultipartFormData> formData) {
            //        if (tmpFile && ![tmpFile isEqualToString:@""]) {
            NSData *imageData = [NSData dataWithContentsOfFile:tmpfile.path];
            [formData appendPartWithFileData:imageData name:@"soundlist" fileName:[NSString stringWithFormat:@"sound.aac"] mimeType:@"audio/aac"];
            
            //        }
            //        if (images && images.count > 0) {
            //            for (UIImage *img in images) {
            //                NSData *imageData = UIImageJPEGRepresentation(img, 0.5);
            //                [formData appendPartWithFileData:imageData name:@"imageslist" fileName:[NSString stringWithFormat:@"photo.jpg"] mimeType:@"image/jpeg"];
            //
            //            }
            //        }
        } success:^(AFHTTPRequestOperation *operation, id responseString) {
            if ([responseString[@"status"] integerValue] == 1) {
                self.mp3_url = [responseString[@"results"][@"filepath"] mutableCopy];
            }
            else{
                self.mp3_url = nil;
            }
            
            NSUInteger imagesCount = [attachments count];
            if (imagesCount) {
                NSMutableDictionary *imageDic = [NSMutableDictionary dictionary];
                for (int i = 0 ; i < imagesCount; i ++) {
                    [imageDic setObject:attachments[i] forKey:[NSString stringWithFormat:@"image%d",i]];
                }
                NSMutableDictionary *dic = [[NSMutableDictionary alloc]initWithCapacity:1];
                dic[@"accessToken"] = [DSE encryptUseDES:ExdangqianUser];
                [weakSelf PostImagesToServer:uploadImagesURLStr dicPostParams:dic dicImages:imageDic sendNewQA:content location:location address:address];
            }
            else{
                if (self.isFeedbackVC) {
                    [weakSelf addNewBlogWithContent:content photos:nil location:location];
                }
                else{
                    [weakSelf addLinsteningCircleWithContent:content timages:nil mp3_url:self.mp3_url playtime:playtime];
                }
                
            }
            
        } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
            NSLog(@"%@",error);
            NSUInteger imagesCount = [attachments count];
            if (imagesCount) {
                NSMutableDictionary *imageDic = [NSMutableDictionary dictionary];
                for (int i = 0 ; i < imagesCount; i ++) {
                    [imageDic setObject:attachments[i] forKey:[NSString stringWithFormat:@"image%d",i]];
                }
                NSMutableDictionary *dic = [[NSMutableDictionary alloc]initWithCapacity:1];
                dic[@"accessToken"] = [DSE encryptUseDES:ExdangqianUser];
                [weakSelf PostImagesToServer:uploadImagesURLStr dicPostParams:dic dicImages:imageDic sendNewQA:content location:location address:address];
            }
            else{
                if (self.isFeedbackVC) {
                    [weakSelf addNewBlogWithContent:content photos:nil location:location];
                }
                else{
                    [weakSelf addLinsteningCircleWithContent:content timages:nil mp3_url:self.mp3_url playtime:playtime];
                }
                
            }
        }];
    }
    else{
        NSUInteger imagesCount = [attachments count];
        if (imagesCount) {
            NSMutableDictionary *imageDic = [NSMutableDictionary dictionary];
            for (int i = 0 ; i < imagesCount; i ++) {
                [imageDic setObject:attachments[i] forKey:[NSString stringWithFormat:@"image%d",i]];
            }
            NSMutableDictionary *dic = [[NSMutableDictionary alloc]initWithCapacity:1];
            dic[@"accessToken"] = [DSE encryptUseDES:ExdangqianUser];
            [weakSelf PostImagesToServer:uploadImagesURLStr dicPostParams:dic dicImages:imageDic sendNewQA:content location:location address:address];
        }
        else{
            if (self.isFeedbackVC) {
                [weakSelf addNewBlogWithContent:content photos:nil location:location];
            }
            else{
                [weakSelf addLinsteningCircleWithContent:content timages:nil mp3_url:self.mp3_url playtime:playtime];
            }
            
        }
    }
    
    
    
}

#pragma mark - UITextFieldDelegate

- (BOOL)textFieldShouldEndEditing:(UITextField *)textField{
    self.commentTextStr = textField.text;
    return YES;
}

//- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
//    self.commentTextStr = textField.text;
//
//    return YES;
//}

#pragma mark - TTTAttributedLabelDelegate
//点击评论回复用户名跳转个人主页
- (void)userNameClickedWithCell:(BlobNewTableViewCell *)cell Model:(child_commentModel *)model {
    
    if ([model.is_comment isEqualToString:@"1"]) {
//        self.replyComment_tuid = model.uid;
//        if ([[CommonCode readFromUserD:@"isLogin"]boolValue] == YES) {
//            self.toolBarView.frame = CGRectMake(0, SCREEN_HEIGHT, SCREEN_WIDTH, 46);
//            [[UIApplication sharedApplication].keyWindow addSubview:self.toolBarView];
//            [self.toolBarView setHidden:NO];
//            [self.commentTextField becomeFirstResponder];
//            self.isReplyComment = YES;
//            [self.commentTextField setPlaceholder:[NSString stringWithFormat:@"@%@",model.user]];
//            [CommonCode writeToUserD:[NSString stringWithFormat:@"%ld",(long)model.indexRow] andKey:@"rowIndex"];
//        }
//        else{
//            [self loginFirst];
//        }
    }
    else{
        //跳转个人主页
//        gerenzhuyeVC *gerenzhuye = [gerenzhuyeVC new];
//        if ([components[@"user_login"] isEqualToString:ExdangqianUser] && [[CommonCode readFromUserD:@"isLogin"]boolValue] == YES) {
//            gerenzhuye.isMypersonalPage = YES;
//        }
//        else{
//            gerenzhuye.isMypersonalPage = NO;
//        }
//        gerenzhuye.isNewsComment = NO;
//        gerenzhuye.user_nicename = components[@"user_nicename"];
//        gerenzhuye.sex = components[@"sex"];
//        gerenzhuye.signature = components[@"signature"];
//        gerenzhuye.user_login = components[@"user_login"];
//        gerenzhuye.avatar = components[@"avatar"];
//        gerenzhuye.fan_num = components[@"fan_num"];
//        gerenzhuye.guan_num = components[@"guan_num"];
//        gerenzhuye.user_id = components[@"id"];
//        self.hidesBottomBarWhenPushed=YES;
//        [self.navigationController pushViewController:gerenzhuye animated:YES];
//        self.hidesBottomBarWhenPushed=YES;
    }
}
//点击回复评论
- (void)reviewWithCell:(BlobNewTableViewCell *)cell andModel:(child_commentModel *)model
{
    self.replyComment_tuid = model.uid;
    if ([[CommonCode readFromUserD:@"isLogin"]boolValue] == YES) {
        //获取当前登录用户ID
        ExdangqianUserUid = [CommonCode readFromUserD:@"dangqianUserUid"];
        //判断是否为自己的评论或者回复
        if ([model.uid isEqualToString:ExdangqianUserUid]) {
            
        }else{
            self.toolBarView.frame = CGRectMake(0, SCREEN_HEIGHT, SCREEN_WIDTH, 46);
            [[UIApplication sharedApplication].keyWindow addSubview:self.toolBarView];
            [self.toolBarView setHidden:NO];
            [self.commentTextField becomeFirstResponder];
            self.isReplyComment = YES;
            [self.commentTextField setPlaceholder:[NSString stringWithFormat:@"@%@",model.user.user_nicename]];
            NSIndexPath *indexPath = [self.blogTableview indexPathForCell:cell];
            [CommonCode writeToUserD:[NSString stringWithFormat:@"%ld",(long)indexPath.row] andKey:@"rowIndex"];
        }
    }
    else{
        [self loginFirst];
    }

}

- (void)audioPlayerDidFinishPlaying:(AVAudioPlayer *)player successfully:(BOOL)flag{
    
    NSLog(@"audioPlayerDidFinishPlaying");
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

#pragma mark - UtilityMethod

- (void)loadData{
    DefineWeakSelf;
    
    NSInteger limit = 10;
    NSString *accessToken = nil;
    
    if (self.isFeedbackVC) {
        if ([[CommonCode readFromUserD:@"isLogin"]boolValue] == YES) {
            accessToken = [DSE encryptUseDES:ExdangqianUser];
        }
        else{
            accessToken = nil;
        }
        [NetWorkTool getFeedBackListWithaccessToken:AvatarAccessToken
                                            andpage:[NSString stringWithFormat:@"%lu",(unsigned long)self.page]
                                           andlimit:[NSString stringWithFormat:@"%ld",(long)limit]
                                             sccess:^(NSDictionary *responseObject) {
//                                                 NSLog(@"%@",[NetWorkTool dictionaryToJson:responseObject[@"results"]]);
                                                 if ([responseObject[@"results"] isKindOfClass:[NSArray class]]) {
                                                     if (self.page == 1) {
                                                         [weakSelf.blogArray removeAllObjects];
                                                     }
                                                     NSMutableArray *resultsArr = [FeedBackAndListenFriendModel mj_objectArrayWithKeyValuesArray:responseObject[@"results"]];
                                                     [weakSelf.blogArray addObjectsFromArray:[self frameArrayWithDataArray:resultsArr]];
                                                     if (resultsArr.count < limit) {
                                                         [weakSelf.blogTableview.mj_footer endRefreshingWithNoMoreData];
                                                     }else{
                                                         [weakSelf.blogTableview.mj_footer endRefreshing];
                                                     }
                                                 }else{
                                                     NSLog(@"没有相关信息");
                                                     [weakSelf.blogTableview.mj_footer endRefreshingWithNoMoreData];
                                                 }
                                                 
                                                 [weakSelf.blogTableview reloadData];
                                                 [weakSelf.blogTableview.mj_header endRefreshing];
                                                 
                                                  ExisRigester = NO;
                                                 
                                             } failure:^(NSError *error) {
                                                 NSLog(@"error = %@",error);
                                                 [weakSelf.blogTableview.mj_header endRefreshing];
                                                 [weakSelf.blogTableview.mj_footer endRefreshing];
                                             }];
    }else{
        accessToken = [DSE encryptUseDES:ExdangqianUser];
        [NetWorkTool getLinsteningCircleListWithaccessToken:accessToken andpage:[NSString stringWithFormat:@"%lu",(unsigned long)self.page] andlimit:nil sccess:^(NSDictionary *responseObject) {
            if ([responseObject[@"results"] isKindOfClass:[NSArray class]]) {
                if (self.page == 1) {
                    [weakSelf.blogArray removeAllObjects];
                }
                NSMutableArray *resultsArr = [FeedBackAndListenFriendModel mj_objectArrayWithKeyValuesArray:responseObject[@"results"]];
                
                [weakSelf.blogArray addObjectsFromArray:[self frameArrayWithDataArray:resultsArr]];
                if (resultsArr.count < limit) {
                    [weakSelf.blogTableview.mj_footer endRefreshingWithNoMoreData];
                }else{
                    [weakSelf.blogTableview.mj_footer endRefreshing];
                }
            }else{
                NSLog(@"没有相关信息");
                [weakSelf.blogTableview.mj_footer endRefreshingWithNoMoreData];
            }
            
            [weakSelf.blogTableview reloadData];
            [weakSelf.blogTableview.mj_header endRefreshing];
            
        } failure:^(NSError *error) {
            NSLog(@"error = %@",error);
            [weakSelf.blogTableview.mj_header endRefreshing];
            [weakSelf.blogTableview.mj_footer endRefreshing];
            
        }];
    }
    
}
//转换数据模型数组为数据frame模型数组
- (NSMutableArray *)frameArrayWithDataArray:(NSMutableArray *)array
{
    NSMutableArray *frameModelArray = [NSMutableArray array];
    for (FeedBackAndListenFriendModel *model in array) {
        FeedBackAndListenFriendFrameModel *frameModel = [[FeedBackAndListenFriendFrameModel alloc] init];
        frameModel.isFeedbackVC = self.isFeedbackVC;
        frameModel.model = model;
        [frameModelArray addObject:frameModel];
    }
    return frameModelArray;
}
- (void)reloadFrameArrayWithIndex:(NSInteger)index commnetIndex:(NSInteger)commentIndex
{
    FeedBackAndListenFriendFrameModel *frameModel = [[FeedBackAndListenFriendFrameModel alloc] init];
    FeedBackAndListenFriendFrameModel *Fmodel = self.blogArray[index];
//    child_commentModel *model = Fmodel.model.child_comment[commentIndex];
    [Fmodel.model.child_comment removeObjectAtIndex:commentIndex];
    
    frameModel.isFeedbackVC = self.isFeedbackVC;
    frameModel.model = Fmodel.model;
    [self.blogArray replaceObjectAtIndex:index withObject:frameModel];
    
    [self.blogTableview reloadRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:index inSection:0]] withRowAnimation:UITableViewRowAnimationNone];
}

- (void)addFavInTableViewCell:(BlobNewTableViewCell *)cell andIszan:(int)iszan{
    NSIndexPath *indexPath = [self.blogTableview indexPathForCell:cell];
    FeedBackAndListenFriendFrameModel *blog = self.blogArray[indexPath.row];
    FeedBackAndListenFriendModel *model = blog.model;
    cell.praiseButton.userInteractionEnabled = NO;
     DefineWeakSelf;
    if (self.isFeedbackVC) {
        if ([[CommonCode readFromUserD:@"isLogin"]boolValue] == YES){
            if (iszan == 1){
                [NetWorkTool delFeedbackZanWithaccessToken:[DSE encryptUseDES:ExdangqianUser] feedback_id:blog.model.ID sccess:^(NSDictionary *responseObject) {
                    //没有重新获取列表数据
                    model.is_zan = @"0";
                    model.zan_num = [NSString stringWithFormat:@"%d",[model.zan_num intValue] - 1];
                    [weakSelf.blogTableview reloadData];
                    cell.praiseButton.userInteractionEnabled = YES;
                    
                    XWAlerLoginView *xw = [[XWAlerLoginView alloc]initWithTitle:@"取消点赞成功"];
                    [xw show];
                } failure:^(NSError *error) {
                    cell.praiseButton.userInteractionEnabled = YES;
                    [SVProgressHUD showErrorWithStatus:@"网络请求失败"];
                    [self performSelector:@selector(SVPDismiss) withObject:nil afterDelay:1.0];
                }];
            }
            else {
                [NetWorkTool addFeedbackZanWithaccessToken:[DSE encryptUseDES:ExdangqianUser] feedback_id:model.ID sccess:^(NSDictionary *responseObject) {
                    //没有重新获取列表数据
                    model.is_zan = @"1";
                    model.zan_num = [NSString stringWithFormat:@"%d",[model.zan_num intValue] + 1];
                    [weakSelf.blogTableview reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
                    cell.praiseButton.userInteractionEnabled = YES;
//                    [cell addOneAnimation];
                    XWAlerLoginView *xw = [[XWAlerLoginView alloc]initWithTitle:@"点赞成功"];
                    [xw show];

                } failure:^(NSError *error) {
                    cell.praiseButton.userInteractionEnabled = YES;
                    [SVProgressHUD showErrorWithStatus:@"网络请求失败"];
                    [self performSelector:@selector(SVPDismiss) withObject:nil afterDelay:1.0];
                }];
            }
            
        }
        else {
            [self loginFirst];
        }
    }
    else{
        [NetWorkTool addAndCancelPraiseWithaccessToken:[DSE encryptUseDES:ExdangqianUser] comments_id:model.ID sccess:^(NSDictionary *responseObject) {
//            [weakSelf loadData];
            
            if (iszan == 0) {
                [cell.praiseButton setImage:[UIImage imageNamed:@"me_mypage_me_list_ic_liked"] forState:UIControlStateNormal];
                cell.frameModel.model.zan = @"1";
                cell.frameModel.model.praisenum = [NSString stringWithFormat:@"%d",[cell.frameModel.model.praisenum intValue] + 1];
                cell.favLabel.text = [NSString stringWithFormat:@"%@人点赞",cell.frameModel.model.praisenum];
            }
            else if (iszan == 1){
                [cell.praiseButton setImage:[UIImage imageNamed:@"me_mypage_me_list_ic_like"] forState:UIControlStateNormal];
                cell.frameModel.model.zan = @"0";
                cell.frameModel.model.praisenum = [NSString stringWithFormat:@"%d",[cell.frameModel.model.praisenum intValue] - 1];
                cell.favLabel.text = [NSString stringWithFormat:@"%@人点赞",cell.frameModel.model.praisenum];
            }
            
            cell.praiseButton.userInteractionEnabled = YES;
            if (iszan == 1) {
                XWAlerLoginView *xw = [[XWAlerLoginView alloc]initWithTitle:@"取消点赞成功"];
                [xw show];
            }else
            {
                XWAlerLoginView *xw = [[XWAlerLoginView alloc]initWithTitle:@"点赞成功"];
                [xw show];
            }
        } failure:^(NSError *error) {
            cell.praiseButton.userInteractionEnabled = YES;
            [SVProgressHUD showErrorWithStatus:@"网络请求失败"];
            [self performSelector:@selector(SVPDismiss) withObject:nil afterDelay:1.0];
        }];
    }
    
}

- (void)deleteBlogIntableViewCell:(BlobNewTableViewCell *)cell frameModel:(FeedBackAndListenFriendFrameModel *)frameModel{
        NSIndexPath *indexPath = [self.blogTableview indexPathForCell:cell];
//        BlogModel *blog = self.blogArray[indexPath.row];
        DefineWeakSelf;
//    FeedBackAndListenFriendFrameModel *frameModel = self.blogArray[indexPath.row];
    
        [UIAlertView alertViewWithTitle:@"提示" message:@"确认删除吗？" cancelButtonTitle:@"取消" otherButtonTitles:@[@"删除"] onDismiss:^(int buttonIndex) {
//            [weakSelf deleteBlog:blog];
            [NetWorkTool delCommentWithaccessToken:AvatarAccessToken comment_id:frameModel.model.ID sccess:^(NSDictionary *responseObject) {
                //
                if ([responseObject[status] intValue] == 1) {
                    
                    NSLog(@"deleteBlogSuccess");
                    [weakSelf.player stop];
                    [weakSelf.voicePlayer pause];
                    [weakSelf.voiceImgV removeFromSuperview];
                    //删除数据和cell
                    [weakSelf.blogArray removeObject:frameModel];
                    [weakSelf.blogTableview deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationLeft];
                }
            } failure:^(NSError *error) {
                //
                NSLog(@"%@",error);
            }];
        } onCancel:^{
            
        }];
}

- (void)addCommentInTableViewCell:(BlobNewTableViewCell *)cell{
    
    if ([[CommonCode readFromUserD:@"isLogin"]boolValue] == YES) {
        
        NSIndexPath *indexPath = [self.blogTableview indexPathForCell:cell];
        _commentCell = cell;
        self.toolBarView.frame = CGRectMake(0, SCREEN_HEIGHT, SCREEN_WIDTH, 46);
        [[UIApplication sharedApplication].keyWindow addSubview:self.toolBarView];
        self.isReplyComment = NO;
        [self.commentTextField setPlaceholder:@"评论"];
        self.blogTableview.delegate = nil;
        [self.blogTableview scrollToRowAtIndexPath:indexPath atScrollPosition:UITableViewScrollPositionTop animated:NO];
//        CGRect rectintableview=[self.blogTableview rectForRowAtIndexPath:indexPath];
//        [self.blogTableview setContentOffset:CGPointMake(self.blogTableview.contentOffset.x,(rectintableview.origin.y-self.blogTableview.contentOffset.y)+self.blogTableview.contentOffset.y + 20) animated:YES];
        self.blogTableview.delegate = self;
        [self.toolBarView setHidden:NO];
        [self.commentTextField becomeFirstResponder];
        
    }
    else{
        [self loginFirst];
    }
    
}

- (void)playVoiceInTableViewCell:(BlobNewTableViewCell *)cell {

    if (_isPlaying) {
        [self.player stop];
        [self.voicePlayer pause];
        [self.voiceImgV removeFromSuperview];
        _isPlaying = NO;
    }
    else{
        NSIndexPath *indexPath = [self.blogTableview indexPathForCell:cell];
        FeedBackAndListenFriendFrameModel *frameModel = self.blogArray[indexPath.row];
        if ([ZRT_PlayerManager manager].isPlaying) {
            [[ZRT_PlayerManager manager] pausePlay];
        }
        //用一个uiimageview 盖住原来的再添加动画效果
        CGRect  frame  = [cell.voiceButton convertRect:self.voiceImgV.bounds toView:self.blogTableview];
        CGRect finalFrame = CGRectMake(frame.origin.x + 10, frame.origin.y + 10, frame.size.width, frame.size.height);
        [self.voiceImgV setFrame:finalFrame];
        [self.blogTableview addSubview:self.voiceImgV];
        [self.voiceImgV startAnimating];
        [self.player stop];
        [self.voicePlayer pause];
        
        if ([frameModel.model.mp3_url rangeOfString:@"mp3"].location != NSNotFound) {
            NSString *urlStr = frameModel.model.mp3_url;
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
            _isPlaying = YES;
            //动画开启
            [self voicePlayWithAnimateTime:[frameModel.model.play_time integerValue]];
            
        }
        else{
            if (self.voicePlayer == nil) {
                self.voicePlayer = [[AVPlayer alloc]init];
                //添加观察者，用来监视播放器的状态变化
                [self.voicePlayer addObserver:self forKeyPath:@"statu" options:NSKeyValueObservingOptionNew context:nil];
            }
            [self.voicePlayer replaceCurrentItemWithPlayerItem:[[AVPlayerItem alloc]initWithURL:[NSURL URLWithString:frameModel.model.mp3_url]]];
            //播放完毕后发出通知
            [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(voicePlayEnd:) name:AVPlayerItemDidPlayToEndTimeNotification object:self.voicePlayer.currentItem];
            [self.voicePlayer play];
            _isPlaying = YES;
            //动画开启
            [self voicePlayWithAnimateTime:[frameModel.model.play_time integerValue]];
            [CommonCode writeToUserD:@"YES" andKey:TINGYOUQUANBOFANGWANBI];
            if (ExisRigester == NO){
                //添加观察者，用来监视播放器的状态变化
                [self.voicePlayer addObserver:self forKeyPath:@"statu" options:NSKeyValueObservingOptionNew context:nil];
                ExisRigester = YES;
            }
            
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
    else{
        [self loginFirst];
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

- (void)dissmissKeyboard{
    self.toReplyBlog = nil;
}

- (void)setupEmotion{
    //    NSMutableArray *emotions = [NSMutableArray array];
    //    for (NSString *name in [EaseEmoji allEmoji]) {
    //        EaseEmotion *emotion = [[EaseEmotion alloc] initWithName:@"" emotionId:name emotionThumbnail:name emotionOriginal:name emotionOriginalURL:@"" emotionType:EMEmotionDefault];
    //        [emotions addObject:emotion];
    //    }
    //    EaseEmotion *emotion = [emotions objectAtIndex:0];
    //    EaseEmotionManager *manager= [[EaseEmotionManager alloc] initWithType:EMEmotionDefault emotionRow:3 emotionCol:7 emotions:emotions tagImage:[UIImage imageNamed:emotion.emotionId]];
    //    [self.faceView setEmotionManagers:@[manager]];
}


- (void)addNewBlogWithContent:(NSString *)content photos:(NSString *)photos location:(NSString *)location{
    DefineWeakSelf;
    content = [CommonCode stringContainsEmoji:content];
    [NetWorkTool addfeedBackWithaccessToken:[DSE encryptUseDES:ExdangqianUser] tuid:@"0" to_comment_id:@"0" comment:content images:photos is_comment:@"0" sccess:^(NSDictionary *responseObject) {
        //TODO:
        [weakSelf loadData];
        [SVProgressHUD dismiss];
        [weakSelf.navigationController popViewControllerAnimated:YES];
        //        [weakSelf dismissViewControllerAnimated:YES completion:nil];
    } failure:^(NSError *error) {
        //
        NSLog(@"%@",error);
    }];
}

- (void)addLinsteningCircleWithContent:(NSString *)content timages:(NSString *)timages mp3_url:(NSString *)mp3_url playtime:(NSString *)playtime{
    DefineWeakSelf;
    content = [CommonCode stringContainsEmoji:content];
    [NetWorkTool addLinsteningCircleWithaccessToken:[DSE encryptUseDES:ExdangqianUser]
                                             to_uid:@"0"
                                            mp3_url:mp3_url
                                           play_time:playtime
                                            timages:timages
                                            content:content
                                         comment_id:nil
                                             sccess:^(NSDictionary *responseObject) {
                                                 [weakSelf loadData];
                                                 [SVProgressHUD dismiss];
                                                 [weakSelf.navigationController popViewControllerAnimated:YES];
    } failure:^(NSError *error) {
        //
        NSLog(@"%@",error);
    }];
}

//- (void)deleteBlog:(NSMutableDictionary *)blog{
//    DefineWeakSelf;
//    [SVProgressHUD showWithMaskType:SVProgressHUDMaskTypeClear];
//    [APPRequest deleteBlogWithBlogID:@(blog.id).stringValue successBlock:^(NSURLSessionDataTask *dataTask, id response) {
//        [weakSelf.blogArray removeObject:blog];
//        [weakSelf.tableView reloadData];
//        [SVProgressHUD dismiss];
//    } errorBlock:^(NSURLSessionDataTask *dataTask, FailureResponseModel *failureResponse) {
//        [SVProgressHUD showErrorWithStatus:failureResponse.errorMessage];
//    }];
//}

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

- (void)back {
    [self.toolBarView setHidden:YES];
    [self.commentTextField resignFirstResponder];
    [self.player stop];
    [self.voicePlayer pause];
    [self.voiceImgV removeFromSuperview];
    [self.navigationController popViewControllerAnimated:YES];
}
//上传图片到服务器
- (NSString *)PostImagesToServer:(NSString *)strUrl
                   dicPostParams:(NSMutableDictionary *)params
                       dicImages:(NSMutableDictionary *)dicImages
                       sendNewQA:(NSString *)contentQA
                        location:(NSString *)location
                         address:(NSString *)address{
    NSString * res;
    
    //分界线的标识符
    NSString *TWITTERFON_FORM_BOUNDARY = @"AaB03x";
    //根据url初始化request
    //NSMutableURLRequest* request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:strUrl] cachePolicy:NSURLRequestReloadIgnoringLocalCacheData timeoutInterval:10];
    
    NSURL *url = [NSURL URLWithString:strUrl];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
    //分界线 --AaB03x
    NSString *MPboundary=[[NSString alloc]initWithFormat:@"--%@",TWITTERFON_FORM_BOUNDARY];
    //结束符 AaB03x--
    NSString *endMPboundary=[[NSString alloc]initWithFormat:@"%@--",MPboundary];
    //要上传的图片
    UIImage *image;//=[params objectForKey:@"pic"];
    //得到图片的data
    //NSData* data = UIImagePNGRepresentation(image);
    //http body的字符串
    NSMutableString *body=[[NSMutableString alloc]init];
    //参数的集合的所有key的集合
    NSArray *keys= [params allKeys];
    
    //遍历keys
    for(int i=0;i<[keys count];i++) {
        //得到当前key
        NSString *key=[keys objectAtIndex:i];
        //如果key不是pic，说明value是字符类型，比如name：Boris
        //if(![key isEqualToString:@"pic"]) {
        //添加分界线，换行
        [body appendFormat:@"%@\r\n",MPboundary];
        //添加字段名称，换2行
        [body appendFormat:@"Content-Disposition: form-data; name=\"%@\"\r\n\r\n",key];
        //[body appendString:@"Content-Transfer-Encoding: 8bit"];
        //添加字段的值
        [body appendFormat:@"%@\r\n",[params objectForKey:key]];
        //}
    }
    ////添加分界线，换行
    //[body appendFormat:@"%@\r\n",MPboundary];
    
    //声明myRequestData，用来放入http body
    NSMutableData *myRequestData=[NSMutableData data];
    //将body字符串转化为UTF8格式的二进制
    [myRequestData appendData:[body dataUsingEncoding:NSUTF8StringEncoding]];
    
    //循环加入上传图片
    keys = [dicImages allKeys];
    for(int i = 0; i< [keys count] ; i++){
        //要上传的图片
        image = [dicImages objectForKey:[keys objectAtIndex:i ]];
        //得到图片的data
        NSData* data =  UIImageJPEGRepresentation(image, 0.0);
        NSMutableString *imgbody = [[NSMutableString alloc] init];
        //此处循环添加图片文件
        //添加图片信息字段
        //声明pic字段，文件名为boris.png
        //[body appendFormat:[NSString stringWithFormat: @"Content-Disposition: form-data; name=\"File\"; filename=\"%@\"\r\n", [keys objectAtIndex:i]]];
        
        ////添加分界线，换行
        [imgbody appendFormat:@"%@\r\n",MPboundary];
        [imgbody appendFormat:@"Content-Disposition: form-data; name=\"File%d\"; filename=\"%@.jpg\"\r\n", i, [keys objectAtIndex:i]];
        //声明上传文件的格式
        [imgbody appendFormat:@"Content-Type: application/octet-stream; charset=utf-8\r\n\r\n"];
        
        NSLog(@"上传的图片：%d  %@", i, [keys objectAtIndex:i]);
        
        //将body字符串转化为UTF8格式的二进制
        //[myRequestData appendData:[body dataUsingEncoding:NSUTF8StringEncoding]];
        [myRequestData appendData:[imgbody dataUsingEncoding:NSUTF8StringEncoding]];
        //将image的data加入
        [myRequestData appendData:data];
        [myRequestData appendData:[ @"\r\n" dataUsingEncoding:NSUTF8StringEncoding]];
    }
    //声明结束符：--AaB03x--
    NSString *end=[[NSString alloc]initWithFormat:@"%@\r\n",endMPboundary];
    //加入结束符--AaB03x--
    [myRequestData appendData:[end dataUsingEncoding:NSUTF8StringEncoding]];
    
    //设置HTTPHeader中Content-Type的值
    NSString *content=[[NSString alloc]initWithFormat:@"multipart/form-data; boundary=%@",TWITTERFON_FORM_BOUNDARY];
    //设置HTTPHeader
    [request setValue:content forHTTPHeaderField:@"Content-Type"];
    //[request setValue:@"keep-alive" forHTTPHeaderField:@"connection"];
    //[request setValue:@"UTF-8" forHTTPHeaderField:@"Charsert"];
    //设置Content-Length
    [request setValue:[NSString stringWithFormat:@"%lu", (unsigned long)[myRequestData length]] forHTTPHeaderField:@"Content-Length"];
    //设置http body
    [request setHTTPBody:myRequestData];
    //http method
    [request setHTTPMethod:@"POST"];
    
    //建立连接，设置代理
    //NSURLConnection *conn = [[NSURLConnection alloc] initWithRequest:request delegate:self];
    
    //设置接受response的data
    NSData *mResponseData;
    NSError *err = nil;
    mResponseData = [NSURLConnection sendSynchronousRequest:request returningResponse:nil error:&err];
    
    if(mResponseData == nil){
        NSLog(@"err code : %@", [err localizedDescription]);
    }
    res = [[NSString alloc] initWithData:mResponseData encoding:NSUTF8StringEncoding];

    
    //json解析数据
    NSError *error = nil;
    id obj =  [NSJSONSerialization JSONObjectWithData:mResponseData options:kNilOptions error:&error];
    if (error) {
        NSLog(@"解析错误=%@",error);
    }else{
        DefineWeakSelf;
        if (self.isFeedbackVC) {
            [weakSelf addNewBlogWithContent:contentQA photos:obj[@"results"] location:location];
        }
        else{
            [weakSelf addLinsteningCircleWithContent:contentQA timages:obj[@"results"] mp3_url:self.mp3_url playtime:self.playtime];
        }
        
    }
    
    return res;
}

- (void)SVPDismiss {
    [SVProgressHUD dismiss];
}

- (void)subReplyClick:(UIGestureRecognizer *)gesture {
    NSLog(@"222222222");
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
    gerenzhuye.fan_num = components[@"fan_num"];
    gerenzhuye.guan_num = components[@"guan_num"];
    gerenzhuye.avatar = components[@"avatar"];
    gerenzhuye.user_id = components[@"id"];
    
    //头像url处理
    gerenzhuye.avatar = NEWSSEMTPHOTOURL(components[@"avatar"]);
    gerenzhuye.fan_num = components[@"fan_num"];
    gerenzhuye.guan_num = components[@"guan_num"];
    self.hidesBottomBarWhenPushed = YES;
    [self.navigationController pushViewController:gerenzhuye animated:YES];
    self.hidesBottomBarWhenPushed = YES;
}

- (void)pingbiLinsteningCircleWithTouid:(NSString *)to_uid {
    [NetWorkTool pingbiLinsteningCircleWithaccessToken:AvatarAccessToken to_uid:to_uid sccess:^(NSDictionary *responseObject) {
        if ([responseObject[@"status"] integerValue] == 1) {
            [SVProgressHUD showSuccessWithStatus:[NSString stringWithFormat:@"%@",responseObject[@"msg"]]];
            [self performSelector:@selector(SVPDismiss) withObject:nil afterDelay:1.0];
            [self loadData];
            
        }
    } failure:^(NSError *error) {
        [SVProgressHUD showErrorWithStatus:@"网络请求失败"];
        [self performSelector:@selector(SVPDismiss) withObject:nil afterDelay:1.0];
    }];
}

- (void)tousuLinsteningCircleWitnTouid:(NSString *)to_uid andCommentid:(NSString *)comment_id {
    pinglunyeVC *pinglunye = [pinglunyeVC new];
    pinglunye.isNewsCommentPage = NO;
    pinglunye.comment_id = comment_id;
    pinglunye.to_uid = to_uid;
    self.hidesBottomBarWhenPushed = YES;
    [self.navigationController pushViewController:pinglunye animated:YES];
    self.hidesBottomBarWhenPushed = YES;
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

- (void)voicePlayStop{
    [self.voiceImgV stopAnimating];
}

#pragma mark - KVO
//观察者方法，用来监听播放状态
- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSString *,id> *)change context:(void *)context{
    //当播放器状态（status）改变时，会进入此判断
    if ([keyPath isEqualToString:@"statu"]){
        switch (self.voicePlayer.status) {
            case AVPlayerStatusUnknown:
                NSLog(@"KVO：未知状态，此时不能播放");
                break;
            case AVPlayerStatusReadyToPlay:
                NSLog(@"KVO：准备完毕，可以播放");
                break;
            case AVPlayerStatusFailed:
                NSLog(@"KVO：加载失败，网络或者服务器出现问题");
                break;
            default:
                break;
        }
    }
}

#pragma mark - NSNotification
- (void)voicePlayEnd:(NSNotification *)notice {
    [self performSelector:@selector(wanbi:) withObject:notice afterDelay:0.5f];
    _isPlaying = NO;
}
- (void)wanbi:(NSNotification *)notice{
    
    if (ExisRigester == YES){
//        [Explayer removeObserver:self forKeyPath:@"statu"];
//        [Explayer removeObserver:self forKeyPath:@"loadedTimeRange"];
        ExisRigester = NO;
    }
    
    [self.player stop];
    [self.voicePlayer pause];
    [CommonCode writeToUserD:@"YES" andKey:TINGYOUQUANBOFANGWANBI];
    _isPlaying = NO;
}

- (void)dealloc {
    RTLog(@"dealloc--------");
    [self.voicePlayer removeObserver:self forKeyPath:@"statu"];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:AVPlayerItemDidPlayToEndTimeNotification object:nil];
    [CommonCode writeToUserD:@"NO" andKey:TINGYOUQUANBOFANGWANBI];
}

#pragma mark - UIButtonAction

- (void)actionAddNewBlog:(UILongPressGestureRecognizer *)longPress{
    
    switch (longPress.state) {
        case UIGestureRecognizerStateEnded:{
            if ([[CommonCode readFromUserD:@"isLogin"]boolValue] == YES){
                NewQAController *vc = [NewQAController loadFromStoryboard];
                vc.delegate = self;
                vc.title = @"意见反馈";
                vc.inputType = 0;
                vc.isFeedbackVC = self.isFeedbackVC;
                vc.textFieldPlaceHolderString = @"今天又有什么有趣的事情…";
                [self.navigationController pushViewController:vc animated:YES];
                //        UINavigationController *navVC = [[UINavigationController alloc] initWithRootViewController:vc];
                //        [navVC.navigationBar setBarTintColor:gMainColor];
                //        [self presentViewController:navVC animated:YES completion:nil];
            }
            else{
                [self loginFirst];
            }
        }
            
            break;
            
        default:
            break;
    }
}

- (void)tapAddNewBlog {
    if ([[CommonCode readFromUserD:@"isLogin"]boolValue] == YES){
        
        [self.view endEditing:YES];
        DefineWeakSelf;
        [UIActionSheet actionSheetWithTitle:nil message:nil buttons:@[@"拍照", @"从手机相册中选择"] showInView:self.view onDismiss:^(int buttonIndex) {
            if (buttonIndex == 0) {
                NewQAController *vc = [NewQAController loadFromStoryboard];
                vc.delegate = self;
                vc.isFeedbackVC = self.isFeedbackVC;
                vc.inputType = 1;
                vc.textFieldPlaceHolderString = @"今天又有什么有趣的事情…";
                [weakSelf.navigationController pushViewController:vc animated:NO];
            }
            else{
                NewQAController *vc = [NewQAController loadFromStoryboard];
                vc.delegate = self;
                vc.isFeedbackVC = self.isFeedbackVC ;
                vc.inputType = 2;
                vc.textFieldPlaceHolderString = @"今天又有什么有趣的事情…";
                [weakSelf.navigationController pushViewController:vc animated:NO];
            }
        } onCancel:^{
            
        }];
        
    }
    else{
        [self loginFirst];
    }
}

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
            indexPath = [self.blogTableview indexPathForCell:_commentCell];
            row = indexPath.row;
        }
        NSString *tuid = @"0";
        NSString *to_comment_id = @"0";
        NSString *iscomment = @"0";
        DefineWeakSelf;
        [SVProgressHUD setDefaultMaskType:SVProgressHUDMaskTypeBlack];
        FeedBackAndListenFriendFrameModel *frameModel = self.blogArray[row];
        if (self.isReplyComment) {
            iscomment = @"1";
            to_comment_id = frameModel.model.ID;
            tuid = self.replyComment_tuid;
        }
        else{
            
            tuid = frameModel.model.uid;
            to_comment_id = frameModel.model.ID;
        }
        if (self.isFeedbackVC) {
            [NetWorkTool addfeedBackWithaccessToken:AvatarAccessToken
                                               tuid:tuid
                                      to_comment_id:to_comment_id
                                            comment:self.commentTextStr
                                             images:nil
                                         is_comment:iscomment
                                             sccess:^(NSDictionary *responseObject) {
                                                 if ([responseObject[@"status"] integerValue] == 1) {
                                                     NSLog(@"blogArray==%@",self.blogArray[row]);
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
        else{
            if ([frameModel.model.post_id isEqualToString:@"0"]) {
                if (!self.isReplyComment) {
                    tuid = @"0";
                }
                [NetWorkTool addfriendDynamicsPingLunWithaccessToken:AvatarAccessToken
                                                             post_id:nil
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
                                                     andpost_id:frameModel.model.post_id
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
        
    }
}

- (void)newMessageAction:(UIButton *)sender {
    //TODO:跳转未读消息
    UnreadMessageViewController *unreadVC = [UnreadMessageViewController new];
    unreadVC.pageSource = self.isFeedbackVC ? 2:1;
    [self.navigationController pushViewController:unreadVC animated:YES];
}

@end

