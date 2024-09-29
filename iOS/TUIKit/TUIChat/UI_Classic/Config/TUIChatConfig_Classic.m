//
//  TUIChatConfig_Classic.m
//  TUIChat
//
//  Created by Tencent on 2024/7/16.
//  Copyright © 2024 Tencent. All rights reserved.

#import "TUIChatConfig_Classic.h"

#import <TUICore/TUIConfig.h>
#import <TIMCommon/TUIBubbleMessageCell.h>
#import <TIMCommon/TUISystemMessageCellData.h>
#import <TIMCommon/TUIMessageCell.h>
#import <TIMCommon/TIMConfig.h>
#import <TIMCommon/TIMCommonMediator.h>
#import <TIMCommon/TUIEmojiMeditorProtocol.h>
#import "TUIBaseChatViewController.h"
#import "TUITextMessageCell.h"
#import "TUIEmojiConfig.h"
#import "TUIChatConversationModel.h"
#import "TUIVoiceMessageCellData.h"

@interface TUIChatConfig_Classic()<TUIChatEventListener>

@end

@implementation TUIChatConfig_Classic

+ (TUIChatConfig_Classic *)sharedConfig {
    static dispatch_once_t onceToken;
    static TUIChatConfig_Classic *config;
    dispatch_once(&onceToken, ^{
        config = [[TUIChatConfig_Classic alloc] init];
    });
    return config;
}

- (instancetype)init {
    self = [super init];
    if (self) {
        TUIChatConfig.defaultConfig.eventConfig.chatEventListener = self;
    }
    return self;
}

- (void)setEnableTypingIndicator:(BOOL)enable {
    [TUIChatConfig defaultConfig].enableTypingStatus = enable;
}

- (BOOL)enableTypingIndicator {
    return [TUIChatConfig defaultConfig].enableTypingStatus;
}

- (void)setBackgroudColor:(UIColor *)backgroudColor {
    [TUIChatConfig defaultConfig].backgroudColor = backgroudColor;
}

- (UIColor *)backgroudColor {
    return [TUIChatConfig defaultConfig].backgroudColor;
}

- (void)setBackgroudImage:(UIImage *)backgroudImage {
    [TUIChatConfig defaultConfig].backgroudImage = backgroudImage;
}

- (UIImage *)backgroudImage {
    return [TUIChatConfig defaultConfig].backgroudImage;
}

- (void)setAvatarStyle:(TUIAvatarStyle_Classic)avatarStyle {
    [TUIConfig defaultConfig].avatarType = (TUIKitAvatarType)avatarStyle;
}

- (TUIAvatarStyle_Classic)avatarStyle {
    return (TUIAvatarStyle_Classic)[TUIConfig defaultConfig].avatarType;
}

- (void)setAvatarCornerRadius:(CGFloat)avatarCornerRadius {
    [TUIConfig defaultConfig].avatarCornerRadius = avatarCornerRadius;
}

- (CGFloat)avatarCornerRadius {
    return [TUIConfig defaultConfig].avatarCornerRadius;
}

- (void)setDefaultAvatarImage:(UIImage *)defaultAvatarImage {
    [TUIConfig defaultConfig].defaultAvatarImage = defaultAvatarImage;
}

- (UIImage *)defaultAvatarImage {
    return [TUIConfig defaultConfig].defaultAvatarImage;
}

- (void)setEnableGroupGridAvatar:(BOOL)enableGroupGridAvatar {
    [TUIConfig defaultConfig].enableGroupGridAvatar = enableGroupGridAvatar;
}

- (BOOL)enableGroupGridAvatar {
    return [TUIConfig defaultConfig].enableGroupGridAvatar;
}

- (void)setIsMessageReadReceiptNeeded:(BOOL)isMessageReadReceiptNeeded {
    [TUIChatConfig defaultConfig].msgNeedReadReceipt = isMessageReadReceiptNeeded;
}

- (BOOL)isMessageReadReceiptNeeded {
    return [TUIChatConfig defaultConfig].msgNeedReadReceipt;
}

- (void)setTimeIntervalForAllowedMessageRecall:(NSUInteger)timeIntervalForAllowedMessageRecall {
    [TUIChatConfig defaultConfig].timeIntervalForMessageRecall = timeIntervalForAllowedMessageRecall;
}

- (NSUInteger)timeIntervalForAllowedMessageRecall {
    return [TUIChatConfig defaultConfig].timeIntervalForMessageRecall;
}

- (void)setEnableFloatWindowForCall:(BOOL)enableFloatWindowForCall {
    [TUIChatConfig defaultConfig].enableFloatWindowForCall = enableFloatWindowForCall;
}

- (BOOL)enableFloatWindowForCall {
    return [TUIChatConfig defaultConfig].enableFloatWindowForCall;
}

- (void)setEnableMultiDeviceForCall:(BOOL)enableMultiDeviceForCall {
    [TUIChatConfig defaultConfig].enableMultiDeviceForCall = enableMultiDeviceForCall;
}

- (BOOL)enableMultiDeviceForCall {
    return [TUIChatConfig defaultConfig].enableMultiDeviceForCall;
}

- (void)setHideVideoCallButton:(BOOL)hideVideoCallButton {
    [TUIChatConfig defaultConfig].enableVideoCall = !hideVideoCallButton;
}

- (void)setEnableAndroidCustomRing:(BOOL)enableAndroidCustomRing {
    [TUIConfig defaultConfig].enableCustomRing = enableAndroidCustomRing;
}

- (BOOL)enableAndroidCustomRing {
    return [TUIConfig defaultConfig].enableCustomRing;
}

- (BOOL)hideVideoCallButton {
    return ![TUIChatConfig defaultConfig].enableVideoCall;
}

- (void)setHideAudioCallButton:(BOOL)hideAudioCallButton {
    [TUIChatConfig defaultConfig].enableAudioCall = !hideAudioCallButton;
}

- (BOOL)hideAudioCallButton {
    return ![TUIChatConfig defaultConfig].enableAudioCall;
}

+ (void)hideItemsWhenLongPressMessage:(TUIChatItemWhenLongPressMessage_Classic)items {
    [TUIChatConfig defaultConfig].enablePopMenuReplyAction = !(items & TUIChatItemWhenLongPressMessage_Classic_Reply);
    [TUIChatConfig defaultConfig].enablePopMenuEmojiReactAction = !(items & TUIChatItemWhenLongPressMessage_Classic_EmojiReaction);
    [TUIChatConfig defaultConfig].enablePopMenuReferenceAction = !(items & TUIChatItemWhenLongPressMessage_Classic_Quote);
    [TUIChatConfig defaultConfig].enablePopMenuPinAction = !(items & TUIChatItemWhenLongPressMessage_Classic_Pin);
    [TUIChatConfig defaultConfig].enablePopMenuRecallAction = !(items & TUIChatItemWhenLongPressMessage_Classic_Recall);
    [TUIChatConfig defaultConfig].enablePopMenuTranslateAction = !(items & TUIChatItemWhenLongPressMessage_Classic_Translate);
    [TUIChatConfig defaultConfig].enablePopMenuConvertAction = !(items & TUIChatItemWhenLongPressMessage_Classic_Convert);
    [TUIChatConfig defaultConfig].enablePopMenuForwardAction = !(items & TUIChatItemWhenLongPressMessage_Classic_Forward);
    [TUIChatConfig defaultConfig].enablePopMenuSelectAction = !(items & TUIChatItemWhenLongPressMessage_Classic_Select);
    [TUIChatConfig defaultConfig].enablePopMenuCopyAction = !(items & TUIChatItemWhenLongPressMessage_Classic_Copy);
    [TUIChatConfig defaultConfig].enablePopMenuDeleteAction = !(items & TUIChatItemWhenLongPressMessage_Classic_Delete);
}

- (void)setIsExcludedFromUnreadCount:(BOOL)isExcludedFromUnreadCount {
    [TUIConfig defaultConfig].isExcludedFromUnreadCount = isExcludedFromUnreadCount;
}

- (BOOL)isExcludedFromUnreadCount {
    return [TUIConfig defaultConfig].isExcludedFromUnreadCount;
}

- (void)setIsExcludedFromLastMessage:(BOOL)isExcludedFromLastMessage {
    [TUIConfig defaultConfig].isExcludedFromLastMessage = isExcludedFromLastMessage;
}

- (BOOL)isExcludedFromLastMessage {
    return [TUIConfig defaultConfig].isExcludedFromLastMessage;
}

- (void)setMaxAudioRecordDuration:(CGFloat)maxAudioRecordDuration {
    [TUIChatConfig defaultConfig].maxAudioRecordDuration = maxAudioRecordDuration;
}

- (CGFloat)maxAudioRecordDuration {
    return [TUIChatConfig defaultConfig].maxAudioRecordDuration;
}

- (void)setMaxVideoRecordDuration:(CGFloat)maxVideoRecordDuration {
    [TUIChatConfig defaultConfig].maxVideoRecordDuration = maxVideoRecordDuration;
}

- (CGFloat)maxVideoRecordDuration {
    return [TUIChatConfig defaultConfig].maxVideoRecordDuration;
}

+ (void)setPlayingSoundMessageViaSpeakerByDefault {
    if ([TUIVoiceMessageCellData getAudioplaybackStyle] == TUIVoiceAudioPlaybackStyleHandset) {
        [TUIVoiceMessageCellData changeAudioPlaybackStyle];
    }
}

+ (void)setCustomTopView:(UIView *)view {
    [TUIBaseChatViewController setCustomTopView:view];
}

- (void)registerCustomMessage:(NSString *)businessID
         messageCellClassName:(NSString *)cellName
     messageCellDataClassName:(NSString *)cellDataName {
    [[TUIChatConfig defaultConfig] registerCustomMessage:businessID
                                    messageCellClassName:cellName
                                messageCellDataClassName:cellDataName];
}


#pragma mark - TUIChatEventListener
- (BOOL)onUserIconClicked:(UIView *)view messageCellData:(TUIMessageCellData *)celldata {
    if ([self.delegate respondsToSelector:@selector(onUserAvatarClicked:messageCellData:)]) {
        return [self.delegate onUserAvatarClicked:view messageCellData:celldata];
    }
    return NO;
}

- (BOOL)onUserIconLongClicked:(UIView *)view messageCellData:(TUIMessageCellData *)celldata {
    if ([self.delegate respondsToSelector:@selector(onUserAvatarLongPressed:messageCellData:)]) {
        return [self.delegate onUserAvatarLongPressed:view messageCellData:celldata];
    }
    return NO;
}

- (BOOL)onMessageClicked:(UIView *)view messageCellData:(TUIMessageCellData *)celldata {
    if ([self.delegate respondsToSelector:@selector(onMessageClicked:messageCellData:)]) {
        return [self.delegate onMessageClicked:view messageCellData:celldata];
    }
    return NO;
}

- (BOOL)onMessageLongClicked:(UIView *)view messageCellData:(TUIMessageCellData *)celldata {
    if ([self.delegate respondsToSelector:@selector(onMessageLongPressed:messageCellData:)]) {
        return [self.delegate onMessageLongPressed:view messageCellData:celldata];
    }
    return NO;
}

@end



@implementation TUIChatConfig_Classic (MessageStyle)

- (void)setSendNicknameFont:(UIFont *)sendNicknameFont {
    TUIMessageCell.outgoingNameFont = sendNicknameFont;
}

- (UIFont *)sendNicknameFont {
    return TUIMessageCell.outgoingNameFont;
}

- (void)setReceiveNicknameFont:(UIFont *)receiveNicknameFont {
    TUIMessageCell.incommingNameFont = receiveNicknameFont;
}

- (UIFont *)receiveNicknameFont {
    return TUIMessageCell.incommingNameFont;
}

- (void)setSendNicknameColor:(UIColor *)sendNicknameColor {
    TUIMessageCell.outgoingNameColor = sendNicknameColor;
}

- (UIColor *)sendNicknameColor {
    return TUIMessageCell.outgoingNameColor;
}

- (void)setReceiveNicknameColor:(UIColor *)receiveNicknameColor {
    TUIMessageCell.incommingNameColor = receiveNicknameColor;
}

- (UIColor *)receiveNicknameColor {
    return TUIMessageCell.incommingNameColor;
}

- (void)setSendTextMessageFont:(UIFont *)sendTextMessageFont {
    TUITextMessageCell.outgoingTextFont = sendTextMessageFont;
}

- (UIFont *)sendTextMessageFont {
    return TUITextMessageCell.outgoingTextFont;
}

- (void)setReceiveTextMessageFont:(UIFont *)receiveTextMessageFont {
    TUITextMessageCell.incommingTextFont = receiveTextMessageFont;
}

- (UIFont *)receiveTextMessageFont {
    return TUITextMessageCell.incommingTextFont;
}

- (void)setSendTextMessageColor:(UIColor *)sendTextMessageColor {
    TUITextMessageCell.outgoingTextColor = sendTextMessageColor;
}

- (UIColor *)sendTextMessageColor {
    return TUITextMessageCell.outgoingTextColor;
}

- (void)setReceiveTextMessageColor:(UIColor *)receiveTextMessageColor {
    TUITextMessageCell.incommingTextColor = receiveTextMessageColor;
}

- (UIColor *)receiveTextMessageColor {
    return TUITextMessageCell.incommingTextColor;
}

@end


typedef NS_ENUM(NSInteger, UIMessageCellLayoutType) {
    UIMessageCellLayoutTypeText,
    UIMessageCellLayoutTypeImage,
    UIMessageCellLayoutTypeVideo,
    UIMessageCellLayoutTypeVoice,
    UIMessageCellLayoutTypeOther,
    UIMessageCellLayoutTypeSystem
};

@implementation TUIChatConfig_Classic (MessageLayout)

- (TUIMessageCellLayout *)sendTextMessageLayout {
    return [self getMessageLayoutOfType:UIMessageCellLayoutTypeText isSender:YES];
}

- (TUIMessageCellLayout *)receiveTextMessageLayout {
    return [self getMessageLayoutOfType:UIMessageCellLayoutTypeText isSender:NO];
}

- (TUIMessageCellLayout *)sendImageMessageLayout {
    return [self getMessageLayoutOfType:UIMessageCellLayoutTypeImage isSender:YES];
}

- (TUIMessageCellLayout *)receiveImageMessageLayout {
    return [self getMessageLayoutOfType:UIMessageCellLayoutTypeImage isSender:NO];
}

- (TUIMessageCellLayout *)sendVoiceMessageLayout {
    return [self getMessageLayoutOfType:UIMessageCellLayoutTypeVoice isSender:YES];
}

- (TUIMessageCellLayout *)receiveVoiceMessageLayout {
    return [self getMessageLayoutOfType:UIMessageCellLayoutTypeVoice isSender:NO];
}

- (TUIMessageCellLayout *)sendVideoMessageLayout {
    return [self getMessageLayoutOfType:UIMessageCellLayoutTypeVideo isSender:YES];
}

- (TUIMessageCellLayout *)receiveVideoMessageLayout {
    return [self getMessageLayoutOfType:UIMessageCellLayoutTypeVideo isSender:NO];
}

- (TUIMessageCellLayout *)sendMessageLayout {
    return [self getMessageLayoutOfType:UIMessageCellLayoutTypeOther isSender:YES];
}

- (TUIMessageCellLayout *)receiveMessageLayout {
    return [self getMessageLayoutOfType:UIMessageCellLayoutTypeOther isSender:NO];
}

- (TUIMessageCellLayout *)systemMessageLayout {
    return [self getMessageLayoutOfType:UIMessageCellLayoutTypeSystem isSender:NO];
}

- (TUIMessageCellLayout *)getMessageLayoutOfType:(UIMessageCellLayoutType)type isSender:(BOOL)isSender {
    TUIMessageCellLayout *innerLayout = nil;
    switch (type) {
        case UIMessageCellLayoutTypeText: {
            innerLayout = isSender ? [TUIMessageCellLayout outgoingTextMessageLayout] : [TUIMessageCellLayout incommingTextMessageLayout];
            break;
        }
        case UIMessageCellLayoutTypeImage: {
            innerLayout = isSender ? [TUIMessageCellLayout outgoingImageMessageLayout] : [TUIMessageCellLayout incommingImageMessageLayout];
            break;
        }
        case UIMessageCellLayoutTypeVideo: {
            innerLayout = isSender ? [TUIMessageCellLayout outgoingVideoMessageLayout] : [TUIMessageCellLayout incommingVideoMessageLayout];
            break;
        }
        case UIMessageCellLayoutTypeVoice: {
            innerLayout = isSender ? [TUIMessageCellLayout outgoingVoiceMessageLayout] : [TUIMessageCellLayout incommingVoiceMessageLayout];
            break;
        }
        case UIMessageCellLayoutTypeOther: {
            innerLayout = isSender ? [TUIMessageCellLayout outgoingMessageLayout] : [TUIMessageCellLayout incommingMessageLayout];
            break;
        }
        case UIMessageCellLayoutTypeSystem: {
            innerLayout = [TUIMessageCellLayout systemMessageLayout];
            break;
        }
    }
    return innerLayout;
}

- (void)setSystemMessageBackgroundColor:(UIColor *)systemMessageBackgroundColor {
    TUISystemMessageCellData.textBackgroundColor = systemMessageBackgroundColor;
}

- (UIColor *)systemMessageBackgroundColor {
    return TUISystemMessageCellData.textBackgroundColor;
}

- (void)setSystemMessageTextFont:(UIFont *)systemMessageTextFont {
    TUISystemMessageCellData.textFont = systemMessageTextFont;
}

- (UIFont *)systemMessageTextFont {
    return TUISystemMessageCellData.textFont;
}

- (void)setSystemMessageTextColor:(UIColor *)systemMessageTextColor {
    TUISystemMessageCellData.textColor = systemMessageTextColor;
}

- (UIColor *)systemMessageTextColor {
    return TUISystemMessageCellData.textColor;
}

- (void)setReceiveNicknameFont:(UIFont *)receiveNicknameFont {
    TUIMessageCell.incommingNameFont = receiveNicknameFont;
}

- (UIFont *)receiveNicknameFont {
    return TUIMessageCell.incommingNameFont;
}

- (void)setReceiveNicknameColor:(UIColor *)receiveNicknameColor {
    TUIMessageCell.incommingNameColor = receiveNicknameColor;
}

- (UIColor *)receiveNicknameColor {
    return TUIMessageCell.incommingNameColor;
}

@end


@implementation TUIChatConfig_Classic (MessageBubble)

- (void)setEnableMessageBubbleStyle:(BOOL)enableMessageBubbleStyle {
    [TIMConfig defaultConfig].enableMessageBubble = enableMessageBubbleStyle;
}

- (BOOL)enableMessageBubbleStyle {
    return [TIMConfig defaultConfig].enableMessageBubble;
}

- (void)setSendBubbleBackgroundImage:(UIImage *)sendBubbleBackgroundImage {
    [TUIBubbleMessageCell setOutgoingBubble:sendBubbleBackgroundImage];
}

- (UIImage *)sendBubbleBackgroundImage {
    return [TUIBubbleMessageCell outgoingBubble];
}

- (void)setSendHighlightBubbleBackgroundImage:(UIImage *)sendHighlightBackgroundImage {
    [TUIBubbleMessageCell setOutgoingHighlightedBubble:sendHighlightBackgroundImage];
}

- (UIImage *)sendHighlightBubbleBackgroundImage {
    return [TUIBubbleMessageCell outgoingHighlightedBubble];
}

- (void)setSendAnimateLightBubbleBackgroundImage:(UIImage *)sendAnimateLightBackgroundImage {
    [TUIBubbleMessageCell setOutgoingAnimatedHighlightedAlpha20:sendAnimateLightBackgroundImage];
}

- (UIImage *)sendAnimateLightBubbleBackgroundImage {
    return [TUIBubbleMessageCell outgoingAnimatedHighlightedAlpha20];
}

- (void)setSendAnimateDarkBubbleBackgroundImage:(UIImage *)sendAnimateDarkBackgroundImage {
    [TUIBubbleMessageCell setOutgoingAnimatedHighlightedAlpha50:sendAnimateDarkBackgroundImage];
}

- (UIImage *)sendAnimateDarkBubbleBackgroundImage {
    return [TUIBubbleMessageCell outgoingAnimatedHighlightedAlpha50];
}

- (void)setSendErrorBubbleBackgroundImage:(UIImage *)sendErrorBubbleBackgroundImage {
    [TUIBubbleMessageCell setOutgoingErrorBubble:sendErrorBubbleBackgroundImage];
}

- (UIImage *)sendErrorBubbleBackgroundImage {
    return [TUIBubbleMessageCell outgoingErrorBubble];
}

- (void)setReceiveBubbleBackgroundImage:(UIImage *)receiveBubbleBackgroundImage {
    [TUIBubbleMessageCell setIncommingBubble:receiveBubbleBackgroundImage];
}

- (UIImage *)receiveBubbleBackgroundImage {
    return [TUIBubbleMessageCell incommingBubble];
}

- (void)setReceiveHighlightBubbleBackgroundImage:(UIImage *)receiveHighlightBubbleBackgroundImage {
    [TUIBubbleMessageCell setIncommingHighlightedBubble:receiveHighlightBubbleBackgroundImage];
}

- (UIImage *)receiveHighlightBubbleBackgroundImage {
    return [TUIBubbleMessageCell incommingHighlightedBubble];
}

- (void)setReceiveAnimateLightBubbleBackgroundImage:(UIImage *)receiveAnimateLightBubbleBackgroundImage {
    [TUIBubbleMessageCell setIncommingAnimatedHighlightedAlpha20:receiveAnimateLightBubbleBackgroundImage];
}

- (UIImage *)receiveAnimateLightBubbleBackgroundImage {
    return [TUIBubbleMessageCell incommingAnimatedHighlightedAlpha20];
}

- (void)setReceiveAnimateDarkBubbleBackgroundImage:(UIImage *)receiveAnimateDarkBubbleBackgroundImage {
    [TUIBubbleMessageCell setIncommingAnimatedHighlightedAlpha50:receiveAnimateDarkBubbleBackgroundImage];
}

- (UIImage *)receiveAnimateDarkBubbleBackgroundImage {
    return [TUIBubbleMessageCell incommingAnimatedHighlightedAlpha50];
}

- (void)setReceiveErrorBubbleBackgroundImage:(UIImage *)receiveErrorBubbleBackgroundImage {
    [TUIBubbleMessageCell setIncommingErrorBubble:receiveErrorBubbleBackgroundImage];
}

- (UIImage *)receiveErrorBubbleBackgroundImage {
    return [TUIBubbleMessageCell incommingErrorBubble];
}

@end


@implementation TUIChatConfig_Classic (InputBar)

- (id<TUIChatInputBarConfigDataSource>)setinputBarDataSource {
    return [TUIChatConfig defaultConfig].inputBarDataSource;
}

- (void)setInputBarDataSource:(id<TUIChatInputBarConfigDataSource>)inputBarDataSource {
    [TUIChatConfig defaultConfig].inputBarDataSource = inputBarDataSource;
}

- (id<TUIChatShortcutViewDataSource>)shortcutViewDataSource {
    return [TUIChatConfig defaultConfig].shortcutViewDataSource;
}

- (void)setShortcutViewDataSource:(id<TUIChatShortcutViewDataSource>)shortcutViewDataSource {
    [TUIChatConfig defaultConfig].shortcutViewDataSource = shortcutViewDataSource;
}

- (void)setShowInputBar:(BOOL)showInputBar {
    [TUIChatConfig defaultConfig].enableMainPageInputBar = showInputBar;
}

- (BOOL)showInputBar {
    return ![TUIChatConfig defaultConfig].enableMainPageInputBar;
}

+ (void)hideItemsInMoreMenu:(TUIChatInputBarMoreMenuItem)items {
    [TUIChatConfig defaultConfig].enableWelcomeCustomMessage = !(items & TUIChatInputBarMoreMenuItem_CustomMessage);
    [TUIChatConfig defaultConfig].showRecordVideoButton = !(items & TUIChatInputBarMoreMenuItem_RecordVideo);
    [TUIChatConfig defaultConfig].showTakePhotoButton = !(items & TUIChatInputBarMoreMenuItem_TakePhoto);
    [TUIChatConfig defaultConfig].showAlbumButton = !(items & TUIChatInputBarMoreMenuItem_Album);
    [TUIChatConfig defaultConfig].showFileButton = !(items & TUIChatInputBarMoreMenuItem_File);
    [TUIChatConfig defaultConfig].showRoomButton = !(items & TUIChatInputBarMoreMenuItem_Room);
    [TUIChatConfig defaultConfig].showPollButton = !(items & TUIChatInputBarMoreMenuItem_Poll);
    [TUIChatConfig defaultConfig].showGroupNoteButton = !(items & TUIChatInputBarMoreMenuItem_GroupNote);
    [TUIChatConfig defaultConfig].enableVideoCall = !(items & TUIChatInputBarMoreMenuItem_VideoCall);
    [TUIChatConfig defaultConfig].enableAudioCall = !(items & TUIChatInputBarMoreMenuItem_AudioCall);
}

- (void)addStickerGroup:(TUIFaceGroup *)group {
    id<TUIEmojiMeditorProtocol> service = [[TIMCommonMediator share] getObject:@protocol(TUIEmojiMeditorProtocol)];
    [service appendFaceGroup:group];
}

@end
