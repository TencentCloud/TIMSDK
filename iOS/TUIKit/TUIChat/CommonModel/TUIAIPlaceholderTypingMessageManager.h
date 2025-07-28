//
//  TUIAIPlaceholderTypingMessageManager.h
//  TUIChat
//
//  Created by AI Assistant on 2025/1/20.
//  Copyright © 2023 Tencent. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@class TUIMessageCellData;
@class TUIChatConversationModel;

/**
 * Global manager for AI placeholder typing messages
 * Manages AI placeholder messages across different chat sessions
 */
@interface TUIAIPlaceholderTypingMessageManager : NSObject

/**
 * Shared instance
 */
+ (instancetype)sharedInstance;

/**
 * Set AI placeholder typing message for a specific conversation
 * @param message The AI placeholder typing message
 * @param conversationID The conversation identifier
 */
- (void)setAIPlaceholderTypingMessage:(nullable TUIMessageCellData *)message forConversation:(NSString *)conversationID;

/**
 * Get AI placeholder typing message for a specific conversation
 * @param conversationID The conversation identifier
 * @return The AI placeholder typing message if exists, nil otherwise
 */
- (nullable TUIMessageCellData *)getAIPlaceholderTypingMessageForConversation:(NSString *)conversationID;

/**
 * Remove AI placeholder typing message for a specific conversation
 * @param conversationID The conversation identifier
 */
- (void)removeAIPlaceholderTypingMessageForConversation:(NSString *)conversationID;

/**
 * Check if there's an AI placeholder typing message for a specific conversation
 * @param conversationID The conversation identifier
 * @return YES if there's an AI placeholder typing message, NO otherwise
 */
- (BOOL)hasAIPlaceholderTypingMessageForConversation:(NSString *)conversationID;

/**
 * Clear all AI placeholder typing messages
 */
- (void)clearAllAIPlaceholderTypingMessages;

@end

NS_ASSUME_NONNULL_END 