//
//  ProjiectDownLoadManager.m
//  Heard the news
//
//  Created by Pop Web on 15/10/27.
//  Copyright © 2015年 泡果网络. All rights reserved.
//

#import "ProjiectDownLoadManager.h"

#import "NewObj.h"

#import <UIKit/UIKit.h>

#import "WHC_Download.h"

#define FILEMANAGER [NSFileManager defaultManager]

@implementation ProjiectDownLoadManager

- (instancetype)init
{
    self = [super init];
    if (self) {
        self.downloadArray = [NSMutableArray array];
        self.downLoadQueue = [[NSOperationQueue alloc]init];
        _downLoadQueue.name = @"downloadQueue";
        [_downLoadQueue setMaxConcurrentOperationCount:3];
        //        [_downLoadQueue addObserver:self forKeyPath:@"operationCount" options:NSKeyValueObservingOptionNew context:nil];
    }
    
    return self;
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSString *,id> *)change context:(void *)context {
    if ([[NSString stringWithFormat:@"%@", change[@"new"]] isEqualToString:@"0"]) {
        [_downLoadQueue addOperation:[_downloadArray firstObject]];
    }
}

+ (ProjiectDownLoadManager *)defaultProjiectDownLoadManager {
    static ProjiectDownLoadManager *manager;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        manager = [[ProjiectDownLoadManager alloc]init];
    });
    return manager;
}

- (NSArray *)userDownLoadPathArray {
    return [FILEMANAGER contentsOfDirectoryAtPath:self.userDownLoadPath error:nil];
}

- (NSString *)userDownLoadPath {
    NSString *path = [NSString stringWithFormat:@"%@/Library/Caches/userDownLoadPathMP3/",NSHomeDirectory()];
    if (![FILEMANAGER fileExistsAtPath:path]) {
        [FILEMANAGER createDirectoryAtPath:path withIntermediateDirectories:YES attributes:nil error:nil];
    }
    return path;
}

- (NSString *)userDownLoadPathImage {
    NSString *path = [NSString stringWithFormat:@"%@/Library/Caches/userDownLoadPathImage",NSHomeDirectory()];
    if (![FILEMANAGER fileExistsAtPath:path]) {
        [FILEMANAGER createDirectoryAtPath:path withIntermediateDirectories:YES attributes:nil error:nil];
    }
    return path;
}

- (NSString *)userDownLoadPlsit {
    NSString *path = [NSString stringWithFormat:@"%@/Library/Caches/userDownLoadPlsit",NSHomeDirectory()];
    if (![FILEMANAGER fileExistsAtPath:path]) {
        [FILEMANAGER createDirectoryAtPath:path withIntermediateDirectories:YES attributes:nil error:nil];
    }
    return path;
}

- (NSString *)userDownLoadSevaPlsit {
    NSString *path = [NSString stringWithFormat:@"%@/Library/Caches/userDownLoadSevaPlsit",NSHomeDirectory()];
    if (![FILEMANAGER fileExistsAtPath:path]) {
        [FILEMANAGER createDirectoryAtPath:path withIntermediateDirectories:YES attributes:nil error:nil];
    }
    return path;
}

- (NSArray *)sevaDownloadArray {
    NSString *str = [self.userDownLoadSevaPlsit stringByAppendingPathComponent:@"downloadSevaArray"];
    NSArray *arr = [NSArray arrayWithContentsOfFile:str];
    if (arr) {
        return arr;
    }
    return nil;
}

//将下载的新闻缓存
- (void)insertSevaDownLoadArray:(NSMutableDictionary *)objc {
    //    dispatch_async(dispatch_get_main_queue(), ^{
    @autoreleasepool {
        NSString *str = [self.userDownLoadSevaPlsit stringByAppendingPathComponent:@"downloadSevaArray"];
        if (![FILEMANAGER fileExistsAtPath:str]) {
            [FILEMANAGER createFileAtPath:str contents:nil attributes:nil];
        }
        NSMutableArray *arr = [NSMutableArray arrayWithContentsOfFile:str];
        
        NSDictionary *dictionary = [objc copy];
        if (arr) {
            if (dictionary) {
                [arr addObject:dictionary];
            }
            [arr writeToFile:str atomically:YES];
            arr = nil;
        }else {
            NSMutableArray *arr1 = [NSMutableArray array];
            if (dictionary) {
                [arr1 addObject:dictionary];
            }
            [arr1 writeToFile:str atomically:YES];
            arr1 = nil;
        }
    }
    //    });
}


- (void)removeSaveObject:(NSMutableDictionary *)objc {
    //    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_LOW, 0), ^{
    NSMutableArray *array = [self sevaDownloadArray].mutableCopy;
    for (int i = 0; i < array.count; i++) {
        NSMutableDictionary *newObj = array[i];
        if ([newObj[@"post_mp"] isEqualToString:objc[@"post_mp"]]) {
            [array removeObjectAtIndex:i];
            break;
        }
    }
    //    NSLog(@"%@", array);
    NSString *str = [self.userDownLoadSevaPlsit stringByAppendingPathComponent:@"downloadSevaArray"];
    [array writeToFile:str atomically:YES] ?nil: NSLog(@"删除失败");
    //    });
}

/**
 *  将下载的新闻写入文件
 *
 *  @param dictionary ;
 */
- (void)insetallDownLoadPlist:(NSDictionary *)dictionary {
    @autoreleasepool {
        NSString *str = [self.userDownLoadPlsit stringByAppendingPathComponent:@"downloadArrar"];
        if (![FILEMANAGER fileExistsAtPath:str]) {
            [FILEMANAGER createFileAtPath:str contents:nil attributes:nil];
        }
        NSMutableArray *arr = [NSMutableArray arrayWithContentsOfFile:str];
        //        if (arr) {
        //            arr = nil;
        //            arr = [NSMutableArray new];
        //        }
        if (arr) {
            if (dictionary) {
                [arr insertObject:dictionary atIndex:0];
            }
            
            [arr writeToFile:str atomically:YES];
            arr = nil;
        }else {
            NSMutableArray *arr1 = [NSMutableArray array];
            if (dictionary) {
                [arr1 insertObject:dictionary atIndex:0];
            }
            
            [arr1 writeToFile:str atomically:YES];
            arr1 = nil;
        }
        
        
        //        free((__bridge void *)(arr));
    }
    
}

/**
 *  获取下载的所有文件
 *
 *  @return 数据数组
 */
- (NSArray *)downloadAllNewObjArrar {
    NSString *str = [self.userDownLoadPlsit stringByAppendingPathComponent:@"downloadArrar"];
    
    NSArray *arr = [NSArray arrayWithContentsOfFile:str];
    if (arr) {
        return arr;
    }
    return nil;
}

- (void)removeDownloadMP3Array:(NSArray *)array {
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_LOW, 0), ^{
        [array enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            [FILEMANAGER removeItemAtPath:obj error:nil];
        }];
    });
}

- (void)removeDownloadPlist:(NSArray *)array {
    @autoreleasepool {
        NSMutableArray *arr = [[self downloadAllNewObjArrar]mutableCopy];
        NSMutableArray *remArr = [NSMutableArray array];
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_LOW, 0), ^{
            [array enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
                 NewObj *o = (NewObj *)obj;
                [arr enumerateObjectsUsingBlock:^(id  _Nonnull obj1, NSUInteger idx, BOOL * _Nonnull stop) {
                    NSDictionary *dic = (NSDictionary *)obj1;
                    if ([dic[@"id"] isEqualToString:o.i_id]) {
                        [remArr addObject:obj1];
                    }
                }];
            }];
            [arr removeObjectsInArray:remArr];
            NSString *str = [self.userDownLoadPlsit stringByAppendingPathComponent:@"downloadArrar"];
            
            [arr writeToFile:str atomically:YES];
        });
    }
}

- (void)removeDownloadImageArray:(NSArray *)array {
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_LOW, 0), ^{
        [array enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            [FILEMANAGER removeItemAtPath:obj error:nil];
        }];
    });
}

- (void)removeAll {
    @autoreleasepool {
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_LOW, 0), ^{
            [FILEMANAGER removeItemAtPath:self.userDownLoadPath error:nil];
            [FILEMANAGER removeItemAtPath:self.userDownLoadPathImage error:nil];
            NSString *str = [self.userDownLoadPlsit stringByAppendingPathComponent:@"downloadArrar"];
            
            [FILEMANAGER removeItemAtPath:str error:nil];
            NSString *str1 = [self.userDownLoadSevaPlsit stringByAppendingPathComponent:@"downloadSevaArray"];
            [FILEMANAGER removeItemAtPath:str1 error:nil];
        });
    }
}

- (void)removeAllOperationQueueDelegateWithDownLoadObject{
    dispatch_async(dispatch_get_main_queue(), ^{
        [_downLoadQueue.operations enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            WHC_Download *downloadObject = (WHC_Download *)obj;
            downloadObject.delegate = nil;
        }];
    });
}

@end
