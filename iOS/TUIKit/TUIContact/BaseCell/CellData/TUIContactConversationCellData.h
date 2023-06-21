
//  Created by Tencent on 2023/06/09.
//  Copyright © 2023 Tencent. All rights reserved.
/**
 *  本文件声明了用于实现会话单元数据源的模块。
 *  会话单元数据源（以下简称“数据源”）包含了会话单元显示所需的一系列信息与数据，这些信息与数据将会在下文进一步说明。
 *  数据源中还包含了部分的业务逻辑，如获取并生成消息概览（subTitle），更新会话信息（群消息或用户消息更新）等逻辑。
 *
 *  This document declares the modules used to implement the conversation unit data source
 *  The conversation unit data source (hereinafter referred to as the "data source") contains a series of information and data required for the display of the
 * conversation unit, which will be described further below. The data source also contains some business logic, such as getting and generating message overview
 * (subTitle), updating conversation information (group message or user message update) and other logic.
 */

#import <TIMCommon/TIMCommonModel.h>
#import <TIMCommon/TIMDefine.h>

NS_ASSUME_NONNULL_BEGIN

@interface TUIContactConversationCellData : TUICommonCellData

@property(nonatomic, strong) NSString *conversationID;

@property(nonatomic, strong) NSString *groupID;

@property(nonatomic, strong) NSString *groupType;

@property(nonatomic, strong) NSString *userID;

@property(nonatomic, strong) NSString *title;

@property(nonatomic, strong) NSString *faceUrl;

@property(nonatomic, strong) UIImage *avatarImage;

@property(nonatomic, strong) NSString *draftText;

@property(nonatomic, assign) int unreadCount;

/**
 *  会话消息概览（下标题）
 *  概览负责显示对应会话最新一条消息的内容/类型。
 *  当最新的消息为文本消息/系统消息时，概览的内容为消息的文本内容。
 *  当最新的消息为多媒体消息时，概览的内容为对应的多媒体形式，如：“动画表情” / “[文件]” / “[语音]” / “[图片]” / “[视频]” 等。
 *  若当前会话有草稿时，概览内容为：“[草稿]XXXXX”，XXXXX为草稿内容。
 *
 *  Conversation Messages Overview (subtitle)
 *  The overview is responsible for displaying the content/type of the latest message for the corresponding conversation.
 *  When the latest message is a text message/system message, the content of the overview is the text content of the message.
 *  When the latest message is a multimedia message, the content of the overview is the name of the corresponding multimedia form, such as: "Animation
 * Expression" / "[File]" / "[Voice]" / "[Picture]" / "[Video]", etc. . If there is a draft in the current conversation, the overview content is:
 * "[Draft]XXXXX", where XXXXX is the draft content.
 */
@property(nonatomic, strong) NSMutableAttributedString *subTitle;

/**
 *  群@ 消息 seq 列表
 *  seq list of group@ messages
 */
@property(nonatomic, strong) NSMutableArray<NSNumber *> *atMsgSeqs;

/**
 *  最新消息时间
 *  记录会话中最新消息的接收/发送时间。
 *
 *  Latest message time
 *  Save the receive/send time of the latest message in the conversation.
 */
@property(nonatomic, strong) NSDate *time;

/**
 *  会话置顶位
 *  The flag that whether the conversation is pinned to the top
 */
@property(nonatomic, assign) BOOL isOnTop;

/**
 * 显示消息多选flag
 * 会话列表中，默认不显示选择按钮。
 * 在消息转发场景下，列表 cell 被复用至选择会话页面，当点选“多选”按钮时，会话列表变为可多选状态
 * YES: 可多选，展示多选视图；NO:不可多选，展示默认视图
 *
 * Indicates whether to display the message checkbox
 * In the conversation list, the message checkbox is not displayed by default.
 * In the message forwarding scenario, the list cell is multiplexed to the select conversation page. When the "Multiple Choice" button is clicked, the
 * conversation list becomes multi-selectable. YES: Multiple selection is enable, multiple selection views are displayed; NO: Multiple selection is disable, the
 * default view is displayed
 */
@property(nonatomic, assign) BOOL showCheckBox;

/**
 * 显示是否选中 flag，默认是 NO
 * Indicates whether the current message is selected, the default is NO
 */
@property(nonatomic, assign) BOOL selected;

/**
 *  消息是否免打扰
 *  Whether the current conversation is marked as do-not-disturb for new messages
 */
@property(nonatomic, assign) BOOL isNotDisturb;

/**
 * 会话排序的 orderKey
 * key by which to sort the conversation list
 */
@property(nonatomic, assign) NSUInteger orderKey;
@end

NS_ASSUME_NONNULL_END
