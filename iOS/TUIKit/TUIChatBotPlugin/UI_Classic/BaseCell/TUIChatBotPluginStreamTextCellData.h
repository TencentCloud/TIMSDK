//
//  TUIChatBotPluginStreamTextCellData.h
//  TUIChatBotPlugin
//
//  Created by lynx on 2023/10/30.
//

#import <TUIChat/TUITextMessageCellData.h>

NS_ASSUME_NONNULL_BEGIN

@interface TUIChatBotPluginStreamTextCellData : TUITextMessageCellData
@property(nonatomic, strong) dispatch_source_t timer;
@property(nonatomic, strong) UIFont *contentFont;
@property(nonatomic, strong) NSAttributedString *contentString;
@property(nonatomic, assign) NSInteger displayedContentLength;
@end

NS_ASSUME_NONNULL_END
