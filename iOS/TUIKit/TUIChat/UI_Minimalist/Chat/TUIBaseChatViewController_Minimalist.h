
//  Created by Tencent on 2023/06/09.
//  Copyright © 2023 Tencent. All rights reserved.
/**
 * 腾讯云通讯服务界面组件 TUIKIT - 聊天界面组件
 *
 * 本文件主要声明用于实现聊天界面的组件，支持 1v1 单聊和群聊天两种模式，其中包括：
 * - 消息展示区：也就是气泡展示区。
 * - 消息输入区：也就是让用户输入消息文字、发表情以及图片和视频的部分。
 *
 * TUIBaseChatViewController_Minimalist 类用于实现聊天视图的总控制器，负责将输入、消息控制器、更多视图等进行统一控制。
 * 本文件中声明的类与协议，能够有效的帮助您实现自定义消息格式。
 *
 * Tencent Cloud Communication Service Interface Component TUIKIT - Chat Interface Component
 *
 * This document mainly declares the components used to implement the chat interface, which supports two modes of 1v1 single chat and group chat, including:
 * - Message display area: that is, the bubble display area.
 * - Message input area: that is, the part that allows users to input message text, emoticons, pictures and videos.
 *
 * The TUIBaseChatViewController class is used to implement the general controller of the chat view, which is responsible for unified control of input, message
 * controller, and more views. The classes and protocols declared in this file can effectively help you implement custom message formats.
 *
 */
#import <TIMCommon/TIMCommonModel.h>
#import <UIKit/UIKit.h>
#import "TUIBaseMessageController_Minimalist.h"
#import "TUIChatConversationModel.h"
#import "TUIInputController_Minimalist.h"
@class TUIBaseChatViewController;

/////////////////////////////////////////////////////////////////////////////////
//
//                          TUIBaseChatViewController_Minimalist
//
/////////////////////////////////////////////////////////////////////////////////

/**
 * 【模块名称】聊天界面组件（TUIBaseChatViewController_Minimalist）
 *
 * 【功能说明】负责实现聊天界面的 UI 组件，包括消息展示区和消息输入区。
 *
 *  TUIBaseChatViewController
 * 类用于实现聊天视图的总控制器，负责将聊天消息控制器（TUIBaseMessageController）、信息输入控制器（TUIInputController）和更多视图进行统一控制。
 *
 *  聊天消息控制器负责在您接收到新消息或者发送消息时在 UI 作出响应，并响应您在消息气泡上的交互操作，详情参考:Section\Chat\TUIBaseMessageController.h
 *  信息输入控制器负责接收您的输入，向你提供输入内容的编辑功能并进行消息的发送，详情参考:Section\Chat\Input\TUIInputController.h
 *  本类中包含了“更多”视图，即在您点击 UI 中“+”按钮时，能够显示出更多按钮来满足您的进一步操作，详情参考:Section\Chat\TUIMoreView.h
 *
 *  Q: 如何实现自定义的个性化消息气泡功能？
 *  A: 如果您想要实现 TUIKit 不支持的消息气泡样式，比如在消息气泡中添加投票链接等，可以参考文档：
 *    https://cloud.tencent.com/document/product/269/37067
 *
 * 【Module name】TUIBaseChatViewController
 * 【Function description】Responsible for implementing the UI components of the chat interface, including the message display area and the message input area.
 *
 *  The TUIBaseChatViewController class is used to implement the overall controller of the chat view, and is responsible for unified control of the chat message
 * controller (TUIBaseMessageController), the information input controller (TUIInputController) and more views.
 *
 *  The chat message controller is responsible for responding in the UI when you receive a new message or sending a message, and respond to your interactions on
 * the message bubble, see: Section\Chat\TUIBaseMessageController.h The information input controller is responsible for receiving your input, providing you with
 * the editing function of the input content and sending messages. For details, please refer to: Section\Chat\Input\TUIInputController.h This class contains the
 * "more" view, that is, when you click the "+" button in the UI, more buttons can be displayed to satisfy your further operations. For details, please refer
 * to: Section\Chat\TUIMoreView.h
 *
 *  Q: How to implement custom messages?
 *  A: If you want to implement a message style that TUIKit does not support, such as adding a voting link to the message style, you can refer to the
 * documentation: https://cloud.tencent.com/document/product/269/37067
 */
@interface TUIBaseChatViewController_Minimalist : UIViewController

@property(nonatomic, strong) TUIChatConversationModel *conversationData;

/**
 * 高亮文本
 * 在搜索场景下，当 highlightKeyword 不为空时，且与 locateMessage 匹配时，打开聊天会话页面会高亮显示当前的 cell
 *
 * Highlight text
 * In the search scenario, when highlightKeyword is not empty and matches @locateMessage, opening the chat session page will highlight the current cell
 */
@property(nonatomic, copy) NSString *highlightKeyword;

/**
 * 定位消息
 * 在搜索场景下，当 locateMessage 不为空时，打开聊天会话页面会自动定位到此处
 *
 * Locate message
 * In the search scenario, when locateMessage is not empty, opening the chat session page will automatically scroll to here
 */
@property(nonatomic, strong) V2TIMMessage *locateMessage;

/**
 *  TUIKit 聊天消息控制器
 *  负责消息气泡的展示，同时负责响应用户对于消息气泡的交互，比如：点击消息发送者头像、轻点消息、长按消息等操作。
 *  聊天消息控制器的详细信息请参考 TUIChat\UI\Chat\TUIBaseMessageController.h
 *
 *  TUIKit message controller
 *  It is responsible for the display of message bubbles, and at the same time, it is responsible for responding to the user's interaction with the message
 * bubbles, such as: clicking on the avatar of the message sender, tapping the message, and long-pressing the message. For more information about the chat
 * message controller, please refer to TUIChat\UI\Chat\TUIBaseMessageController.h
 */
@property TUIBaseMessageController_Minimalist *messageController;

/**
 *  TUIKit 信息输入控制器
 *  负责接收用户输入，同时显示“+”按钮与语音输入按钮、表情按钮等。
 *  同时 TUIInputController 整合了消息的发送功能，您可以直接使用 TUIInputController 进行消息的输入采集与发送。
 *  信息输入控制器的详细信息请参考 TUIChat\UI\Input\TUIInputController.h
 *
 *  TUIKit input controller
 *  Responsible for receiving user input, and displaying the "+" button, voice input button, emoticon button, etc.
 *  At the same time, TUIInputController integrates the message sending function, and you can directly use TUIInputController to collect and send message input.
 *  Please refer to TUIChat\UI\Input\TUIInputController.h for details of the message input controller
 */
@property TUIInputController_Minimalist *inputController;

- (void)sendMessage:(V2TIMMessage *)message;
- (void)sendMessage:(V2TIMMessage *)message placeHolderCellData:(TUIMessageCellData *)placeHolderCellData;

/**
 * 在聊天界面顶部添加自定义视图，该视图会常驻在消息列表顶部，不会随着消息列表上滑而上滑。
 * 不设置则默认不显示。
 */
+ (void)setCustomTopView:(UIView *)view;

/**
 * 获取聊天界面顶部的自定义视图。
 */
+ (UIView *)customTopView;

@end
