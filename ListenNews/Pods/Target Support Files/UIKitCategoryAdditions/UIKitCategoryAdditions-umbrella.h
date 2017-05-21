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

#import "MKBlockAdditions.h"
#import "NSObject+MKBlockAdditions.h"
#import "UIActionSheet+MKBlockAdditions.h"
#import "UIAlertView+MKBlockAdditions.h"

FOUNDATION_EXPORT double UIKitCategoryAdditionsVersionNumber;
FOUNDATION_EXPORT const unsigned char UIKitCategoryAdditionsVersionString[];

