//
//  HomePageHeader.h
//  kuangjiaTingWen
//
//  Created by 泡果 on 2017/6/2.
//  Copyright © 2017年 zhimi. All rights reserved.
//

#ifndef HomePageHeader_h
#define HomePageHeader_h

#import "zhuboxiangqingVCNew.h"
#import "ClassViewController.h"

#import "ClassContentTableViewCell.h"
#import "ClassAuditionTableViewCell.h"
#import "ClassImageViewTableViewCell.h"
#import "ClassCommentTableViewCell.h"

#import "ClassModel.h"
#import "ClassAuditionListModel.h"
#import "ClassCommentListModel.h"
#import "ClassContentCellFrameModel.h"
#import "ClassImageViewCellFrameModel.h"
#import "ClassCommentCellFrameModel.h"
#import "ClassAuditionCellFrameModel.h"


static NSString *const TitleFontSize = @"titleFontSize";/**<新闻标题和内容，课堂标题和内容的字体大小*/
static NSString *const DateFont = @"dateFont";/**<新闻发布日期的字体大小*/
static NSString *const orderNumber = @"orderNumber";/**<课堂购买订单号*/
static NSString *const ReloadClassList = @"reloadClassList";/**<刷新课堂列表通知*/

#endif /* HomePageHeader_h */
