//
//  TUIUtils.h
//  TXIMSDK_TUIKit_iOS
//
//  Created by xiangzhang on 2020/7/3.
//

#import <Foundation/Foundation.h>
#import "TRTCCallingModel.h"
@import ImSDK_Plus;

NS_ASSUME_NONNULL_BEGIN

@interface TRTCCallingUtils : NSObject

///生成随机 RoomID
+ (UInt32)generateRoomID;

+ (void)getCallUserModel:(NSString *)userID finished:(void(^)(CallUserModel *))finished;

+ (NSString *)dictionary2JsonStr:(NSDictionary *)dict;

+ (NSData *)dictionary2JsonData:(NSDictionary *)dict;

+ (NSDictionary *)jsonSring2Dictionary:(NSString *)jsonString;

+ (NSDictionary *)jsonData2Dictionary:(NSData *)jsonData;

@end

NS_ASSUME_NONNULL_END
