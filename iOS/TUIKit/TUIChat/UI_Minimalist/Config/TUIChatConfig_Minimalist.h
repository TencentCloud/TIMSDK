//
//  TUIChatConfig_Minimalist.h
//  TUIChat
//
//  Created by Tencent on 2024/7/16.
//  Copyright © 2024 Tencent. All rights reserved.

#import <Foundation/Foundation.h>
#import "UIAlertController+TUICustomStyle.h"
#import "TUIChatShortcutMenuView.h"
#import <TIMCommon/TIMCommonModel.h>
#import <TIMCommon/TUIMessageCellLayout.h>
#import "TUIChatConfig.h"

NS_ASSUME_NONNULL_BEGIN

@class TUIMessageCellData;

typedef NS_ENUM(NSInteger, TUIAvatarStyle_Minimalist) {
    TUIAvatarStyleRectangle_Minimalist,
    TUIAvatarStyleCircle_Minimalist,
    TUIAvatarStyleRoundedRectangle_Minimalist,
};
typedef NS_OPTIONS(NSInteger, TUIChatItemWhenLongPressMessage_Minimalist) {
    TUIChatItemWhenLongPressMessage_Minimalist_None = 0,
    TUIChatItemWhenLongPressMessage_Minimalist_Reply = 1 << 0,
    TUIChatItemWhenLongPressMessage_Minimalist_EmojiReaction = 1 << 1,
    TUIChatItemWhenLongPressMessage_Minimalist_Quote = 1 << 2,
    TUIChatItemWhenLongPressMessage_Minimalist_Pin = 1 << 3,
    TUIChatItemWhenLongPressMessage_Minimalist_Recall = 1 << 4,
    TUIChatItemWhenLongPressMessage_Minimalist_Translate = 1 << 5,
    TUIChatItemWhenLongPressMessage_Minimalist_Convert = 1 << 6,
    TUIChatItemWhenLongPressMessage_Minimalist_Forward = 1 << 7,
    TUIChatItemWhenLongPressMessage_Minimalist_Select = 1 << 8,
    TUIChatItemWhenLongPressMessage_Minimalist_Copy = 1 << 9,
    TUIChatItemWhenLongPressMessage_Minimalist_Delete = 1 << 10,
    TUIChatItemWhenLongPressMessage_Minimalist_Info = 1 << 11,
};
@protocol TUIChatConfigDelegate_Minimalist <NSObject>
/**
 * Tells the delegate a user's avatar in the chat list is clicked.
 * Returning YES indicates this event has been intercepted, and Chat will not process it further.
 * Returning NO indicates this event is not intercepted, and Chat will continue to process it.
 */
- (BOOL)onUserAvatarClicked:(UIView *)view messageCellData:(TUIMessageCellData *)celldata;
/**
 * Tells the delegate a user's avatar in the chat list is long pressed.
 * Returning YES indicates that this event has been intercepted, and Chat will not process it further.
 * Returning NO indicates that this event is not intercepted, and Chat will continue to process it.
 */
- (BOOL)onUserAvatarLongPressed:(UIView *)view messageCellData:(TUIMessageCellData *)celldata;
/**
 * Tells the delegate a message in the chat list is clicked.
 * Returning YES indicates that this event has been intercepted, and Chat will not process it further.
 * Returning NO indicates that this event is not intercepted, and Chat will continue to process it.
 */
- (BOOL)onMessageClicked:(UIView *)view messageCellData:(TUIMessageCellData *)celldata;
/**
 * Tells the delegate a message in the chat list is long pressed.
 * Returning YES indicates that this event has been intercepted, and Chat will not process it further.
 * Returning NO indicates that this event is not intercepted, and Chat will continue to process it.
 */
- (BOOL)onMessageLongPressed:(UIView *)view messageCellData:(TUIMessageCellData *)celldata;
@end


@interface TUIChatConfig_Minimalist : NSObject
+ (TUIChatConfig_Minimalist *)sharedConfig;
/**
 * The object that acts as the delegate of the TUIChatMessageConfig_Minimalist.
 */
@property (nonatomic, weak) id<TUIChatConfigDelegate_Minimalist> delegate;
/**
 * Customize the backgroud color of message list interface.
 * This configuration takes effect in all message list interfaces.
 */
@property (nonatomic, strong) UIColor *backgroudColor;
/**
 * Customize the backgroud image of message list interface.
 * This configuration takes effect in all message list interfaces.
 */
@property (nonatomic, strong) UIImage *backgroudImage;
/**
 *  Customize the style of avatar.
 *  The default value is TUIAvatarStyleCircle.
 *  This configuration takes effect in all avatars.
 */
@property (nonatomic, assign) TUIAvatarStyle_Minimalist avatarStyle;
/**
 *  Customize the corner radius of the avatar.
 *  This configuration takes effect in all avatars.
 */
@property (nonatomic, assign) CGFloat avatarCornerRadius;
/**
 * Display the group avatar in the nine-square grid style.
 * The default value is YES.
 * This configuration takes effect in all groups.
 */
@property (nonatomic, assign) BOOL enableGroupGridAvatar;
/**
 *  Default avatar image.
 *  This configuration takes effect in all avatars.
 */
@property (nonatomic, strong) UIImage *defaultAvatarImage;
/**
 *  Enable the display "Alice is typing..." on one-to-one chat interface.
 *  The default value is YES.
 *  This configuration takes effect in all one-to-one chat message list interfaces.
 */
@property (nonatomic, assign) BOOL enableTypingIndicator;
/**
 *  When sending a message, set this flag to require message read receipt.
 *  The default value is NO.
 *  This configuration takes effect in all chat message list interfaces.
 */
@property (nonatomic, assign) BOOL isMessageReadReceiptNeeded;
/**
 *  Hide the "Video Call" button in the message list header.
 *  The default value is NO.
 */
@property (nonatomic, assign) BOOL hideVideoCallButton;
/**
 *  Hide the "Audio Call" button in the message list header.
 *  The default value is NO.
 */
@property (nonatomic, assign) BOOL hideAudioCallButton;
/**
 * Turn on audio and video call floating windows,
 * The default value is YES.
 */
@property (nonatomic, assign) BOOL enableFloatWindowForCall;
/**
 * Enable multi-terminal login function for audio and video calls
 * The default value is NO.
 */
@property (nonatomic, assign) BOOL enableMultiDeviceForCall;
/**
 * Set this parameter when the sender sends a message, and the receiver will not update the unread count after receiving the message.
 * The default value is NO.
 */
@property (nonatomic, assign) BOOL isExcludedFromUnreadCount;
/**
 * Set this parameter when the sender sends a message, and the receiver will not update the last message of the conversation after receiving the message.
 * The default value is NO.
 */
@property (nonatomic, assign) BOOL isExcludedFromLastMessage;
/**
 * Time interval within which a message can be recalled after being sent.
 * The default value is 120 seconds.
 * If you want to adjust this configuration, please modify the setting on Chat Console synchronously: https://trtc.io/document/34419?platform=web&product=chat&menulabel=uikit#message-recall-settings
 */
@property (nonatomic, assign) NSUInteger timeIntervalForAllowedMessageRecall;
/**
 * Maximum audio recording duration, no more than 60s.
 * The default value is 60 seconds.
 */
@property (nonatomic, assign) CGFloat maxAudioRecordDuration;
/**
 * Maximum video recording duration, no more than 15s.
 * The default value is 15 seconds.
 */
@property (nonatomic, assign) CGFloat maxVideoRecordDuration;
/**
 * Enable custom ringtone.
 * This config takes effect only for Android devices.
 */
@property (nonatomic, assign) BOOL enableAndroidCustomRing;
/**
 * Hide the items in the pop-up menu when user presses the message.
 */
+ (void)hideItemsWhenLongPressMessage:(TUIChatItemWhenLongPressMessage_Minimalist)items;
/**
 * Call this method to use speakers instead of handsets by default when playing voice messages.
 */
+ (void)setPlayingSoundMessageViaSpeakerByDefault;
/**
 * Add a custom view at the top of the chat interface.
 * This view will be displayed at the top of the message list and will not slide up.
 */
+ (void)setCustomTopView:(UIView *)view;
/**
 * Register custom message.
 * - Parameters:
 *   - businessID: Customized message‘s businessID, which is unique.
 *   - cellName: Customized message's MessagCell class name.
 *   - cellDataName: Customized message's MessagCellData class name.
 */
- (void)registerCustomMessage:(NSString *)businessID
         messageCellClassName:(NSString *)cellName
     messageCellDataClassName:(NSString *)cellDataName;
@end


@interface TUIChatConfig_Minimalist (MessageStyle)
/**
 * The color of send text message.
 */
@property(nonatomic, assign) UIColor *sendTextMessageColor;
/**
 * The font of send text message.
 */
@property(nonatomic, assign) UIFont *sendTextMessageFont;
/**
 * The color of receive text message.
 */
@property(nonatomic, assign) UIColor *receiveTextMessageColor;
/**
 * The font of receive text message.
 */
@property(nonatomic, assign) UIFont *receiveTextMessageFont;
/**
 * The text color of system message.
 */
@property (nonatomic, strong) UIColor *systemMessageTextColor;
/**
 * The font of system message.
 */
@property (nonatomic, strong) UIFont *systemMessageTextFont;
/**
 * The background color of system message.
 */
@property (nonatomic, strong) UIColor *systemMessageBackgroundColor;
@end


@interface TUIChatConfig_Minimalist (MessageLayout)
/**
 * Text message cell layout of my sent message.
 */
@property(nonatomic, assign, readonly) TUIMessageCellLayout *sendTextMessageLayout;
/**
 * Text message cell layout of my received message.
 */
@property(nonatomic, assign, readonly) TUIMessageCellLayout *receiveTextMessageLayout;
/**
 * Image message cell layout of my sent message.
 */
@property(nonatomic, assign, readonly) TUIMessageCellLayout *sendImageMessageLayout;
/**
 * Image message cell layout of my received message.
 */
@property(nonatomic, assign, readonly) TUIMessageCellLayout *receiveImageMessageLayout;
/**
 * Voice message cell layout of my sent message.
 */
@property(nonatomic, assign, readonly) TUIMessageCellLayout *sendVoiceMessageLayout;
/**
 * Voice message cell layout of my received message.
 */
@property(nonatomic, assign, readonly) TUIMessageCellLayout *receiveVoiceMessageLayout;
/**
 * Video message cell layout of my sent message.
 */
@property(nonatomic, assign, readonly) TUIMessageCellLayout *sendVideoMessageLayout;
/**
 * Video message cell layout of my received message.
 */
@property(nonatomic, assign, readonly) TUIMessageCellLayout *receiveVideoMessageLayout;
/**
 * Other message cell layout of my sent message.
 */
@property(nonatomic, assign, readonly) TUIMessageCellLayout *sendMessageLayout;
/**
 * Other message cell layout of my received message.
 */
@property(nonatomic, assign, readonly) TUIMessageCellLayout *receiveMessageLayout;
/**
 * System message cell layout.
 */
@property(nonatomic, assign, readonly) TUIMessageCellLayout *systemMessageLayout;
@end


@interface TUIChatConfig_Minimalist (MessageBubble)
/**
 * Enable the message display in the bubble style.
 * The default value is YES.
 */
@property(nonatomic, assign) BOOL enableMessageBubbleStyle;
/**
 * Set the background image of the last sent message bubble in consecutive messages.
 */
@property (nonatomic, strong) UIImage *sendLastBubbleBackgroundImage;
/**
 * Set the background image of the non-last sent message bubble in consecutive message.
 */
@property (nonatomic, strong) UIImage *sendBubbleBackgroundImage;
/**
 * Set the background image of the sent message bubble in highlight status.
 */
@property (nonatomic, strong) UIImage *sendHighlightBubbleBackgroundImage;
/**
 * Set the light background image when the sent message bubble needs to flicker.
 */
@property (nonatomic, strong) UIImage *sendAnimateLightBubbleBackgroundImage;
/**
 * Set the dark background image when the sent message bubble needs to flicker.
 */
@property (nonatomic, strong) UIImage *sendAnimateDarkBubbleBackgroundImage;
/**
 * Set the background image of the last received message bubble in consecutive message.
 */
@property (nonatomic, strong) UIImage *receiveLastBubbleBackgroundImage;
/**
 * Set the background image of the non-last received message bubble in consecutive message.
 */
@property (nonatomic, strong) UIImage *receiveBubbleBackgroundImage;
/**
 * Set the background image of the received message bubble in highlight status.
 */
@property (nonatomic, strong) UIImage *receiveHighlightBubbleBackgroundImage;
/**
 * Set the light background image when the received message bubble needs to flicker.
 */
@property (nonatomic, strong) UIImage *receiveAnimateLightBubbleBackgroundImage;
/**
 * Set the dark background image when the received message bubble needs to flicker.
 */
@property (nonatomic, strong) UIImage *receiveAnimateDarkBubbleBackgroundImage;
@end

@interface TUIChatConfig_Minimalist (InputBar)
/**
 *  DataSource for inputBar.
 */
@property (nonatomic, weak) id<TUIChatInputBarConfigDataSource> inputBarDataSource;
/**
 *  Show the input bar in the message list interface.
 *  The default value is YES.
 */
@property(nonatomic, assign) BOOL showInputBar;
/**
 *  Hide items in more menu.
 */
+ (void)hideItemsInMoreMenu:(TUIChatInputBarMoreMenuItem)items;
/**
 * Add sticker group.
 */
- (void)addStickerGroup:(TUIFaceGroup *)group;
@end


NS_ASSUME_NONNULL_END
