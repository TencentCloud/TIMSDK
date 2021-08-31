//
//  TUILiveHeartBeatManager.h
//  Pods
//
//  Created by harvy on 2020/9/25.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface TUILiveHeartBeatManager : NSObject

+ (instancetype)shareManager;


/// 开始心跳
/// @param type 直播间类型,      直播:liveRoom   语音房:voiceRoom
/// @param roomId 房间id
- (void)startWithType:(NSString *)type roomId:(NSString *)roomId;

/// 结束心跳
- (void)stop;

@end

NS_ASSUME_NONNULL_END
