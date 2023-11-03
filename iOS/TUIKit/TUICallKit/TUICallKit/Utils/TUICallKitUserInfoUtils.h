//
//  TUICallKitUserInfoUtils.h
//  TUICallKit
//
//  Created by noah on 2023/10/17.
//  Copyright © 2023 Tencent. All rights reserved
//

#import <Foundation/Foundation.h>

@class CallingUserModel;

NS_ASSUME_NONNULL_BEGIN

typedef void (^TUICallUserModelListSucc)(NSArray<CallingUserModel *> *modelList);
typedef void (^TUICallUserModelFail)(int code, NSString *_Nullable errMsg);

@interface TUICallKitUserInfoUtils : NSObject

/// Return the remark first.If remark is empty, return the nickname. If nickname is also empty, return the userId.
+ (void)getUserInfo:(NSArray<NSString *> *)userList succ:(TUICallUserModelListSucc)succ fail:(TUICallUserModelFail)fail;

@end

NS_ASSUME_NONNULL_END
