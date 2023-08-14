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
 * 通话协议类型
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
 * 通话流媒体类型
 * The stream media type of calls
 */
typedef NS_ENUM(NSInteger, TUICallStreamMediaType) {
    TUICallStreamMediaTypeUnknown = 0,
    TUICallStreamMediaTypeVoice = 1,
    TUICallStreamMediaTypeVideo = 2,
};

/**
 * 通话的参与者样式
 * The participant style of calls
 */
typedef NS_ENUM(NSInteger, TUICallParticipantType) {
    TUICallParticipantTypeUnknown = 0,
    TUICallParticipantTypeC2C = 1,
    TUICallParticipantTypeGroup = 2,
};

/**
 * 通话人员的角色
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
 * 音视频通话的协议类型
 * The protocol type of voice-video-call
 */
@property(nonatomic, assign, readonly) TUICallProtocolType protocolType;

/**
 * 音视频通话的流媒体类型
 * The stream media type of voice-video-call
 */
@property(nonatomic, assign, readonly) TUICallStreamMediaType streamMediaType;

/**
 * 音视频通话的参与者类型，目前仅支持 C2C 和 Group
 * The participate type of voice-video-call, one-to-one and group are supported
 */
@property(nonatomic, assign, readonly) TUICallParticipantType participantType;

/**
 * 音视频通话的参与者角色，目前仅支持主叫和被叫
 * The participate role type of voice-video-call, caller and callee are supported
 */
@property(nonatomic, assign, readonly) TUICallParticipantRole participantRole;

/**
 * 是否在 TUIChat 消息列表上过滤，TUIChat 7.1 版本开始支持
 * Exclude from history of chat page，supported in TUIChat 7.1 and later
 */
@property(nonatomic, assign, readonly) BOOL excludeFromHistory;

/**
 * 音视频通话消息的展示文本
 * The display text of voice-video-call message
 */
@property(nonatomic, copy, readonly, nonnull) NSString *content;

/**
 * 音视频通话消息的展示方向
 * The display direction of voice-video-call message
 */
@property(nonatomic, assign, readonly) TUICallMessageDirection direction;

/**
 * 通话记录是否展示未读红点
 * Whether display unread point in call history
 */
@property(nonatomic, assign, readonly) BOOL showUnreadPoint;

/**
 * Whether to use the receiver's avatar
 */
@property(nonatomic, assign, readonly) BOOL isUseReceiverAvatar;

@end

/**
 * 音视频通话消息的 UI 外观
 * The style of voice-video-call message in TUIChat
 */
typedef NS_ENUM(NSInteger, TUIChatCallingMessageAppearance) {
    TUIChatCallingMessageAppearanceDetails = 0,
    TUIChatCallingMessageAppearanceSimplify = 1,
};

@protocol TUIChatCallingDataProtocol <NSObject>

/**
 * 设置音视频通话消息的 UI 样式
 * Seting styles of voice-video-call message in TUIChat
 */
- (void)setCallingMessageStyle:(TUIChatCallingMessageAppearance)style;

/**
 * 基于当前的音视频消息，重拨（一般用于点击聊天页面的通话记录后重新拨打）
 * Redial based on the current voice-video-call message (generally used to redial after clicking the call history on the chat page)
 */
- (void)redialFromMessage:(V2TIMMessage *)innerMessage;

/**
 * 解析音视频通话消息
 * Parse voice-video-call message
 */
- (BOOL)isCallingMessage:(V2TIMMessage *)innerMessage callingInfo:(id<TUIChatCallingInfoProtocol> __nullable *__nullable)callingInfo;

@end

@interface TUIChatCallingDataProvider : NSObject <TUIChatCallingDataProtocol>

@end

NS_ASSUME_NONNULL_END
