//
//  DownLoadRigthViewController.m
//  Heard the news
//
//  Created by Pop Web on 15/10/30.
//  Copyright © 2015年 泡果网络. All rights reserved.
//

#import "DownLoadRigthViewController.h"
#import "DownloadCell.h"

#import "ProjiectDownLoadManager.h"

#import "CommonCode.h"

#import "WHC_Download.h"

#import "NewObj.h"

#import "MBProgressHUD.h"


#define downManager [ProjiectDownLoadManager defaultProjiectDownLoadManager]
@interface DownLoadRigthViewController ()<UIAlertViewDelegate>
@property (nonatomic, strong) UILabel *label;

@property (nonatomic, strong)  NSMutableArray *downLoadArray;    //视频文件数组
@property (nonatomic, strong)  NSMutableSet   *downLoadSet;    //视频文件数组

@property (nonatomic, strong)  NSLock         *lock;    //视频文件数组
@property (nonatomic) NSInteger           selectIdx;
@end

@implementation DownLoadRigthViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.tableView.contentInset = UIEdgeInsetsMake(0, 0, 70, 0);
    self.tableView.tableFooterView = [UIView new];
    self.tableView.backgroundColor = gSubColor;
//    self.tableView.showsVerticalScrollIndicator = NO;
    self.tableView.showsHorizontalScrollIndicator = NO;
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(downloaddelete:) name:@"downloaddelete" object:nil];
    
//    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(downloadQueue:) name:@"downloadQueue" object:nil];

     [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(addDownload:) name:@"addDownload" object:nil];
    [self.tableView registerNib:[UINib nibWithNibName:@"DownloadCell" bundle:nil] forCellReuseIdentifier:@"downloadCell"];
    self.lock = [[NSLock alloc]init];
    [self initData];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark -  NSNotification

- (void)addDownload:(NSNotification *)notification {
    [self initData];
}

#pragma mark - Table view data source

- (void)dealloc{
    [[NSNotificationCenter defaultCenter]removeObserver:self];
}

- (void)initData {
    dispatch_async(dispatch_get_main_queue(), ^{
        NSArray *sevaArray = [downManager sevaDownloadArray];
        ProjiectDownLoadManager *manager = [ProjiectDownLoadManager defaultProjiectDownLoadManager];
        if ([[NSUserDefaults standardUserDefaults]boolForKey:@"sevaDownload"]) {
            [[NSUserDefaults standardUserDefaults]setBool:NO forKey:@"sevaDownload"];
            [[NSUserDefaults standardUserDefaults]synchronize];
            for (int i = 0 ;i < sevaArray.count; i++) {
                @autoreleasepool {
                    NSDictionary *dic = (NSDictionary *)sevaArray[i];
                    NSMutableDictionary *newObj = [dic mutableCopy];
                    WHC_Download *op = [[WHC_Download alloc]initStartDownloadWithURL:[NSURL URLWithString:newObj[@"post_mp"]] savePath:manager.userDownLoadPath savefileName:[newObj[@"post_mp"] stringByReplacingOccurrencesOfString:@"/" withString:@""] withObj:newObj delegate:nil];
                    if (op) {
                        UIAlertView *al = [[UIAlertView alloc]initWithTitle:nil message:@"是否恢复上次未完成的下载" delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"恢复", nil];
                        al.tag = 300;
                        [al show];
                        return;
                    }
                }
            }
            
        }
        
        self.downLoadArray = [downManager.downLoadQueue.operations mutableCopy];
//        self.downLoadSet = [NSMutableSet setWithArray:downManager.downLoadQueue.operations];
        [self.tableView reloadData];
    });
}

//- (void)downloadQueue:(NSNotification *)notification {
////    if (_) {
////        <#statements#>
////    }
//    [_downLoadArray addObject:notification.object];
//}

- (void)downloaddelete:(NSNotification *)notification {
    __weak __typeof(self) selfBlock = self;
    if (!_downLoadArray.count)return;
    @synchronized(self) {
        dispatch_async(dispatch_get_main_queue(), ^{
            @autoreleasepool {
                NSInteger idx = [_downLoadArray indexOfObject:notification.object[0]];
                if (idx <= _downLoadArray.count) {
                    [_downLoadArray removeObjectAtIndex:idx];
                    NSIndexPath *indexP = [NSIndexPath indexPathForRow:idx inSection:0];
                    [selfBlock.tableView deleteRowsAtIndexPaths:@[indexP] withRowAnimation:UITableViewRowAnimationLeft];
//                    NSMutableSet *set = [NSMutableSet setWithArray:_downLoadArray];
//                    [set addObjectsFromArray:[ProjiectDownLoadManager defaultProjiectDownLoadManager].downLoadQueue.operations];
//                    [_downLoadArray removeAllObjects];
//                    self.downLoadArray = [downManager.downLoadQueue.operations mutableCopy];
                    if (!_downLoadArray.count) {
                        self.downLoadArray = [downManager.downLoadQueue.operations mutableCopy];
                        [selfBlock.tableView reloadData];
                        return;
                    }
                }
                if (!_downLoadArray.count) {
                    [selfBlock.tableView reloadData];
                    return;
                }
            }
        });
        
    }
    
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    if (!_downLoadArray.count) {
        if (!_label) {
            _label = [[UILabel alloc]initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, 20)];
            _label.textAlignment = NSTextAlignmentCenter;
            _label.text = @"没有下载任务";
            _label.textColor = [UIColor lightGrayColor];
            _label.center = CGPointMake(SCREEN_WIDTH / 2, SCREEN_HEIGHT / 2 - 50);
            [self.tableView addSubview:_label];
        }else {
            [self.tableView addSubview:_label];
        }
        [self.tableView.tableFooterView removeFromSuperview];
    }else {
        [_label removeFromSuperview];
        //        self.tableView.tableFooterView = [UIView new];
    }
    
    return _downLoadArray.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return 0.0f;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
    //    if (_downLoadArray.count) {
    //        return 0;
    //    }
    return 0;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 104;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    DownloadCell  * cell = [tableView dequeueReusableCellWithIdentifier:@"downloadCell" forIndexPath:indexPath];
    if (_downLoadArray.count) {
        @autoreleasepool {
            WHC_Download *operation = _downLoadArray[indexPath.row];
            [cell displayCell:operation];
        }
    }
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    WHC_Download *operation =  _downLoadArray[indexPath.row];
    _selectIdx = indexPath.row;
    if (operation.isFinsh) {
        UIAlertView *als = [[UIAlertView alloc]initWithTitle:nil message:@"是否删除下载" delegate:self cancelButtonTitle:nil otherButtonTitles:@"删除下载",nil];
        als.tag = 100;
        [als show];
        return;
    }
    UIAlertView *al = [[UIAlertView alloc]initWithTitle:nil message:@"是否删除下载" delegate:self cancelButtonTitle:@"继续下载" otherButtonTitles:@"删除下载", nil];
    al.tag = 200;
    //    DownLoadOperation *operation =  _downLoadArray[_selectIdx];
    //    operation.requestOperation.isPaused ? nil : [operation.requestOperation pause];
    [al show];
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    if (alertView.tag == 100) {
        WHC_Download *operation =  _downLoadArray[_selectIdx];
        [operation cancelDownloadTaskAndDelFile:YES];
        [_downLoadArray removeObjectAtIndex:_selectIdx];
        [[ProjiectDownLoadManager defaultProjiectDownLoadManager]removeSaveObject:operation.obj];
        [[ProjiectDownLoadManager defaultProjiectDownLoadManager].downloadArray removeObject:operation];
        //        [downManager.downloadArray removeObjectAtIndex:_selectIdx];
        [self.tableView deleteRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:_selectIdx inSection:0]] withRowAnimation:UITableViewRowAnimationFade];
        [[NSNotificationCenter defaultCenter]postNotificationName:@"changeNumber" object:nil];
        
    }
    if (buttonIndex == 1 && alertView.tag == 200) {
        WHC_Download *operation =  _downLoadArray[_selectIdx];
        [operation cancelDownloadTaskAndDelFile:YES];
        [_downLoadArray removeObjectAtIndex:_selectIdx];
        [[ProjiectDownLoadManager defaultProjiectDownLoadManager]removeSaveObject:operation.obj];
        
        [[ProjiectDownLoadManager defaultProjiectDownLoadManager].downloadArray removeObject:operation];
        //        [downManager.downloadArray removeObjectAtIndex:_selectIdx];
        [self.tableView deleteRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:_selectIdx inSection:0]] withRowAnimation:UITableViewRowAnimationFade];
        [[NSNotificationCenter defaultCenter]postNotificationName:@"changeNumber" object:nil];
        
    }
    if (buttonIndex == 1 && alertView.tag == 300) {
        MBProgressHUD *_HUD = [MBProgressHUD showHUDAddedTo:self.view.superview animated:YES];
        _HUD.mode = MBProgressHUDModeIndeterminate;
        _HUD.labelText = @"恢复中...";
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_LOW, 0), ^{
            NSArray *sevaArray = [downManager sevaDownloadArray];
            ProjiectDownLoadManager *manager = [ProjiectDownLoadManager defaultProjiectDownLoadManager];
            [sevaArray enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
                @autoreleasepool {
                    NSDictionary *dic = (NSDictionary *)obj;
                    NSMutableDictionary *newObj = [dic mutableCopy];
                    WHC_Download *op = [[WHC_Download alloc]initStartDownloadWithURL:[NSURL URLWithString:newObj[@"post_mp"]] savePath:manager.userDownLoadPath savefileName:[newObj[@"post_mp"] stringByReplacingOccurrencesOfString:@"/" withString:@""] withObj:newObj delegate:nil];
                    if (op) {
                        [manager.downLoadQueue addOperation:op];
                    }
                }
            }];
            dispatch_async(dispatch_get_main_queue(), ^{
                self.downLoadArray = [downManager.downLoadQueue.operations mutableCopy];
                [[NSNotificationCenter defaultCenter]postNotificationName:@"changeNumber" object:nil];
                [self.tableView reloadData];
                [_HUD setHidden:YES];
            });
            
        });
        
    }else if (alertView.tag == 300 && buttonIndex == 0) {
        NSString *str1 = [downManager.userDownLoadSevaPlsit stringByAppendingPathComponent:@"downloadSevaArray"];
        [[NSFileManager defaultManager] removeItemAtPath:str1 error:nil];
        self.downLoadArray = [downManager.downLoadQueue.operations mutableCopy];
        [[NSNotificationCenter defaultCenter]postNotificationName:@"changeNumber" object:nil];
        [self.tableView reloadData];
    }
}


/*
 - (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
 UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:<#@"reuseIdentifier"#> forIndexPath:indexPath];
 
 // Configure the cell...
 
 return cell;
 }
 */

/*
 // Override to support conditional editing of the table view.
 - (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
 // Return NO if you do not want the specified item to be editable.
 return YES;
 }
 */

/*
 // Override to support editing the table view.
 - (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
 if (editingStyle == UITableViewCellEditingStyleDelete) {
 // Delete the row from the data source
 [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
 } else if (editingStyle == UITableViewCellEditingStyleInsert) {
 // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
 }
 }
 */

/*
 // Override to support rearranging the table view.
 - (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath {
 }
 */

/*
 // Override to support conditional rearranging of the table view.
 - (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath {
 // Return NO if you do not want the item to be re-orderable.
 return YES;
 }
 */

/*
 #pragma mark - Navigation
 
 // In a storyboard-based application, you will often want to do a little preparation before navigation
 - (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
 // Get the new view controller using [segue destinationViewController].
 // Pass the selected object to the new view controller.
 }
 */

@end
