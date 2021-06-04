/******************************************************************************
 *
 * 腾讯云通讯服务界面组件 TUIKIT - 聊天界面组件
 *
 * 本文件主要声明用于实现聊天界面的组件，支持 1v1 单聊和群聊天两种模式，其中包括：
 * - 消息展示区：也就是气泡展示区。
 * - 消息输入区：也就是让用户输入消息文字、发表情以及图片和视频的部分。
 *
 * TUIChatController 类用于实现聊天视图的总控制器，负责将输入、消息控制器、更多视图等进行统一控制。
 * 本文件中声明的类与协议，能够有效的帮助您实现自定义消息格式。
 *
 * TUIChatControllerListener 负责提供聊天控制器的部分回调委托。包括接收新消息、显示新消息和某一“更多”单元被点击的回调。
 *
 ******************************************************************************/
#import <UIKit/UIKit.h>
#import "TUIInputController.h"
#import "TUIMessageController.h"
#import "TUIConversationCell.h"

@class TUIChatController;

/**
 *  moreCell 优先级，优先级越好，排列越靠前
 */
typedef NS_ENUM(NSInteger, MoreCellPriority) {
    MoreCellPriority_High                   = 0,  ///< 高优先级
    MoreCellPriority_Nomal                  = 1,  ///< 中优先级
    MoreCellPriority_Low                    = 2,  ///< 低优先级
    MoreCellPriority_Lowest                 = 3,  ///< 最低优先级
};;

/////////////////////////////////////////////////////////////////////////////////
//
//                         TUIChatControllerListener
//
/////////////////////////////////////////////////////////////////////////////////

/**
 *  TUIChatControllerListener 协议
 *  此协议旨在帮助开发者根据自身需求实现自定义消息。
 *  自定义消息的的具体实现方法，请参照链接 https://github.com/tencentyun/TIMSDK/wiki/TUIKit-iOS%E8%87%AA%E5%AE%9A%E4%B9%89%E6%B6%88%E6%81%AF
 */
@protocol TUIChatControllerListener <NSObject>

/**
 *  发送新消息时的回调
 *
 *  @param controller 委托者，当前聊天控制器。
 *  @param msgCellData TUIMessageCellData 即将发送的 msgCellData 。
 */
- (void)chatController:(TUIChatController *)controller didSendMessage:(TUIMessageCellData *)msgCellData;

/**
 *  接收新消息时的回调，用于甄别自定义消息
 *
 *  每条新消息在进入气泡展示区之前，都会通过 onNewMessage() 通知给您的代码。
 *  - 如果您返回 nil，TUIChatController 会认为该条消息非自定义消息，会将其按照普通消息的处理流程进行处理。
 *  - 如果您返回一个 TUIMessageCellData 类型的对象，TUIChatController 会在随后触发的 onShowMessageData() 回调里传入您返回的 cellData 对象。
 *
 *  也就是说，onNewMessage() 负责让您甄别自己的个性化消息，而 onShowMessageData() 回调则负责让您展示这条个性化消息。
 *
 * <pre>
 *  - (TUIMessageCellData *)chatController:(TUIChatController *)controller onNewMessage:(TIMMessage *)msg
 *  {
 *     TIMElem *elem = [msg getElem:0];
 *     //判断是否为自定义元素。
 *     if([elem isKindOfClass:[TIMCustomElem class]]){
 *        MyCustomCellData *cellData = [[MyCustomCellData alloc] initWithDirection:msg.isSelf ? MsgDirectionOutgoing : MsgDirectionIncoming];
 *
 *        //MyCustomCellData 是您自定义的消息类型，假设它包含 text 和 link 两个字段
 *        //此处省略从 elem 解析出自定义数据的代码段
 *
 *        cellData.text = @"这是我的自定义消息";
 *        cellData.link = @"www.qq.com";
 *        return cellData;
 *     }
 *     return nil;
 *  }
 * </pre>
 *
 *  @param controller 委托者，当前聊天控制器。
 *  @param msg 接收到的新消息，在此回调中，特指包含您自定义消息类型的消息元素。
 *  @return 返回一个消息单元数据源，此数据源为您自定义的消息数据源，继承自 TUIMessageCellData。当接收到的消息不是您的自定义消息时，您可以返回 nil。
 */
- (TUIMessageCellData *)chatController:(TUIChatController *)controller onNewMessage:(V2TIMMessage *)msg;

/**
 * 展示自定义个性化消息
 *
 * 您可以通过重载 onShowMessageData() 改变消息气泡的默认展示逻辑，只需要返回一个自定义的 TUIMessageCell 对象即可。
 *
 * <pre>
 *  - (TUIMessageCell *)chatController:(TUIChatController *)controller onShowMessageData:(TUIMessageCellData *)data
 *  {
 *      //判定当前传入数据源是否为自定义消息的数据源
 *      if ([data isKindOfClass:[MyCustomCellData class]]) {
 *          MyCustomCell *myCell = [[MyCustomCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"MyCell"];
 *          [myCell fillWithData:(MyCustomCellData *)data];
 *          return myCell;
 *      }
 *      return nil;
 *  }
 * </pre>
 *
 *  在上述代码中，当我们判定待显示的数据源为自定义数据源时，我们便实例化 MyCustomCell，并通过传入的 data 进行初始化，并将 MyCustomCell 作为返回值返回。
 *  当我们判断传入的数据并非自定义数据源时，我们可以返回 nil。
 *  需要注意的是，在此处的 MyCustomCell 在此处略过了具体的声明与实现。如果您对自定义消息单元的声明与实现有疑问的话，请参考本协议声明时，注释中给出的链接。
 *
 *  @param controller 委托者，当前聊天控制器。
 *  @param cellData 即将显示的消息单元的数据源，在此回调中，特指您自定义的消息数据源。
 *
 *  @return 返回一个即将显示的消息单元，此消息单元为您自定义的消息单元，继承自 TUIMessageCell。当接收到的消息不是您的自定义消息时，您可以返回空。
 */
- (TUIMessageCell *)chatController:(TUIChatController *)controller onShowMessageData:(TUIMessageCellData *)cellData;


/**
 *  “更多” 单元注册回调。
 *
 *  @param chatController 委托者，当前聊天控制器。
 *  @return 返回需要注册的 “更多” 单元。
 */
- (NSArray <TUIInputMoreCellData *> *)chatController:(TUIChatController *)chatController onRegisterMoreCell:(MoreCellPriority *)priority;

/**
 *  “更多”单元点击回调。
 *  当您点击某一“更多”单元后回执行该回调，您可以通过该回调实现对“更多”视图的定制。
 *  比如您在更多视图4个单元的基础上，添加了一个名为 myMoreCell 的第5个单元，则您可以按下列代码实现该自定义单元的响应回调。
 * <pre>
 *  - (void)chatController:(TUIChatController *)chatController onSelectMoreCell:(TUIInputMoreCell *)cell{
 *      if ([cell.data.title isEqualToString:@"myMoreCell"]) {
 *       //Do something
 *      }
 *  }
 *</pre>
 *
 *  @param chatController 委托者，当前聊天控制器。
 *  @param cell 被点击的“更多”单元，在此回调中特指您自定义的“更多”单元。
 */
- (void)chatController:(TUIChatController *)chatController onSelectMoreCell:(TUIInputMoreCell *)cell;

/**
 *  点击消息头像回调
 *  默认点击头像是打开联系人资料页，如果您实现了此方法，则内部不做任何处理
 *
 *  @param controller 会话对象
 *  @param cell 所点击的消息单元
 */
- (void)chatController:(TUIChatController *)controller onSelectMessageAvatar:(TUIMessageCell *)cell;

/**
 *  点击消息内容回调
 *
 *  @param controller 会话对象
 *  @param cell 所点击的消息单元
 */
- (void)chatController:(TUIChatController *)controller onSelectMessageContent:(TUIMessageCell *)cell;

/**
 *    获取消息摘要回调（主要用于消息合并转发）
 *
 *  @param controller 会话对象
 *  @param message  消息对象
 *  @return 返回消息摘要信息
 */
- (NSString *)chatController:(TUIChatController *)controller onGetMessageAbstact:(V2TIMMessage *)message;

@end


/////////////////////////////////////////////////////////////////////////////////
//
//                          TUIChatController
//
/////////////////////////////////////////////////////////////////////////////////

/**
 * 【模块名称】聊天界面组件（TUIChatController）
 *
 * 【功能说明】负责实现聊天界面的 UI 组件，包括消息展示区和消息输入区。
 *
 *  TUIChatController 类用于实现聊天视图的总控制器，负责将聊天消息控制器（TUIMessageController）、信息输入控制器（TUIInputController）和更多视频进行统一控制。
 *
 *  聊天消息控制器负责在您接收到新消息或者发送消息时在 UI 作出响应，并响应您在消息气泡上的交互操作，详情参考:Section\Chat\TUIMessageController.h
 *  信息输入控制器负责接收您的输入，向你提供输入内容的编辑功能并进行消息的发送，详情参考:Section\Chat\Input\TUIInputController.h
 *  本类中包含了“更多”视图，即在您点击 UI 中“+”按钮时，能够显示出更多按钮来满足您的进一步操作，详情参考:Section\Chat\TUIMoreView.h
 *
 *  Q: 如何实现自定义的个性化消息气泡功能？
 *  A: 如果您想要实现 TUIKit 不支持的消息气泡样式，比如在消息气泡中添加投票链接等，可以参考文档：
 *     https://github.com/tencentyun/TIMSDK/wiki/TUIKit-iOS%E8%87%AA%E5%AE%9A%E4%B9%89%E6%B6%88%E6%81%AF
 */
@interface TUIChatController : UIViewController

//********************************
@property TUnReadView *unRead;
//********************************

/**
 *  TUIKit 聊天消息控制器
 *  负责消息气泡的展示，同时负责响应用户对于消息气泡的交互，比如：点击消息发送者头像、轻点消息、长按消息等操作。
 *  聊天消息控制器的详细信息请参考 Section\Chat\TUIMessageController.h
 */
@property TUIMessageController *messageController;

/**
 *  TUIKit 信息输入控制器。
 *  负责接收用户输入，同时显示“+”按钮与语音输入按钮、表情按钮等。
 *  同时 TUIInputController 整合了消息的发送功能，您可以直接使用 TUIInputController 进行消息的输入采集与发送。
 *  信息输入控制器的详细信息请参考 Section\Chat\Input\TUIInputController.h
 */
@property TUIInputController *inputController;

/**
 *  被委托类，负责实现并执行 TUIChatControllerListener 的委托函数（已弃用，请使用 TUIKitListenerManager -> addChatControllerListener 方法监听）
 */
//@property (weak) id<TUIChatControllerListener> delegate;


/**
 *  更多菜单视图数据的数据组
 *  更多菜单视图包括：拍摄、图片、视频、文件。详细信息请参考 Section\Chat\TUIMoreView.h
 */
@property NSArray<TUIInputMoreCellData *> *moreMenus;

/**
 *  设置会话数据
 */
@property (nonatomic, strong) TUIConversationCellData *conversationData;

/**
 *  发送自定义的个性化消息
 *
 *  TUIKit 已经实现了基本的文本、表情、图片、文字和视频的发送逻辑，如果已经能够满足您的需求，可以不关注此接口。
 *  如果您想要发送我们暂不支持的个性化消息，就需要使用该接口对消息进行自定义。
 *
 *  您可以参考一下代码示例来对自定义消息进行包装：
 *
 *  <pre>
 *      //实例化您的自定义消息数据源，并对消息数据源中的必要属性进行复制
 *      MyCustomCellData *cellData = [[MyCustomCellData alloc] initWithDirection:MsgDirectionOutgoing];
 *
 *      //创建 cellData 的 innerMessage（十分重要）。此处的 innerMessage 为 IM SDK 收发消息的核心元素之一。
 *      cellData.innerMessage = [[TIMMessage alloc] init];
 *
 *      //创建自定义元素，并添加进 innerMessage 中。
 *      TIMCustomElem * custom_elem = [[TIMCustomElem alloc] init];
 *      NSString * text = @"<xml><text>这是我的自定义消息</text><link>www.qq.com</link></xml>";
 *      NSData *data = [text dataUsingEncoding:NSUTF8StringEncoding];
 *      [custom_elem setData:data];
 *      [cellData.innerMessage addElem:custom_elem];
 *
 *      //自此，自定义消息数据源包装完毕，调用 sendMessage 发送自定义消息。
 *      [chatController sendMessage:cellData];
 *  </pre>
 *
 *  调用 sendMessage() 之后，消息会被发送出去，但是如果仅完成这一步，个性化消息并不能展示在气泡区，
 *  需要继续监听 TUIChatControllerListener 中的 onNewMessage 和 onShowMessageData 回调才能完成个性化消息的展示。
 *
 *  @param message 需要发送的消息数据源。包括消息内容、发送者的头像、发送者昵称、消息字体与颜色等等。详细信息请参考 Section\Chat\CellData\TUIMessageCellData.h
 */
- (void)sendMessage:(TUIMessageCellData *)message;

/**
 *  保存草稿。
 *  以草稿的格式，保存当前聊天视图中未删除且未发送的信息。
 *  本函数会在您返回父视图时自动调用。
 *  需要注意的是，目前版本仅能保存未发送的文本消息作为草稿。
 */
- (void)saveDraft;

#pragma mark - 用于消息搜索场景
/**
 高亮文本，在搜索场景下，当highlightKeyword不为空时，且与locateMessage匹配时，打开聊天会话页面会高亮显示当前的cell
 */
@property (nonatomic, copy) NSString *highlightKeyword;

/**
 * 定位消息，在搜索场景下，当locateMessage不为空时，打开聊天会话页面会自动定位到此处
 */
@property (nonatomic, strong) V2TIMMessage *locateMessage;

@end
