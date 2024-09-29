//
//  TUIChatConfig_Minimalist.m
//  TUIChat
//
//  Created by Tencent on 2024/7/16.
//  Copyright © 2024 Tencent. All rights reserved.

#import "TUIChatConfig_Minimalist.h"

#import <TUICore/TUIConfig.h>
#import <TIMCommon/TUIMessageCellLayout.h>
#import <TIMCommon/TUIMessageCell.h>
#import <TIMCommon/TIMConfig.h>
#import <TIMCommon/TUIBubbleMessageCell_Minimalist.h>
#import <TIMCommon/TUISystemMessageCellData.h>
#import <TIMCommon/TIMCommonMediator.h>
#import <TIMCommon/TUIEmojiMeditorProtocol.h>
#import "TUIBaseChatViewController_Minimalist.h"
#import "TUITextMessageCell_Minimalist.h"
#import "TUIEmojiConfig.h"
#import "TUIChatConversationModel.h"
#import "TUIVoiceMessageCellData.h"

@interface TUIChatConfig_Minimalist()<TUIChatEventListener>

@end

@implementation TUIChatConfig_Minimalist

+ (TUIChatConfig_Minimalist *)sharedConfig {
    static dispatch_once_t onceToken;
    static TUIChatConfig_Minimalist *config;
    dispatch_once(&onceToken, ^{
        config = [[TUIChatConfig_Minimalist alloc] init];
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

- (void)setAvatarStyle:(TUIAvatarStyle_Minimalist)avatarStyle {
    [TUIConfig defaultConfig].avatarType = (TUIKitAvatarType)avatarStyle;
}

- (TUIAvatarStyle_Minimalist)avatarStyle {
    return (TUIAvatarStyle_Minimalist)[TUIConfig defaultConfig].avatarType;
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

+ (void)hideItemsWhenLongPressMessage:(TUIChatItemWhenLongPressMessage_Minimalist)items {
    [TUIChatConfig defaultConfig].enablePopMenuReplyAction = !(items & TUIChatItemWhenLongPressMessage_Minimalist_Reply);
    [TUIChatConfig defaultConfig].enablePopMenuEmojiReactAction = !(items & TUIChatItemWhenLongPressMessage_Minimalist_EmojiReaction);
    [TUIChatConfig defaultConfig].enablePopMenuReferenceAction = !(items & TUIChatItemWhenLongPressMessage_Minimalist_Quote);
    [TUIChatConfig defaultConfig].enablePopMenuPinAction = !(items & TUIChatItemWhenLongPressMessage_Minimalist_Pin);
    [TUIChatConfig defaultConfig].enablePopMenuRecallAction = !(items & TUIChatItemWhenLongPressMessage_Minimalist_Recall);
    [TUIChatConfig defaultConfig].enablePopMenuTranslateAction = !(items & TUIChatItemWhenLongPressMessage_Minimalist_Translate);
    [TUIChatConfig defaultConfig].enablePopMenuConvertAction = !(items & TUIChatItemWhenLongPressMessage_Minimalist_Convert);
    [TUIChatConfig defaultConfig].enablePopMenuForwardAction = !(items & TUIChatItemWhenLongPressMessage_Minimalist_Forward);
    [TUIChatConfig defaultConfig].enablePopMenuSelectAction = !(items & TUIChatItemWhenLongPressMessage_Minimalist_Select);
    [TUIChatConfig defaultConfig].enablePopMenuCopyAction = !(items & TUIChatItemWhenLongPressMessage_Minimalist_Copy);
    [TUIChatConfig defaultConfig].enablePopMenuDeleteAction = !(items & TUIChatItemWhenLongPressMessage_Minimalist_Delete);
    [TUIChatConfig defaultConfig].enablePopMenuInfoAction = !(items & TUIChatItemWhenLongPressMessage_Minimalist_Info);
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
    [TUIBaseChatViewController_Minimalist setCustomTopView:view];
}

- (void)registerCustomMessage:(NSString *)businessID
         messageCellClassName:(NSString *)cellName
     messageCellDataClassName:(NSString *)cellDataName {
    [[TUIChatConfig defaultConfig] registerCustomMessage:businessID
                                    messageCellClassName:cellName
                                messageCellDataClassName:cellDataName
                                               styleType:TUIChatRegisterCustomMessageStyleTypeMinimalist];
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


@implementation TUIChatConfig_Minimalist (MessageStyle)

- (void)setSendNicknameFont:(UIFont *)sendNicknameFont {
    TUIMessageCell_Minimalist.outgoingNameFont = sendNicknameFont;
}

- (UIFont *)sendNicknameFont {
    return TUIMessageCell_Minimalist.outgoingNameFont;
}

- (void)setReceiveNicknameFont:(UIFont *)receiveNicknameFont {
    TUIMessageCell_Minimalist.incommingNameFont = receiveNicknameFont;
}

- (UIFont *)receiveNicknameFont {
    return TUIMessageCell_Minimalist.incommingNameFont;
}

- (void)setSendNicknameColor:(UIColor *)sendNicknameColor {
    TUIMessageCell_Minimalist.outgoingNameColor = sendNicknameColor;
}

- (UIColor *)sendNicknameColor {
    return TUIMessageCell_Minimalist.outgoingNameColor;
}

- (void)setReceiveNicknameColor:(UIColor *)receiveNicknameColor {
    TUIMessageCell_Minimalist.incommingNameColor = receiveNicknameColor;
}

- (UIColor *)receiveNicknameColor {
    return TUIMessageCell_Minimalist.incommingNameColor;
}

- (void)setSendTextMessageFont:(UIFont *)sendTextMessageFont {
    TUITextMessageCell_Minimalist.outgoingTextFont = sendTextMessageFont;
}

- (UIFont *)sendTextMessageFont {
    return TUITextMessageCell_Minimalist.outgoingTextFont;
}

- (void)setReceiveTextMessageFont:(UIFont *)receiveTextMessageFont {
    TUITextMessageCell_Minimalist.incommingTextFont = receiveTextMessageFont;
}

- (UIFont *)receiveTextMessageFont {
    return TUITextMessageCell_Minimalist.incommingTextFont;
}

- (void)setSendTextMessageColor:(UIColor *)sendTextMessageColor {
    TUITextMessageCell_Minimalist.outgoingTextColor = sendTextMessageColor;
}

- (UIColor *)sendTextMessageColor {
    return TUITextMessageCell_Minimalist.outgoingTextColor;
}

- (void)setReceiveTextMessageColor:(UIColor *)receiveTextMessageColor {
    TUITextMessageCell_Minimalist.incommingTextColor = receiveTextMessageColor;
}

- (UIColor *)receiveTextMessageColor {
    return TUITextMessageCell_Minimalist.incommingTextColor;
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

@implementation TUIChatConfig_Minimalist (MessageLayout)

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


@end


@implementation TUIChatConfig_Minimalist (MessageBubble)

- (void)setEnableMessageBubbleStyle:(BOOL)enableMessageBubbleStyle {
    [TIMConfig defaultConfig].enableMessageBubble = enableMessageBubbleStyle;
}

- (BOOL)enableMessageBubbleStyle {
    return [TIMConfig defaultConfig].enableMessageBubble;
}

- (void)setSendLastBubbleBackgroundImage:(UIImage *)sendLastBubbleBackgroundImage {
    [TUIBubbleMessageCell_Minimalist setOutgoingBubble:sendLastBubbleBackgroundImage];
}

- (UIImage *)sendLastBubbleBackgroundImage {
    return [TUIBubbleMessageCell_Minimalist outgoingBubble];
}

- (void)setSendBubbleBackgroundImage:(UIImage *)sendBubbleBackgroundImage {
    [TUIBubbleMessageCell_Minimalist setOutgoingSameBubble:sendBubbleBackgroundImage];
}

- (UIImage *)sendBubbleBackgroundImage {
    return [TUIBubbleMessageCell_Minimalist outgoingSameBubble];
}

- (void)setReceiveLastBubbleBackgroundImage:(UIImage *)receiveLastBubbleBackgroundImage {
    [TUIBubbleMessageCell_Minimalist setIncommingBubble:receiveLastBubbleBackgroundImage];
}

- (UIImage *)receiveLastBubbleBackgroundImage {
    return [TUIBubbleMessageCell_Minimalist incommingBubble];
}

- (void)setReceiveBubbleBackgroundImage:(UIImage *)receiveBubbleBackgroundImage {
    [TUIBubbleMessageCell_Minimalist setIncommingSameBubble:receiveBubbleBackgroundImage];
}

- (UIImage *)receiveBubbleBackgroundImage {
    return [TUIBubbleMessageCell_Minimalist incommingSameBubble];
}

- (void)setSendHighlightBubbleBackgroundImage:(UIImage *)sendHighlightBackgroundImage {
    [TUIBubbleMessageCell_Minimalist setOutgoingHighlightedBubble:sendHighlightBackgroundImage];
}

- (UIImage *)sendHighlightBubbleBackgroundImage {
    return [TUIBubbleMessageCell_Minimalist outgoingHighlightedBubble];
}

- (void)setReceiveHighlightBubbleBackgroundImage:(UIImage *)receiveHighlightBubbleBackgroundImage {
    [TUIBubbleMessageCell_Minimalist setIncommingHighlightedBubble:receiveHighlightBubbleBackgroundImage];
}

- (UIImage *)receiveHighlightBubbleBackgroundImage {
    return [TUIBubbleMessageCell_Minimalist incommingHighlightedBubble];
}

- (void)setSendAnimateLightBubbleBackgroundImage:(UIImage *)sendAnimateLightBackgroundImage {
    [TUIBubbleMessageCell_Minimalist setOutgoingAnimatedHighlightedAlpha20:sendAnimateLightBackgroundImage];
}

- (UIImage *)sendAnimateLightBubbleBackgroundImage {
    return [TUIBubbleMessageCell_Minimalist outgoingAnimatedHighlightedAlpha20];
}

- (void)setReceiveAnimateLightBubbleBackgroundImage:(UIImage *)receiveAnimateLightBubbleBackgroundImage {
    [TUIBubbleMessageCell_Minimalist setIncommingAnimatedHighlightedAlpha20:receiveAnimateLightBubbleBackgroundImage];
}

- (UIImage *)receiveAnimateLightBubbleBackgroundImage {
    return [TUIBubbleMessageCell_Minimalist incommingAnimatedHighlightedAlpha20];
}

- (void)setSendAnimateDarkBubbleBackgroundImage:(UIImage *)sendAnimateDarkBackgroundImage {
    [TUIBubbleMessageCell_Minimalist setOutgoingAnimatedHighlightedAlpha50:sendAnimateDarkBackgroundImage];
}

- (UIImage *)sendAnimateDarkBubbleBackgroundImage {
    return [TUIBubbleMessageCell_Minimalist outgoingAnimatedHighlightedAlpha50];
}

- (void)setReceiveAnimateDarkBubbleBackgroundImage:(UIImage *)receiveAnimateDarkBubbleBackgroundImage {
    [TUIBubbleMessageCell_Minimalist setIncommingAnimatedHighlightedAlpha50:receiveAnimateDarkBubbleBackgroundImage];
}

- (UIImage *)receiveAnimateDarkBubbleBackgroundImage {
    return [TUIBubbleMessageCell_Minimalist incommingAnimatedHighlightedAlpha50];
}

@end


@implementation TUIChatConfig_Minimalist (InputBar)

- (id<TUIChatInputBarConfigDataSource>)inputBarDataSource {
    return [TUIChatConfig defaultConfig].inputBarDataSource;
}

- (void)setInputBarDataSource:(id<TUIChatInputBarConfigDataSource>)inputBarDataSource {
    [TUIChatConfig defaultConfig].inputBarDataSource = inputBarDataSource;
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
}

- (void)addStickerGroup:(TUIFaceGroup *)group {
    id<TUIEmojiMeditorProtocol> service = [[TIMCommonMediator share] getObject:@protocol(TUIEmojiMeditorProtocol)];
    [service appendFaceGroup:group];
}

@end
