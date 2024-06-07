//
//  TUIChatCallingDataProvider.h
//  TUIChat
//
//  Created by harvy on 2022/12/21.
//  Copyright © 2023 Tencent. All rights reserved.
//

#import <Foundation/Foundation.h>

#import <ImSDK_Plus/ImSDK_Plus.h>

@class TUIMessageCellData;

NS_ASSUME_NONNULL_BEGIN

/**
 * The protocol type of calls
 */
typedef NS_ENUM(NSInteger, TUICallProtocolType) {
    TUICallProtocolTypeUnknown = 0,
    TUICallProtocolTypeSend = 1,
    TUICallProtocolTypeAccept = 2,
    TUICallProtocolTypeReject = 3,
    TUICallProtocolTypeCancel = 4,
    TUICallProtocolTypeHangup = 5,
    TUICallProtocolTypeTimeout = 6,
    TUICallProtocolTypeLineBusy = 7,
    TUICallProtocolTypeSwitchToAudio = 8,
    TUICallProtocolTypeSwitchToAudioConfirm = 9,
};

/**
 * The stream media type of calls
 */
typedef NS_ENUM(NSInteger, TUICallStreamMediaType) {
    TUICallStreamMediaTypeUnknown = 0,
    TUICallStreamMediaTypeVoice = 1,
    TUICallStreamMediaTypeVideo = 2,
};

/**
 * The participant style of calls
 */
typedef NS_ENUM(NSInteger, TUICallParticipantType) {
    TUICallParticipantTypeUnknown = 0,
    TUICallParticipantTypeC2C = 1,
    TUICallParticipantTypeGroup = 2,
};

/**
 * The role of participant
 */
typedef NS_ENUM(NSInteger, TUICallParticipantRole) {
    TUICallParticipantRoleUnknown = 0,
    TUICallParticipantRoleCaller = 1,
    TUICallParticipantRoleCallee = 2,
};

/**
 * The direction of voice-video-call message
 */
typedef NS_ENUM(NSInteger, TUICallMessageDirection) {
    TUICallMessageDirectionIncoming = 0,
    TUICallMessageDirectionOutgoing = 1,
};

@protocol TUIChatCallingInfoProtocol <NSObject>

/**
 * The protocol type of voice-video-call
 */
@property(nonatomic, assign, readonly) TUICallProtocolType protocolType;

/**
 * The stream media type of voice-video-call
 */
@property(nonatomic, assign, readonly) TUICallStreamMediaType streamMediaType;

/**
 * The participate type of voice-video-call, one-to-one and group are supported
 */
@property(nonatomic, assign, readonly) TUICallParticipantType participantType;

/**
 * The participate role type of voice-video-call, caller and callee are supported
 */
@property(nonatomic, assign, readonly) TUICallParticipantRole participantRole;

/**
 * Exclude from history of chat page，supported in TUIChat 7.1 and later
 */
@property(nonatomic, assign, readonly) BOOL excludeFromHistory;

/**
 * The display text of voice-video-call message
 */
@property(nonatomic, copy, readonly, nonnull) NSString *content;

/**
 * 
 * The display direction of voice-video-call message
 */
@property(nonatomic, assign, readonly) TUICallMessageDirection direction;

/**
 * 
 * Whether display unread point in call history
 */
@property(nonatomic, assign, readonly) BOOL showUnreadPoint;

/**
 * Whether to use the receiver's avatar
 */
@property(nonatomic, assign, readonly) BOOL isUseReceiverAvatar;


@property(nonatomic, strong, readonly) NSArray<NSString *> *participantIDList;

@end

/**
 * The style of voice-video-call message in TUIChat
 */
typedef NS_ENUM(NSInteger, TUIChatCallingMessageAppearance) {
    TUIChatCallingMessageAppearanceDetails = 0,
    TUIChatCallingMessageAppearanceSimplify = 1,
};

@protocol TUIChatCallingDataProtocol <NSObject>

/**
 * Seting styles of voice-video-call message in TUIChat
 */
- (void)setCallingMessageStyle:(TUIChatCallingMessageAppearance)style;

/**
 * Redial based on the current voice-video-call message (generally used to redial after clicking the call history on the chat page)
 */
- (void)redialFromMessage:(V2TIMMessage *)innerMessage;

/**
 * Parse voice-video-call message
 */
- (BOOL)isCallingMessage:(V2TIMMessage *)innerMessage callingInfo:(id<TUIChatCallingInfoProtocol> __nullable *__nullable)callingInfo;

@end

@interface TUIChatCallingDataProvider : NSObject <TUIChatCallingDataProtocol>

@end

NS_ASSUME_NONNULL_END
