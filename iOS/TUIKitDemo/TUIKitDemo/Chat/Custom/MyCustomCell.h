//
//  MyCustomCell.h
//  TUIKitDemo
//
//  Created by annidyfeng on 2019/6/10.
//  Copyright © 2019年 Tencent. All rights reserved.
//

#import "TUIMessageCell.h"
#import "MyCustomCellData.h"

NS_ASSUME_NONNULL_BEGIN

@interface MyCustomCell : TUIMessageCell
@property UILabel *myTextLabel;
@property UILabel *myLinkLabel;

@property MyCustomCellData *customData;
- (void)fillWithData:(MyCustomCellData *)data;

@end

NS_ASSUME_NONNULL_END
