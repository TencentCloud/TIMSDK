/**
 *
 *  本文件声明了用于实现会话单元数据源的模块。
 *  会话单元数据源（以下简称“数据源”）包含了会话单元显示所需的一系列信息与数据，这些信息与数据将会在下文进一步说明。
 *  数据源中还包含了部分的业务逻辑，如获取并生成消息概览（subTitle），更新会话信息（群消息或用户消息更新）等逻辑。
 *
 *  This file declares the modules used to implement the conversation unit data source.
 *  The conversation unit data source (hereinafter referred to as the "data source") contains a series of information and data required for the display of the conversation unit, which will be described further below.
 *  The data source also contains some business logic, such as getting and generating message overview (subTitle), updating conversation information (group message or user message update) and other logic.
 */

#import "TUICommonModel.h"
#import "TUIDefine.h"

NS_ASSUME_NONNULL_BEGIN

typedef NS_ENUM(NSInteger, TUIConversationOnlineStatus) {
    TUIConversationOnlineStatusUnknown  = 0,
    TUIConversationOnlineStatusOnline   = 1,
    TUIConversationOnlineStatusOffline  = 2,
};


/**
 * 【模块名称】会话单元数据源（TUIConversationCellData）
 *
 * 【功能说明】存放会话单元所需的一系列信息和数据。
 *  会话单元数据源包含以下信息与数据：
 *  1、会话 ID。
 *  2、会话类型。
 *  3、头像 URL 与头像图片。
 *  4、会话标题与信息概览（副标题）。
 *  5、会话时间（最新一条消息的收/发时间）。
 *  6、会话未读计数。
 *  7、会话置顶标识。
 *  数据源中还包含了部分的业务逻辑，如获取并生成消息概览（subTitle），更新会话信息（群消息或用户消息更新）等逻辑。
 *
 *
 * 【Module name】Conversation unit data source (TUIConversationCellData)
 * 【Function description】Store a series of information and data required by the conversation unit.
 *  The conversation unit data source contains the following information and data:
 *  1. Conversation ID.
 *  2. Conversation type.
 *  3. Avatar URL and avatar image.
 *  4. Conversation title and information overview (subtitle).
 *  5. Conversation time (receive/send time of the latest message).
 *  6. Conversation unread count.
 *  7. Conversation top logo.
 *  The data source also contains some business logic, such as getting and generating message overview (subTitle), updating conversation information (group message or user message update) and other logic.
 */
@interface TUIConversationCellData : TUICommonCellData

@property (nonatomic, strong) NSString *conversationID;

@property (nonatomic, strong) NSString *groupID;

@property (nonatomic, strong) NSString *groupType;

@property (nonatomic, strong) NSString *userID;

@property (nonatomic, strong) NSString *title;

@property (nonatomic, strong) NSString *faceUrl;

@property (nonatomic, strong) UIImage *avatarImage;

@property (nonatomic, strong) NSString *draftText;

@property (nonatomic, assign) int unreadCount;


/**
 *  会话消息概览（下标题）
 *  概览负责显示对应会话最新一条消息的内容/类型。
 *  当最新的消息为文本消息/系统消息时，概览的内容为消息的文本内容。
 *  当最新的消息为多媒体消息时，概览的内容为对应的多媒体形式，如：“动画表情” / “[文件]” / “[语音]” / “[图片]” / “[视频]” 等。
 *  若当前会话有草稿时，概览内容为：“[草稿]XXXXX”，XXXXX为草稿内容。
 *
 *  Overview of conversation messages (sub title)
 *  The overview is responsible for displaying the content/type of the latest message for the corresponding conversation.
 *  When the latest message is a text message/system message, the content of the overview is the text content of the message
 *  When the latest message is a multimedia message, the content of the overview is in the corresponding multimedia form, such as: "[Animation Expression]" / "[File]" / "[Voice]" / "[Picture]" / "[Video]", etc.
 *  If there is a draft in the current conversation, the overview content is: "[Draft]XXXXX", where XXXXX is the draft content.
 */
@property (nonatomic, strong) NSMutableAttributedString *subTitle;

/**
 *  群@ 消息 seq 列表
 *  Sequence list of group-at message
 */
@property (nonatomic, strong) NSMutableArray<NSNumber *> *atMsgSeqs;

/**
 *  最新消息时间
 *  记录会话中最新消息的接收/发送时间。
 *
 *  The time of the latest message
 *  Recording the receive/send time of the latest message in the conversation.
 */
@property (nonatomic, strong) NSDate *time;

/**
 *  会话置顶位
 *  YES：会话置顶；NO：会话未置顶。
 *
 *  The flag indicating whether the session is pinned
 *  YES: Conversation is pinned; NO: Conversation not pinned
 */
@property (nonatomic, assign) BOOL isOnTop;

/**
 * 显示消息多选flag
 * 会话列表中，默认不显示选择按钮。
 * 在消息转发场景下，列表 cell 被复用至选择会话页面，当点选“多选”按钮时，会话列表变为可多选状态
 * YES: 可多选，展示多选视图；NO:不可多选，展示默认视图
 *
 *
 * Indicates whether to display the message checkbox
 * In the conversation list, the message checkbox is not displayed by default.
 * In the message forwarding scenario, the list cell is multiplexed to the select conversation page. When the "Multiple Choice" button is clicked, the conversation list becomes multi-selectable.
 * YES: Multiple selection is enable, multiple selection views are displayed; NO: Multiple selection is disable, the default view is displayed
 */
@property (nonatomic, assign) BOOL showCheckBox;

/**
 * 显示是否选中 flag，默认是 NO
 * Indicates whether the current message is selected, the default is NO
 */
@property (nonatomic, assign) BOOL selected;

/**
 *  消息是否免打扰
 *  Whether the current conversation is marked as do-not-disturb for new messages
 */
@property (nonatomic, assign) BOOL isNotDisturb;

/**
 * 会话排序的 orderKey
 * key by which to sort the conversation list
 */
@property (nonatomic, assign) NSUInteger orderKey;

/**
 * 在线状态
 * The user's online status
 */
@property (nonatomic, assign) TUIConversationOnlineStatus onlineStatus;


/**
 * 会话标记- 当前会话被标记为未读
 * Conversation Mark -  The current conversation is marked as unread
 */
@property (nonatomic, assign) BOOL isMarkAsUnread;

/**
 * 会话标记- 当前会话被标记为隐藏
 * Conversation Mark - The current conversation is marked as hidden
 */
@property (nonatomic, assign) BOOL isMarkAsHide;

/**
 * 会话标记- 当前会话被标记为折叠
 * Conversation Mark - The current conversation is marked as folded
 */
@property (nonatomic, assign) BOOL isMarkAsFolded;

/**
 * 会话标记- 会话折叠，当存在被折叠的会话时，本地会产生一条折叠群组去收纳他们，此标记是折叠群组标记
 * Conversation Mark - Conversation folded, when there are folded conversations, a folded group will be generated locally to accommodate them, this tag is the folded group tag
 */
@property (nonatomic, assign) BOOL isLocalConversationFoldList;

/**
 * 会话折叠的子标题： 格式为  “群名 : 最后一条消息”
 * Conversation collapsed subtitle: in the format "group name: last message"
 */
@property (nonatomic, strong) NSMutableAttributedString *foldSubTitle;

@property (nonatomic, strong) V2TIMMessage *lastMessage;

+ (BOOL)isMarkedByHideType:(NSArray *)markList;

+ (BOOL)isMarkedByUnReadType:(NSArray *)markList;

+ (BOOL)isMarkedByFoldType:(NSArray *)markList;

@end

NS_ASSUME_NONNULL_END
