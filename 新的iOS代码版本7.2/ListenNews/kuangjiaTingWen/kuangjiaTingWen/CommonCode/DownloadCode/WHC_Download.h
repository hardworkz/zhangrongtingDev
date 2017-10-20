//
//  WHC_Download.h
//  PhoneBookBag
//
//  Created by 吴海超 on 15/7/27.
//  Copyright (c) 2015年 吴海超. All rights reserved.
//

/*
 *  qq:712641411
 *  iOS大神qq群:460122071
 *  gitHub:https://github.com/netyouli
 *  csdn:http://blog.csdn.net/windwhc/article/category/3117381
 */

#import <Foundation/Foundation.h>
#define kWHC_DownloadDidCompleteNotification (@"WHCDownloadDidCompleteNotification")
@class WHC_Download,NewObj;

typedef enum:NSInteger{
    FreeDiskSpaceLack,      //磁盘空间不足错误
    GeneralErrorInfo,       //一般错误信息
    NetWorkErrorInfo        //网络工作错误
}WHCDownloadErrorType;

@protocol WHCDownloadDelegate <NSObject>
@optional
//得到第一相应并判断要下载的文件是否已经完整下载了
- (void)WHCDownload:(WHC_Download *)download filePath:(NSString *)filePath hasACompleteDownload:(BOOL)has;

//接受下载数据处理下载显示进度和网速
- (void)WHCDownload:(WHC_Download *)download didReceivedLen:(uint64_t)receivedLen totalLen:(uint64_t)totalLen networkSpeed:(NSString *)networkSpeed;

//下载出错
- (void)WHCDownload:(WHC_Download *)download error:(NSError *)error;

//下载结束
- (void)WHCDownload:(WHC_Download *)download filePath:(NSString *)filePath isSuccess:(BOOL)success;

@end

@interface WHC_Download : NSOperation

@property (nonatomic , assign)id<WHCDownloadDelegate>delegate;
@property (nonatomic , copy)NSString       *   saveFilePath;      //文件名路径
@property (nonatomic , copy)NSString       *   saveFileName;      //文件名
@property (nonatomic , strong)NSURL          *   downUrl;           //下载地址
@property (nonatomic , copy , readonly)NSString       *   downPath;           //下载地址
@property (nonatomic , assign , readonly)BOOL               downloadComplete;  //下载是否完成
@property (nonatomic , assign , readonly)BOOL               downloading;       //是否正在下载
@property(nonatomic , copy) void(^progressBlock)(NSString * bytesRead, long long totalBytesRead, long long totalBytesExpectedToRead);
@property(nonatomic , copy) void(^statue)();

@property (nonatomic , assign , readonly)uint64_t           downloadLen;       //下载实际长度
@property (nonatomic , assign , readonly)uint64_t           totalLen;          //文件实际总长度
@property (nonatomic) BOOL isdownLoad;
@property (nonatomic) BOOL isFinsh;

@property (nonatomic, strong) NSMutableDictionary *obj;
//取消下载是否删除已下载的文件
- (void)cancelDownloadTaskAndDelFile:(BOOL)isDel;

//添加依赖下载队列
- (void)addDependOnDownload:(WHC_Download *)download;

- (id)initStartDownloadWithURL:(NSURL *)url
                      savePath:(NSString *)savePath
                  savefileName:(NSString*)savefileName
                       withObj:(NSMutableDictionary *)obj
                       isSingleDownload:(BOOL)isSingleDownload
                      delegate:(id<WHCDownloadDelegate>)delegate;

@end
