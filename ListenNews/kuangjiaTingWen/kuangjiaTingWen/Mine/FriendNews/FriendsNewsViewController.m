//
//  FriendsNewsViewController.m
//  kuangjiaTingWen
//
//  Created by 泡果 on 16/7/28.
//  Copyright © 2016年 贺楠. All rights reserved.
//

#import "FriendsNewsViewController.h"
#import "MJRefresh.h"
#import "NSDate+TimeFormat.h"
#import "UIView+tap.h"
#import "gerenzhuyeVC.h"
#import "bofangVC.h"

@interface FriendsNewsViewController ()<UITableViewDataSource,UITableViewDelegate>

@property (strong, nonatomic) UITableView *tableView;
@property (strong, nonatomic) NSMutableArray *infoArr;
@property (assign, nonatomic) NSInteger numberPage;
@property (strong, nonatomic) UIImageView *titleImg;


@end

@implementation FriendsNewsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self setupData];
    [self setupView];
    
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self.navigationController setNavigationBarHidden:NO];
    self.hidesBottomBarWhenPushed = YES;
}

- (void)setupData {
    
    [self loadData];
}

- (void)setupView {
    
    [self enableAutoBack];
    [self setTitle:@"好友动态"];
    
    [self.view addSubview:self.tableView];
    
    UISwipeGestureRecognizer *rightSwipe = [[UISwipeGestureRecognizer alloc]initWithTarget:self action:@selector(rightSwipeAction)];
    [rightSwipe setDirection:UISwipeGestureRecognizerDirectionRight];
    [self.tableView addGestureRecognizer:rightSwipe];
    
    DefineWeakSelf;
    weakSelf.tableView.mj_header = [MJRefreshNormalHeader headerWithRefreshingBlock:^{
        [weakSelf refreshData];
    }];
    weakSelf.tableView.mj_footer = [MJRefreshAutoStateFooter footerWithRefreshingBlock:^{
        [weakSelf shangLaJiaZai];
    }];
}

- (UITableView *)tableView {
    if (!_tableView){
        _tableView = [[UITableView alloc]initWithFrame:CGRectMake(0, 0, IPHONE_W, IPHONE_H - 64) style:UITableViewStylePlain];
        _tableView.delegate = self;
        _tableView.dataSource = self;
    }
    return _tableView;
}

- (NSMutableArray *)infoArr {
    if (!_infoArr)
    {
        _infoArr = [NSMutableArray array];
    }
    return _infoArr;
}

#pragma mark - Utilities

- (void)loadData {
    [NetWorkTool getPaoGuoFriendDongTaiWithaccessToken:[DSE encryptUseDES:ExdangqianUser] andPage:@"1" andLimit:@"10" sccess:^(NSDictionary *responseObject2) {
        if ([responseObject2[@"results"] isKindOfClass:[NSArray class]])
        {
            [self.infoArr removeAllObjects];
            [self.infoArr addObjectsFromArray:responseObject2[@"results"]];
        }
        [self.tableView reloadData];
        [CommonCode writeToUserD:self.infoArr andKey:[NSString stringWithFormat:@"%@haoyoupinglun",ExdangqianUser]];
    } failure:^(NSError *error2) {
        NSLog(@"error = %@",error2);
    }];
    [self.tableView.mj_header endRefreshing];
}

- (void)refreshData {
    self.numberPage = 1;
    [NetWorkTool getPaoGuoFriendDongTaiWithaccessToken:[DSE encryptUseDES:ExdangqianUser] andPage:@"1" andLimit:@"10" sccess:^(NSDictionary *responseObject2) {
        if ([responseObject2[@"results"] isKindOfClass:[NSArray class]]){
            [self.infoArr removeAllObjects];
            [self.infoArr addObjectsFromArray:responseObject2[@"results"]];
        }
        [self.tableView reloadData];
        [CommonCode writeToUserD:self.infoArr andKey:[NSString stringWithFormat:@"%@haoyoupinglun",ExdangqianUser]];
    } failure:^(NSError *error2) {
        NSLog(@"error = %@",error2);
    }];
    [self.tableView.mj_header endRefreshing];
    
}

- (void)shangLaJiaZai {
    self.numberPage ++;
    [NetWorkTool getPaoGuoFriendDongTaiWithaccessToken:[DSE encryptUseDES:ExdangqianUser] andPage:[NSString stringWithFormat:@"%ld",(long)self.numberPage] andLimit:@"10" sccess:^(NSDictionary *responseObject) {
        if ([responseObject[@"results"] isKindOfClass:[NSArray class]])
        {
            [self.infoArr addObjectsFromArray:responseObject[@"results"]];
        }
        [self.tableView reloadData];
        [self.tableView.mj_footer endRefreshing];
    } failure:^(NSError *error) {
        NSLog(@"error = %@",error);
        [self.tableView.mj_footer endRefreshing];
    }];
}

- (void)rightSwipeAction {
    [self.navigationController popViewControllerAnimated:YES];
}

#pragma mark - UITableViewDelegate 

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 171;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [self.infoArr count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    static NSString *gerenzhuyeIdentify = @"friendNewsIdentify";
    UITableViewCell *cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:gerenzhuyeIdentify];
    if (!cell)
    {
        cell = [tableView dequeueReusableCellWithIdentifier:gerenzhuyeIdentify];
    }
    _titleImg = [[UIImageView alloc]init];
    _titleImg.frame = CGRectMake(8.0 / 375 * IPHONE_W, 13, 40, 40);
    _titleImg.layer.cornerRadius = 20.0f;
    _titleImg.layer.masksToBounds = YES;
    [_titleImg sd_setImageWithURL:[NSURL URLWithString:USERPHOTOHTTPSTRING(self.infoArr[indexPath.row][@"comment"][@"avatar"])] placeholderImage:[UIImage imageNamed:@"user-5"]];
    DefineWeakSelf;
    [_titleImg addTapCallBack:^{
        NSDictionary *components = weakSelf.infoArr[indexPath.row][@"comment"];
        gerenzhuyeVC *gerenzhuye = [gerenzhuyeVC new];
        if ([components[@"user_login"] isEqualToString:ExdangqianUser] && [[CommonCode readFromUserD:@"isLogin"]boolValue] == YES) {
            gerenzhuye.isMypersonalPage = YES;
        }
        else{
            gerenzhuye.isMypersonalPage = NO;
        }
        gerenzhuye.isNewsComment = YES;
        gerenzhuye.user_nicename = components[@"user_nicename"];
        gerenzhuye.sex = components[@"sex"];
        gerenzhuye.signature = components[@"signature"];
        gerenzhuye.user_login = components[@"user_login"];
        gerenzhuye.avatar = components[@"avatar"];
        gerenzhuye.fan_num = components[@"fan_num"];
        gerenzhuye.guan_num = components[@"guan_num"];
        weakSelf.hidesBottomBarWhenPushed = YES;
        [weakSelf.navigationController pushViewController:gerenzhuye animated:YES];
        weakSelf.hidesBottomBarWhenPushed = YES;
    }];
    [cell.contentView addSubview:_titleImg];
    UILabel *titleLabName = [[UILabel alloc]init];
    titleLabName.frame = CGRectMake(55.0 / 375 * IPHONE_W, 13, 200, 21);
    if ([self.infoArr[indexPath.row][@"comment"] isKindOfClass:[NSDictionary class]])
    {
        if ([self.infoArr[indexPath.row][@"comment"][@"full_name"] isEqualToString:@""])
        {
            titleLabName.text = self.infoArr[indexPath.row][@"user_login"];
        }else
        {
            titleLabName.text = self.infoArr[indexPath.row][@"comment"][@"full_name"];
        }
    }else
    {
        if ([self.infoArr[indexPath.row][@"user_nicename"] isEqualToString:@""])
        {
            titleLabName.text = self.infoArr[indexPath.row][@"user_login"];
        }else
        {
            titleLabName.text = self.infoArr[indexPath.row][@"user_nicename"];
        }
    }
    
    titleLabName.textColor = ColorWithRGBA(46, 216, 250, 1);
    titleLabName.font = [UIFont systemFontOfSize:15.0f];
    titleLabName.textAlignment = NSTextAlignmentLeft;//按钮文字左对齐
    [cell.contentView addSubview:titleLabName];
    
    UILabel *timeLab = [[UILabel alloc]initWithFrame:CGRectMake(56.0 / 375 * IPHONE_W, 33, 200, 21)];
    timeLab.textColor = ColorWithRGBA(170, 170, 170, 1);
    timeLab.font = [UIFont systemFontOfSize:13.0f];
    timeLab.textAlignment = NSTextAlignmentLeft;
    NSDate *date = [NSDate dateFromString:self.infoArr[indexPath.row][@"createtime"]];
    timeLab.text = [date showTimeByTypeA];
    //    timeLab.text = self.infoArr[indexPath.row][@"createtime"];
    [cell.contentView addSubview:timeLab];
    
    UILabel *fenxiangLab = [[UILabel alloc]initWithFrame:CGRectMake(8.0 / 375 * IPHONE_W, 56, IPHONE_W - 8.0 / 375 * IPHONE_W, 21)];
    fenxiangLab.textColor = [UIColor blackColor];
    
    NSString *textContent;
    if ([self.infoArr[indexPath.row][@"comment"] isKindOfClass:[NSDictionary class]])
    {
        textContent = self.infoArr[indexPath.row][@"comment"][@"content"];
    }else
    {
        textContent = self.infoArr[indexPath.row][@"content"];
    }
    if (![textContent isEqualToString:@""])
    {
        if ([textContent rangeOfString:@"[e1]"].location != NSNotFound && [textContent rangeOfString:@"[/e1]"].location != NSNotFound)
        {
            fenxiangLab.text = [CommonCode jiemiEmoji:textContent];
        }else
        {
            fenxiangLab.text = textContent;
        }
    }else
    {
        fenxiangLab.text = @"分享了：";
    }
    fenxiangLab.font = [UIFont systemFontOfSize:15.0f];
    fenxiangLab.textAlignment = NSTextAlignmentLeft;
    [cell.contentView addSubview:fenxiangLab];
    
    UIView *bgV = [[UIView alloc]initWithFrame:CGRectMake(3.0 / 375 * IPHONE_W, 84, IPHONE_W - 6.0 / 375 * IPHONE_W, 79)];
    bgV.backgroundColor = ColorWithRGBA(239, 239, 244, 1);
    [cell.contentView addSubview:bgV];
    
    UIImageView *imgLeft = [[UIImageView alloc]initWithFrame:CGRectMake(5.0 / 375 * IPHONE_W, 10, 112.0 / 375 * IPHONE_W, 62.72 / 375 *IPHONE_W)];
    [imgLeft sd_setImageWithURL:[NSURL URLWithString:NEWSSEMTPHOTOURL(self.infoArr[indexPath.row][@"smeta"])] placeholderImage:[UIImage imageNamed:@"thumbnailsdefault"]];
    [bgV addSubview:imgLeft];
    imgLeft.contentMode = UIViewContentModeScaleToFill;
    
    UILabel *titleLab = [[UILabel alloc]initWithFrame:CGRectMake(123.0 / 375 * IPHONE_W, 11, 248.0 / 375 * IPHONE_W, 21)];
    titleLab.text = self.infoArr[indexPath.row][@"post_title"];
    titleLab.textColor = [UIColor blackColor];
    titleLab.textAlignment = NSTextAlignmentLeft;
    titleLab.font = [UIFont systemFontOfSize:14.0f];
    [titleLab setNumberOfLines:0];
    titleLab.lineBreakMode = NSLineBreakByWordWrapping;
    CGSize size = [titleLab sizeThatFits:CGSizeMake(titleLab.frame.size.width, MAXFLOAT)];
    titleLab.frame = CGRectMake(titleLab.frame.origin.x, titleLab.frame.origin.y, titleLab.frame.size.width, size.height);
    [bgV addSubview:titleLab];
    
    UILabel *daxiao = [[UILabel alloc]initWithFrame:CGRectMake(125.0 / 375 * IPHONE_W, 63, 35.0 / 375 * IPHONE_W, 14)];
    daxiao.text = @"大小";
    daxiao.font = [UIFont systemFontOfSize:13.0f];
    daxiao.textColor = [UIColor whiteColor];
    daxiao.textAlignment = NSTextAlignmentCenter;
    daxiao.backgroundColor = ColorWithRGBA(38, 191, 252, 1);
    [bgV addSubview:daxiao];
    UILabel *dataLab = [[UILabel alloc]initWithFrame:CGRectMake(161.0 / 375 * IPHONE_W, 63, 50.0 / 375 * IPHONE_W, 14)];
    dataLab.text = [NSString stringWithFormat:@"%.2lf%@",[self.infoArr[indexPath.row][@"post_size"] intValue] / 1024.0 / 1024.0,@"M"];
    dataLab.textColor = [UIColor whiteColor];
    dataLab.backgroundColor = [UIColor grayColor];
    dataLab.font = [UIFont systemFontOfSize:13.0f ];
    dataLab.textAlignment = NSTextAlignmentCenter;
    [bgV addSubview:dataLab];
    UILabel *riqiLab = [[UILabel alloc]initWithFrame:CGRectMake(210.0 / 375 * IPHONE_W, 61, 145.0 / 375 * IPHONE_W, 21)];
    riqiLab.text = self.infoArr[indexPath.row][@"post_modified"];;
    riqiLab.textColor = ColorWithRGBA(170, 170, 170, 1);
    riqiLab.font = [UIFont systemFontOfSize:13.0f ];
    [bgV addSubview:riqiLab];
    
    
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    if ([self.infoArr[indexPath.row][@"post_id"]isEqualToString:@"0"]) {
        return;
    }
    else{
        //TODO:跳转新闻详情
        if ([[CommonCode readFromUserD:@"dangqianbofangxinwenID"] isEqualToString:self.infoArr[indexPath.row][@"post_id"]]){
            self.hidesBottomBarWhenPushed = YES;
            [self.navigationController.navigationBar setHidden:YES];
            [self.navigationController pushViewController:[bofangVC shareInstance] animated:YES];
            [[bofangVC shareInstance].tableView reloadData];
            self.hidesBottomBarWhenPushed = YES;
            if ([bofangVC shareInstance].isPlay) {
                
            }
            else{
                [[bofangVC shareInstance] doplay2];
            }
        }
        else{
            [bofangVC shareInstance].newsModel.jiemuID = self.infoArr[indexPath.row][@"post_id"];
            [bofangVC shareInstance].newsModel.Titlejiemu = self.infoArr[indexPath.row][@"post_title"];
            [bofangVC shareInstance].newsModel.RiQijiemu = self.infoArr[indexPath.row][@"post_date"];
            [bofangVC shareInstance].newsModel.ImgStrjiemu = self.infoArr[indexPath.row][@"smeta"];
            [bofangVC shareInstance].newsModel.post_lai = self.infoArr[indexPath.row][@"post_lai"];
            [bofangVC shareInstance].newsModel.post_news = self.infoArr[indexPath.row][@"post_news"];
            //获取主播信息
            [[NSNotificationCenter defaultCenter] postNotificationName:@"getActInfoNotification" object:self.infoArr[indexPath.row][@"post_id"]];
            [bofangVC shareInstance].newsModel.jiemuName = nil;
            [bofangVC shareInstance].newsModel.jiemuDescription = nil;
            [bofangVC shareInstance].newsModel.jiemuImages = nil;
            [bofangVC shareInstance].newsModel.jiemuFan_num = nil;
            [bofangVC shareInstance].newsModel.jiemuMessage_num = nil;
            [bofangVC shareInstance].newsModel.jiemuIs_fan = nil;
            [bofangVC shareInstance].newsModel.post_mp = self.infoArr[indexPath.row][@"post_mp"];
            [bofangVC shareInstance].newsModel.post_time = self.infoArr[indexPath.row][@"post_time"];
            [bofangVC shareInstance].iszhuboxiangqing = NO;
            [bofangVC shareInstance].newsModel.post_keywords = self.infoArr[indexPath.row][@"post_keywords"];
            [bofangVC shareInstance].newsModel.url = @"";
            [bofangVC shareInstance].yinpinzongTime.text = [[bofangVC shareInstance] convertStringWithTime:[self.infoArr[indexPath.row][@"post_time"] intValue] / 1000];
            
            ExcurrentNumber = (int)indexPath.row;
            [bofangVC shareInstance].newsModel.ImgStrjiemu = self.infoArr[indexPath.row][@"smeta"];
            [bofangVC shareInstance].newsModel.ZhengWenjiemu = self.infoArr[indexPath.row][@"post_excerpt"];
            [bofangVC shareInstance].newsModel.praisenum = self.infoArr[indexPath.row][@"praisenum"];
            [[bofangVC shareInstance].tableView reloadData];
            //        Explayer = [[AVPlayer alloc]initWithPlayerItem:[[AVPlayerItem alloc]initWithURL:[NSURL URLWithString:arr[indexPath.row][@"post_mp"]]]];
            [Explayer replaceCurrentItemWithPlayerItem:[[AVPlayerItem alloc]initWithURL:[NSURL URLWithString:self.infoArr[indexPath.row][@"post_mp"]]]];
            if ([bofangVC shareInstance].isPlay || ExIsKaiShiBoFang == NO) {
                
            }
            else{
                [[bofangVC shareInstance] doplay2];
            }
            ExisRigester = YES;
            ExIsKaiShiBoFang = YES;
            ExwhichBoFangYeMianStr = @"shouyebofang";
            self.hidesBottomBarWhenPushed = YES;
            [self.navigationController.navigationBar setHidden:YES];
            [self.navigationController pushViewController:[bofangVC shareInstance] animated:YES];
            [[bofangVC shareInstance].tableView reloadData];
            //        [self.navigationController.navigationBar setHidden:NO];
            self.hidesBottomBarWhenPushed = YES;
            [[NSNotificationCenter defaultCenter] postNotificationName:@"yuanpanzhuan" object:nil];
            [[NSNotificationCenter defaultCenter] postNotificationName:@"qiehuanxinwen" object:nil];
            //            [CommonCode writeToUserD:self.blogArray andKey:@"zhuyeliebiao"];
            [CommonCode writeToUserD:self.infoArr[indexPath.row][@"post_id"] andKey:@"dangqianbofangxinwenID"];
            if ([[CommonCode readFromUserD:@"yitingguoxinwenID"] isKindOfClass:[NSArray class]])
            {
                NSMutableArray *yitingguoArr = [NSMutableArray arrayWithArray:[CommonCode readFromUserD:@"yitingguoxinwenID"]];
                [yitingguoArr addObject:self.infoArr[indexPath.row][@"post_id"]];
                [CommonCode writeToUserD:yitingguoArr andKey:@"yitingguoxinwenID"];
            }
            else
            {
                NSMutableArray *yitingguoArr = [NSMutableArray array];
                [yitingguoArr addObject:self.infoArr[indexPath.row][@"post_id"]];
                [CommonCode writeToUserD:yitingguoArr andKey:@"yitingguoxinwenID"];
            }
            [tableView reloadData];
        }
        
    }
}



- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
 #pragma mark - Navigation
 
 // In a storyboard-based application, you will often want to do a little preparation before navigation
 - (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
 // Get the new view controller using [segue destinationViewController].
 // Pass the selected object to the new view controller.
 }
 */

@end
