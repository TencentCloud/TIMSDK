
//  Created by Tencent on 2023/06/09.
//  Copyright © 2023 Tencent. All rights reserved.
/**
 *
 *  - 本文件声明了 TUIBubbleMessageCellData 类。
 *  - 本类继承于 TUIMessageCellData，用于存放气泡消息单元所需的一系列数据与信息。
 *  - 本类作为气泡消息数据源的基类，当您想实现自定义的气泡消息时，也需使对应消息的数据源继承自本类。
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
 * 【模块名称】TUIBubbleMessageCellData
 * 【功能说明】气泡消息数据源。
 *  - 气泡消息，即最常见的包含文本与表情字符的消息，大多数情况下将会是您最常见的消息类型。
 *  - 气泡消息数据源（以下简称数据源），负责存储渲染气泡消息 UI 所需的各种信息。
 *  - 数据源实现了一系列的业务逻辑，可以向气泡消息 UI 提供所需的信息。
 *  - TUIFileMessageCellData 和 TUIVoiceMessageCellData 均继承于本类，实现了气泡消息的 UI。
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
