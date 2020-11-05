//
//  TUILiveUserProfile.h
//  TXIMSDK_TUIKit_live_iOS
//
//  Created by coddyliu on 2020/9/23.
//

#import <Foundation/Foundation.h>
#import <ImSDK/V2TIMManager.h>

NS_ASSUME_NONNULL_BEGIN

typedef void(^TUILiveRequestCallback)(int code, NSString * _Nullable message);
@interface TUILiveUserProfile : NSObject

/// 刷新当前登录用户的用户信息，如改名，改头像后调用
+ (void)refreshLoginUserInfo:(TUILiveRequestCallback _Nullable)callback;

/// 获取当前登录用户信息，如果在登录成功前调用，返回nil
+ (V2TIMUserFullInfo * _Nullable)getLoginUserInfo;

/// 退出登录时调用，清理UserInfo
+ (void)onLogout;

@end

NS_ASSUME_NONNULL_END
