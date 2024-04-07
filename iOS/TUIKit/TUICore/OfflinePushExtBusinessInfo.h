//
//  OfflinePushExtBusinessInfo.h
//  TUICore
//
//  Created by cologne on 2024/3/19.
//  Copyright © 2024 Tencent. All rights reserved.

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

// Common feature function class instance
@interface OfflinePushExtBusinessInfo : NSObject

/**
 * Set the version number of offline messages
 */
@property(nonatomic, assign) NSInteger version;
/**
 * Set the chat type of offline messages sent by the identifier (1: Single chat; 2: Group chat)
 */
@property(nonatomic, assign) NSInteger chatType;
/**
 * Set the type of offline messages sent by the identity (1:Chat Message;  2: Call Message)
 */
@property(nonatomic, assign) NSInteger action;
/**
 * Set the sender ID that identifies offline messages (the userID or groupID of the sender can identify the chatID of the chat)
 */
@property(nonatomic, copy) NSString *sender;
/**
 * Identifies the sender nickname of offline messages
 */
@property(nonatomic, copy) NSString *nickname;
/**
 * Sender avatar for offline messages
 */
@property(nonatomic, copy) NSString *faceUrl;
/**
 * Display fields for offline messages
 */
@property(nonatomic, copy) NSString *content;
/**
 * Set custom data (will be completely transparently transmitted to the receiving end)
 */
@property(nonatomic, strong) NSData *customData;

- (void)configWithEntityDic:(NSDictionary *)entityDic;
- (NSDictionary *)toReportData;
@end

NS_ASSUME_NONNULL_END
