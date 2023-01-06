/**
 *
 *  本文件声明了用于实现消息收发逻辑的控制器类。
 *  消息控制器负责统一显示您发送/收到的消息，同时在您对这些消息进行交互（点击/长按等）时提供响应回调。
 *  消息控制器还负责对您发送的消息进行统一的数据处理，使其变为可以通过 IM SDK 发送的数据格式并进行发送。
 *  也就是说，当您使用本控制器时，您可以省去很大部分的数据处理上的工作，从而能够更快捷、更方便的接入 IM SDK。
 *
 *  This file declares the controller class used to implement the messaging logic
 *  The message controller is responsible for uniformly displaying the messages you send/receive, while providing response callbacks when you interact with those messages (tap/long-press, etc.).
 *  The message controller is also responsible for unified data processing of the messages you send into a data format that can be sent through the IM SDK and sent.
 *  That is to say, when you use this controller, you can save a lot of data processing work, so that you can access the IM SDK more quickly and conveniently.
 */

#import <UIKit/UIKit.h>
#import "TUIMessageCell.h"

#import "TUIBaseMessageControllerDelegate.h"
#import "TUIChatConversationModel.h"
#import "TUIChatDefine.h"

@class TUIConversationCellData;
@class TUIBaseMessageController;
@class TUIReplyMessageCell;

/////////////////////////////////////////////////////////////////////////////////
//
//                         TUIBaseMessageController
//
/////////////////////////////////////////////////////////////////////////////////

/**
 * 【模块名称】TUIBaseMessageController
 * 【功能说明】消息控制器，负责实现消息的接收、发送、显示等一系列业务逻辑。
 *  - 本类提供了接收/显示新消息、显示/隐藏菜单、点击消息头像等交互操作的回调接口。
 *  - 同时本类提供了图像、视频、文件信息的发送功能，直接整合调用了 IM SDK 实现发送功能。
 *
 * 【Module name】TUIBaseMessageController
 * 【Function description】The message controller is responsible for implementing a series of business logic such as receiving, sending, and displaying messages.
 *  - This class provides callback interfaces for interactive operations such as receiving/displaying new messages, showing/hiding menus, and clicking on message avatars.
 *  - At the same time, this class provides the sending function of image, video, and file information, and directly integrates and calls the IM SDK to realize the sending function.
 *
 */
@interface TUIBaseMessageController : UITableViewController

@property (nonatomic, weak) id<TUIBaseMessageControllerDelegate> delegate;

@property (nonatomic, assign) BOOL isInVC;

/**
 * 发送消息是否需要已读回执，默认 NO
 * Whether a read receipt is required to send a message, the default is NO
 */
@property (nonatomic) BOOL isMsgNeedReadReceipt;

- (void)sendMessage:(V2TIMMessage *)msg;

- (void)clearUImsg;

- (void)scrollToBottom:(BOOL)animate;

- (void)setConversation:(TUIChatConversationModel *)conversationData;

/**
 * 开启多选模式后，获取当前选中的结果
 * 如果多选模式关闭，返回空数组
 *
 * After enabling multi-selection mode, get the currently selected result
 * Returns an empty array if multiple selection mode is off
 */
- (NSArray<TUIMessageCellData *> *)multiSelectedResult:(TUIMultiResultOption)option;
- (void)enableMultiSelectedMode:(BOOL)enable;

- (void)deleteMessages:(NSArray<TUIMessageCellData *> *)uiMsgs;

/**
 * 会话已读上报
 *
 */
- (void)readReport;

/**
 * 子类实现点击回复消息
 */
- (void)showReplyMessage:(TUIReplyMessageCell *)cell;
- (void)willShowMediaMessage:(TUIMessageCell *)cell;
- (void)didCloseMediaMessage:(TUIMessageCell *)cell;

// Reload the specific cell UI.
- (void)reloadCellOfMessage:(NSString *)messageID;
- (void)reloadAndScrollToBottomOfMessage:(NSString *)messageID;
- (void)scrollCellToBottomOfMessage:(NSString *)messageID;

@end
