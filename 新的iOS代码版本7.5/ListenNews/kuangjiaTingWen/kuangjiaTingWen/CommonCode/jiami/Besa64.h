//
//  Besa64.h
//  kuangjiaTingWen
//
//  Created by Zhimi on 17/1/6.
//  Copyright © 2017年 贺楠. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Besa64 : NSObject

+ (NSString*)encodeBase64String:(NSString*)input;

+ (NSString*)decodeBase64String:(NSString*)input;

+ (NSString*)encodeBase64Data:(NSData*)data;

+ (NSString*)decodeBase64Data:(NSData*)data;

@end
