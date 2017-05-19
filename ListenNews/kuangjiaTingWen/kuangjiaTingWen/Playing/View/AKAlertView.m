//
//  AKAlertView.m
//  BaseDemo
//
//  Created by ak on 16/10/28.
//  Copyright © 2016年 AK. All rights reserved.
//

#import "AKAlertView.h"
#import "UIView+AK.h"

#pragma mark - Colors

#define GREENCOLOR  [UIColor colorWithRed:0.443 green:0.765 blue:0.255 alpha:1]
#define REDCOLOR    [UIColor colorWithRed:0.906 green:0.296 blue:0.235 alpha:1]
#define BLUECOLOR  [UIColor colorWithRed:0/255.0 green:159/255.0 blue:240/255.0 alpha:1]



#define KunitTime 0.25


#define kScreenW [UIScreen mainScreen].bounds.size.width
#define kScreenH [UIScreen mainScreen].bounds.size.height



typedef void(^animateBlock)();

@interface AKAlertView()<UITextViewDelegate>
{
    
    UIView *contentView;UIView*bgView;
    
    UIImageView *headView;
    
    UILabel *titleLb,*desLb,*shareLb;
    
    UIButton *deleteBtn,*titleLBtn,*sureBtn,*cancelBtn,*shareBtn;
    
    UITextView *messageTextV;
    UILabel *textVPlaceholderLab,*textCountlab;
    
    UIView *experienceView;
    UILabel *exp;
    
    //animateBlock Arr
    NSMutableArray * _animateArr;
    
    float kcontentW;
    float headW;
}
@end
@implementation AKAlertView


+(instancetype)alertView:(NSString*)title des:(NSString*)des type:(AKAlert)type effect:(AKAlertEffect)effect sureTitle:(NSString*)sureTitle cancelTitle:(NSString*)cancelTitle{
    
    AKAlertView* view = [[AKAlertView alloc]init];
    view.type=type;
    view.effect=effect;
    view->titleLb.text=title;
    view->desLb.text=des;
    [view->titleLBtn setImage:[UIImage imageNamed:title] forState:UIControlStateNormal];
    [view->sureBtn setTitle:sureTitle forState:UIControlStateNormal];
    [view->cancelBtn setTitle:cancelTitle forState:UIControlStateNormal];
    return view;
}

#pragma mark - Life Circle

- (instancetype)init
{
    self = [super init];
    if (self) {
        
        //default values
        _tintColor=GREENCOLOR;
        
        _animateArr=@[].mutableCopy;
        
        _headImg=[UIImage imageNamed:@"Icon-180"];
        
        kcontentW=250.0;
        
        headW=80.0;
        
        self.frame=[[UIScreen mainScreen]bounds];
        
        
        //add blur effect view
        UIView* bgV =nil;
        
//        if([UIDevice currentDevice].systemVersion.floatValue >= 8.0){
//            bgV = [[UIVisualEffectView alloc] initWithEffect:[UIBlurEffect effectWithStyle:UIBlurEffectStyleLight]];
//            
//        }else{
//            UIToolbar *toolBar = [[UIToolbar alloc]init];
//            toolBar.barStyle = UIBarStyleBlackOpaque;
//            bgV = toolBar;
//        }
        bgV = [[UIView alloc]init];
        [bgV setBackgroundColor:[[UIColor grayColor] colorWithAlphaComponent:0.5]];
        bgV.frame=self.frame;
        [self addSubview:bgV];
        bgV.userInteractionEnabled=YES;
        UITapGestureRecognizer* tapBg=[[UITapGestureRecognizer  alloc]initWithTarget:self action:@selector(bgTap)];
        [bgV addGestureRecognizer:tapBg];
        bgView=bgV;
        
        
        UIView *contentV=[UIView new];
        contentV.backgroundColor=[UIColor whiteColor];
        [self addSubview: contentV];
        contentV.layer.cornerRadius=5;
        contentView=contentV;
        
        experienceView = [[UIView alloc]initWithFrame:CGRectMake(170, 120, 40, 40)];
        experienceView.alpha=0;
        [contentV addSubview:experienceView];
        UILabel *exptitle = [[UILabel alloc]initWithFrame:CGRectMake(0, 0, 35, 20)];
        [exptitle setText:@"经验"];
        [exptitle setFont:[UIFont systemFontOfSize:10.0]];
        [exptitle setTextColor:gTextDownload];
        [exptitle setTransform:CGAffineTransformMakeRotation(-M_PI_4 / 2)];
        [experienceView addSubview:exptitle];
        exp = [[UILabel alloc]initWithFrame:CGRectMake(5, 15, 35, 20)];
        //1听币 = 1元  +5经验
        NSMutableDictionary *dic = [CommonCode readFromUserD:REWARDINFODICTKEY];
        [exp setText:[NSString stringWithFormat:@"+%d",([dic[@"listen_money"] intValue] * 5) ]];
        [exp setFont:[UIFont systemFontOfSize:10.0]];
        [exp setTextColor:UIColorFromHex(0xF67825)];
        [exp setTransform:CGAffineTransformMakeRotation(-M_PI_4 / 2)];
        [experienceView addSubview:exp];
        
        
        UILabel* tLb = [[UILabel alloc]init];
        tLb.textColor=[UIColor blackColor];
        tLb.font= [UIFont systemFontOfSize:18];
        tLb.numberOfLines=0;
        tLb.textAlignment=NSTextAlignmentCenter;
        [contentView addSubview:tLb];
        titleLb = tLb;
        
        UIButton* tlB  = [[UIButton alloc]init];
        [contentView addSubview:tlB];
        titleLBtn = tlB;
        
        UILabel* dLb = [[UILabel alloc]init];
        dLb.textColor=[UIColor blackColor];
        dLb.font= [UIFont systemFontOfSize:15];
        dLb.numberOfLines=0;
        dLb.textAlignment=NSTextAlignmentCenter;
        [contentView addSubview:dLb];
        desLb = dLb;
        
        
        messageTextV = [[UITextView alloc]initWithFrame:CGRectMake(15, CGRectGetMaxX(titleLBtn.frame) + 12.5, 220, 60)];
        
        [contentView addSubview:messageTextV];
        messageTextV.layer.borderColor = BLUECOLOR.CGColor;
        messageTextV.layer.borderWidth =1.0;
        messageTextV.layer.cornerRadius =5.0;
        messageTextV.font = [UIFont systemFontOfSize:11.0f];
        messageTextV.delegate = self;
        
        textVPlaceholderLab = [[UILabel alloc]initWithFrame:CGRectMake(10, 5, 200, 25)];
        textVPlaceholderLab.text = @"有什么想对主播或者其他听众们说的";
        textVPlaceholderLab.textColor = gTextColorSub;
        textVPlaceholderLab.font = [UIFont systemFontOfSize:11.0f ];
        textVPlaceholderLab.alpha = 0.5f;
        textVPlaceholderLab.hidden = NO;
        [messageTextV addSubview:textVPlaceholderLab];
        
        textCountlab = [[UILabel alloc]initWithFrame:CGRectMake(150, 40, 70, 15)];
        textCountlab.text = @"还能输入25字";
        textCountlab.textColor = gTextColorSub;
        textCountlab.font = [UIFont systemFontOfSize:9.0f ];
        textCountlab.alpha = 0.5f;
        textCountlab.hidden = NO;
        [messageTextV addSubview:textCountlab];
        
        shareBtn =  [[UIButton alloc]init];
        [shareBtn setFrame:CGRectMake(91, CGRectGetMaxY(messageTextV.frame) + 10, 20, 20)];
        [shareBtn setImage:[UIImage imageNamed:@"message"] forState:UIControlStateSelected];
        [shareBtn setImage:[UIImage imageNamed:@"unMessage"] forState:UIControlStateNormal];
        shareBtn.selected = NO;
        shareBtn.tag=13;
        [shareBtn addTarget:self action:@selector(btnClick:) forControlEvents:UIControlEventTouchUpInside];
        [contentView addSubview:shareBtn];
        
        shareLb = [[UILabel alloc]init];
        [shareLb setFrame:CGRectMake(CGRectGetMaxX(shareBtn.frame) + 5, shareBtn.frame.origin.y, 60, 20)];
        [shareLb setText:@"留言后分享"];
        shareLb.textColor=gTextColorBackground;
        shareLb.font= [UIFont systemFontOfSize:9];
        shareLb.numberOfLines=0;
        shareLb.textAlignment=NSTextAlignmentCenter;
        [contentView addSubview:shareLb];
        
        UIButton* deleteB  = [[UIButton alloc]init];
        [deleteB setFrame:CGRectMake(kcontentW - 35, 15, 20, 20)];
        [deleteB setImage:[UIImage imageNamed:@"Delete"] forState:UIControlStateNormal];
        deleteB.tag=12;
        [deleteB addTarget:self action:@selector(btnClick:) forControlEvents:UIControlEventTouchUpInside];
        [contentView addSubview:deleteB];
        
        UIButton* sureB  = [[UIButton alloc]init];
        sureB.backgroundColor=_tintColor;
        [sureB setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [sureB setTitle:@"sure" forState:UIControlStateNormal];
        sureB.titleLabel.font=[UIFont systemFontOfSize:13];
        sureB.tag=10;
        [sureB addTarget:self action:@selector(btnClick:) forControlEvents:UIControlEventTouchUpInside];
        [sureB setCorner:5];
        [contentView addSubview:sureB];
        sureBtn=sureB;
        
        
        UIButton* cancelB  = [[UIButton alloc]init];
        cancelB.backgroundColor=[UIColor lightGrayColor];
        [cancelB setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [cancelB setTitle:@"cancel" forState:UIControlStateNormal];
        cancelB.titleLabel.font=[UIFont systemFontOfSize:13];
        cancelB.tag=11;
        [cancelB addTarget:self action:@selector(btnClick:) forControlEvents:UIControlEventTouchUpInside];
        [cancelB setCorner:5];
        [contentView addSubview:cancelB];
        cancelBtn=cancelB;
        
        
        UIImageView* headV =[UIImageView new];
        [contentView addSubview:headV];
        headView=headV;
        
        //add shadow
        contentView.layer.shadowColor=[UIColor blackColor].CGColor;
        contentView.layer.shadowOffset=CGSizeZero;
        contentView.layer.shadowRadius=20.f;
        contentView.layer.shadowOpacity=0.4f;
        
    }
    return self;
}

-(void)layoutSubviews{
    [super layoutSubviews];
    
    NSLog(@"layout subviews");
    
    [self setupColorAndImg];
    
    
    float btnW=110,btnH=35,statusBarH=20;
    
    float titleMarginT=headW + 20 + 30 ,desMarginT=10,btnMarginT=20,btnMarginB=20;
    
    //    float spaceBtn=20;//space between surebtn and cancelbtn
    
    float titleH=[self getLbSize:titleLb].height;
    
    float desH=[self getLbSize:desLb].height;
    
    
    float contentH = titleMarginT+titleH+desMarginT+desH+btnMarginT+btnH+btnMarginB,contentW=kcontentW;
    
    while((contentH+headW+statusBarH*2)>kScreenH) {
        //adjust the height
        if(titleH>desH)titleH-=10;
        else desH-=10;
        
        contentH = titleMarginT+titleH+desMarginT+desH+btnMarginT+btnH+btnMarginB,contentW=kcontentW;
        
    }
    
    [headView setCorner:headW/2];
    headView.frame=CGRectMake((contentW-headW)/2, 30, headW, headW + 10);
    
    titleLb.frame=CGRectMake(0, titleMarginT, contentW, titleH);
    titleLb.hidden = YES;
    titleLBtn.frame=CGRectMake(0, titleMarginT, contentW, titleH);
    desLb.frame=CGRectMake(0, CGRectGetMaxY(titleLb.frame)+desMarginT, contentW, desH);
    messageTextV.frame=CGRectMake(15, CGRectGetMaxY(titleLb.frame) + 12.5, 220, 60);
    [shareBtn setFrame:CGRectMake(91, CGRectGetMaxY(messageTextV.frame) + 10, 20, 20)];
    [shareLb setFrame:CGRectMake(CGRectGetMaxX(shareBtn.frame), shareBtn.frame.origin.y, 60, 20)];
    float btnY=CGRectGetMaxY(desLb.frame)+btnMarginT ;
    
    if (self.type==AKAlertSuccess){
        desLb.hidden = YES;
        experienceView.hidden = NO;
        messageTextV.hidden = NO;
        shareBtn.hidden = NO;
        shareLb.hidden = NO;
        btnY=CGRectGetMaxY(shareBtn.frame)+btnMarginT;
        contentH = titleMarginT+titleH+80+desH+btnMarginT+btnH+btnMarginB;
        
    }
    else if (self.type==AKAlertFaild){
        messageTextV.hidden = YES;
        desLb.hidden = NO;
        shareBtn.hidden = YES;
        shareLb.hidden = YES;
        experienceView.hidden = YES;
        btnY=CGRectGetMaxY(desLb.frame)+btnMarginT;
        contentH = titleMarginT+titleH+desMarginT+desH+btnMarginT+btnH+btnMarginB;
    }
    sureBtn.frame=CGRectMake((contentW-btnW*2)/2, btnY - 10, btnW*2, btnH);
    cancelBtn.frame=CGRectZero;
    contentView.t_size=CGSizeMake(contentW, contentH);
    contentView.t_center=self.center;
    
    //    if (self.type==AKAlertSuccess||self.type==AKAlertInfo || self.type==AKAlertFaild ) {
    //        //show one btn
    //        sureBtn.frame=CGRectMake((contentW-btnW*2)/2, btnY, btnW*2, btnH);
    //        cancelBtn.frame=CGRectZero;
    //    }
    //
    ////    if (self.type==AKAlertFaild||self.type==AKAlertCustom) {
    //    else{
    //        //show two btn
    //        sureBtn.frame=CGRectMake(contentW/2-btnW-spaceBtn/2, btnY, btnW, btnH);
    //        cancelBtn.frame=CGRectMake(contentW/2+spaceBtn/2, btnY, btnW, btnH);
    //    }
    
}

-(CGSize)getLbSize:(UILabel*)lb{
    return [lb.text boundingRectWithSize:CGSizeMake(kcontentW, MAXFLOAT) options:NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName:lb.font} context:nil].size;
}



#pragma mark - Property
-(void)setHeadImg:(UIImage *)headImg{
    _headImg=headImg;
    headView.image=headImg;
    
}

-(void)setTintColor:(UIColor *)tintColor{
    
    sureBtn.backgroundColor=tintColor;
    
}
#pragma mark - Animations

-(void)show{
    
    [[UIApplication sharedApplication].keyWindow addSubview:self];
    if (self.willAppear) {
        self.willAppear(self);
    }
    
    if (self.effect==AKAlertEffectDrop) {
        
        //step1
        animateBlock drop = ^(){
            
            contentView.center=CGPointMake(kScreenW/2, -kScreenH);
            
            headView.alpha=1;
            
            [UIView animateWithDuration:KunitTime delay:0 options:UIViewAnimationOptionCurveEaseInOut animations:^{
                
                contentView.center=CGPointMake(kScreenW/2, kScreenH/2);
                
                
            } completion:^(BOOL finished) {
                [self removeAni];
            }];
        };
        
        [_animateArr addObject:drop];
        if (self.type==AKAlertSuccess && [[CommonCode readFromUserD:@"isLogin"]boolValue] == YES){
            animateBlock up = ^(){
                
                experienceView.frame = CGRectMake(170, 120, 40, 40);

                experienceView.alpha=0;
                
                [UIView animateWithDuration:KunitTime delay:0 options:UIViewAnimationOptionCurveEaseInOut animations:^{
                    
                    experienceView.alpha=1;
                    experienceView.frame = CGRectMake(170, 80, 40, 40);;
                    
                    
                } completion:^(BOOL finished) {
                    [self removeAni];
                }];
            };
            
            [_animateArr addObject:up];
        }
        
        //        //step2
        //        animateBlock smaller = ^(){
        //
        //            [UIView animateWithDuration:KunitTime delay:0 options:UIViewAnimationOptionCurveEaseInOut animations:^{
        //
        //
        //                headView.alpha=1;
        //
        //                headView.transform=CGAffineTransformMakeScale(0.4, 0.4);
        //
        //            } completion:^(BOOL finished) {
        //
        //               [self removeAni];
        //            }];
        //        };
        //
        //        [_animateArr addObject:smaller];
        //
        //
        //        //step3
        //        animateBlock bigger = ^(){
        //
        //            [UIView animateWithDuration:KunitTime delay:0 options:UIViewAnimationOptionCurveEaseInOut animations:^{
        //
        //                headView.transform=CGAffineTransformIdentity;
        //
        //            } completion:^(BOOL finished) {
        //
        //                 [self removeAni];
        //
        //                if (self.didAppear) {
        //                    self.didAppear(self);
        //                }
        //            }];
        //        };
        //
        //        [_animateArr addObject:bigger];
        
        
    }
    if (self.effect==AKAlertEffectFade) {
        
        
        animateBlock fadeBG = ^(){
            bgView.alpha=0.5;
            contentView.alpha=0;
            [UIView animateWithDuration:KunitTime delay:0 options:UIViewAnimationOptionCurveEaseInOut animations:^{
                
                bgView.alpha=1;
                
            } completion:^(BOOL finished) {
                
                [self removeAni];
            }];
        };
        
        [_animateArr addObject:fadeBG];
        
        animateBlock fade = ^(){
            
            [UIView animateWithDuration:KunitTime delay:0 options:UIViewAnimationOptionCurveEaseInOut animations:^{
                
                contentView.alpha=1;
                
            } completion:^(BOOL finished) {
                
                [self removeAni];
                
                if (self.didAppear) {
                    self.didAppear(self);
                }
            }];
        };
        
        [_animateArr addObject:fade];
        
        
    }
    
    [self nextAnimate];
    
    
}

-(void)nextAnimate{
    
    if (_animateArr.count==0) {
        return;
    }
    animateBlock ani= [_animateArr firstObject];
    ani();
    
    
}

-(void)removeAni{
    [_animateArr removeObjectAtIndex:0];
    
    [self nextAnimate];
}


#pragma mark  - user Interaction

-(void)dismiss{
    
    
    dispatch_async(dispatch_get_main_queue(), ^(void) {
        if (self.willDisappear) {
            self.willDisappear(self);
        }
        [UIView animateWithDuration:KunitTime delay:0 options:UIViewAnimationOptionCurveLinear animations:^{
            self.alpha=0;
            
        } completion:^(BOOL finished) {
            [self removeFromSuperview];
            
            if (self.didDisappear) {
                self.didDisappear(self);
            }
        }];
        
        
    });
    
    
}

-(void)btnClick:(UIButton*)btn{
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        
        
        switch (btn.tag) {
            case 10://sure
                if (self.sureClick) {
                    self.sureClick(self,shareBtn.selected,messageTextV.text);
                }
                [self dismiss];
                break;
            case 11://cancel
                
                if (self.cancelClick) {
                    self.cancelClick(self);
                }
                [self dismiss];
                break;
            case 12://cancel
                
                if (self.cancelClick) {
                    self.cancelClick(self);
                }
                [self dismiss];
                break;
            case 13://cancel
            {
                if (shareBtn.selected) {
                    shareBtn.selected = NO;
                }
                else{
                    shareBtn.selected = YES;
                }
            }
                break;
                
            default:
                [self dismiss];
                break;
        }
        
    });
    
}


-(void)bgTap{
    
    if (self.bgClick) {
        self.bgClick(self);
    }
    //    [self dismiss];
}



-(void)setupColorAndImg{
    
    UIImage* img =nil;
    
    switch (self.type) {
        case AKAlertSuccess:
            img=[UIImage imageNamed:@"PaySuccess"];
            self.tintColor=BLUECOLOR;
            break;
            
        case AKAlertInfo:
            img=[self imageWithBgColor:BLUECOLOR logo:[UIImage imageNamed:@"infoMark"]];
            self.tintColor=BLUECOLOR;
            break;
            
        case AKAlertFaild:
            img=[UIImage imageNamed:@"PayFail"];
            self.tintColor=BLUECOLOR;
            
            break;
        case AKAlertCustom:
            img =self.headImg;
            break;
            
        default:
            break;
    }
    
    headView.image=img;
}

-(UIImage*)imageWithBgColor:(UIColor*)color logo:(UIImage*)logoImg{
    if (!color||!logoImg) {
        return  nil;
    }
    UIGraphicsBeginImageContextWithOptions(CGSizeMake(headW, headW), NO, 1);
    
    CGContextRef ctx=  UIGraphicsGetCurrentContext();
    
    
    CGContextSetFillColorWithColor(ctx, [color CGColor]);
    
    CGContextBeginPath(ctx);
    CGContextAddArc(ctx, headW/2, headW/2, headW/2, 0, M_PI*2, YES);
    CGContextClosePath(ctx);
    CGContextFillPath(ctx);
    
    
    float logoW=headW*0.3,logoY=(headW-logoW)/2;
    
    [logoImg drawInRect:CGRectMake(logoY, logoY,logoW,logoW)];
    
    UIImage * img =   UIGraphicsGetImageFromCurrentImageContext();
    
    UIGraphicsEndImageContext();
    
    return  img ;
}

#pragma mark --- UItextViewDelegate
-(void)textViewDidChange:(UITextView *)textView{
    NSString  *nsTextContent = textView.text;
    NSInteger existTextNum = nsTextContent.length;
    if (existTextNum > 25){
        //截取到最大位置的字符
        NSString *s = [nsTextContent substringToIndex:25];
        [textView setText:s];
    }
    if (nsTextContent.length == 0) {
        textVPlaceholderLab.hidden = NO;
    }
    else{
        textVPlaceholderLab.hidden = YES;
    }
    if ([nsTextContent length] <= 25) {
        [textCountlab setText:[NSString stringWithFormat:@"还能输入%lu个字",(25 - (unsigned long)[textView.text length])]];
        messageTextV.userInteractionEnabled = YES;
    }
    else{
        [textCountlab setText:@"还能输入0个字"];
    }
    
}

- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range
 replacementText:(NSString *)text{
    
    NSString *comcatstr = [textView.text stringByReplacingCharactersInRange:range withString:text];
    
    NSInteger caninputlen = 25 - comcatstr.length;
    
    if (caninputlen >= 0)
    {
        return YES;
    }
    else
    {
        NSInteger len = text.length + caninputlen;
        //防止当text.length + caninputlen < 0时，使得rg.length为一个非法最大正数出错
        NSRange rg = {0,MAX(len,0)};
        
        if (rg.length > 0)
        {
            NSString *s = [text substringWithRange:rg];
            
            [textView setText:[textView.text stringByReplacingCharactersInRange:range withString:s]];
        }
        return NO;
    }
    
}

-(void)textViewDidBeginEditing:(UITextView *)textView{
    contentView.center=CGPointMake(kScreenW/2, kScreenH/2 - 100);
}

- (void)textViewDidEndEditing:(UITextView *)textView{
    contentView.center=CGPointMake(kScreenW/2, kScreenH/2);
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField{
    [textField resignFirstResponder];
    //主要是[receiver resignFirstResponder]在哪调用就能把receiver对应的键盘往下收
    return YES;
}

@end
