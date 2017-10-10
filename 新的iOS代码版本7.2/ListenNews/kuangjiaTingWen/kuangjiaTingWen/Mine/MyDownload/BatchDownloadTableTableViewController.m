//
//  BatchDownloadTableTableViewController.m
//  kuangjiaTingWen
//
//  Created by 泡果 on 16/7/21.
//  Copyright © 2016年 贺楠. All rights reserved.
//

#import "BatchDownloadTableTableViewController.h"
#import "DownloadTableViewCell.h"
#import "AppDelegate.h"
#import "bofangVC.h"
#import "ProjiectDownLoadManager.h"
#import "WHC_Download.h"
#import "MJRefresh.h"

@interface BatchDownloadTableTableViewController ()

@property (strong, nonatomic) UIButton *allSelecteButton;
@property (strong, nonatomic) UILabel *allSelectedLabel;
@property (strong, nonatomic) UIButton *doneButton;

@property (assign, nonatomic) BOOL isAllSelected;

@property (strong, nonatomic) NSMutableArray *selectedNewsArr;

@property (assign, nonatomic) NSUInteger page;

@end

@implementation BatchDownloadTableTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self setupData];
    [self setupView];
    
}

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    [self.navigationController setNavigationBarHidden:NO animated:animated];
    [self.navigationController.navigationBar setTranslucent:NO];
}

- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
    [self.navigationController.navigationBar setTranslucent:YES];
}

- (void)setupData {
    self.page = 1;
    [self loadData];
    self.title = @"批量下载";
    for (int i = 0 ; i < [self.newsListArr  count]; i ++) {
        NSMutableDictionary *dic = self.newsListArr[i];
        [dic setObject:@"NO" forKey:@"isSelected"];
    }
    [self.tableView setEditing:YES animated:YES];
    [self.tableView setAllowsMultipleSelection:YES];
    
    self.isAllSelected = NO;
}

- (void)setupView {
    [self enableAutoBack];
    
    self.tableView.mj_header.automaticallyChangeAlpha = YES;
    UISwipeGestureRecognizer *rightSwipe = [[UISwipeGestureRecognizer alloc]initWithTarget:self action:@selector(rightSwipeAction)];
    [rightSwipe setDirection:UISwipeGestureRecognizerDirectionRight];
    [self.tableView addGestureRecognizer:rightSwipe];
    
    UIButton *backImage = [UIButton buttonWithType:UIButtonTypeCustom];
    [backImage setFrame:CGRectMake(0, 0, 44, 30)];
    backImage.contentEdgeInsets = UIEdgeInsetsMake(0, 0, 0, 20);
    [backImage setImage:[UIImage imageNamed:@"back"] forState:UIControlStateNormal];
    [backImage addTarget:self action:@selector(back) forControlEvents:UIControlEventTouchUpInside];
    
    UIBarButtonItem *backItem = [[UIBarButtonItem alloc] initWithCustomView:backImage];
    self.navigationItem.leftBarButtonItem = backItem;

    
    if ([self.downloadSource isEqualToString:@"1"]){
        DefineWeakSelf;
        self.tableView.mj_header = [MJRefreshNormalHeader headerWithRefreshingBlock:^{
            weakSelf.page = 1;
            [weakSelf loadData];
        }];
        self.tableView.mj_footer = [MJRefreshAutoNormalFooter footerWithRefreshingBlock:^{
            weakSelf.page ++;
            [weakSelf loadData];
        }];
    }
}
- (void)back{
    [self.navigationController popViewControllerAnimated:YES];
}
- (UIButton *)allSelecteButton{
    if (!_allSelecteButton) {
        _allSelecteButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [_allSelecteButton setFrame:CGRectMake(15, 50, 20, 20)];
        [_allSelecteButton setBackgroundImage:[UIImage imageNamed:@"unselect"] forState:UIControlStateNormal];
        [_allSelecteButton setBackgroundImage:[UIImage imageNamed:@"selected"] forState:UIControlStateSelected];
        [_allSelecteButton addTarget:self action:@selector(allSelecteButtonAction:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _allSelecteButton;
}

- (UIButton *)doneButton{
    if (!_doneButton) {
        _doneButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [_doneButton setFrame:CGRectMake(SCREEN_WIDTH - 65, 40, 50, 40)];
        [_doneButton setTitle:@"下载" forState:UIControlStateNormal];
        [_doneButton setTitleColor:gMainColor forState:UIControlStateNormal];
        [_doneButton addTarget:self action:@selector(doneButtonAction:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _doneButton;
}

- (NSMutableArray *)newsListArr{
    if (!_newsListArr) {
        _newsListArr = [NSMutableArray array];
    }
    return _newsListArr;
}

- (NSMutableArray *)selectedNewsArr {
    if (!_selectedNewsArr) {
        _selectedNewsArr = [NSMutableArray array];
    }
    return _selectedNewsArr;
}

#pragma mark - Utilities 

- (void)loadData{
    DefineWeakSelf;
    if ([self.downloadSource isEqualToString:@"1"]) {
        NSInteger limit = 10;
        [NetWorkTool postPaoGuoZhuBoOrJieMuMessageWithID:self.programID andpage:[NSString stringWithFormat:@"%lu",(unsigned long)self.page] andlimit:@"10" sccess:^(NSDictionary *responseObject) {
            if ([responseObject[@"results"] isKindOfClass:[NSArray class]]){
                
                if (self.page == 1) {
                    [weakSelf.newsListArr removeAllObjects];
                }
                NSMutableArray *resultsArr = responseObject[@"results"];
                [weakSelf.newsListArr addObjectsFromArray:resultsArr];
                
                if ( [responseObject[@"results"] count]< limit) {
                    [weakSelf.tableView.mj_footer endRefreshingWithNoMoreData];
                }
                else{
                    [weakSelf.tableView.mj_footer resetNoMoreData];
                }
            }
            [weakSelf.tableView reloadData];
            [weakSelf.tableView.mj_header endRefreshing];
            [weakSelf.tableView.mj_footer endRefreshing];

        } failure:^(NSError *error) {
            [weakSelf.tableView.mj_header endRefreshing];
            [weakSelf.tableView.mj_footer endRefreshing];
        }];
    }
}

- (void)allSelecteButtonAction:(UIButton *)sender {
    
    if (self.isAllSelected) {
        self.isAllSelected = NO;
        [self.allSelectedLabel setText:@"全选"];
        [self.allSelecteButton setBackgroundImage:[UIImage imageNamed:@"unselect"] forState:UIControlStateNormal];
        for (int i = 0 ; i < [self.newsListArr count]; i ++) {
            NSIndexPath *indexPath = [NSIndexPath indexPathForRow:i  inSection:0];
            [self.tableView deselectRowAtIndexPath:indexPath animated:YES];
            [self.newsListArr[indexPath.row] setObject:@"NO" forKey:@"isSelected"];
        }
    }
    else{
        self.isAllSelected = YES;
        [self.allSelectedLabel setText:@"取消"];
        [self.allSelecteButton setBackgroundImage:[UIImage imageNamed:@"selected"] forState:UIControlStateNormal];
        for (int i = 0 ; i < [self.newsListArr count]; i ++) {
            NSIndexPath *indexPath = [NSIndexPath indexPathForRow:i  inSection:0];
            [self.tableView selectRowAtIndexPath:indexPath animated:YES scrollPosition:UITableViewScrollPositionNone];
            [self.newsListArr[indexPath.row] setObject:@"YES" forKey:@"isSelected"];
        }
    }
}

- (void)doneButtonAction:(UIButton *)sender {

    [self.selectedNewsArr removeAllObjects];
    for (int i = 0 ; i < [self.newsListArr count]; i ++) {
        if ([[self.newsListArr[i] objectForKey:@"isSelected"] isEqualToString:@"YES"]) {
            [self.selectedNewsArr addObject:self.newsListArr[i]];
        }
    }
    if ([self.selectedNewsArr count]) {
        [SVProgressHUD showWithStatus:@"正在下载"];
        [self performSelector:@selector(SVPDismiss) withObject:nil afterDelay:1.0];
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_LOW, 0), ^{
            ProjiectDownLoadManager *manager = [ProjiectDownLoadManager defaultProjiectDownLoadManager];
            [self.selectedNewsArr enumerateObjectsUsingBlock:^(id object, NSUInteger idx, BOOL *stop)
             {
                 NSMutableDictionary *downObj = self.selectedNewsArr[idx];
                 WHC_Download *op = [[WHC_Download alloc]initStartDownloadWithURL:[NSURL URLWithString:downObj[@"post_mp"]] savePath:manager.userDownLoadPath savefileName:[downObj[@"post_mp"] stringByReplacingOccurrencesOfString:@"/" withString:@""] withObj:downObj withCell:nil isSingleDownload:NO delegate:nil];
                 if (op) {
                     dispatch_async(dispatch_get_main_queue(), ^{
                         [manager.downLoadQueue addOperation:op];
                     });
                 }
             }];
            
        });
        
    }
    else{
        [SVProgressHUD showErrorWithStatus:@"请选择要下载的新闻"];
        [self performSelector:@selector(SVPDismiss) withObject:nil afterDelay:1.0];
    }
    
}

- (void)SVPDismiss {
    [SVProgressHUD dismiss];
}

- (void)rightSwipeAction {
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - UITableViewDelegate

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {

    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
    return [self.newsListArr count];
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    
    return  80.0;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    return  99.0 / 667 * SCREEN_HEIGHT;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *identify = @"Cell";
    DownloadTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:identify];
    if (cell == nil) {
        cell = [[DownloadTableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identify];
    }
//    cell.selectedBackgroundView = [[UIView alloc] initWithFrame:cell.frame] ;
//    cell.selectedBackgroundView.backgroundColor = [UIColor whiteColor];
    [cell updateCellValueWithDict:self.newsListArr[indexPath.row]];
    
    return cell;
}


- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    
    UIView *tableHeadView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, 80)];
    [tableHeadView setBackgroundColor:[UIColor whiteColor]];
    
    UIView *topBgView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, 40)];
    [topBgView setBackgroundColor:gSubColor];
    
    UILabel *headTitle = [[UILabel alloc]initWithFrame:CGRectMake(5, 0, SCREEN_WIDTH - 10, 40)];
    [headTitle setText:[NSString stringWithFormat:@"%@ 共%lu条",self.headTitleStr,(unsigned long)[self.newsListArr count]]];
    [headTitle setFont:[UIFont systemFontOfSize:16]];
    UIView *line = [[UIView alloc]initWithFrame:CGRectMake(0, 39, SCREEN_WIDTH, 1)];
    [line setBackgroundColor:gSubColor];
    [headTitle addSubview:line];
    [topBgView addSubview:headTitle];
    [tableHeadView addSubview:topBgView];
    
    [tableHeadView addSubview:self.allSelecteButton];
    [tableHeadView addSubview:self.doneButton];
    
     self.allSelectedLabel = [[UILabel alloc]initWithFrame:CGRectMake(55, 40, 50, 40)];
    [self.allSelectedLabel setText:@"全选"];
    [tableHeadView addSubview:self.allSelectedLabel];
    
    UIView *bottomLine = [[UIView alloc]initWithFrame:CGRectMake(0, 79, SCREEN_WIDTH, 1)];
    [bottomLine setBackgroundColor:gSubColor];
    [tableHeadView addSubview:bottomLine];
    
    return tableHeadView;
    
}

- (void)tableView:(UITableView *)tableView didDeselectRowAtIndexPath:(NSIndexPath *)indexPath {
    if (self.tableView.editing) {
        [self.newsListArr[indexPath.row] setObject:@"NO" forKey:@"isSelected"];
    }
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if (self.tableView.editing) {
        [self.newsListArr[indexPath.row] setObject:@"YES" forKey:@"isSelected"];
    }
    
}

//- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section {
//
//}

/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/

- (UITableViewCellEditingStyle)tableView:(UITableView*)tableView editingStyleForRowAtIndexPath:(NSIndexPath*)indexPath{
    return UITableViewCellEditingStyleDelete | UITableViewCellEditingStyleInsert;
}

// Override to support editing the table view.
//- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
//    if (editingStyle == UITableViewCellEditingStyleDelete) {
//        // Delete the row from the data source
//        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
//    } else if (editingStyle == UITableViewCellEditingStyleInsert) {
//        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
//    }   
//}


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
