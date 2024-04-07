
//  Created by Tencent on 2023/06/09.
//  Copyright © 2023 Tencent. All rights reserved.
/**
 *  This document declares the modules used to implement the conversation unit data source
 *  The conversation unit data source (hereinafter referred to as the "data source") contains a series of information and data required for the display of the
 * conversation unit, which will be described further below. The data source also contains some business logic, such as getting and generating message overview
 * (subTitle), updating conversation information (group message or user message update) and other logic.
 */

#import <TIMCommon/TIMCommonModel.h>
#import <TIMCommon/TIMDefine.h>

NS_ASSUME_NONNULL_BEGIN

@interface TUIContactConversationCellData_Minimalist : TUICommonCellData

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
 *  Conversation Messages Overview (subtitle)
 *  The overview is responsible for displaying the content/type of the latest message for the corresponding conversation.
 *  When the latest message is a text message/system message, the content of the overview is the text content of the message.
 *  When the latest message is a multimedia message, the content of the overview is the name of the corresponding multimedia form, such as: "Animation
 * Expression" / "[File]" / "[Voice]" / "[Picture]" / "[Video]", etc. . If there is a draft in the current conversation, the overview content is:
 * "[Draft]XXXXX", where XXXXX is the draft content.
 */
@property(nonatomic, strong) NSMutableAttributedString *subTitle;

/**
 *  seq list of group@ messages
 */
@property(nonatomic, strong) NSMutableArray<NSNumber *> *atMsgSeqs;

/**
 *  Latest message time
 *  Save the receive/send time of the latest message in the conversation.
 */
@property(nonatomic, strong) NSDate *time;

/**
 *  The flag that whether the conversation is pinned to the top
 */
@property(nonatomic, assign) BOOL isOnTop;

/**
 * Indicates whether to display the message checkbox
 * In the conversation list, the message checkbox is not displayed by default.
 * In the message forwarding scenario, the list cell is multiplexed to the select conversation page. When the "Multiple Choice" button is clicked, the
 * conversation list becomes multi-selectable. YES: Multiple selection is enable, multiple selection views are displayed; NO: Multiple selection is disable, the
 * default view is displayed
 */
@property(nonatomic, assign) BOOL showCheckBox;

/**
 * Indicates whether the current message is selected, the default is NO
 */
@property(nonatomic, assign) BOOL selected;

/**
 *  Whether the current conversation is marked as do-not-disturb for new messages
 */
@property(nonatomic, assign) BOOL isNotDisturb;

/**
 * key by which to sort the conversation list
 */
@property(nonatomic, assign) NSUInteger orderKey;
@end

NS_ASSUME_NONNULL_END
