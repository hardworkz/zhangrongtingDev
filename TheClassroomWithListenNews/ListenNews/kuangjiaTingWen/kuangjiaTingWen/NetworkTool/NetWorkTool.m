//
//  AppDelegate.m
//  1yqb
//
//  Created by 曲天白 on 15/12/11.
//  Copyright © 2015年 乙科网络. All rights reserved.
//

#import "NetWorkTool.h"
#import "AFNetworking.h"

@implementation NetWorkTool

//将NSDictionary中的Null类型的项目转化成@""
+(NSDictionary *)nullDic:(NSDictionary *)myDic{
    NSArray *keyArr = [myDic allKeys];
    NSMutableDictionary *resDic = [[NSMutableDictionary alloc]init];
    for (int i = 0; i < keyArr.count; i ++)
    {
        id obj = [myDic objectForKey:keyArr[i]];
        
        obj = [self changeType:obj];
        
        [resDic setObject:obj forKey:keyArr[i]];
    }
    return resDic;
}

//将NSArray中的Null类型的项目转化成@""
+(NSArray *)nullArr:(NSArray *)myArr
{
    NSMutableArray *resArr = [[NSMutableArray alloc] init];
    for (int i = 0; i < myArr.count; i ++)
    {
        id obj = myArr[i];
        
        obj = [self changeType:obj];
        
        [resArr addObject:obj];
    }
    return resArr;
}

//将NSString类型的原路返回
+(NSString *)stringToString:(NSString *)string
{
    return string;
}

//将Null类型的项目转化成@""
+(NSString *)nullToString
{
    return @"";
}

#pragma mark - 公有方法
//类型识别:将所有的NSNull类型转化成@""
+(id)changeType:(id)myObj
{
    if ([myObj isKindOfClass:[NSDictionary class]])
    {
        return [self nullDic:myObj];
    }
    else if([myObj isKindOfClass:[NSArray class]])
    {
        return [self nullArr:myObj];
    }
    else if([myObj isKindOfClass:[NSString class]])
    {
        return [self stringToString:myObj];
    }
    else if([myObj isKindOfClass:[NSNull class]])
    {
        return [self nullToString];
    }
    else
    {
        return myObj;
    }
}
/**
 *  数组转json
 *
 *  @param arr 数组
 *
 *  @return 数组json
 */
+ (NSString *)NSArrayTojson:(NSArray *)arr{
    NSError *parseError   = nil;
    
    NSData *jsonData      = [NSJSONSerialization dataWithJSONObject:arr options:NSJSONWritingPrettyPrinted error:&parseError];
    return [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
}
/**
 *  json 转 字典
 *
 *  @param jsonStr json
 *
 *  @return 数组
 */
+ (NSDictionary *)dictionaryWithJsonString:(NSString *)jsonStr{
    if (jsonStr == nil) {
        return nil;
    }
    NSData *jsonData      = [jsonStr dataUsingEncoding:NSUTF8StringEncoding];
    NSError *error;
    NSDictionary *dic     = [NSJSONSerialization JSONObjectWithData:jsonData options:NSJSONReadingMutableContainers error:&error];
    return dic;
}
/**
 * 字典转json
 */
+ (NSString*)dictionaryToJson:(NSDictionary *)dic {
    
    NSError *parseError   = nil;
    
    NSData *jsonData      = [NSJSONSerialization dataWithJSONObject:dic options:NSJSONWritingPrettyPrinted error:&parseError];
    
    return [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
    
}
/**
 *  json 转 数组
 *
 *  @param jsonStr json
 *
 *  @return 数组
 */
+(NSArray *)arrayWithjsonString:(NSString *)jsonStr{
    if (jsonStr == nil) {
        return nil;
    }
    NSData *jsonData      = [jsonStr dataUsingEncoding:NSUTF8StringEncoding];
    NSError *error;
    NSArray *arr          = [NSJSONSerialization JSONObjectWithData:jsonData options:NSJSONReadingMutableContainers error:&error];
    return arr;
}
/**
 *  便利加载网络图片
 *
 *  @param imagV       图片容器
 *  @param imageUrlStr 图片地址字符串
// */
//+(void)imageWithImagView:(UIImageView *)imagV andImageUrlStr :(NSString *)imageUrlStr {
//    
//    NSString *completeUrl = [NSString stringWithFormat:@"%@%@", MAIN_URL,imageUrlStr];
//    NSURL *url            = [NSURL URLWithString:completeUrl];
//    [imagV sd_setImageWithURL:url];
//    
//}

+(void)syncNetworkingUrl:(NSString *)url
                 andDict:(NSDictionary *)param
                 success:(void (^)(NSDictionary *responseObject))success
                 failure:(void (^)(NSError *error))failure{
    //请求管理者
    AFHTTPRequestOperationManager *mgr    = [AFHTTPRequestOperationManager manager];
    
    //修改afn 支持新浪返回的JSON结构
    mgr.requestSerializer                 = [AFHTTPRequestSerializer serializer ];
    mgr.responseSerializer                = [AFJSONResponseSerializer serializer];
    [mgr.requestSerializer willChangeValueForKey:@"timeoutInterval"];
    mgr.requestSerializer.timeoutInterval = 8;
    [mgr.requestSerializer didChangeValueForKey:@"timeoutInterval"];
    NSString *urlStr=[NSString stringWithFormat:@"%@",url];
    //发送请求
    [mgr GET:urlStr parameters:param success:^(AFHTTPRequestOperation *operation, NSDictionary* responseObject) {
        
        //数据保护
        if (responseObject != nil) {
            NSLog(@"获取成功");
            dispatch_async(dispatch_get_main_queue(), ^{
                success([self changeType:responseObject]); //成功回调
            });
            
            return ;
        }
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"获取失败");
        
        dispatch_async(dispatch_get_main_queue(), ^{
            failure(error);//失败回调
        });
        
    }];
}
///**
// * 异步网络请求数据
// * @param：网络请求参数字典
// * @success：请求成功回调代码块
// * @fail:请求失败回调代码块
// */
+(void)asyncNetworkingUrl:(NSString *)url
                  andDict:(NSDictionary *)param
                  success:(void (^)(NSDictionary *responseObject))success
                  failure:(void (^)(NSError *error))failure{
    
    //请求管理者
    AFHTTPRequestOperationManager *mgr    = [AFHTTPRequestOperationManager manager];
    
    //修改afn 支持新浪返回的JSON结构
    mgr.requestSerializer                 = [AFHTTPRequestSerializer serializer ];
    mgr.responseSerializer                = [AFJSONResponseSerializer serializer];
    [mgr.requestSerializer willChangeValueForKey:@"timeoutInterval"];
    mgr.requestSerializer.timeoutInterval = 8;
    [mgr.requestSerializer didChangeValueForKey:@"timeoutInterval"];
    NSString *urlStr=[NSString stringWithFormat:@"%@%@",APPHostURL,url];
    //发送请求
    [mgr POST:urlStr parameters:param success:^(AFHTTPRequestOperation *operation, NSDictionary* responseObject) {
        //数据保护
        if (responseObject != nil) {
            NSLog(@"获取成功");
            dispatch_async(dispatch_get_main_queue(), ^{
                success([self changeType:responseObject]); //成功回调
             });
            
            return ;
        }
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"获取失败");
        
        dispatch_async(dispatch_get_main_queue(), ^{
            failure(error);//失败回调
        });
    
    }];
}
/**
 *  登录
 *
 *  @param mobile   用户注册手机
 *  @param email    用户注册邮箱
 *  @param password 用户密码
 *  @param success  成功responseObject
 *  @param failure  失败error
 */
+(void)login_mobile:(NSString *)mobile andlogin_email:(NSString *)email andlogin_password:(NSString *)password andpw:(NSString *)pw success:(void (^)(NSDictionary *))success failure:(void (^)(NSError *))failure
{
    NSMutableDictionary *dic = [[NSMutableDictionary alloc]initWithCapacity:1];
    
    dic[@"login_mobile"]     = mobile;
    dic[@"login_email"]      = email;
    dic[@"login_password"]   = password;
    dic[@"password"] = pw;
    
    
    [self asyncNetworkingUrl:@"/User/Login/" andDict:dic success:success failure:failure];
}
/**
 *  获取用户信息
 *
 *  @param uid     uid
 *  @param success 成功responseObject
 *  @param failure 失败error
 */
+(void)GetUserInFo_uid:(NSString *)uid success:(void (^)(NSDictionary *))success failure:(void (^)(NSError *))failure{
    NSMutableDictionary *dic = [[NSMutableDictionary alloc]initWithCapacity:1];
    
    dic[@"uid"]= uid;
    [self asyncNetworkingUrl:@"/User/Setting" andDict:dic success:success failure:failure];
    
}
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
+(void)SetUserInFo_uid:(NSString *)uid andUseremail:(NSString *)email andUserQianMing:(NSString *)qianming andUserName:(NSString *)name andUserQQ:(NSString *)qq success:(void (^)(NSDictionary *))success failure:(void (^)(NSError *))failure{
    NSMutableDictionary *dic = [[NSMutableDictionary alloc]initWithCapacity:1];
    dic[@"uid"]= uid;
    dic[@"email"]    = email;
    dic[@"qianming"] = qianming;
    dic[@"username"] = name;
    dic[@"qq"] = qq;
    [self asyncNetworkingUrl:@"/User/Setting/set" andDict:dic success:success failure:failure];
}
/**
 *  签到
 *
 *  @param uid     uid
 *  @param success 成功responseObject
 *  @param failure 失败error
 */
+(void)Sign_uid:(NSString *)uid andState:(NSString *)str success:(void (^)(NSDictionary *))success failure:(void (^)(NSError *))failure{
    NSMutableDictionary *dic = [[NSMutableDictionary alloc]initWithCapacity:1];
    dic[@"uid"]= uid;
    dic[@"action"] = str ;
    [self asyncNetworkingUrl:@"/User/Sign" andDict:dic success:success failure:failure];
}
/**
 *  获取收货地址列表
 *
 *  @param uid     uid
 *  @param success 成功responseObject
 *  @param failure 失败error
 */
+(void)Address_uid:(NSString *)uid success:(void (^)(NSDictionary *))success failure:(void (^)(NSError *))failure{
    NSMutableDictionary *dic = [[NSMutableDictionary alloc]initWithCapacity:1];
    dic[@"uid"]= uid;
    [self asyncNetworkingUrl:@"/User/Address/addresslist" andDict:dic success:success failure:failure];
}
+(void)Getcity_uid:(NSString *)uid success:(void (^)(NSDictionary *))success failure:(void (^)(NSError *))failure{
    [self asyncNetworkingUrl:@"/User/Address/GetAddessJson" andDict:nil success:success failure:failure];
    
}
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
+(void)Addaddress_uid:(NSString *)uid andSheng:(NSString *)sheng andShi:(NSString *)shi andQu:(NSString *)qu andinfo:(NSString *)info andYouBian:(NSString *)youbian andShouJianRen:(NSString *)shoujianren andmobile:(NSString *)mobile andTell:(NSString *)tell success:(void (^)(NSDictionary *))success failure:(void (^)(NSError *))failure{
    NSMutableDictionary *dic = [[NSMutableDictionary alloc]initWithCapacity:1];
    dic[@"uid"]= uid;
    dic[@"sheng"] = sheng;
    dic[@"shi"] = shi;
    dic[@"xian"] = qu;
    dic[@"jiedao"] = info;
    dic[@"youbian"] = youbian;
    dic[@"shouhuoren"] = shoujianren;
    dic[@"mobile"] = mobile;
    dic[@"tell"] = tell;
    [self asyncNetworkingUrl:@"/User/Address" andDict:dic success:success failure:failure];
    
}
/**
 *  修改收货地址（设置默认、删除）
 *
 *  @param uid     uid
 *  @param Id      地址id
 *  @param action  动作
 *  @param success 成功
 *  @param failure 失败
 */
+(void)SetAddress_uid:(NSString *)uid andadressID:(NSString *)Id andAction:(NSString *)action success:(void (^)(NSDictionary *))success failure:(void (^)(NSError *))failure{
    NSMutableDictionary*dic = [[NSMutableDictionary alloc]initWithCapacity:1];
    dic[@"uid"] = uid;
    dic[@"id"] = Id;
    if ([action isEqualToString:@"2"]) {
        dic[@"action"] = @"del";
    }
    else if ([action isEqualToString:@"0"]) {
        dic[@"action"] = @"setdef";
    }
    [self asyncNetworkingUrl:@"/User/Address/addresscontrol" andDict:dic success:success failure:failure];
    
}
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
+(void)BianJiaddress_uid:(NSString *)uid andAddId:(NSString *)addId andSheng:(NSString *)sheng andShi:(NSString *)shi andQu:(NSString *)qu andinfo:(NSString *)info andYouBian:(NSString *)youbian andShouJianRen:(NSString *)shoujianren andmobile:(NSString *)mobile andTell:(NSString *)tell success:(void (^)(NSDictionary *))success failure:(void (^)(NSError *))failure{
    
    NSMutableDictionary *dic = [[NSMutableDictionary alloc]initWithCapacity:1];
    dic[@"uid"]= uid;
    dic[@"id"] = addId;
    dic[@"sheng"] = sheng;
    dic[@"shi"] = shi;
    dic[@"xian"] = qu;
    dic[@"jiedao"] = info;
    dic[@"youbian"] = youbian;
    dic[@"shouhuoren"] = shoujianren;
    dic[@"mobile"] = mobile;
    dic[@"tell"] = tell;
    [self asyncNetworkingUrl:@"/User/Address/addressedit" andDict:dic success:success failure:failure];
    
}
/**
 *  获取账户明细
 *
 *  @param uid     uid
 *  @param type    获取种类
 *  @param page    页数
 *  @param success 成功
 *  @param failure 失败
 */
+(void)MoneyDetial_uid:(NSString *)uid andtype:(NSString *)type andpage:(NSString *)page success:(void (^)(NSDictionary *))success failure:(void (^)(NSError *))failure{
    NSMutableDictionary *dic = [[NSMutableDictionary alloc]initWithCapacity:1];
    dic[@"uid"] = uid ;
    dic[@"type"] = type;
    dic[@"page"] = page;
    [self asyncNetworkingUrl:@"/User/Accountlist" andDict:dic success:success failure:failure];
}
/**
 *  抢宝记录
 *
 *  @param uid     uid
 *  @param index   当前分类
 *  @param page    页数
 *  @param success 成功
 *  @param failure 失败
 */
+(void)GetBaoDetial_uid:(NSString *)uid andtypeIndex:(NSString *)index andpage:(NSString *)page success:(void (^)(NSDictionary *))success failure:(void (^)(NSError *))failure{
    NSMutableDictionary*dic = [[NSMutableDictionary alloc]initWithCapacity:1];
    dic[@"uid"] = uid;
    dic[@"page"] = page;
    if ([index intValue] == 0) {
        [self asyncNetworkingUrl:@"/User/Qiangbaolist" andDict:dic success:success failure:failure];
    }else if ([index intValue] == 1){
        [self asyncNetworkingUrl:@"/User/Qiangbaolist/Going" andDict:dic success:success failure:failure];
    }else{
        [self asyncNetworkingUrl:@"/User/Qiangbaolist/Publish" andDict:dic success:success failure:failure];
    }
    
}
/**
 *  获得宝物纪录
 *
 *  @param uid     uid
 *  @param success 成功
 *  @param failure 失败
 */
+(void)BaoDetial_uid:(NSString *)uid success:(void (^)(NSDictionary *))success failure:(void (^)(NSError *))failure{
    
    NSMutableDictionary *dic = [[NSMutableDictionary alloc]initWithCapacity:1];
    dic[@"uid"] = @"39";
    [self asyncNetworkingUrl:@"/User/Orderlist" andDict:dic success:success failure:failure];
    
}
/**
 *  塞单
 *
 *  @param uid     <#uid description#>
 *  @param success <#success description#>
 *  @param failure <#failure description#>
 */
+(void)sandan_uid:(NSString *)uid success:(void (^)(NSDictionary *responseObject))success
          failure:(void (^)(NSError *error))failure{
    
    NSMutableDictionary *dic = [[NSMutableDictionary alloc]initWithCapacity:1];
    dic[@"uid"] = uid;
    [self asyncNetworkingUrl:@"/User/Orderlist/shaidan" andDict:dic success:success failure:failure];

}

+(void)QBsandan_page:(NSString *)page andsid:(NSString *)sid success:(void (^)(NSDictionary *responseObject))success
           failure:(void (^)(NSError *error))failure{
    NSMutableDictionary *dic = [[NSMutableDictionary alloc]initWithCapacity:1];
    dic[@"uid"] = page;
    dic[@"sid"] = sid;
    [self asyncNetworkingUrl:@"/Index/Shaidan" andDict:dic success:success failure:failure];
}


/**
 *  点赞
 *
 *  @param uid     <#uid description#>
 *  @param state   <#state description#>
 *  @param success <#success description#>
 *  @param failure <#failure description#>
 */
+(void)sandanZan_uid:(NSString *)uid success:(void (^)(NSDictionary *responseObject))success
             failure:(void (^)(NSError *error))failure{
    
    NSMutableDictionary *dic = [[NSMutableDictionary alloc]initWithCapacity:1];
    dic[@"sd_id"] = uid;
    
    
    [self asyncNetworkingUrl:@"/User/Orderlist/ShaidanZan" andDict:dic success:success failure:failure];
    
    
}
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
//+ (void)userHeadImg:(NSArray *)imgArr anduid:(NSString *)uid andtitle:(NSString *)titile andinfo:(NSString *)info andshopID:(NSString *)shopiD andqishu:(NSString *)qishu
//            success:(void (^)(NSDictionary *responseObject))success
//            failure:(void (^)(NSError *error))failure   uploadProgressBlock:(void(^)(float uploadPercent,long long totalBytesWritten,long long totalBytesExpectedToWrite))uploadProgressBlock{
//    NSMutableDictionary *dict = [[NSMutableDictionary alloc]initWithCapacity:1];
//    dict[@"uid"] = uid;
//    dict[@"title"] = titile;
//    dict[@"content"] = info;
//    dict[@"shopid"] = shopiD;
//    dict[@"qishu"] = qishu;
//    
//    NSString *url = [NSString stringWithFormat:@"%@%@",MAIN_URL,@"/User/Orderlist/Addshaidan"];
//    
//    
//    //请求管理者
//    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
//    
//    manager.responseSerializer = [AFJSONResponseSerializer serializer];
//    manager.requestSerializer = [AFJSONRequestSerializer serializer];
//    
//    AFHTTPRequestOperation *operation = [manager POST:url parameters:dict constructingBodyWithBlock:^(id<AFMultipartFormData> formData) {
//        
//        int i = 0;
//        //根据当前系统时间生成图片名称
//        NSDate *date = [NSDate date];
//        NSDateFormatter *formatter = [[NSDateFormatter alloc]init];
//        [formatter setDateFormat:@"yyyy.MM.dd"];
//        NSString *dateString = [formatter stringFromDate:date];
//        for (UIImage *image in imgArr) {
//            NSString *fileName = [NSString stringWithFormat:@"%@%d.png",dateString,i];
//            NSData *imageData;
//            imageData = UIImageJPEGRepresentation(image, 0.5);
//            NSLog(@"图片二进制：%@",imageData);
//            //            [formData appendPartWithFileData:imageData name:@"photo" fileName:fileName mimeType:@"image/jpg/png/jpeg"];
//            [formData appendPartWithFileData:imageData name:[NSString stringWithFormat:@"photo%d",i] fileName:fileName mimeType:@"multipart/form-data"];
//            i++;
//        }
//        
//        
//        //        [formData appendPartWithFileData:data name:@"userHeadImg" fileName:@"HeadImg.png" mimeType:@"multipart/form-data"];
//        
//        
//    } success:^(AFHTTPRequestOperation *operation, id responseObject) {
//        dispatch_async(dispatch_get_main_queue(), ^{
//            success(responseObject); //成功回调
//        });
//    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
//        dispatch_async(dispatch_get_main_queue(), ^{
//            failure(error); //成功回调
//        });
//    }];
//    
//    
//    [operation setUploadProgressBlock:^(NSUInteger bytesWritten, long long totalBytesWritten, long long totalBytesExpectedToWrite) {
//        CGFloat percent = totalBytesWritten * 1.0 / totalBytesExpectedToWrite;
//        uploadProgressBlock(percent,totalBytesWritten,totalBytesExpectedToWrite);
//    }];
//    
//}
///**
// *  晒单详情
// *
// *  @param sdid    晒单id
// *  @param success <#success description#>
// *  @param failure <#failure description#>
// */
//+(void)SDXQ_sd_id:(NSString *)sdid success:(void (^)(NSDictionary *))success failure:(void (^)(NSError *))failure{
//    
//    NSMutableDictionary *dic = [[NSMutableDictionary alloc]initWithCapacity:1];
//    dic[@"sd_id"] = sdid;
//    [self asyncNetworkingUrl:@"/User/Orderlist/ShaidanDetail" andDict:dic success:success failure:failure];
//}
//
//+ (void)userHeadImg:(NSArray *)imgArr anduid:(NSString *)uid success:(void (^)(NSDictionary *))success failure:(void (^)(NSError *))failure uploadProgressBlock:(void (^)(float, long long, long long))uploadProgressBlock{
//    
//    NSMutableDictionary *dict = [[NSMutableDictionary alloc]initWithCapacity:1];
//    dict[@"uid"] = uid;
//    NSString *url = [NSString stringWithFormat:@"%@%@",MAIN_URL,@"/User/Setting/UploadHeartImg"];
//    
//    //请求管理者
//    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
//    
//    manager.responseSerializer = [AFJSONResponseSerializer serializer];
//    manager.requestSerializer = [AFJSONRequestSerializer serializer];
//    
//    AFHTTPRequestOperation *operation = [manager POST:url parameters:dict constructingBodyWithBlock:^(id<AFMultipartFormData> formData) {
//        
//        int i = 0;
//        //根据当前系统时间生成图片名称
//        NSDate *date = [NSDate date];
//        NSDateFormatter *formatter = [[NSDateFormatter alloc]init];
//        [formatter setDateFormat:@"yyyy.MM.dd"];
//        NSString *dateString = [formatter stringFromDate:date];
//        for (UIImage *image in imgArr) {
//            NSString *fileName = [NSString stringWithFormat:@"%@.png",uid];
//            NSData *imageData;
//            imageData = UIImageJPEGRepresentation(image, 0.5);
//            NSLog(@"图片二进制：%@",imageData);
//            //            [formData appendPartWithFileData:imageData name:@"photo" fileName:fileName mimeType:@"image/jpg/png/jpeg"];
//            [formData appendPartWithFileData:imageData name:[NSString stringWithFormat:@"photo%d",i] fileName:fileName mimeType:@"multipart/form-data"];
//            i++;
//        }
//        
//        
//        //        [formData appendPartWithFileData:data name:@"userHeadImg" fileName:@"HeadImg.png" mimeType:@"multipart/form-data"];
//        
//    } success:^(AFHTTPRequestOperation *operation, id responseObject) {
//        dispatch_async(dispatch_get_main_queue(), ^{
//            success(responseObject); //成功回调
//        });
//    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
//        dispatch_async(dispatch_get_main_queue(), ^{
//            failure(error); //成功回调
//        });
//    }];
//    [operation setUploadProgressBlock:^(NSUInteger bytesWritten, long long totalBytesWritten, long long totalBytesExpectedToWrite) {
//        CGFloat percent = totalBytesWritten * 1.0 / totalBytesExpectedToWrite;
//        uploadProgressBlock(percent,totalBytesWritten,totalBytesExpectedToWrite);
//    }];
//    
//    
//    
//    
//}


+(void)SDXQ_pinglu_sd_id:(NSString *)sdid anduid:(NSString *)uid andinfo:(NSString *)info success:(void (^)(NSDictionary *))success failure:(void (^)(NSError *))failure{
    NSMutableDictionary *dic = [[NSMutableDictionary alloc]initWithCapacity:1];
    dic[@"sd_id"] = sdid;
    dic[@"uid"] = uid;
    dic[@"pingcontent"] = info;
    [self asyncNetworkingUrl:@"/User/Orderlist/ShaidanPing" andDict:dic success:success failure:failure];
}

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
+ (void)ShangPinXiangQing_gid:(NSString *)gid anduid:(NSString *)uid andsid:(NSString *)sid andqishu:(NSString*)qishu success:(void (^)(NSDictionary *responseObject))success failure:(void (^)(NSError *error))failure{
    
    NSMutableDictionary *dic = [[NSMutableDictionary alloc]initWithCapacity:1];
    dic[@"gid"] = gid;
    dic[@"uid"] = uid;
    dic[@"sid"] = sid;
    dic[@"qishu"] = qishu;
    [self asyncNetworkingUrl:@"/Index/ShopDetail" andDict:dic success:success failure:failure];
}
+ (void)XiangQingPingLun_gid:(NSString *)gid andpage:(NSString *)sid andqishu:(NSString*)qishu andPage:(NSString *)page success:(void (^)(NSDictionary *responseObject))success failure:(void (^)(NSError *error))failure{
    
    NSMutableDictionary *dic = [[NSMutableDictionary alloc]initWithCapacity:1];
    dic[@"gid"] = gid;
    dic[@"sid"] = sid;
    dic[@"qishu"] = qishu;
    dic[@"page"] = page;
    [self asyncNetworkingUrl:@"/Index/ShopDetail/Golist" andDict:dic success:success failure:failure];
}
/**
 *  图文详情
 *
 *  @param gid     <#gid description#>
 *  @param success <#success description#>
 *  @param failure <#failure description#>
 */
+ (void)TuWenXiangQing_gid:(NSString *)gid success:(void (^)(NSDictionary *responseObject))success failure:(void (^)(NSError *error))failure{
    NSMutableDictionary *dic = [[NSMutableDictionary alloc]initWithCapacity:1];
    dic[@"gid"] = gid;
    [self asyncNetworkingUrl:@"/Index/ShopDetail/Tuwen" andDict:dic success:success failure:failure];
    
}

+(void)jisuan_gid:(NSString *)gid success:(void (^)(NSDictionary *))success failure:(void (^)(NSError *))failure{
    NSMutableDictionary *dic = [[NSMutableDictionary alloc]initWithCapacity:1];
    dic[@"gid"] = gid;
    [self asyncNetworkingUrl:@"/Index/ShopDetail/Chakanjisuan" andDict:dic success:success failure:failure];
    
}
+ (void)PersonalCenter_uid:(NSString *)uid success:(void (^)(NSDictionary *responseObject))success failure:(void (^)(NSError *error))failure{
    NSMutableDictionary *dic = [[NSMutableDictionary alloc]initWithCapacity:1];
    dic[@"uid"] = uid;
    [self asyncNetworkingUrl:@"/Index/User" andDict:dic success:success failure:failure];
}
+ (void)PersonalCenter_state:(NSInteger)state anduid:(NSString *)uid andpage:(NSInteger)page success:(void (^)(NSDictionary *responseObject))success failure:(void (^)(NSError *error))failure{
    NSMutableDictionary *dic = [[NSMutableDictionary alloc]initWithCapacity:1];
    dic[@"uid"] = uid;
    dic[@"page"] = [NSString stringWithFormat:@"%ld",(long)page];
    if (state == 0) {
        [self asyncNetworkingUrl:@"/Index/User/Qblist" andDict:dic success:success failure:failure];
    }else if (state == 1){
        [self asyncNetworkingUrl:@"/Index/User/Getlist" andDict:dic success:success failure:failure];
    }
    
    
}
+ (void)reg_mobile:(NSString *)mobile success:(void(^)(NSDictionary *))success failure:(void(^)(NSError *))failure{
    NSMutableDictionary *dic = [[NSMutableDictionary alloc]initWithCapacity:1];
    dic[@"mobile"] = mobile;
    [self asyncNetworkingUrl:@"/User/MobileVerify" andDict:dic success:success failure:failure];
}
+ (void)verify:(NSString *)verify andMobile:(NSString *)mobile
       andQQ:(NSString *)QQ success:(void(^)(NSDictionary*))success failure:(void(^)(NSError*))failure{
    NSMutableDictionary *dic = [[NSMutableDictionary alloc]initWithCapacity:1];
    dic[@"verify"] = verify;
    dic[@"mobile"] = mobile;
    dic[@"QQ"] = QQ;
    [self asyncNetworkingUrl:@"/User/Zhuce/yanzhen" andDict:dic success:success failure:failure];
}
+ (void)verifyXiuGai:(NSString *)verify andMobile:(NSString *)mobile success:(void(^)(NSDictionary*))success failure:(void(^)(NSError*))failure{
    NSMutableDictionary *dic = [[NSMutableDictionary alloc]initWithCapacity:1];
    dic[@"verify"] = verify;
    dic[@"mobile"] = mobile;
    [self asyncNetworkingUrl:@"/User/Setting/DuanxinVerify" andDict:dic success:success failure:failure];
}
+ (void)newPassword:(NSString*)password andMobile:(NSString *)mobile success:(void(^)(NSDictionary*))success failure:(void(^)(NSError*))failure{
    NSMutableDictionary *dic = [[NSMutableDictionary alloc]initWithCapacity:1];
    dic[@"password"] = password;
    dic[@"mobile"] = mobile;
    [self asyncNetworkingUrl:@"/User/Setting/ResetPassword" andDict:dic success:success failure:failure];
}
+ (void)password:(NSString*)password andMobile:(NSString *)mobile success:(void(^)(NSDictionary*))success failure:(void(^)(NSError*))failure{
    NSMutableDictionary *dic = [[NSMutableDictionary alloc]initWithCapacity:1];
    dic[@"password"] = password;
    dic[@"mobile"] = mobile;
    [self asyncNetworkingUrl:@"/User/Zhuce/" andDict:dic success:success failure:failure];
}
+ (void)shouYesuccess:(void (^)(NSDictionary *responseObject))success
              failure:(void (^)(NSError *error))failure{
 [self asyncNetworkingUrl:@"/Index/Shouye" andDict:nil success:success failure:failure];
}
/**
 *  商品列表
 *
 *  @param class
 *  @param sort
 *  @param page 
 */
+ (void)shangpinClass:(NSString*)class sort:(NSString*)sort page:(NSString*)page success:(void (^)(NSDictionary *responseObject))success
              failure:(void (^)(NSError *error))failure{
   NSMutableDictionary *dic = [[NSMutableDictionary alloc]initWithCapacity:1];
    dic[@"class"] = class;
    dic[@"sort"]  = sort;
    dic[@"page"]  = page;
   [self asyncNetworkingUrl:@"/Index/Shoplist" andDict:dic success:success failure:failure];
}
/**
 *  商品列表
 *
 *  @param name;
 
 */
+ (void)searchName:(NSString *)name sort:(NSString *)sort page:(NSString *)page success:(void (^)(NSDictionary *responseObject))success
           failure:(void (^)(NSError *error))failure{

NSMutableDictionary *dic = [[NSMutableDictionary alloc]initWithCapacity:1
];
    dic[@"sort"] = sort;
    dic[@"name"] = name;
    dic[@"page"] = page;
    [self asyncNetworkingUrl:@"/Index/Shoplist/Search" andDict:dic success:success failure:failure];
}
//搜索热门
+ (void)searchHotsuccess:(void (^)(NSDictionary *responseObject))success
                 failure:(void (^)(NSError *error))failure{
[self asyncNetworkingUrl:@"/Index/Shoplist/Hotso" andDict:nil success:success failure:failure];
}
//首页十元

+ (void)shouYeTenpage:(NSString *)page success:(void (^)(NSDictionary *responseObject))success failure:(void (^)(NSError *error))failure{
    NSMutableDictionary * dic = [[NSMutableDictionary alloc]initWithCapacity:1];
    dic[@"page"] = page;

[self asyncNetworkingUrl:@"/Index/Shouye/Ten" andDict:dic success:success failure:failure];
}

//首页限时
+ (void)shouYeXSccess:(void (^)(NSDictionary *responseObject))success
              failure:(void (^)(NSError *error))failure{
[self asyncNetworkingUrl:@"/Index/Shouye/XS" andDict:nil success:success failure:failure];
}
//即将揭晓
+ (void)soonPublicPage:(NSString *)page success:(void (^)(NSDictionary *responseObject))success failure:(void (^)(NSError *error))failure{
    NSMutableDictionary * dic = [[NSMutableDictionary alloc]initWithCapacity:1];
    dic[@"page"] = page;
    [self asyncNetworkingUrl:@"/Index/Zuixin" andDict:dic success:success failure:failure];
}
//购物车信息
+ (void)buybuybuyid:(NSString *)gid success:(void (^)(NSDictionary *responseObject))success failure:(void (^)(NSError *error))failure{
    NSMutableDictionary * dic = [[NSMutableDictionary alloc]initWithCapacity:1];
    
    dic[@"gid"] = gid;
    [self asyncNetworkingUrl:@"/Index/Go/Cart" andDict:dic success:success failure:failure];
}

//融云获取Token
+(void)getToken:(NSString*)userId andName:(NSString *)name andportraitUri:(NSString *)touXiangUrl success:(void (^)(NSDictionary *responseObject))success
        failure:(void (^)(NSError *error))failure
{
    NSMutableDictionary *dic = [[NSMutableDictionary alloc]initWithCapacity:1];
    dic[@"userId"] = userId;
    dic[@"name"] = name;
    dic[@"portraitUri"] = touXiangUrl;
    
    [self asyncNetworkingUrl:@"https://api.cn.rong.io/user/getToken.json" andDict:dic success:success failure:failure];
}

//上传注册信息
+(void)getZhuCe_username:(NSString*)username andpassword:(NSString *)password andnickname:(NSString *)nickname andsignature:(NSString *)signature success:(void (^)(NSDictionary *responseObject))success
                 failure:(void (^)(NSError *error))failure
{
    NSMutableDictionary *dic = [[NSMutableDictionary alloc]initWithCapacity:1];
    dic[@"username"] = username;
    dic[@"password"] = password;
    dic[@"nickname"] = nickname;
    dic[@"signature"] = signature;
    
    [self asyncNetworkingUrl:@"http://112.74.105.205/usermsg/home/user/doRegister" andDict:dic success:success failure:failure];
    
}
//登录以获取信息
+(void)getDengLu_username:(NSString *)username andpassword:(NSString *)password success:(void (^)(NSDictionary *))success failure:(void (^)(NSError *))failure
{
    NSMutableDictionary *dic = [[NSMutableDictionary alloc]initWithCapacity:1];
    dic[@"username"] = username;
    dic[@"password"] = password;
    [self asyncNetworkingUrl:@"http://112.74.105.205/usermsg/home/user/dologin" andDict:dic success:success failure:failure];
}

#pragma mark - 听闻接口请求方法

//获取进入app的广告界面
+ (void)getIntoAppGuangGaoPage:(NSString *)page andLimit:(NSString *)limit sccess:(void (^)(NSDictionary *responseObject))success
                           failure:(void (^)(NSError *error))failure{
    NSMutableDictionary *dic = [[NSMutableDictionary alloc]initWithCapacity:1];
    dic[@"page"] = page;
    dic[@"limit"] = limit;
    [self asyncNetworkingUrl:@"/interface/kaiList" andDict:dic success:success failure:failure];
}

//获取头条新闻列表
+ (void)getTouTiaoListWithaccessToken:(NSString *)accessToken andPage:(NSString *)page andLimit:(NSString *)limit sccess:(void (^)(NSDictionary *responseObject))success
                       failure:(void (^)(NSError *error))failure
{
    NSMutableDictionary *dic = [[NSMutableDictionary alloc]initWithCapacity:1];
    dic[@"accessToken"] = accessToken;
    dic[@"page"] = page;
    dic[@"limit"] = limit;
    [self asyncNetworkingUrl:@"/interface/touList" andDict:dic success:success failure:failure];
}
////根据频道id获取新闻列表
//+ (void)getNewsListWithID:(NSString *)ID andpage:(NSString *)page andlimit:(NSString *)limit sccess:(void (^)(NSDictionary *responseObject))success failure:(void(^)(NSError *error))failure
//{
//    NSMutableDictionary *dic = [[NSMutableDictionary alloc]initWithCapacity:1];
//    dic[@"term_id"] = ID;
//    dic[@"page"] = page;
//    dic[@"limit"] = limit;
//    [self asyncNetworkingUrl:@"/interface/postList" andDict:dic success:success failure:failure];
//}
//根据频道id获取新闻列表（新）
+ (void)getNewsListWithaccessToken:(NSString *)accessToken andID:(NSString *)ID andpage:(NSString *)page andlimit:(NSString *)limit sccess:(void (^)(NSDictionary *responseObject))success failure:(void(^)(NSError *error))failure
{
    NSMutableDictionary *dic = [[NSMutableDictionary alloc]initWithCapacity:1];
    dic[@"accessToken"] = accessToken;
    dic[@"term_id"] = ID;
    dic[@"page"] = page;
    dic[@"limit"] = limit;
    [self asyncNetworkingUrl:@"/interface/postList" andDict:dic success:success failure:failure];
}

//根据关键字获取推荐新闻列表
+ (void)getTuiJianWithKeyWords:(NSString *)keywords andaccessToken:(NSString *)accessToken andpage:(NSString *)page andlimit:(NSString *)limit sccess:(void (^)(NSDictionary *responseObject))success failure:(void(^)(NSError *error))failure
{
    NSMutableDictionary *dic = [[NSMutableDictionary alloc]initWithCapacity:1];
    dic[@"accessToken"] = accessToken;
    dic[@"keyword"] = keywords;
    dic[@"page"] = page;
    dic[@"limit"] = limit;
    [self asyncNetworkingUrl:@"/interface/postList" andDict:dic success:success failure:failure];
}
//根据用户手机号码查询用户信息
+ (void)getUserInfoWithUserPhoneNumber:(NSString *)phonenumber sccess:(void (^)(NSDictionary *responseObject))success failure:(void(^)(NSError *error))failure
{
    NSMutableDictionary *dic = [[NSMutableDictionary alloc]initWithCapacity:1];
    dic[@"accessToken"] = phonenumber;
    [self asyncNetworkingUrl:@"/interface/userinfo" andDict:dic success:success failure:failure];
}
//根据用户名密码获取当前登录用户信息
+ (void)getPaoGuoUserInfoWithUserName:(NSString *)accessToken andPassWord:(NSString *)password sccess:(void (^)(NSDictionary *responseObject))success failure:(void(^)(NSError *error))failure
{
    NSMutableDictionary *dic = [[NSMutableDictionary alloc]initWithCapacity:1];
    dic[@"accessToken"] = accessToken;
    dic[@"password"] = password;
    [self asyncNetworkingUrl:@"/interfaceNew/login" andDict:dic success:success failure:failure];
}
//修改用户信息上传
+ (void)postPaoGuoUserInfoWithUserName:(NSString *)accessToken andNiceName:(NSString *)nicename andSex:(NSString *)sex andSignature:(NSString  *)signature sccess:(void (^)(NSDictionary *responseObject))success failure:(void(^)(NSError *error))failure
{
    NSMutableDictionary *dic = [[NSMutableDictionary alloc]initWithCapacity:1];
    dic[@"accessToken"] = accessToken;
    dic[@"nicename"] = nicename;
    dic[@"sex"] = sex;
    dic[@"signature"] = signature;
    [self asyncNetworkingUrl:@"/interfaceNew/modifyUserInfo" andDict:dic success:success failure:failure];
}
//获取节目列表
+ (void)postPaoGuoJieMuLieBiaoWithaccessToken:(NSString *)accessToken sccess:(void (^)(NSDictionary *responseObject))success failure:(void(^)(NSError *error))failure
{
    NSMutableDictionary *dic = [[NSMutableDictionary alloc]initWithCapacity:1];
    dic[@"accessToken"] = accessToken;
//    dic[@"keyword"] = keyword;
    [self asyncNetworkingUrl:@"/interface/Act" andDict:dic success:success failure:failure];
}
//获取自己关注的节目列表
+ (void)getPaoGuoSelfJieMuLieBiaoWithaccessToken:(NSString *)accessToken sccess:(void (^)(NSDictionary *responseObject))success failure:(void(^)(NSError *error))failure
{
    NSMutableDictionary *dic = [[NSMutableDictionary alloc]initWithCapacity:1];
    dic[@"accessToken"] = accessToken;
    [self asyncNetworkingUrl:@"/interface/newList" andDict:dic success:success failure:failure];
}
///获取我的节目列表
+ (void)getPaoGuoSelfWoDeJieMuWithaccessToken:(NSString *)accessToken andPage:(NSString *)page andLimit:(NSString *)limit sccess:(void (^)(NSDictionary *responseObject))success failure:(void (^)(NSError *error))failure
{
    NSMutableDictionary *dic = [[NSMutableDictionary alloc]initWithCapacity:1];
    dic[@"accessToken"] = accessToken;
    dic[@"page"] = page;
    dic[@"limit"] = limit;
    [self asyncNetworkingUrl:@"/interface/acanNew" andDict:dic success:success failure:failure];
}
///添加节目关注
+ (void)postPaoGuoAddJieMuGuanZhuWithaccessToken:(NSString *)accessToken andAct_id:(NSString *)act_id sccess:(void (^)(NSDictionary *responseObject))success failure:(void (^)(NSError *error))failure
{
    NSMutableDictionary *dic = [[NSMutableDictionary alloc]initWithCapacity:1];
    dic[@"accessToken"] = accessToken;
    dic[@"act_id"] = act_id;
    [self asyncNetworkingUrl:@"/interface/addActtention" andDict:dic success:success failure:failure];
}
///取消节目关注
+ (void)postPaoGuoCancelJieMuGuanZhuWithaccessToken:(NSString *)accessToken andAct_id:(NSString *)act_id sccess:(void (^)(NSDictionary *responseObject))success failure:(void (^)(NSError *error))failure
{
    NSMutableDictionary *dic = [[NSMutableDictionary alloc]initWithCapacity:1];
    dic[@"accessToken"] = accessToken;
    dic[@"act_id"] = act_id;
    [self asyncNetworkingUrl:@"/interface/cancelActtention" andDict:dic success:success failure:failure];
}

///获取应用推荐列表
+ (void)getPaoGuoYingYongTuiJianWithaccessToken:(NSString *)accessToken sccess:(void (^)(NSDictionary *responseObject))success failure:(void (^)(NSError *error))failure
{
    NSMutableDictionary *dic = [[NSMutableDictionary alloc]initWithCapacity:1];
    dic[@"accessToken"] = accessToken;
    [self asyncNetworkingUrl:@"/interface/groom" andDict:dic success:success failure:failure];
}
///获取关注列表列表
+ (void)getPaoGuoGuanZhuLieBiaoWithaccessToken:(NSString *)accessToken andPage:(NSString *)page andLimit:(NSString *)limit sccess:(void (^)(NSDictionary *responseObject))success failure:(void (^)(NSError *error))failure
{
    NSMutableDictionary *dic = [[NSMutableDictionary alloc]initWithCapacity:1];
    dic[@"accessToken"] = accessToken;
    dic[@"page"] = page;
    dic[@"limit"] = limit;
    [self asyncNetworkingUrl:@"/interface/attentionList" andDict:dic success:success failure:failure];
}
///根据用户user_login获取到用户信息
+ (void)getPaoGuoUserInfoWithuser_login:(NSString *)user_login sccess:(void (^)(NSDictionary *responseObject2))success failure:(void (^)(NSError *error))failure
{
    NSMutableDictionary *dic = [[NSMutableDictionary alloc]initWithCapacity:1];
    dic[@"accessToken"] = user_login;
    [self asyncNetworkingUrl:@"/interface/userinfo" andDict:dic success:success failure:failure];
}
///根据用户user_login获取到用户更多信息
+ (void)getPaoGuoMoreUserInfoWithuser_login:(NSString *)user_login sccess:(void (^)(NSDictionary *responseObject2))success failure:(void (^)(NSError *error2))failure
{
    NSMutableDictionary *dic = [[NSMutableDictionary alloc]initWithCapacity:1];
    dic[@"accessToken"] = user_login;
    [self asyncNetworkingUrl:@"/interface/userinfo" andDict:dic success:success failure:failure];
}
///根据用户token获取到用户好友动态更多信息
+ (void)getPaoGuoFriendDongTaiWithaccessToken:(NSString *)accessToken andPage:(NSString *)page andLimit:(NSString *)limit sccess:(void (^)(NSDictionary *responseObject))success failure:(void (^)(NSError *error))failure
{
    NSMutableDictionary *dic = [[NSMutableDictionary alloc]initWithCapacity:1];
    dic[@"accessToken"] = accessToken;
    dic[@"page"] = page;
    dic[@"limit"] = limit;
    [self asyncNetworkingUrl:@"/interfaceTest/shareLogListNew" andDict:dic success:success failure:failure];
}
///根据用户token获取到用户好友评论动态更多信息
+ (void)getPaoGuoFriendPingLunWithaccessToken:(NSString *)accessToken andPage:(NSString *)page andLimit:(NSString *)limit sccess:(void (^)(NSDictionary *responseObject1))success failure:(void (^)(NSError *error1))failure
{
    NSMutableDictionary *dic = [[NSMutableDictionary alloc]initWithCapacity:1];
    dic[@"accessToken"] = accessToken;
    dic[@"page"] = page;
    dic[@"limit"] = limit;
    [self asyncNetworkingUrl:@"/interfaceTest/shareLogListNew" andDict:dic success:success failure:failure];
}
///根据用户token获取到用户自己评论动态更多信息
+ (void)getPaoGuoSelfPingLunWithaccessToken:(NSString *)accessToken andPage:(NSString *)page andLimit:(NSString *)limit sccess:(void (^)(NSDictionary *responseObject2))success failure:(void (^)(NSError *error2))failure
{
    NSMutableDictionary *dic = [[NSMutableDictionary alloc]initWithCapacity:1];
    dic[@"accessToken"] = accessToken;
    dic[@"page"] = page;
    dic[@"limit"] = limit;
    [self asyncNetworkingUrl:@"/interfaceTest/myShareLogListNew" andDict:dic success:success failure:failure];
}

+ (void)getMyDynamicsListWithaccessToken:(NSString *)accessToken
                                 andPage:(NSString *)page
                                andLimit:(NSString *)limit
                                  sccess:(void (^)(NSDictionary *responseObject))success
                                 failure:(void (^)(NSError *error))failure{
    NSMutableDictionary *dic = [[NSMutableDictionary alloc]initWithCapacity:1];
    dic[@"accessToken"] = accessToken;
    dic[@"page"] = page;
    dic[@"limit"] = limit;
    [self asyncNetworkingUrl:@"/interfaceYou/myDynamics" andDict:dic success:success failure:failure];
}

///根据用户token获取到用户自己关注列表
+ (void)getPaoGuoSelfGuanZhuLieBiaoWithaccessToken:(NSString *)accessToken andPage:(NSString *)page andLimit:(NSString *)limit sccess:(void (^)(NSDictionary *responseObject))success failure:(void (^)(NSError *error))failure
{
    NSMutableDictionary *dic = [[NSMutableDictionary alloc]initWithCapacity:1];
    dic[@"accessToken"] = accessToken;
    dic[@"page"] = page;
    dic[@"limit"] = limit;
    [self asyncNetworkingUrl:@"/interface/attentionList" andDict:dic success:success failure:failure];
}
///根据用户token获取到用户自己粉丝列表
+ (void)getPaoGuoSelfFenSiLieBiaoWithaccessToken:(NSString *)accessToken andPage:(NSString *)page andLimit:(NSString *)limit sccess:(void (^)(NSDictionary *responseObject))success failure:(void (^)(NSError *error))failure
{
    NSMutableDictionary *dic = [[NSMutableDictionary alloc]initWithCapacity:1];
    dic[@"accessToken"] = accessToken;
    dic[@"page"] = page;
    dic[@"limit"] = limit;
    [self asyncNetworkingUrl:@"/interface/fanList" andDict:dic success:success failure:failure];
}
///根据用户token和要取消关注的用户id取消关注
+ (void)getPaoGuoCancelFriendWithaccessToken:(NSString *)accessToken anduid_2:(NSString *)uid_2 sccess:(void (^)(NSDictionary *responseObject))success failure:(void (^)(NSError *error))failure
{
    NSMutableDictionary *dic = [[NSMutableDictionary alloc]initWithCapacity:1];
    dic[@"accessToken"] = accessToken;
    dic[@"uid_2"] = uid_2;
    [self asyncNetworkingUrl:@"/interface/cancelAttention" andDict:dic success:success failure:failure];
}
///根据用户token和要添加关注的用户id取消关注
+ (void)getPaoGuoAddFriendWithaccessToken:(NSString *)accessToken anduid_2:(NSString *)uid_2 sccess:(void (^)(NSDictionary *responseObject))success failure:(void (^)(NSError *error))failure
{
    NSMutableDictionary *dic = [[NSMutableDictionary alloc]initWithCapacity:1];
    dic[@"accessToken"] = accessToken;
    dic[@"uid_2"] = uid_2;
    [self asyncNetworkingUrl:@"/interface/addAttention" andDict:dic success:success failure:failure];
}
///根据用户token和用户关键字获取推荐新闻
+ (void)getPaoGuoTuiJianNewsWithuid:(NSString *)uid andkeyword:(NSString *)keyword andPage:(NSString *)page andLimit:(NSString *)limit sccess:(void (^)(NSDictionary *responseObject))success failure:(void (^)(NSError *error))failure
{
    NSMutableDictionary *dic = [[NSMutableDictionary alloc]initWithCapacity:1];
    dic[@"uid"] = uid;
    dic[@"keyword"] = keyword;
    dic[@"page"] = page;
    dic[@"limit"] = limit;
    [self asyncNetworkingUrl:@"/interface/tuijian" andDict:dic success:success failure:failure];
}

+ (void)getPaoguoSearchNewsWithaccessToken:(NSString *)accessToken
                                   term_id:(NSString *)term_id
                                   keyword:(NSString *)keyword
                                   andPage:(NSString *)page
                                  andLimit:(NSString *)limit
                                    sccess:(void (^)(NSDictionary *responseObject))success
                                   failure:(void (^)(NSError *error))failure{
    NSMutableDictionary *dic = [[NSMutableDictionary alloc]initWithCapacity:1];
    dic[@"accessToken"] = accessToken;
    dic[@"term_id"] = term_id;
    dic[@"keyword"] = keyword;
    dic[@"page"] = page;
    dic[@"limit"] = limit;
    [self asyncNetworkingUrl:@"/interface/postList" andDict:dic success:success failure:failure];
}

+ (void)getAllAnchorInfoListWithan_id:(NSString *)an_id
                              keyword:(NSString *)keyword
                              andPage:(NSString *)page
                             andLimit:(NSString *)limit
                               sccess:(void (^)(NSDictionary *responseObject))success
                              failure:(void (^)(NSError *error))failure{
    
    NSMutableDictionary *dic = [[NSMutableDictionary alloc]initWithCapacity:1];
    dic[@"an_id"] = an_id;
    dic[@"keyword"] = keyword;
    dic[@"page"] = page;
    dic[@"limit"] = limit;
    [self asyncNetworkingUrl:@"/interface/Anchor"
                     andDict:dic
                     success:success
                     failure:failure];
    
}

+ (void)getAllActInfoListWithAccessToken:(NSString *)accessToken
                                   ac_id:(NSString *)ac_id
                                 keyword:(NSString *)keyword
                                 andPage:(NSString *)page
                                andLimit:(NSString *)limit
                                  sccess:(void (^)(NSDictionary *responseObject))success
                                 failure:(void (^)(NSError *error))failure{
    NSMutableDictionary *dic = [[NSMutableDictionary alloc]initWithCapacity:1];
    dic[@"accessToken"] = accessToken;
    dic[@"ac_id"] = ac_id;
    dic[@"keyword"] = keyword;
    dic[@"page"] = page;
    dic[@"limit"] = limit;
    [self asyncNetworkingUrl:@"/interface/Act"
                     andDict:dic
                     success:success
                     failure:failure];
}


///根据新闻ID获取新闻详细内容
+ (void)getPaoguoJieMuNeiRongWithJieMuID:(NSString *)post_id andPage:(NSString *)page andLimit:(NSString *)limit sccess:(void (^)(NSDictionary *responseObject))success failure:(void (^)(NSError *error))failure
{
    NSMutableDictionary *dic = [[NSMutableDictionary alloc]initWithCapacity:1];
    dic[@"post_id"] = post_id;
    dic[@"page"] = page;
    dic[@"limit"] = limit;
    [self asyncNetworkingUrl:@"/interface/postinfo" andDict:dic success:success failure:failure];
}
///根据新闻ID获取新闻评论列表
+ (void)getPaoGuoJieMuPingLunLieBiaoWithJieMuID:(NSString *)post_id anduid:(NSString *)uid andPage:(NSString *)page andLimit:(NSString *)limit sccess:(void (^)(NSDictionary *responseObject))success failure:(void (^)(NSError *error))failure
{
    NSMutableDictionary *dic = [[NSMutableDictionary alloc]initWithCapacity:1];
    dic[@"uid"] = uid;
    dic[@"post_id"] = post_id;
    dic[@"page"] = page;
    dic[@"limit"] = limit;
    [self asyncNetworkingUrl:@"/interface/commentList" andDict:dic success:success failure:failure];
}
///针对新闻进行评论（可以回复新闻中的评论）
+ (void)postPaoGuoXinWenPingLunWithaccessToken:(NSString *)accessToken
                                     andto_uid:(NSString *)to_uid
                                    andpost_id:(NSString *)post_id
                                 andcomment_id:(NSString *)comment_id
                                 andpost_table:(NSString *)post_table
                                    andcontent:(NSString *)content
                                        sccess:(void (^)(NSDictionary *responseObject))success
                                       failure:(void (^)(NSError *error))failure{
    
    NSMutableDictionary *dic = [[NSMutableDictionary alloc]initWithCapacity:1];
    dic[@"accessToken"] = accessToken;
    dic[@"to_uid"] = to_uid;
    dic[@"post_id"] = post_id;
    dic[@"comment_id"] = comment_id;
    dic[@"post_table"] = post_table;
    dic[@"content"] = content;
    [self asyncNetworkingUrl:@"/interface/addComment" andDict:dic success:success failure:failure];
}
///根据用户名以及评论ID针对新闻评论点赞
+ (void)postPaoGuoXinWenPingLunDianZanWithaccessToken:(NSString *)accessToken
                                            andact_id:(NSString *)act_id
                                               sccess:(void (^)(NSDictionary *responseObject))success
                                              failure:(void (^)(NSError *error))failure{
    NSMutableDictionary *dic = [[NSMutableDictionary alloc]initWithCapacity:1];
    dic[@"accessToken"] = accessToken;
    dic[@"act_id"] = act_id;
    [self asyncNetworkingUrl:@"/interface/addActPraise"
                     andDict:dic
                     success:success
                     failure:failure];
}
///根据填写的电话号码以及界面信息发送短信验证码
+ (void)postPaoGuoZhuCeYanZhengMaWithphoneFNumber:(NSString *)accessToken anduseType:(NSString *)useType sccess:(void (^)(NSDictionary *responseObject))success failure:(void (^)(NSError *error))failure
{
    NSMutableDictionary *dic = [[NSMutableDictionary alloc]initWithCapacity:1];
    dic[@"accessToken"] = accessToken;
    dic[@"useType"] = useType;
    [self asyncNetworkingUrl:@"/interface/sendVcode" andDict:dic success:success failure:failure];
}
///根据填写的密码以及电话号码以及验证码注册用户
+ (void)postPaoGuoZhuCeWithZhuCeAccessToken:(NSString *)accessToken andpassword:(NSString *)password anduser_nicename:(NSString *)user_nicename andvcode:(NSString *)vcode sccess:(void (^)(NSDictionary *responseObject))success failure:(void (^)(NSError *error))failure{
    NSMutableDictionary *dic = [[NSMutableDictionary alloc]initWithCapacity:1];
    dic[@"accessToken"] = accessToken;
    dic[@"password"] = password;
    dic[@"user_nicename"] = user_nicename;
    dic[@"vcode"] = vcode;
    [self asyncNetworkingUrl:@"/interfaceNew/register" andDict:dic success:success failure:failure];
}
///首页搜索布局列表
+ (void)getPaoGuoShouYeSouSuoLieBiao:(NSString *)str sccess:(void (^)(NSDictionary *responseObject))success failure:(void (^)(NSError *error))failure
{
    NSMutableDictionary *dic = [[NSMutableDictionary alloc]initWithCapacity:1];
    dic[@"str"] = str;
    [self asyncNetworkingUrl:@"/interfaceYou/findIndex" andDict:dic success:success failure:failure];
}
///根据主播ID以及用户accessToken进行对主播的关注
+ (void)postPaoGuoGuanZhuWithaccessToken:(NSString *)accessToken andact_id:(NSString *)act_id sccess:(void (^)(NSDictionary *responseObject))success failure:(void (^)(NSError *error))failure
{
    NSMutableDictionary *dic = [[NSMutableDictionary alloc]initWithCapacity:1];
    dic[@"accessToken"] = accessToken;
    dic[@"act_id"] = act_id;
    [self asyncNetworkingUrl:@"/interface/addActtention" andDict:dic success:success failure:failure];
}
///根据主播ID以及用户accessToken进行对主播的取消关注
+ (void)postPaoGuoQuXiaoGuanZhuWithaccessToken:(NSString *)accessToken andact_id:(NSString *)act_id sccess:(void (^)(NSDictionary *responseObject))success failure:(void (^)(NSError *error))failure
{
    NSMutableDictionary *dic = [[NSMutableDictionary alloc]initWithCapacity:1];
    dic[@"accessToken"] = accessToken;
    dic[@"act_id"] = act_id;
    [self asyncNetworkingUrl:@"/interface/cancelActtention" andDict:dic success:success failure:failure];
}
///找回密码时，填写正确的验证码后自动调用这个接口给用户发送短信随机密码
+ (void)postPaoGuoZhaoHuiMiMaGetSuiJiMiMaWithaccessToken:(NSString *)accessToken andvcode:(NSString *)vcode sccess:(void (^)(NSDictionary *responseObject))success failure:(void (^)(NSError *error))failure
{
    NSMutableDictionary *dic = [[NSMutableDictionary alloc]initWithCapacity:1];
    dic[@"accessToken"] = accessToken;
    dic[@"vcode"] = vcode;
    [self asyncNetworkingUrl:@"/interface/forgetPwd" andDict:dic success:success failure:failure];
}
///修改密码，要上传用户名，旧密码，新密码
+ (void)postPaoGuoXiuGaiMiMaWithaccessToken:(NSString *)accessToken andopassword:(NSString *)opassword andpassword:(NSString *)password sccess:(void (^)(NSDictionary *responseObject))success failure:(void (^)(NSError *error))failure
{
    NSMutableDictionary *dic = [[NSMutableDictionary alloc]initWithCapacity:1];
    dic[@"accessToken"] = accessToken;
    dic[@"opassword"] = opassword;
    dic[@"password"] = password;
    [self asyncNetworkingUrl:@"/interface/modifyPwd" andDict:dic success:success failure:failure];
}
///根据主播或者节目ID获取详情新闻留言照片等等列表信息
+ (void)postPaoGuoZhuBoOrJieMuMessageWithID:(NSString *)an_id andpage:(NSString *)page andlimit:(NSString *)limit sccess:(void (^)(NSDictionary *responseObject))success failure:(void(^)(NSError *error))failure
{
    NSMutableDictionary *dic = [[NSMutableDictionary alloc]initWithCapacity:1];
    dic[@"ac_id"] = an_id;
    dic[@"page"] = page;
    dic[@"limit"] = limit;
    [self asyncNetworkingUrl:@"/interface/Actinfo" andDict:dic success:success failure:failure];
}
///	根据分类获取该分类下主播播报的新闻列表
+ (void)postPaoGuoFenLeiZhuBoBoBaoXinWenWithterm_id:(NSString *)term_id andpage:(NSString *)page andlimit:(NSString *)limit sccess:(void (^)(NSDictionary *responseObject))success failure:(void(^)(NSError *error))failure
{
    NSMutableDictionary *dic = [[NSMutableDictionary alloc]initWithCapacity:1];
    dic[@"term_id"] = term_id;
    dic[@"page"] = page;
    dic[@"limit"] = limit;
    [self asyncNetworkingUrl:@"/interfaceYou/zhuboNewsList" andDict:dic success:success failure:failure];
}
///	根据分类获取该分类下节目播报的新闻列表
+ (void)postPaoGuoFenLeiJieMuBoBaoXinWenWithterm_id:(NSString *)term_id andpage:(NSString *)page andlimit:(NSString *)limit sccess:(void (^)(NSDictionary *responseObject))success failure:(void(^)(NSError *error))failure
{
    NSMutableDictionary *dic = [[NSMutableDictionary alloc]initWithCapacity:1];
    dic[@"term_id"] = term_id;
    dic[@"page"] = page;
    dic[@"limit"] = limit;
    [self asyncNetworkingUrl:@"/interfaceYou/actNewsList" andDict:dic success:success failure:failure];
}
///根据频道ID获取该频道下所有节目列表（主播的频道ID为0）
+ (void)getPaoguoJieMuLieBiaoWithterm_id:(NSString *)term_id
                          andaccessToken:(NSString *)accessToken
                                  sccess:(void (^)(NSDictionary *responseObject))success
                                 failure:(void(^)(NSError *error))failure{
    NSMutableDictionary *dic = [[NSMutableDictionary alloc]initWithCapacity:1];
    dic[@"term_id"] = term_id;
    dic[@"accessToken"] = accessToken;
    [self asyncNetworkingUrl:@"/interfaceYou/findList" andDict:dic success:success failure:failure];
}

+ (void)getFindList_goldWithterm_id:(NSString *)term_id
                     andaccessToken:(NSString *)accessToken
                             sccess:(void (^)(NSDictionary *responseObject))success
                            failure:(void(^)(NSError *error))failure{
    NSMutableDictionary *dic = [[NSMutableDictionary alloc]initWithCapacity:1];
    dic[@"term_id"] = term_id;
    dic[@"accessToken"] = accessToken;
    [self asyncNetworkingUrl:@"/interfaceNew/findList_gold" andDict:dic success:success failure:failure];
}


//获取节目列表
+ (void)postPaoGuoJieMuLieBiaoWithKeyWord:(NSString *)keyword sccess:(void (^)(NSDictionary *responseObject))success failure:(void(^)(NSError *error))failure
{
    NSMutableDictionary *dic = [[NSMutableDictionary alloc]initWithCapacity:1];
    dic[@"keyword"] = keyword;
    [self asyncNetworkingUrl:@"/interface/Act" andDict:dic success:success failure:failure];
}
///获取总的分类列表
+ (void)getPaoGuoFenLeiLieBiaoWithWhateverSomething:(NSString *)Whatever
                                             sccess:(void (^)(NSDictionary *responseObject))success
                                            failure:(void(^)(NSError *error))failure{
    NSMutableDictionary *dic = [[NSMutableDictionary alloc]initWithCapacity:1];
    dic[@"Whatever"] = Whatever;
    [self asyncNetworkingUrl:@"/interfaceYou/termList" andDict:dic success:success failure:failure];
}
///获取该频道下的幻灯片信息
+ (void)getPaoGuoPinDaoHuanDengPianXinXiWithterm_id:(NSString *)term_id
                                         andkeyword:(NSString *)keyword
                                             sccess:(void (^)(NSDictionary *responseObject))success
                                            failure:(void(^)(NSError *error))failure{
    NSMutableDictionary *dic = [[NSMutableDictionary alloc]initWithCapacity:1];
    dic[@"term_id"] = term_id;
    dic[@"keyword"] = keyword;
    [self asyncNetworkingUrl:@"/interface/ztList" andDict:dic success:success failure:failure];
}

+ (void)getSlideListWithcat_idname:(NSString *)cat_idname
                            sccess:(void (^)(NSDictionary *responseObject))success
                           failure:(void(^)(NSError *error))failure{
    NSMutableDictionary *dic = [[NSMutableDictionary alloc]initWithCapacity:1];
    dic[@"cat_idname"] = cat_idname;
    [self asyncNetworkingUrl:@"/interface/slideList" andDict:dic success:success failure:failure];
}

///获取随机用户信息（推荐好友列表）
+ (void)getPaoGuoSuiJiYongHuXinXiWithaccessToken:(NSString *)accessToken andPage:(NSString *)page andLimit:(NSString *)limit sccess:(void (^)(NSDictionary *responseObject))success failure:(void(^)(NSError *error))failure
{
    NSMutableDictionary *dic = [[NSMutableDictionary alloc]initWithCapacity:1];
    dic[@"accessToken"] = accessToken;
    dic[@"page"] = page;
    dic[@"limit"] = limit;
    [self asyncNetworkingUrl:@"/interface/listUserRand" andDict:dic success:success failure:failure];
}

+ (void)getPaoGuosousuoYongHuXinXiLieBiaoWithaccessToken:(NSString *)accessToken
                                             andkeywords:(NSString *)keywords
                                                  sccess:(void (^)(NSDictionary *responseObject))success
                                                 failure:(void(^)(NSError *error))failure{
    NSMutableDictionary *dic = [[NSMutableDictionary alloc]initWithCapacity:1];
    dic[@"accessToken"] = accessToken;
    dic[@"keywords"] = keywords;
    [self asyncNetworkingUrl:@"/interface/listUser"
                     andDict:dic
                     success:success
                     failure:failure];
}

+ (void)getPaoguoJieMuOrZhuBoPingLunLieBiaoWithact_id:(NSString *)act_id
                                              andpage:(NSString *)page
                                             andlimit:(NSString *)limit
                                               sccess:(void (^)(NSDictionary *responseObject))success
                                              failure:(void(^)(NSError *error))failure{
    
    NSMutableDictionary *dic = [[NSMutableDictionary alloc]initWithCapacity:1];
    dic[@"act_id"] = act_id;
    dic[@"page"] = page;
    dic[@"limit"] = limit;
    [self asyncNetworkingUrl:@"/interface/actList"
                     andDict:dic
                     success:success
                     failure:failure];
}

+ (void)postPaoGuoDiSanFangDengLuJieKouwithname:(NSString *)name
                                        andhead:(NSString *)head
                                        andtype:(int)type
                                      andopenid:(NSString *)openid
                                andaccess_token:(NSString *)access_token
                                  andexpires_in:(NSDate *)expires_in
                                         sccess:(void (^)(NSDictionary *responseObject))success
                                        failure:(void(^)(NSError *error))failure{
    
    NSMutableDictionary *dic = [[NSMutableDictionary alloc]initWithCapacity:1];
    dic[@"name"] = name;
    dic[@"head"] = head;
    dic[@"type"] = @(type);
    dic[@"openid"] = openid;
    dic[@"access_token"] = access_token;
    dic[@"expires_in"] = expires_in;
    [self asyncNetworkingUrl:@"/interfaceNew/oauthLogin"
                     andDict:dic
                     success:success
                     failure:failure];
}

+ (void)netwokingGET:(NSString *)getString
       andParameters:(NSDictionary *)parameters
             success:(void (^)(id))block{
    @autoreleasepool {
        [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];
            AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
            manager.requestSerializer.timeoutInterval = 40;
            [manager GET:[NSString stringWithFormat:@"https://api.weibo.com/2/users/show.json?uid=%@&access_token=%@", parameters[@"uid"], parameters[@"access_token"]] parameters:nil success:^(NSURLSessionDataTask *task, id responseObject) {
                block(responseObject);
            } failure:^(NSURLSessionDataTask *task, NSError *error) {
                //网络监听
//                [[NetworkingMangater sharedManager] networkingState];
            }];
        
    }
}

+ (void)postPaoGuoZhuBoOrJieMuLiuYanWithaccessToken:(NSString *)accessToken
                                          andto_uid:(NSString *)to_uid
                                          andact_id:(NSString *)act_id
                                      andcomment_id:(NSString *)comment_id
                                       andact_table:(NSString *)act_table
                                         andcontent:(NSString *)content
                                             sccess:(void (^)(NSDictionary *responseObject))success
                                            failure:(void(^)(NSError *error))failure{
    
    NSMutableDictionary *dic = [[NSMutableDictionary alloc]initWithCapacity:1];
    dic[@"accessToken"] = accessToken;
    dic[@"to_uid"] = to_uid;
    dic[@"act_id"] = act_id;
    dic[@"comment_id"] = comment_id;
    dic[@"act_table"] = act_table;
    dic[@"content"] = content;
    [self asyncNetworkingUrl:@"/interface/addAct" andDict:dic success:success failure:failure];
}

+ (void)getDownloadNewsListWithterm_id:(NSString *)term_id
                            start_time:(NSString *)start_time
                              end_time:(NSString *)end_time
                                sccess:(void (^)(NSDictionary *))success
                               failure:(void (^)(NSError *))failure{
    
    NSMutableDictionary *dic = [[NSMutableDictionary alloc]initWithCapacity:1];
    dic[@"term_id"] = term_id;
    dic[@"start_time"] = start_time;
    dic[@"end_time"] = end_time;
    [self asyncNetworkingUrl:@"/interfaceNew/xiazai" andDict:dic success:success failure:failure];
}

+ (void)getToutiaoDownloadNewsListWithkeyword:(NSString *)keyword
                                   start_time:(NSDate *)start_time
                                     end_time:(NSDate *)end_time
                                       sccess:(void (^)(NSDictionary *))success
                                      failure:(void (^)(NSError *))failure {
    
    NSMutableDictionary *dic = [[NSMutableDictionary alloc]initWithCapacity:1];
    dic[@"keyword"] = keyword;
    dic[@"start_time"] = start_time;
    dic[@"end_time"] = end_time;
    [self asyncNetworkingUrl:@"/interface/touxia" andDict:dic success:success failure:failure];
    
}

+ (void)getFeedBackListWithaccessToken:(NSString *)accessToken
                               andpage:(NSString *)page
                              andlimit:(NSString *)limit
                                sccess:(void (^)(NSDictionary *responseObject))success
                               failure:(void(^)(NSError *error))failure {
    
    NSMutableDictionary *dic = [[NSMutableDictionary alloc]initWithCapacity:1];
    dic[@"accessToken"] = accessToken;
    dic[@"page"] = page;
    dic[@"limit"] = limit;
    [self asyncNetworkingUrl:@"/interfaceYou/feedBackList" andDict:dic success:success failure:failure];
}

+ (void)addFeedbackZanWithaccessToken:(NSString *)accessToken
                          feedback_id:(NSString *)feedback_id
                               sccess:(void (^)(NSDictionary *responseObject))success
                              failure:(void(^)(NSError *error))failure{
    NSMutableDictionary *dic = [[NSMutableDictionary alloc]initWithCapacity:1];
    dic[@"accessToken"] = accessToken;
    dic[@"feedback_id"] = feedback_id;
    [self asyncNetworkingUrl:@"/interfaceYou/addFeedbackZan" andDict:dic success:success failure:failure];
}

+ (void)delFeedbackZanWithaccessToken:(NSString *)accessToken
                          feedback_id:(NSString *)feedback_id
                               sccess:(void (^)(NSDictionary *responseObject))success
                              failure:(void(^)(NSError *error))failure {
    NSMutableDictionary *dic = [[NSMutableDictionary alloc]initWithCapacity:1];
    dic[@"accessToken"] = accessToken;
    dic[@"feedback_id"] = feedback_id;
    [self asyncNetworkingUrl:@"/interfaceYou/delFeedbackZan" andDict:dic success:success failure:failure];
}


+ (void)uploadImagesWithaccessToken:(NSString *)accessToken
                             images:(NSDictionary *)images
                             sccess:(void (^)(NSDictionary *responseObject))success
                            failure:(void(^)(NSError *error))failure {
    NSMutableDictionary *dic = [[NSMutableDictionary alloc]initWithCapacity:1];
    dic[@"accessToken"] = accessToken;
    dic[@"images"] = images;
    [self asyncNetworkingUrl:@"/interfaceYou/uploadImages" andDict:dic success:success failure:failure];

}

+ (void)addfeedBackWithaccessToken:(NSString *)accessToken
                              tuid:(NSString *)tuid
                     to_comment_id:(NSString *)to_comment_id
                           comment:(NSString *)comment
                            images:(NSString *)images
                        is_comment:(NSString *)is_comment
                            sccess:(void (^)(NSDictionary *responseObject))success
                           failure:(void(^)(NSError *error))failure{
    NSMutableDictionary *dic = [[NSMutableDictionary alloc]initWithCapacity:1];
    dic[@"accessToken"] = accessToken;
    dic[@"tuid"] = tuid;
    dic[@"to_comment_id"] = to_comment_id;
    dic[@"images"] = images;
    dic[@"comment"] = comment;
    dic[@"is_comment"] = is_comment;
    [self asyncNetworkingUrl:@"/interfaceYou/addfeedBack" andDict:dic success:success failure:failure];
}

+ (void)getmyCommentListWithaccessToken:(NSString *)accessToken
                                andpage:(NSString *)page
                               andlimit:(NSString *)limit
                                 sccess:(void (^)(NSDictionary *responseObject))success
                                failure:(void(^)(NSError *error))failure{
    NSMutableDictionary *dic = [[NSMutableDictionary alloc]initWithCapacity:1];
    dic[@"accessToken"] = accessToken;
    dic[@"page"] = page;
    dic[@"limit"] = limit;
    [self asyncNetworkingUrl:@"/interface/myCommentList" andDict:dic success:success failure:failure];
}

+ (void)getpostinfoWithpost_id:(NSString *)post_id
                       andpage:(NSString *)page
                      andlimit:(NSString *)limit
                        sccess:(void (^)(NSDictionary *responseObject))success
                       failure:(void(^)(NSError *error))failure {
    NSMutableDictionary *dic = [[NSMutableDictionary alloc]initWithCapacity:1];
    dic[@"post_id"] = post_id;
    dic[@"page"] = page;
    dic[@"limit"] = limit;
    [self asyncNetworkingUrl:@"/interfaceNew/postDetail" andDict:dic success:success failure:failure];
}

+ (void)getlistUserKeywordWithaccessToken:(NSString *)accessToken
                                   sccess:(void (^)(NSDictionary *responseObject))success
                                  failure:(void(^)(NSError *error))failure {
    NSMutableDictionary *dic = [[NSMutableDictionary alloc]initWithCapacity:1];
    dic[@"accessToken"] = accessToken;
    [self asyncNetworkingUrl:@"/interface/listUserKeyword" andDict:dic success:success failure:failure];
}

+ (void)addUserKeywordWithaccessToken:(NSString *)accessToken
                              keyword:(NSString *)keyword
                               sccess:(void (^)(NSDictionary *responseObject))success
                              failure:(void(^)(NSError *error))failure{
    NSMutableDictionary *dic = [[NSMutableDictionary alloc]initWithCapacity:1];
    dic[@"accessToken"] = accessToken;
    dic[@"keyword"] = keyword;
    [self asyncNetworkingUrl:@"/interface/addUserKeyword" andDict:dic success:success failure:failure];
}

+ (void)frequencykeywordWithaccessToken:(NSString *)accessToken
                                   k_id:(NSString *)k_id
                                 sccess:(void (^)(NSDictionary *responseObject))success
                                failure:(void(^)(NSError *error))failure {
    NSMutableDictionary *dic = [[NSMutableDictionary alloc]initWithCapacity:1];
    dic[@"accessToken"] = accessToken;
    dic[@"k_id"] = k_id;
    [self asyncNetworkingUrl:@"/interface/frequencykeyword" andDict:dic success:success failure:failure];
}

+ (void)matchCellphoneWithcellphone:(NSString *)cellphone
                             sccess:(void (^)(NSDictionary *responseObject))success
                            failure:(void(^)(NSError *error))failure {
    NSMutableDictionary *dic = [[NSMutableDictionary alloc]initWithCapacity:1];
    dic[@"cellphone"] = cellphone;
    [self asyncNetworkingUrl:@"/interface/cellphone" andDict:dic success:success failure:failure];
}

+ (void)getPlaceListWithoutParameter:(NSString *)parameter sccess:(void (^)(NSDictionary *responseObject))success failure:(void(^)(NSError *error))failure{
    NSMutableDictionary *dic = [[NSMutableDictionary alloc]initWithCapacity:1];
    dic[@"parameter"] = parameter;
    [self asyncNetworkingUrl:@"/interfaceYou/placelist" andDict:dic success:success failure:failure];
}

+ (void)delCommentWithaccessToken:(NSString *)accessToken
                       comment_id:(NSString *)comment_id
                           sccess:(void (^)(NSDictionary *responseObject))success
                          failure:(void(^)(NSError *error))failure{
    NSMutableDictionary *dic = [[NSMutableDictionary alloc]initWithCapacity:1];
    dic[@"accessToken"] = accessToken;
    dic[@"id"] = comment_id;
    [self asyncNetworkingUrl:@"/interface/delComment" andDict:dic success:success failure:failure];
}

+ (void)delActWithaccessToken:(NSString *)accessToken
                       act_id:(NSString *)act_id
                       sccess:(void (^)(NSDictionary *responseObject))success
                      failure:(void(^)(NSError *error))failure{
    NSMutableDictionary *dic = [[NSMutableDictionary alloc]initWithCapacity:1];
    dic[@"accessToken"] = accessToken;
    dic[@"ac_id"] = act_id;
    [self asyncNetworkingUrl:@"/interface/delAct" andDict:dic success:success failure:failure];
}

+ (void)getLinsteningCircleListWithaccessToken:(NSString *)accessToken
                                       andpage:(NSString *)page
                                      andlimit:(NSString *)limit
                                        sccess:(void (^)(NSDictionary *responseObject))success
                                       failure:(void(^)(NSError *error))failure {
    NSMutableDictionary *dic = [[NSMutableDictionary alloc]initWithCapacity:1];
    dic[@"accessToken"] = accessToken;
    dic[@"page"] = page;
    dic[@"limit"] = limit;
    [self asyncNetworkingUrl:@"/interfaceYou/friendDynamics" andDict:dic success:success failure:failure];
    
}

+ (void)addAndCancelPraiseWithaccessToken:(NSString *)accessToken
                              comments_id:(NSString *)comments_id
                                   sccess:(void (^)(NSDictionary *responseObject))success
                                  failure:(void (^)(NSError *error))failure{
    
    NSMutableDictionary *dic = [[NSMutableDictionary alloc]initWithCapacity:1];
    dic[@"accessToken"] = accessToken;
    dic[@"comments_id"] = comments_id;
    [self asyncNetworkingUrl:@"/interface/addAndCancelPraise" andDict:dic success:success failure:failure];
    
}

+ (void)uploadMpVoiceWithaccessToken:(NSString *)accessToken
                                file:(NSString *)file
                            playtime:(NSString *)playtime
                              sccess:(void (^)(NSDictionary *responseObject))success
                             failure:(void (^)(NSError *error))failure{
    NSMutableDictionary *dic = [[NSMutableDictionary alloc]initWithCapacity:1];
    dic[@"accessToken"] = accessToken;
    dic[@"playtime"] = playtime;
    [self asyncNetworkingUrl:@"/interfaceYou/uploadMpVoice" andDict:dic success:success failure:failure];
}


+ (void)addLinsteningCircleWithaccessToken:(NSString *)accessToken
                                    to_uid:(NSString *)to_uid
                                   mp3_url:(NSString *)mp3_url
                                  play_time:(NSString *)play_time
                                   timages:(NSString *)timages
                                   content:(NSString *)content
                                comment_id:(NSString *)comment_id
                                    sccess:(void (^)(NSDictionary *responseObject))success
                                   failure:(void (^)(NSError *error))failure {
    NSMutableDictionary *dic = [[NSMutableDictionary alloc]initWithCapacity:1];
    dic[@"accessToken"] = accessToken;
    dic[@"to_uid"] = to_uid;
    dic[@"mp3_url"] = mp3_url;
    dic[@"play_time"] = play_time;
    dic[@"timages"] = timages;
    dic[@"content"] = content;
    dic[@"comment_id"] = comment_id;
    [self asyncNetworkingUrl:@"/interfaceYou/fabiao" andDict:dic success:success failure:failure];
    
}

+ (void)addfriendDynamicsPingLunWithaccessToken:(NSString *)accessToken
                                        post_id:(NSString *)post_id
                                     comment_id:(NSString *)comment_id
                                         to_uid:(NSString *)to_uid
                                        content:(NSString *)content
                                         sccess:(void (^)(NSDictionary *responseObject))success
                                        failure:(void (^)(NSError *error))failure{
    NSMutableDictionary *dic = [[NSMutableDictionary alloc]initWithCapacity:1];
    dic[@"accessToken"] = accessToken;
    dic[@"post_id"] = post_id;
    dic[@"comment_id"] = comment_id;
    dic[@"to_uid"] = to_uid;
    dic[@"content"] = content;
    [self asyncNetworkingUrl:@"/interfaceYou/pinglun" andDict:dic success:success failure:failure];
    
}

+ (void)pingbiLinsteningCircleWithaccessToken:(NSString *)accessToken
                                       to_uid:(NSString *)to_uid
                                       sccess:(void (^)(NSDictionary *responseObject))success
                                      failure:(void (^)(NSError *error))failure{
    NSMutableDictionary *dic = [[NSMutableDictionary alloc]initWithCapacity:1];
    dic[@"accessToken"] = accessToken;
    dic[@"to_uid"] = to_uid;
    [self asyncNetworkingUrl:@"/interfaceYou/pingbi" andDict:dic success:success failure:failure];
}

+ (void)tousuLinsteningCircleWithaccessToken:(NSString *)accessToken
                                      to_uid:(NSString *)to_uid
                                  comment_id:(NSString *)comment_id
                                     content:(NSString *)content
                                      sccess:(void (^)(NSDictionary *responseObject))success
                                     failure:(void (^)(NSError *error))failure{
    NSMutableDictionary *dic = [[NSMutableDictionary alloc]initWithCapacity:1];
    dic[@"accessToken"] = accessToken;
    dic[@"to_uid"] = to_uid;
    dic[@"comment_id"] = comment_id;
    dic[@"content"] = content;
    [self asyncNetworkingUrl:@"/interfaceYou/tousu" andDict:dic success:success failure:failure];
}

+ (void)getAddcriticismNumWithaccessToken:(NSString *)accessToken
                                  andpage:(NSString *)page
                                 andlimit:(NSString *)limit
                                  anddate:(NSString *)date
                                   sccess:(void (^)(NSDictionary *responseObject))success
                                  failure:(void (^)(NSError *error))failure{
    NSMutableDictionary *dic = [[NSMutableDictionary alloc]initWithCapacity:1];
    dic[@"accessToken"] = accessToken;
    dic[@"page"] = page;
    dic[@"limit"] = limit;
    dic[@"date"] = date;
    [self asyncNetworkingUrl:@"/interface/addcriticism" andDict:dic success:success failure:failure];
}

+ (void)getNewPromptForMeWithaccessToken:(NSString *)accessToken
                                 andpage:(NSString *)page
                                andlimit:(NSString *)limit
                                  sccess:(void (^)(NSDictionary *responseObject))success
                                 failure:(void(^)(NSError *error))failure{
    NSMutableDictionary *dic = [[NSMutableDictionary alloc]initWithCapacity:1];
    dic[@"accessToken"] = accessToken;
    dic[@"page"] = page;
    dic[@"limit"] = limit;
    [self asyncNetworkingUrl:@"/interfaceYou/newPromptForMe" andDict:dic success:success failure:failure];
}

+ (void)getFeedbackForMeWithaccessToken:(NSString *)accessToken
                                 sccess:(void (^)(NSDictionary *responseObject))success
                                failure:(void(^)(NSError *error))failure{
    NSMutableDictionary *dic = [[NSMutableDictionary alloc]initWithCapacity:1];
    dic[@"accessToken"] = accessToken;
    [self asyncNetworkingUrl:@"/interfaceYou/feedbackForMe" andDict:dic success:success failure:failure];
}

+ (void)feedbackGetOneWithaccessToken:(NSString *)accessToken
                          feedback_id:(NSString *)feedback_id
                               sccess:(void (^)(NSDictionary *responseObject))success
                              failure:(void(^)(NSError *error))failure{
    NSMutableDictionary *dic = [[NSMutableDictionary alloc]initWithCapacity:1];
    dic[@"accessToken"] = accessToken;
    dic[@"feedback_id"] = feedback_id;
    [self asyncNetworkingUrl:@"/interfaceYou/feedbackGetOne" andDict:dic success:success failure:failure];
}

+ (void)newPromptGetOneWithaccessToken:(NSString *)accessToken
                              parentid:(NSString *)parentid
                                  path:(NSString *)path
                                sccess:(void (^)(NSDictionary *responseObject))success
                               failure:(void(^)(NSError *error))failure{
    NSMutableDictionary *dic = [[NSMutableDictionary alloc]initWithCapacity:1];
    dic[@"accessToken"] = accessToken;
    dic[@"parentid"] = parentid;
    dic[@"path"] = path;
    [self asyncNetworkingUrl:@"/interfaceYou/newPromptGetOne" andDict:dic success:success failure:failure];
}

+ (void)getPostDetailWithaccessToken:(NSString *)accessToken
                             post_id:(NSString *)post_id
                              sccess:(void (^)(NSDictionary *responseObject))success
                             failure:(void(^)(NSError *error))failure{
    
    NSMutableDictionary *dic = [[NSMutableDictionary alloc]initWithCapacity:1];
    dic[@"accessToken"] = accessToken;
    dic[@"post_id"] = post_id;
    [self asyncNetworkingUrl:@"/interfaceNew/postDetail" andDict:dic success:success failure:failure];
}

+ (void)getAwardListWithaccessToken:(NSString *)accessToken
                            post_id:(NSString *)post_id
                             act_id:(NSString *)act_id
                             sccess:(void (^)(NSDictionary *responseObject))success
                            failure:(void(^)(NSError *error))failure{
    NSMutableDictionary *dic = [[NSMutableDictionary alloc]initWithCapacity:1];
    dic[@"accessToken"] = accessToken;
    dic[@"post_id"] = post_id;
    dic[@"act_id"] = act_id;
    [self asyncNetworkingUrl:@"/interfaceNew/awardList" andDict:dic success:success failure:failure];
}


+ (void)getListenMoneyWithaccessToken:(NSString *)accessToken
                               sccess:(void (^)(NSDictionary *responseObject))success
                              failure:(void(^)(NSError *error))failure{
    NSMutableDictionary *dic = [[NSMutableDictionary alloc]initWithCapacity:1];
    dic[@"accessToken"] = accessToken;
    [self asyncNetworkingUrl:@"/interfaceNew/listen_money" andDict:dic success:success failure:failure];
}


+ (void)uploadzhinewWithuid:(NSString *)uid
                   trade_id:(NSString *)trade_id
                       tpye:(NSString *)type
                 total_fees:(NSString *)total_fees
                   Ratetime:(NSString *)Ratetime
                     sccess:(void (^)(NSDictionary *responseObject))success
                    failure:(void(^)(NSError *error))failure{
    NSMutableDictionary *dic = [[NSMutableDictionary alloc]initWithCapacity:1];
    dic[@"uid"] = uid;
    dic[@"trade_id"] = trade_id;
    dic[@"type"] = type;
    dic[@"total_fees"] = total_fees;
    dic[@"Ratetime"] = Ratetime;
    [self asyncNetworkingUrl:@"/interface/zhinew" andDict:dic success:success failure:failure];
    
}


+ (void)netwokingPostZhiFu:(NSString *)postString andParameters:(NSDictionary *)parameters success:(void (^)(id))block failure:(void (^)())blockFailure {
    //    NSLog(@"%@", parameters);
    
    @autoreleasepool {
        [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];
        if (!Greater_Than_IOS6) {
            AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
            manager.responseSerializer.acceptableContentTypes = [NSSet setWithObject:@"text/html"];
            
            [manager POST:[NSString stringWithFormat:@"http://admin.tingwen.me/index.php/api/interface/%@", postString] parameters:parameters success:^(AFHTTPRequestOperation *operation, id responseObject) {
                block(responseObject);
                [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
                
            } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                //网络监听
//                [[NetworkingMangater sharedManager] networkingState];
            }];
        }else {
            AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
            manager.requestSerializer.timeoutInterval = 40;
            manager.responseSerializer.acceptableContentTypes = [NSSet setWithObject:@"text/html"];
            [manager POST:postString parameters:parameters success:^(NSURLSessionDataTask *task, id responseObject) {
                block(responseObject);
                [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
            } failure:^(NSURLSessionDataTask *task, NSError *error) {
                blockFailure();
            }];
            //            NSLog(@"operation : %@", @([AFHTTPSessionManager manager].operationQueue.operations.count));
            
        }
    }
}

+ (void)listenMoneyRechargeWithaccessToken:(NSString *)accessToken
                              listen_money:(NSString *)listen_money
                                    act_id:(NSString *)act_id
                                   post_id:(NSString *)post_id
                                      type:(NSString *)type
                                    sccess:(void (^)(NSDictionary *responseObject))success
                                   failure:(void(^)(NSError *error))failure{
    NSMutableDictionary *dic = [[NSMutableDictionary alloc]initWithCapacity:1];
    dic[@"accessToken"] = accessToken;
    dic[@"listen_money"] = listen_money;
    dic[@"type"] = type;
    dic[@"act_id"] = act_id;
    dic[@"post_id"] = post_id;
    [self asyncNetworkingUrl:@"/interfaceNew/listenMoneyUse" andDict:dic success:success failure:failure];
}

+ (void)rewardedMessageWithaccessToken:(NSString *)accessToken
                                act_id:(NSString *)act_id
                               message:(NSString *)message
                                sccess:(void (^)(NSDictionary *responseObject))success
                               failure:(void(^)(NSError *error))failure{
    NSMutableDictionary *dic = [[NSMutableDictionary alloc]initWithCapacity:1];
    dic[@"accessToken"] = accessToken;
    dic[@"message"] = message;
    dic[@"act_id"] = act_id;
    [self asyncNetworkingUrl:@"/interfaceNew/message" andDict:dic success:success failure:failure];
}

+ (void)getMySubscribeWithaccessToken:(NSString *)accessToken
                                limit:(NSString *)limit
                               sccess:(void (^)(NSDictionary *responseObject))success
                              failure:(void(^)(NSError *error))failure{
    NSMutableDictionary *dic = [[NSMutableDictionary alloc]initWithCapacity:1];
    dic[@"accessToken"] = accessToken;
    dic[@"limit"] = limit;
    [self asyncNetworkingUrl:@"/interfaceNew/subscribe" andDict:dic success:success failure:failure];
}

+ (void)getMyuserinfoWithaccessToken:(NSString *)accessToken
                             user_id:(NSString *)user_id
                              sccess:(void (^)(NSDictionary *responseObject))success
                             failure:(void(^)(NSError *error))failure{
    NSMutableDictionary *dic = [[NSMutableDictionary alloc]initWithCapacity:1];
    dic[@"accessToken"] = accessToken;
    dic[@"user_id"] = user_id;
    [self asyncNetworkingUrl:@"/interfaceNew/userinfo" andDict:dic success:success failure:failure];
}

+ (void)signInWithaccessToken:(NSString *)accessToken
                       sccess:(void (^)(NSDictionary *responseObject))success
                      failure:(void(^)(NSError *error))failure{
    NSMutableDictionary *dic = [[NSMutableDictionary alloc]initWithCapacity:1];
    dic[@"accessToken"] = accessToken;
    [self asyncNetworkingUrl:@"/interfaceNew/sign" andDict:dic success:success failure:failure];
}

+ (void)getZs_lisMoneySccess:(void (^)(NSDictionary *responseObject))success
                     failure:(void(^)(NSError *error))failure{
    [self asyncNetworkingUrl:@"/interfaceNew/zs_lisMoney" andDict:nil success:success failure:failure];
    
}

+ (void)listenMoneyRechargeWithaccessToken:(NSString *)accessToken
                              listen_money:(NSString *)listen_money
                                      type:(NSString *)type
                                    sccess:(void (^)(NSDictionary *responseObject))success
                                   failure:(void(^)(NSError *error))failure{
    NSMutableDictionary *dic = [[NSMutableDictionary alloc]initWithCapacity:1];
    dic[@"accessToken"] = accessToken;
    dic[@"listen_money"] = listen_money;
    dic[@"type"] = type;
    [self asyncNetworkingUrl:@"/interfaceNew/listenMoneyRecharge" andDict:dic success:success failure:failure];
}

+ (void)use_recordWithaccessToken:(NSString *)accessToken
                           sccess:(void (^)(NSDictionary *responseObject))success
                          failure:(void(^)(NSError *error))failure{
    NSMutableDictionary *dic = [[NSMutableDictionary alloc]initWithCapacity:1];
    dic[@"accessToken"] = accessToken;
    [self asyncNetworkingUrl:@"/interfaceNew/use_record" andDict:dic success:success failure:failure];
}

+ (void)recharge_recordWithaccessToken:(NSString *)accessToken
                                sccess:(void (^)(NSDictionary *responseObject))success
                               failure:(void(^)(NSError *error))failure{
    NSMutableDictionary *dic = [[NSMutableDictionary alloc]initWithCapacity:1];
    dic[@"accessToken"] = accessToken;
    [self asyncNetworkingUrl:@"/interfaceNew/recharge_record" andDict:dic success:success failure:failure];
}

+ (void)goldUseWithaccessToken:(NSString *)accessToken
                        act_id:(NSString *)act_id
                       post_id:(NSString *)post_id
                        sccess:(void (^)(NSDictionary *responseObject))success
                       failure:(void(^)(NSError *error))failure{
    NSMutableDictionary *dic = [[NSMutableDictionary alloc]initWithCapacity:1];
    dic[@"accessToken"] = accessToken;
    dic[@"act_id"] = act_id;
    dic[@"post_id"] = post_id;
    [self asyncNetworkingUrl:@"/interfaceNew/goldUse" andDict:dic success:success failure:failure];
}

+ (void)getFan_boardWithact_id:(NSString *)act_id
                        sccess:(void (^)(NSDictionary *responseObject))success
                       failure:(void(^)(NSError *error))failure{
    NSMutableDictionary *dic = [[NSMutableDictionary alloc]initWithCapacity:1];
    dic[@"act_id"] = act_id;
    [self asyncNetworkingUrl:@"/interfaceNew/fan_board" andDict:dic success:success failure:failure];
}

+ (void)getZan_boardWithaccessToken:(NSString *)accessToken
                             act_id:(NSString *)act_id
                             sccess:(void (^)(NSDictionary *responseObject))success
                            failure:(void(^)(NSError *error))failure{
    NSMutableDictionary *dic = [[NSMutableDictionary alloc]initWithCapacity:1];
    dic[@"accessToken"] = accessToken;
    dic[@"act_id"] = act_id;
    [self asyncNetworkingUrl:@"/interfaceNew/zan_board" andDict:dic success:success failure:failure];
}

+ (void)getAppVersionSccess:(void (^)(NSDictionary *responseObject))success
                    failure:(void(^)(NSError *error))failure{
    [self asyncNetworkingUrl:@"/interfaceNew/getVersion" andDict:nil success:success failure:failure];
}

+ (void)collectionPostNewsWithaccessToken:(NSString *)accessToken
                                  post_id:(NSString *)post_id
                                   sccess:(void (^)(NSDictionary *responseObject))success
                                  failure:(void(^)(NSError *error))failure{
    NSMutableDictionary *dic = [[NSMutableDictionary alloc]initWithCapacity:1];
    dic[@"accessToken"] = accessToken;
    dic[@"post_id"] = post_id;
    [self asyncNetworkingUrl:@"/interfaceNew/collection" andDict:dic success:success failure:failure];
}

+ (void)get_collectionWithaccessToken:(NSString *)accessToken
                               sccess:(void (^)(NSDictionary *responseObject))success
                              failure:(void(^)(NSError *error))failure{
    NSMutableDictionary *dic = [[NSMutableDictionary alloc]initWithCapacity:1];
    dic[@"accessToken"] = accessToken;
    [self asyncNetworkingUrl:@"/interfaceNew/get_collection" andDict:dic success:success failure:failure];
}

+ (void)del_collectionWithaccessToken:(NSString *)accessToken
                              post_id:(NSString *)post_id
                               sccess:(void (^)(NSDictionary *responseObject))success
                              failure:(void(^)(NSError *error))failure{
    NSMutableDictionary *dic = [[NSMutableDictionary alloc]initWithCapacity:1];
    dic[@"accessToken"] = accessToken;
    dic[@"post_id"] = post_id;
    [self asyncNetworkingUrl:@"/interfaceNew/del_collection" andDict:dic success:success failure:failure];
}

+ (void)getWechatAccess_tokenWithSSOCode:(NSString *)code
                                 success:(void (^)(NSDictionary *responseObject))success
                                failture:(void(^)(NSError *error))failure{
    NSMutableDictionary *dic = [[NSMutableDictionary alloc]initWithCapacity:1];
    dic[@"code"] = code;
    [self syncNetworkingUrl:nil andDict:dic success:success failure:failure];
}

+ (void)getColumnListWithaccessToken:(NSString *)accessToken
                             andPage:(NSString *)page
                            andLimit:(NSString *)limit
                              sccess:(void (^)(NSDictionary *responseObject))success
                             failure:(void (^)(NSError *error))failure{
    NSMutableDictionary *dic = [[NSMutableDictionary alloc]initWithCapacity:1];
    dic[@"accessToken"] = accessToken;
    dic[@"page"] = page;
    dic[@"limit"] = limit;
    [self asyncNetworkingUrl:@"/interfaceNew/columnList" andDict:dic success:success failure:failure];
}

+ (void)getInformationListWithaccessToken:(NSString *)accessToken
                                  andPage:(NSString *)page
                                 andLimit:(NSString *)limit
                                   sccess:(void (^)(NSDictionary *responseObject))success
                                  failure:(void (^)(NSError *error))failure{
    NSMutableDictionary *dic = [[NSMutableDictionary alloc]initWithCapacity:1];
    dic[@"accessToken"] = accessToken;
    dic[@"page"] = page;
    dic[@"limit"] = limit;
    [self asyncNetworkingUrl:@"/interfaceNew/information" andDict:dic success:success failure:failure];
}

+ (void)getClassroomListWithaccessToken:(NSString *)accessToken
                                andPage:(NSString *)page
                               andLimit:(NSString *)limit
                                 sccess:(void (^)(NSDictionary *responseObject))success
                                failure:(void (^)(NSError *error))failure{
    NSMutableDictionary *dic = [[NSMutableDictionary alloc]initWithCapacity:1];
    dic[@"accessToken"] = accessToken;
    dic[@"page"] = page;
    dic[@"limit"] = limit;
    [self asyncNetworkingUrl:@"/interfaceNew/classroom" andDict:dic success:success failure:failure];
}

+ (void)getAuditionListWithaccessToken:(NSString *)accessToken
                                act_id:(NSString *)act_id
                                sccess:(void (^)(NSDictionary *responseObject))success
                               failure:(void (^)(NSError *error))failure{
    NSMutableDictionary *dic = [[NSMutableDictionary alloc]initWithCapacity:1];
    dic[@"accessToken"] = accessToken;
    dic[@"act_id"] = act_id;
    [self asyncNetworkingUrl:@"/interfaceNew/audition" andDict:dic success:success failure:failure];
    
}

+ (void)get_orderWithaccessToken:(NSString *)accessToken
                          act_id:(NSString *)act_id
                          sccess:(void (^)(NSDictionary *responseObject))success
                         failure:(void (^)(NSError *error))failure{
    NSMutableDictionary *dic = [[NSMutableDictionary alloc]initWithCapacity:1];
    dic[@"accessToken"] = accessToken;
    dic[@"act_id"] = act_id;
    [self asyncNetworkingUrl:@"/interfaceNew/get_order" andDict:dic success:success failure:failure];
}

@end
