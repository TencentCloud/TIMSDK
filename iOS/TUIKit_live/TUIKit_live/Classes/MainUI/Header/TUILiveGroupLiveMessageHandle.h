//
//  TUILiveGroupLiveMessageHandle.h
//  TXIMSDK_TUIKit_live_iOS
//
//  Created by coddyliu on 2020/9/28.
//

#import <Foundation/Foundation.h>
#import "TUILiveRoomAnchorViewController.h"
NS_ASSUME_NONNULL_BEGIN

@interface TUILiveGroupLiveMessageHandle : NSObject
+ (instancetype)shareInstance;
- (void)startObserver:(id<TUILiveRoomAnchorDelegate>)observer;
- (void)stopObserver;
@end

NS_ASSUME_NONNULL_END
