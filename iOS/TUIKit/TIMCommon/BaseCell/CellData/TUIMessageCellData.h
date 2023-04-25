/**
 *
 *  本文件声明了 TUIMessageCellData 类。
 *  - "消息单元"数据源作为多种细化数据源的父类，提供了各类"消息单元"数据源属性与行为的基本模板。
 *  - 本文件中的"数据源类"是所有消息数据的基类，各个类型的数据源都继承与本类或者本类的子类。
 *  - 当您想要自定义消息时，需要将自定义消息的数据源继承于本类或者本类的子类。
 *
 * This file declares the TUIMessageCellData class.
 * - The "message unit" data source, as the parent class of various detailed data sources, provides basic templates for the properties and behaviors of various "message unit" data sources.
 * - The "data source class" in this document is the base class for all message data, and each type of data source inherits from this class or its subclasses.
 * - When you want to customize the message, you need to inherit the data source of the customized message from this class or a subclass of this class.
 */
#import <TIMCommon/TIMCommonModel.h>
#import "TUIMessageCellLayout.h"
#import <TIMCommon/TIMDefine.h>

NS_ASSUME_NONNULL_BEGIN

typedef void (^TDownloadProgress)(NSInteger curSize, NSInteger totalSize);
typedef void (^TDownloadResponse)(int code, NSString *desc, NSString *path);

/**
 *  消息状态枚举
 *
 *  The definition of message status
 */
typedef NS_ENUM(NSUInteger, TMsgStatus) {
    Msg_Status_Init,        // 消息创建, message initial
    Msg_Status_Sending,     // 消息发送中, message sending
    Msg_Status_Sending_2,   // 消息发送中_2，推荐使用，message sending, recommended
    Msg_Status_Succ,        // 消息发送成功, message sent successfully
    Msg_Status_Fail,        // 消息发送失败, Failed to send message
};

/**
 *  消息方向枚举
 *  消息方向影响气泡图标、气泡位置等 UI 风格。
 *
 *  The definition of message direction
 *  Message direction affects UI styles such as bubble icons, bubble positions, etc.
 */
typedef NS_ENUM(NSUInteger, TMsgDirection) {
    MsgDirectionIncoming, //消息接收
    MsgDirectionOutgoing, //消息发送
};

/**
 * 【模块名称】TUIMessageCellData
 * 【功能说明】聊天消息单元数据源，配合消息控制器实现消息收发的业务逻辑。
 *  - 用于存储消息管理与逻辑实现所需要的各类数据与信息。包括消息状态、消息发送者 ID 与头像等一系列数据。
 *  - 聊天信息数据单元整合并调用了 IM SDK，能够通过 SDK 提供的接口实现消息的业务逻辑。
 *
 * 【Module name】TUIMessageCellData
 * 【Function description】The data source of the chat message unit cooperates with the message controller to realize the business logic of message sending and receiving.
 *  - It is used to store various data and information required for message management and logic implementation. Including a series of data such as message status, message sender ID and avatar.
 *  - The chat information data unit integrates and calls the IM SDK, and can implement the business logic of the message through the interface provided by the SDK.
 */
@interface TUIMessageCellData : TUICommonCellData

/**
 *  Getting cellData according to message
 */
+ (TUIMessageCellData *)getCellData:(V2TIMMessage *)message;

/**
 * Getting the display string according to the message
 */
+ (NSString *)getDisplayString:(V2TIMMessage *)message;

/**
 * 获取消息回复自定义引用的布局及其数据的类
 * Class to get the layout of the message reply custom reference and its data
 */
- (Class)getReplyQuoteViewDataClass;
- (Class)getReplyQuoteViewClass;

/**
 *  Message unique id
 */
@property (nonatomic, strong) NSString *msgID;

/**
 *  Message sender ID
 */
@property (nonatomic, strong) NSString *identifier;

/**
 *  Sender's avatar url
 */
@property (nonatomic, strong) NSURL * __nullable avatarUrl;

/**
 *  Sender's avatar
 */
@property (nonatomic, strong) UIImage *__nullable avatarImage __attribute__((deprecated("not supported")));

/**
 * Whether to use the receiver's avatar, default is NO
 */
@property (nonatomic, assign) BOOL isUseMsgReceiverAvatar;

/**
 *  信息发送者昵称
 *  昵称与 ID 不一定相同，在聊天界面默认展示昵称。
 *
 *  Sender's nickname
 *  The nickname and ID are not necessarily the same, and the nickname is displayed by default in the chat interface.
 */
@property (nonatomic, strong) NSString *name;

/**
 *  名称展示 flag
 *  - 好友聊天时，默认不在消息中展示昵称。
 *  - 群组聊天时，对于群组内其他用户发送的信息，展示昵称。
 *  - YES：展示昵称；NO：不展示昵称。
 *
 *  The flag of showing name
 *  - In 1 vs 1 chat, the nickname is not displayed in the message by default.
 *  - In group chat, the nickname is displayed for messages sent by other users in the group.
 *  - YES: showing nickname;  NO: hidden nickname
 */
@property (nonatomic, assign) BOOL showName;

/**
 *  头像展示
 *  Display user avatar
 */
@property (nonatomic, assign) BOOL showAvatar;

/**
 *  当前消息是否和下一条消息发送者一样
 *  Whether the current message is the same as the sender of the next message
 */
@property (nonatomic, assign) BOOL sameToNextMsgSender;

/**
 * 显示消息多选 flag
 * - 消息列表中，默认不显示选择按钮，当长按消息弹出多选按钮并点击后，消息列表变为可多选状态
 * - YES: 可多选，展示多选视图；NO:不可多选，展示默认视图
 *
 * The flag of showing message multiple selection
 * - In the message list, the selection button is not displayed by default. When you long press the message to pop up the multi-select button and click it, the message list becomes multi-selectable.
 * - YES: Enable multiple selection, multiple selection views are displayed; NO: Disable multiple selection, the default view is displayed.
 */
@property (nonatomic, assign) BOOL showCheckBox;

/**
 * 显示是否选中 flag
 * The flag of selected
 */
@property (nonatomic, assign) BOOL selected;

/**
 * 消息 @ 用户列表
 * The user list in at message
 */
@property (nonatomic, strong) NSMutableArray<NSString *>*atUserList;

/**
 * 消息方向
 * - 消息方向影响气泡图标、气泡位置等 UI 风格。
 *
 * Message direction
 * - Message direction affects UI styles such as bubble icons, bubble positions, etc.
 */
@property (nonatomic, assign) TMsgDirection direction;

/**
 * 消息状态
 * Message status
 */
@property (nonatomic, assign) TMsgStatus status;

/**
 * 内层消息
 * IM SDK 提供的消息对象。内含各种获取消息信息的成员函数，包括获取优先级、获取元素索引、获取离线消息配置信息等。
 * 详细信息请参考 TXIMSDK__Plus_iOS\Frameworks\ImSDK_Plus.framework\Headers\V2TIMMessage.h
 *
 * IMSDK message
 * The Message object provided by IM SDK. Contains various member functions for obtaining message information, including obtaining priority, obtaining element index, obtaining offline message configuration information, etc.
 * For details, please refer to TXIMSDK__Plus_iOS\Frameworks\ImSDK_Plus.framework\Headers\V2TIMMessage.h
 */
@property (nonatomic, strong) V2TIMMessage *innerMessage;

/**
 * 昵称字体
 * 当需要显示昵称时，从该变量设置/获取昵称字体。
 *
 * The font of nickname
 * When the nickname needs to be displayed, set/get the nickname font from this variable.
 */
@property (nonatomic, strong) UIFont *nameFont;

/**
 *  昵称颜色
 *  当需要显示昵称时，从该变量设置/获取昵称颜色。
 *
 *  The color of the label that displays the nickname
 *  When the nickname needs to be displayed, set/get the nickname color from this variable.
 *
 */
@property (nonatomic, strong) UIColor *nameColor;

/**
 *  接收时昵称颜色
 *  当需要显示昵称，且消息 direction 为 MsgDirectionIncoming 时使用
 *
 *  The color of the label that displays the recipient's nickname
 *  Used when the nickname needs to be displayed and the message direction is MsgDirectionIncoming
 */
@property (nonatomic, class) UIColor *incommingNameColor;

/**
 *  接收时昵称字体
 *  当需要显示昵称，且消息 direction 为 MsgDirectionIncoming 时使用
 *
 *  The font of the label that displays the recipient's nickname
 *  Used when the nickname needs to be displayed and the message direction is MsgDirectionIncoming
 *
 */
@property (nonatomic, class) UIFont *incommingNameFont;

/**
 *  发送时昵称颜色
 *  当需要显示昵称，且消息 direction 为 MsgDirectionOutgoing 时使用。
 *
 *  The color of the label showing the sender's nickname
 *  Used when the nickname needs to be displayed and the message direction is MsgDirectionOutgoing.
 */
@property (nonatomic, class) UIColor *outgoingNameColor;

/**
 *  发送时昵称字体
 *  当需要显示昵称，且消息 direction 为 MsgDirectionOutgoing 时使用。
 *
 *  The font of the label that displays the sender's nickname
 *  Used when the nickname needs to be displayed and the message direction is MsgDirectionOutgoing.
 */
@property (nonatomic, class) UIFont *outgoingNameFont;

/**
 *  消息单元布局
 *  包括消息边距、气泡内边距、头像边距、头像大小等 UI 布局。
 *  详细信息请参考 Section\Chat\CellLayout\TUIMessageCellLayout.h
 *
 *  Message unit layout
 *  It includes UI information such as message margins, bubble padding, avatar margins, and avatar size.
 *  For details, please refer to Section\Chat\CellLayout\TUIMessageCellLayout.h
 */
@property (nonatomic, strong) TUIMessageCellLayout *cellLayout;

/**
 * 是否显示已读回执
 *
 * The flag of whether showing read receipts.
 */
@property (nonatomic, assign) BOOL showReadReceipt;

/**
 * 是否显示消息时间
 *
 * The flag of  whether showing message time.
 */
@property (nonatomic, assign) BOOL showMessageTime;

/**
 * 是否显示消息编辑 x 人回复按钮
 *
 * The flag of whether showing the button which indicated how many people modiffied.
 */
@property (nonatomic, assign) BOOL showMessageModifyReplies;
/**
 * 高亮关键字，当改关键字不为空时，会短暂高亮显示，主要用在消息搜索场景中
 *
 * Highlight keywords, when the keyword is not empty, it will be highlighted briefly, mainly used in message search scenarios.
 */
@property (nonatomic, copy) NSString * __nullable highlightKeyword;

/**
 * 消息已读回执
 *
 * Message read receipt
 */
@property (nonatomic, strong) V2TIMMessageReceipt *messageReceipt;

/**
 * 当前消息的「回复消息」列表
 *
 * List of Reply Messages for the current message
 */
@property (nonatomic, strong) NSArray *messageModifyReplies;

/**
 * 「表情互动消息」的用户信息
 * key: emoji key    value: user_id
 *
 * User information of "Emoji Interactive Message"
 */
@property (nonatomic, strong) NSDictionary *messageModifyReacts;
@property (nonatomic, assign) CGSize messageModifyReactsSize;

/**
 *  当前会话参与消息编辑(回复、表情回应)的好友信息
 * Information about friends who participate in message editing (reply, emoticon react) in the current conversation
 */

@property (nonatomic, strong) NSDictionary *messageModifyUserInfos;

/// Size for bottom container.
@property (nonatomic, assign) CGSize bottomContainerSize;

/// If cell content can be forwarded.
- (BOOL)canForward;

/**
 *  内容大小
 *  返回一个气泡内容的视图大小。
 *
 *  The size of content
 *  Returns the view size of the content of a bubble.
 */
- (CGSize)contentSize;

/**
 *  根据消息方向（收/发）初始化消息单元
 *  - 除了基本消息的初始化外，还包括根据方向设置方向变量、昵称字体等。
 *  - 同时为子类提供可继承的行为。
 *
 *  Initialize the message unit according to the message direction (receive/sent)
 *  - In addition to the initialization of basic messages, it also includes setting direction variables, nickname fonts, etc. according to the direction.
 *  - Also provides inheritable behavior for subclasses.
 */
- (instancetype)initWithDirection:(TMsgDirection)direction NS_DESIGNATED_INITIALIZER;

- (instancetype)init NS_UNAVAILABLE;

- (void)clearCachedCellHeight;

@end

NS_ASSUME_NONNULL_END



/**
 * 【模块名称】TUIMessageCellDataFileUploadProtocol
 * 【功能说明】文件类型的消息, 统一上传(发送)进度字段
 *
 * 【Module name】TUIMessageCellDataFileUploadProtocol
 * 【Function description】File type message, unified upload (send) progress field
 */
@protocol TUIMessageCellDataFileUploadProtocol <NSObject>

@required
/**
 *  上传（发送）进度
 *
 *  The progress of uploading (sending)
 */
@property (nonatomic, assign) NSUInteger uploadProgress;

@end

@protocol TUIMessageCellDataFileDownloadProtocol <NSObject>

@required
/**
 *  下载（接收）进度
 *
 *  The progress of downloading (receving)
 */
@property (nonatomic, assign) NSUInteger downladProgress;

/**
 *  下载标识符
 *  YES：正在下载；NO：未在下载
 *
 *  The flag of whether is downloading
 *  YES: downloading; NO: not download
 */
@property (nonatomic, assign) BOOL isDownloading;


@end
