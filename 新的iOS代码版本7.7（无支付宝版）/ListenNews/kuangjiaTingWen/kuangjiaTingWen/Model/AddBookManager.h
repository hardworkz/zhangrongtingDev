//
//  AddBookManager.h
//  Heard the news
//
//  Created by 温仲斌 on 15/12/1.
//  Copyright © 2015年 泡果网络. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface AddBookManager : NSObject

+ (AddBookManager *)shaerManager;
- (NSMutableArray *)getBook;

@end
