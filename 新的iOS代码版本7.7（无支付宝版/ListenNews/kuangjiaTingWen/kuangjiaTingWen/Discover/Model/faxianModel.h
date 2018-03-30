//
//  faxianModel.h
//  kuangjiaTingWen
//
//  Created by 泡果 on 2017/6/16.
//  Copyright © 2017年 zhimi. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface faxianModel : NSObject
@property (strong, nonatomic) NSString *ID;/**<组类型ID */
@property (strong, nonatomic) NSString *type;/**<组类型 */
@property (strong, nonatomic) NSArray *data;/**<组数据 */
@end
