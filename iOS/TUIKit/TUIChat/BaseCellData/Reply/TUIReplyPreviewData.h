//
//  TUIReplyPreviewData.h
//  TUIChat
//
//  Created by wyl on 2022/3/22.
//  Copyright © 2023 Tencent. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "TUIChatDefine.h"

@class V2TIMMessage;

@interface TUIReplyPreviewData : NSObject

/**
 * The message ID of the replyed original message
 */
@property(nonatomic, copy) NSString *msgID;

/**
 * The abstract of the replyed original message
 */
@property(nonatomic, copy) NSString *msgAbstract;

/**
 * The sender's displayname of the replyed original message. Nickname is prior than userID.
 */
@property(nonatomic, copy) NSString *sender;

/**
 * The faceURL of the replyed original message
 */
@property(nonatomic, copy) NSString *faceURL;

/**
 * The message type of the replyed original message. For details, see the enumeration value of V2TIMElemType.
 */
@property(nonatomic, assign) NSInteger type;

/**
 * The replyed original message
 */
@property(nonatomic, strong) V2TIMMessage *originMessage;

//  Message reply root RootID (not necessarily the msgID of the originMessage above, but the ID of the message at the top)
@property(nonatomic, copy) NSString *messageRootID;

+ (NSString *)displayAbstract:(NSInteger)type abstract:(NSString *)abstract withFileName:(BOOL)withFilename isRisk:(BOOL)isRisk;

@end

@interface TUIReferencePreviewData : TUIReplyPreviewData

@end
