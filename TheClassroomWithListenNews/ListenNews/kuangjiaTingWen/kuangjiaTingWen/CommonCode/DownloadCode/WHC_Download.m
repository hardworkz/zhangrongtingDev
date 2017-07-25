//
//  WHC_Download.m
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

#import "WHC_Download.h"

//#import "NewObj.h"

#import "SDWebImageManager.h"

#import "CommonCode.h"

#import "ProjiectDownLoadManager.h"
#define ProManager [ProjiectDownLoadManager defaultProjiectDownLoadManager]

#define kWHC_RequestTimeout                         (60)     //默认请求超时时间60s
#define kWHC_Domain                                 (@"WHC_Download")
#define kWHC_InvainUrl                              (@"无效的url%@")
#define kWHC_calculateFolderSpaceAvailableFailTxt   (@"计算文件夹存储空间失败")
#define kWHC_ErrorCode                              (@"错误码:%ld")
#define kWHC_FreeDiskSapceError                     (@"磁盘可用空间不足需要存储空间:%llu")
#define kWHC_RequestRange                           (@"bytes=%lld-")
#define kWHC_WriteSizeLen                           (1024 * 1024)
#define kWHC_DownloadSpeedDuring                    (1.5)

typedef enum : NSUInteger {
    downloadState,
    downloadStop,
} DownloadStatue;
@interface WHC_Download (){
    //    NSURLConnection           *   _urlConnection;      //网络连接
    //    NSMutableData             *   _downloadData;       //文件数据存储
    unsigned long long            _localFileSizeLen;   //文件尺寸大小
    unsigned long long            _actualFileSizeLen;  //实际文件大小
    unsigned long long            _recvDataLen;        //接受数据长度
    unsigned long long            _orderTimeRecvLen;   //特定时间接受的长度
    //    NSFileHandle              *   _fileHandle;         //文件句柄
    //    NSTimer                   *   _timer;              //网速时钟
    //    NSString                  *   _downloadSpeed;      //下载速度
}

@property (nonatomic, strong)NSURLConnection *urlConnection;      //网络连接
@property (nonatomic, strong)NSFileHandle    *fileHandle;         //文件句柄
@property (nonatomic, strong) NSMutableData  *downloadData;       //文件数据存储
@property (nonatomic, strong) NSTimer        *timer;              //网速时钟

@property (nonatomic, copy) NSString         *downloadSpeed;      //下载速度
@property (nonatomic, copy) NSString         *imageURL;      //下载速度

@property (nonatomic, strong) NSSet *runLoopModes;
@property (nonatomic, strong) NSOutputStream *outputStream;
@property (readwrite, nonatomic, strong) NSRecursiveLock *lock;
@property (nonatomic) DownloadStatue downloadStatue;
@end


@implementation WHC_Download
@synthesize outputStream = _outputStream;

#pragma mark - OverrideProperty

- (id)initStartDownloadWithURL:(NSURL *)url
                      savePath:(NSString *)savePath
                  savefileName:(NSString*)savefileName
                       withObj:(NSMutableDictionary *)obj
                      delegate:(id<WHCDownloadDelegate>)delegate {
    if (self = [super init]) {
        for (NSMutableDictionary *d in [ProManager downloadAllNewObjArrar]) {
            if ([d[@"post_mp"] rangeOfString:[obj[@"post_mp"] stringByReplacingOccurrencesOfString:@"/" withString:@""]].location != NSNotFound) {
                RTLog(@"存在");
                return nil;
            }
        }
        NSString * fielName = nil;
        if(savefileName){
            NSString * format = [self fileFormat:url.absoluteString];
            if([format isEqualToString:[NSString stringWithFormat:@".%@",[[savefileName componentsSeparatedByString:@"."] lastObject]]]){
                fielName = savefileName;
            }else{
                fielName = [NSString stringWithFormat:@"%@%@",savefileName,format];
            }
        }
        for (WHC_Download * tempDownload in ProManager.downLoadQueue.operations) {
            if ([fielName isEqualToString:tempDownload.saveFileName]){
                //                if(delegate && [delegate respondsToSelector:@selector(WHCDownload:filePath:hasACompleteDownload:)]){
                //                    [delegate WHCDownload:tempDownload filePath:savePath hasACompleteDownload:YES];
                //                }
                return nil;
            }
        }
        self.isdownLoad = NO;
        //        self.delegate = delegate;
        self.saveFileName = fielName;
        self.saveFilePath = savePath;
        [self setProgressBlock:^(NSString * a, long long b, long long c) {
            //            NSLog(@"%@,%@,%@", a,@(b), @(c));
        }];
        self.lock = [[NSRecursiveLock alloc] init];
        //        self.lock.name = @"com.alamofire.tingwen.operation.lock";
        self.runLoopModes = [NSSet setWithObject:NSRunLoopCommonModes];
        self.obj = obj;
        //新闻图片url处理
        NSString *finalURL = NEWSSEMTPHOTOURL(obj[@"smeta"]);
        if ([finalURL  rangeOfString:@"http"].location != NSNotFound){
            finalURL = NEWSSEMTPHOTOURL(obj[@"smeta"]);
        }
        else{
            finalURL = USERPHOTOHTTPSTRINGZhuBo(NEWSSEMTPHOTOURL(obj[@"smeta"]));
        }
        self.imageURL = finalURL;
        self.downUrl = url;
        self.isFinsh = NO;
        self.name = @"download";
        //        [self setStatue:^{
        //
        //        }];
        self.downloadStatue = downloadStop;
        [ProManager insertSevaDownLoadArray:obj];
        
        
        //判断是否是单次下载新闻，记录次数限制
        NSDictionary *userInfoDict = [CommonCode readFromUserD:@"dangqianUserInfo"];
        RTLog(@"%@",userInfoDict);
        if ([userInfoDict[results][member_type] intValue] == 0) {
            int limitTime = [[CommonCode readFromUserD:[NSString stringWithFormat:@"%@_%@",limit_time,ExdangqianUserUid]] intValue];
            RTLog(@"limit_time---%d",limitTime);
            int limitNum = [[CommonCode readFromUserD:[NSString stringWithFormat:@"%@",limit_num]] intValue];
            if (limitTime >= limitNum) {
                [NetWorkTool sendLimitDataWithaccessToken:AvatarAccessToken sccess:^(NSDictionary *responseObject) {
                    if ([responseObject[status] intValue] == 1) {
                        [[NSNotificationCenter defaultCenter] postNotificationName:@"updateUserInfo" object:nil];
                    }
                } failure:^(NSError *error) {
                    
                }];
            }else{
                [CommonCode writeToUserD:[NSString stringWithFormat:@"%d",limitTime + 1] andKey:[NSString stringWithFormat:@"%@_%@",limit_time,ExdangqianUserUid]];
            }
        }
    }
    return self;
}

//获取要下载的文件格式
- (NSString *)fileFormat:(NSString *)downloadUrl{
    NSArray  * strArr = [downloadUrl componentsSeparatedByString:@"."];
    if(strArr && strArr.count > 0){
        NSString *s = [NSString stringWithFormat:@".%@",strArr.lastObject];
        return s;
    }else{
        return nil;
    }
}

- (NSString *)saveFileName{
    if(_saveFileName){
        return _saveFileName;
    }else{
        return [_downUrl lastPathComponent];
    }
}

- (NSString *)saveFilePath{
    return [_saveFilePath stringByAppendingString:self.saveFileName];
}

- (NSString *)downPath{
    return self.downUrl.absoluteString;
}

- (uint64_t)downloadLen{
    return _recvDataLen;
}

- (uint64_t)totalLen{
    return _actualFileSizeLen;
}
#pragma mark - OverrideMethod

- (void)start{
    [self.lock lock];
    
    @autoreleasepool {
        NSMutableURLRequest  * urlRequest = [[NSMutableURLRequest alloc]initWithURL:_downUrl cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:kWHC_RequestTimeout];
        //检测该请求是否合法
        if(![NSURLConnection canHandleRequest:urlRequest]){
            [self handleDownloadError:nil];
        }else{
            __autoreleasing  NSError  * error = nil;
            NSFileManager  * fm = [NSFileManager defaultManager];
            if(![fm fileExistsAtPath:self.saveFilePath]){
                [fm createFileAtPath:self.saveFilePath contents:nil attributes:nil];
            }else {
                _localFileSizeLen = [[fm attributesOfItemAtPath:self.saveFilePath error:&error] fileSize];
                NSData *data = [NSData dataWithContentsOfFile:self.saveFilePath];
                NSString  * strRange =  [NSString stringWithFormat:@"bytes=-%lu", (unsigned long)data.length];
                [urlRequest addValue:strRange forHTTPHeaderField:@"Range"];
            }
            if(error == nil){
                _fileHandle = nil;
                self.fileHandle = [NSFileHandle fileHandleForWritingAtPath:self.saveFilePath];
                [_fileHandle seekToEndOfFile];

                if(_urlConnection == nil){
                    self.urlConnection = [[NSURLConnection alloc]initWithRequest:urlRequest delegate:self startImmediately:NO];
                }
                
                if ([self isCancelled]) {
                    [self performSelector:@selector(cancelConnection1) onThread:[[self class] networkRequestThread1] withObject:nil waitUntilDone:NO modes:[self.runLoopModes allObjects]];
                } else {
                    
                    [self performSelector:@selector(operationDidStart1) onThread:[[self class] networkRequestThread1] withObject:nil waitUntilDone:NO modes:[self.runLoopModes allObjects]];
                }
            }else{
            }
        }
    }
    
    [self.lock unlock];
    
}

- (NSOutputStream *)outputStream {
    if (!_outputStream) {
        self.outputStream = [NSOutputStream outputStreamToMemory];
    }
    
    return _outputStream;
}

- (void)operationDidStart1 {
    [self.lock lock];
    //    if (![self isCancelled]) {
    NSMutableURLRequest  * urlRequest = [[NSMutableURLRequest alloc]initWithURL:_downUrl cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:kWHC_RequestTimeout];
    //检测该请求是否合法
    if(![NSURLConnection canHandleRequest:urlRequest]){
        [self handleDownloadError:nil];
    }else{
            @autoreleasepool {
                NSRunLoop *runLoop = [NSRunLoop currentRunLoop];
                for (NSString *runLoopMode in self.runLoopModes) {
                    [self.urlConnection scheduleInRunLoop:runLoop forMode:runLoopMode];
                    [self.outputStream scheduleInRunLoop:runLoop forMode:runLoopMode];
                }
                [self willChangeValueForKey:@"isExecuting"];
                [self.outputStream open];
                [self.urlConnection start];
                _downloadStatue = downloadState;
                [self didChangeValueForKey:@"isExecuting"];
            }
        }
        [self.lock unlock];
}

- (void)setOutputStream:(NSOutputStream *)outputStream {
    [self.lock lock];
    if (outputStream != _outputStream) {
        if (_outputStream) {
            [_outputStream close];
        }
        
        _outputStream = outputStream;
    }
    [self.lock unlock];
}

- (void)cancelConnection1 {
    if (![self isFinished]) {
        if (self.urlConnection) {
            [self.urlConnection cancel];

        } else {

        }
    }
}

+ (void)networkRequestThreadEntryPoint1:(id)__unused object {
    @autoreleasepool {
        [[NSThread currentThread] setName:@"downloadQueue"];
        NSRunLoop *runLoop = [NSRunLoop currentRunLoop];
        [runLoop addPort:[NSMachPort port] forMode:NSDefaultRunLoopMode];
        [runLoop run];
    }
}

+ (NSThread *)networkRequestThread1 {
    static NSThread *_networkRequestThread = nil;
    static dispatch_once_t oncePredicate;
    dispatch_once(&oncePredicate, ^{
        _networkRequestThread = [[NSThread alloc] initWithTarget:self selector:@selector(networkRequestThreadEntryPoint1:) object:nil];
        [_networkRequestThread start];
    });
    
    return _networkRequestThread;
}

- (BOOL)isFinished{
    return self.urlConnection == nil;
}

- (BOOL)isConcurrent{
    return YES;
}

- (BOOL)isAsynchronous{
    return YES;
}
#pragma mark - privateMethod

- (void)handleDownloadError:(NSError *)error{
    if(error == nil){
        error = [[NSError alloc]initWithDomain:kWHC_Domain
                                          code:GeneralErrorInfo
                                      userInfo:@{NSLocalizedDescriptionKey:[NSString stringWithFormat:kWHC_InvainUrl,_downUrl.path]}];
    }
    NSFileManager  * fm = [NSFileManager defaultManager];
    if([fm fileExistsAtPath:self.saveFilePath]){
        __autoreleasing  NSError  * error = nil;
        [fm removeItemAtPath:self.saveFilePath error:&error];
    }
    dispatch_async(dispatch_get_main_queue(), ^{
        if(_delegate && [_delegate respondsToSelector:@selector(WHCDownload:error:)]){
            [_delegate WHCDownload:self error:error];
        }
    });
}

- (void)cancelledDownloadNotify{
    if(_timer){
        [_timer invalidate];
        [_timer fire];
        _timer = nil;
    }
    
    [ProManager.downloadArray removeObject:self];
    self.delegate = nil;
    if (_downloadStatue == downloadStop) {
        [_fileHandle synchronizeFile];
        [_fileHandle closeFile];
        self.fileHandle = nil;
        self.urlConnection = nil;
        self.downloadData = nil;
        return;
    }

    [self willChangeValueForKey:@"isExecuting"];
    [self willChangeValueForKey:@"isFinished"];
    [self willChangeValueForKey:@"isCancelled"];
    [self.urlConnection cancel];
    [_fileHandle synchronizeFile];
    [_fileHandle closeFile];
    self.fileHandle = nil;
    self.urlConnection = nil;
    self.downloadData = nil;
    [self didChangeValueForKey:@"isExecuting"];
    [self didChangeValueForKey:@"isFinished"];
    [self didChangeValueForKey:@"isCancelled"];
}

- (unsigned long long)calculateFreeDiskSpace{
    unsigned long long  freeDiskLen = 0;
    NSString * docPath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject];
    NSFileManager  * fm   = [NSFileManager defaultManager];
    NSDictionary   * dict = [fm attributesOfFileSystemForPath:docPath error:nil];
    if(dict){
        freeDiskLen = [dict[NSFileSystemFreeSize] unsignedLongLongValue];
    }
    return freeDiskLen;
}

- (void)calculateDownloadSpeed{
    float downloadSpeed = (float)_orderTimeRecvLen / (kWHC_DownloadSpeedDuring * 1024.0);
    _downloadSpeed = [NSString stringWithFormat:@"%.1fKB/S", downloadSpeed];
    if(downloadSpeed >= 1024.0){
        downloadSpeed = ((float)_orderTimeRecvLen / 1024.0) / (kWHC_DownloadSpeedDuring * 1024.0);
        _downloadSpeed = [NSString stringWithFormat:@"%.1fMB/S",downloadSpeed];
    }
    _orderTimeRecvLen = 0;
}

- (void)dealloc{
    _downloadComplete = YES;
    if (_outputStream) {
        [_outputStream close];
        _outputStream = nil;
    }
    if(_timer){
        [_timer invalidate];
        [_timer fire];
        _timer = nil;
    }
    //        [[NSNotificationCenter defaultCenter]postNotificationName:kWHC_DownloadDidCompleteNotification object:self];
}

#pragma mark - publicMothed

//添加依赖下载队列
- (void)addDependOnDownload:(WHC_Download *)download{
    [self addDependency:download];
}

//取消下载是否删除已下载的文件
- (void)cancelDownloadTaskAndDelFile:(BOOL)isDel{
    _downloading = NO;
    _downloadComplete = isDel;
    [self cancelledDownloadNotify];
    if(isDel){
        NSFileManager  * fm = [NSFileManager defaultManager];
        if([fm fileExistsAtPath:self.saveFilePath]){
            __autoreleasing  NSError  * error = nil;
            [fm removeItemAtPath:self.saveFilePath error:&error];
        }
    }
    dispatch_async(dispatch_get_main_queue(), ^{
        if(_delegate && [_delegate respondsToSelector:@selector(WHCDownload:filePath:isSuccess:)]){
            [_delegate WHCDownload:self filePath:_downUrl.absoluteString  isSuccess:NO];
        }
    });
    
}

#pragma mark - NSURLConnectionDelegate
- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error{
    if (error) {
        NSLog(@"下载失败");
        [ProManager removeSaveObject:_obj];
        NSFileManager  * fm = [NSFileManager defaultManager];
        if([fm fileExistsAtPath:self.saveFilePath]){
            __autoreleasing  NSError  * error = nil;
            [fm removeItemAtPath:self.saveFilePath error:&error];
        }
        _isFinsh = YES;
        dispatch_async(dispatch_get_main_queue(), ^{
            if (_delegate && [_delegate respondsToSelector:@selector(WHCDownload:error:)]) {
                [_delegate WHCDownload:self error:error];
            }
        });
    }
    [self cancelledDownloadNotify];
    [self handleDownloadError:error];
}

- (void)connection:(NSURLConnection*)connection didReceiveResponse:(NSURLResponse *)response{
    [self.lock lock];
    BOOL  isCancel = YES;
    _actualFileSizeLen = response.expectedContentLength + _localFileSizeLen;
    NSHTTPURLResponse  *  headerResponse = (NSHTTPURLResponse *)response;
    if(headerResponse.statusCode >= 400){
        if(headerResponse.statusCode == 416){
            _downloadComplete = YES;
            [self cancelledDownloadNotify];
            dispatch_async(dispatch_get_main_queue(), ^{
                if(_delegate && [_delegate respondsToSelector:@selector(WHCDownload:filePath:hasACompleteDownload:)]){
                    [_delegate WHCDownload:self filePath:self.saveFilePath hasACompleteDownload:YES];
                }
            });
            return;
        }else{
            __autoreleasing NSError  * error = [[NSError alloc]initWithDomain:kWHC_Domain code:NetWorkErrorInfo userInfo:@{NSLocalizedDescriptionKey:[NSString stringWithFormat:kWHC_ErrorCode,(long)headerResponse.statusCode]}];
            [self handleDownloadError:error];
        }
    }else{
        if([self calculateFreeDiskSpace] < _actualFileSizeLen){
            __autoreleasing NSError  * error = [[NSError alloc]initWithDomain:kWHC_Domain code:FreeDiskSpaceLack userInfo:@{NSLocalizedDescriptionKey:[NSString stringWithFormat:kWHC_FreeDiskSapceError,_actualFileSizeLen]}];
            [self handleDownloadError:error];
        }else{
            _downloading = YES;
            _recvDataLen = _localFileSizeLen;
            _orderTimeRecvLen = 0;
            if (!self.timer) {
                self.timer = [NSTimer scheduledTimerWithTimeInterval:kWHC_DownloadSpeedDuring target:self selector:@selector(calculateDownloadSpeed) userInfo:nil repeats:YES];
            }
            isCancel = NO;

            dispatch_async(dispatch_get_main_queue(), ^{
                if(_delegate && [_delegate respondsToSelector:@selector(WHCDownload:filePath:hasACompleteDownload:)]){
                    [_delegate WHCDownload:self filePath:self.saveFilePath hasACompleteDownload:NO];
                }
            });
            [self calculateDownloadSpeed];
        }
    }
    if(isCancel){
        [self cancelDownloadTaskAndDelFile:NO];
    }
    [self.lock unlock];
}


- (void)connection:(NSURLConnection*)connection didReceiveData:(NSData *)data{
    //    [_downloadData appendData:data];
    [self.lock lock];
    _recvDataLen += data.length;
    _orderTimeRecvLen += data.length;
    if( _fileHandle){
        [_fileHandle writeData:data];
    }
    dispatch_async(dispatch_get_main_queue(), ^{
        if(_delegate && [_delegate respondsToSelector:@selector(WHCDownload:didReceivedLen:totalLen:networkSpeed:)]){
            [_delegate WHCDownload:self didReceivedLen:_recvDataLen totalLen:_actualFileSizeLen networkSpeed:_downloadSpeed];
        }
    });
    [self.lock unlock];
}

- (void)connectionDidFinishLoading:(NSURLConnection*)connection{
    //    if(_fileHandle){
    //        [_fileHandle writeData:_downloadData];
    //        self.downloadData = nil;
    //        self.downloadData = [NSMutableData data];
    //    }
    [self.lock lock];
    dispatch_async(dispatch_get_main_queue(), ^{
        if(_delegate && [_delegate respondsToSelector:@selector(WHCDownload:filePath:isSuccess:)]){
            [_delegate WHCDownload:self filePath:self.saveFilePath  isSuccess:YES];
        }
    });
    [self cancelledDownloadNotify];
    
    //    [_downloadData writeToFile:self.saveFileName atomically:YES] ? NSLog(@"下载成功") : NSLog(@"下载失败");
    NSMutableDictionary *objDic = [_obj mutableCopy];
    __weak __typeof(self) selfBlock = self;
    [objDic setValue:[_obj[@"post_mp"] stringByReplacingOccurrencesOfString:@"/" withString:@""] forKey:@"post_mp"];
    
    [ProManager removeSaveObject:_obj];
    
    //下载图片
    [[SDWebImageDownloader sharedDownloader] downloadImageWithURL:[NSURL URLWithString:_imageURL] options:0 progress:nil completed:^(UIImage *image, NSData *data, NSError *error, BOOL finished) {
        if (!error) {
            @synchronized(selfBlock) {
                @autoreleasepool {
                    //获取图片目录路径
                    NSString *finalURL = NEWSSEMTPHOTOURL(_obj[@"smeta"]);
                    if ([finalURL  rangeOfString:@"http"].location != NSNotFound){
                        finalURL = NEWSSEMTPHOTOURL(_obj[@"smeta"]);
                    }
                    else{
                        finalURL = USERPHOTOHTTPSTRINGZhuBo(NEWSSEMTPHOTOURL(_obj[@"smeta"]));
                    }
                    //存储路径去掉 "/"符号
                    NSString *imagePath = [ProManager.userDownLoadPathImage stringByAppendingPathComponent:[finalURL stringByReplacingOccurrencesOfString:@"/" withString:@""]];
                    //转化为NSData
                    //                NSData *imageData = UIImageJPEGRepresentation(image, 0.9);
                    //图片写入到本地
                    if ([data writeToFile:imagePath atomically:YES]) {
                        //设置本地图片地址
                        //下载完成
                        //新闻图片url处理
                        NSString *finalURL = NEWSSEMTPHOTOURL(selfBlock.obj[@"smeta"]);
                        if ([finalURL  rangeOfString:@"http"].location != NSNotFound){
                            finalURL = NEWSSEMTPHOTOURL(selfBlock.obj[@"smeta"]);
                        }
                        else{
                            finalURL = USERPHOTOHTTPSTRINGZhuBo(NEWSSEMTPHOTOURL(selfBlock.obj[@"smeta"]));
                        }
                        [objDic setValue:[finalURL stringByReplacingOccurrencesOfString:@"/" withString:@""] forKey:@"smeta"];
                    }else {
                        NSLog(@"存储失败 %@", imagePath);
                    }
                }
            }
        }else{
            NSLog(@"图片下载失败");
        }
        [ProManager insetallDownLoadPlist:objDic];
        if (selfBlock) {
            [[NSNotificationCenter defaultCenter]postNotificationName:@"downloaddelete" object:@[selfBlock]];
            [ProManager.downloadArray removeObject:selfBlock];
        }
        
        [[NSNotificationCenter defaultCenter] postNotificationName:@"addDownload" object:objDic];
        
        [[NSNotificationCenter defaultCenter]postNotificationName:@"changeNumber" object:nil];
    }];
    [self.lock unlock];
}
@end
