//
//  AddBookViewController.m
//  Heard the news
//
//  Created by 温仲斌 on 15/12/2.
//  Copyright © 2015年 泡果网络. All rights reserved.
//

#import "AddBookViewController.h"

#import "CommonCode.h"

#import "AddBookManager.h"

#import "AddBookClass.h"

#import "AddBookViewController.h"

//#import "NetworkingMangater.h"

#import "HUProgressView.h"

#import "UserClass.h"

#import "GZ_Cell.h"

#import "TXLCell.h"

#import "gerenzhuyeVC.h"

@interface AddBookViewController ()<MFMessageComposeViewControllerDelegate>
{
    UILabel *existLable;
    UILabel *NoExistLable;
    UIView *bacView;
    HUProgressView *progress;
}

@property (nonatomic, strong) NSMutableArray *existArray;
@property (nonatomic, strong) NSMutableArray *NoExistArray;

@end

@implementation AddBookViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
    self.title = @"通讯录好友";

    progress = [[HUProgressView alloc] initWithProgressIndicatorStyle:HUProgressIndicatorStyleLarge];
    progress.center = CGPointMake(self.view.center.x, self.view.center.y - 64);
    progress.strokeColor = [UIColor grayColor];
    [self.view addSubview:progress];
    [progress startProgressAnimating];

    self.existArray = [NSMutableArray array];
    self.NoExistArray = [NSMutableArray array];
    
    
    UIButton *bs = [UIButton buttonWithType:UIButtonTypeCustom];
    [bs setImage:ImageWithName(@"back") forState:UIControlStateNormal];
    bs.bounds = CGRectMake(0, 0, 9, 15);
    bs.center = CGPointMake(0, 22);
    UIView *buttonView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, 44, 44)];
    [buttonView addSubview:bs];
    UITapGestureRecognizer *tapButton = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(back)];
    [buttonView addGestureRecognizer:tapButton];
    UIBarButtonItem *back = [[UIBarButtonItem alloc]initWithCustomView:buttonView];
    self.navigationItem.leftBarButtonItem = back;
    
    [self.tableView registerNib:[UINib nibWithNibName:@"GZ_Cell" bundle:nil] forCellReuseIdentifier:@"cell"];
    [self.tableView registerNib:[UINib nibWithNibName:@"TXLCell" bundle:nil] forCellReuseIdentifier:@"TXLCell"];

    [self.tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:@"cell1"];
    
    NSMutableString *telString = [NSMutableString string];
    NSMutableArray *ar = [[AddBookManager shaerManager]getBook].mutableCopy;
    [ar enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        UserClass *c = (UserClass *)obj;
        if (idx) {
            [telString appendString:@","];
            [telString appendString:c.user_phone];
        }else {
            [telString appendString:c.user_phone];
        }
    }];
    
    __weak typeof(self) selfBlock = self;
    [NetWorkTool matchCellphoneWithcellphone:telString sccess:^(NSDictionary *responseObject) {
        if ([responseObject[@"results"] isKindOfClass:[NSArray class]]) {
            for (NSDictionary *dic in responseObject[@"results"]) {
                UserClass *userC = [UserClass userClassWithDictionary:dic];
                [selfBlock.existArray addObject:userC];
                NSPredicate *p = [NSPredicate predicateWithFormat:@"SELF.user_phone == %@", userC.user_phone];
                NSArray *a = [ar filteredArrayUsingPredicate:p];
                if (a.count) {
                    [ar removeObject:a[0]];
                }
            }
        }
        [selfBlock.NoExistArray addObjectsFromArray:ar];
        [progress stopProgressAnimating];
        [selfBlock.tableView reloadData];
        
    } failure:^(NSError *error) {
        [progress stopProgressAnimating];
        [selfBlock.tableView reloadData];
    }];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self.navigationController setNavigationBarHidden:NO animated:YES];
    self.hidesBottomBarWhenPushed = YES;
}

- (void)back {
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


- (void)messageComposeViewController:(MFMessageComposeViewController *)controller didFinishWithResult:(MessageComposeResult)result{
    [controller dismissViewControllerAnimated:YES completion:nil];
    switch(result){
        caseMessageComposeResultSent:
            //信息传送成功
            
            break;
        caseMessageComposeResultFailed:
            //信息传送失败
            break;
        caseMessageComposeResultCancelled:
            //信息被用户取消传送
            break;
        default:
            break;
    }
}

-(void)showMessageView:(NSArray*)phones title:(NSString*)title body:(NSString*)body
{
    if([MFMessageComposeViewController canSendText])
    {
        MFMessageComposeViewController*controller=[[MFMessageComposeViewController alloc]init];
        controller.recipients= phones;
        controller.navigationBar.tintColor=[UIColor redColor];
        controller.body=body;
        controller.messageComposeDelegate=self;
        //TODO:跳转
        
//        UIViewController *VC = [UIViewController new];
//        for (UIView* next = [self superview]; next; next = next.superview) {
//            UIResponder* nextResponder = [next nextResponder];
//            if ([nextResponder isKindOfClass:[UIViewController class]]) {
//                VC =  (UIViewController*)nextResponder;
//            }
//        }
        [self.navigationController presentViewController:controller animated:YES completion:nil];
        [[[[controller viewControllers]lastObject]navigationItem]setTitle:title];//修改短信界面标题
    }
    else
    {
        UIAlertView*alert=[[UIAlertView alloc]initWithTitle:@"提示信息"
                                                    message:@"该设备不支持短信功能"
                                                   delegate:nil
                                          cancelButtonTitle:@"确定"
                                          otherButtonTitles:nil,nil];
        [alert show];
    }
}

#pragma mark - UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (section) {
        return _NoExistArray.count;
    }
    return _existArray.count;
}

- (CGFloat)tableView:(UITableView *)tableView estimatedHeightForHeaderInSection:(NSInteger)section {
    return 20;
}


- (nullable UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    if (!_existArray.count) {
        return nil;
    }
    if (section) {
        if (!_NoExistArray.count) {
            return nil;
        }
        if (!NoExistLable) {
            NoExistLable = [[UILabel alloc]initWithFrame:CGRectMake(0, 3, SCREEN_WIDTH, 20)];
            NoExistLable.textAlignment = NSTextAlignmentCenter;
            NoExistLable.font = [UIFont systemFontOfSize:13];
        }
        NoExistLable.text = @"--可邀请的好友--";
        return NoExistLable;
    }
    if (!_existArray.count) {
        return nil;
    }
    if (!existLable) {
        existLable = [[UILabel alloc]initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, 20)];
        existLable.textAlignment = NSTextAlignmentCenter;
        existLable.font = [UIFont systemFontOfSize:13];
    }
    existLable.text = @"--已开通的好友--";
    return existLable;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (!indexPath.section) {
        GZ_Cell *cell = [tableView dequeueReusableCellWithIdentifier:@"cell" forIndexPath:indexPath];
        cell.type = 1;
        cell.type = NO;
        cell.isFen = NO;
        UserClass *uClass =_existArray[indexPath.row];
        [cell setData:uClass andType:0];
        return cell;
    }
    TXLCell *cell = [tableView dequeueReusableCellWithIdentifier:@"TXLCell" forIndexPath:indexPath];
    DefineWeakSelf;
    [cell setInviteFriend:^(TXLCell *cell, NSString *user_phone, NSString *user_nickname) {
         [weakSelf showMessageView:[NSArray arrayWithObjects:user_phone,nil]title:@"test"body:[NSString stringWithFormat:@"亲爱的%@,您的好友邀请您加入“《听闻》”app。甜美主播真人录制，实时资讯每日更新，解放双手，轻松闻尽天下事。友情链接：http://www.tingwen.me/", user_nickname.length ? user_nickname :user_phone]];
    }];

    [cell setData:_NoExistArray[indexPath.row]];
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if (!indexPath.section) {
//        UserClass *uClass =_existArray[indexPath.row];
//        gerenzhuyeVC *gerenzhuye = [gerenzhuyeVC new];
//        gerenzhuye.isMypersonalPage = NO;
//        gerenzhuye.user_nicename = uClass.user_nicename;
//        gerenzhuye.sex = uClass.sex;
//        gerenzhuye.signature = uClass.signature;
//        gerenzhuye.user_login = uClass.user_login;
//        gerenzhuye.avatar = uClass.avatar;
//        gerenzhuye.fan_num = uClass.fan_num;
//        gerenzhuye.guan_num = uClass.guan_num;
//        self.hidesBottomBarWhenPushed=YES;
//        [self.navigationController pushViewController:gerenzhuye animated:YES];
//        self.hidesBottomBarWhenPushed=YES;
        
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (!indexPath.section) {
        return 67;
    }
    return 44;
}

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
