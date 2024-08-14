
//  Created by lynx on 2024/3/1.
//  Copyright © 2024 Tencent. All rights reserved.

#import <TIMCommon/TUIBubbleMessageCell.h>
#import "TUIBotRichTextCellData.h"

@interface TUIBotRichTextCell : TUIBubbleMessageCell
@property TUIBotRichTextCellData *webViewData;

- (void)fillWithData:(TUIBotRichTextCellData *)data;
@end
