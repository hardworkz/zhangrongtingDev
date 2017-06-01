//
//  AppDelegate.m
//  1yqb
//
//  Created by 曲天白 on 15/12/11.
//  Copyright © 2015年 乙科网络. All rights reserved.
//

#import "EXtern.h"

@implementation EXtern
NSMutableDictionary *MyuserDic =nil;
NSMutableArray *addFriendsApply = nil;
NSMutableArray  *EXDoneindexArray = nil;
NSString *ExNavLeftStr = nil;
NSString *ExdangqianUser = nil;
NSString *ExTouXiangPath = nil;
//播放器
AVPlayer *Explayer = nil;
int ExcurrentNumber = 0;
NSString *Exterm_id = nil;
int ExnumberPage = 0;             //当前数据页数(每页10个)
BOOL ExisRigester = NO;              //Explayer是否被注册
BOOL ExisFristOpenApp = YES;
BOOL ExisZaiWaiMianBoFangWanBi = YES;
NSString *ExchooseWhatYeMian = nil;      //判断是在搜索页面点进播放页的还是在别的什么页面, @"sousuoYeMianDianJi",@"centerYeMianDianJi",
BOOL ExisPingLunHouFanHui = NO;
NSString *ExdangqianUserUid = nil;     //当前登录用户uid
NSMutableArray *ExzhengzaixiazailiebiaoArr = nil;
//yixiazaiVC *Exyixiazai = nil;      //APP大全局已下载界面
NSMutableArray *ExxiazaishifouwanchengArr = nil;        //此下载cell是否完成
NSMutableArray *ExyiwanchengxiazaiArr = nil;       //已经完成下载的数组
BOOL ExisFristIntoApp = YES;
NSString *ExwhichBoFangYeMianStr = nil;  //是哪一个页面在播放
NSString *ExyanzhengmaStr = nil;       //注册验证码
NSString *ExZhuCeAccessToken = nil;    //注册手机号
NSString *ExwhichBoFangVCStr = nil;       //是哪一个控制器在播放
BOOL ExIsKaiShiBoFang = NO;           //是否开始播放，一进入app是默认没有播放，只有点击一个新闻后才会开始播放。
NSString *ExDangQianUserAccessToken = nil;
@end
