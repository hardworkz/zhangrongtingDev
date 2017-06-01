//
//  ProjiectDownLoadManager.h
//  Heard the news
//
//  Created by Pop Web on 15/10/27.
//  Copyright © 2015年 泡果网络. All rights reserved.
//

#import <Foundation/Foundation.h>

@class NewObj;

@interface ProjiectDownLoadManager : NSObject

@property (nonatomic, strong) NSMutableArray *downloadArray;
@property (nonatomic, strong) NSString *userDownLoadPath;
@property (nonatomic, strong) NSString *userDownLoadPlsit;
@property (nonatomic, strong) NSString *userDownLoadPathImage;
@property (nonatomic, strong) NSOperationQueue *downLoadQueue;
@property (nonatomic, strong) NSString *userDownLoadSevaPlsit;

+ (ProjiectDownLoadManager *)defaultProjiectDownLoadManager;
- (NSArray *)userDownLoadPathArray;
- (void)insetallDownLoadPlist:(NSDictionary *)dictionary;
- (NSArray *)downloadAllNewObjArrar;
- (void)removeDownloadMP3Array:(NSArray *)array;
- (void)removeDownloadImageArray:(NSArray *)array;
- (void)removeDownloadPlist:(NSArray *)array;
- (void)removeAll;
- (void)removeAllOperationQueueDelegateWithDownLoadObject;
- (void)insertSevaDownLoadArray:(NSMutableDictionary *)objc;
- (NSArray *)sevaDownloadArray;
- (void)removeSaveObject:(NSMutableDictionary *)objc;
@end
