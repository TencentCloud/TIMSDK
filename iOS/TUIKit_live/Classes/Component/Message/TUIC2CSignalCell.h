//
//  TUIC2CSignalCell.h
//  TUIKitDemo
//
//  Copyright © 2019年 Tencent. All rights reserved.
//
#import "TUITextMessageCell.h"
#import "TUIC2CSignalCellData.h"

@interface TUIC2CSignalCell : TUITextMessageCell

- (void)fillWithData:(TUIC2CSignalCellData *)data;

@end
