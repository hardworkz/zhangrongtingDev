//
//  DownLoadLiftViewController.m
//  Heard the news
//
//  Created by Pop Web on 15/10/30.
//  Copyright © 2015年 泡果网络. All rights reserved.
//

#import "DownLoadLiftViewController.h"
#import "DownloadNewCell.h"

#import "DownloadCell.h"

#import "ProjiectDownLoadManager.h"

#import "NewObj.h"

#import "CommonCode.h"

#import "bofangVC.h"


static NSInteger selectIndex2 = -1;

@interface DownLoadLiftViewController ()
@property (nonatomic, strong) UILabel *label;
@property (nonatomic) BOOL isMeiyou;
@property (nonatomic, copy)NSString * selectId;
@property (nonatomic, strong) NSMutableArray *downloadArray;

@property (strong, nonatomic) UIButton *allPlayButton;
@property (strong, nonatomic) UILabel *allPlayLabel;
@property (strong, nonatomic) UIButton *manageButton;
@property (strong, nonatomic) UIView *manageToolBarView;
@property (strong, nonatomic) UIButton *allSelectButton;
@property (strong, nonatomic) UIButton *allDeletebutton;

@end

@implementation DownLoadLiftViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.tableView.tableFooterView = [UIView new];
    self.tableView.backgroundColor = gSubColor;
    self.tableView.contentInset = UIEdgeInsetsMake(0, 0, 70, 0);
    //    self.tableView.showsVerticalScrollIndicator = NO;
    self.tableView.showsHorizontalScrollIndicator = NO;
    self.downloadArray = [NSMutableArray array];
    //选择cell
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(selectCell1:) name:@"selectCellD" object:nil];
    [self.tableView registerNib:[UINib nibWithNibName:@"DownloadNewCell" bundle:nil] forCellReuseIdentifier:@"downloadNewCell"];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(addDownload:) name:@"addDownload" object:nil];
    [self initData];
    
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(removeAllDeleteButton:) name:@"removeAllDeleteButton" object:nil];
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(gaibianyanse:) name:@"gaibianyanse" object:nil];
}

- (void)setEditing:(BOOL)editing animated:(BOOL)animated {
    [super setEditing:editing animated:animated];
    [[NSNotificationCenter defaultCenter]postNotificationName:@"bianji" object:nil];
//    UIViewController *v;
    if ([self isKindOfClass:[UINavigationController class]]) {
//        UINavigationController * nav = (UINavigationController *)self;
//        v =  nav.topViewController;
    };
    ////    UIViewController *v = [self.view getVisalViewController];
    //    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
    //    button.layer.cornerRadius = 5;
    //    button.clipsToBounds= YES;
    //    button.titleLabel.font = [UIFont systemFontOfSize:15];
    //    [button setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    //    [button setTitle:@"删除全部" forState:UIControlStateNormal];
    //    button.backgroundColor = [UIColor redColor];
    //    button.frame = CGRectMake(10, SCREEN_WIDTH - 50, SCREEN_WIDTH - 20, 44);
    //    [button addTarget:self action:@selector(remove:) forControlEvents:UIControlEventTouchUpInside];
    //    if (editing) {
    ////        UIBarButtonItem *bar = self.navigationItem.rightBarButtonItem;
    ////        [bar setTitle:@"取消"];
    //        [self.view.window addSubview:button];
    //    }else {
    ////        UIBarButtonItem *bar = self.navigationItem.rightBarButtonItem;
    ////        [bar setTitle:@"编辑"];
    //        [self.view.window.subviews enumerateObjectsUsingBlock:^(__kindof UIView * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
    //            if ([obj isKindOfClass:[UIButton class]]) {
    //                [obj removeFromSuperview];
    //            }
    //        }];
    //    }
}

- (void)remove:(UIButton *)sender{
    [[ProjiectDownLoadManager defaultProjiectDownLoadManager] removeAll];
    [_downloadArray removeAllObjects];
    [self.tableView reloadData];
    
    UIButton *manageBtn = (UIButton *)[self.view viewWithTag:1000];
    [self manageButtonAction:manageBtn];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - getter

- (UIButton *)allPlayButton{
    if (!_allPlayButton) {
        _allPlayButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [_allPlayButton setFrame:CGRectMake(15, 10, 20, 20)];
        [_allPlayButton setBackgroundImage:[UIImage imageNamed:@"downloaded_play"] forState:UIControlStateNormal];
        [_allPlayButton setAccessibilityLabel:@"播放全部"];
        //        [_allPlayButton setBackgroundImage:[UIImage imageNamed:@"downloaded_play"] forState:UIControlStateSelected];
        [_allPlayButton addTarget:self action:@selector(allPlayButtonAction:) forControlEvents:UIControlEventTouchUpInside];
        
    }
    return _allPlayButton;
}

- (UIButton *)manageButton{
    if (!_manageButton) {
        _manageButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [_manageButton setFrame:CGRectMake(SCREEN_WIDTH - 65, 0, 50, 40)];
        [_manageButton setTag:1000];
        [_manageButton setTitle:@"管理" forState:UIControlStateNormal];
        [_manageButton setTitle:@"取消" forState:UIControlStateSelected];
        [_manageButton setTitleColor:gMainColor forState:UIControlStateNormal];
        [_manageButton addTarget:self action:@selector(manageButtonAction:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _manageButton;
}

//- (UIView *)manageToolBarView {
//    if (!_manageToolBarView) {
//        _manageToolBarView = [[UIView alloc]initWithFrame:CGRectMake(0, SCREEN_HEIGHT - 64- 50 - 40, SCREEN_WIDTH, 40)];
//        [_manageToolBarView setBackgroundColor:[UIColor whiteColor]];
//        self.allSelectButton = [UIButton buttonWithType:UIButtonTypeCustom];
//        [self.allSelectButton setFrame:CGRectMake(0, 0, SCREEN_WIDTH / 2, 40)];
//        [self.allSelectButton setTitle:@"全选" forState:UIControlStateNormal];
//        [self.allSelectButton setTitleColor:gTextColorSub forState:UIControlStateNormal];
//        [self.allSelectButton addTarget:self action:@selector(allselectDownloadNews:) forControlEvents:UIControlEventTouchUpInside];
//        [_manageToolBarView addSubview:self.allSelectButton];
//        UIButton *deleteButton = [UIButton buttonWithType:UIButtonTypeCustom];
//        [deleteButton setFrame:CGRectMake(SCREEN_WIDTH / 2, 0, SCREEN_WIDTH / 2, 40)];
//        [deleteButton setTitle:@"删除" forState:UIControlStateNormal];
//        [deleteButton setTitleColor:gTextColorSub forState:UIControlStateNormal];
//        [deleteButton addTarget:self action:@selector(deleteDownloadNews:) forControlEvents:UIControlEventTouchUpInside];
//        [_manageToolBarView addSubview:deleteButton];
//        UIView *line = [[UIView alloc]initWithFrame:CGRectMake(SCREEN_WIDTH / 2, 0, 1, 40)];
//        [line setBackgroundColor:gThinLineColor];
//        [_manageToolBarView addSubview:line];
//    }
//    return _manageToolBarView;
//}

- (UIButton *)allDeletebutton {
    if (!_allDeletebutton) {
        _allDeletebutton = [UIButton buttonWithType:UIButtonTypeCustom];
        _allDeletebutton.layer.cornerRadius = 5;
        _allDeletebutton.clipsToBounds= YES;
        _allDeletebutton.titleLabel.font = [UIFont systemFontOfSize:15];
        [_allDeletebutton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [_allDeletebutton setTitle:@"删除全部" forState:UIControlStateNormal];
        _allDeletebutton.backgroundColor = [UIColor redColor];
        _allDeletebutton.frame = CGRectMake(10, SCREEN_HEIGHT - 50, SCREEN_WIDTH - 20, 44);
        [_allDeletebutton addTarget:self action:@selector(remove:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _allDeletebutton;
}

#pragma mark - Utilities

- (void)allPlayButtonAction:(UIButton *)sender {
    [CommonCode writeToUserD:@"NO" andKey:TINGYOUQUANBOFANGWANBI];
    NSArray *arr = _downloadArray;
    if ([arr count]) {
        NewObj *obj = [_downloadArray firstObject];
        if ([[CommonCode readFromUserD:@"dangqianbofangxinwenID"] isEqualToString:obj.i_id]){
            if ([bofangVC shareInstance].isPlay) {
                
            }
            else{
                if ([bofangVC shareInstance].isFirst) {
                    //
                }
                else{
                   [[bofangVC shareInstance] doplay2];
                }
            }
            self.hidesBottomBarWhenPushed = YES;
            [self.navigationController.navigationBar setHidden:YES];
            [self.navigationController pushViewController:[bofangVC shareInstance ] animated:YES];
            self.hidesBottomBarWhenPushed = NO;
        }
        else{
            [bofangVC shareInstance].newsModel.jiemuID = obj.i_id;
            [bofangVC shareInstance].newsModel.Titlejiemu = obj.post_title;
            [bofangVC shareInstance].newsModel.RiQijiemu = obj.post_date;
            [bofangVC shareInstance].newsModel.ImgStrjiemu = obj.smeta;
            [bofangVC shareInstance].newsModel.post_lai = obj.post_lai;
            [bofangVC shareInstance].newsModel.post_news = obj.post_act[@"id"];
            [bofangVC shareInstance].newsModel.jiemuName = obj.post_act[@"name"];
            [bofangVC shareInstance].newsModel.jiemuDescription = obj.post_act[@"description"];
            [bofangVC shareInstance].newsModel.jiemuImages = obj.post_act[@"images"];
            [bofangVC shareInstance].newsModel.jiemuFan_num = obj.post_act[@"fan_num"];
            [bofangVC shareInstance].newsModel.jiemuMessage_num = obj.post_act[@"message_num"];
            [bofangVC shareInstance].newsModel.jiemuIs_fan = obj.post_act[@"is_fan"];
            [bofangVC shareInstance].newsModel.post_mp = obj.post_mp;
            [bofangVC shareInstance].newsModel.post_time = obj.post_time;
            [bofangVC shareInstance].newsModel.post_keywords = obj.post_keywords;
            [bofangVC shareInstance].newsModel.url = obj.url;
            [bofangVC shareInstance].iszhuboxiangqing = NO;
            [bofangVC shareInstance].yinpinzongTime.text = [[bofangVC shareInstance] convertStringWithTime:[obj.post_time intValue] / 1000];
            
            ExcurrentNumber = 0;
            
            [bofangVC shareInstance].newsModel.ImgStrjiemu = obj.smeta;
            [bofangVC shareInstance].newsModel.ZhengWenjiemu = obj.post_excerpt;
            [bofangVC shareInstance].newsModel.praisenum = obj.praisenum;
            [bofangVC shareInstance].newsModel.post_keywords = obj.post_keywords;
            [bofangVC shareInstance].newsModel.url = obj.url;
            [[bofangVC shareInstance].tableView reloadData];
            [Explayer replaceCurrentItemWithPlayerItem:[[AVPlayerItem alloc]initWithURL:[NSURL fileURLWithPath:obj.post_mp]]];
            ExisRigester = YES;
            ExIsKaiShiBoFang = YES;
            ExwhichBoFangYeMianStr = @"Downloadbofang";
            self.hidesBottomBarWhenPushed = YES;
            [self.navigationController.navigationBar setHidden:YES];
            [self.navigationController pushViewController:[bofangVC shareInstance ] animated:YES];
            self.hidesBottomBarWhenPushed = NO;
            
            if ([bofangVC shareInstance].isPlay || ExIsKaiShiBoFang == NO) {
                
            }
            else{
                if ([bofangVC shareInstance].isFirst) {
                    //
                }
                else{
                    [[bofangVC shareInstance] doplay2];
                }
            }
            
            [[NSNotificationCenter defaultCenter] postNotificationName:@"yuanpanzhuan" object:nil];
            [[NSNotificationCenter defaultCenter] postNotificationName:@"qiehuanxinwen" object:nil];
            [CommonCode writeToUserD:obj.i_id andKey:@"dangqianbofangxinwenID"];
            //TODO:把obj 转成字典放入数组
            NSMutableArray *downloadArr = [NSMutableArray array];
            for (int i = 0; i < [_downloadArray count]; i ++) {
                NSMutableDictionary *dic = [[_downloadArray[i] getAllPropertiesAndVaules] mutableCopy];
                [dic setObject:dic[@"i_id"] forKey:@"id"];
                [downloadArr addObject:dic];
            }
            [CommonCode writeToUserD:downloadArr andKey:@"zhuyeliebiao"];
            if ([[CommonCode readFromUserD:@"yitingguoxinwenID"] isKindOfClass:[NSArray class]])
            {
                NSMutableArray *yitingguoArr = [NSMutableArray arrayWithArray:[CommonCode readFromUserD:@"yitingguoxinwenID"]];
                [yitingguoArr addObject:obj.i_id];
                [CommonCode writeToUserD:yitingguoArr andKey:@"yitingguoxinwenID"];
            }else
            {
                NSMutableArray *yitingguoArr = [NSMutableArray array];
                [yitingguoArr addObject:obj.i_id];
                [CommonCode writeToUserD:yitingguoArr andKey:@"yitingguoxinwenID"];
            }
            [[NSNotificationCenter defaultCenter] postNotificationName:@"dianjihougaibiangezhongyanse" object:nil];
        }
    }
    else{
        [SVProgressHUD showErrorWithStatus:@"没有可以播放的新闻"];
        [self performSelector:@selector(SVPDismiss) withObject:nil afterDelay:1.0];
    }
    [self.tableView reloadData];
}

- (void)SVPDismiss {
    [SVProgressHUD dismiss];
}

- (void)manageButtonAction:(UIButton *)sender {
    //TODO:考虑左右滑动时,删除全部按钮的位置

    
    if (self.manageButton.selected) {
        [self.manageButton setSelected:NO];
        [self.tableView setEditing:NO];
        [self.allDeletebutton removeFromSuperview];
//        [self.view.window.subviews enumerateObjectsUsingBlock:^(__kindof UIView * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
//            if ([obj isKindOfClass:[UIButton class]]) {
//                [obj removeFromSuperview];
//            }
//        }];
    }
    else{
        [self.manageButton setSelected:YES];
        [self.tableView setEditing:YES];
        [self.view.window addSubview:self.allDeletebutton];
    }
}

- (void)removeAllDeleteButton:(NSNotification *)notification{
    [self.manageButton setSelected:NO];
    [self.tableView setEditing:NO];
    [self.allDeletebutton removeFromSuperview];
}

- (void)gaibianyanse:(NSNotification *)notification {
    [self.tableView reloadData];
}

#pragma mark - UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    
    return 1;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    
    return 40.0;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    
    UIView *tableHeadView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, 40)];
    [tableHeadView setBackgroundColor:[UIColor whiteColor]];
    
    UIView *line = [[UIView alloc]initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, 1)];
    [line setBackgroundColor:gSubColor];
    [tableHeadView addSubview:line];
    [tableHeadView addSubview:self.allPlayButton];
    [tableHeadView addSubview:self.manageButton];
    
    self.allPlayLabel = [[UILabel alloc]initWithFrame:CGRectMake(55, 0, 80, 40)];
    [self.allPlayLabel setText:@"播放全部"];
    [tableHeadView addSubview:self.allPlayLabel];
    
    UIView *bottomLine = [[UIView alloc]initWithFrame:CGRectMake(0, 39, SCREEN_WIDTH, 1)];
    [bottomLine setBackgroundColor:gSubColor];
    [tableHeadView addSubview:bottomLine];
    
    return tableHeadView;
}

#pragma mark - UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (!_downloadArray.count) {
        if (!_label) {
            _label = [[UILabel alloc]initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, 20)];
            _label.textAlignment = NSTextAlignmentCenter;
            _label.text = @"没有下载信息";
            _label.textColor = [UIColor lightGrayColor];
            _label.center = self.tableView.center;
            _isMeiyou = YES;
            [self.tableView addSubview:_label];
        }else {
            [self.tableView addSubview:_label];
        }
    }else {
        [_label removeFromSuperview];
        _isMeiyou = NO;
    }
    
    return _downloadArray.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
    //    if (_downloadArray.count) {
    //        return 0;
    //    }
    return 0;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 100;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    DownloadNewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"downloadNewCell" forIndexPath:indexPath];
    
    return cell;
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath {
    DownloadNewCell *cell1 = (DownloadNewCell *)cell;
    if (indexPath.row == selectIndex2) {
        [self.tableView selectRowAtIndexPath:indexPath animated:YES scrollPosition:UITableViewScrollPositionNone];
    }
    if (_downloadArray.count) {
        
        NewObj *obj = _downloadArray[indexPath.row];
        NSLog(@"post_act%@",obj.post_act);
        
        //        Post_actor *actor = [Post_actor new];
        //        actor = obj.post_act;
        //        NSLog(@"actor.images=%@",actor.images);
        
        [cell1 setNewData:_downloadArray[indexPath.row]];
    }
}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    [[NSNotificationCenter defaultCenter] postNotificationName:@"selectCellD" object:[_downloadArray[indexPath.row] i_id]];
     NewObj *obj = _downloadArray[indexPath.row];
    [CommonCode writeToUserD:@"NO" andKey:TINGYOUQUANBOFANGWANBI];
    if ([[CommonCode readFromUserD:@"dangqianbofangxinwenID"] isEqualToString:obj.i_id]){
        self.hidesBottomBarWhenPushed = YES;
        [self.navigationController.navigationBar setHidden:YES];
        [self.navigationController pushViewController:[bofangVC shareInstance ] animated:YES];
        self.hidesBottomBarWhenPushed = NO;
    }
    else{
        [bofangVC shareInstance].newsModel.jiemuID = obj.i_id;
        [bofangVC shareInstance].newsModel.Titlejiemu = obj.post_title;
        [bofangVC shareInstance].newsModel.RiQijiemu = obj.post_date;
        [bofangVC shareInstance].newsModel.ImgStrjiemu = obj.smeta;
        [bofangVC shareInstance].newsModel.post_lai = obj.post_lai;
        [bofangVC shareInstance].newsModel.post_news = obj.post_news;
        [bofangVC shareInstance].newsModel.jiemuName = obj.post_act[@"name"];
        [bofangVC shareInstance].newsModel.jiemuDescription = obj.post_act[@"description"];
        [bofangVC shareInstance].newsModel.jiemuImages = obj.post_act[@"images"];
        [bofangVC shareInstance].newsModel.jiemuFan_num = obj.post_act[@"fan_num"];
        [bofangVC shareInstance].newsModel.jiemuMessage_num = obj.post_act[@"message_num"];
        [bofangVC shareInstance].newsModel.jiemuIs_fan = obj.post_act[@"is_fan"];
        [bofangVC shareInstance].newsModel.post_mp = obj.post_mp;
        [bofangVC shareInstance].newsModel.post_time = obj.post_time;
        [bofangVC shareInstance].newsModel.post_keywords = obj.post_keywords;
        [bofangVC shareInstance].newsModel.url = obj.url;
        [bofangVC shareInstance].iszhuboxiangqing = NO;
        [bofangVC shareInstance].yinpinzongTime.text = [[bofangVC shareInstance] convertStringWithTime:[obj.post_time intValue] / 1000];
        
        ExcurrentNumber = (int)indexPath.row;
        
        [bofangVC shareInstance].newsModel.ImgStrjiemu = obj.smeta;
        [bofangVC shareInstance].newsModel.ZhengWenjiemu = obj.post_excerpt;
        [bofangVC shareInstance].newsModel.praisenum = obj.praisenum;
        [bofangVC shareInstance].newsModel.post_keywords = obj.post_keywords;
        [bofangVC shareInstance].newsModel.url = obj.url;
        [[bofangVC shareInstance].tableView reloadData];
        [Explayer replaceCurrentItemWithPlayerItem:[[AVPlayerItem alloc]initWithURL:[NSURL fileURLWithPath:obj.post_mp]]];
        if ([bofangVC shareInstance].isPlay || ExIsKaiShiBoFang == NO) {
            
        }
        else{
            [[bofangVC shareInstance] doplay2];
        }
        ExisRigester = YES;
        ExIsKaiShiBoFang = YES;
        ExwhichBoFangYeMianStr = @"Downloadbofang";
        self.hidesBottomBarWhenPushed = YES;
        [self.navigationController.navigationBar setHidden:YES];
        [self.navigationController pushViewController:[bofangVC shareInstance ] animated:YES];
        self.hidesBottomBarWhenPushed = NO;
        
        [[NSNotificationCenter defaultCenter] postNotificationName:@"yuanpanzhuan" object:nil];
        [[NSNotificationCenter defaultCenter] postNotificationName:@"qiehuanxinwen" object:nil];
        [CommonCode writeToUserD:obj.i_id andKey:@"dangqianbofangxinwenID"];
        //TODO:把obj 转成字典放入数组
        NSMutableArray *downloadArr = [NSMutableArray array];
        for (int i = 0; i < [_downloadArray count]; i ++) {
            NSMutableDictionary *dic = [[_downloadArray[i] getAllPropertiesAndVaules] mutableCopy];
            [dic setObject:dic[@"i_id"] forKey:@"id"];
            [downloadArr addObject:dic];
        }
        [CommonCode writeToUserD:downloadArr andKey:@"zhuyeliebiao"];
        if ([[CommonCode readFromUserD:@"yitingguoxinwenID"] isKindOfClass:[NSArray class]])
        {
            NSMutableArray *yitingguoArr = [NSMutableArray arrayWithArray:[CommonCode readFromUserD:@"yitingguoxinwenID"]];
            [yitingguoArr addObject:obj.i_id];
            [CommonCode writeToUserD:yitingguoArr andKey:@"yitingguoxinwenID"];
        }else
        {
            NSMutableArray *yitingguoArr = [NSMutableArray array];
            [yitingguoArr addObject:obj.i_id];
            [CommonCode writeToUserD:yitingguoArr andKey:@"yitingguoxinwenID"];
        }
        [[bofangVC shareInstance].tableView reloadData];
        [tableView reloadData];
        [[NSNotificationCenter defaultCenter] postNotificationName:@"dianjihougaibiangezhongyanse" object:nil];
    }
}


- (void)dealloc{
    [[NSNotificationCenter defaultCenter]removeObserver:self];
}

- (void)initData {
    ProjiectDownLoadManager *manager = [ProjiectDownLoadManager defaultProjiectDownLoadManager];
    NSArray *arr = [manager downloadAllNewObjArrar];
    __weak __typeof(self) selfBlock = self;
    [arr enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        @autoreleasepool {
            NewObj *nObj = [NewObj newObjWithDictionary:obj];
            [selfBlock.downloadArray addObject:nObj];
        }
    }];
    [self.tableView reloadData];
}

- (void)addDownload:(NSNotification *)notification {
    //    NSArray *arr = [manager downloadAllNewObjArrar];
    
    __weak __typeof(self) selfBlock = self;
    NSInteger conut = _downloadArray.count;
    dispatch_async(dispatch_get_main_queue(), ^{
        NewObj *nObj = [NewObj newObjWithDictionary:notification.object];
        [_downloadArray insertObject:nObj atIndex:0];
        //        selectIndex2++;
        if (_isMeiyou) {
            [selfBlock.tableView reloadData];
            return ;
        }
        if (_downloadArray.count > conut) {
            @synchronized(self) {
                NSIndexPath *indexP = [NSIndexPath indexPathForRow:0 inSection:0];
                //                NSIndexPath *indexP1 = [NSIndexPath indexPathForRow:selectIndex2 inSection:0];
                [selfBlock.tableView insertRowsAtIndexPaths:@[indexP] withRowAnimation:UITableViewRowAnimationRight];
                //                NSPredicate *p = [NSPredicate predicateWithFormat:@"i_id == %@", [NewContentViewController defaultNewContentController].obj.i_id];
                //                if ([[_downloadArray filteredArrayUsingPredicate:p]count]) {
                //                    NewObj* obj = [_downloadArray filteredArrayUsingPredicate:p][0];
                //                    selectIndex2 = [_downloadArray indexOfObject:obj];
                //                }else {
                //                    selectIndex2 = -1;
                //                }
                [selfBlock.tableView selectRowAtIndexPath:[NSIndexPath indexPathForRow:selectIndex2 inSection:0] animated:YES scrollPosition:UITableViewScrollPositionNone];
                //                [self.tableView selectRowAtIndexPath:indexP1 animated:YES scrollPosition:UITableViewScrollPositionNone];
                
            }
        }
    });
    
}

#pragma  mark - 选择cell通知
- (void)selectCell1:(NSNotification *)notification {
    _selectId = notification.object;
    dispatch_async(dispatch_get_main_queue(), ^{
        NSPredicate *p = [NSPredicate predicateWithFormat:@"i_id == %@", notification.object];
        if ([[_downloadArray filteredArrayUsingPredicate:p]count]) {
            NewObj* obj = [_downloadArray filteredArrayUsingPredicate:p][0];
            selectIndex2 = [_downloadArray indexOfObject:obj];
        }else {
            selectIndex2 = -1;
        }
        //        [self.tableView selectRowAtIndexPath:[NSIndexPath indexPathForRow:selectIndex2 inSection:0] animated:YES scrollPosition:UITableViewScrollPositionNone];
        if (selectIndex2 >= 0) {
            //            [self.tableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:selectIndex2 inSection:0]
            //                                  atScrollPosition:UITableViewScrollPositionMiddle animated:YES] ;
        }
    });
}

// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the specified item to be editable.
    return YES;
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    //   selectIndex2 = [[[NSUserDefaults standardUserDefaults]objectForKey:@"selectC2"] integerValue];
    //    [self.tableView selectRowAtIndexPath:[NSIndexPath indexPathForRow:selectIndex2 inSection:0] animated:YES scrollPosition:UITableViewScrollPositionNone];
    
    //    NSPredicate *p = [NSPredicate predicateWithFormat:@"i_id == %@", [NewContentViewController defaultNewContentController].obj.i_id];
    //    if ([[_downloadArray filteredArrayUsingPredicate:p]count]) {
    //        NewObj* obj = [_downloadArray filteredArrayUsingPredicate:p][0];
    //        selectIndex2 = [_downloadArray indexOfObject:obj];
    //    }else {
    //        selectIndex2 = -1;
    //    }
    //    [self.tableView selectRowAtIndexPath:[NSIndexPath indexPathForRow:selectIndex2 inSection:0] animated:YES scrollPosition:UITableViewScrollPositionNone];
    //    if (selectIndex2 >= 0) {
    //        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
    ////            [self.tableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:selectIndex2 inSection:0] atScrollPosition:UITableViewScrollPositionMiddle animated:YES] ;
    //        });
    //    }
    
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        
        DownloadNewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
        [_downloadArray removeObject:cell.obj];
        ProjiectDownLoadManager *manager = [ProjiectDownLoadManager defaultProjiectDownLoadManager];
        [manager removeDownloadPlist:@[cell.obj]];
        [manager removeDownloadImageArray:@[cell.obj.smeta]];
        [manager removeDownloadMP3Array:@[cell.obj.post_mp]];
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
        [self.tableView reloadData];
    } else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }
}

- (NSString *)tableView:(UITableView *)tableView titleForDeleteConfirmationButtonForRowAtIndexPath:(NSIndexPath *)indexPath{
    return @"删除";
}

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
