//
//  MyCustomCellData.h
//  TUIKitDemo
//
//  Created by annidyfeng on 2019/6/10.
//  Copyright © 2019年 Tencent. All rights reserved.
//
#import "TUIMessageCellData.h"
#import "TUIBubbleMessageCellData_Minimalist.h"
NS_ASSUME_NONNULL_BEGIN

@interface TUILinkCellData_Minimalist : TUIBubbleMessageCellData_Minimalist

@property NSString *text;
@property NSString *link;

@end

NS_ASSUME_NONNULL_END
