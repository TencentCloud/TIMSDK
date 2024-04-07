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
 *  UniqueID for a conversation
 */
@property(nonatomic, strong) NSString *conversationID;

/**
 *  If the conversation type is group chat, the groupID means group id
 */
@property(nonatomic, strong) NSString *groupID;

/**
 *  Group type
 */
@property(nonatomic, strong) NSString *groupType;

/**
 *  If the conversation type is one-to-one chat, the userID means peer user id
 */
@property(nonatomic, strong) NSString *userID;

/**
 *  title
 */
@property(nonatomic, strong) NSString *title;

/**
 *  The avatar of the user or group corresponding to the conversation
 */
@property(nonatomic, strong) NSString *faceUrl;

/**
 *  Image for avatar
 */
@property(nonatomic, strong) UIImage *avatarImage;

/**
 *  
 *  Conversation draft
 */
@property(nonatomic, strong) NSString *draftText;

/**
 *  Group@ message tip string
 */
@property(nonatomic, strong) NSString *atTipsStr;

/**
 *  Sequence list of group-at message
 */
@property(nonatomic, strong) NSMutableArray<NSNumber *> *atMsgSeqs;

/**
 *  The input status of the other Side (C2C Only)
 */

@property(nonatomic, assign) BOOL otherSideTyping;

/**
 *  A read receipt is required to send a message, the default is YES
 */
@property(nonatomic, assign) BOOL msgNeedReadReceipt;

/**
 *  Display the video call button, if the TUICalling component is integrated, the default is YES
 */

@property(nonatomic, assign) BOOL enableVideoCall;

/**
 *  Whether to display the audio call button, if the TUICalling component is integrated, the default is YES
 */
@property(nonatomic, assign) BOOL enableAudioCall;

/**
 *  Display custom welcome message button, default YES
 */
@property(nonatomic, assign) BOOL enableWelcomeCustomMessage;

@property(nonatomic, assign) BOOL enabelRoom;

@property(nonatomic, assign) BOOL isLimitedPortraitOrientation;

@property(nonatomic, assign) BOOL enablePoll;

@property(nonatomic, assign) BOOL enableGroupNote;

@property(nonatomic, assign) BOOL enableTakePhoto;

@property(nonatomic, assign) BOOL enableRecordVideo;

@property(nonatomic, assign) BOOL enableAlbum;

@property(nonatomic, assign) BOOL enableFile;

@end

NS_ASSUME_NONNULL_END
