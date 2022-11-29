#import "TUICommonModel.h"
#import "TUIConversationCellData.h"
#import "TUICommonModel.h"

NS_ASSUME_NONNULL_BEGIN

/**
 * 【模块名称】消息列表会话单元（TUIConversationCell）
 *
 * 【功能说明】在消息列表界面中，显示单个会话的预览信息。
 *  会话单元所展示的会话信息包括：
 *  1、头像信息（用户头像/群头像）
 *  2、会话标题（用户昵称/群名称）
 *  3、会话消息概览（展示最新的一条的消息内容）
 *  4、未读消息数（若有未读消息的话）
 *  5、会话时间（最新消息的收到/发出时间）
 */
@interface TUIConversationCell : UITableViewCell

/**
 *  头像视图。
 *  当该会话为1对1好友会话时，头像视图为用户头像。·
 *  当该会话为群聊时，头像视图为群头像。
 *
 *  Image view for displaying avatar
 *  When conversation type is one-to-one, the image view will display user's avatar
 *  When conversation type is group chat, the image view will display group's avatar
 */
@property (nonatomic, strong) UIImageView *headImageView;

/**
 *  会话标题
 *  当该会话为1对1好友会话时，标题为好友的备注，若对应好友没有备注的话，则显示好友 ID。
 *  当该会话为群聊时，标题为群名称。
 *
 *  Title of conversation
 *  When conversation type is one-to-one, the title is the friend's remarks, and if the corresponding friend has no remarks, the friend's ID is displayed.
 *  When the conversation is a group chat, the title is the group name.
 */
@property (nonatomic, strong) UILabel *titleLabel;

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
@property (nonatomic, strong) UILabel *subTitleLabel;

/**
 *  时间标签
 *  负责在会话单元中显示最新消息的接收/发送时间。
 *
 *  The label for displaying time
 *  Responsible for displaying the received/sent time of the latest message in the conversation unit.
 */
@property (nonatomic, strong) UILabel *timeLabel;

/**
 *  消息免打扰红点
 *  The red dot view that identifies whether the current conversation is set to do not disturb
 */
@property (nonatomic, strong) UIView *notDisturbRedDot;

/**
 *  消息免打扰图标
 *  The image view that identifies whether the current conversation is set to do not disturb
 */
@property (nonatomic, strong) UIImageView *notDisturbView;

/**
 *  未读视图
 *  如果当前会话有未读消息，则在会话单元右侧显示未读数量。
 *
 *  A view indicating whether the current conversation has unread messages
 *  If the current conversation has unread messages, the unread count is displayed to the right of the conversation unit.
 */
@property (nonatomic, strong) TUIUnReadView *unReadView;

/**
 * 会话选中图标
 * 多选场景中用来标识是否选中会话
 *
 * Icon indicating whether the conversation is selected
 * In the multi-selection scenario, it is used to identify whether the conversation is selected
 */
@property (nonatomic, strong) UIImageView *selectedIcon;

/**
 * 在线状态图标
 * The icon of the user's online status
 */
@property (nonatomic, strong) UIImageView *onlineStatusIcon;

@property (nonatomic, strong) UIImageView *lastMessageStatusImageView;

@property (atomic, strong) TUIConversationCellData *convData;

- (void)fillWithData:(TUIConversationCellData *)convData;

@end

NS_ASSUME_NONNULL_END
