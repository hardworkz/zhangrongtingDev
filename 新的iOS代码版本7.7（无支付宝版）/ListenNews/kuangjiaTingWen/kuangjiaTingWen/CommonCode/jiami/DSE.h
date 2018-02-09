//
//  DSE.h
//  kuangjiaTingWen
//
//  Created by Zhimi on 17/1/6.
//  Copyright © 2017年 贺楠. All rights reserved.
//

//防止文件冲突 把文件名改为DSE.h  本来为DES.h



#import <Foundation/Foundation.h>
#import <CommonCrypto/CommonDigest.h>
#import <CommonCrypto/CommonCryptor.h>

@interface DSE : NSObject{
    
}
//+ (NSString *) udid;
//+ (NSString *) md5:(NSString *)str;
//+ (NSString *) doCipher:(NSString *)sTextIn key:(NSString *)sKey context:(CCOperation)encryptOrDecrypt;
//+ (NSString *) encryptStr:(NSString *) str;
//+ (NSString *) decryptStr:(NSString *) str;
//
//
//#pragma mark Based64
//
//+ (NSString *)encryptUseDES:(NSString *)plainText key:(NSString *)key;
//
//+ (NSString *)encryptUseDES:(NSString *)plainText andKey:(NSString *)authKey andIv:(NSString *)authIv;
//
//+ (NSString *) encodeBase64WithString:(NSString *)strData;
//+ (NSString *) encodeBase64WithData:(NSData *)objData;
//+ (NSData *) decodeBase64WithString:(NSString *)strBase64;

+(NSString *)encryptUseDES:(NSString *)plainText;//加密
+(NSString *)decryptUseDES:(NSString *)cipherText;//解密

@end
