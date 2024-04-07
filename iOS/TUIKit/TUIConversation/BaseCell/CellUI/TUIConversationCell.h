
//  Created by Tencent on 2023/06/09.
//  Copyright © 2023 Tencent. All rights reserved.

#import <TIMCommon/TIMCommonModel.h>
#import "TUIConversationCellData.h"

NS_ASSUME_NONNULL_BEGIN

/**
 *
 * [Function description] In the message list interface, display the preview information of a single conversation.
 * The session information displayed in the session unit includes:
 * 1. Avatar information (user avatar/group avatar)
 * 2. Session title (user nickname/group name)
 * 3. Conversation message overview (displays the latest message content)
 * 4. Number of unread messages (if there are unread messages)
 * 5. Session time (receipt/sent time of the latest message)
 */
@interface TUIConversationCell : UITableViewCell

/**
 *  Image view for displaying avatar
 *  When conversation type is one-to-one, the image view will display user's avatar
 *  When conversation type is group chat, the image view will display group's avatar
 */
@property(nonatomic, strong) UIImageView *headImageView;

/**
 *  Title of conversation
 *  When conversation type is one-to-one, the title is the friend's remarks, and if the corresponding friend has no remarks, the friend's ID is displayed.
 *  When the conversation is a group chat, the title is the group name.
 */
@property(nonatomic, strong) UILabel *titleLabel;

/**
 *  Overview of conversation messages (sub title)
 *  The overview is responsible for displaying the content/type of the latest message for the corresponding conversation.
 *  When the latest message is a text message/system message, the content of the overview is the text content of the message
 *  When the latest message is a multimedia message, the content of the overview is in the corresponding multimedia form, such as: "[Animation Expression]" /
 * "[File]" / "[Voice]" / "[Picture]" / "[Video]", etc. If there is a draft in the current conversation, the overview content is: "[Draft]XXXXX", where XXXXX is
 * the draft content.
 */
@property(nonatomic, strong) UILabel *subTitleLabel;

/**
 *  The label for displaying time
 *  Responsible for displaying the received/sent time of the latest message in the conversation unit.
 */
@property(nonatomic, strong) UILabel *timeLabel;

/**
 *  The red dot view that identifies whether the current conversation is set to do not disturb
 */
@property(nonatomic, strong) UIView *notDisturbRedDot;

/**
 *  The image view that identifies whether the current conversation is set to do not disturb
 */
@property(nonatomic, strong) UIImageView *notDisturbView;

/**
 *  A view indicating whether the current conversation has unread messages
 *  If the current conversation has unread messages, the unread count is displayed to the right of the conversation unit.
 */
@property(nonatomic, strong) TUIUnReadView *unReadView;

/**
 * Icon indicating whether the conversation is selected
 * In the multi-selection scenario, it is used to identify whether the conversation is selected
 */
@property(nonatomic, strong) UIImageView *selectedIcon;

/**
 * The icon of the user's online status
 */
@property(nonatomic, strong) UIImageView *onlineStatusIcon;

@property(nonatomic, strong) UIImageView *lastMessageStatusImageView;

@property(atomic, strong) TUIConversationCellData *convData;

- (void)fillWithData:(TUIConversationCellData *)convData;

@end

NS_ASSUME_NONNULL_END
