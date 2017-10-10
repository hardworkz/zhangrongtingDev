//
//  titleImageVC.m
//  reHeardTheNews
//
//  Created by Pop Web on 16/3/17.
//  Copyright © 2016年 paoguo. All rights reserved.
//

#import "titleImageVC.h"
#import "UIImageView+WebCache.h"
#import "FMActionSheet.h"
#import "UIColor+HexString.h"
#import "xiugaimimaVC.h"
#import "AFHTTPSessionManager.h"
@interface titleImageVC ()<UITableViewDataSource,UITableViewDelegate,UIActionSheetDelegate,UIImagePickerControllerDelegate>
{
    BOOL             isFullScreen;
    UIImageView     *touxiangImage;
    UITextField     *nameTF;
    UILabel         *sexLab;
    UITextField     *jianjieTF;
    NSDictionary    *userInfoDic;
    NSString        *isNan1Nv2;

}
/* 本页面主tableView */
@property(strong,nonatomic)UITableView *tableView;
/* lab */
@property(strong,nonatomic)NSArray *leftLabArr;

@property(strong,nonatomic)UIImageView *imageView;
@end

@implementation titleImageVC

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.view.backgroundColor = [UIColor whiteColor];
    
    userInfoDic = [[NSDictionary alloc]init];
    userInfoDic = [CommonCode readFromUserD:@"dangqianUserInfo"];
    
    self.title = @"编辑资料";
//    [self enableAutoBack];
    self.navigationController.navigationBar.titleTextAttributes = @{NSForegroundColorAttributeName: [UIColor blackColor],
                                                                    NSFontAttributeName : [UIFont boldSystemFontOfSize:18]};
    
    UIButton *leftBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [leftBtn setBackgroundImage:[UIImage imageNamed:@"back"] forState:UIControlStateNormal];
    leftBtn.bounds = CGRectMake(0, 0, 9, 15);
    UIBarButtonItem *back = [[UIBarButtonItem alloc]initWithCustomView:leftBtn];
    [leftBtn addTarget:self action:@selector(back) forControlEvents:UIControlEventTouchUpInside];
    self.navigationItem.leftBarButtonItem = back;
    
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc]initWithTitle:@"保存" style:UIBarButtonItemStylePlain target:self action:@selector(baocun:)];
    self.navigationItem.rightBarButtonItem.tintColor = [UIColor blackColor];
    [self.view addSubview:self.tableView];
    
    UISwipeGestureRecognizer *rightTapG = [[UISwipeGestureRecognizer alloc]initWithTarget:self action:@selector(tapGAction)];
    [rightTapG setDirection:UISwipeGestureRecognizerDirectionRight];
    [self.tableView addGestureRecognizer:rightTapG];
    
    //登录成功通知
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(loginSccess:) name:@"loginSccess" object:nil];
    //上传头像成功通知
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(shangchuantouxiangChengGong:) name:@"shangchuantouxiangChengGong" object:nil];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self.navigationController.navigationBar setHidden:NO];
    self.hidesBottomBarWhenPushed = YES;
}

#pragma mark --- tableView代理事件
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 3;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (section == 1)
    {
        return 3;
    }else
    {
        return 1;
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *bianjiIdentify = @"bianjiIdentify";
    UITableViewCell *cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:bianjiIdentify];
    if (!cell)
    {
        cell = [tableView dequeueReusableCellWithIdentifier:bianjiIdentify];
    }
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    UILabel *leftLab = [[UILabel alloc]initWithFrame:CGRectMake(10.0 / 375 * IPHONE_W, 11.0 / 667 * SCREEN_HEIGHT, 120.0 / 375 * IPHONE_W, 21.0 / 667 * SCREEN_HEIGHT)];
    leftLab.textColor = [UIColor blackColor];
    leftLab.font = [UIFont systemFontOfSize:16.0f];
    leftLab.text = self.leftLabArr[indexPath.section][indexPath.row];
    leftLab.textAlignment = NSTextAlignmentLeft;
    [cell.contentView addSubview:leftLab];
    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
 
    if (indexPath.section == 0 && indexPath.row == 0)
    {
        touxiangImage = [[UIImageView alloc]initWithFrame:CGRectMake(310.0 / 375 * IPHONE_W, 10.0 / 667 * SCREEN_HEIGHT, 29.0 / 667 * SCREEN_HEIGHT, 29.0 / 667 * SCREEN_HEIGHT)];
        touxiangImage.layer.cornerRadius = 14.5 / 667 * SCREEN_HEIGHT;
        touxiangImage.layer.masksToBounds = YES;
        touxiangImage.image = [UIImage imageWithContentsOfFile:ExTouXiangPath];
//        [touxiangImage sd_setImageWithURL:[NSURL URLWithString:USERPHOTOHTTPSTRING(userInfoDic[@"results"][@"avatar"])] placeholderImage:[UIImage imageNamed:@"right-1"]];
        [cell.contentView addSubview:touxiangImage];
    }else if (indexPath.section == 1 && indexPath.row == 0)
    {
        nameTF = [[UITextField alloc]initWithFrame:CGRectMake(120.0 / 375 * IPHONE_W, 15.0 / 667 * SCREEN_HEIGHT, 225.0 / 375 * IPHONE_W, 17.0 / 667 * SCREEN_HEIGHT)];
        nameTF.textAlignment = NSTextAlignmentRight;
        nameTF.font = [UIFont systemFontOfSize:16.0f ];
        nameTF.textColor = [UIColor blackColor];
        
        NSString *isNameNil = [CommonCode readFromUserD:@"dangqianUserInfo"][@"results"][@"user_nicename"];
        if (isNameNil.length == 0)
        {
            nameTF.text = [CommonCode readFromUserD:@"dangqianUserInfo"][@"results"][@"user_login"];
        }else
        {
            nameTF.text = userInfoDic[@"results"][@"user_nicename"];;
        }
        
        
        [cell.contentView addSubview:nameTF];
    }else if (indexPath.section == 1 && indexPath.row == 1)
    {
        sexLab = [[UILabel alloc]initWithFrame:CGRectMake(320.0 / 375 * IPHONE_W, 15.0 / 667 * SCREEN_HEIGHT, 20.0 / 375 * IPHONE_W, 17.0 / 667 * SCREEN_HEIGHT)];
        sexLab.font = [UIFont systemFontOfSize:16.0f ];
        sexLab.textColor = [UIColor blackColor];
        if ([userInfoDic[@"results"][@"sex"] isEqualToString:@"0"])
        {
            sexLab.text = @"";
            isNan1Nv2 = @"2";
            
        }
        else if ([userInfoDic[@"results"][@"sex"] isEqualToString:@"1"]){
            sexLab.text = @"男";
            isNan1Nv2 = @"1";
        }
        else{
             sexLab.text = @"女";
            isNan1Nv2 = @"2";
        }
        
        [cell.contentView addSubview:sexLab];
    }else if (indexPath.section == 1 && indexPath.row == 2)
    {
        jianjieTF = [[UITextField alloc]initWithFrame:CGRectMake(120.0 / 375 * IPHONE_W, 15.0, 225.0 / 375 * IPHONE_W, 17)];
        jianjieTF.textAlignment = NSTextAlignmentRight;
        jianjieTF.font = [UIFont systemFontOfSize:14.0f ];
        jianjieTF.textColor = [UIColor blackColor];
        NSString *isSignatureNil = userInfoDic[@"results"][@"signature"];
        if (isSignatureNil.length == 0)
        {
            jianjieTF.text = @"该用户没有什么想说的";
        }else
        {
            jianjieTF.text = userInfoDic[@"results"][@"signature"];
        }
        [cell.contentView addSubview:jianjieTF];
    } 
    return cell;
}
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 49.0 / 667 * SCREEN_HEIGHT;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
    return 8.0 / 667 * SCREEN_HEIGHT;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    if (section == 0)
    {
        return 8.0 / 667 * SCREEN_HEIGHT;
    }else
    {
        return 0.0001;
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == 0 && indexPath.row == 0)
    {
        [self shangchuantouxiang];
    }
    if (indexPath.section == 1 && indexPath.row == 1){
        [self.view endEditing:YES];
        FMActionSheet *sheet = [[FMActionSheet alloc] initWithTitle:@"请选择性别："
                                                       buttonTitles:[NSArray arrayWithObjects:@"男",@"女", nil]
                                                  cancelButtonTitle:@"取消"
                                                           delegate:(id<FMActionSheetDelegate>)self];
        sheet.titleFont = [UIFont systemFontOfSize:20];
        sheet.titleBackgroundColor = [UIColor colorWithHexString:@"f4f5f8"];
        sheet.titleColor = [UIColor colorWithHexString:@"666666"];
        sheet.lineColor = [UIColor colorWithHexString:@"dbdce4"];
        
        [sheet show];

    }else if (indexPath.section == 2 && indexPath.row == 0)
    {
        [self.navigationController pushViewController:[xiugaimimaVC new] animated:YES];
    }
}
#pragma FMActionSheetDelegate

- (void)actionSheets:(FMActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
    if (buttonIndex == 0) {
        sexLab.text = @"男";
        isNan1Nv2 = @"1";
    }else if(buttonIndex == 1){
        sexLab.text = @"女";
        isNan1Nv2 = @"2";
    }
}
#pragma mark --- 通知事件

- (void)shangchuantouxiangChengGong:(NSNotification *)notification{
    touxiangImage.image = [UIImage imageWithContentsOfFile:ExTouXiangPath];
    [self.tableView reloadData];
}

- (void)loginSccess:(NSNotification *)notification{
    
}

#pragma mark --- 事件
- (void)shangchuantouxiang
{
    UIActionSheet *sheet;
    //判断是否支持相机
    if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera])
    {
        sheet  = [[UIActionSheet alloc] initWithTitle:@"选择" delegate:self cancelButtonTitle:nil destructiveButtonTitle:@"取消" otherButtonTitles:@"拍照",@"从相册选择", nil];
        
    }
    
    else
    {
        
        sheet = [[UIActionSheet alloc] initWithTitle:@"选择" delegate:self cancelButtonTitle:nil destructiveButtonTitle:@"取消" otherButtonTitles:@"从相册选择", nil];
        
    }
    
    sheet.tag = 255;
    
    [sheet showInView:self.view];
    
    
    //==================
}
#pragma mark --- 图片选择器代理
-(void) actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (actionSheet.tag == 255) {
        
        NSUInteger sourceType = 0;
        
        // 判断是否支持相机
        if([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]) {
            
            switch (buttonIndex) {
                case 0:
                    // 取消
                    return;
                case 1:
                    // 相机
                    sourceType = UIImagePickerControllerSourceTypeCamera;
                    break;
                    
                case 2:
                    // 相册
                    sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
                    break;
            }
        }
        else {
            if (buttonIndex == 0) {
                
                return;
            } else {
                sourceType = UIImagePickerControllerSourceTypeSavedPhotosAlbum;
            }
        }
        // 跳转到相机或相册页面
        UIImagePickerController *imagePickerController = [[UIImagePickerController alloc] init];
        
        imagePickerController.delegate = self;
        
        imagePickerController.allowsEditing = YES;
        
        imagePickerController.sourceType = sourceType;
        
        [self presentViewController:imagePickerController animated:YES completion:^{}];
        
    }
}
#pragma mark - image picker delegte
- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info{
    [picker dismissViewControllerAnimated:YES completion:^{
        [self.tableView reloadData];
    }];
    
    UIImage *image = [info objectForKey:UIImagePickerControllerEditedImage];
    /* 此处info 有六个值
     * UIImagePickerControllerMediaType; // an NSString UTTypeImage)
     * UIImagePickerControllerOriginalImage;  // a UIImage 原始图片
     * UIImagePickerControllerEditedImage;    // a UIImage 裁剪后图片
     * UIImagePickerControllerCropRect;       // an NSValue (CGRect)
     * UIImagePickerControllerMediaURL;       // an NSURL
     * UIImagePickerControllerReferenceURL    // an NSURL that references an asset in the AssetsLibrary framework
     * UIImagePickerControllerMediaMetadata    // an NSDictionary containing metadata from a captured photo
     */
    // 保存图片至本地，方法见下文
    //    [self saveImage:image withName:@"currentImage.png"];
    [SVProgressHUD setDefaultMaskType:SVProgressHUDMaskTypeBlack];
    [SVProgressHUD showWithStatus:@"正在上传头像..."];
    
    UIImage *scaleImg = [self scaleToSize:image size:CGSizeMake(500, 500)];
    [self saveImage:scaleImg withName:@"userAvatar.png"];
    
    
    UIImage *savedImage = [[UIImage alloc] initWithContentsOfFile:[[NSHomeDirectory() stringByAppendingPathComponent:@"Documents"] stringByAppendingPathComponent:@"userAvatar.png"]];
    
    isFullScreen = NO;
    [self.imageView setImage:savedImage];
    
    self.imageView.tag = 100;
    
    NSData *imgData = UIImageJPEGRepresentation(savedImage, 0.5);
    
    //        [[UserProfileManager sharedInstance] uploadUserHeadImageProfileInBackground:image completion:^(BOOL success, NSError *error) {
    //            NSLog(@"一开始的error里面有 = %@",error);
    //            if (success == YES)
    //            {
    //                NSLog(@"上传成功");
    //            }else
    //            {
    //                NSLog(@"上传失败 error = %@",error);
    //            }
    //        }];
    
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    //设置上传数据格式为2进制
    manager.requestSerializer = [AFHTTPRequestSerializer serializer];
    //设置返回的数据是二进制格式
    manager.responseSerializer = [AFHTTPResponseSerializer serializer];
    NSDictionary *dict = @{@"accessToken":AvatarAccessToken};
    
    [manager POST:@"http://api.tingwen.me/index.php/api/interfaceNew/uploadHeadImg" parameters:dict constructingBodyWithBlock:^(id<AFMultipartFormData> formData) {
        [formData appendPartWithFileData:imgData name:@"photo" fileName:@"image.jpeg" mimeType:@"image.jpeg"];
    } success:^(NSURLSessionDataTask *task, id responseObject) {

        id obj = [NSJSONSerialization JSONObjectWithData:responseObject options:kNilOptions error:nil];
        if ([obj[@"status"] integerValue] == 1) {
            [SVProgressHUD showSuccessWithStatus:[NSString stringWithFormat:@"%@",obj[@"msg"]]];
            [self performSelector:@selector(SVPDismiss) withObject:nil afterDelay:1.0];
        }
        else{
            [SVProgressHUD showInfoWithStatus:[NSString stringWithFormat:@"%@",obj[@"msg"]]];
            [self performSelector:@selector(SVPDismiss) withObject:nil afterDelay:1.0];
        }
        NSLog(@"obj = %@",obj);
        [self.tableView reloadData];
        [[NSNotificationCenter defaultCenter]postNotificationName:@"shangchuantouxiangChengGong" object:nil];
    } failure:^(NSURLSessionDataTask *task, NSError *error) {
        NSLog(@"错误 = %@",error);
        [SVProgressHUD dismiss];
    }];
    
}
- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker
{
    [self dismissViewControllerAnimated:YES completion:^{
        [self.tableView reloadData];
    }];
}
#pragma mark - 保存图片至沙盒
- (void) saveImage:(UIImage *)currentImage withName:(NSString *)imageName
{
    
    NSData *imageData = UIImageJPEGRepresentation(currentImage, 0.5);
    // 获取沙盒目录
    
    NSString *fullPath = [[NSHomeDirectory() stringByAppendingPathComponent:@"Documents"] stringByAppendingPathComponent:imageName];
    // 将图片写入文件
    
    [imageData writeToFile:fullPath atomically:NO];
}
-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    
    isFullScreen = !isFullScreen;
    UITouch *touch = [touches anyObject];
    
    CGPoint touchPoint = [touch locationInView:self.view];
    
    CGPoint imagePoint = self.imageView.frame.origin;
    //touchPoint.x ，touchPoint.y 就是触点的坐标
    
    // 触点在imageView内，点击imageView时 放大,再次点击时缩小
    if(imagePoint.x <= touchPoint.x && imagePoint.x +self.imageView.frame.size.width >=touchPoint.x && imagePoint.y <=  touchPoint.y && imagePoint.y+self.imageView.frame.size.height >= touchPoint.y)
    {
        // 设置图片放大动画
        [UIView beginAnimations:nil context:nil];
        // 动画时间
        [UIView setAnimationDuration:1];
        
        if (isFullScreen) {
            // 放大尺寸
            
            self.imageView.frame = CGRectMake(0, 0, 320, 480);
        }
        else {
            // 缩小尺寸
            self.imageView.frame = CGRectMake(50, 65, 90, 115);
        }
        
        // commit动画
        [UIView commitAnimations];
        
    }
    
}
#pragma mark --- 图片压缩方法
- (UIImage *)scaleToSize:(UIImage *)img size:(CGSize)size
{
    // 创建一个bitmap的context
    // 并把它设置成为当前正在使用的context
    UIGraphicsBeginImageContext(size);
    // 绘制改变大小的图片
    [img drawInRect:CGRectMake(0,0, size.width, size.height)];
    // 从当前context中创建一个改变大小后的图片
    UIImage* scaledImage =UIGraphicsGetImageFromCurrentImageContext();
    // 使当前的context出堆栈
    UIGraphicsEndImageContext();
    //返回新的改变大小后的图片
    return scaledImage;
}
//============================
- (void)tapGAction
{
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)baocun:(UIBarButtonItem *)sender {
    
    NSDictionary *dic = [CommonCode readFromUserD:@"dangqianUserInfo"];
    NSMutableDictionary *Mdic = [[NSMutableDictionary alloc]initWithDictionary:dic];
    NSMutableDictionary *dicRe = [[NSMutableDictionary alloc]initWithDictionary:Mdic[@"results"]];
    
    [dicRe setValue:nameTF.text forKey:@"user_nicename"];
    [dicRe setValue:jianjieTF.text forKey:@"signature"];
    [dicRe setValue:isNan1Nv2 forKey:@"sex"];
    [Mdic setValue:dicRe forKey:@"results"];
    [CommonCode writeToUserD:Mdic andKey:@"dangqianUserInfo"];

    NSDictionary *postDic = [CommonCode readFromUserD:@"dangqianUserInfo"];
    
    [NetWorkTool postPaoGuoUserInfoWithUserName:[DSE encryptUseDES:[CommonCode readFromUserD:@"dangqianUser"]] andNiceName:postDic[@"results"][@"user_nicename"] andSex:postDic[@"results"][@"sex"] andSignature:postDic[@"results"][@"signature"] sccess:^(NSDictionary *responseObject) {
        if ([responseObject[@"status"] integerValue] == 1) {
            UIAlertController *xiugaichenggong = [UIAlertController alertControllerWithTitle:@"修改信息成功" message:nil preferredStyle:UIAlertControllerStyleAlert];
            [xiugaichenggong addAction:[UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
                [[NSNotificationCenter defaultCenter]postNotificationName:@"xiugaixinxiSeccess" object:postDic];
                [self.navigationController popViewControllerAnimated:YES];
            }]];
            [self presentViewController:xiugaichenggong animated:YES completion:nil];
            //修改资料成功 --》 获取用户信息
            [[NSNotificationCenter defaultCenter] postNotificationName:@"updateUserInfo" object:nil];
        }
        else{
            UIAlertController *xiugaichenggong = [UIAlertController alertControllerWithTitle:[NSString stringWithFormat:@"%@",responseObject[@"msg"]] message:nil preferredStyle:UIAlertControllerStyleAlert];
            [xiugaichenggong addAction:[UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            }]];
            [self presentViewController:xiugaichenggong animated:YES completion:nil];
        }
        
    } failure:^(NSError *error) {
        UIAlertController *xiugaichenggong = [UIAlertController alertControllerWithTitle:@"修改信息失败" message:nil preferredStyle:UIAlertControllerStyleAlert];
        [xiugaichenggong addAction:[UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        }]];
        [self presentViewController:xiugaichenggong animated:YES completion:nil];
        NSLog(@"修改失败 = %@",error);
    }];
    
}

- (void)back {
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)SVPDismiss {
    [SVProgressHUD dismiss];
}

#pragma mark --- 懒加载
- (UITableView *)tableView{
    if (!_tableView){
        _tableView = [[UITableView alloc]initWithFrame:CGRectMake(0, 0, IPHONE_W, IPHONE_H) style:UITableViewStyleGrouped];
        _tableView.dataSource = self;
        _tableView.delegate = self;
    }
    return _tableView;
}

- (NSArray *)leftLabArr{
    if (!_leftLabArr){
        _leftLabArr = [NSArray array];
        _leftLabArr = @[@[@"设置头像"],@[@"昵称",@"性别",@"简介"],@[@"修改密码"]];
    }
    return _leftLabArr;
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter]removeObserver:self];
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
