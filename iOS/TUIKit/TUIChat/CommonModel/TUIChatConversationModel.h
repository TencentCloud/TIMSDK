//
//  TUIChatConversationModel.h
//  TXIMSDK_TUIKit_iOS
//
//  Created by kayev on 2021/8/12.
//  Copyright © 2023 Tencent. All rights reserved.
//

#import <Foundation/Foundation.h>

@import UIKit;

NS_ASSUME_NONNULL_BEGIN

@interface TUIChatConversationModel : NSObject

/**
 *  会话唯一 ID
 *  UniqueID for a conversation
 */
@property(nonatomic, strong) NSString *conversationID;

/**
 *  如果是群会话，groupID 为群 ID
 *  If the conversation type is group chat, the groupID means group id
 */
@property(nonatomic, strong) NSString *groupID;

/**
 *  群类型
 *  Group type
 */
@property(nonatomic, strong) NSString *groupType;

/**
 *  如果是单聊会话，userID 对方用户 ID
 *  If the conversation type is one-to-one chat, the userID means peer user id
 */
@property(nonatomic, strong) NSString *userID;

/**
 *  标题
 *  title
 */
@property(nonatomic, strong) NSString *title;

/**
 *  会话头像
 *  The avatar of the user or group corresponding to the conversation
 */
@property(nonatomic, strong) NSString *faceUrl;

/**
 *  头像图片
 *  Image for avatar
 */
@property(nonatomic, strong) UIImage *avatarImage;

/**
 *  会话草稿箱
 *  Conversation draft
 */
@property(nonatomic, strong) NSString *draftText;

/**
 *  群@ 消息 seq 列表
 *  Sequence list of group-at message
 */
@property(nonatomic, strong) NSMutableArray<NSNumber *> *atMsgSeqs;

/**
 *  对方的输入状态 (单聊 Only)
 *  The input status of the other Side (C2C Only)
 */

@property(nonatomic, assign) BOOL otherSideTyping;

@property(nonatomic, assign) BOOL enabelVideo;

@property(nonatomic, assign) BOOL enabelAudio;

@property(nonatomic, assign) BOOL enabelRoom;

@property(nonatomic, assign) BOOL isLimitedPortraitOrientation;

@end

NS_ASSUME_NONNULL_END
