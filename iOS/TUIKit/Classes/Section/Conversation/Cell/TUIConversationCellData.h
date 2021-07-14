/******************************************************************************
 *
 *  本文件声明了用于实现会话单元数据源的模块。
 *  会话单元数据源（以下简称“数据源”）包含了会话单元显示所需的一系列信息与数据，这些信息与数据将会在下文进一步说明。
 *  数据源中还包含了部分的业务逻辑，如获取并生成消息概览（subTitle），更新会话信息（群消息或用户消息更新）等逻辑。
 *
 ******************************************************************************/

#import "TCommonCell.h"
#import "THeader.h"

NS_ASSUME_NONNULL_BEGIN


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
 */
@interface TUIConversationCellData : TCommonCellData

/**
 *  会话唯一 ID
 */
@property (nonatomic, strong) NSString *conversationID;

/**
 *  如果是群会话，groupID 为群 ID
 */
@property (nonatomic, strong) NSString *groupID;

/**
 *  群类型
 */
@property (nonatomic, strong) NSString *groupType;

/**
 *  如果是单聊会话，userID 对方用户 ID
 */
@property (nonatomic, strong) NSString *userID;

/**
 *  会话头像
 */
@property (nonatomic, strong) NSString *faceUrl;

/**
 *  会话未读数
 */
@property (nonatomic, assign) int unreadCount;

/**
 *  会话草稿箱
 */
@property (nonatomic, strong) NSString *draftText;

/**
 *  头像图片，通过头像 URL 获取。
 */
@property (nonatomic, strong) UIImage *avatarImage;

/**
 *  标题
 */
@property (nonatomic, strong) NSString *title;

/**
 *  会话消息概览（下标题）
 *  概览负责显示对应会话最新一条消息的内容/类型。
 *  当最新的消息为文本消息/系统消息时，概览的内容为消息的文本内容。
 *  当最新的消息为多媒体消息时，概览的内容为对应的多媒体形式，如：“动画表情” / “[文件]” / “[语音]” / “[图片]” / “[视频]” 等。
 *  若当前会话有草稿时，概览内容为：“[草稿]XXXXX”，XXXXX为草稿内容。
 */
@property (nonatomic, strong) NSMutableAttributedString *subTitle;

/**
 *  群@ 消息 seq 列表
 */
@property (nonatomic, strong) NSMutableArray<NSNumber *> *atMsgSeqList;

/**
 *  最新消息时间
 *  记录会话中最新消息的接收/发送时间。
 */
@property (nonatomic, strong) NSDate *time;

/**
 *  会话置顶位
 *  YES：会话置顶；NO：会话未置顶。
 */
@property BOOL isOnTop;

/**
 * 显示消息多选flag
 * 会话列表中，默认不显示选择按钮。
 * 在消息转发场景下，列表 cell 被复用至选择会话页面，当点选“多选”按钮时，会话列表变为可多选状态
 * YES: 可多选，展示多选视图；NO:不可多选，展示默认视图
 */
@property (nonatomic, assign) BOOL showCheckBox;

/**
 * 显示是否选中 flag，默认是 NO
 */
@property (nonatomic, assign) BOOL selected;

/**
 *  消息是否免打扰
 */
@property (nonatomic, assign) BOOL isNotDisturb;

/**
 * 会话排序的 orderKey
 */
@property (nonatomic, assign) NSUInteger orderKey;

@end

NS_ASSUME_NONNULL_END
