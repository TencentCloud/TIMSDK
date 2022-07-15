//
//  TUIChatConversationModel.h
//  TXIMSDK_TUIKit_iOS
//
//  Created by kayev on 2021/8/12.
//

#import <Foundation/Foundation.h>

@import UIKit;

NS_ASSUME_NONNULL_BEGIN

@interface TUIChatConversationModel : NSObject

/**
 *  会话唯一 ID
 */
@property (nonatomic, strong) NSString *conversationID;

/**
 *  如果是群会话，groupID 为群 ID
 */
@property (nonatomic, strong) NSString *groupID;

/**
 *  群类型
 */
@property (nonatomic, strong) NSString *groupType;

/**
 *  如果是单聊会话，userID 对方用户 ID
 */
@property (nonatomic, strong) NSString *userID;

/**
 *  标题
 */
@property (nonatomic, strong) NSString *title;

/**
 *  会话头像
 */
@property (nonatomic, strong) NSString *faceUrl;

/**
 *  头像图片，通过头像 UIImage 获取。
 */
@property (nonatomic, strong) UIImage *avatarImage;

/**
 *  会话草稿箱
 */
@property (nonatomic, strong) NSString *draftText;

/**
 *  群@ 消息 seq 列表
 */
@property (nonatomic, strong) NSMutableArray<NSNumber *> *atMsgSeqs;

/**
 *  对方的输入状态 (单聊 Only)
 *  The input status of the other Side (C2C Only)
 */

@property (nonatomic, assign) BOOL otherSideTyping;

@end

NS_ASSUME_NONNULL_END
