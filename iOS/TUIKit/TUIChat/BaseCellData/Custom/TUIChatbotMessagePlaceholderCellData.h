//
//  TUIChatbotMessagePlaceholderCellData.h
//  TUIChat
//
//  Created by AI Assistant on 2025/1/20.
//  Copyright © 2023 Tencent. All rights reserved.
//

#import "TUITextMessageCellData.h"

NS_ASSUME_NONNULL_BEGIN

/**
 * AI chatbot placeholder message cell data
 * Used to display loading animation while waiting for AI response
 */
@interface TUIChatbotMessagePlaceholderCellData : TUITextMessageCellData

/**
 * Whether the AI is currently typing/generating response
 * When YES, shows loading animation
 * When NO, hides the cell or shows completed state
 */
@property(nonatomic, assign) BOOL isAITyping;

/**
 * Create placeholder cell data for AI typing state
 */
+ (instancetype)createAIPlaceholderCellData;

@end

NS_ASSUME_NONNULL_END 