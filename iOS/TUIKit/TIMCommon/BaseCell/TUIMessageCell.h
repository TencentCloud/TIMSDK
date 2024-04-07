
//  Created by Tencent on 2023/06/09.
//  Copyright © 2023 Tencent. All rights reserved.
/**
 *
 *
 *  This document declares the modules and components used to implement the message unit.
 *  The message unit (TUIMessageCell) is a general term for the bubble message/picture message/emoticon message/video message displayed in the chat view.
 *  The above messages are implemented by inheriting from this class or a subclass of this class. If you want to customize the message, you also need to
 * implement it by inheriting from this class or a subclass of this class. The XXXX message unit (TUIXXXXMessageCell) is mainly responsible for displaying on
 * the page and responding to user interaction events. For data processing and acquisition in the message unit, please refer to
 * TUIChat\CellData\TUIXXXXMessageCellData.h according to the specific message unit
 *
 *  The interaction callbacks provided by the TUIMessageCellDelegate protocol include: long press, resend, click on the message, click on the avatar, etc.
 *  The TUIMessageCell class stores message-related information, such as the sender's avatar, sender's nickname, and message content (supports various formats
 * such as text, pictures, and videos). At the same time, TUIMessageeCell, as a parent class, provides basic properties and behavior templates for subclass
 * messages.
 */

#import <UIKit/UIKit.h>
#import "TUIFitButton.h"
#import "TUIMessageCellData.h"
#import "TUISecurityStrikeView.h"


@class TUIMessageCell;


@protocol TUIMessageCellProtocol <NSObject>

@required
+ (CGFloat)getHeight:(TUIMessageCellData *)data withWidth:(CGFloat)width;
+ (CGFloat)getEstimatedHeight:(TUIMessageCellData *)data;
+ (CGSize)getContentSize:(TUIMessageCellData *)data;

@end


/////////////////////////////////////////////////////////////////////////////////
//
//                              TUIMessageCellDelegate
//
/////////////////////////////////////////////////////////////////////////////////

@protocol TUIMessageCellDelegate <NSObject>

/**
 *  Callback for long press message
 *  You can use this callback to implement secondary operations such as delete and recall (when the sender of the message long-presses his own message) on top
 * of the long-pressed message.
 */
- (void)onLongPressMessage:(TUIMessageCell *)cell;

/**
 *  Callback for clicking retryView
 *  You can use this callback to implement: resend the message.
 */
- (void)onRetryMessage:(TUIMessageCell *)cell;

/**
 *  Callback for clicking message cell
 *  Usually:
 *  - Clicking on the sound message means playing voice
 *  - Clicking on the file message means opening the file
 *  - Clicking on the picture message means showing the larger image
 *  - Clicking on the video message means playing the video.
 *  Usually, it only provides a reference for the function implementation, and you can implement the delegate function according to your needs.
 */
- (void)onSelectMessage:(TUIMessageCell *)cell;

/**
 *  Callback for clicking avatar view of the messageCell
 *  You can use this callback to implement: in response to the user's click, jump to the detailed information interface of the corresponding user.
 */
- (void)onSelectMessageAvatar:(TUIMessageCell *)cell;

/**
 *  Callback for long pressing avatar view of messageCell
 */
- (void)onLongSelectMessageAvatar:(TUIMessageCell *)cell;

/**
 *  Callback for clicking read receipt label
 */
- (void)onSelectReadReceipt:(TUIMessageCellData *)cell;

/**
 * Clicking the x-person reply button to jump to the multi-person reply details page
 */
- (void)onJumpToRepliesDetailPage:(TUIMessageCellData *)data;


- (void)onJumpToMessageInfoPage:(TUIMessageCellData *)data selectCell:(TUIMessageCell *)cell;

@end

/////////////////////////////////////////////////////////////////////////////////
//
//                              TUIMessageCell
//
/////////////////////////////////////////////////////////////////////////////////

@interface TUIMessageCell : TUICommonTableViewCell <TUIMessageCellProtocol>

/**
 * Icon that identifies the message selected
 * In the multi-selection scenario, it is used to identify whether the message is selected
 */
@property(nonatomic, strong) UIImageView *selectedIcon;

/**
 * Message selection view
 * When multiple selection is activated, the view will be overlaid on this cell, and clicking on the view will trigger the check/uncheck of the message
 */
@property(nonatomic, strong) UIButton *selectedView;

/**
 *  
 *  The icon view of displays user's avatar
 */
@property(nonatomic, strong) UIImageView *avatarView;

/**
 *  
 *  The label of displays user's displayname
 */
@property(nonatomic, strong) UILabel *nameLabel;

/**
 *  Container view
 *  It wraps various views of MesageCell as the "bottom" of MessageCell, which is convenient for view management and layout.
 */
@property(nonatomic, strong) UIView *container;

/**
 *  Activity indicator
 *  A circling icon is provided while the message is being sent to indicate that the message is being sent.
 */
@property(nonatomic, strong) UIActivityIndicatorView *indicator;

/**
 *  Retry view, displayed after sending failed, click on this view to trigger onRetryMessage: callback.
 */
@property(nonatomic, strong) UIImageView *retryView;


/**
 *  security Strike View
 */
@property (nonatomic, strong) TUISecurityStrikeView * securityStrikeView;

/**
 *  Message reply details button
 */
@property(nonatomic, strong) TUIFitButton *messageModifyRepliesButton;

/**
 * The message data class which stores the information required in the messageCell, including sender ID, sender avatar, message sending status, message bubble
 * icon, etc. For details of messageData, please refer to: TUIChat\Cell\CellData\TUIMessageCellData.h
 */
@property(readonly) TUIMessageCellData *messageData;

/**
 *  A control that identifies whether a message has been read
 */
@property(nonatomic, strong) UILabel *readReceiptLabel;

/**
 * The message time label control, which is not displayed by default, is located at the far right of the message cell
 * In the message forwarding scenario, open the forwarded message list, and the time of the current message will be displayed on the far right of the message.
 */
@property(nonatomic, strong) UILabel *timeLabel;

/**
 * Whether to disable the default selection behavior encapsulated in TUIKit, such as group live broadcast by default to create live room and other behaviors,
 * default: NO
 */
@property(nonatomic, assign) BOOL disableDefaultSelectAction;

@property(nonatomic, weak) id<TUIMessageCellDelegate> delegate;

/**
 * 
 * Whether the highlight flashing animation is in progress
 */
@property(nonatomic, assign) BOOL highlightAnimating;

- (void)fillWithData:(TUICommonCellData *)data;

/**
 * Set the highlighting effect after matching the keyword, mainly used for jumping after message search, subclass rewriting
 * The base class provides the default highlighting effect, and the subclass can implement it freely
 *
 * @param keyword  Highlight keywords
 */
- (void)highlightWhenMatchKeyword:(NSString *)keyword;

/**
 * Returns the view for highlighting
 */
- (UIView *)highlightAnimateView;

/**
 * Update the content of the read label
 */
- (void)updateReadLabelText;

/// Preset bottom container in cell, which can be added custom view/viewControllers.
@property(nonatomic, strong) UIView *bottomContainer;

/// When bottom container is layout ready, notify it to add custom extensions.
- (void)notifyBottomContainerReadyOfData:(TUIMessageCellData *)cellData;

/// Callback of SelectCell
@property(nonatomic, copy) TUIValueCallbck pluginMsgSelectCallback;

@end


@interface TUIMessageCell (TUILayoutConfiguration)

/**
 *  The color of the label that displays the recipient's nickname
 *  Used when the nickname needs to be displayed and the message direction is MsgDirectionIncoming
 */
@property(nonatomic, class) UIColor *incommingNameColor;

/**
 *
 *  The font of the label that displays the recipient's nickname
 *  Used when the nickname needs to be displayed and the message direction is MsgDirectionIncoming
 *
 */
@property(nonatomic, class) UIFont *incommingNameFont;

/**
 *  The color of the label showing the sender's nickname
 *  Used when the nickname needs to be displayed and the message direction is MsgDirectionOutgoing.
 */
@property(nonatomic, class) UIColor *outgoingNameColor;

/**
 *
 *  The font of the label that displays the sender's nickname
 *  Used when the nickname needs to be displayed and the message direction is MsgDirectionOutgoing.
 */
@property(nonatomic, class) UIFont *outgoingNameFont;

@end
