
//  Created by Tencent on 2023/06/09.
//  Copyright © 2023 Tencent. All rights reserved.
/**
 *
 *  This file declares the modules used to implement the conversation unit data source.
 *  The conversation unit data source (hereinafter referred to as the "data source") contains a series of information and data required for the display of the
 * conversation unit, which will be described further below. The data source also contains some business logic, such as getting and generating message overview
 * (subTitle), updating conversation information (group message or user message update) and other logic.
 */

#import <TIMCommon/TIMCommonModel.h>
#import <TIMCommon/TIMDefine.h>

NS_ASSUME_NONNULL_BEGIN

typedef NS_ENUM(NSInteger, TUIConversationOnlineStatus) {
    TUIConversationOnlineStatusUnknown = 0,
    TUIConversationOnlineStatusOnline = 1,
    TUIConversationOnlineStatusOffline = 2,
};

/**
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
 *  The data source also contains some business logic, such as getting and generating message overview (subTitle), updating conversation information (group
 * message or user message update) and other logic.
 */
@interface TUIConversationCellData : TUICommonCellData

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
 *  Overview of conversation messages (sub title)
 *  The overview is responsible for displaying the content/type of the latest message for the corresponding conversation.
 *  When the latest message is a text message/system message, the content of the overview is the text content of the message
 *  When the latest message is a multimedia message, the content of the overview is in the corresponding multimedia form, such as: "[Animation Expression]" /
 * "[File]" / "[Voice]" / "[Picture]" / "[Video]", etc. If there is a draft in the current conversation, the overview content is: "[Draft]XXXXX", where XXXXX is
 * the draft content.
 */
@property(nonatomic, strong) NSMutableAttributedString *subTitle;

/**
 *  Group@ message tips string
 */
@property(nonatomic, strong) NSString *atTipsStr;

/**
 *  Sequence list of group-at message
 */
@property(nonatomic, strong) NSMutableArray<NSNumber *> *atMsgSeqs;

/**
 *
 *  The time of the latest message
 *  Recording the receive/send time of the latest message in the conversation.
 */
@property(nonatomic, strong) NSDate *time;

/**
 *
 *  The flag indicating whether the session is pinned
 *  YES: Conversation is pinned; NO: Conversation not pinned
 */
@property(nonatomic, assign) BOOL isOnTop;

/**
 *
 * Indicates whether to display the message checkbox
 * In the conversation list, the message checkbox is not displayed by default.
 * In the message forwarding scenario, the list cell is multiplexed to the select conversation page. When the "Multiple Choice" button is clicked, the
 * conversation list becomes multi-selectable. YES: Multiple selection is enable, multiple selection views are displayed; NO: Multiple selection is disable, the
 * default view is displayed
 */
@property(nonatomic, assign) BOOL showCheckBox;

/**
 * Indicates whether the current message is disable selected, the default is NO
 */
@property(nonatomic, assign) BOOL disableSelected;

/**
 * Indicates whether the current message is selected, the default is NO
 */
@property(nonatomic, assign) BOOL selected;

/**
 * Indicates whether the cell is displayed in lite mode, the default is NO
 */
@property(nonatomic, assign) BOOL isLiteMode;

/**
 *  Whether the current conversation is marked as do-not-disturb for new messages
 */
@property(nonatomic, assign) BOOL isNotDisturb;

/**
 * key by which to sort the conversation list
 */
@property(nonatomic, assign) NSUInteger orderKey;

/**
 * conversation group list
 */
@property(nonatomic, strong) NSArray *conversationGroupList;

/**
 * conversation mark list
 */
@property(nonatomic, strong) NSArray *conversationMarkList;

/**
 * The user's online status
 */
@property(nonatomic, assign) TUIConversationOnlineStatus onlineStatus;

/**
 * Conversation Mark -  The current conversation is marked as unread
 */
@property(nonatomic, assign) BOOL isMarkAsUnread;

/**
 * Conversation Mark - The current conversation is marked as hidden
 */
@property(nonatomic, assign) BOOL isMarkAsHide;

/**
 * Conversation Mark - The current conversation is marked as folded
 */
@property(nonatomic, assign) BOOL isMarkAsFolded;

/**
 * Conversation Mark - Conversation folded, when there are folded conversations, a folded group will be generated locally to accommodate them, this tag is the
 * folded group tag
 */
@property(nonatomic, assign) BOOL isLocalConversationFoldList;

/**
 * Conversation collapsed subtitle: in the format "group name: last message"
 */
@property(nonatomic, strong) NSMutableAttributedString *foldSubTitle;

@property(nonatomic, strong) V2TIMMessage *lastMessage;
@property(nonatomic, strong) V2TIMConversation *innerConversation;

+ (BOOL)isMarkedByHideType:(NSArray *)markList;

+ (BOOL)isMarkedByUnReadType:(NSArray *)markList;

+ (BOOL)isMarkedByFoldType:(NSArray *)markList;

@end

NS_ASSUME_NONNULL_END
