//
//  TUICallingUserManager.h
//  TUICalling
//
//  Created by noah on 2022/4/28.
//  Copyright © 2022 Tencent. All rights reserved.
//

#import <Foundation/Foundation.h>

@class CallingUserModel;

NS_ASSUME_NONNULL_BEGIN

typedef void (^CallingUserModelCallback)(NSInteger code, NSString * _Nonnull message, CallingUserModel * _Nullable userInfo);

@interface TUICallingUserManager : NSObject

- (instancetype)init NS_UNAVAILABLE;
+ (instancetype)new NS_UNAVAILABLE;

+ (void)clearCache;

+ (void)destroyInstance;

+ (void)cacheUser:(CallingUserModel *)userInfo;

+ (nullable CallingUserModel *)getUser:(NSString *)userId;

+ (NSArray<CallingUserModel *> *)allUserList;

+ (NSArray<NSString *> *)allUserIdList;

+ (void)getUserInfo:(NSString *)userId callback:(CallingUserModelCallback)callback;

+ (void)removeUser:(NSString *)userId;

@end

NS_ASSUME_NONNULL_END
