//
//  zhuboXiangQingTabelView.m
//  reHeardTheNews
//
//  Created by 贺楠 on 16/5/27.
//  Copyright © 2016年 paoguo. All rights reserved.
//

#import "zhuboXiangQingTabelView.h"
#import "MJRefresh.h"
@interface zhuboXiangQingTabelView ()
{
    NSArray *xinwenArr;
}
@end

@implementation zhuboXiangQingTabelView

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
    [self.tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:@"cell"];
    self.tableView.tableFooterView = [[UIView alloc]init];
    __typeof (self) __weak weakSelf = self;
    
    [NetWorkTool postPaoGuoZhuBoOrJieMuMessageWithID:self.jiemuID andpage:@"1" andlimit:@"10" sccess:^(NSDictionary *responseObject) {
        if ([responseObject[@"results"] isKindOfClass:[NSArray class]])
        {
            xinwenArr = [[NSArray alloc]initWithArray:responseObject[@"results"]];
            [self.tableView reloadData];
        }
    } failure:^(NSError *error) {
        NSLog(@"error = %@",error);
    }];
    
    if (_isNeedRefresh) {
        self.tableView.mj_header = [MJRefreshNormalHeader headerWithRefreshingBlock:^{
            // 进入刷新状态后会自动调用这个block
            [weakSelf delayInSeconds:1.0 block:^{
                [weakSelf.tableView.mj_header endRefreshing];
            }];
        }];
        
        self.tableView.mj_footer = [MJRefreshBackNormalFooter footerWithRefreshingBlock:^{
            // 进入刷新状态后会自动调用这个block
            [weakSelf delayInSeconds:1.0 block:^{
                weakSelf.itemNum += 4;
                [weakSelf.tableView.mj_footer endRefreshing];
                [weakSelf.tableView reloadData];
            }];
        }];
    }
    
    UISwipeGestureRecognizer *rightSwipe = [[UISwipeGestureRecognizer alloc]initWithTarget:self action:@selector(back)];
    [rightSwipe setDirection:UISwipeGestureRecognizerDirectionRight];
    [self.view addGestureRecognizer:rightSwipe];
}

- (void)delayInSeconds:(CGFloat)delayInSeconds block:(dispatch_block_t) block
{
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, delayInSeconds * NSEC_PER_SEC),  dispatch_get_main_queue(), block);
}

- (void)back {
    [self.navigationController popViewControllerAnimated:YES];
}

#pragma mark - Table view data source

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return xinwenArr.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    static NSString *zhuboxiangqingxinwenIdentify = @"zhuboxiangqingxinwenIdentify";
    UITableViewCell *cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:zhuboxiangqingxinwenIdentify];
    if (!cell)
    {
        cell = [tableView dequeueReusableCellWithIdentifier:zhuboxiangqingxinwenIdentify forIndexPath:indexPath];
    }
    UILabel *titleLab = [[UILabel alloc]initWithFrame:CGRectMake(15.0 / 375 * IPHONE_W, 12.0 / 667 * IPHONE_H, 355.0 / 375 * IPHONE_W, 21)];
    titleLab.text = xinwenArr[indexPath.row][@"post_title"];
    titleLab.textColor = [UIColor blackColor];
    titleLab.textAlignment = NSTextAlignmentLeft;
    titleLab.font = [UIFont boldSystemFontOfSize:17.0f];
    [cell.contentView addSubview:titleLab];
    [titleLab setNumberOfLines:0];
    titleLab.lineBreakMode = NSLineBreakByWordWrapping;
    CGSize size = [titleLab sizeThatFits:CGSizeMake(titleLab.frame.size.width, MAXFLOAT)];
    titleLab.frame = CGRectMake(titleLab.frame.origin.x, titleLab.frame.origin.y, titleLab.frame.size.width, size.height);
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    [cell.contentView addSubview:titleLab];
    UILabel *daxiao = [[UILabel alloc]initWithFrame:CGRectMake(15.0 / 375 * IPHONE_W, 63, 26.0 / 375 * IPHONE_W, 14)];
    daxiao.text = @"大小";
    daxiao.font = [UIFont systemFontOfSize:13.0f / 375 * IPHONE_W];
    daxiao.textColor = [UIColor whiteColor];
    daxiao.textAlignment = NSTextAlignmentCenter;
    daxiao.backgroundColor = ColorWithRGBA(38, 191, 252, 1);
    [cell.contentView addSubview:daxiao];
    UILabel *dataLab = [[UILabel alloc]initWithFrame:CGRectMake(41.0 / 375 * IPHONE_W, 63, 50.0 / 375 * IPHONE_W, 14)];
    dataLab.text = [NSString stringWithFormat:@"%.2lf%@",[xinwenArr[indexPath.row][@"post_size"] intValue] / 1024.0 / 1024.0,@"M"];
    dataLab.textColor = [UIColor whiteColor];
    dataLab.backgroundColor = [UIColor grayColor];
    dataLab.font = [UIFont systemFontOfSize:13.0f / 375 * IPHONE_W];
    dataLab.textAlignment = NSTextAlignmentCenter;
    [cell.contentView addSubview:dataLab];
    UILabel *riqiLab = [[UILabel alloc]initWithFrame:CGRectMake(240.0 / 375 * IPHONE_W, 61, 135.0 / 375 * IPHONE_W, 21)];
    riqiLab.text = xinwenArr[indexPath.row][@"post_modified"];;
    riqiLab.textColor = ColorWithRGBA(170, 170, 170, 1);
    riqiLab.font = [UIFont systemFontOfSize:13.0f / 375 * IPHONE_W];
    [cell.contentView addSubview:riqiLab];
    
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 80.0;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
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
