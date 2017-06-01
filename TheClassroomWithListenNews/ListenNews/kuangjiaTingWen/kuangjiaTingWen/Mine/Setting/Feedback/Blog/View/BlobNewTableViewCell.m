//
//  BlobNewTableViewCell.m
//  kuangjiaTingWen
//
//  Created by 泡果 on 2017/5/12.
//  Copyright © 2017年 zhimi. All rights reserved.
//

#import "BlobNewTableViewCell.h"
#import "NSDate+TimeFormat.h"

@interface BlobNewTableViewCell ()<UITableViewDelegate,UITableViewDataSource>
@property (weak, nonatomic) UIImageView *headerImage;
@property (weak, nonatomic) UILabel *creat_timeLabel;
@property (weak, nonatomic) UILabel *content;
@property (weak, nonatomic) UIView *contentNewsView;
@property (weak, nonatomic) UIImageView *newsImage;
@property (weak, nonatomic) UILabel *newsTitle;
@property (weak, nonatomic) UIView *voiceView;
@property (weak, nonatomic) UILabel *voiceTimeLabel;
@property (weak, nonatomic) UIButton *deleteBtn;
@property (weak, nonatomic) UIButton *commentBtn;
@property (weak, nonatomic) UIImageView *favImage;
@property (weak, nonatomic) UILabel *favLabel;
@property (weak, nonatomic) UIImageView *commentBgView;
@property (weak, nonatomic) UIView *devider;

@property (strong, nonatomic) UILabel *addOneLabel;

@property (strong, nonatomic) UITableView *commentReviewTableView;

@property(strong,nonatomic)UIImageView *voiceImgV;
@property (strong, nonatomic) UILabel *tipLabel;

@property (strong, nonatomic) NSMutableArray *dataArray;
@end
@implementation BlobNewTableViewCell
- (NSMutableArray *)dataArray
{
    if (_dataArray == nil) {
        _dataArray = [NSMutableArray array];
    }
    return _dataArray;
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


+ (NSString *)ID
{
    return @"BlobNewTableViewCell";
}
+(BlobNewTableViewCell *)cellWithTableView:(UITableView *)tableView
{
    BlobNewTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:[BlobNewTableViewCell ID]];
    if (cell == nil) {
        cell = [[BlobNewTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:[BlobNewTableViewCell ID]];
    }
    return cell;
}
- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        //用户头像
        UIImageView *headerImage = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"user-5"]];
        headerImage.contentMode = UIViewContentModeScaleToFill;
        headerImage.backgroundColor = [UIColor clearColor];
        headerImage.layer.cornerRadius = 23;
        headerImage.layer.masksToBounds = YES;
        headerImage.userInteractionEnabled = YES;
        [headerImage addTapGesWithTarget:self action:@selector(clickHead:)];
        [headerImage addLongPressGesWithTarget:self action:@selector(longPressHead:)];
        [self.contentView addSubview:headerImage];
        self.headerImage = headerImage;
        //用户昵称
        _nameLabe = [[UILabel alloc] init];
        [_nameLabe setTextColor:gMainColor];
        _nameLabe.userInteractionEnabled = YES;
        UITapGestureRecognizer *headTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(clickHead:)];
        [_nameLabe addGestureRecognizer:headTap];
        _nameLabe.font = [UIFont systemFontOfSize:15.0];
        [self.contentView addSubview:_nameLabe];
        //用户发布时间
        UILabel *creat_timeLabel = [[UILabel alloc] init];
        creat_timeLabel.textColor = [UIColor lightGrayColor];
        creat_timeLabel.textAlignment = NSTextAlignmentRight;
        creat_timeLabel.font = [UIFont systemFontOfSize:10.0];
        [self.contentView addSubview:creat_timeLabel];
        self.creat_timeLabel = creat_timeLabel;
        //用户发布内容
        UILabel *content = [[UILabel alloc] init];
        content.textAlignment = NSTextAlignmentLeft;
        content.font = [UIFont systemFontOfSize:16.0];
        content.numberOfLines = 0;
        [self.contentView addSubview:content];
        self.content = content;
        //用户评论新闻
        UIView *contentNewsView = [[UIView alloc] init];
        contentNewsView.backgroundColor = ColorWithRGBA(235, 235, 241, 1.0);
        [self.contentView addSubview:contentNewsView];
        self.contentNewsView = contentNewsView;
            //新闻图片
            UIImageView *newsImage = [[UIImageView alloc] init];
            newsImage.contentMode = UIViewContentModeScaleAspectFill;
            newsImage.clipsToBounds = YES;
            newsImage.backgroundColor = [UIColor clearColor];
            [newsImage.layer setMasksToBounds:YES];
            [newsImage.layer setCornerRadius:4.0];
            [contentNewsView addSubview:newsImage];
            self.newsImage = newsImage;
            //新闻标题
            UILabel *newsTitle = [[UILabel alloc] init];
            newsTitle.font = [UIFont systemFontOfSize:14.0];
            newsTitle.numberOfLines = 0;
            [contentNewsView addSubview:newsTitle];
            self.newsTitle = newsTitle;
        //语音view
        UIView *voiceView = [[UIView alloc] init];
        [self.contentView addSubview:voiceView];
        self.voiceView = voiceView;
            //语音按钮
            UIButton *voiceBtn = [[UIButton alloc] init];
            [voiceBtn setBackgroundImage:[UIImage imageNamed:@"voice"] forState:UIControlStateNormal];
            UITapGestureRecognizer *playVoiceTapG = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(playVoiceAction:)];
            [voiceBtn addGestureRecognizer:playVoiceTapG];
            [voiceView addSubview:voiceBtn];
            self.voiceButton = voiceBtn;
            //语音时间按钮
            UILabel *voiceTimeLabel = [[UILabel alloc] init];
            voiceTimeLabel.font = [UIFont systemFontOfSize:10.0];
            voiceTimeLabel.textColor = [UIColor lightGrayColor];
            [voiceView addSubview:voiceTimeLabel];
            self.voiceTimeLabel = voiceTimeLabel;
        //图片内容view
        MultiImageView *photoImageView = [[MultiImageView alloc] init];
        [self.contentView addSubview:photoImageView];
        self.photosImageView = photoImageView;
        //自己发布，删除按钮
        UIButton *deleteBtn = [[UIButton alloc] init];
        [deleteBtn setTitleColor:gMainColor forState:UIControlStateNormal];
        [deleteBtn setTitle:@"删除" forState:UIControlStateNormal];
        deleteBtn.titleLabel.font = [UIFont systemFontOfSize:13.0];
        [deleteBtn addTarget:self action:@selector(actionDeleteBlog:) forControlEvents:UIControlEventTouchUpInside];
        [self.contentView addSubview:deleteBtn];
        self.deleteBtn = deleteBtn;
        //点赞按钮
        UIButton *praiseButton = [[UIButton alloc] init];
        [praiseButton setImage:[UIImage imageNamed:@"me_mypage_me_list_ic_like"] forState:UIControlStateNormal];
        [praiseButton addTarget:self action:@selector(actionPraise:) forControlEvents:UIControlEventTouchUpInside];
        [self.contentView addSubview:praiseButton];
        self.praiseButton = praiseButton;
        //评论按钮
        UIButton *commentBtn = [[UIButton alloc] init];
        [commentBtn setImage:[UIImage imageNamed:@"me_mypage_me_list_ic_comment"] forState:UIControlStateNormal];
        [commentBtn addTarget:self action:@selector(actionAddComment:) forControlEvents:UIControlEventTouchUpInside];
        [self.contentView addSubview:commentBtn];
        self.commentBtn = commentBtn;
        //点赞数，评论背景
        UIImageView *commentBgView = [[UIImageView alloc] init];
        commentBgView.userInteractionEnabled = YES;
        commentBgView.contentMode = UIViewContentModeScaleToFill;
        commentBgView.image = [UIImage imageNamed:@"bg_blog_comment"];
        [self.contentView addSubview:commentBgView];
        self.commentBgView = commentBgView;
        //点赞图标
        UIImageView *favImage = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"feeback_fav"]];
        favImage.contentMode = UIViewContentModeScaleToFill;
        favImage.backgroundColor = [UIColor clearColor];
        [commentBgView addSubview:favImage];
        self.favImage = favImage;
        //点赞人数
        UILabel *favLabel = [[UILabel alloc] init];
        favLabel.font = [UIFont systemFontOfSize:10.0];
        favLabel.textColor = [UIColor lightGrayColor];
        [commentBgView addSubview:favLabel];
        self.favLabel = favLabel;
        //评论回复模块
        _commentReviewTableView = [[UITableView alloc] init];
        _commentReviewTableView.dataSource = self;
        _commentReviewTableView.delegate = self;
        _commentReviewTableView.scrollEnabled = NO;
        _commentReviewTableView.backgroundColor = [UIColor clearColor];
        _commentReviewTableView.separatorStyle = UITableViewCellSeparatorStyleNone;
        [commentBgView addSubview:_commentReviewTableView];
        //分割线
        UIView *devider = [[UIView alloc] init];
        devider.backgroundColor = [UIColor lightGrayColor];
        [self.contentView addSubview:devider];
        self.devider = devider;
    }
    return self;
}
- (void)setFrameModel:(FeedBackAndListenFriendFrameModel *)frameModel
{
    _frameModel = frameModel;
    self.dataArray = [self frameModelWithDataModel:frameModel.model.child_comment];
    [self.commentReviewTableView reloadData];
    FeedBackAndListenFriendModel *model = frameModel.model;
    _headerImage.frame = frameModel.headerImageF;
    _nameLabe.frame = frameModel.nameLabeF;
    _creat_timeLabel.frame = frameModel.creat_timeLabelF;
    _content.frame = frameModel.contentF;
    
    _contentNewsView.frame = frameModel.contentNewsViewF;
    _newsImage.frame = frameModel.newsImageF;
    _newsTitle.frame = frameModel.newsTitleF;
    
    _voiceView.frame = frameModel.voiceViewF;
    _voiceButton.frame = frameModel.voiceButtonF;
    [_voiceButton addSubview:self.tipLabel];
    [_voiceButton addSubview:self.voiceImgV];
    _voiceTimeLabel.frame = frameModel.voiceTimeLabelF;
    
    _photosImageView.frame = frameModel.photosImageViewF;
    
    _deleteBtn.frame = frameModel.deleteBtnF;
    _praiseButton.frame = frameModel.praiseButtonF;
    _commentBtn.frame = frameModel.commentBtnF;
    
    _commentBgView.frame = frameModel.commentBgViewF;
    _favImage.frame = frameModel.favImageF;
    _favLabel.frame = frameModel.favLabelF;
    _commentReviewTableView.frame = frameModel.tableViewF;
    _devider.frame = frameModel.deviderF;
    //设置头像
    UserModel *user = frameModel.model.user;
    //头像url处理
    NSString *imgUrl = [NSString stringWithFormat:@"%@",[user.avatar stringByReplacingOccurrencesOfString:@"\\" withString:@""]];
    NSString *imgUrl1 = [imgUrl stringByReplacingOccurrencesOfString:@"\"" withString:@""];
    NSString *imgUrl2 = [imgUrl1 stringByReplacingOccurrencesOfString:@"thumb:" withString:@""];
    NSString *imgUrl3 = [imgUrl2 stringByReplacingOccurrencesOfString:@"{" withString:@""];
    NSString *imgUrl4 = [imgUrl3 stringByReplacingOccurrencesOfString:@"}" withString:@""];
    if ([imgUrl4  rangeOfString:@"http"].location != NSNotFound)
    {
        [_headerImage sd_setImageWithURL:[NSURL URLWithString:imgUrl4] placeholderImage:AvatarPlaceHolderImage];
    }else
    {
        NSString *str = USERPHOTOHTTPSTRING(imgUrl4);
        [_headerImage sd_setImageWithURL:[NSURL URLWithString:str] placeholderImage:AvatarPlaceHolderImage];
    }
    //设置用户昵称
    _nameLabe.text = [user.user_nicename isEqualToString:@""] ? user.user_login :user.user_nicename;
    //设置发布内容
    if (self.isUnreadMessage) {
        _content.text = model.content;
    }
    else{
        _content.text = model.comment;
    }
    //判断是意见反馈还是听友圈，意见反馈没有语音和评论新闻链接跳转view
    if (self.isFeebackBlog) {
        self.contentNewsView.hidden = YES;
        self.voiceView.hidden = YES;
    }else{//听友圈
        if (![model.post_id isEqualToString:@"0"]) {//新闻评论，不显示语音
            self.contentNewsView.hidden = NO;
            self.voiceView.hidden = YES;
            //设置新闻图片
            NSString *aimgUrl = [NSString stringWithFormat:@"%@",[model.post.smeta stringByReplacingOccurrencesOfString:@"\\" withString:@""]];
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
            //设置新闻标题
            [_newsTitle setText:model.post.post_title];

        }else{//语音,无新闻
            self.contentNewsView.hidden = YES;
            if ([model.mp3_url isEmpty]) {//无语音
                self.voiceView.hidden = YES;
            }
            else{
                self.voiceView.hidden = NO;
                if ([model.comment isEqualToString:@""]) {//是否有文字内容
                    
                }else
                {
                    
                }
                _voiceTimeLabel.text = [NSString stringWithFormat:@"%@''",model.play_time];
            }

        }
    }
    
    //处理图片
    NSMutableArray *urls = [NSMutableArray new];
    if (self.isFeebackBlog) {
        if (![model.images isEqualToString:@""]){
            NSArray *array = [model.images componentsSeparatedByString:@","];
            for (int i = 0 ; i < array.count ; i ++ ) {
                [urls addObject:[NSURL URLWithString:[NSString stringWithFormat:@"http://admin.tingwen.me/%@", array[i]]]];
            }
        }
    }
    else{
        if (![model.timages isEqualToString:@""]){
            NSArray *array = [model.timages componentsSeparatedByString:@","];
            for (int i = 0 ; i < array.count ; i ++ ) {
                [urls addObject:[NSURL URLWithString:[NSString stringWithFormat:@"http://admin.tingwen.me/%@", array[i]]]];
            }
        }
    }
    NSArray *photos = urls;
    if ([photos count]) {
        _photosImageView.images = photos;
        _photosImageView.hidden = NO;
        CGSize size = [_photosImageView sizeForContent:photos];
        _photosImageView.height = size.height;
    }
    else{
        _photosImageView.hidden = YES;
    }
    
    //时间戳转时间
    NSDateFormatter* formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"yyyy-MM-dd HH:mm"];
    NSString *timeStr = [self stringWithTime:[(model.create_time) integerValue]];
    NSDate *date = _isFeebackBlog ? [formatter dateFromString:timeStr] : [NSDate dateFromString:model.createtime];
    _creat_timeLabel.text = [date showTimeByTypeA];

    //删除按钮的显示和隐藏
    ExdangqianUserUid = [CommonCode readFromUserD:@"dangqianUserUid"];
    if (!_isFeebackBlog && [model.uid isEqualToString:ExdangqianUserUid]) {
        _deleteBtn.hidden = NO;
    }
    else{
        _deleteBtn.hidden = YES;
    }
    //点赞人数
    [_favImage setImage:[UIImage imageNamed:@"feeback_fav"]];
    if (![_isFeebackBlog ? model.zan_num : model.praisenum isEqualToString:@"0"]) {
        _favLabel.fd_collapsed = NO;
        _favLabel.text = [NSString stringWithFormat:@"%@人点赞",_isFeebackBlog ? model.zan_num : model.praisenum ];
    }else
    {
        _favLabel.text = [NSString stringWithFormat:@"0人点赞"];
    }
    //是否点赞
    if ([_isFeebackBlog ? model.is_zan :model.zan integerValue] == 1) {
        [_praiseButton setImage:[UIImage imageNamed:@"me_mypage_me_list_ic_liked"] forState:UIControlStateNormal];
        _praiseButton.userInteractionEnabled = YES;
    }
    else if ([_isFeebackBlog ? model.is_zan :model.zan integerValue] == 0){
        [_praiseButton setImage:[UIImage imageNamed:@"me_mypage_me_list_ic_like"] forState:UIControlStateNormal];
        _praiseButton.userInteractionEnabled = YES;
    }

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
//点赞+1动画
- (void)addOneAnimation{
    _addOneLabel = [[UILabel alloc] initWithFrame:_frameModel.praiseButtonF];
    _addOneLabel.text = @"+1";
    _addOneLabel.textColor = gMainColor;
    _addOneLabel.textAlignment = NSTextAlignmentCenter;
    _addOneLabel.font = [UIFont systemFontOfSize:13.0f];
    [self.contentView addSubview:_addOneLabel];
    
    [UIView animateWithDuration:2.0 animations:^{
        _addOneLabel.frame = CGRectMake(_frameModel.praiseButtonF.origin.x, _frameModel.praiseButtonF.origin.y - 100, _frameModel.praiseButtonF.size.width, _frameModel.praiseButtonF.size.height);
    } completion:^(BOOL finished) {
        [_addOneLabel removeFromSuperview];
    }];
    
}
#pragma mark - 触发方法
- (void)actionPraise:(id)sender {
    if (self.addFav) {
        self.addFav(self,[_isFeebackBlog ?_frameModel.model.is_zan :_frameModel.model.zan intValue]);
    }
}


- (void)actionAddComment:(id)sender {
    if (self.addComment) {
        self.addComment(self);
    }
}
- (void)actionDeleteBlog:(UIButton *)sender {
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
    if (!self.isFeebackBlog && ![self.frameModel.model.uid isEqualToString:ExdangqianUserUid] && longPresG.state == UIGestureRecognizerStateEnded) {
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
//转换为frame模型
- (NSMutableArray *)frameModelWithDataModel:(NSArray *)array
{
    NSMutableArray *frameArray = [NSMutableArray array];
    for (child_commentModel *model in array) {
        CommentAndReviewFrameModel *frameModel = [[CommentAndReviewFrameModel alloc] init];
        frameModel.model = model;
        [frameArray addObject:frameModel];
    }
    return frameArray;
}
#pragma mark - table view datasource and delegate
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.frameModel.model.child_comment.count;
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    CommentAndReviewTableViewCell *cell = [CommentAndReviewTableViewCell cellWithTableView:tableView];
    CommentAndReviewFrameModel *frameModel = self.dataArray[indexPath.row];
    cell.frameModel = frameModel;
//    cell.blogViewController = _blogViewController;
    
    DefineWeakSelf;
    [cell setClickRowCellWithReview:^(CommentAndReviewTableViewCell *cell, child_commentModel *model) {
        [weakSelf userReviewClickedWithModel:model];
    }];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    return cell;
}
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    CommentAndReviewFrameModel *frameModel = self.dataArray[indexPath.row];
    return frameModel.cellHeight;
}
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    CommentAndReviewFrameModel *frameModel = self.dataArray[indexPath.row];
    if (self.addReview) {
        self.addReview(self,frameModel.model);
    }
}
//用户点击评论回复
- (void)userReviewClickedWithModel:(child_commentModel *)model
{
    if (self.addReview) {
        self.addReview(self,model);
    }
}
@end
