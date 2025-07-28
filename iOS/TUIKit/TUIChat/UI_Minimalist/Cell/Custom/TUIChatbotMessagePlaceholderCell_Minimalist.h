//
//  TUIChatbotMessagePlaceholderCell_Minimalist.h
//  TUIChat
//
//  Created by AI Assistant on 2025/1/20.
//  Copyright © 2023 Tencent. All rights reserved.
//

#import "TUITextMessageCell_Minimalist.h"
#import "TUIChatbotMessagePlaceholderCellData.h"

NS_ASSUME_NONNULL_BEGIN

/**
 * AI chatbot placeholder message cell
 * Displays only a loading animation while waiting for AI response
 */
@interface TUIChatbotMessagePlaceholderCell_Minimalist : TUITextMessageCell_Minimalist

/**
 * Loading animation image view
 */
@property(nonatomic, strong, readonly) UIImageView *loadingImageView;

/**
 * Fill cell with placeholder data
 */
- (void)fillWithData:(TUIChatbotMessagePlaceholderCellData *)data;

@end

NS_ASSUME_NONNULL_END 
