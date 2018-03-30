//
//  pinglunyeVC.h
//  reHeardTheNews
//
//  Created by 贺楠 on 16/4/27.
//  Copyright © 2016年 paoguo. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface pinglunyeVC : UIViewController
@property(nonatomic)NSString *to_uid;
@property(nonatomic)NSString *post_id;
@property(nonatomic)NSString *comment_id;
@property(nonatomic)NSString *post_table;
@property(nonatomic)BOOL isNewsCommentPage;// 新闻评论/听友圈投诉
//@property(assign,nonatomic)NSString *content;
@end
