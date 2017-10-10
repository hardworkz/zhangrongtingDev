//
//  ClassModel.h
//  kuangjiaTingWen
//
//  Created by 泡果 on 2017/6/2.
//  Copyright © 2017年 zhimi. All rights reserved.
//

#import <Foundation/Foundation.h>

/*
 "id": "6",
 "author": "1",
 "act_id": "247",
 "date": "2017-03-01 18:35:12",
 "content": null,
 "title": "2017\u521b\u4e1a\u6295\u8d44\u3001\u804c\u573a\u664b\u5347\u5fc5\u8bfb\u768458\u672c\u4e66",
 "lai": "\u96ea\u6f2b\u8bfb\u4e66",
 "excerpt": "",
 "modified": "2017-03-01 18:29:45",
 "status": "1",
 "smeta": "{\"thumb\":\"http:\\\/\\\/admin.tingwen.me\\\/Uploads\\\/2017-03-01\\\/crop_58b6a2ff47db5.jpg\"}",
 "images": "http:\/\/admin.tingwen.me\/Uploads\/stimg\/20170301\/58b6a3c9efd2a.jpg,http:\/\/admin.tingwen.me\/Uploads\/stimg\/20170504\/590b0574c86d6.jpg",
 "name": "\u96ea\u6f2b\u8bfb\u4e66",
 "price": "99.00",
 "sprice": "2610.00",
 */
@interface ClassModel : NSObject
@property (strong, nonatomic) NSString *ID;/**< */
@property (strong, nonatomic) NSString *author;/**< */
@property (strong, nonatomic) NSString *act_id;/**< */
@property (strong, nonatomic) NSString *date;/**< */
@property (strong, nonatomic) NSString *content;/**< */
@property (strong, nonatomic) NSString *title;/**< */
@property (strong, nonatomic) NSString *lai;/**< */
@property (strong, nonatomic) NSString *excerpt;/**< */
@property (strong, nonatomic) NSString *modified;/**< */
@property (strong, nonatomic) NSString *status;/**< */
@property (strong, nonatomic) NSString *smeta;/**< */
@property (strong, nonatomic) NSString *images;/**< */
@property (strong, nonatomic) NSMutableArray *imagesArray;/**< 图片url数组*/
@property (strong, nonatomic) NSMutableArray *imagesFrameArray;/**< 图片frame数组*/
@property (strong, nonatomic) NSString *name;/**< */
@property (strong, nonatomic) NSString *price;/**< */
@property (strong, nonatomic) NSString *sprice;/**< */
@property (strong, nonatomic) NSArray *shiting;/**< 试听列表*/
@property (strong, nonatomic) NSArray *comments;/**< 评论列表*/
@property (strong, nonatomic) NSMutableArray *commentsFrameArray;/**< 图片frame数组*/
@end
