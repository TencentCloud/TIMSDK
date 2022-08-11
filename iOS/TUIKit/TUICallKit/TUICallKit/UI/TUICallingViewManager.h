//
//  TUICallingViewManager.h
//  TUICalling
//
//  Created by noah on 2022/5/17.
//  Copyright © 2022 Tencent. All rights reserved
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "TUICallEngineHeader.h"
#import "TUICallingStatusManager.h"

@class CallingUserModel;

NS_ASSUME_NONNULL_BEGIN

/**
 View Manager Class
 */
@interface TUICallingViewManager : NSObject <TUICallingStatusManagerProtocol>

- (void)createCallingView:(TUICallMediaType)callType callRole:(TUICallRole)callRole callScene:(TUICallScene)callScene;

- (void)createGroupCallingAcceptView:(TUICallMediaType)callType callRole:(TUICallRole)callRole callScene:(TUICallScene)callScene;

- (void)updateCallingView:(NSArray<CallingUserModel *> *)inviteeList sponsor:(CallingUserModel *)sponsor;

- (void)showCallingView;

- (void)closeCallingView;

- (UIView *)getCallingView;

- (void)updateCallingTimeStr:(NSString *)timeStr;

- (void)userEnter:(CallingUserModel *)userModel;

- (void)userLeave:(CallingUserModel *)userModel;

- (void)updateUser:(CallingUserModel *)userModel;

- (void)enableFloatWindow:(BOOL)enable;

@end

NS_ASSUME_NONNULL_END
