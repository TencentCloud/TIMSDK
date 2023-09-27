//
//  BaseCallViewProtocol.h
//  TUICalling
//
//  Created by noah on 2022/5/17.
//  Copyright © 2022 Tencent. All rights reserved
//

#import <Foundation/Foundation.h>
#import "UIColor+TUICallingHex.h"
#import "TUICallingVideoRenderView.h"
#import "TUICallingAction.h"
#import "TUICallingCommon.h"

NS_ASSUME_NONNULL_BEGIN

@protocol BaseCallViewProtocol <NSObject, TUICallingVideoRenderViewDelegate>

@optional

- (void)updateViewWithUserList:(NSArray<CallingUserModel *> *)userList
                       sponsor:(CallingUserModel *)sponsor
                      callType:(TUICallMediaType)callType
                      callRole:(TUICallRole)callRole;

- (void)userAdd:(CallingUserModel *)userModel;

- (void)userEnter:(CallingUserModel *)userModel;

- (void)userLeave:(CallingUserModel *)userModel;

- (void)updateUserInfo:(CallingUserModel *)userModel;

- (void)updateCameraOpenStatus:(BOOL)isOpen;

- (void)updateRemoteView;

- (void)updateCallingSingleView;

@end

NS_ASSUME_NONNULL_END
