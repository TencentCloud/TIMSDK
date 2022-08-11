//
//  TUICallKitGCDTimer.h
//  TUICallKit
//
//  Created by noah on 2022/8/4.
//  Copyright © 2022 Tencent. All rights reserved
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface TUICallKitGCDTimer : NSObject

+ (NSString *)timerTask:(void(^)(void))task
                  start:(NSTimeInterval)start
               interval:(NSTimeInterval)interval
                repeats:(BOOL)repeats
                  async:(BOOL)async;

+ (void)cancelTimer:(NSString *)timerName;

@end

NS_ASSUME_NONNULL_END
