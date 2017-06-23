//
//  AppDelegate.m
//  1yqb
//
//  Created by 曲天白 on 15/12/11.
//  Copyright © 2015年 乙科网络. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AVFoundation/AVFoundation.h>
//#import "yixiazaiVC.h"
@interface EXtern : NSObject
extern NSMutableDictionary *MyuserDic;
extern NSMutableArray  *addFriendsApply;
extern NSMutableArray  *EXDoneindexArray;
extern NSString *ExNavLeftStr;
extern NSString *ExdangqianUser;
extern NSString *ExTouXiangPath;
//播放器
extern AVPlayer *Explayer;
extern int ExcurrentNumber;//当前音频在队列中的位置
extern NSString *Exterm_id;          //频道ID
extern int ExnumberPage;             //当前数据页数(每页10个)
extern BOOL ExisRigester;              //Explayer是否被注册
extern BOOL ExisFristOpenApp;
extern BOOL ExisZaiWaiMianBoFangWanBi;
extern NSString *ExchooseWhatYeMian;      //判断是在搜索页面点进播放页的还是在别的什么页面，@"sousuoYeMianDianJi",@"centerYeMianDianJi",
extern BOOL ExisPingLunHouFanHui;
extern NSString *ExdangqianUserUid;     //当前登录用户uid
extern NSMutableArray *ExzhengzaixiazailiebiaoArr;    //正在下载列表;
//extern yixiazaiVC *Exyixiazai;      //APP大全局已下载界面
extern NSMutableArray *ExxiazaishifouwanchengArr;        //此下载cell是否完成
extern NSMutableArray *ExyiwanchengxiazaiArr;       //已经完成下载的数组
extern BOOL ExisFristIntoApp;
extern NSString *ExwhichBoFangYeMianStr;  //是主控制器的哪一个页面在播放
extern NSString *ExyanzhengmaStr;       //注册验证码
extern NSString *ExZhuCeAccessToken;    //注册手机号
extern NSString *ExwhichBoFangVCStr;       //是哪一个控制器在播放
extern BOOL ExIsKaiShiBoFang;           //是否开始播放，一进入app是默认没有播放，只有点击一个新闻后才会开始播放。
extern NSString *ExDangQianUserAccessToken;
//课堂模块全局保存数据
extern BOOL ExIsClassVCPlay;//是否跳转播放课堂界面
extern NSString *Exact_id;//保存当前课堂ID
@end
