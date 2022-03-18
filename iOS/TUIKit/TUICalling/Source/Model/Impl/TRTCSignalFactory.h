//
//  TRTCSignalFactory.h
//  TUICalling
//
//  Created by adams on 2021/6/17.
//

#import <Foundation/Foundation.h>
#import "TRTCCallingUtils.h"

NS_ASSUME_NONNULL_BEGIN

@interface TRTCSignalFactory : NSObject

+ (NSMutableDictionary *)packagingSignalingWithExtInfo:(NSString *)extInfo
                                                roomID:(NSUInteger)roomID
                                                   cmd:(NSString *)cmd
                                               cmdInfo:(NSString *)cmdInfo
                                               message:(NSString *)message
                                              callType:(CallType)callType;

+ (NSMutableDictionary *)packagingSignalingWithExtInfo:(NSString *)extInfo
                                                roomID:(NSUInteger)roomID
                                                   cmd:(NSString *)cmd
                                               cmdInfo:(NSString *)cmdInfo
                                               userIds:(NSArray *)userIds
                                               message:(NSString *)message
                                              callType:(CallType)callType;

+ (NSDictionary *)getDataDictionary: (NSDictionary *)signaling;

+ (CallType)convertCmdToCallType:(NSString *)cmd;

+ (NSDictionary *)convertOldSignalingToNewSignaling:(NSDictionary *)oldSignalingDictionary;

@end

NS_ASSUME_NONNULL_END
