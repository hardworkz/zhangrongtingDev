//
//  NewQAController.m
//  KangShiFu_Elearnning
//
//  Created by ND-MAC-WangGuoMing on 7/16/14.
//  Copyright (c) 2014 Lin Yawen. All rights reserved.
//

#import "NewQAController.h"
#import "CTAssetsPickerController.h"

#import "NewQATextController.h"
#import "NewBlogPictureController.h"

#import "UIAlertView+MKBlockAdditions.h"
#import "UIActionSheet+MKBlockAdditions.h"
#import "UIBarButtonItem+Utility.h"
#import "UIView+AnimationOptionsForCurve.h"
#import "UIImage+compress.h"
#import "UIView+tap.h"
#import "AppDelegate.h"
#import "AFNetworking.h"


@interface NewQAController ()<UIScrollViewDelegate,UINavigationControllerDelegate ,UIImagePickerControllerDelegate, CTAssetsPickerControllerDelegate,AVAudioRecorderDelegate,UIGestureRecognizerDelegate>
{
    NSURL *tmpFile;
    AVAudioRecorder *recorder;
    BOOL recording;
    AVAudioPlayer *audioPlayer;
    NSTimer *timer;

}
//@property (nonatomic, strong) NSMutableArray *assets; //选择的图片
@property (weak, nonatomic) IBOutlet UIView *toolBarView;
@property (weak, nonatomic) IBOutlet UILabel *addressLabel;

@property (strong, nonatomic) NSArray *staffButtons;
//已选择的人
@property (strong, nonatomic) NSArray *staffs;

@property (assign, nonatomic) BOOL hideSelectStaffItem;

@property (assign, nonatomic) BOOL hideToolBar;

@property (assign, nonatomic) NSString *location;

@property (strong, nonatomic) UIButton *voicebtn;

@property (strong,nonatomic) UIImageView *voiceImgV;

@property (strong, nonatomic) UILabel *voicetimeLabel;

@property (strong, nonatomic) UIButton *deleteVoiceButton;

@property (strong, nonatomic) UIButton *recordVoiceButton;

@property(strong,nonatomic) UIImageView  *remindImg;

@property(strong,nonatomic) UIImageView  *remindMacImg;

@property(strong,nonatomic) UIImageView  *reminVoiceImg;

@property(strong,nonatomic) UIImageView  *reminWarnImg;

@property(strong,nonatomic) UILabel      *remindLab;

@property (assign, nonatomic) NSString *playtime;

@property(assign,nonatomic) BOOL send;


//@property (assign, nonatomic) BOOL recording;
//
//@property (strong, nonatomic) AVAudioRecorder *recorder;
//
//@property (strong, nonatomic) NSURL *tmpFile;

@end

@implementation NewQAController

+ (id)loadFromStoryboard{
    NewQAController *vc = [[UIStoryboard storyboardWithName:@"NewQA" bundle:nil]
                           instantiateViewControllerWithIdentifier:@"NewQAController"];
//    vc.title = @"提问题";
    return vc;
}

- (void)viewDidLoad{
    [super viewDidLoad];
    //    [self setupNavBackground];
    [self setupUI];
    
}

-(void)setupUI{
//    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"返回" style:UIBarButtonItemStylePlain target:self action:@selector(actionCancel)];
    self.title = self.isFeedbackVC ? @"意见反馈" : @"听友圈";
//    [self enableAutoBack];
    UIButton *leftBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    leftBtn.frame = CGRectMake(10, 25, 35, 35);
    [leftBtn setImageEdgeInsets:UIEdgeInsetsMake(5, 0, 5, 10)];
    [leftBtn setImage:[UIImage imageNamed:@"back"] forState:UIControlStateNormal];
    leftBtn.accessibilityLabel = @"返回";
    [leftBtn addTarget:self action:@selector(back) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem *item_left = [[UIBarButtonItem alloc] initWithCustomView:leftBtn];
    self.navigationItem.leftBarButtonItem = item_left;
    
    UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
    [btn setTitleColor:nTextColorMain forState:UIControlStateNormal];
    [btn setTitle:@"发送" forState:UIControlStateNormal];
    [btn addTarget:self action:@selector(actionSend) forControlEvents:UIControlEventTouchUpInside];
    btn.titleLabel.font = [UIFont systemFontOfSize:15.0f];
    [btn sizeToFit];
    UIBarButtonItem *item = [[UIBarButtonItem alloc] initWithCustomView:btn];
    self.navigationItem.rightBarButtonItem = item;
    
    if (self.isFeedbackVC) {
        
    }
    else{
        [self.view addSubview:self.voicebtn];
        [self.view addSubview:self.voicetimeLabel];
        [self.view addSubview:self.deleteVoiceButton];
        [self.view addSubview:self.recordVoiceButton];
        [self.voicebtn setHidden:YES];
        [self.voicetimeLabel setHidden:YES];
        [self.deleteVoiceButton setHidden:YES];
        recording = NO;
        
    }
    _playtime = nil;
    self.send = NO;
    
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(huishoujianpan:) name:@"huishoujianpan" object:nil];
    
}
- (void)back {
    [self.navigationController popViewControllerAnimated:YES];
}
-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    [[NSNotificationCenter defaultCenter] addObserver:self
											 selector:@selector(handleWillShowKeyboard:)
												 name:UIKeyboardWillShowNotification
                                               object:nil];
    
	[[NSNotificationCenter defaultCenter] addObserver:self
											 selector:@selector(handleWillHideKeyboard:)
												 name:UIKeyboardWillHideNotification
                                               object:nil];
    switch (self.inputType) {
        case 0: break;
        case 1: [self avatarTakePicture];  break;
        case 2: [self avatarChooseAlbum];  break;
        default: break;
    }
    
    IQKeyboardManager *manager = [IQKeyboardManager sharedManager];
    manager.enable = YES;
    manager.shouldResignOnTouchOutside = YES;
    manager.shouldToolbarUsesTextFieldTintColor = NO;
    manager.enableAutoToolbar = NO;
}

- (void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    [timer invalidate];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillShowNotification object:nil];
	[[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillHideNotification object:nil];
    [IQKeyboardManager sharedManager].enable = NO;
}

-(void)viewDidDisappear:(BOOL)animated{
    [super viewDidDisappear:animated];
}

-(void)dealloc{
}

- (void)actionAutoBack:(UIBarButtonItem *)barItem{
    [self actionCancel];
}

//- (NSMutableArray *)assets{
//    if (_assets == nil) {
//        _assets = [[NSMutableArray alloc] init];
//    }
//    return _assets;
//}

- (UIButton *)voicebtn{
    if (_voicebtn == nil) {
        _voicebtn = [UIButton buttonWithType:UIButtonTypeCustom];
        [_voicebtn setFrame:CGRectMake(20, 130, 80, 30)];
        [_voicebtn setBackgroundImage:[UIImage imageNamed:@"voice"] forState:UIControlStateNormal];
        [_voicebtn addSubview:self.voiceImgV];
        UILabel *tipLabel = [[UILabel alloc]initWithFrame:CGRectMake(30, 5, 50, 20)];
        [tipLabel setText:@"点击播放"];
        [tipLabel setFont:[UIFont systemFontOfSize:10.0]];
        [tipLabel setTextColor:[UIColor whiteColor]];
        [_voicebtn addSubview:tipLabel];
        [_voicebtn addTarget:self action:@selector(playVoiceAction:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _voicebtn;
}

-(UIImageView *)voiceImgV{
    if ( _voiceImgV == nil) {
        _voiceImgV = [[UIImageView alloc]initWithFrame:CGRectMake(10, 7.5, 15, 15)];
        [_voiceImgV setImage:[UIImage imageNamed:@"v_anim4"]];
        
    }
    return _voiceImgV;
}

- (UILabel *)voicetimeLabel {
    if (_voicetimeLabel == nil) {
        _voicetimeLabel = [[UILabel alloc]initWithFrame:CGRectMake(self.voicebtn.frame.origin.x + self.voicebtn.frame.size.width + 5, self.voicebtn.frame.origin.y , 20, 30)];
        [_voicetimeLabel setFont:gFontSub11];
        [_voicetimeLabel setTextColor:gTextColorSub];
        [_voicetimeLabel setText:@"60''"];
    }
    return _voicetimeLabel;
}

- (UIButton *)deleteVoiceButton {
    if (_deleteVoiceButton == nil) {
        _deleteVoiceButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [_deleteVoiceButton setFrame:CGRectMake(self.voicetimeLabel.frame.origin.x + self.voicetimeLabel.frame.size.width + 10, self.voicebtn.frame.origin.y , 40, 30)];
        [_deleteVoiceButton setTitle:@"删除" forState:UIControlStateNormal];
        [_deleteVoiceButton.titleLabel setFont:gFontMain13];
        [_deleteVoiceButton setTitleColor:[UIColor lightGrayColor] forState:UIControlStateNormal];
        [_deleteVoiceButton addTarget:self action:@selector(deleteVoiceButton:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _deleteVoiceButton;
}

- (UIButton *)recordVoiceButton {
    if (_recordVoiceButton == nil) {
        _recordVoiceButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [_recordVoiceButton setFrame:CGRectMake(30, SCREEN_HEIGHT -  140, SCREEN_WIDTH - 60, 30)];
        [_recordVoiceButton setTitle:@"按住录音" forState:UIControlStateNormal];
        [_recordVoiceButton.layer setBorderWidth:0.5];
        [_recordVoiceButton.layer setMasksToBounds:YES];
        [_recordVoiceButton.layer setCornerRadius:5.0];
        [_recordVoiceButton.layer setBorderColor:gTextColorSub.CGColor];
        [_recordVoiceButton setTitleColor:[UIColor lightGrayColor] forState:UIControlStateNormal];
        //给按住说话 按钮添加手势
        UILongPressGestureRecognizer *guesture = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(handSpeakBtnPressed:)];
        guesture.delegate = self;
        guesture.minimumPressDuration = 0.01f;
        
        //录音按钮添加手势操作
        [_recordVoiceButton addGestureRecognizer:guesture];
    }
    return _recordVoiceButton;
}

-(UIImageView *)remindImg
{
    if (_remindImg == nil)
    {
        _remindImg = [[UIImageView alloc]initWithFrame:CGRectMake(0, 0, 144, 144)];
//        _remindImg.image = [UIImage imageNamed:@"play_pressed"];
        _remindImg.backgroundColor = [UIColor lightGrayColor];
        _remindImg.center = self.view.center;
        [_remindImg addSubview:self.remindMacImg];
        [_remindImg addSubview:self.reminVoiceImg];
        [_remindImg addSubview:self.reminWarnImg];
        [_remindImg addSubview:self.remindLab];
    }
    return _remindImg;
}
-(UIImageView *)remindMacImg
{
    if (_remindMacImg == nil)
    {
        _remindMacImg = [[UIImageView alloc]initWithFrame:CGRectMake(10, 20, 72, 100)];
        _remindMacImg.image = [UIImage imageNamed:@"RecordingBkg"];
        _remindMacImg.hidden = YES;
    }
    return _remindMacImg;
}
-(UIImageView *)reminVoiceImg{
    if (_reminVoiceImg == nil){
        _reminVoiceImg = [[UIImageView alloc]initWithFrame:CGRectMake(82, 22, 38, 100)];
        _reminVoiceImg.image = [UIImage imageNamed:@"RecordingSignal001"];
        _reminVoiceImg.hidden = YES;
    }
    return _reminVoiceImg;
}

-(UIImageView *)reminWarnImg
{
    if (_reminWarnImg == nil)
    {
        _reminWarnImg = [[UIImageView alloc]initWithFrame:CGRectMake(20, 20, 100, 100)];
        _reminWarnImg.hidden = YES;
    }
    return _reminWarnImg;
}
-(UILabel *)remindLab
{
    if (_remindLab == nil)
    {
        CGFloat x = self.remindImg.frame.size.width;
        CGFloat y = self.remindImg.frame.size.height;
        _remindLab = [[UILabel alloc]initWithFrame:CGRectMake(10, y-30, x-20, 20)];
        _remindLab.textColor = [UIColor whiteColor];
        _remindLab.font = [UIFont systemFontOfSize:14.0f];
        _remindLab.textAlignment = 1;
    }
    return _remindLab;
}

#define EmbedBlogTextIdentifier @"EmbedBlogTextIdentifier"

-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender{
    [super prepareForSegue:segue sender:sender];
    if ([segue.identifier isEqualToString:EmbedBlogTextIdentifier]){
        NewQATextController * dest = segue.destinationViewController;
        self.qaTextController = (NewQATextController *)dest;
        if (self.maxContentLength <= 0) {
            self.maxContentLength = 1024;
        }
        dest.maxContentLength = self.maxContentLength;
        if (self.textFieldPlaceHolderString) {
            dest.placeHolderString = self.textFieldPlaceHolderString;
        }
        if (self.hideSelectStaffItem) {
            dest.isAddNewQuestion = NO;
        }
        else{
            dest.isAddNewQuestion = YES;
        }
        dest.qaController = self;
    }
}

#pragma mark - Keyboard notifications

- (void)handleWillShowKeyboard:(NSNotification *)notification{
    [self keyboardWillShowHide:notification];
}

- (void)handleWillHideKeyboard:(NSNotification *)notification{
    [self keyboardWillShowHide:notification];
}

- (void)keyboardWillShowHide:(NSNotification *)notification{
    CGRect keyboardRect = [[notification.userInfo objectForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue];
	UIViewAnimationCurve curve = [[notification.userInfo objectForKey:UIKeyboardAnimationCurveUserInfoKey] integerValue];
	double duration = [[notification.userInfo objectForKey:UIKeyboardAnimationDurationUserInfoKey] doubleValue];
    
    [UIView animateWithDuration:duration
                          delay:0.0f
                        options:[UIView animationOptionsForCurve:curve]
                     animations:^{
                         CGFloat keyboardY = [self.view convertRect:keyboardRect fromView:nil].origin.y;
                         
                         CGRect inputViewFrame = self.toolBarView.frame;
                         CGFloat inputViewFrameY = keyboardY - inputViewFrame.size.height;
                         
                         // for ipad modal form presentations
                         CGFloat messageViewFrameBottom = self.view.frame.size.height - self.toolBarView.height;
                         if(inputViewFrameY > messageViewFrameBottom)
                             inputViewFrameY = messageViewFrameBottom;
                         
                         self.toolBarView.frame = CGRectMake(inputViewFrame.origin.x,
                                                         inputViewFrameY,
                                                         inputViewFrame.size.width,
                                                         inputViewFrame.size.height);
                         
                     }
                     completion:^(BOOL finished) {
                     }];
}

- (void)huishoujianpan:(NSNotification *)notification {
//    [self.view endEditing:YES];
    [self.qaTextController.txBlogText resignFirstResponder];
}

#pragma mark - PublicMethod

- (void)clearContentWithKeywordArray:(NSArray *)keywardArray{
    NSMutableString *content = [NSMutableString stringWithString:self.qaTextController.txBlogText.text];
    for (NSString *string in keywardArray) {
        NSString *placeString = @"";
        for (NSInteger i = 0; i < string.length; i++) {
            placeString = [placeString stringByAppendingString:@"*"];
        }
        [content replaceOccurrencesOfString:string withString:placeString options:NSCaseInsensitiveSearch range:NSMakeRange(0, content.length)];
    }
    self.qaTextController.txBlogText.text = content;
}

- (void)hideSelectPeopleItem:(BOOL)hide{
    self.hideSelectStaffItem = hide;
}

- (void)hideToolBar:(BOOL)hide{
    self.hideToolBar = hide;
}

#pragma mark - UI action

//发送
- (void)actionSend{
    [SVProgressHUD setDefaultMaskType:SVProgressHUDMaskTypeBlack];
    [SVProgressHUD showWithStatus:@"发送中..."];
    NSString *trimString = [self.qaTextController.txBlogText.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    NSInteger minLength = self.minContnetLength == 0 ? 1 : self.minContnetLength;
    
    if (trimString.length < minLength && [self.blogPictureController.arrayOfPictures count] == 0) {
//        if (self.lengthLimitedTips) {
//            [SVProgressHUD showErrorWithStatus:self.lengthLimitedTips];
//        }
//        else{
            [SVProgressHUD showErrorWithStatus:@"消息不能为空！"];
            [self performSelector:@selector(SVPDismiss) withObject:nil afterDelay:1.0];
//        }
        return;
    }
    if ([self.blogPictureController.arrayOfPictures count] > 9) {
        [SVProgressHUD showErrorWithStatus:@"最多只能上传9张图片"];
        [self performSelector:@selector(SVPDismiss) withObject:nil afterDelay:1.0];
        return;
    }
    
    NSString * content = self.qaTextController.txBlogText.text;
    if ([self.delegate respondsToSelector:@selector(newQAController:sendNewQA:attachments:location:address:MpvoiceURL:MpvoicePlaytime:)]) {
        if (self.isFeedbackVC) {
            [self.delegate newQAController:self sendNewQA:content attachments:self.blogPictureController.arrayOfPictures location:self.location address:self.addressLabel.text MpvoiceURL:nil MpvoicePlaytime:nil];
            return;
        }
        else{
            if (self.voicebtn.hidden) {
                [self.delegate newQAController:self sendNewQA:content attachments:self.blogPictureController.arrayOfPictures location:self.location address:self.addressLabel.text MpvoiceURL:nil MpvoicePlaytime:nil];
                return;
            }
            else{
               [self.delegate newQAController:self sendNewQA:content attachments:self.blogPictureController.arrayOfPictures location:self.location address:self.addressLabel.text MpvoiceURL:tmpFile MpvoicePlaytime:_playtime];
                return;
            }
        }
        
    }
    [self.qaTextController adjustLayout];
}


#pragma mark - UIButtonAction

- (IBAction)actionAtSomeone:(id)sender{
//    EditSelectUserController *vc = [EditSelectUserController loadFromSB];
//    vc.delegate = self;
//    vc.staffs = self.staffs;
//    [self presentViewController:embedInNavi(vc) animated:YES completion:nil];
//    
//    ContactsController *contactController = [[ContactsController alloc] initWithNibName:@"ContactsController" bundle:nil];
//    contactController.title = @"邀请回答";
//    contactController.delegate = self;
//    contactController.selectedStaffs = self.staffs;
//    [self presentViewController:embedInNavi(contactController) animated:YES completion:nil];
}

- (IBAction)actionSelectPhoto:(id)sender{
    
    if ([self.blogPictureController.arrayOfPictures count] >= 9) {
        [SVProgressHUD showErrorWithStatus:@"最多只能选择9张图片"];
        [self performSelector:@selector(SVPDismiss) withObject:nil afterDelay:1.0];
    }
    else{
        [self.view endEditing:YES];
        DefineWeakSelf;
        [UIActionSheet actionSheetWithTitle:nil message:nil buttons:@[@"拍照", @"从手机相册中选择"] showInView:self.view onDismiss:^(int buttonIndex) {
            if (buttonIndex == 0) {
                
                [weakSelf avatarTakePicture];
            }
            else{
                [weakSelf avatarChooseAlbum];
            }
        } onCancel:^{
            
        }];
    }
}

- (void)avatarTakePicture{
    if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]){
        UIImagePickerController * imgCtrl = [[UIImagePickerController alloc] init];
        imgCtrl.sourceType = UIImagePickerControllerSourceTypeCamera;
        imgCtrl.delegate = self;
        imgCtrl.allowsEditing = YES;
        [self presentViewController:imgCtrl animated:YES completion:^{
        }];
    }
}

- (void)avatarChooseAlbum{
    CTAssetsPickerController *picker = [[CTAssetsPickerController alloc] init];
    picker.maximumNumberOfSelection = 9 - [self.blogPictureController.arrayOfPictures count];
    picker.assetsFilter = [ALAssetsFilter allAssets];
    picker.delegate = self;
    [self presentViewController:picker animated:YES completion:NULL];
}

- (void)playVoiceAction:(UIButton *)voiceButton {
    //设置帧动画的图片数组
    self.voiceImgV.animationImages = [NSArray arrayWithObjects:
                                      [UIImage imageNamed:@"v_anim2"],
                                      [UIImage imageNamed:@"v_anim3"],
                                      [UIImage imageNamed:@"v_anim4"],nil];
    //设置帧动画播放时长
    [self.voiceImgV setAnimationDuration:1.0];
    //设置帧动画播放次数
    [self.voiceImgV setAnimationRepeatCount:[_playtime integerValue]];
    
    //如果动画正在播放就不会继续播放下一个动画
    if (self.voiceImgV.isAnimating) {
        return;
    }
    else{
        [self.voiceImgV startAnimating];
    }
    //播放语音
    //获取单例
    AVAudioSession *avSession = [AVAudioSession sharedInstance];
    //重新设置策略，不然播放的声音会很小
    [avSession setCategory:AVAudioSessionCategoryPlayback error:nil];
    //重新设置为活动状态
    [avSession setActive:YES error:nil];
    NSError *error = nil;
    audioPlayer = [[AVAudioPlayer alloc]initWithContentsOfURL:tmpFile error:&error];
    audioPlayer.volume = 1;
    if (error) {
        NSLog(@"error:%@",[error description]);
        return;
    }
    //准备播放
    [audioPlayer prepareToPlay];
    [audioPlayer play];
    
}

- (void)deleteVoiceButton:(UIButton *)sender {
    [self.voicebtn setHidden:YES];
    [self.voicetimeLabel setHidden:YES];
    [self.deleteVoiceButton setHidden:YES];
}

- (void)handSpeakBtnPressed:(UILongPressGestureRecognizer *)gestureRecognizer {
    self.reminVoiceImg.hidden = NO;
    self.remindMacImg.hidden = NO;
    self.reminWarnImg.hidden = YES;
    CGFloat min_x = 30;
    CGFloat max_x = IPHONE_W-70;
    CGFloat min_y = self.recordVoiceButton.frame.origin.y;
    CGFloat max_y = self.recordVoiceButton.frame.origin.y + 30;
    CGPoint touchPoint =  [gestureRecognizer locationInView:self.view];
    
    AVAudioSession *audioSession = [AVAudioSession sharedInstance];
    if (gestureRecognizer.state == UIGestureRecognizerStateBegan) {
        [self.recordVoiceButton setTitle:@"松开结束" forState:UIControlStateNormal];
        //开始录音
//        [self start:nil];
        if (!recording) {
            recording = YES;
            [audioSession setCategory:AVAudioSessionCategoryRecord error:nil];
            [audioSession setActive:YES error:nil];
            [self.recordVoiceButton setTitle:@"松开结束" forState:UIControlStateNormal];
            [self.view addSubview:self.remindImg];
            self.remindLab.text = @"手指上划 结束录音";
            NSDictionary *setting = [[NSDictionary alloc]initWithObjectsAndKeys:
                                     [NSNumber numberWithFloat:16000.0],AVSampleRateKey,//采样率
                                     [NSNumber numberWithInt:kAudioFormatMPEG4AAC],AVFormatIDKey,//数据格式
                                     [NSNumber numberWithInt:16],AVLinearPCMBitDepthKey,//位深
                                     [NSNumber numberWithInt:1],AVNumberOfChannelsKey,//声道数
                                     [NSNumber numberWithBool:NO],AVLinearPCMIsBigEndianKey,
                                     [NSNumber numberWithBool:NO],AVLinearPCMIsFloatKey, nil];
            tmpFile = [NSURL fileURLWithPath:[NSTemporaryDirectory() stringByAppendingPathComponent:[NSString stringWithFormat:@"%@.%@",@"tempRecord",@"aac"]]];
            recorder = [[AVAudioRecorder alloc]initWithURL: tmpFile settings:setting error:nil];
            [recorder setDelegate:self];
            
            [recorder prepareToRecord];
            [recorder record];
            [timer invalidate];
            //监听录音音量大小
            timer = nil;
            timer = [NSTimer scheduledTimerWithTimeInterval:0.01f target:self selector:@selector(changeTheVioceBSImgAction) userInfo:nil repeats:YES];
            [[NSRunLoop currentRunLoop]addTimer:timer forMode:NSRunLoopCommonModes];
            
        }
        else{
            recording = NO;
            [audioSession setActive:NO error:nil];
            [recorder stop];
            [self.recordVoiceButton setTitle:@"按住说话" forState:UIControlStateNormal];
        }
        
    }
    else if (gestureRecognizer.state == UIGestureRecognizerStateChanged) {
        NSLog(@"UIGestureRecognizerStateChanged");
        
        if (min_x <= touchPoint.x && max_x >= touchPoint.x && min_y <= touchPoint.y && max_y >= touchPoint.y) {
            self.remindLab.text = @"手指上划 结束录音";
            
            self.reminWarnImg.hidden = YES;
            self.remindMacImg.hidden = NO;
            self.reminVoiceImg.hidden = NO;
            self.remindMacImg.image = [UIImage imageNamed:@"RecordingBkg"];
            self.reminVoiceImg.image = [UIImage imageNamed:@"RecordingSignal001"];
        }
        else{
            self.remindLab.text = @"松开手指 结束录音";
            self.reminWarnImg.hidden = NO;
            self.remindMacImg.hidden = YES;
            self.reminVoiceImg.hidden = YES;
            
            self.reminWarnImg.image = [UIImage imageNamed:@"RecordCancel"];
            
        }
    }
    else if (gestureRecognizer.state == UIGestureRecognizerStateEnded) {
        NSLog(@"UIGestureRecognizerStateEnded");
        
        NSData *data = [[NSData alloc]initWithContentsOfFile:tmpFile.path];
        NSError *err=nil;
        audioPlayer =[[AVAudioPlayer  alloc]initWithData:data error:&err];
        NSInteger voiceDuration = audioPlayer.duration;
        if (voiceDuration == 0)
        {
//            self.remindLab.text = @"时间太短了!";
            self.remindMacImg.hidden = YES;
            self.reminVoiceImg.hidden = YES;
            self.reminWarnImg.hidden = NO;
            self.reminWarnImg.image = [UIImage imageNamed:@"gantanhao"];
            [self performSelector:@selector(delayRemove) withObject:nil afterDelay:0.5f];
            [self.recordVoiceButton setTitle:@"按住说话" forState:UIControlStateNormal];
            //结束录音
            recording = NO;
            [audioSession setActive:NO error:nil];
            [recorder stop];
            [self.recordVoiceButton setTitle:@"按住说话" forState:UIControlStateNormal];
        }else
        {
            if ([self.remindLab.text isEqualToString:@"松开手指 结束录音"])
            {
                //取消录音;
                [self.remindImg removeFromSuperview];
                [self.recordVoiceButton setTitle:@"按住说话" forState:UIControlStateNormal];
                //结束录音
                recording = NO;
                [audioSession setActive:NO error:nil];
                [recorder stop];
                [self.recordVoiceButton setTitle:@"按住说话" forState:UIControlStateNormal];
                
            }else
            {
                //结束录音,保存并发送
                [self.remindImg removeFromSuperview];
                NSLog(@"成功录音");
                [self.recordVoiceButton setTitle:@"按住说话" forState:UIControlStateNormal];
                //结束录音
                recording = NO;
                [audioSession setActive:NO error:nil];
                [recorder stop];
                [self.recordVoiceButton setTitle:@"按住说话" forState:UIControlStateNormal];
            }
        }
    }
}

//开始录音
- (void)start:(UIButton *)btn {
    // 文件名以时间命名
    int x = arc4random() % 100000;
    NSTimeInterval time = [[NSDate date] timeIntervalSince1970];
    NSString *fileName = [NSString stringWithFormat:@"%d%d",(int)time,x];
    AVAudioSession *audioSession = [AVAudioSession sharedInstance];
    if (!recording) {
        recording = YES;
        [audioSession setCategory:AVAudioSessionCategoryRecord error:nil];
        [audioSession setActive:YES error:nil];
        [self.recordVoiceButton setTitle:@"松开结束" forState:UIControlStateNormal];
        
        NSDictionary *setting = [[NSDictionary alloc]initWithObjectsAndKeys:
                                 [NSNumber numberWithFloat:44100.0],AVSampleRateKey,//采样率
                                 [NSNumber numberWithInt:kAudioFormatMPEG4AAC],AVFormatIDKey,//数据格式
                                 [NSNumber numberWithInt:8],AVLinearPCMBitDepthKey,//位深
                                 [NSNumber numberWithInt:1],AVNumberOfChannelsKey,//声道数
                                 [NSNumber numberWithBool:NO],AVLinearPCMIsBigEndianKey,
                                 [NSNumber numberWithBool:NO],AVLinearPCMIsFloatKey, nil];
        tmpFile = [NSURL fileURLWithPath:[NSTemporaryDirectory() stringByAppendingPathComponent:[NSString stringWithFormat:@"%@.%@",fileName,@"aac"]]];
        recorder = [[AVAudioRecorder alloc]initWithURL: tmpFile settings:setting error:nil];
        [recorder setDelegate:self];
        
        [recorder prepareToRecord];
        [recorder record];
    }
    else{
        recording = NO;
        [audioSession setActive:NO error:nil];
        [recorder stop];
        [self.recordVoiceButton setTitle:@"按住说话" forState:UIControlStateNormal];
    }
}

// 结束录音
- (void)stop:(UIButton *)btn {
    recording = NO;
//    [audioSession setActive:NO error:nil];
    [recorder stop];
    [self.recordVoiceButton setTitle:@"按住说话" forState:UIControlStateNormal];
}


#pragma mark - AVAudioRecorderDelegate

- (void)audioRecorderDidFinishRecording:(AVAudioRecorder *)recorder successfully:(BOOL)flag {
     [timer invalidate];
    AVURLAsset* audioAsset = [AVURLAsset URLAssetWithURL:tmpFile options:nil];
    CMTime audioDuration = audioAsset.duration;
    float audioDurationSeconds =CMTimeGetSeconds(audioDuration);
    _playtime = [NSString stringWithFormat:@"%.2f",audioDurationSeconds];
    self.voicetimeLabel.text = [NSString stringWithFormat:@"%.0f''",audioDurationSeconds];
    [self.voicebtn setHidden:NO];
    [self.voicetimeLabel setHidden:NO];
    [self.deleteVoiceButton setHidden:NO];
}

#pragma mark - CTAssetsPickerControllerDelegate

- (void)assetsPickerController:(CTAssetsPickerController *)picker didFinishPickingAssets:(NSArray *)assets{
    self.inputType = 0;
    DefineWeakSelf;
//    for (ALAsset *asset in assets) {
//        ALAssetRepresentation *assetRep = [asset defaultRepresentation];
//        CGImageRef imgRef = [assetRep fullResolutionImage];
//        UIImage *img = [UIImage imageWithCGImage:imgRef
//                                           scale:assetRep.scale
//                                     orientation:(UIImageOrientation)assetRep.orientation];
//
//        //分辨率限制1000，文件大小限制在500K
////        [self.assets addObject:[UIImage imageWithData:imageData]];
//    }
    [self.blogPictureController loadAssets:assets completion:^{
        [weakSelf.qaTextController adjustLayout];
    }];
}
- (void)assetsPickerControllerDidCancel:(CTAssetsPickerController *)picker {
    self.inputType = 0;
}

#pragma mark - UIImagePickerControllerDelegate

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info{
    self.inputType = 0;
    DefineWeakSelf;
    [self dismissViewControllerAnimated:YES
                             completion:^{
                                 UIImage * img = [info objectForKey:UIImagePickerControllerEditedImage];
                                 [weakSelf.blogPictureController addImage:img completion:^{
                                     [weakSelf.qaTextController adjustLayout];
                                 }];
                             }];
}

#pragma mark - UtilityMethod

/**
 *  压缩图片
 *
 *  @param rawImg 原始图片
 *
 *  @return 压缩完的图片
 */
- (UIImage *)compressImage:(UIImage *)rawImg{
    UIImage *imgCompressed = [rawImg imageWithScaledToSize:CGSizeMake(500, 500)];
    return imgCompressed;
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker{
     self.inputType = 0;
    [self dismissViewControllerAnimated:YES completion:nil];
}

//#pragma mark - ContactsControllerDelegate
//
//- (void)contactsController:(ContactsController *)vc selectedContacters:(NSArray *)contacters{
//    for (StaffModel *staff in contacters) {
//        [AddressBook addNewlyStaffs:staff];
////        [self.qaTextController atSomeOne:staff];
//    }
//    
//    [self dismissViewControllerAnimated:YES completion:nil];
//    
//    self.staffs = contacters;
//    [self dismissViewControllerAnimated:YES completion:nil];
//    define_weakself;
//    [self.selectUserController updateViewWithSelectStaffs:contacters finsih:^(BOOL finish) {
//        if (finish) {
//            [weakSelf.qaTextController adjustLayout];
//        }
//    }];
//}

//#pragma mark - EditSelectUserControllerDelegate
//
//- (void)editSelectUserController:(EditSelectUserController *)controller didFinfishSelectContacts:(NSArray *)contacts{
//    self.staffs = contacts;
//    [self dismissViewControllerAnimated:YES completion:nil];
//    define_weakself;
//    [self.selectUserController updateViewWithSelectStaffs:contacts finsih:^(BOOL finish) {
//        if (finish) {
//            [weakSelf.qaTextController adjustLayout];
//        }
//    }];
//}
//
//- (void)editSelectUserControllerDidCancel:(EditSelectUserController *)controller{
//    [self dismissViewControllerAnimated:YES completion:^{
//        
//    }];
//}

- (void)actionCancel {
    [self.view endEditing:YES];

    if ([self.qaTextController.txBlogText.text length] == 0
        && [self.blogPictureController.arrayOfPictures count] == 0){
        [super actionAutoBack:nil];
        return;
    }
    
    if (IOS_VERSION_GREATER_THAN(@"8.0")){
        UIAlertController *alertController = [UIAlertController alertControllerWithTitle:nil
                                                                                  message:@"放弃编辑的内容？"
                                                                           preferredStyle:UIAlertControllerStyleAlert];
        DefineWeakSelf;
        UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"取消"
                                                                style:UIAlertActionStyleCancel
                                                              handler:^(UIAlertAction *action) {
                                                                  [weakSelf.qaTextController.txBlogText becomeFirstResponder];
                                                              }];
        
        [alertController addAction:cancelAction];
        
        
        UIAlertAction *giveUpAction = [UIAlertAction actionWithTitle:@"放弃"
                                                                style:UIAlertActionStyleDefault
                                                              handler:^(UIAlertAction *action) {
                                                                      [super actionAutoBack:nil];
                                                              }];
        
        [alertController addAction:giveUpAction];
        
        [self presentViewController:alertController animated:YES completion:nil];
    }
    else{
        DefineWeakSelf;
        [UIAlertView alertViewWithTitle:nil
                                message:@"放弃编辑的内容？"
                      cancelButtonTitle:@"取消"
                      otherButtonTitles:@[@"放弃"]
                              onDismiss:^(int buttonIndex) {
                                  
                                  [super actionAutoBack:nil];
                              }
                               onCancel:^{
                                   [weakSelf.qaTextController.txBlogText becomeFirstResponder];
                               }];
    }
}

- (BOOL)swipeAble{
    return YES;
}

- (void)SVPDismiss {
    [SVProgressHUD dismiss];
}

-(void)changeTheVioceBSImgAction{
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        [recorder updateMeters]; //刷新音量值
        
        double lowPassResults = pow(10, (0.05 * [recorder peakPowerForChannel:0]));
        
        NSLog(@"lowPassResults = %f",lowPassResults);
        //最大50  0
        dispatch_async(dispatch_get_main_queue(), ^{
            if (0<lowPassResults<=0.1) {
                self.reminVoiceImg.image = [UIImage imageNamed:@"v1"];
            }else if (0.1<lowPassResults<=0.2) {
                self.reminVoiceImg.image = [UIImage imageNamed:@"v2"];
            }else if (0.2<lowPassResults<=0.3) {
                self.reminVoiceImg.image = [UIImage imageNamed:@"v3"];
            }else if (0.3<lowPassResults<=0.4) {
                self.reminVoiceImg.image = [UIImage imageNamed:@"v4"];
            }else if (0.4<lowPassResults<=0.5) {
                self.reminVoiceImg.image = [UIImage imageNamed:@"v5"];
            }else if (0.5<lowPassResults<=0.6) {
                self.reminVoiceImg.image = [UIImage imageNamed:@"v6"];
            }else{
                self.reminVoiceImg.image = [UIImage imageNamed:@"v7"];
            }
        });
    });
}

-(void)delayRemove{
    [self.remindImg removeFromSuperview];
}


- (void)uploadMpvoiceAction:(UIButton *)sender {
    
    NSMutableDictionary *dic = [[NSMutableDictionary alloc]initWithCapacity:1];
    dic[@"accessToken"] = [DSE encryptUseDES:ExdangqianUser];
    dic[@"playtime"] = _playtime;
    AFHTTPRequestOperationManager *manager = [[AFHTTPRequestOperationManager alloc] initWithBaseURL:[NSURL URLWithString:uploadMpVoiceURLStr]];
    manager.responseSerializer = [AFJSONResponseSerializer serializer];
    manager.responseSerializer.acceptableContentTypes = [NSSet setWithObjects:@"text/html",nil];
    
    manager.requestSerializer.timeoutInterval = 30.0;
    
    [manager POST:uploadMpVoiceURLStr parameters:dic constructingBodyWithBlock:^(id<AFMultipartFormData> formData) {
//        if (tmpFile && ![tmpFile isEqualToString:@""]) {
            NSData *imageData = [NSData dataWithContentsOfFile:tmpFile.path];
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
        
        NSLog(@"%@",responseString);
        
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"%@",error);
    }];
    
    
    
    
    
}

@end
