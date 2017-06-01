//
//  BlogTableViewCell.m
//  Broker
//
//  Created by Eric Wang on 15/10/11.
//  Copyright (c) 2015年 Eric. All rights reserved.
//

#import "BlogTableViewCell.h"
#import "UIImageView+WebCache.h"
#import "UIView+tap.h"
#import "NSDate+TimeFormat.h"

#import "NSDateFormatter+Category.h"
#import "NSDate+TimeFormat.h"

//1张图片的最大宽度
#define OneImageMaxWidht 200
//1张图片的最大高度
#define OneImageMaxHeight 200

#define URL(httpurl) [NSURL URLWithString:httpurl]

static NSString *const kUserIDKey = @"UserID";
static NSString *const kUserNameKey = @"UserName";

@interface BlogTableViewCell ()<TTTAttributedLabelDelegate>

@property (weak, nonatomic) IBOutlet UIImageView *headImageView;
@property (weak, nonatomic) IBOutlet UIView *commentView;
@property (weak, nonatomic) IBOutlet UILabel *timeLabe;
@property (weak, nonatomic) IBOutlet UILabel *time;


@property (weak, nonatomic) IBOutlet UILabel *blogLabel;

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *blogImageHeightConstraint;

@property (weak, nonatomic) IBOutlet UIImageView *favIconImage;
@property (weak, nonatomic) IBOutlet UILabel *praiseNamesLabel;
@property (weak, nonatomic) IBOutlet UIView *praiseLine;

@property (weak, nonatomic) NSMutableDictionary *blog;
@property (assign, nonatomic) BOOL isFeebackBlog;
@property (assign, nonatomic) BOOL isUnreadMessage;

@property (weak, nonatomic) IBOutlet UIButton *deleteButton;

@property (weak, nonatomic) IBOutlet UIButton *zanButton;
@property (weak, nonatomic) IBOutlet UIButton *commentButton;

@property(strong,nonatomic)UIImageView *voiceImgV;
@property (strong, nonatomic) UILabel *tipLabel;

@property (weak, nonatomic) IBOutlet UILabel *voiceTimeLabel;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *voiceHeightConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *voiceWidthConstraint;


@property (weak, nonatomic) IBOutlet UIView *newsBackgroundView;
@property (weak, nonatomic) IBOutlet UIImageView *newsImage;
@property (weak, nonatomic) IBOutlet UILabel *newsTitle;
@property (weak, nonatomic) IBOutlet UILabel *newsDate;
@property (weak, nonatomic) IBOutlet UILabel *newsData;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *newsBgImageHeightConstraint;

@end

@implementation BlogTableViewCell

- (void)awakeFromNib {
    // Initialization code
//    [self.contentView mas_makeConstraints:^(MASConstraintMaker *make) {
//        make.left.mas_equalTo(0).priorityLow();
//        make.right.mas_equalTo(0).priorityLow();
//        make.top.mas_equalTo(0).priorityLow();
//        make.bottom.mas_equalTo(0).priorityLow();
//    }];
//    _blogLabel.preferredMaxLayoutWidth = SCREEN_WIDTH - 81;
    
    _headImageView.layer.cornerRadius = _headImageView.frame.size.width / 2;
    _headImageView.layer.masksToBounds = YES;
    _headImageView.userInteractionEnabled = YES;
    [_headImageView addTapGesWithTarget:self action:@selector(clickHead:)];
    [_headImageView addLongPressGesWithTarget:self action:@selector(longPressHead:)];
    _commentLabel.lineBreakMode = NSLineBreakByCharWrapping;
    [_nameLabe setTextColor:gMainColor];
    [_praiseNamesLabel setTextColor:gMainColor];
    [_praiseLine setBackgroundColor:[UIColor whiteColor]];
//    [_praiseLine setHidden:YES];
    [_zanButton setTitleColor:gMainColor forState:UIControlStateNormal];
    [_commentButton setTitleColor:gMainColor forState:UIControlStateNormal];
    [_deleteButton setTitleColor:gMainColor forState:UIControlStateNormal];
    [_newsBackgroundView setBackgroundColor:gNewsSubColor];
    [_newsData setTextColor:[UIColor grayColor]];
    [_newsDate setTextColor:[UIColor grayColor]];
    [_newsImage.layer setMasksToBounds:YES];
    [_newsImage.layer setCornerRadius:4.0];
    [_voiceButton addSubview:self.voiceImgV];
    [_voiceButton addSubview:self.tipLabel];

    UITapGestureRecognizer *playVoiceTapG = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(playVoiceAction:)];
    [_voiceButton addGestureRecognizer:playVoiceTapG];
    
}

-(UIImageView *)voiceImgV
{
    if ( _voiceImgV == nil) {
        _voiceImgV = [[UIImageView alloc]initWithFrame:CGRectMake(10, 10, 20, 20)];
        [_voiceImgV setImage:[UIImage imageNamed:@"v_anim4"]];
        
    }
    return _voiceImgV;
}

- (UILabel *)tipLabel {
    if (!_tipLabel) {
        _tipLabel = [[UILabel alloc]initWithFrame:CGRectMake(35, 10, 50, 20)];
        [_tipLabel setText:@"点击播放"];
        [_tipLabel setFont:[UIFont systemFontOfSize:12.0]];
        [_tipLabel setTextColor:[UIColor whiteColor]];
    }
    return _tipLabel;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void)updateCellWithBlog:(NSMutableDictionary *)blog andisFeebackBlog:(BOOL )isFeebackBlog andisUnreadMessage:(BOOL )isUnreadMessage{
    
    self.blog = blog;
    self.isFeebackBlog = isFeebackBlog;
    self.isUnreadMessage = isUnreadMessage;
    NSDictionary *user = self.blog[@"user"];
    //头像url处理
    if ([NEWSSEMTPHOTOURL(user[@"avatar"])  rangeOfString:@"http"].location != NSNotFound)
    {
        [_headImageView sd_setImageWithURL:[NSURL URLWithString:NEWSSEMTPHOTOURL(user[@"avatar"])] placeholderImage:AvatarPlaceHolderImage];
    }else
    {
        NSString *str = USERPHOTOHTTPSTRING(NEWSSEMTPHOTOURL(user[@"avatar"]));
        [_headImageView sd_setImageWithURL:[NSURL URLWithString:str] placeholderImage:AvatarPlaceHolderImage];
    }
    _nameLabe.text = [user[@"user_nicename"] length] ? user[@"user_nicename"] :user[@"user_login"];
    //判断是否有发布文字内容
    if ([self.blog[@"comment"] length]) {
        _blogLabel.fd_collapsed = NO;
    }
    else{
        _blogLabel.text = nil;
        _blogLabel.fd_collapsed = YES;
    }
    if (self.isUnreadMessage) {
        if ([self.blog[@"content"] rangeOfString:@"[e1]"].location != NSNotFound && [self.blog[@"content"] rangeOfString:@"[/e1]"].location != NSNotFound){
            self.blog[@"content"] = [CommonCode jiemiEmoji:self.blog[@"content"]];
        }
        _blogLabel.text = self.blog[@"content"];
    }
    else{
        if ([self.blog[@"comment"] rangeOfString:@"[e1]"].location != NSNotFound && [self.blog[@"comment"] rangeOfString:@"[/e1]"].location != NSNotFound){
            self.blog[@"comment"] = [CommonCode jiemiEmoji:self.blog[@"comment"]];
        }
        _blogLabel.text = self.blog[@"comment"];
    }
    //意见反馈
    if (isFeebackBlog) {
        CGSize hideSize = CGSizeMake(SCREEN_WIDTH - 90.0f, 0.0f);
        self.voiceImgV.hidden = YES;
        self.tipLabel.hidden = YES;
        _voiceHeightConstraint.constant = hideSize.height;
        _voiceButton.fd_collapsed = YES;
        _voiceTimeLabel.hidden = YES;
        _voiceTimeLabel.attributedText = nil;
        _voiceTimeLabel.fd_collapsed = YES;
        _newsImage = nil;
        _newsTitle.text = nil;
        _newsData.text = nil;
        _newsDate.text = nil;
        _newsBgImageHeightConstraint.constant = hideSize.height;
        _newsBackgroundView.fd_collapsed = YES;
    }
    else{
        //听友圈
        if (![self.blog[@"post_id"]isEqualToString:@"0"]) {
            CGSize voiceSize = CGSizeMake(68.0f, 0.0f);
            _voiceButton.fd_collapsed = YES;
            self.voiceImgV.hidden = YES;
            self.tipLabel.hidden = YES;
            _voiceWidthConstraint.constant = voiceSize.width;
            _voiceHeightConstraint.constant = voiceSize.height;
            _voiceTimeLabel.hidden = YES;
            _voiceTimeLabel.attributedText = nil;
            _voiceTimeLabel.fd_collapsed = YES;
            CGSize newsBgsize = CGSizeMake(SCREEN_WIDTH - 90.0f, 68.0f);
            _newsBgImageHeightConstraint.constant = newsBgsize.height;
            _newsBackgroundView.fd_collapsed = NO;
            
            
            NSString *aimgUrl = [NSString stringWithFormat:@"%@",[self.blog[@"post"][@"smeta"] stringByReplacingOccurrencesOfString:@"\\" withString:@""]];
            NSString *bimgUrl1 = [aimgUrl stringByReplacingOccurrencesOfString:@"\"" withString:@""];
            NSString *cimgUrl2 = [bimgUrl1 stringByReplacingOccurrencesOfString:@"thumb:" withString:@""];
            NSString *dimgUrl3 = [cimgUrl2 stringByReplacingOccurrencesOfString:@"{" withString:@""];
            NSString *eimgUrl4 = [dimgUrl3 stringByReplacingOccurrencesOfString:@"}" withString:@""];
            
            if ([eimgUrl4  rangeOfString:@"http"].location != NSNotFound){
                [_newsImage sd_setImageWithURL:[NSURL URLWithString:eimgUrl4] placeholderImage:NewsPlaceHolderImage];
            }
            else{
                NSString *str = USERPHOTOHTTPSTRINGZhuBo(eimgUrl4);
                [_newsImage sd_setImageWithURL:[NSURL URLWithString:str] placeholderImage:NewsPlaceHolderImage];
            }
            
            
            [_newsTitle setText:self.blog[@"post"][@"post_title"]];
            [_newsData setText:[NSString stringWithFormat:@"%.2lf%@",[self.blog[@"post"][@"post_size"] intValue] / 1024.0 / 1024.0,@"M"]];
            NSDate *date = [NSDate dateFromString:self.blog[@"post"][@"post_modified"]];
            _newsDate.text = [date showTimeByTypeA];

        }
        else{
//            _newsImage = nil;
            _newsTitle.text = nil;
            _newsData.text = nil;
            _newsDate.text = nil;
            CGSize newsBgsize = CGSizeMake(SCREEN_WIDTH - 90.0f, 0.0f);
            _newsBgImageHeightConstraint.constant = newsBgsize.height;
            _newsBackgroundView.fd_collapsed = YES;
            
            if ([self.blog[@"mp3_url"] isEmpty]) {
                CGSize hideSize = CGSizeMake(SCREEN_WIDTH - 90.0f, 0.0f);
                self.voiceImgV.hidden = YES;
                self.tipLabel.hidden = YES;
                _voiceHeightConstraint.constant = hideSize.height;
                _voiceButton.fd_collapsed = YES;
                _voiceTimeLabel.hidden = YES;
                _voiceTimeLabel.attributedText = nil;
                _voiceTimeLabel.fd_collapsed = YES;
            }
            else{
                CGSize voiceSize = CGSizeMake(80.0f, 40.0f);
                self.voiceImgV.hidden = NO;
                self.tipLabel.hidden = NO;
                _voiceButton.fd_collapsed = NO;
                _voiceHeightConstraint.constant = voiceSize.height;
                float voiceWidth = 80.0f;
                if ([self.blog[@"play_time"] integerValue] < 30) {
                    voiceWidth = ([self.blog[@"play_time"] integerValue] - 1 ) * 4.0 + 80.0;
                }
                else{
                    voiceWidth = 200.0f;
                }
                _voiceWidthConstraint.constant =voiceWidth;
                _voiceTimeLabel.text = [NSString stringWithFormat:@"%@''",self.blog[@"play_time"]];
                _voiceTimeLabel.hidden = NO;
                _voiceTimeLabel.fd_collapsed = NO;
                
//                CGSize hideSize = CGSizeMake(SCREEN_WIDTH - 10.0f, 0.0f);
//                self.voiceImgV.hidden = YES;
//                self.tipLabel.hidden = YES;
//                _voiceHeightConstraint.constant = hideSize.height;
//                _voiceButton.fd_collapsed = YES;
//                _voiceTimeLabel.attributedText = nil;
//                _voiceTimeLabel.fd_collapsed = YES;
            }
        }
    }
    
    //处理图片
     NSMutableArray *urls = [NSMutableArray new];
    if (isFeebackBlog) {
        if (![self.blog[@"images"] isEqualToString:@""]){
            NSArray *array = [self.blog[@"images"] componentsSeparatedByString:@","];
            for (int i = 0 ; i < array.count ; i ++ ) {
                [urls addObject:[NSURL URLWithString:[NSString stringWithFormat:@"http://admin.tingwen.me/%@", array[i]]]];
            }
        }
    }
    else{
        if (![self.blog[@"timages"] isEqualToString:@""]){
            NSArray *array = [self.blog[@"timages"] componentsSeparatedByString:@","];
            for (int i = 0 ; i < array.count ; i ++ ) {
                [urls addObject:[NSURL URLWithString:[NSString stringWithFormat:@"http://admin.tingwen.me/%@", array[i]]]];
            }
        }
    }
    NSArray *photos = urls;
    if ([photos count]) {
        _photosImageView.fd_collapsed = NO;
//        if ([photos count] == 1) {
//                    NSString *pat = [NSString stringWithFormat:@"%@", [photos firstObject]];
//                    NSURL *url = URL(pat);
//                    [[SDWebImageDownloader sharedDownloader]downloadImageWithURL:url options:SDWebImageDownloaderUseNSURLCache progress:^(NSInteger receivedSize, NSInteger expectedSize) {
//            
//                    } completed:^(UIImage *image, NSData *data, NSError *error, BOOL finished) {
//                        //这边就能拿到图片了
//                        if (image.size.width < OneImageMaxWidht && image.size.height < OneImageMaxHeight) {
//                            _blogImageHeightConstraint.constant = image.size.height;
//                            }
//                        else if (image.size.width > OneImageMaxWidht && image.size.height > OneImageMaxHeight){
//                             _blogImageHeightConstraint.constant = OneImageMaxHeight;
//                        }
//                        else if (image.size.width > OneImageMaxWidht){
//                            _blogImageHeightConstraint.constant = image.size.height;
//                        }
//                        else if (image.size.height > OneImageMaxHeight){
//                            _blogImageHeightConstraint.constant = OneImageMaxHeight;
//                        }
//                        else{
//                            _blogImageHeightConstraint.constant =  OneImageMaxHeight;
//                        }
//                    }];
//        }
//        else{
            CGSize size = [_photosImageView sizeForContent:photos];
            _blogImageHeightConstraint.constant = size.height;
//        }
        _photosImageView.images = photos;
    }
    else{
        _photosImageView.fd_collapsed = YES;
    }
    
    //时间戳转时间
    NSDateFormatter* formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"yyyy-MM-dd HH:mm"];
    NSString *timeStr = [self stringWithTime:[(self.blog[@"create_time"]) integerValue]];
    NSDate *date = isFeebackBlog ? [formatter dateFromString:timeStr] : [NSDate dateFromString:self.blog[@"createtime"]];
    _timeLabe.text = [date showTimeByTypeA];
    _timeLabe.fd_collapsed = YES;
    _timeLabe.hidden = YES;
    _time.text = [date showTimeByTypeA];

//    _deleteButton.hidden = !(blog.user_send.user_id == [AuthorManager currentLoginUser].user_id);
    ExdangqianUserUid = [CommonCode readFromUserD:@"dangqianUserUid"];
    if (!isFeebackBlog && [self.blog[@"uid"] isEqualToString:ExdangqianUserUid]) {
        _deleteButton.hidden = NO;
        _deleteButton.fd_collapsed = NO;
    }
    else{
        _deleteButton.hidden = YES;
        _deleteButton.fd_collapsed = YES;
    }
    
    [_praiseButton setImage:[UIImage imageNamed:@"me_mypage_me_list_ic_like"] forState:UIControlStateNormal];
    _praiseButton.userInteractionEnabled = YES;
 
    if (![isFeebackBlog ? self.blog[@"zan_num"] : self.blog[@"praisenum"] isEqualToString:@"0"]) {
        _praiseNamesLabel.fd_collapsed = NO;
        _praiseNamesLabel.text = [NSString stringWithFormat:@"%@人点赞",isFeebackBlog ? self.blog[@"zan_num"] : self.blog[@"praisenum"] ];
    }
    else{
        _praiseNamesLabel.text = nil;
        _praiseNamesLabel.fd_collapsed = YES;
    }
    
    if ([isFeebackBlog ? self.blog[@"is_zan"] :self.blog[@"zan"] integerValue] == 1) {
        [_praiseButton setImage:[UIImage imageNamed:@"me_mypage_me_list_ic_liked"] forState:UIControlStateNormal];
        _praiseButton.userInteractionEnabled = YES;
    }
    else if ([self.blog[@"is_zan"] integerValue] == 0){
        [_praiseButton setImage:[UIImage imageNamed:@"me_mypage_me_list_ic_like"] forState:UIControlStateNormal];
        _praiseButton.userInteractionEnabled = YES;
    }
    
    [_praiseLine setHidden:YES];
    _praiseLine.fd_collapsed = YES;
    
    if ([self.blog[@"child_comment"] isKindOfClass:[NSArray class]]) {
        _commentLabel.fd_collapsed = NO;
        _commentLabel.text = @"";
        if ([self.blog[@"child_comment"] count]) {
            NSMutableAttributedString *resultAttStr = [[NSMutableAttributedString alloc] init];
            for (int i = 0 ; i < [self.blog[@"child_comment"] count]; i ++) {
                NSMutableDictionary *commentDic = self.blog[@"child_comment"][i];
                NSMutableDictionary *user = commentDic[@"user"];
                 NSDictionary *to_user = commentDic[@"to_user"];
                NSRange user2Range;
                NSString *lastString =  @"\n";
                if (i == [self.blog[@"child_comment"] count] - 1) {
                    lastString = @"";
                }
                NSString *content = @"";
                if (isFeebackBlog ? [ commentDic[@"is_comment"] isEqualToString:@"0"] : ![[to_user allKeys] containsObject:@"id"]) {
                    content = [NSString stringWithFormat:@"%@:%@%@", [user[@"user_nicename"] length]? user[@"user_nicename"] : user[@"user_login"], commentDic[@"comment"], lastString];
                    //TODO:emoji解密
                    if ([content rangeOfString:@"[e1]"].location != NSNotFound && [content rangeOfString:@"[/e1]"].location != NSNotFound){
                            content = [CommonCode jiemiEmoji:content];
                        }
                    
                }
                else if (isFeebackBlog ? [ commentDic[@"is_comment"] isEqualToString:@"1"] : [[to_user allKeys] containsObject:@"id"]){
                    content = [NSString stringWithFormat:@"%@回复%@:%@%@", user[@"user_nicename"],[to_user[@"user_nicename"] length] ? to_user[@"user_nicename"]:to_user[@"user_login"], commentDic[@"comment"], lastString];
                    if ([content rangeOfString:@"[e1]"].location != NSNotFound && [content rangeOfString:@"[/e1]"].location != NSNotFound){
                        content = [CommonCode jiemiEmoji:content];
                    }
                    user2Range = NSMakeRange(([user[@"user_nicename"] length] ? [user[@"user_nicename"] length] : [user[@"user_login"] length]) + 2, ([to_user[@"user_nicename"] length] ? [to_user[@"user_nicename"] length] : [to_user[@"user_login"] length]));
                    
                }
                
                NSMutableAttributedString *attString = [[NSMutableAttributedString alloc] initWithString:content];
                NSMutableParagraphStyle *style = [[NSMutableParagraphStyle alloc] init];
                [style setLineSpacing:10];
                
                [resultAttStr appendAttributedString:attString];
                
            }
            [_commentLabel setFont:gFontMain15];
            _commentLabel.lineSpacing = 5;
            _commentLabel.attributedText = resultAttStr;
        }
    }
    else{
        _commentLabel.attributedText = nil;
        _commentLabel.fd_collapsed = YES;
    }
    
    
    //加上以下内容 cell重用时的高度错乱
//    if ((![isFeebackBlog ? self.blog[@"zan_num"] : self.blog[@"praisenum"] isEqualToString:@"0"]) && (![self.blog[@"child_comment"] isKindOfClass:[NSArray class]]) ) {
//        _commentView.fd_collapsed = NO;
//        _commentView.hidden = YES;
//    }
//    else {
//        _commentView.fd_collapsed = YES;
//        _commentView.hidden = NO;
//    }
//    _commentView.fd_collapsed = (![self.blog[@"child_comment"] isKindOfClass:[NSArray class]] && [self.blog[@"zan_num"] isEqualToString:@"0"]);
}

- (NSString *)stringWithTime:(NSTimeInterval)timestamp {
    //设置时间显示格式
    NSDateFormatter *formatter = [[NSDateFormatter alloc]init];
    [formatter setDateStyle:NSDateFormatterMediumStyle];
    [formatter setTimeStyle:NSDateFormatterShortStyle];
    //先设置好dateStyle、timeStyle,再设置格式
    [formatter setDateFormat:@"YYYY-MM-dd HH:mm"];
    NSDate *date = [NSDate dateWithTimeIntervalSince1970:timestamp];
    //将NSDate按格式转化为对应的时间格式字符串
    NSString *timesString = [formatter stringFromDate:date];
    
    return timesString;
}


#pragma mark - UIButtonAction

- (IBAction)actionPraise:(id)sender {
    if (self.addFav) {
        self.addFav(self,[self.blog[@"is_zan"] intValue]);
    }
}


- (IBAction)actionAddComment:(id)sender {
    if (self.addComment) {
        self.addComment(self);
    }
}
- (IBAction)actionDeleteBlog:(UIButton *)sender {
    if (self.deleteBlog) {
        self.deleteBlog(self);
    }
}

- (void)clickHead:(UITapGestureRecognizer *)tap{
    if (self.clickHeadView) {
        self.clickHeadView(self);
    }
}

- (void)longPressHead:(UILongPressGestureRecognizer *)longPresG{
    ExdangqianUserUid = [CommonCode readFromUserD:@"dangqianUserUid"];
    if (!self.isFeebackBlog && ![self.blog[@"uid"] isEqualToString:ExdangqianUserUid] && longPresG.state == UIGestureRecognizerStateEnded) {
        if (self.longPressHeadView) {
            self.longPressHeadView(self);
        }
    }
}

- (void)playVoiceAction:(UITapGestureRecognizer *)tap{
    //播放语音
    if (self.playVoice) {
        self.playVoice(self);
    }
    
}

//- (IBAction)playVoiceAction:(UIButton *)sender {
//    //播放语音
//    if (self.playVoice) {
//        self.playVoice(self);
//    }
//    
//    //设置帧动画的图片数组
//    self.voiceImgV.animationImages = [NSArray arrayWithObjects:
//                                      [UIImage imageNamed:@"v_anim2"],
//                                      [UIImage imageNamed:@"v_anim3"],
//                                      [UIImage imageNamed:@"v_anim4"],nil];
//    //设置帧动画播放时长
//    [self.voiceImgV setAnimationDuration:1.0];
//    //设置帧动画播放次数
//    [self.voiceImgV setAnimationRepeatCount:5];
//    
//    //如果动画正在播放就不会继续播放下一个动画
//    if (self.voiceImgV.isAnimating) {
//        return;
//    }
//    else{
//        [self.voiceImgV startAnimating];
//    }
//}

- (void)ancer{
    NSLog(@"1111111111111");
}

@end
