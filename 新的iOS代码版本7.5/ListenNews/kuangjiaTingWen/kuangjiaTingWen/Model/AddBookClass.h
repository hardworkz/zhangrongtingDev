//
//  AddBookClass.h
//  Heard the news
//
//  Created by 温仲斌 on 15/12/1.
//  Copyright © 2015年 泡果网络. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AddressBook/AddressBook.h>

#import <AddressBookUI/AddressBookUI.h>
#import <MessageUI/MessageUI.h>

@interface AddBookClass : NSObject

@property (nonatomic, assign)ABAddressBookRef addressBookRef;
@property NSInteger sectionNumber;
@property NSInteger recordID;
@property (nonatomic, strong) NSString *name;
@property (nonatomic, strong) NSString *email;
@property (nonatomic, strong) NSString *tel;
@property (nonatomic, strong) NSMutableArray *personArray;

@end
