//
//  TRTCGCDTimer.h
//  TUICalling
//
//  Created by noah on 2021/8/24.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface TRTCGCDTimer : NSObject

/// 创建GCD定时器
/// @param task 任务
/// @param start 计时器开始时间
/// @param interval 时间间隔
/// @param repeats 时候否重复调用
/// @param async 是否在子线程
/// @return 定时器标识（最终取消定时器是需要根据此标识取消的）
+ (NSString *)timerTask:(void(^)(void))task
                  start:(NSTimeInterval)start
               interval:(NSTimeInterval)interval
                repeats:(BOOL)repeats
                  async:(BOOL)async;

/// 取消定时器
/// @param timerName 定时器标识
+ (void)canelTimer:(NSString *)timerName;

@end

NS_ASSUME_NONNULL_END
