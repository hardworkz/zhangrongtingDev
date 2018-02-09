//
//  NewQAController.h
//  KangShiFu_Elearnning
//
//  Created by ND-MAC-WangGuoMing on 7/16/14.
//  Copyright (c) 2014 Lin Yawen. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "StoryBoardLoader.h"

/**
 *  发布新的问题界面
 */

/**
 *  内容类型
 */
typedef NS_ENUM(NSInteger, InputContentType){
    /**
     *  无
     */
    InputContentTypeNone = 0,
    /**
     *  补充问题
     */
    InputContentTypeAppendQuestion,
    /**
     *  新增问题
     */
    InputContentTypeNewQuestion,
    /**
     *  回答问题
     */
    InputContentTypeAnswer
};


@class NewQATextController,NewBlogPictureController, NewQASelectedUsersController;

@protocol NewQAControllerDelegate;

@interface NewQAController : UIViewController<StoryboardLoader>

// 文本内容
@property (nonatomic,strong) NewQATextController * qaTextController;
/**
 *  已选择的用户内容
 */
@property (strong, nonatomic) NewQASelectedUsersController *selectUserController;
// 图片内容
@property(nonatomic,strong) NewBlogPictureController * blogPictureController;
@property (assign, nonatomic) id<NewQAControllerDelegate> delegate;
@property (assign, nonatomic) NSInteger maxContentLength;
@property (assign, nonatomic) NSInteger minContnetLength;

@property (copy, nonatomic) NSString *lengthLimitedTips;
@property (strong, nonatomic) NSString *textFieldPlaceHolderString;

@property (assign, nonatomic) InputContentType inputContentType;

//界面来源类型
@property (assign, nonatomic) NSInteger inputType;
@property (assign, nonatomic)BOOL isFeedbackVC;

/**
 *  替换敏感字
 *
 *  @param keyward 敏感字数组
 */
- (void)clearContentWithKeywordArray:(NSArray *)keywardArray;

- (void)hideSelectPeopleItem:(BOOL)hide;
- (void)hideToolBar:(BOOL)hide;

- (void)actionSelectPhoto:(id)sender;

@end


@protocol NewQAControllerDelegate <NSObject>

@optional
//退出
- (void)newQAControllerCancelAddNewQA:(NewQAController *)qaController;

//发表问题成功
- (void)newQAController:(NewQAController *)qaController
              sendNewQA:(NSString *)content
            attachments:(NSArray *)attachments
               location:(NSString *)location
                address:(NSString *)address
             MpvoiceURL:(NSURL *)tmpfile
        MpvoicePlaytime:(NSString *)playtime;

@end
