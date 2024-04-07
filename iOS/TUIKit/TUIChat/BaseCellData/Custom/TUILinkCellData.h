//
//  MyCustomCellData.h
//  TUIKitDemo
//
//  Created by annidyfeng on 2019/6/10.
//  Copyright © 2019 Tencent. All rights reserved.
//
#import <TIMCommon/TUIBubbleMessageCellData.h>
#import <TIMCommon/TUIMessageCellData.h>
NS_ASSUME_NONNULL_BEGIN

@interface TUILinkCellData : TUIBubbleMessageCellData

@property NSString *text;
@property NSString *link;

@end

NS_ASSUME_NONNULL_END
