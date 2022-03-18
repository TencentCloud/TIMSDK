//
//  TUIInvitedActionProtocal.h
//  TUICalling
//
//  Created by noah on 2021/8/30.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@protocol TUIInvitedActionProtocal <NSObject>

/// 接听Calling电话
- (void)acceptCalling;

/// 拒接Calling电话
- (void)refuseCalling;

/// 主动挂断电话
- (void)hangupCalling;

@end

NS_ASSUME_NONNULL_END
