//
//  SingleWebViewController.h
//  zfbuser
//
//  Created by Eric Wang on 15/10/30.
//  Copyright (c) 2015年 Eric. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SingleWebViewController : RootViewController

- (instancetype)initWithTitle:(NSString *)title url:(NSURL *)url;

- (void)addShareBarButton;


@end
