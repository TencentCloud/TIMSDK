
//  Created by Tencent on 2023/06/09.
//  Copyright © 2023 Tencent. All rights reserved.
/**
 *
 *  - This file declares the TUIBubbleMessageCellData class.
 *  - This class inherits from TUIMessageCellData and is used to store a series of data and information required by the bubble message unit.
 *  - This class is used as the base class for the data source of the bubble message. When you want to implement a custom bubble message,
 *   you also need to make the data source of the corresponding message inherit from this class.
 *
 */
#import "TUIMessageCellData.h"

NS_ASSUME_NONNULL_BEGIN

/**
 *
 * 【Module name】TUIBubbleMessageCellData
 * 【Function description】Bubble message data source.
 *  - Bubble messages, the most common type of messages that contain text and emoji characters, will be your most common type of message in most cases.
 *  - The Bubble Message data source (hereinafter referred to as the data source) is responsible for storing various information required to render the Bubble
 * Message UI.
 *  - The data source implements a series of business logic that can provide the required information to the Bubble Message UI.
 *  - Both TUIFileMessageCellData and TUIVoiceMessageCellData inherit from this class and implement the UI of bubble messages.
 */
@interface TUIBubbleMessageCellData : TUIMessageCellData

@end

NS_ASSUME_NONNULL_END
