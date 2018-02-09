//
//  faxianSubModel.h
//  kuangjiaTingWen
//
//  Created by 泡果 on 2017/6/16.
//  Copyright © 2017年 zhimi. All rights reserved.
//

#import <Foundation/Foundation.h>

/*
 "id": "247",
 "name": "2017\u521b\u4e1a\u6295\u8d44\u3001\u804c\u573a\u664b\u5347\u5fc5\u8bfb\u768458\u672c\u4e66",
 "description": "\u9b4f\u96ea\u6f2b \u8d44\u6df1\u8bb2\u4e66\u8001\u5e08\r\n\u4e2d\u56fd\u597d\u58f0\u97f3\u5b9e\u529b\u6d3e\u6b4c\u624b",
 "images": "2017-03-21\/crop_58d1144b8157a.jpg",
 "list_tpl": null,
 "one_tpl": null,
 "listorder": "21",
 "status": "1",
 "post_content": "",
 "comment_count_act": "0",
 "act_type": "1",
 "term_id": "0",
 "author": "1",
 "price": "99.00",
 "sprice": "2610.00",
 "fan_num": 715,
 "message_num": "21",
 "is_fan": 0,
 "is_free": "0"
 */
@interface faxianSubModel : NSObject
@property (strong, nonatomic) NSString *ID;/**<*/
@property (strong, nonatomic) NSString *name;/**<*/
@property (strong, nonatomic) NSString *Description;/**<*/
@property (strong, nonatomic) NSString *images;/**<*/
@property (strong, nonatomic) NSString *list_tpl;/**<*/
@property (strong, nonatomic) NSString *one_tpl;/**<*/
@property (strong, nonatomic) NSString *listorder;/**<*/
@property (strong, nonatomic) NSString *status;/**<*/
@property (strong, nonatomic) NSString *post_content;/**<*/
@property (strong, nonatomic) NSString *comment_count_act;/**<*/
@property (strong, nonatomic) NSString *act_type;/**<*/
@property (strong, nonatomic) NSString *term_id;/**<*/
@property (strong, nonatomic) NSString *author;/**<*/
@property (strong, nonatomic) NSString *price;/**<*/
@property (strong, nonatomic) NSString *sprice;/**<*/
@property (strong, nonatomic) NSString *fan_num;/**<*/
@property (strong, nonatomic) NSString *message_num;/**<*/
@property (strong, nonatomic) NSString *is_fan;/**<*/
@property (strong, nonatomic) NSString *is_free;/**<课堂判断是否已购买*/
@end
