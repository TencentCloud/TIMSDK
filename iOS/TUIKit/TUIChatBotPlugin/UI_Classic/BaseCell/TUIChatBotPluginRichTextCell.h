
//  Created by lynx on 2024/3/1.
//  Copyright © 2024 Tencent. All rights reserved.

#import <TIMCommon/TUIBubbleMessageCell.h>
#import "TUIChatBotPluginRichTextCellData.h"

@interface TUIChatBotPluginRichTextCell : TUIBubbleMessageCell
@property TUIChatBotPluginRichTextCellData *webViewData;

- (void)fillWithData:(TUIChatBotPluginRichTextCellData *)data;
@end
