//
//  TUIChatbotMessageCell.h
//  TUIChat
//
//  Created by Yiliang Wang on 2025/5/30.
//  Copyright © 2023 Tencent. All rights reserved.
//

#import "TUITextMessageCell.h"
#import "TUIChatbotMessageCellData.h"

NS_ASSUME_NONNULL_BEGIN

@interface TUIChatbotMessageCell : TUITextMessageCell

/**
 * Immediately stop the streaming rendering timer and loading animation
 * This method can be called externally to force stop the rendering process
 */
- (void)immediateStopRendering;

- (void)fillWithData:(TUIChatbotMessageCellData *)data;

@end

NS_ASSUME_NONNULL_END
