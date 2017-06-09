//
//  AppDelegate.m
//  1yqb
//
//  Created by 曲天白 on 15/12/11.
//  Copyright © 2015年 乙科网络. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>



#define SERVER_IMAGE @""//图片加载头地址
#define SUCCEED_CODE @"0"  //网络返回成功码
@interface NetWorkTool : NSObject
/**
 *  数组转json
 *
 *  @param arr 数组
 *
 *  @return 数组json
 */
+ (NSString *)NSArrayTojson:(NSArray *)arr;
/**
 *  json 转 字典
 *
 *  @param jsonStr json
 *
 *  @return 数组
 */
+ (NSDictionary *)dictionaryWithJsonString:(NSString *)jsonStr;
/**
 * 字典转json
 */
+ (NSString*)dictionaryToJson:(NSDictionary *)dic;
/**
 *  json 转 数组
 *
 *  @param jsonStr json
 *
 *  @return 数组
 */
+(NSArray *)arrayWithjsonString:(NSString *)jsonStr;
/**
 *  便利加载网络图片
 *
 *  @param imagV       图片容器
 *  @param imageUrlStr 图片地址字符串
 */
+(void)imageWithImagView:(UIImageView *)imagV andImageUrlStr :(NSString *)imageUrlStr;

/**
 *  同步请求
 *
 *  @param url     请求URL
 *  @param param   请求参数
 *  @param success 成功回调
 *  @param failure 失败回调
 */
+(void)syncNetworkingUrl:(NSString *)url
                  andDict:(NSDictionary *)param
                  success:(void (^)(NSDictionary *responseObject))success
                  failure:(void (^)(NSError *error))failure;
/**
 *  异步请求
 *
 *  @param url     请求URL
 *  @param param   请求参数
 *  @param success 成功回调
 *  @param failure 失败回调
 */
+(void)asyncNetworkingUrl:(NSString *)url
                  andDict:(NSDictionary *)param
                  success:(void (^)(NSDictionary *responseObject))success
                  failure:(void (^)(NSError *error))failure;
/**
 *  登录
 *
 *  @param mobile   用户注册手机
 *  @param email    用户注册邮箱
 *  @param password 用户密码
 *  @param success  成功responseObject
 *  @param failure  失败error
 */
+(void)login_mobile:(NSString *)mobile andlogin_email:(NSString *)email andlogin_password:(NSString *)password andpw:(NSString *)pw success:(void (^)(NSDictionary *))success failure:(void (^)(NSError *))failure;
/**
 *  获取用户信息
 *
 *  @param uid     uid
 *  @param success 成功responseObject
 *  @param failure 失败error
 */
+(void)GetUserInFo_uid:(NSString*)uid  success:(void (^)(NSDictionary *responseObject))success
               failure:(void (^)(NSError *error))failure;
/**
 *  保存用户信息
 *
 *  @param uid      uid
 *  @param email    email
 *  @param qianming 签名
 *  @param name     昵称
 *  @param qq       QQ
 *  @param success  成功responseObject
 *  @param failure  失败error
 */
+(void)SetUserInFo_uid:(NSString*)uid andUseremail:(NSString *)email andUserQianMing:(NSString*)qianming andUserName:(NSString*)name andUserQQ:(NSString*)qq  success:(void (^)(NSDictionary *responseObject))success
               failure:(void (^)(NSError *error))failure;

/**
 *  签到
 *
 *  @param uid     uid
 *  @param success 成功responseObject
 *  @param failure 失败error
 */
+(void)Sign_uid:(NSString*)uid andState:(NSString *)str success:(void (^)(NSDictionary *responseObject))success
        failure:(void (^)(NSError *error))failure;

/**
 *  获取收货地址列表
 *
 *  @param uid     uid
 *  @param success 成功responseObject
 *  @param failure 失败error
 */
+(void)Address_uid:(NSString*)uid success:(void (^)(NSDictionary *responseObject))success
           failure:(void (^)(NSError *error))failure;

//融云获取Token
+(void)getToken:(NSString*)userId andName:(NSString *)name andportraitUri:(NSString *)touXiangUrl success:(void (^)(NSDictionary *responseObject))success
        failure:(void (^)(NSError *error))failure;

/**
 *  获取城市列表
 *
 *  @param uid     nil
 *  @param success 成功responseObject
 *  @param failure 失败error
 */
+(void)Getcity_uid:(NSString*)uid success:(void (^)(NSDictionary *responseObject))success
           failure:(void (^)(NSError *error))failure;
/**
 *   添加收货地址
 *
 *  @param uid         用户id
 *  @param sheng       省
 *  @param shi         市
 *  @param qu          区
 *  @param info        详细
 *  @param youbian     邮编
 *  @param shoujianren 收件人
 *  @param mobile      手机号
 *  @param tell        座机
 *  @param success     成功
 *  @param failure     失败
 */
+(void)Addaddress_uid:(NSString*)uid andSheng:(NSString *)sheng andShi:(NSString *)shi andQu:(NSString *)qu andinfo:(NSString *)info andYouBian:(NSString *)youbian andShouJianRen:(NSString *)shoujianren andmobile:(NSString *)mobile andTell:(NSString *)tell success:(void (^)(NSDictionary *responseObject))success
              failure:(void (^)(NSError *error))failure;
/**
 *  修改收货地址（设置默认、删除）
 *
 *  @param uid     uid
 *  @param Id      地址id
 *  @param action  动作
 *  @param success 成功
 *  @param failure 失败
 */
+(void)SetAddress_uid:(NSString*)uid andadressID:(NSString *)Id andAction:(NSString *)action success:(void (^)(NSDictionary *responseObject))success
              failure:(void (^)(NSError *error))failure;
/**
 *  编辑收货地址
 *
 *  @param uid         <#uid description#>
 *  @param addId       <#addId description#>
 *  @param sheng       <#sheng description#>
 *  @param shi         <#shi description#>
 *  @param qu          <#qu description#>
 *  @param info        <#info description#>
 *  @param youbian     <#youbian description#>
 *  @param shoujianren <#shoujianren description#>
 *  @param mobile      <#mobile description#>
 *  @param tell        <#tell description#>
 *  @param success     <#success description#>
 *  @param failure     <#failure description#>
 */
+(void)BianJiaddress_uid:(NSString*)uid andAddId:(NSString *)addId andSheng:(NSString *)sheng andShi:(NSString *)shi andQu:(NSString *)qu andinfo:(NSString *)info andYouBian:(NSString *)youbian andShouJianRen:(NSString *)shoujianren andmobile:(NSString *)mobile andTell:(NSString *)tell success:(void (^)(NSDictionary *responseObject))success
                 failure:(void (^)(NSError *error))failure;
/**
 *  获取账户明细
 *
 *  @param uid     uid
 *  @param type    获取种类
 *  @param page    页数
 *  @param success 成功
 *  @param failure 失败
 */
+(void)MoneyDetial_uid:(NSString *)uid andtype:(NSString *)type andpage:(NSString *)page success:(void (^)(NSDictionary *responseObject))success
               failure:(void (^)(NSError *error))failure;
/**
 *  抢宝记录
 *
 *  @param uid     uid
 *  @param index   当前分类
 *  @param page    页数
 *  @param success 成功
 *  @param failure 失败
 */
+(void)GetBaoDetial_uid:(NSString *)uid andtypeIndex:(NSString *)index andpage:(NSString *)page success:(void (^)(NSDictionary *responseObject))success
                failure:(void (^)(NSError *error))failure;
/**
 *  获得宝物纪录
 *
 *  @param uid     uid
 *  @param success 成功
 *  @param failure 失败
 */
+(void)BaoDetial_uid:(NSString *)uid  success:(void (^)(NSDictionary *responseObject))success
             failure:(void (^)(NSError *error))failure;
/**
 *  塞单
 *
 *  @param uid     <#uid description#>
 *  @param success <#success description#>
 *  @param failure <#failure description#>
 */
+(void)sandan_uid:(NSString *)uid success:(void (^)(NSDictionary *responseObject))success
          failure:(void (^)(NSError *error))failure;

+(void)QBsandan_page:(NSString *)page andsid:(NSString *)sid success:(void (^)(NSDictionary *responseObject))success
             failure:(void (^)(NSError *error))failure;

/**
 *  点赞
 *
 *  @param uid     <#uid description#>
 *  @param state   <#state description#>
 *  @param success <#success description#>
 *  @param failure <#failure description#>
 */
+(void)sandanZan_uid:(NSString *)uid success:(void (^)(NSDictionary *responseObject))success
             failure:(void (^)(NSError *error))failure;
//首页
+ (void)shouYesuccess:(void (^)(NSDictionary *responseObject))success
              failure:(void (^)(NSError *error))failure;
/**
 *  商品列表
 *
 *  @param class
 *  @param sort
 *  @param page
 */
//+ (void)shangpinClass:(NSString*)class sort:(NSString*)sort page:(NSString*)page success:(void (^)(NSDictionary *responseObject))success
//failure:(void (^)(NSError *error))failure;
/**
 *  商品列表
 *
 *  @param name;
 
 */
+ (void)searchName:(NSString *)name sort:(NSString *)sort page:(NSString *)page success:(void (^)(NSDictionary *responseObject))success
           failure:(void (^)(NSError *error))failure;
/**
 *  发晒单
 *
 *  @param imgArr              <#imgArr description#>
 *  @param uid                 <#uid description#>
 *  @param titile              <#titile description#>
 *  @param info                <#info description#>
 *  @param shopiD              <#shopiD description#>
 *  @param qishu               <#qishu description#>
 *  @param success             <#success description#>
 *  @param failure             <#failure description#>
 *  @param uploadProgressBlock <#uploadProgressBlock description#>
 */

+ (void)userHeadImg:(NSArray *)imgArr anduid:(NSString *)uid andtitle:(NSString *)titile andinfo:(NSString *)info andshopID:(NSString *)shopiD andqishu:(NSString *)qishu
            success:(void (^)(NSDictionary *responseObject))success
            failure:(void (^)(NSError *error))failure   uploadProgressBlock:(void(^)(float uploadPercent,long long totalBytesWritten,long long totalBytesExpectedToWrite))uploadProgressBlock;
/**
 *  晒单详情
 *
 *  @param sdid    晒单id
 *  @param success success description
 *  @param failure <#failure description#>
 */
+ (void)SDXQ_sd_id:(NSString *)sdid success:(void (^)(NSDictionary *responseObject))success
           failure:(void (^)(NSError *error))failure;
/**
 *  评论
 *
 *  @param sdid    <#sdid description#>
 *  @param uid     <#uid description#>
 *  @param info    <#info description#>
 *  @param success <#success description#>
 *  @param failure <#failure description#>
 */
+(void)SDXQ_pinglu_sd_id:(NSString *)sdid anduid:(NSString *)uid andinfo:(NSString *)info success:(void (^)(NSDictionary *responseObject))success
                 failure:(void (^)(NSError *error))failure;
/**
 *  更改头像
 *
 *  @param imgArr              <#imgArr description#>
 *  @param uid                 <#uid description#>
 *  @param success             <#success description#>
 *  @param failure             <#failure description#>
 *  @param uploadProgressBlock <#uploadProgressBlock description#>
 */
+ (void)userHeadImg:(NSArray *)imgArr anduid:(NSString *)uid
            success:(void (^)(NSDictionary *responseObject))success
            failure:(void (^)(NSError *error))failure   uploadProgressBlock:(void(^)(float uploadPercent,long long totalBytesWritten,long long totalBytesExpectedToWrite))uploadProgressBlock;

/**
 *  商品详情
 *
 *  @param gid     商品id
 *  @param uid     uid
 *  @param sid     同期商品id
 *  @param qishu   期数
 *  @param success <#success description#>
 *  @param failure <#failure description#>
 */
+ (void)ShangPinXiangQing_gid:(NSString *)gid anduid:(NSString *)uid andsid:(NSString *)sid andqishu:(NSString*)qishu success:(void (^)(NSDictionary *responseObject))success failure:(void (^)(NSError *error))failure;
/**
 *  图文详情
 *
 *  @param gid     <#gid description#>
 *  @param success <#success description#>
 *  @param failure <#failure description#>
 */
+ (void)TuWenXiangQing_gid:(NSString *)gid success:(void (^)(NSDictionary *responseObject))success failure:(void (^)(NSError *error))failure;
/**
 *  计算
 *
 *  @param gid     <#gid description#>
 *  @param success <#success description#>
 *  @param failure <#failure description#>
 */
+ (void)jisuan_gid:(NSString *)gid success:(void (^)(NSDictionary *responseObject))success failure:(void (^)(NSError *error))failure;
/**
 *  商品详情评论
 *
 *  @param gid     <#gid description#>
 *  @param sid     <#sid description#>
 *  @param qishu   <#qishu description#>
 *  @param success <#success description#>
 *  @param failure <#failure description#>
 */
+ (void)XiangQingPingLun_gid:(NSString *)gid andpage:(NSString *)sid andqishu:(NSString*)qishu andPage:(NSString *)page success:(void (^)(NSDictionary *responseObject))success failure:(void (^)(NSError *error))failure;

+ (void)PersonalCenter_uid:(NSString *)uid success:(void (^)(NSDictionary *responseObject))success failure:(void (^)(NSError *error))failure;

+ (void)PersonalCenter_state:(NSInteger)state anduid:(NSString *)uid andpage:(NSInteger)page success:(void (^)(NSDictionary *responseObject))success failure:(void (^)(NSError *error))failure;

+ (void)reg_mobile:(NSString *)mobile success:(void(^)(NSDictionary *responseObject))success failure:(void(^)(NSError *error))failure;

+ (void)verify:(NSString *)verify andMobile:(NSString *)mobile andQQ:(NSString*)QQ success:(void(^)(NSDictionary*responseObject))success failure:(void(^)(NSError*error))failure;

+ (void)verifyXiuGai:(NSString *)verify andMobile:(NSString *)mobile success:(void(^)(NSDictionary*responseObject))success failure:(void(^)(NSError*error))failure;

+ (void)password:(NSString*)password andMobile:(NSString *)mobile success:(void(^)(NSDictionary*responseObject))success failure:(void(^)(NSError*error))failure;

+ (void)newPassword:(NSString*)password andMobile:(NSString *)mobile success:(void(^)(NSDictionary*responseObject))success failure:(void(^)(NSError*error))failure;
//搜索热门

+ (void)searchHotsuccess:(void (^)(NSDictionary *responseObject))success
                 failure:(void (^)(NSError *error))failure;
//首页十元
+ (void)shouYeTenpage:(NSString *)page success:(void (^)(NSDictionary *responseObject))success
              failure:(void (^)(NSError *error))failure;
//首页限时

+ (void)shouYeXSccess:(void (^)(NSDictionary *responseObject))success
              failure:(void (^)(NSError *error))failure;
//即将揭晓
+ (void)soonPublicPage:(NSString *)page success:(void (^)(NSDictionary *responseObject))success
               failure:(void (^)(NSError *error))failure;
//购物车信息
+ (void)buybuybuyid:(NSString *)gid success:(void (^)(NSDictionary *responseObject))success failure:(void (^)(NSError *error))failure;

//上传注册信息===============================
+(void)getZhuCe_username:(NSString*)username andpassword:(NSString *)password andnickname:(NSString *)nickname andsignature:(NSString *)signture success:(void (^)(NSDictionary *responseObject))success
                 failure:(void (^)(NSError *error))failure;
//上传登录信息===============================
+(void)getDengLu_username:(NSString*)username andpassword:(NSString *)password success:(void (^)(NSDictionary *responseObject))success
                  failure:(void (^)(NSError *error))failure;

#pragma mark --- 以下是泡果
///获取进入app的广告界面
+ (void)getIntoAppGuangGaoPage:(NSString *)page andLimit:(NSString *)limit sccess:(void (^)(NSDictionary *responseObject))success
                       failure:(void (^)(NSError *error))failure;
///获取头条新闻列表
+ (void)getTouTiaoListWithaccessToken:(NSString *)accessToken andPage:(NSString *)page andLimit:(NSString *)limit sccess:(void (^)(NSDictionary *responseObject))success
                              failure:(void (^)(NSError *error))failure;
/////根据频道id获取新闻列表
//+ (void)getNewsListWithID:(NSString *)ID andpage:(NSString *)page andlimit:(NSString *)limit sccess:(void (^)(NSDictionary *responseObject))success failure:(void(^)(NSError *error))failure;

//根据关键字获取推荐新闻列表
+ (void)getTuiJianWithKeyWords:(NSString *)keywords andaccessToken:(NSString *)accessToken andpage:(NSString *)page andlimit:(NSString *)limit sccess:(void (^)(NSDictionary *responseObject))success failure:(void(^)(NSError *error))failure;

/**
 *  	查询用户信息
 *  @param phonenumber 用户名<加密过的手机号码>(必填)：
 *  @param success     成功
 *  @param failure     错误
 */
+ (void)getUserInfoWithUserPhoneNumber:(NSString *)phonenumber
                                sccess:(void (^)(NSDictionary *responseObject))success
                               failure:(void(^)(NSError *error))failure;


///根据用户名密码获取当前登录用户信息
+ (void)getPaoGuoUserInfoWithUserName:(NSString *)accessToken andPassWord:(NSString *)password sccess:(void (^)(NSDictionary *responseObject))success failure:(void(^)(NSError *error))failure;

///修改用户信息上传
+ (void)postPaoGuoUserInfoWithUserName:(NSString *)accessToken andNiceName:(NSString *)nicename andSex:(NSString *)sex andSignature:(NSString  *)signature sccess:(void (^)(NSDictionary *responseObject))success failure:(void(^)(NSError *error))failure;
///获取节目列表
+ (void)postPaoGuoJieMuLieBiaoWithaccessToken:(NSString *)accessToken sccess:(void (^)(NSDictionary *responseObject))success failure:(void(^)(NSError *error))failure;

///获取自己关注的节目列表
+ (void)getPaoGuoSelfJieMuLieBiaoWithaccessToken:(NSString *)accessToken sccess:(void (^)(NSDictionary *responseObject))success failure:(void(^)(NSError *error))failure;

///获取我的节目列表
+ (void)getPaoGuoSelfWoDeJieMuWithaccessToken:(NSString *)accessToken andPage:(NSString *)page andLimit:(NSString *)limit sccess:(void (^)(NSDictionary *responseObject))success failure:(void (^)(NSError *error))failure;

///添加节目关注
+ (void)postPaoGuoAddJieMuGuanZhuWithaccessToken:(NSString *)accessToken andAct_id:(NSString *)act_id sccess:(void (^)(NSDictionary *responseObject))success failure:(void (^)(NSError *error))failure;

///取消节目关注
+ (void)postPaoGuoCancelJieMuGuanZhuWithaccessToken:(NSString *)accessToken andAct_id:(NSString *)act_id sccess:(void (^)(NSDictionary *responseObject))success failure:(void (^)(NSError *error))failure;

///获取应用推荐列表
+ (void)getPaoGuoYingYongTuiJianWithaccessToken:(NSString *)accessToken sccess:(void (^)(NSDictionary *responseObject))success failure:(void (^)(NSError *error))failure;

///获取关注列表列表
+ (void)getPaoGuoGuanZhuLieBiaoWithaccessToken:(NSString *)accessToken andPage:(NSString *)page andLimit:(NSString *)limit sccess:(void (^)(NSDictionary *responseObject))success failure:(void (^)(NSError *error))failure;

///根据用户user_login获取到用户信息
+ (void)getPaoGuoUserInfoWithuser_login:(NSString *)user_login sccess:(void (^)(NSDictionary *responseObject2))success failure:(void (^)(NSError *error))failure;

///根据用户user_login获取到用户更多信息
+ (void)getPaoGuoMoreUserInfoWithuser_login:(NSString *)user_login sccess:(void (^)(NSDictionary *responseObject2))success failure:(void (^)(NSError *error2))failure;

///根据用户token获取到用户好友动态更多信息
+ (void)getPaoGuoFriendDongTaiWithaccessToken:(NSString *)accessToken andPage:(NSString *)page andLimit:(NSString *)limit sccess:(void (^)(NSDictionary *responseObject))success failure:(void (^)(NSError *error))failure;

///根据用户token获取到用户好友评论动态更多信息
+ (void)getPaoGuoFriendPingLunWithaccessToken:(NSString *)accessToken andPage:(NSString *)page andLimit:(NSString *)limit sccess:(void (^)(NSDictionary *responseObject1))success failure:(void (^)(NSError *error1))failure;

///根据用户token获取到用户自己评论动态更多信息
+ (void)getPaoGuoSelfPingLunWithaccessToken:(NSString *)accessToken andPage:(NSString *)page andLimit:(NSString *)limit sccess:(void (^)(NSDictionary *responseObject2))success failure:(void (^)(NSError *error2))failure;
/**
 *  	我的个人主页新接口
 *
 *  @param accessToken accessToken description
 *  @param page        page
 *  @param limit       limit
 *  @param success     成功
 *  @param failure     错误
 */
+ (void)getMyDynamicsListWithaccessToken:(NSString *)accessToken
                                     login_uid:(NSString *)login_uid
                                    andPage:(NSString *)page
                                   andLimit:(NSString *)limit
                                     sccess:(void (^)(NSDictionary *responseObject))success
                                    failure:(void (^)(NSError *error))failure;

///根据用户token获取到用户自己关注列表
+ (void)getPaoGuoSelfGuanZhuLieBiaoWithaccessToken:(NSString *)accessToken andPage:(NSString *)page andLimit:(NSString *)limit sccess:(void (^)(NSDictionary *responseObject))success failure:(void (^)(NSError *error))failure;

///根据用户token获取到用户自己粉丝列表
+ (void)getPaoGuoSelfFenSiLieBiaoWithaccessToken:(NSString *)accessToken andPage:(NSString *)page andLimit:(NSString *)limit sccess:(void (^)(NSDictionary *responseObject))success failure:(void (^)(NSError *error))failure;

///根据用户token和要取消关注的用户id取消关注
+ (void)getPaoGuoCancelFriendWithaccessToken:(NSString *)accessToken anduid_2:(NSString *)uid_2 sccess:(void (^)(NSDictionary *responseObject))success failure:(void (^)(NSError *error))failure;

///根据用户token和要添加关注的用户id添加关注
+ (void)getPaoGuoAddFriendWithaccessToken:(NSString *)accessToken anduid_2:(NSString *)uid_2 sccess:(void (^)(NSDictionary *responseObject))success failure:(void (^)(NSError *error))failure;

///根据用户token和用户关键字获取推荐新闻
+ (void)getPaoGuoTuiJianNewsWithuid:(NSString *)uid andkeyword:(NSString *)keyword andPage:(NSString *)page andLimit:(NSString *)limit sccess:(void (^)(NSDictionary *responseObject))success failure:(void (^)(NSError *error))failure;


/**
 *  获取文章列表
 *
 *  @param accessToken accessToken
 *  @param term_id     文章分类ID
 *  @param keyword     标题,关键词,内容
 *  @param page        分页页码
 *  @param limit       每页显示条数 默认10条
 *  @param success     成功
 *  @param failure     失败
 */
+ (void)getPaoguoSearchNewsWithaccessToken:(NSString *)accessToken
                                   term_id:(NSString *)term_id
                                   keyword:(NSString *)keyword
                               andPage:(NSString *)page
                              andLimit:(NSString *)limit
                                sccess:(void (^)(NSDictionary *responseObject))success
                               failure:(void (^)(NSError *error))failure;

/**
 *  获取全部主播信息列表
 *
 *  @param an_id   主播ID
 *  @param keyword 标题、关键词、内容
 *  @param page    分页页码
 *  @param limit   每页显示条数
 *  @param success 成功
 *  @param failure 是吧
 */
+ (void)getAllAnchorInfoListWithan_id:(NSString *)an_id
                              keyword:(NSString *)keyword
                              andPage:(NSString *)page
                             andLimit:(NSString *)limit
                                    sccess:(void (^)(NSDictionary *responseObject))success
                              failure:(void (^)(NSError *error))failure;
/**
 *  获取全部节目信息列表
 *
 *  @param accessToken 用户accessToken
 *  @param ac_id       节目ID
 *  @param keyword     标题,关键词,内容
 *  @param page        分页页码
 *  @param limit       每页显示条数
 *  @param success     成功
 *  @param failure     失败
 */
+ (void)getAllActInfoListWithAccessToken:(NSString *)accessToken
                                   ac_id:(NSString *)ac_id
                                 keyword:(NSString *)keyword
                                 andPage:(NSString *)page
                                andLimit:(NSString *)limit
                                  sccess:(void (^)(NSDictionary *responseObject))success
                                 failure:(void (^)(NSError *error))failure;


///根据新闻ID获取新闻详细内容
+ (void)getPaoguoJieMuNeiRongWithJieMuID:(NSString *)post_id andPage:(NSString *)page andLimit:(NSString *)limit sccess:(void (^)(NSDictionary *responseObject))success failure:(void (^)(NSError *error))failure;

///根据新闻ID获取新闻评论列表
+ (void)getPaoGuoJieMuPingLunLieBiaoWithJieMuID:(NSString *)post_id anduid:(NSString *)uid andPage:(NSString *)page andLimit:(NSString *)limit sccess:(void (^)(NSDictionary *responseObject))success failure:(void (^)(NSError *error))failure;

/**
 *  新增评论(对指定文章内容的评论进行新增操作)
 *
 *  @param accessToken 用户名<加密过的用户名>
 *  @param to_uid      回复评论人的用户ID,默认为零 (必填)
 *  @param post_id     对应文章表中的id字段 (必填)：
 *  @param comment_id  当前评论的ID表中的ID字段 (非必填,回复评论时必填)：
 *  @param post_table  对应文章表的表名,去除前缀 (必填)：
 *  @param content     评论内容 (必填)：
 *  @param success     成功
 *  @param failure     错误
 */
+ (void)postPaoGuoXinWenPingLunWithaccessToken:(NSString *)accessToken
                                     andto_uid:(NSString *)to_uid
                                    andpost_id:(NSString *)post_id
                                 andcomment_id:(NSString *)comment_id
                                 andpost_table:(NSString *)post_table
                                    andcontent:(NSString *)content
                                        sccess:(void (^)(NSDictionary *responseObject))success
                                       failure:(void (^)(NSError *error))failure;


/**
 *  根据用户名以及评论ID针对新闻评论点赞
 *
 *  @param accessToken accessToken
 *  @param comments_id 当前评论ID
 *  @param success     成功
 *  @param failure     失败
 */
+ (void)postPaoGuoXinWenPingLunDianZanWithaccessToken:(NSString *)accessToken
                                            andact_id:(NSString *)act_id
                                               sccess:(void (^)(NSDictionary *responseObject))success
                                              failure:(void (^)(NSError *error))failure;
///根据填写的电话号码以及界面信息发送短信验证码
+ (void)postPaoGuoZhuCeYanZhengMaWithphoneFNumber:(NSString *)accessToken anduseType:(NSString *)useType sccess:(void (^)(NSDictionary *responseObject))success failure:(void (^)(NSError *error))failure;

///根据填写的密码以及电话号码以及验证码注册用户
+ (void)postPaoGuoZhuCeWithZhuCeAccessToken:(NSString *)accessToken andpassword:(NSString *)password anduser_nicename:(NSString *)user_nicename andvcode:(NSString *)vcode sccess:(void (^)(NSDictionary *responseObject))success failure:(void (^)(NSError *error))failure;

///首页搜索布局列表
+ (void)getPaoGuoShouYeSouSuoLieBiao:(NSString *)str sccess:(void (^)(NSDictionary *responseObject))success failure:(void (^)(NSError *error))failure;

///根据频道id获取新闻列表（新）
+ (void)getNewsListWithaccessToken:(NSString *)accessToken andID:(NSString *)ID andpage:(NSString *)page andlimit:(NSString *)limit sccess:(void (^)(NSDictionary *responseObject))success failure:(void(^)(NSError *error))failure;

///根据主播ID以及用户accessToken进行对主播的关注
+ (void)postPaoGuoGuanZhuWithaccessToken:(NSString *)accessToken andact_id:(NSString *)act_id sccess:(void (^)(NSDictionary *responseObject))success failure:(void (^)(NSError *error))failure;

///根据主播ID以及用户accessToken进行对主播的取消关注
+ (void)postPaoGuoQuXiaoGuanZhuWithaccessToken:(NSString *)accessToken andact_id:(NSString *)act_id sccess:(void (^)(NSDictionary *responseObject))success failure:(void (^)(NSError *error))failure;

///取到节目与主播分类相关信息
///找回密码时，填写正确的验证码后自动调用这个接口给用户发送短信随机密码
+ (void)postPaoGuoZhaoHuiMiMaGetSuiJiMiMaWithaccessToken:(NSString *)accessToken andvcode:(NSString *)vcode sccess:(void (^)(NSDictionary *responseObject))success failure:(void (^)(NSError *error))failure;

///修改密码，要上传用户名，旧密码，新密码
+ (void)postPaoGuoXiuGaiMiMaWithaccessToken:(NSString *)accessToken andopassword:(NSString *)opassword andpassword:(NSString *)password sccess:(void (^)(NSDictionary *responseObject))success failure:(void (^)(NSError *error))failure;

///根据主播或者节目ID获取详情新闻留言照片等等列表信息
+ (void)postPaoGuoZhuBoOrJieMuMessageWithID:(NSString *)an_id andpage:(NSString *)page andlimit:(NSString *)limit sccess:(void (^)(NSDictionary *responseObject))success failure:(void(^)(NSError *error))failure;

///	根据分类获取该分类下主播播报的新闻列表
+ (void)postPaoGuoFenLeiZhuBoBoBaoXinWenWithterm_id:(NSString *)term_id andpage:(NSString *)page andlimit:(NSString *)limit sccess:(void (^)(NSDictionary *responseObject))success failure:(void(^)(NSError *error))failure;

///	根据分类获取该分类下节目播报的新闻列表
+ (void)postPaoGuoFenLeiJieMuBoBaoXinWenWithterm_id:(NSString *)term_id andpage:(NSString *)page andlimit:(NSString *)limit sccess:(void (^)(NSDictionary *responseObject))success failure:(void(^)(NSError *error))failure;

///根据频道ID获取该频道下所有节目列表（主播的频道ID为0）
+ (void)getPaoguoJieMuLieBiaoWithterm_id:(NSString *)term_id
                          andaccessToken:(NSString *)accessToken
                                  sccess:(void (^)(NSDictionary *responseObject))success
                                 failure:(void(^)(NSError *error))failure;

/**
 *  获取主播、节目排行
 *
 *  @param term_id         昵称
 *  @param access_token 授权信息
 *  @param success      成功
 *  @param failure      失败
 */
+ (void)getFindList_goldWithterm_id:(NSString *)term_id
                     andaccessToken:(NSString *)accessToken
                             sccess:(void (^)(NSDictionary *responseObject))success
                            failure:(void(^)(NSError *error))failure;



//获取节目列表
+ (void)postPaoGuoJieMuLieBiaoWithKeyWord:(NSString *)keyword sccess:(void (^)(NSDictionary *responseObject))success failure:(void(^)(NSError *error))failure;

///获取总的分类列表
+ (void)getPaoGuoFenLeiLieBiaoWithWhateverSomething:(NSString *)Whatever
                                             sccess:(void (^)(NSDictionary *responseObject))success
                                            failure:(void(^)(NSError *error))failure;

///获取该频道下的幻灯片信息
+ (void)getPaoGuoPinDaoHuanDengPianXinXiWithterm_id:(NSString *)term_id
                                         andkeyword:(NSString *)keyword
                                             sccess:(void (^)(NSDictionary *responseObject))success
                                            failure:(void(^)(NSError *error))failure;
/**
 *  获取幻灯片广告列表
 *
 *  @param cat_idname 对应幻灯片表中的cat_idname字段 (必填)
 *  @param success    成功
 *  @param failure    错误
 */
+ (void)getSlideListWithcat_idname:(NSString *)cat_idname
                            sccess:(void (^)(NSDictionary *responseObject))success
                           failure:(void(^)(NSError *error))failure;
/**
 *  获取幻灯片广告列表
 *
 *  @param accessToken 对应幻灯片表中的accessToken字段 (必填)
 *  @param success    成功
 *  @param failure    错误
 */
+ (void)getNewSlideListWithaccessToken:(NSString *)accessToken
                                sccess:(void (^)(NSDictionary *responseObject))success
                               failure:(void(^)(NSError *error))failure;
///获取随机用户信息（推荐好友列表）
+ (void)getPaoGuoSuiJiYongHuXinXiWithaccessToken:(NSString *)accessToken andPage:(NSString *)page andLimit:(NSString *)limit sccess:(void (^)(NSDictionary *responseObject))success failure:(void(^)(NSError *error))failure;

///获取搜索用户信息列表
+ (void)getPaoGuosousuoYongHuXinXiLieBiaoWithaccessToken:(NSString *)accessToken
                                             andkeywords:(NSString *)keywords
                                                  sccess:(void (^)(NSDictionary *responseObject))success
                                                 failure:(void(^)(NSError *error))failure;

///获取主播或节目留言列表
+ (void)getPaoguoJieMuOrZhuBoPingLunLieBiaoWithact_id:(NSString *)act_id
                                              andpage:(NSString *)page
                                             andlimit:(NSString *)limit
                                               sccess:(void (^)(NSDictionary *responseObject))success
                                              failure:(void(^)(NSError *error))failure;

/**
 *  	第三方登录接口(自动绑定,未注册用户)
 *
 *  @param name         昵称
 *  @param head         头像地址
 *  @param type         来源：1.qq 2.微博 3.微信
 *  @param openid       唯一标识
 *  @param access_token 授权信息
 *  @param expires_in   授权有效时间
 *  @param success      成功
 *  @param failure      失败
 */
+ (void)postPaoGuoDiSanFangDengLuJieKouwithname:(NSString *)name
                                        andhead:(NSString *)head
                                        andtype:(int)type
                                      andopenid:(NSString *)openid
                                andaccess_token:(NSString *)access_token
                                  andexpires_in:(NSDate *)expires_in
                                         sccess:(void (^)(NSDictionary *responseObject))success
                                        failure:(void(^)(NSError *error))failure;
/**
 *  获取微博个人资料
 *
 *  @param getString  <#getString description#>
 *  @param parameters <#parameters description#>
 *  @param block      <#block description#>
 */
+ (void)netwokingGET:(NSString *)getString
       andParameters:(NSDictionary *)parameters
             success:(void (^)(id))block;

+ (void)GETWechatAccesstoken:(NSString *)getURL
               andParameters:(NSDictionary *)parameters
                     success:(void (^)(id))block;


/**
 *  给主播或者节目进行留言
 *
 *  @param accessToken 用户名<加密过的用户名>
 *  @param to_uid      回复评论人的用户ID,默认为零 (必填)
 *  @param act_id      对应节目表中的id字段 (必填)：
 *  @param comment_id  当前评论的ID表中的ID字段 (非必填,回复评论时必填)：
 *  @param act_table   对应节目表的表名,去除前缀 (必填)： 现在默认为 act
 *  @param content     评论内容
 *  @param success     成功
 *  @param failure     失败
 */
+ (void)postPaoGuoZhuBoOrJieMuLiuYanWithaccessToken:(NSString *)accessToken
                                          andto_uid:(NSString *)to_uid
                                          andact_id:(NSString *)act_id
                                      andcomment_id:(NSString *)comment_id
                                       andact_table:(NSString *)act_table
                                         andcontent:(NSString *)content
                                             sccess:(void (^)(NSDictionary *responseObject))success
                                            failure:(void(^)(NSError *error))failure;

/**
 *  根据分类、时间搜索下载
 *
 *  @param term_id    分类ID
 *  @param start_time 开始时间
 *  @param end_time   结束时间
 *  @param success    成功信息
 *  @param failure    错误信息
 */
+ (void)getDownloadNewsListWithterm_id:(NSString *)term_id
                            start_time:(NSString *)start_time
                              end_time:(NSString *)end_time
                                sccess:(void (^)(NSDictionary *))success
                               failure:(void (^)(NSError *))failure;

/**
 *  根据头条、时间搜索下载
 *
 *  @param term_id    头条ID
 *  @param start_time 开始时间
 *  @param end_time   结束时间
 *  @param success    成功信息
 *  @param failure    错误信息
 */
+ (void)getToutiaoDownloadNewsListWithkeyword:(NSString *)keyword
                                   start_time:(NSDate *)start_time
                                     end_time:(NSDate *)end_time
                                       sccess:(void (^)(NSDictionary *))success
                                      failure:(void (^)(NSError *))failure;


/**
 *  	<意见反馈>反馈信息列表
 *
 *  @param accessToken 登录后传
 *  @param page        默认为1
 *  @param limit       默认为10
 *  @param success     成功
 *  @param failure     错误
 */
+ (void)getFeedBackListWithaccessToken:(NSString *)accessToken
                               andpage:(NSString *)page
                               andlimit:(NSString *)limit
                               sccess:(void (^)(NSDictionary *responseObject))success
                               failure:(void(^)(NSError *error))failure;
/**
 *  <意见反馈>点赞
 *
 *  @param accessToken accessToken
 *  @param feedback_id 被点赞的那条反馈信息的ID
 *  @param success     成功
 *  @param failure     错误
 */
+ (void)addFeedbackZanWithaccessToken:(NSString *)accessToken
                               feedback_id:(NSString *)feedback_id
                                sccess:(void (^)(NSDictionary *responseObject))success
                               failure:(void(^)(NSError *error))failure;
/**
 *  <意见反馈>取消赞
 *
 *  @param accessToken accessToken
 *  @param feedback_id 被取消赞的那条反馈信息的ID
 *  @param success     成功
 *  @param failure     错误
 */
+ (void)delFeedbackZanWithaccessToken:(NSString *)accessToken
                          feedback_id:(NSString *)feedback_id
                               sccess:(void (^)(NSDictionary *responseObject))success
                              failure:(void(^)(NSError *error))failure;
/**
 *  <意见反馈>上传图片(支持多图)
 *
 *  @param accessToken 用户accessToken
 *  @param images      图片
 *  @param success     成功
 *  @param failure     错误
 */
+ (void)uploadImagesWithaccessToken:(NSString *)accessToken
                             images:(NSDictionary *)images
                             sccess:(void (^)(NSDictionary *responseObject))success
                            failure:(void(^)(NSError *error))failure;
/**
 *  <意见反馈>添加反馈信息
 *
 *  @param accessToken   用户accessToken
 *  @param tuid          用户评论的那条的用户ID(只在评论别人的时候需要传,否则(新建时)传0)
 *  @param to_comment_id 用户评论的那条的评论ID(只在评论别人的时候需要传,否则（新建时)传0)
 *  @param comment       评论内容
 *  @param images        图片(字符串逗号分隔)
 *  @param is_comment    是否是回复别人的：0:不是  1:是
 *  @param success       成功
 *  @param failure       错误
 */
+ (void)addfeedBackWithaccessToken:(NSString *)accessToken
                              tuid:(NSString *)tuid
                     to_comment_id:(NSString *)to_comment_id
                           comment:(NSString *)comment
                            images:(NSString *)images
                        is_comment:(NSString *)is_comment
                            sccess:(void (^)(NSDictionary *responseObject))success
                           failure:(void(^)(NSError *error))failure;

/**
 *  好友个人主页的评论列表
 *
 *  @param accessToken 好友的 user_login 加密生成的accesstoken
 *  @param page        分页页码
 *  @param limit       每页显示条数 默认10条
 *  @param success     成功
 *  @param failure     错误
 */
+ (void)getmyCommentListWithaccessToken:(NSString *)accessToken
                                andpage:(NSString *)page
                               andlimit:(NSString *)limit
                                 sccess:(void (^)(NSDictionary *responseObject))success
                                failure:(void(^)(NSError *error))failure;
/**
 *  获取文章内容信息,带文章评论及分页
 *
 *  @param post_id 文章表表中的id字段 (必填)：
 *  @param page    分页页码
 *  @param limit   每页显示条数 默认10条
 *  @param success 成功
 *  @param failure 错误
 */
+ (void)getpostinfoWithpost_id:(NSString *)post_id
                        andpage:(NSString *)page
                       andlimit:(NSString *)limit
                         sccess:(void (^)(NSDictionary *responseObject))success
                        failure:(void(^)(NSError *error))failure;

/**
 *  	查询客户端用户关键词
 *
 *  @param accessToken 用户名<加密过的用户名>
 *  @param success     成功
 *  @param failure     错误
 */
+ (void)getlistUserKeywordWithaccessToken:(NSString *)accessToken
                                   sccess:(void (^)(NSDictionary *responseObject))success
                                  failure:(void(^)(NSError *error))failure;
/**
 *  新增客户端用户关键词
 *
 *  @param accessToken 用户名<加密过的用户名>
 *  @param keyword     关键词
 *  @param success     成功
 *  @param failure     错误
 */
+ (void)addUserKeywordWithaccessToken:(NSString *)accessToken
                              keyword:(NSString *)keyword
                               sccess:(void (^)(NSDictionary *responseObject))success
                              failure:(void(^)(NSError *error))failure;
/**
 *  关键词频率+1
 *
 *  @param accessToken 用户名<加密过的用户名>
 *  @param k_id        当前关键词的ID
 *  @param success     成功
 *  @param failure     错误
 */
+ (void)frequencykeywordWithaccessToken:(NSString *)accessToken
                                   k_id:(NSString *)k_id
                                 sccess:(void (^)(NSDictionary *responseObject))success
                                failure:(void(^)(NSError *error))failure;
/**
 *  匹配通讯录好友
 *
 *  @param cellphone 通信录数组
 *  @param success   成功
 *  @param failure   失败
 */
+ (void)matchCellphoneWithcellphone:(NSString *)cellphone
                             sccess:(void (^)(NSDictionary *responseObject))success
                            failure:(void(^)(NSError *error))failure;
/**
 * 获取本地的城市列表
 *
 *  @param parameter 无参数（可随意填写一个）
 *  @param success   成功
 *  @param failure   错误
 */
+ (void)getPlaceListWithoutParameter:(NSString *)parameter
                              sccess:(void (^)(NSDictionary *responseObject))success
                             failure:(void(^)(NSError *error))failure;

/**
 *  删除新闻评论
 *
 *  @param accessToken accessToken description
 *  @param comment_id  评论ID
 *  @param success     成功
 *  @param failure     错误
 */
+ (void)delCommentWithaccessToken:(NSString *)accessToken
                       comment_id:(NSString *)comment_id
                           sccess:(void (^)(NSDictionary *responseObject))success
                          failure:(void(^)(NSError *error))failure;
/**
 *  删除节目评论
 *
 *  @param accessToken accessToken description
 *  @param act_id  评论ID
 *  @param success     成功
 *  @param failure     错误
 */
+ (void)delActWithaccessToken:(NSString *)accessToken
                       act_id:(NSString *)act_id
                       sccess:(void (^)(NSDictionary *responseObject))success
                      failure:(void(^)(NSError *error))failure;


/**
 *  	听友圈列表
 *
 *  @param accessToken accessToken description
 *  @param page        页码
 *  @param limit       每页显示条数 默认10条
 *  @param success     成功
 *  @param failure     错误信息
 */
+ (void)getLinsteningCircleListWithaccessToken:(NSString *)accessToken
                                       andpage:(NSString *)page
                                      andlimit:(NSString *)limit
                                        sccess:(void (^)(NSDictionary *responseObject))success
                                       failure:(void(^)(NSError *error))failure;

/**
 *  	针对新闻评论进行点赞 《点赞》
 *
 *  @param accessToken accessToken description
 *  @param userAccessToken userAccessToken description
 *  @param act_id      当前评论的ID：
 *  @param success     成功
 *  @param failure     错误
 */
+ (void)addAndCancelPraiseWithaccessToken:(NSString *)accessToken
                              comments_id:(NSString *)comments_id
                                   sccess:(void (^)(NSDictionary *responseObject))success
                                  failure:(void (^)(NSError *error))failure;

/**
 *  上传录音文件
 *
 *  @param accessToken accessToken description
 *  @param file        <#file description#>
 *  @param playtime    录音时长
 *  @param success     成功
 *  @param failure     错误
 */
+ (void)uploadMpVoiceWithaccessToken:(NSString *)accessToken
                                file:(NSString *)file
                            playtime:(NSString *)playtime
                              sccess:(void (^)(NSDictionary *responseObject))success
                             failure:(void (^)(NSError *error))failure;

/**
 *  听友圈内容发表及回复接口
 *
 *  @param accessToken accessToken
 *  @param to_uid      回复评论人的用户ID,默认为零 (必填)
 *  @param mp3_url     对应的语音信息(选填）
 *  @param playtime    对应的语音时长(选填)：
 *  @param timages     发表的图片(选填)：
 *  @param content     评论内容 (必填)：
 *  @param comment_id  当前评论的ID (非必填,回复评论时必填)：
 *  @param success     成功
 *  @param failure     错误
 */
+ (void)addLinsteningCircleWithaccessToken:(NSString *)accessToken
                                    to_uid:(NSString *)to_uid
                                    mp3_url:(NSString *)mp3_url
                                  play_time:(NSString *)play_time
                                   timages:(NSString *)timages
                                   content:(NSString *)content
                                comment_id:(NSString *)comment_id
                                    sccess:(void (^)(NSDictionary *responseObject))success
                                   failure:(void (^)(NSError *error))failure;
/**
 *  听友圈评论（对发表的内容评论）
 *
 *  @param accessToken accessToken description
 *  @param post_id     文章id (选填)
 *  @param to_uid      回复评论人的用户ID,默认为零 (必填)评论时为0  回复时传ID  
 *  @param comment_id  当前评论的ID(非必填,回复评论时必填)
 *  @param content     评论内容 (选填)
 *  @param success     成功
 *  @param failure     错误
 */
+ (void)addfriendDynamicsPingLunWithaccessToken:(NSString *)accessToken
                                        post_id:(NSString *)post_id
                                     comment_id:(NSString *)comment_id
                                         to_uid:(NSString *)to_uid
                                        content:(NSString *)content
                                         sccess:(void (^)(NSDictionary *responseObject))success
                                        failure:(void (^)(NSError *error))failure;
/**
 *  听友圈屏蔽接口
 *
 *  @param accessToken accessToken description
 *  @param to_uid      被屏蔽人的id (必填)
 *  @param success     成功
 *  @param failure     错误
 */
+ (void)pingbiLinsteningCircleWithaccessToken:(NSString *)accessToken
                                       to_uid:(NSString *)to_uid
                                       sccess:(void (^)(NSDictionary *responseObject))success
                                      failure:(void (^)(NSError *error))failure;
/**
 *  	听友圈投诉接口
 *
 *  @param accessToken accessToken description
 *  @param to_uid      被投诉人的id (必填)：
 *  @param comment_id  评论的id，表示在哪条评论上被投诉（必填）
 *  @param content     投诉的原因 (必填)：
 *  @param success     success
 *  @param failure     failure
 */
+ (void)tousuLinsteningCircleWithaccessToken:(NSString *)accessToken
                                      to_uid:(NSString *)to_uid
                                  comment_id:(NSString *)comment_id
                                     content:(NSString *)content
                                      sccess:(void (^)(NSDictionary *responseObject))success
                                     failure:(void (^)(NSError *error))failure;


/**
 *  获取用户好友动态的最新条数
 *
 *  @param accessToken accessToken description
 *  @param time        时间戳
 *  @param success     成功
 *  @param failure     错误
 */
+ (void)getAddcriticismNumWithaccessToken:(NSString *)accessToken
                                  andpage:(NSString *)page
                                 andlimit:(NSString *)limit
                                  anddate:(NSString *)date
                                   sccess:(void (^)(NSDictionary *responseObject))success
                                  failure:(void (^)(NSError *error))failure;

/**
 *  对我听友圈的回复
 *
 *  @param accessToken accessToken description
 *  @param page        页码
 *  @param limit       每页条数
 *  @param success     成功
 *  @param failure     错误
 */
+ (void)getNewPromptForMeWithaccessToken:(NSString *)accessToken
                                 andpage:(NSString *)page
                                andlimit:(NSString *)limit
                                  sccess:(void (^)(NSDictionary *responseObject))success
                                 failure:(void(^)(NSError *error))failure;

/**
 *  <意见反馈>获取对我评论的数据列表
 *
 *  @param accessToken accessToken description
 *  @param success     成功
 *  @param failure     错误
 */
+ (void)getFeedbackForMeWithaccessToken:(NSString *)accessToken
                                 sccess:(void (^)(NSDictionary *responseObject))success
                                failure:(void(^)(NSError *error))failure;

/**
 *  <意见反馈>根据意见ID获取这条意见的详细信息(包括这条意见下的评论)
 *
 *  @param accessToken accessToken description
 *  @param feedback_id 意见ID(如是子评论请传 to_comment_id字段的值)
 *  @param success     成功
 *  @param failure     错误
 */
+ (void)feedbackGetOneWithaccessToken:(NSString *)accessToken
                          feedback_id:(NSString *)feedback_id
                               sccess:(void (^)(NSDictionary *responseObject))success
                              failure:(void(^)(NSError *error))failure;
/**
 *  获取这条未读听友圈的详细信息
 *
 *  @param accessToken accessToken description
 *  @param parentid    父类ID
 *  @param path        path description
 *  @param success     成功
 *  @param failure     错误
 */
+ (void)newPromptGetOneWithaccessToken:(NSString *)accessToken
                              parentid:(NSString *)parentid
                                  path:(NSString *)path
                               sccess:(void (^)(NSDictionary *responseObject))success
                              failure:(void(^)(NSError *error))failure;
/**
 *  根据post_id获取新闻内容,文章所属主播/节目的信息，主播/节目的打赏榜单，金币的金额（在post表中增加文章被打赏的金币值） 评论数
 *
 *  @param accessToken accessToken description
 *  @param post_id    文章ID
 *  @param success     成功
 *  @param failure     错误
 */
+ (void)getPostDetailWithaccessToken:(NSString *)accessToken
                             post_id:(NSString *)post_id
                              sccess:(void (^)(NSDictionary *responseObject))success
                             failure:(void(^)(NSError *error))failure;

/**
 *  赏谢榜
 *
 *  @param accessToken accessToken description
 *  @param post_id    节目ID（必填）
 *  @param act_id    节目ID（必填）
 *  @param success     成功
 *  @param failure     错误
 */
+ (void)getAwardListWithaccessToken:(NSString *)accessToken
                            post_id:(NSString *)post_id
                             act_id:(NSString *)act_id
                             sccess:(void (^)(NSDictionary *responseObject))success
                            failure:(void(^)(NSError *error))failure;


/**
 *  查看听币余额
 *
 *  @param accessToken accessToken description
 *  @param success     成功
 *  @param failure     错误
 */
+ (void)getListenMoneyWithaccessToken:(NSString *)accessToken
                               sccess:(void (^)(NSDictionary *responseObject))success
                              failure:(void(^)(NSError *error))failure;
/**
 *  支付宝、微信支付成功之后保存信息
 *
 *  @param uid 用户id
 *  @param trade_id 订单id
 *  @param type 来源:0微信 1支付宝
 *  @param total_fees 支付金额
 *  @param Ratetime 支付时间
 *  @param success     成功
 *  @param failure     错误
 */
+ (void)uploadzhinewWithuid:(NSString *)uid
                   trade_id:(NSString *)trade_id
                       tpye:(NSString *)type
                 total_fees:(NSString *)total_fees
                   Ratetime:(NSString *)Ratetime
                     sccess:(void (^)(NSDictionary *responseObject))success
                    failure:(void(^)(NSError *error))failure;


//获取微信支付订单信息
+ (void)netwokingPostZhiFu:(NSString *)postString
             andParameters:(NSDictionary *)parameters
                   success:(void (^)(id))block
                   failure:(void (^)())blockFailure;

/**
 *  听币或现金打赏主播或者节目
 *
 *  @param accessToken      accessToken
 *  @param listen_money     打赏的金额 (必填)
 *  @param act_id           被打赏的主播/节目的id(必填)
 *  @param post_id          被打赏的文章id
 *  @param type             打赏的方式，听币为1，现金为2(必填)
 *  @param success          成功
 *  @param failure          错误
 */
+ (void)listenMoneyRechargeWithaccessToken:(NSString *)accessToken
                              listen_money:(NSString *)listen_money
                                    act_id:(NSString *)act_id
                                   post_id:(NSString *)post_id
                                      type:(NSString *)type
                                    sccess:(void (^)(NSDictionary *responseObject))success
                                   failure:(void(^)(NSError *error))failure;


/**
 *  听币或现金打赏成功后的留言
 *
 *  @param accessToken      accessToken
 *  @param act_id           被打赏的主播/节目的id(必填)
 *  @param message          留言内容
 *  @param success          成功
 *  @param failure          错误
 */
+ (void)rewardedMessageWithaccessToken:(NSString *)accessToken
                                act_id:(NSString *)act_id
                               message:(NSString *)message
                                sccess:(void (^)(NSDictionary *responseObject))success
                               failure:(void(^)(NSError *error))failure;

/**
 *  获取我订阅的节目/主播
 *
 *  @param accessToken      accessToken
 *  @param limit           limit
 *  @param success          成功
 *  @param failure          错误
 */
+ (void)getMySubscribeWithaccessToken:(NSString *)accessToken
                                limit:(NSString *)limit
                               sccess:(void (^)(NSDictionary *responseObject))success
                              failure:(void(^)(NSError *error))failure;

/**
 *  获取个人经验值，听币，金币,签到情况以及个人信息，粉丝数，关注数
 接口标识
 *
 *  @param accessToken      accessToken
 *  @param user_id          用户id(选填)
 *  @param success          成功
 *  @param failure          错误
 */
+ (void)getMyuserinfoWithaccessToken:(NSString *)accessToken
                             user_id:(NSString *)user_id
                              sccess:(void (^)(NSDictionary *responseObject))success
                             failure:(void(^)(NSError *error))failure;
/**
 *  听币充值赠送的相应值
 *  @param success          成功
 *  @param failure          错误
 */
+ (void)signInWithaccessToken:(NSString *)accessToken
                       sccess:(void (^)(NSDictionary *responseObject))success
                      failure:(void(^)(NSError *error))failure;

/**
 *  签到
 *
 *  @param accessToken      accessToken
 *  @param success          成功
 *  @param failure          错误
 */

+ (void)getZs_lisMoneySccess:(void (^)(NSDictionary *responseObject))success
                     failure:(void(^)(NSError *error))failure;

/**
 *  听币充值
 *
 *  @param accessToken      accessToken
 *  @param listen_money     充值的金额 (必填)：
 *  @param type             充值的方式 1：微信 2：支付宝 3：银联(必填)
 *  @param success          成功
 *  @param failure          错误
 */

+ (void)listenMoneyRechargeWithaccessToken:(NSString *)accessToken
                              listen_money:(NSString *)listen_money
                                      type:(NSString *)type
                                    sccess:(void (^)(NSDictionary *responseObject))success
                                   failure:(void(^)(NSError *error))failure;


/**
 *  消费记录
 *
 *  @param accessToken      accessToken
 *  @param success          成功
 *  @param failure          错误
 */

+ (void)use_recordWithaccessToken:(NSString *)accessToken
                           sccess:(void (^)(NSDictionary *responseObject))success
                          failure:(void(^)(NSError *error))failure;
/**
 *  充值记录
 *
 *  @param accessToken      accessToken
 *  @param success          成功
 *  @param failure          错误
 */
+ (void)recharge_recordWithaccessToken:(NSString *)accessToken
                                sccess:(void (^)(NSDictionary *responseObject))success
                               failure:(void(^)(NSError *error))failure;

/**
 *  金币打赏文章
 *
 *  @param accessToken      accessToken
 *  @param act_id           被打赏的主播/节目的id(必填)
 *  @param post_id          被打赏的文章id
 *  @param success          成功
 *  @param failure          错误
 */
+ (void)goldUseWithaccessToken:(NSString *)accessToken
                        act_id:(NSString *)act_id
                       post_id:(NSString *)post_id
                        sccess:(void (^)(NSDictionary *responseObject))success
                       failure:(void(^)(NSError *error))failure;

/**
 *  粉丝榜
 *
 *  @param act_id           主播/节目的id(必填)
 *  @param success          成功
 *  @param failure          错误
 */
+ (void)getFan_boardWithact_id:(NSString *)act_id
                        sccess:(void (^)(NSDictionary *responseObject))success
                       failure:(void(^)(NSError *error))failure;

/**
 *  	赏谢榜、粉丝榜
 *
 *  @param accessToken      accessToken
 *  @param act_id           主播/节目的id(必填)
 *  @param success          成功
 *  @param failure          错误
 */
+ (void)getZan_boardWithaccessToken:(NSString *)accessToken
                             act_id:(NSString *)act_id
                             sccess:(void (^)(NSDictionary *responseObject))success
                            failure:(void(^)(NSError *error))failure;

/**
 *  版本号  通过判断版本号，确定走内购还是 支付宝/微信支付
 *
 *  @param success          成功
 *  @param failure          错误
 */
+ (void)getAppVersionSccess:(void (^)(NSDictionary *responseObject))success
                    failure:(void(^)(NSError *error))failure;


/**
 *  	添加新闻收藏
 *
 *  @param accessToken      accessToken
 *  @param act_id           新闻id(必填)
 *  @param success          成功
 *  @param failure          错误
 */
+ (void)collectionPostNewsWithaccessToken:(NSString *)accessToken
                                  post_id:(NSString *)post_id
                                   sccess:(void (^)(NSDictionary *responseObject))success
                                  failure:(void(^)(NSError *error))failure;


/**
 *  获取用户收藏的新闻列表
 *
 *  @param accessToken      accessToken
 *  @param success          成功
 *  @param failure          错误
 */
+ (void)get_collectionWithaccessToken:(NSString *)accessToken
                               sccess:(void (^)(NSDictionary *responseObject))success
                              failure:(void(^)(NSError *error))failure;

/**
 *  	删除/取消新闻收藏
 *
 *  @param accessToken      accessToken
 *  @param act_id           新闻id(必填)
 *  @param success          成功
 *  @param failure          错误
 */
+ (void)del_collectionWithaccessToken:(NSString *)accessToken
                              post_id:(NSString *)post_id
                               sccess:(void (^)(NSDictionary *responseObject))success
                              failure:(void(^)(NSError *error))failure;
//通过code获取微信授权的个人信息
+ (void)getWechatAccess_tokenWithSSOCode:(NSString *)code
                                 success:(void (^)(NSDictionary *responseObject))success
                                failture:(void(^)(NSError *error))failure;

/**
 *  	获取栏目新闻列表数据
 *
 *  @param accessToken      accessToken
 *  @param page             页码（默认为1）
 *  @param limit            每页条数（默认为10条
 *  @param success          成功
 *  @param failure          错误
 */
+ (void)getColumnListWithaccessToken:(NSString *)accessToken
                             andPage:(NSString *)page
                            andLimit:(NSString *)limit
                              sccess:(void (^)(NSDictionary *responseObject))success
                             failure:(void (^)(NSError *error))failure;
/**
 *  	获取快讯新闻列表数据
 *
 *  @param accessToken      accessToken
 *  @param page             页码（默认为1）
 *  @param limit            每页条数（默认为10条
 *  @param success          成功
 *  @param failure          错误
 */
+ (void)getInformationListWithaccessToken:(NSString *)accessToken
                                  andPage:(NSString *)page
                                 andLimit:(NSString *)limit
                                   sccess:(void (^)(NSDictionary *responseObject))success
                                  failure:(void (^)(NSError *error))failure;
/**
 *  	获取听闻课堂列表列表数据
 *
 *  @param accessToken      accessToken
 *  @param page             页码（默认为1）
 *  @param limit            每页条数（默认为10条
 *  @param success          成功
 *  @param failure          错误
 */
+ (void)getClassroomListWithaccessToken:(NSString *)accessToken
                                andPage:(NSString *)page
                               andLimit:(NSString *)limit
                                 sccess:(void (^)(NSDictionary *responseObject))success
                                failure:(void (^)(NSError *error))failure;

/**
 *  	获取指定节目的试听详情
 *
 *  @param accessToken      accessToken
 *  @param act_id           课堂id
 *  @param success          成功
 *  @param failure          错误
 */
+ (void)getAuditionListWithaccessToken:(NSString *)accessToken
                                act_id:(NSString *)act_id
                                 sccess:(void (^)(NSDictionary *responseObject))success
                                failure:(void (^)(NSError *error))failure;

/**
 *  	获取用户对该节目的订单
 *
 *  @param accessToken      accessToken
 *  @param act_id           主播或节目id (必填)
 *  @param success          成功
 *  @param failure          错误
 */
+ (void)get_orderWithaccessToken:(NSString *)accessToken
                          act_id:(NSString *)act_id
                          sccess:(void (^)(NSDictionary *responseObject))success
                         failure:(void (^)(NSError *error))failure;
/**
 *  	听币购买界面调用
 *
 *  @param accessToken      accessToken
 *  @param act_id           主播或节目id (必填)
 *  @param money           订单金额 (必填)
 *  @param success          成功
 *  @param failure          错误
 */
+ (void)buyActWithaccessToken:(NSString *)accessToken
                       act_id:(NSString *)act_id
                        money:(NSString *)money
                       sccess:(void (^)(NSDictionary *responseObject))success
                      failure:(void (^)(NSError *error))failure;
/**
 *  	购买节目成功调用上传订单
 *
 *  @param accessToken      accessToken
 *  @param order_num           订单号 (必填)
 *  @param success          成功
 *  @param failure          错误
 */
+ (void)order_notifyWithaccessToken:(NSString *)accessToken
                             order_num:(NSString *)order_num
                             sccess:(void (^)(NSDictionary *responseObject))success
                            failure:(void (^)(NSError *error))failure;
/**
 *  	删除用户自己的评论
 *
 *  @param accessToken      accessToken
 *  @param comment_id           评论id (必填)
 *  @param success          成功
 *  @param failure          错误
 */
+ (void)postDeleteSelfCommentWithaccessToken:(NSString *)accessToken
                                  commnet_id:(NSString *)comment_id
                                      sccess:(void (^)(NSDictionary *responseObject))success
                                     failure:(void(^)(NSError *error))failure;
@end

