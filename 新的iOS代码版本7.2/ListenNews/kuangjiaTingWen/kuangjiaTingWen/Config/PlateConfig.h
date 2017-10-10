//
//  PlateConfig.h
//  lantu
//
//  Created by Eric Wang on 16/2/20.
//  Copyright © 2016年 Eric. All rights reserved.
//

#ifndef PlateConfig_h
#define PlateConfig_h


#if IsParent_APP

#else


//#define gMainColor [UIColor colorWithRed:0/255.0 green:159/255.0 blue:240/255.0 alpha:1]
#define gMainColor UIColorFromHex(0x5cb8e6)

#define gSubColor [UIColor colorWithRed:238/255.0 green:238/255.0 blue:238/255.0 alpha:1]


#define gNewsSubColor [UIColor colorWithRed:239/255.0 green:239/255.0 blue:244/255.0 alpha:1]

//关注、留言、粉丝按钮的背景颜色
#define gButtonAssist [UIColor colorWithRed:0.18 green:0.15 blue:0.14 alpha:0.6]

#define gTextColorMain UIColorFromHex(0xffffff)
//辅助说明
//#define gTextColorSub UIColorFromHex(0x999999)
#define gTextColorSub UIColorFromHex(0x8899a6)
//标题
#define gTextDownload UIColorFromHex(0x222222)
//分隔线
#define gThinLineColor UIColorFromHex(0xd7d7d7)
//介绍、辅助说明
#define gTextColorAssist UIColorFromHexWithAlpha(0xffffff,0.6)
//图片外圈
#define gImageBorderColor UIColorFromHexWithAlpha(0xffffff,0.5)

#define gImageMarkColor UIColorFromHexWithAlpha(0x000000,0.15)

//打赏框颜色
#define gTextRewardColor UIColorFromHex(0xf7c323)
//打赏框颜色
#define gButtonRewardColor UIColorFromHex(0xf67825)


#define gAllVCBackgroundColor UIColorFromHex(0xf1f1f1)
//#define gMainColor UIColorFromHex(0x31426b)
#define gThickLineColor UIColorFromHex(0xf2f2f2)

#define gTextColorBackground UIColorFromHex(0x666666)

#define gFontSelected34 [UIFont systemFontOfSize:34.0]
#define gFontSelected25 [UIFont systemFontOfSize:25.0]
#define gFontSelected24 [UIFont systemFontOfSize:24.0]
#define gFontSelected23 [UIFont systemFontOfSize:23.0]
#define gFontSelected21 [UIFont systemFontOfSize:21.0]
#define gFontSelected20 [UIFont systemFontOfSize:20.0]
#define gFontSelected19 [UIFont systemFontOfSize:19.0]
#define gFontSelected18 [UIFont systemFontOfSize:18.0]

#define gFontMajor17 [UIFont systemFontOfSize:17.0]
#define gFontMajor16 [UIFont systemFontOfSize:16.0]
#define gFontMain15 [UIFont systemFontOfSize:15.0]
#define gFontMain14 [UIFont systemFontOfSize:14.0]
#define gFontMain13 [UIFont systemFontOfSize:13.0]
#define gFontMain12 [UIFont systemFontOfSize:12.0]
#define gFontSub11 [UIFont systemFontOfSize:11.0]
#define gFontDetail9 [UIFont systemFontOfSize:9.0]

//新版色调

#define nMainColor UIColorFromHex(0x5cb8e6)
#define nSubColor UIColorFromHex(0xc0c7cc)

#define nTextColorMain UIColorFromHex(0x2e3133)
#define nTextColorSub UIColorFromHex(0x8899a6)
#define nMineNameColor UIColorFromHex(0xe1e4e6)
//课堂购买特别颜色
#define purchaseButtonColor [UIColor colorWithHue:0.99 saturation:0.78 brightness:0.70 alpha:1.00]

#endif


#endif /* PlateConfig_h */
