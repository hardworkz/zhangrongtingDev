//
//  NewQATextController.m
//  KangShiFu_Elearnning
//
//  Created by ND-MAC-WangGuoMing on 7/16/14.
//  Copyright (c) 2014 Lin Yawen. All rights reserved.
//

#import "NewQATextController.h"
#import "NewBlogPictureController.h"
//#import "NewBlogController.h"
#import "CTAssetsPickerController.h"
#import "NewQAController.h"
//#import "NewQASelectedUsersController.h"
#import "UIDevice+iAppInfos.h"


typedef NS_ENUM(NSInteger, BlogContentType)
{
    BlogContentTypeText = 0,
    BlogContentTypePic = 1,
    BlogContentTypeUsers = 2
};

@interface NewQATextController ()<UITextViewDelegate>
{
    dispatch_once_t onceToken;
}
// 图片内容
@property(nonatomic,strong) NewBlogPictureController * blogPictureController;
@property (nonatomic, strong) NSMutableArray *assets; //选择的图片

@property (weak, nonatomic) IBOutlet UIButton *voiceButton;
@property (weak, nonatomic) IBOutlet UILabel *voiceTimeLabel;
@property (weak, nonatomic) IBOutlet UIButton *deleteVoiceButton;

@property (weak, nonatomic) IBOutlet UIButton *voiceRecoderButton;

@end

@implementation NewQATextController

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.txBlogText.delegate = self;
    self.txBlogText.placeholder = @"说点什么吧...";
    
    [IQKeyboardManager sharedManager].shouldFixTextViewClip = NO;
    [IQKeyboardManager sharedManager].canAdjustTextView = NO;
    
//    if (self.isAddNewQuestion) {
//        self.txBlogText.placeholder = @"清晰的描述问题，可以更容易获得答案噢 ~";
//    }
//    else{
//        self.txBlogText.placeholder = @"请输入添加答案的内容";
//    }
//    if (self.placeHolderString) {
//        self.txBlogText.placeholder = self.placeHolderString;
//    }
    
    CGSize size = [[UIScreen mainScreen] bounds].size;
    if (size.height <= 480.0f) {
        _txBlogText.height -= 50;
    }
    
    _receivers  = [NSMutableArray array];
    
}
-(void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    [self.txBlogText becomeFirstResponder];
}
- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event
{
    [self.txBlogText resignFirstResponder];
}
#pragma mark - UITextViewDelegate
//-(void)textViewDidBeginEditing:(UITextView *)textView
//{
//    // do sth necessary
//}
//
//-(void)textViewDidEndEditing:(UITextView *)textView
//{
//    // do sth necessary
////    [textView setNeedsLayout];
//}

- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text
{
    if (textView.text.length >= self.maxContentLength && text.length > range.length) {
        NSString *msg = [NSString stringWithFormat:@"最大输入字符为%ld个", (long)self.maxContentLength];
        [SVProgressHUD showErrorWithStatus:msg];
        return NO;
    }
    
    return YES;
}

//- (void)textViewDidChange:(UITextView *)textView
//{
////    [self adjustLayout];
//    if (textView.markedTextRange == nil && self.maxContentLength > 0 && textView.text.length >= self.maxContentLength) {
//        /**
//         *  SAAS-3855
//         【兼容】【问答社区】4S 7.0.4输入内容大于1024个字符应用闪退
//         *  NSMutableRLEArray replaceObjectsInRange:withObject:length:: Out of bounds
//         *                 --- linyawen  03.18
//         */
////        @try {
//            NSString *msg = [NSString stringWithFormat:@"最大输入字符为%ld个", (long)self.maxContentLength];
////            [SVProgressHUD showErrorWithStatus:msg];
//        [[XWAlerLoginView alertWithTitle:msg] show];
////            textView.text = [textView.text substringToIndex:(self.maxContentLength -1)];
////            [textView scrollRangeToVisible:NSMakeRange(textView.text.length - 10, 10)];
////        }
////        @catch (NSException *exception) {
////            ;
////        }
////        @finally {
////            ;
////        };
//    }
//}

//-(void)adjustLayout{
//    [self.tableView reloadData];
//    self.txBlogText.width = self.txBlogText.width;
//    if (!IOS_VERSION_LESS_THAN_OR_EQUAL_TO(@"7")) {
//        [self.txBlogText resignFirstResponder];
//    };
//}


#pragma mark - Table view data source
// 微博输入区域的高度
-(float)heightOfTextCell{
    return 160;
    //TODO: 随着输入 动态改变大小
    //    UIFont * font = self.txBlogText.font;
    //    float height = [self.txBlogText.text heightWithFont:font constrainedToWidth:self.view.width lineBreakMode:NSLineBreakByWordWrapping];
    //    return height + 40;
}

//微博图片的高度
-(float)heightOfPicCell
{
    CGSize size = self.blogPictureController.contentSize;
    return size.height < 90 ? 90 : size.height + 45;
}

/**
 *  已选择用户列表的高度
 *
 *  @return 高度
 */
- (CGFloat)heightOfSelectUsers{
//    CGSize size = self.selectUserController.collectionView.contentSize;
//    return size.height;
    return 0;
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    float height = 44;
    switch (indexPath.row)
    {
        case BlogContentTypeText:
        {
            // 填写微博文本
            height = [self heightOfTextCell];
            break;
        };
        case BlogContentTypePic:
        {
            // 微博图片
            height = [self heightOfPicCell];
            break;
        };
        case BlogContentTypeUsers:{
            height = [self heightOfSelectUsers];
        }
            break;
        default:
            break;
    };
    return height;
};

#pragma mark - Navigation
#define EmbedBlogPicIdentifier  @"EmbedBlogPicIdentifier"
#define EmbedBlogSelectedUserIdentifier  @"EmbedSelectUserIdentifier"

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    [super prepareForSegue:segue sender:sender];
    if ([segue.identifier isEqualToString:EmbedBlogPicIdentifier]) {
//        NIDASSERT([segue.destinationViewController isKindOfClass:[NewBlogPictureController class]]);
        NewQAController *blogVC = (NewQAController *)self.qaController;
//        NIDASSERT([blogVC isKindOfClass:[NewQAController class]]);
        blogVC.blogPictureController = segue.destinationViewController;
        self.blogPictureController = segue.destinationViewController;
        self.blogPictureController.qaController = self.qaController;
    };
    if ([segue.identifier isEqualToString:EmbedBlogSelectedUserIdentifier]) {
//        NIDASSERT([segue.destinationViewController isKindOfClass:[NewQASelectedUsersController class]]);
        NewQAController *blogVC = (NewQAController *)self.qaController;
//        NIDASSERT([blogVC isKindOfClass:[NewQAController class]]);
        NewQASelectedUsersController *vc = (NewQASelectedUsersController *)segue.destinationViewController;
        self.selectUserController = vc;
        blogVC.selectUserController = vc;
    }
}

#pragma mark - PublicMethod

-(void)atSomeOne:(id)contacter
{
//    StaffModel *staff = (StaffModel *) contacter;
//    if ([self.receivers containsObject:staff]) {
//        return;
//    }
//    self.txBlogText.text = [NSString stringWithFormat:@"%@@%@ ", self.txBlogText.text, staff.account_name];
//    [self.receivers addObject:staff];
}

#pragma mark - UIScrollViewDelegate

//- (void)scrollViewDidScroll:(UIScrollView *)scrollView{
//    [self.view endEditing:YES];
//    [self adjustLayout];
//    [self.txBlogText resignFirstResponder];
//}


@end
