
//  Created by Tencent on 2023/06/09.
//  Copyright © 2023 Tencent. All rights reserved.

#import <TIMCommon/TIMDefine.h>
#import "TUIBaseMessageController.h"

NS_ASSUME_NONNULL_BEGIN

@interface TUIMessageController : TUIBaseMessageController

/**
 * 高亮文本
 * 在搜索场景下，当 highlightKeyword 不为空时，且与 locateMessage 匹配时，打开聊天会话页面会高亮显示当前的 cell
 *
 * Highlight text
 * In the search scenario, when highlightKeyword is not empty and matches @locateMessage, opening the chat session page will highlight the current cell
 */
@property(nonatomic, copy) NSString *hightlightKeyword;

/**
 * 定位消息
 * 在搜索场景下，当 locateMessage 不为空时，打开聊天会话页面会自动定位到此处
 *
 * Locate message
 * In the search scenario, when locateMessage is not empty, opening the chat session page will automatically scroll to here
 */
@property(nonatomic, strong) V2TIMMessage *locateMessage;

@property(nonatomic, strong) V2TIMMessage *C2CIncomingLastMsg;

@end

NS_ASSUME_NONNULL_END
