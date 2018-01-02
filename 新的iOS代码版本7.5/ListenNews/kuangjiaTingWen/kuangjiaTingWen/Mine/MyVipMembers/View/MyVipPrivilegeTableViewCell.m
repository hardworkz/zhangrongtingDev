//
//  MyVipPrivilegeTableViewCell.m
//  kuangjiaTingWen
//
//  Created by 泡果 on 2017/7/19.
//  Copyright © 2017年 zhimi. All rights reserved.
//

#import "MyVipPrivilegeTableViewCell.h"

@interface MyVipPrivilegeTableViewCell()
{
    UITextView *textView;
}
@end
static NSString *const VIPContent = @"普通会员:\n1.每日可收听新闻数不限\n2.可使用批量下载功能\n3.拥有尊贵VIP标识\n超级会员:\n1.享有普通会员全部特权\n2.可收听听闻课堂所有内容\n3.在听闻线下活动中拥有一次VIP席位\n温馨提示:\n1.会员服务一经开通后，不支持退款\n2.购买之后若还是无法正常使用，请尝试重启听闻客户端\n\n";/**<vip内容介绍*/

@implementation MyVipPrivilegeTableViewCell
+ (NSString *)ID
{
    return @"MyVipPrivilegeTableViewCell";
}
+(MyVipPrivilegeTableViewCell *)cellWithTableView:(UITableView *)tableView
{
    MyVipPrivilegeTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:[MyVipPrivilegeTableViewCell ID]];
    if (cell == nil) {
        cell = [[MyVipPrivilegeTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:[MyVipPrivilegeTableViewCell ID]];
    }
    return cell;
}
- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        self.backgroundColor = ColorWithRGBA(249, 247, 247, 1);
        
        textView = [[UITextView alloc] initWithFrame:CGRectMake(10, 0, SCREEN_WIDTH, SCREEN_HEIGHT - (90 + 60 + 4 * 44 + 64))];
        textView.editable = NO;
        textView.backgroundColor = ColorWithRGBA(249, 247, 247, 1);
        textView.textColor = [UIColor lightGrayColor];
        textView.text = VIPContent;
        textView.font = CUSTOM_FONT_TYPE(12.0);
        textView.scrollEnabled = NO;
        [self.contentView addSubview:textView];
    }
    return self;
}
@end
