//
//  ClassAuditionListModel.h
//  kuangjiaTingWen
//
//  Created by 泡果 on 2017/6/2.
//  Copyright © 2017年 zhimi. All rights reserved.
//

#import <Foundation/Foundation.h>

/*
 "s_title": "\u9b4f\u96ea\u6f2b \u6b22\u8fce\u60a8\u52a0\u5165\u201c\u96ea\u6f2b\u8bfb\u4e66\u201d",
 "s_mpurl": "http:\/\/admin.tingwen.me\/data\/upload\/stmp3\/20170307\/58be72a61970a.mp3"
 */
@interface ClassAuditionListModel : NSObject
@property (strong, nonatomic) NSString *s_title;/**< */
@property (strong, nonatomic) NSString *s_mpurl;/**< */
@end
