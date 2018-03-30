//
//  Besa64.m
//  kuangjiaTingWen
//
//  Created by Zhimi on 17/1/6.
//  Copyright © 2017年 贺楠. All rights reserved.
//

#import "Besa64.h"
#import "GTMBase64.h"

@implementation Besa64

+ (NSString*)encodeBase64String:(NSString* )input {
    
    NSData*data = [input dataUsingEncoding:NSUTF8StringEncoding allowLossyConversion:YES];
    
    data = [GTMBase64 encodeData:data];
    
    NSString*base64String = [[NSString alloc]initWithData:data encoding:NSUTF8StringEncoding] ;
    
    return base64String;
    
}

+ (NSString*)decodeBase64String:(NSString* )input {
    
    NSData*data = [input dataUsingEncoding:NSUTF8StringEncoding allowLossyConversion:YES];
    
    data = [GTMBase64 decodeData:data];
    
    NSString*base64String = [[NSString alloc]initWithData:data encoding:NSUTF8StringEncoding] ;
    
    return base64String;
    
}

+ (NSString*)encodeBase64Data:(NSData*)data {
    
    data = [GTMBase64 encodeData:data];
    
    NSString * base64String = [[NSString alloc]initWithData:data encoding:NSUTF8StringEncoding] ;
    
    return base64String;
    
}

+ (NSString*)decodeBase64Data:(NSData*)data {
    
    data = [GTMBase64 decodeData:data];
    
    NSString*base64String = [[NSString alloc]initWithData:data encoding:NSUTF8StringEncoding] ;
    
    return base64String;
    
}

@end
