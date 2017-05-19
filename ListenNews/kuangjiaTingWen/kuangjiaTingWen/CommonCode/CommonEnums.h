//
//  CommonEnums.h
//  wutuobang
//
//  Created by Eric Wang on 16/4/25.
//  Copyright © 2016年 Eric. All rights reserved.
//

#import <Foundation/Foundation.h>

/**
 *  用户类型
 */
typedef NS_ENUM(NSUInteger, UserType) {
    /**
     *  机构
     */
    UserTypeOrg = 1,
    /**
     *  家长
     */
    UserTypeParent,
    /**
     *  小孩
     */
    UserTypeChildren,
    /**
     *  老师
     */
    UserTypeTeacher
};

/**
 *  性别
 */
typedef NS_ENUM(NSUInteger, SexType) {
    /**
     *  未定义
     */
    SexTypeUndefine = 0,
    /**
     *  男
     */
    SexTypeMale = 1,
    /**
     *  女
     */
    SexTypeFemale = 2,
};

/**
 *  短信类型
 */
typedef NS_ENUM(NSUInteger, SMSType) {
    /**
     *  注册
     */
    SMSTypeRegister,
    /**
     *  忘记密码
     */
    SMSTypeForgetPassword,
    /**
     *  其他
     */
    SMSTypeOther
};


/**
 *  家长身份
 */
typedef NS_ENUM(NSUInteger, RelationShipType) {
    /**
     *  爸爸
     */
    RelationShipTypeFather = 1,
    /**
     *  妈妈
     */
    RelationShipTypeMother,
    /**
     *  兄弟姐妹
     */
    RelationShipTypeBrotherOrSister,
    /**
     *  爷爷
     */
    RelationShipTypeGrandpa,
    /**
     *  奶奶
     */
    RelationShipTypeGrandma
};



/**
 *  已点名列表
 */
typedef NS_ENUM(NSUInteger, CallTaskSortType) {
    /**
     *  按签到时间排序
     */
    CallTaskSortTypeByTime = 0,
    /**
     *  按点名老师排序
     */
    CallTaskSortTypeByTeacher = 1,
    /**
     *  按年级班级排序
     */
    CallTaskSortTypeByClass = 2
};

/**
 *  签到状态
 */
typedef NS_ENUM(NSUInteger, SignStatus) {
    /**
     *  已签到
     */
    SignStatusSigned
};

@interface CommonEnums : NSObject

+ (NSString *)userTypeName:(UserType)userType;

+ (NSString *)relationShipTypeName:(RelationShipType)type;

+ (NSString *)callTaskSortTypeName:(CallTaskSortType)sortType;

+ (NSString *)signStatusName:(SignStatus)staus;

@end
