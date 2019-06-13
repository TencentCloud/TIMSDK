//
//  TUISystemMessageCell.h
//  UIKit
//
//  Created by annidyfeng on 2019/5/30.
//

#import "TUISystemMessageCellData.h"
#import "TUIMessageCell.h"

@interface TUISystemMessageCell : TUIMessageCell
@property (readonly) UILabel *messageLabel;
@property (readonly) TUISystemMessageCellData *systemData;
- (void)fillWithData:(TUISystemMessageCellData *)data;
@end
