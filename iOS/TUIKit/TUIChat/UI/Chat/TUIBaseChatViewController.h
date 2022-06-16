/******************************************************************************
 *
 * 腾讯云通讯服务界面组件 TUIKIT - 聊天界面组件
 *
 * 本文件主要声明用于实现聊天界面的组件，支持 1v1 单聊和群聊天两种模式，其中包括：
 * - 消息展示区：也就是气泡展示区。
 * - 消息输入区：也就是让用户输入消息文字、发表情以及图片和视频的部分。
 *
 * TUIBaseChatViewController 类用于实现聊天视图的总控制器，负责将输入、消息控制器、更多视图等进行统一控制。
 * 本文件中声明的类与协议，能够有效的帮助您实现自定义消息格式。
 *
 ******************************************************************************/
#import <UIKit/UIKit.h>
#import "TUIInputController.h"
#import "TUIBaseMessageController.h"
#import "TUICommonModel.h"
#import "TUIChatConversationModel.h"
@class TUIBaseChatViewController;

/////////////////////////////////////////////////////////////////////////////////
//
//                          TUIBaseChatViewController
//
/////////////////////////////////////////////////////////////////////////////////

/**
 * 【模块名称】聊天界面组件（TUIBaseChatViewController）
 *
 * 【功能说明】负责实现聊天界面的 UI 组件，包括消息展示区和消息输入区。
 *
 *  TUIBaseChatViewController 类用于实现聊天视图的总控制器，负责将聊天消息控制器（TUIBaseMessageController）、信息输入控制器（TUIInputController）和更多视频进行统一控制。
 *
 *  聊天消息控制器负责在您接收到新消息或者发送消息时在 UI 作出响应，并响应您在消息气泡上的交互操作，详情参考:Section\Chat\TUIBaseMessageController.h
 *  信息输入控制器负责接收您的输入，向你提供输入内容的编辑功能并进行消息的发送，详情参考:Section\Chat\Input\TUIInputController.h
 *  本类中包含了“更多”视图，即在您点击 UI 中“+”按钮时，能够显示出更多按钮来满足您的进一步操作，详情参考:Section\Chat\TUIMoreView.h
 *
 *  Q: 如何实现自定义的个性化消息气泡功能？
 *  A: 如果您想要实现 TUIKit 不支持的消息气泡样式，比如在消息气泡中添加投票链接等，可以参考文档：
 *     https://github.com/tencentyun/TIMSDK/wiki/TUIKit-iOS%E8%87%AA%E5%AE%9A%E4%B9%89%E6%B6%88%E6%81%AF
 */
@interface TUIBaseChatViewController : UIViewController

/// 会话数据
@property (nonatomic, strong) TUIChatConversationModel *conversationData;

#pragma mark - 用于消息搜索场景
/**
 高亮文本，在搜索场景下，当highlightKeyword不为空时，且与locateMessage匹配时，打开聊天会话页面会高亮显示当前的cell
 */
@property (nonatomic, copy) NSString *highlightKeyword;

/**
 * 定位消息，在搜索场景下，当locateMessage不为空时，打开聊天会话页面会自动定位到此处
 */
@property (nonatomic, strong) V2TIMMessage *locateMessage;

/**
 *  未读数展示 view
 */
@property TUIUnReadView *unRead;

/**
 *  TUIKit 聊天消息控制器
 *  负责消息气泡的展示，同时负责响应用户对于消息气泡的交互，比如：点击消息发送者头像、轻点消息、长按消息等操作。
 *  聊天消息控制器的详细信息请参考 Section\Chat\TUIBaseMessageController.h
 */
@property TUIBaseMessageController *messageController;

/**
 *  TUIKit 信息输入控制器。
 *  负责接收用户输入，同时显示“+”按钮与语音输入按钮、表情按钮等。
 *  同时 TUIInputController 整合了消息的发送功能，您可以直接使用 TUIInputController 进行消息的输入采集与发送。
 *  信息输入控制器的详细信息请参考 Section\Chat\Input\TUIInputController.h
 */
@property TUIInputController *inputController;

/**
 *  更多菜单视图数据的数据组
 *  更多菜单视图包括：拍摄、图片、视频、文件。详细信息请参考 Section\Chat\TUIMoreView.h
 */
@property NSArray<TUIInputMoreCellData *> *moreMenus;

/**
 *  发送消息
 */
- (void)sendMessage:(V2TIMMessage *)message;

@end
