//
//  NewQATextController.h
//  KangShiFu_Elearnning
//
//  Created by ND-MAC-WangGuoMing on 7/16/14.
//  Copyright (c) 2014 Lin Yawen. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SAMTextView.h"

@class NewQAController;
@class NewQASelectedUsersController;

@interface NewQATextController : UITableViewController

@property (weak, nonatomic) IBOutlet SAMTextView *txBlogText;
@property (assign, nonatomic) BOOL isAddNewQuestion;
@property (strong, nonatomic) NSString *placeHolderString;

/**
 *  已选择的用户内容
 */
@property (strong, nonatomic) NewQASelectedUsersController *selectUserController;
@property (strong, nonatomic) NSMutableArray *receivers;
@property (assign, nonatomic) NSInteger maxContentLength;

/**
 *  自适应布局(当填充文本，图片 内容以后)
 */
-(void)adjustLayout;

/**
 *  @某人
 *
 *  @param contacter contacter
 */
- (void)atSomeOne:(id)contacter;

@property(nonatomic,weak) NewQAController *qaController;

@end
