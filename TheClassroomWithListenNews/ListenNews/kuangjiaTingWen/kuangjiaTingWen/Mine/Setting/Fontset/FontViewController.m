//
//  FontViewController.m
//  Heard the news
//
//  Created by Pop Web on 15/8/13.
//  Copyright (c) 2015年 泡果网络. All rights reserved.
//

#import "FontViewController.h"
#import "bofangVC.h"
#import "CommonCode.h"

@interface FontViewController ()
@property (weak, nonatomic) IBOutlet UITableViewCell *c1;
@property (weak, nonatomic) IBOutlet UITableViewCell *c2;
@property (weak, nonatomic) IBOutlet UITableViewCell *c3;
@property (weak, nonatomic) IBOutlet UITableViewCell *c4;
@property (weak, nonatomic) IBOutlet UITableViewCell *c5;
@property (weak, nonatomic) IBOutlet UITableViewCell *c6;

@end

static UITableViewCell *cell1;

@implementation FontViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
    
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
    self.title = @"设置字体";
    NSString *fontStr = [CommonCode readFromUserD:NEWSFONTKEY];
    if ([fontStr length]) {
        self.fontSizeStr = fontStr;
    }
    else{
        self.fontSizeStr = @"大";
    }
    
    NSString *str = [[NSUserDefaults standardUserDefaults] objectForKey:@"fontSize"];
    if ([str isEqualToString:@"巨无霸"]) {
        _c1.accessoryType = UITableViewCellAccessoryCheckmark;
        cell1 = _c1;
    }else if([str isEqualToString:@"巨大"]){
        _c2.accessoryType = UITableViewCellAccessoryCheckmark;
        cell1 = _c2;
    }else if([str isEqualToString:@"超大"]){
        _c3.accessoryType = UITableViewCellAccessoryCheckmark;
        cell1 = _c3;
    }else if([str isEqualToString:@"大"]){
        _c4.accessoryType = UITableViewCellAccessoryCheckmark;
        cell1 = _c4;
    }else if([str isEqualToString:@"中"]){
        _c5.accessoryType = UITableViewCellAccessoryCheckmark;
        cell1 = _c5;
    }else if([str isEqualToString:@"小"]) {
        _c6.accessoryType = UITableViewCellAccessoryCheckmark;
        cell1 = _c6;
    }

    self.tableView.tableFooterView = [UIView new];
    UIButton *bs = [UIButton buttonWithType:UIButtonTypeCustom];
    [bs setImage:[UIImage imageNamed:@"back"] forState:UIControlStateNormal];
    bs.accessibilityLabel = @"返回";
    bs.bounds = CGRectMake(0, 0, 9, 15);
    bs.center = CGPointMake(0, 22);
    UIView *buttonView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, 44, 44)];
    [buttonView addSubview:bs];
    UITapGestureRecognizer *tapButton = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(back)];
    [buttonView addGestureRecognizer:tapButton];
    UIBarButtonItem *back = [[UIBarButtonItem alloc]initWithCustomView:buttonView];
    self.navigationItem.leftBarButtonItem = back;
    
    UISwipeGestureRecognizer *rightSwipe = [[UISwipeGestureRecognizer alloc]initWithTarget:self action:@selector(back)];
    [rightSwipe setDirection:UISwipeGestureRecognizerDirectionRight];
    [self.view addGestureRecognizer:rightSwipe];
    
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    self.hidesBottomBarWhenPushed = YES;
}

- (void)back {
    [self.navigationController popViewControllerAnimated:YES];
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    cell1.accessoryType = UITableViewCellAccessoryNone;
    UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
    cell.accessoryType = UITableViewCellAccessoryCheckmark;
    cell1 = cell;
    self.fontSizeStr = cell.textLabel.text;
    if (self.didFinishSetFont) {
        self.didFinishSetFont(self);
    }
    //新闻界面的字体大小 与设置_字体设置相关联
    CGFloat titleFontSize;
    CGFloat dateFont;
    if (indexPath.row == 0) {
        titleFontSize = 25.0;
        dateFont = 19.0;
    }
    else if (indexPath.row == 1){
        titleFontSize = 23.0;
        dateFont = 17.0;
    }
    else if (indexPath.row == 2){
        titleFontSize = 21.0;
        dateFont = 16.0;
    }
    else if (indexPath.row == 3){
        titleFontSize = 19.0;
        dateFont = 14.0;
    }
    else if (indexPath.row == 4){
        titleFontSize = 17.0;
        dateFont = 12.0;
    }
    else{
        titleFontSize = 15.0;
        dateFont = 11.0;
    }
    
    [NewPlayVC shareInstance].titleFontSize = titleFontSize;
    [NewPlayVC shareInstance].dateFont = dateFont;
    [[NewPlayVC shareInstance] reloadInterface];
    
    [ClassViewController shareInstance].titleFontSize = titleFontSize;
    [[ClassViewController shareInstance] frameArrayWithClassModel:nil];
    [[ClassViewController shareInstance].helpTableView reloadData];
    
    [CommonCode writeToUserD:cell.textLabel.text andKey:NEWSFONTKEY];
    [CommonCode writeToUserD:@(titleFontSize) andKey:TitleFontSize];
    [CommonCode writeToUserD:@(dateFont) andKey:DateFont];

    [[NSUserDefaults standardUserDefaults] setValue:cell.textLabel.text forKey:@"fontSize"];
    [[NSUserDefaults standardUserDefaults]synchronize];
    
//    [[NSNotificationCenter defaultCenter] postNotificationName:@"changeSheZhi" object:@"font"];
    
    [self.navigationController popViewControllerAnimated:YES];
}

@end
