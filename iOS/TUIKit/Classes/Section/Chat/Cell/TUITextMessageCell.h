//
//  TUITextMessageCell.h
//  UIKit
//
//  Created by annidyfeng on 2019/5/30.
//

#import "TUIBubbleMessageCell.h"
#import "TUITextMessageCellData.h"


@interface TUITextMessageCell : TUIBubbleMessageCell
@property (nonatomic, strong) UILabel *content;
@property TUITextMessageCellData *textData;
- (void)fillWithData:(TUITextMessageCellData *)data;
@end
