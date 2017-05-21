#ifdef __OBJC__
#import <UIKit/UIKit.h>
#else
#ifndef FOUNDATION_EXPORT
#if defined(__cplusplus)
#define FOUNDATION_EXPORT extern "C"
#else
#define FOUNDATION_EXPORT extern
#endif
#endif
#endif

#import "AppInformationsManager.h"
#import "JMODevicePowerInfos.h"
#import "JMOLogMacro.h"
#import "JMOMobileProvisionning.h"
#import "NSDictionary+iAppInfos.h"
#import "UIApplication+iAppInfos.h"
#import "UIDevice+iAppInfos.h"

FOUNDATION_EXPORT double iAppInfosVersionNumber;
FOUNDATION_EXPORT const unsigned char iAppInfosVersionString[];

