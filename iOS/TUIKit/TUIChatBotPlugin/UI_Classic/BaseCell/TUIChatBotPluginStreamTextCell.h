//
//  TUIChatBotPluginStreamTextCell.h
//  TUIChatBotPlugin
//
//  Created by lynx on 2023/10/30.
//

#import <TUIChat/TUITextMessageCell.h>
#import "TUIChatBotPluginStreamTextCellData.h"

NS_ASSUME_NONNULL_BEGIN

@interface TUIChatBotPluginStreamTextCell : TUITextMessageCell
- (void)fillWithData:(TUIChatBotPluginStreamTextCellData *)data;
@end

NS_ASSUME_NONNULL_END
