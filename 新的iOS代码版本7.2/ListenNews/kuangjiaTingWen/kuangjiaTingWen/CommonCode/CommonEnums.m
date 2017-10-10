//
//  CommonEnums.m
//  wutuobang
//
//  Created by Eric Wang on 16/4/25.
//  Copyright © 2016年 Eric. All rights reserved.
//

#import "CommonEnums.h"

@implementation CommonEnums

+ (NSString *)userTypeName:(UserType)userType{
    switch (userType) {
        case UserTypeOrg: {
            return @"org";
            break;
        }
        case UserTypeParent: {
            return @"parent";
            break;
        }
        case UserTypeTeacher: {
            return @"teacher";
            break;
        }
        case UserTypeChildren: {
            return @"child";
            break;
        }
    }
}

+ (NSString *)relationShipTypeName:(RelationShipType)type{
    switch (type) {
        case RelationShipTypeFather: {
            return @"父亲";
            break;
        }
        case RelationShipTypeMother: {
            return @"母亲";
            break;
        }
        case RelationShipTypeBrotherOrSister: {
            return @"兄弟姐妹";
            break;
        }
        case RelationShipTypeGrandpa: {
            return @"爷爷";
            break;
        }
        case RelationShipTypeGrandma: {
            return @"奶奶";
            break;
        }
    }
}

+ (NSString *)callTaskSortTypeName:(CallTaskSortType)sortType{
    switch (sortType) {
        case CallTaskSortTypeByTeacher: {
            return @"teacher";
            break;
        }
        case CallTaskSortTypeByClass: {
            return @"class";
            break;
        }
        case CallTaskSortTypeByTime: {
            return @"sign";
            break;
        }
    }
}

+ (NSString *)signStatusName:(SignStatus)staus{
    switch (staus) {
        case SignStatusSigned: {
            return @"signed";
            break;
        }
    }
}

@end
