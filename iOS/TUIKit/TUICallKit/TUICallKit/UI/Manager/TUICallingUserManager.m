//
//  TUICallingUserManager.m
//  TUICalling
//
//  Created by noah on 2022/4/28.
//  Copyright © 2022 Tencent. All rights reserved.
//

#import "TUICallingUserManager.h"
#import "TUICallKitHeader.h"
#import "TUICallingUserModel.h"
#import <TUICore/TUILogin.h>

@interface TUICallingUserManager ()

@property (nonatomic, strong, nullable) dispatch_queue_t queue;
@property (nonatomic, strong) NSMutableDictionary<NSString *, CallingUserModel *> *userCacheMap;

@end

@implementation TUICallingUserManager

static TUICallingUserManager *gInstance = nil;
static dispatch_once_t gOnceToken;

+ (instancetype)shareInstance {
    dispatch_once(&gOnceToken, ^{
        gInstance = [[TUICallingUserManager alloc] init];
    });
    return gInstance;
}

- (instancetype)init {
    self = [super init];
    if (self) {
        _queue = dispatch_queue_create("TRTCCallingUserManage", DISPATCH_QUEUE_SERIAL);
        _userCacheMap = [[NSMutableDictionary alloc] init];
    }
    return self;
}

#pragma mark Public function

+ (void)clearCache {
    [[TUICallingUserManager shareInstance] deleteCache];
}

+ (void)destroyInstance {
    gInstance = nil;
    gOnceToken = 0;
}

+ (void)cacheUser:(CallingUserModel *)userInfo {
    [[TUICallingUserManager shareInstance] saveUser:userInfo];
}

+ (nullable CallingUserModel *)getUser:(NSString *)userId {
    if (userId) {
        return [[TUICallingUserManager shareInstance] getUser:userId];
    } else {
        return nil;
    }
}

+ (NSArray<CallingUserModel *> *)allUserList {
    return [[TUICallingUserManager shareInstance] getUserList];
}

+ (NSArray<NSString *> *)allUserIdList {
    return [[TUICallingUserManager shareInstance] getUserIdList];
}

+ (void)removeUser:(NSString *)userId {
    if (userId) {
        [[TUICallingUserManager shareInstance] deleteUser:userId];
    }
}

+ (NSString *)getSelfUserId {
    return [TUILogin getUserID];
}

#pragma mark private function

- (void)saveUser:(CallingUserModel *)userInfo {
    if (userInfo && userInfo.userId) {
        __weak typeof(self) wealSelf = self;
        [self syncRun:^{
            __strong typeof(self) strongSelf = wealSelf;
            [strongSelf.userCacheMap setValue:userInfo forKey:userInfo.userId];
        }];
    }
}

- (NSArray<CallingUserModel *> *)getUserList {
    __weak typeof(self) wealSelf = self;
    __block NSArray<CallingUserModel *> *memberList = @[];
    [self syncRun:^{
        __strong typeof(self) strongSelf = wealSelf;
        memberList = [strongSelf.userCacheMap allValues];
    }];
    return memberList;
}

- (NSArray<NSString *> *)getUserIdList {
    __weak typeof(self) wealSelf = self;
    __block NSArray<NSString *> *memberIdList = @[];
    [self syncRun:^{
        __strong typeof(self) strongSelf = wealSelf;
        memberIdList = [strongSelf.userCacheMap allKeys];
    }];
    return memberIdList;
}

- (CallingUserModel *)getUser:(NSString *)userId {
    __weak typeof(self) wealSelf = self;
    __block CallingUserModel *user = nil;
    [self syncRun:^{
        __strong typeof(self) strongSelf = wealSelf;
        user = [strongSelf.userCacheMap objectForKey:userId];
    }];
    return user;
}

- (void)deleteUser:(NSString *)userId {
    if (userId) {
        __weak typeof(self) wealSelf = self;
        [self syncRun:^{
            __strong typeof(self) strongSelf = wealSelf;
            [strongSelf.userCacheMap removeObjectForKey:userId];
        }];
    }
}

- (void)deleteCache {
    __weak typeof(self) wealSelf = self;
    [self syncRun:^{
        __strong typeof(self) strongSelf = wealSelf;
        if (strongSelf) {
            strongSelf->_userCacheMap = [[NSMutableDictionary alloc] init];
        }
    }];
}

- (void)syncRun:(os_block_t)block {
    if (_queue) {
        dispatch_sync(_queue, ^{
            if (block) {
                block();
            }
        });
    }
}

- (void)dealloc {
    NSLog(@"dealloc %@", NSStringFromClass([self class]));
}

@end
