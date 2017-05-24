//
//  GZ_Cell.m
//  Heard the news
//
//  Created by Pop Web on 15/8/27.
//  Copyright (c) 2015年 泡果网络. All rights reserved.
//

#import "GZ_Cell.h"

#import "UserClass.h"

#import "UIImageView+WebCache.h"

//#import "UtilsMacro.h"

//#import "NetworkingMangater.h"

#import "DSE.h"

//#import "SQLClass.h"

#import "MBProgressHUD.h"

#import "ZhuBoClass.h"

#import "XWAddView.h"


typedef enum : NSUInteger {
    XWButtonStatueJieMu,
    XWButtonStatueJieMuAdd,
    XWButtonStatueNone
} XWButtonStatue;

typedef enum : NSUInteger {
    XWUserStatueAdd,
    XWUserStatueCan
} XWUserStatue;


@interface GZ_Cell ()

@property (weak, nonatomic) IBOutlet UIImageView *userImageView;
@property (weak, nonatomic) IBOutlet UILabel *userName;
@property (weak, nonatomic) IBOutlet UILabel *userJJ;
@property (strong, nonatomic) UserClass *user;
@property (strong, nonatomic) ZhuBoClass *zhuBo;
@property (nonatomic) XWButtonStatue xwStatue;
@property (nonatomic) XWUserStatue xwUserStatue;
@property (weak, nonatomic) IBOutlet UIView *buttonView;
@property (assign, nonatomic) NSInteger idx;
@property (weak, nonatomic) IBOutlet XWAddView *bacView;

@end

@implementation GZ_Cell

- (void)awakeFromNib {
    // Initialization code
    
}

- (IBAction)clse:(id)sender {
    //    if (_type) {
    //        [NetworkingMangater netwokingPost:@"addAttention" andParameters:@{@"accessToken":[DES encryptUseDES:user.user_login], @"uid_2" : _user.i_id} success:^(id obj) {
    //            if ([obj[@"msg"] isEqualToString:@"添加好友关注成功!"]) {
    //                [[NSNotificationCenter defaultCenter]postNotificationName:@"deleteCellAdd" object:_user];
    //            }
    //        }];
    //    }else {
    //        [NetworkingMangater netwokingPost:@"cancelAttention" andParameters:@{@"accessToken":[DES encryptUseDES:user.user_login], @"uid_2" : _user.friend_id} success:^(id obj) {
    //            if ([obj[@"msg"] isEqualToString:@"取消好友关注成功!"]) {
    //                [[NSNotificationCenter defaultCenter]postNotificationName:@"deleteCell" object:_user];
    //            }
    //        }];
    //    }
    switch (_xwStatue) {
        case XWButtonStatueJieMu:
            [self cancelAttentionJieMu];
            break;
        case XWButtonStatueJieMuAdd:
            [self addAttentionJieMu];
            break;
        case XWButtonStatueNone:{
            switch (_idx) {
                case 0:
                    [self addAttention];
                    break;
                case 1:
                    [self cancelAttention];
                    break;
                case 2:
                    [self cancelAttention];
                    break;
                default:
                    break;
            }
        }
            
            break;
        default:
            break;
    }
}

- (void)addAttention {
//    NSArray *a = [SQLClass selectListName:kUserLsit withClass:[UserClass class]];
//    
//    if (!a.count) {
//        UIAlertView *al = [[UIAlertView alloc]initWithTitle:nil message:@"请登入" delegate:nil cancelButtonTitle:nil otherButtonTitles:@"知道了", nil];
//        [al show];
//        return;
//    }
//    
//    UserClass *user = [a lastObject];
    
    __weak __typeof(self) selfBlock = self;
    NSString *idString = nil;
    if ([_user.friend_id isEqualToString:[CommonCode readFromUserD:@"dangqianUserUid"]]) {
        idString = _user.uid;
    }else if ([_user.uid isEqualToString:[CommonCode readFromUserD:@"dangqianUserUid"]]) {
        idString = _user.friend_id;
    }else if(_user.i_id){
        idString = _user.i_id;
    }else if(_isFen){
        idString = _user.uid;
    }else {
        idString = _user.friend_id;
    }
    
    if (_type) {
        _idx = 2;
    }else {
        _idx = 1;
    }
    [selfBlock setTypeButton:_idx];
    
    [NetWorkTool getPaoGuoAddFriendWithaccessToken:[DSE encryptUseDES:ExdangqianUser] anduid_2:idString sccess:^(NSDictionary *responseObject) {
        if ([responseObject[@"msg"] isEqualToString:@"添加好友关注成功!"]) {
            [[NSNotificationCenter defaultCenter]postNotificationName:@"deleteCellAdd" object:_user];
            
            NSMutableArray *ar = [[[NSUserDefaults standardUserDefaults]objectForKey:@"guanZhuArray"]mutableCopy];
            [ar addObject:idString];
            [[NSUserDefaults standardUserDefaults]setObject:ar forKey:@"guanZhuArray"];
        }
    } failure:^(NSError *error) {
        //
    }];
    
}

- (void)cancelAttention {
    __weak __typeof(self) selfBlock = self;
//    NSArray *a = [SQLClass selectListName:kUserLsit withClass:[UserClass class]];
//    
//    if (!a.count) {
//        UIAlertView *al = [[UIAlertView alloc]initWithTitle:nil message:@"请登入" delegate:nil cancelButtonTitle:nil otherButtonTitles:@"知道了", nil];
//        [al show];
//        return;
//    }
//    UserClass *user = [a lastObject];
    NSString *idString = nil;
    if ([_user.friend_id isEqualToString:[CommonCode readFromUserD:@"dangqianUserUid"]]) {
        idString = _user.uid;
    }else if ([_user.uid isEqualToString:[CommonCode readFromUserD:@"dangqianUserUid"]]) {
        idString = _user.friend_id;
    }else if(_user.i_id){
        idString = _user.i_id;
    }else if(_isFen){
        idString = _user.uid;
    }else {
        idString = _user.friend_id;
    }
    if (_isFen) {
        _idx = 0;
    }else if(!_type){
        _idx = 0;
    }else {
        _idx = 0;
    }
    [selfBlock setTypeButton:_idx];
    
    [NetWorkTool getPaoGuoCancelFriendWithaccessToken:[DSE encryptUseDES:ExdangqianUser] anduid_2:idString sccess:^(NSDictionary *responseObject) {
        if ([responseObject[@"msg"] isEqualToString:@"取消好友关注成功!"]) {
            //            [[NSNotificationCenter defaultCenter]postNotificationName:@"deleteCell" object:_user];
            
            NSMutableArray *ar = [[[NSUserDefaults standardUserDefaults]objectForKey:@"guanZhuArray"]mutableCopy];
            [ar removeObject:idString];
            [[NSUserDefaults standardUserDefaults]setObject:ar forKey:@"guanZhuArray"];
        }    } failure:^(NSError *error) {
        //
    }];
}

- (void)setData:(UserClass *)user andType:(NSInteger)idx {
    _user = user;
    
    _xwStatue= XWButtonStatueNone;
    
    if ([user.avatar hasPrefix:@"http"]) {
        [_userImageView sd_setImageWithURL:[NSURL URLWithString:USERPHOTOHTTPSTRING(user.avatar)] placeholderImage:ImageWithName(@"right-1")];
    }else {
        [_userImageView sd_setImageWithURL:[NSURL URLWithString:USERPOTO(user.avatar)] placeholderImage:ImageWithName(@"right-1")];
    }
    if (user.signature) {
        _userJJ.text = user.signature;
    }else {
        _userJJ.text = @"没有简介";
    }
    
    [self setTypeButton:idx];
//    if ([SQLClass selectListName:kUserLsit withClass:[UserClass class]].count) {
//        UserClass *u = (UserClass *)[SQLClass selectListName:kUserLsit withClass:[UserClass class]][0];
        if ([ExdangqianUser isEqualToString:_user.user_login]) {
            _usertypeButton.hidden = YES;
        }else {
            _usertypeButton.hidden = NO;
        }
//    }else {
//        _usertypeButton.hidden = NO;
//    }
    
    _bacView.hidden = _usertypeButton.hidden;
    
    if ([user.user_nicename isEqualToString:@"(null)"] || [user.user_nicename isEqualToString:@""]) {
        _userName.text = user.user_login;
    }else {
        _userName.text = user.user_nicename;
    }
}



- (void)setTypeButton:(NSInteger)idx {
    
    switch (idx) {
        case 0:
            //添加
            [_usertypeButton setImage:ImageWithName(@"card_icon_addattention") forState:UIControlStateNormal];
            break;
        case 1:
            //单向关注
            [_usertypeButton setImage:ImageWithName(@"card_icon_unfollow") forState:UIControlStateNormal];
            break;
        case 2:
            //互相关注
            [_usertypeButton setImage:ImageWithName(@"card_icon_arrow") forState:UIControlStateNormal];
            break;
        default:
            break;
    }
    
    _idx = idx;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
    
    // Configure the view for the selected state
}

- (void)drawRect:(CGRect)rect {
//    _buttonView.layer.borderWidth = .5f;
//    _buttonView.layer.borderColor = [UIColor colorWithRed:0.0 green:0.0 blue:0.0 alpha:0.38].CGColor;
//    _usertypeButton.layer.cornerRadius = 5;
//    _usertypeButton.layer.borderColor = [UIColor lightGrayColor].CGColor;
//    _usertypeButton.clipsToBounds = YES;
}

#pragma mark - 节目
- (void)setData:(ZhuBoClass *)user {
    _zhuBo = user;
    if ([user.images hasPrefix:@"http"]) {
        [_userImageView sd_setImageWithURL:[NSURL URLWithString:USERPHOTOHTTPSTRING(user.images)] placeholderImage:ImageWithName(@"right-1")];
    }else {
        [_userImageView sd_setImageWithURL:[NSURL URLWithString:USERPHOTOHTTPSTRINGZhuBo(user.images)] placeholderImage:ImageWithName(@"right-1")];
    }
    if (user.signature) {
        _userJJ.text = user.signature;
    }else {
        _userJJ.text = @"没有简介";
    }
    _userName.text = user.name;
    if (user.isHaoYou) {
        _xwStatue = XWButtonStatueJieMu;
        [_usertypeButton setImage:ImageWithName(@"card_icon_unfollow") forState:UIControlStateNormal];
    }else {
        _xwStatue = XWButtonStatueJieMuAdd;
        [_usertypeButton setImage:ImageWithName(@"card_icon_addattention") forState:UIControlStateNormal];
    }
}

- (void)cancelAttentionJieMu {
//    __weak __typeof(self) selfBlock = self;
//    NSArray *a = [SQLClass selectListName:kUserLsit withClass:[UserClass class]];
//    
//    if (!a.count) {
//        UIAlertView *al = [[UIAlertView alloc]initWithTitle:nil message:@"请登入" delegate:nil cancelButtonTitle:nil otherButtonTitles:@"知道了", nil];
//        [al show];
//        return;
//    }
//    UserClass *user = [a lastObject];
    
    NSString *idString = nil;
    idString = _zhuBo.friend_id ? _zhuBo.friend_id : _zhuBo.i_id;

    [[NSNotificationCenter defaultCenter]postNotificationName:@"delegateCellJieMu" object:_zhuBo];
    _xwStatue = XWButtonStatueJieMuAdd;

    if (_zhuBo.isHaoYou) {
        [_usertypeButton setImage:ImageWithName(@"card_icon_unfollow") forState:UIControlStateNormal];
    }else {
        [_usertypeButton setImage:ImageWithName(@"card_icon_addattention") forState:UIControlStateNormal];
    }
    
    [NetWorkTool postPaoGuoCancelJieMuGuanZhuWithaccessToken:[DSE encryptUseDES:ExdangqianUser] andAct_id:idString sccess:^(NSDictionary *responseObject) {
        if ([responseObject[@"msg"] isEqualToString:@"取消节目关注成功!"]) {
            NSLog(@"取消成功");
        }
        
    } failure:^(NSError *error) {
        NSLog(@"网络请求失败");
    }];
}


- (void)setDataAddJieMu:(ZhuBoClass *)user {
    _zhuBo = user;
    _xwStatue = XWButtonStatueJieMuAdd;
    if ([user.images hasPrefix:@"http"]) {
        [_userImageView sd_setImageWithURL:[NSURL URLWithString:USERPHOTOHTTPSTRING(user.images)] placeholderImage:ImageWithName(@"right-1")];
    }else {
        [_userImageView sd_setImageWithURL:[NSURL URLWithString:USERPHOTOHTTPSTRINGZhuBo(user.images)] placeholderImage:ImageWithName(@"right-1")];
    }
    if (user.signature) {
        _userJJ.text = user.signature;
    }else {
        _userJJ.text = @"没有简介";
    }
    _userName.text = user.name;
    [_usertypeButton setImage:ImageWithName(@"card_icon_addattention") forState:UIControlStateNormal];
}

- (void)addAttentionJieMu {
    _xwStatue = XWButtonStatueJieMu;

//    NSString *idString = nil;
//    idString = _zhuBo.i_id;
    NSString *str = [DSE encryptUseDES:ExdangqianUser];
    [[NSNotificationCenter defaultCenter]postNotificationName:@"addCellJieMu" object:_zhuBo];
    if (!_zhuBo.isHaoYou) {
        [_usertypeButton setImage:ImageWithName(@"card_icon_unfollow") forState:UIControlStateNormal];
    }else {
        [_usertypeButton setImage:ImageWithName(@"card_icon_addattention") forState:UIControlStateNormal];
    }
    
    [NetWorkTool postPaoGuoAddJieMuGuanZhuWithaccessToken:str andAct_id:_zhuBo.i_id sccess:^(NSDictionary *responseObject) {
        if ([responseObject[@"msg"] isEqualToString:@"添加节目关注成功!"]) {
            
        }
    } failure:^(NSError *error) {
        //
    }];
    
}
@end
