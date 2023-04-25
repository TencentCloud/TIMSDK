//
//  MyCustomCell.h
//  TUIKitDemo
//
//  Created by annidyfeng on 2019/6/10.
//  Copyright © 2019年 Tencent. All rights reserved.
//

#import <TIMCommon/TUIMessageCell.h>
#import "TUILinkCellData.h"
#import <TIMCommon/TUIBubbleMessageCell.h>
NS_ASSUME_NONNULL_BEGIN

@interface TUILinkCell : TUIBubbleMessageCell
@property UILabel *myTextLabel;
@property UILabel *myLinkLabel;

@property TUILinkCellData *customData;
- (void)fillWithData:(TUILinkCellData *)data;

@end

NS_ASSUME_NONNULL_END
