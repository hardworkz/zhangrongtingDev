//
//  newsActModel.h
//  kuangjiaTingWen
//
//  Created by 泡果 on 2017/6/21.
//  Copyright © 2017年 zhimi. All rights reserved.
//

#import <Foundation/Foundation.h>

/*
 "id": "155",
 "name": "\u6797\u6657",
 "description": "\u8d22\u7ecf\u65b0\u95fb\u3001\u79d1\u6280\u65b0\u95fb\u4e3b\u64ad",
 "images": "2017-03-02\/crop_58b79cb65a38d.jpg",
 "fan_num": "22440",
 "message_num": "28",
 "is_fan": "0"
 */
@interface newsActModel : NSObject
@property (nonatomic, strong) NSString *act_id;
@property (nonatomic, strong) NSString *name;
@property (nonatomic, strong) NSString *Description;
@property (nonatomic, strong) NSString *images;
@property (nonatomic, strong) NSString *fan_num;
@property (nonatomic, strong) NSString *message_num;
@property (nonatomic, strong) NSString *is_fan;
@end
