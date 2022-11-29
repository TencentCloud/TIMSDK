//
//  MyCustomCell.h
//  TUIKitDemo
//
//  Created by annidyfeng on 2019/6/10.
//  Copyright © 2019年 Tencent. All rights reserved.
//

#import "TUIMessageCell.h"
#import "TUILinkCellData_Minimalist.h"
#import "TUIBubbleMessageCell_Minimalist.h"
NS_ASSUME_NONNULL_BEGIN

@interface TUILinkCell_Minimalist : TUIBubbleMessageCell_Minimalist
@property UILabel *myTextLabel;
@property UILabel *myLinkLabel;

@property TUILinkCellData_Minimalist *customData;
- (void)fillWithData:(TUILinkCellData_Minimalist *)data;

@end

NS_ASSUME_NONNULL_END
