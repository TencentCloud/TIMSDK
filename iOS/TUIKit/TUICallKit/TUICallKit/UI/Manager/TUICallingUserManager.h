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

@interface TUICallingUserManager : NSObject

- (instancetype)init NS_UNAVAILABLE;
+ (instancetype)new NS_UNAVAILABLE;

+ (void)clearCache;

+ (void)destroyInstance;

+ (void)cacheUser:(CallingUserModel *)userInfo;

+ (nullable CallingUserModel *)getUser:(NSString *)userId;

+ (NSArray<CallingUserModel *> *)allUserList;

+ (NSArray<NSString *> *)allUserIdList;

+ (void)removeUser:(NSString *)userId;

+ (NSString *)getSelfUserId;

@end

NS_ASSUME_NONNULL_END
