
//  Created by Tencent on 2023/06/09.
//  Copyright © 2023 Tencent. All rights reserved.

#import "TUILogin.h"
#import "TUICore.h"
#import "TUIDefine.h"

@import ImSDK_Plus;

NSString *const TUILoginSuccessNotification = @"TUILoginSuccessNotification";
NSString *const TUILoginFailNotification = @"TUILoginFailNotification";
NSString *const TUILogoutSuccessNotification = @"TUILogoutSuccessNotification";
NSString *const TUILogoutFailNotification = @"TUILogoutFailNotification";

@implementation TUILoginConfig

- (instancetype)init {
    if (self = [super init]) {
        self.logLevel = TUI_LOG_INFO;
    }
    return self;
}

@end

@interface TUILogin () <V2TIMSDKListener>

@property(nonatomic, strong) NSHashTable *loginListenerSet;

@property(nonatomic, assign) int sdkAppID;
@property(nonatomic, copy) NSString *userID;
@property(nonatomic, copy) NSString *userSig;
@property(nonatomic, copy) NSString *nickName;
@property(nonatomic, copy) NSString *faceUrl;
@property(nonatomic, assign) BOOL loginWithInit;
@property(nonatomic, assign) TUIBusinessScene currentBusinessScene;

@end

@implementation TUILogin

#pragma mark - API
+ (void)initWithSdkAppID:(int)sdkAppID {
    [TUILogin.shareInstance initWithSdkAppID:sdkAppID];
}

+ (void)login:(NSString *)userID userSig:(NSString *)userSig succ:(TSucc)succ fail:(TFail)fail {
    [TUILogin.shareInstance login:userID userSig:userSig succ:succ fail:fail];
}

+ (void)login:(int)sdkAppID userID:(NSString *)userID userSig:(NSString *)userSig succ:(TSucc)succ fail:(TFail)fail {
    [TUILogin.shareInstance login:sdkAppID userID:userID userSig:userSig config:nil succ:succ fail:fail];
}

+ (void)login:(int)sdkAppID userID:(NSString *)userID userSig:(NSString *)userSig config:(TUILoginConfig *)config succ:(TSucc)succ fail:(TFail)fail {
    [TUILogin.shareInstance login:sdkAppID userID:userID userSig:userSig config:config succ:succ fail:fail];
}

+ (void)getSelfUserInfo {
    [TUILogin.shareInstance getSelfUserInfo];
}

+ (void)logout:(TSucc)succ fail:(TFail)fail {
    [TUILogin.shareInstance logout:succ fail:fail];
}

+ (void)addLoginListener:(id<TUILoginListener>)listener {
    [TUILogin.shareInstance addLoginListener:listener];
}

+ (void)removeLoginListener:(id<TUILoginListener>)listener {
    [TUILogin.shareInstance removeLoginListener:listener];
}

+ (int)getSdkAppID {
    return [TUILogin.shareInstance getSdkAppID];
}

+ (BOOL)isUserLogined {
    return [V2TIMManager sharedInstance].getLoginStatus == V2TIM_STATUS_LOGINED;
}

+ (NSString *)getUserID {
    return [TUILogin.shareInstance getUserID];
}

+ (NSString *)getUserSig {
    return [TUILogin.shareInstance getUserSig];
}

+ (NSString *)getNickName {
    return [TUILogin.shareInstance getNickName];
}

+ (NSString *)getFaceUrl {
    return [TUILogin.shareInstance getFaceUrl];
}

+ (void)setCurrentBusinessScene:(TUIBusinessScene)scene {
    TUILogin.shareInstance.currentBusinessScene = scene;
}

+ (TUIBusinessScene)getCurrentBusinessScene {
    return TUILogin.shareInstance.currentBusinessScene;
}

#pragma mark - Private

+ (instancetype)shareInstance {
    static id gShareInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
      gShareInstance = [[self alloc] init];
    });
    return gShareInstance;
}

- (instancetype)init {
    if (self = [super init]) {
        _loginListenerSet = [NSHashTable weakObjectsHashTable];
        _sdkAppID = 0;
        _userID = nil;
        _userSig = nil;
        _nickName = nil;
        _faceUrl = nil;
        _loginWithInit = NO;
        _currentBusinessScene = None;
    }
    return self;
}

- (void)initWithSdkAppID:(int)sdkAppID {
    if (0 != self.sdkAppID && sdkAppID != self.sdkAppID) {
        [self logout:nil fail:nil];
        [[V2TIMManager sharedInstance] unInitSDK];
    }
    self.sdkAppID = sdkAppID;
    V2TIMSDKConfig *config = [[V2TIMSDKConfig alloc] init];
    config.logLevel = V2TIM_LOG_INFO;
    [[V2TIMManager sharedInstance] initSDK:sdkAppID config:config listener:nil];
}

- (void)login:(NSString *)userID userSig:(NSString *)userSig succ:(TSucc)succ fail:(TFail)fail {
    self.userID = userID;
    self.userSig = userSig;
    self.loginWithInit = NO;
    self.currentBusinessScene = None;
    if ([[[V2TIMManager sharedInstance] getLoginUser] isEqualToString:userID]) {
        if (succ) {
            succ();
        }
        [NSNotificationCenter.defaultCenter postNotificationName:TUILoginSuccessNotification object:nil];
    } else {
        __weak __typeof(self) weakSelf = self;
        [[V2TIMManager sharedInstance] login:userID
            userSig:userSig
            succ:^{
              __strong __typeof(weakSelf) strongSelf = weakSelf;
              [strongSelf getSelfUserInfo];
              if (succ) {
                  succ();
              }
              [NSNotificationCenter.defaultCenter postNotificationName:TUILoginSuccessNotification object:nil];
            }
            fail:^(int code, NSString *desc) {
              if (fail) {
                  fail(code, desc);
              }
              [NSNotificationCenter.defaultCenter postNotificationName:TUILoginFailNotification object:nil];
            }];
    }
}

- (void)login:(int)sdkAppID userID:(NSString *)userID userSig:(NSString *)userSig config:(TUILoginConfig *)config succ:(TSucc)succ fail:(TFail)fail {
    self.loginWithInit = YES;
    self.currentBusinessScene = None;
    if (0 != self.sdkAppID && sdkAppID != self.sdkAppID) {
        [self logout:nil fail:nil];
        [[V2TIMManager sharedInstance] unInitSDK];
    }
    self.sdkAppID = sdkAppID;
    V2TIMSDKConfig *sdkConfig = [[V2TIMSDKConfig alloc] init];
    if (config != nil) {
        sdkConfig.logLevel = (V2TIMLogLevel)config.logLevel;
        sdkConfig.logListener = ^(V2TIMLogLevel logLevel, NSString *logContent) {
          if (config.onLog) {
              config.onLog(logLevel, logContent);
          }
        };
    } else {
        sdkConfig.logLevel = V2TIM_LOG_INFO;
    }

    [[V2TIMManager sharedInstance] initSDK:sdkAppID config:sdkConfig];

    [V2TIMManager.sharedInstance addIMSDKListener:self];

    self.userID = userID;
    self.userSig = userSig;
    if ([[[V2TIMManager sharedInstance] getLoginUser] isEqualToString:userID]) {
        if (succ) {
            succ();
        }
        [NSNotificationCenter.defaultCenter postNotificationName:TUILoginSuccessNotification object:nil];
        return;
    }
    __weak __typeof(self) weakSelf = self;
    [[V2TIMManager sharedInstance] login:userID
        userSig:userSig
        succ:^{
          __strong __typeof(weakSelf) strongSelf = weakSelf;
          [strongSelf getSelfUserInfo];
          if (succ) {
              succ();
          }
          [NSNotificationCenter.defaultCenter postNotificationName:TUILoginSuccessNotification object:nil];
        }
        fail:^(int code, NSString *desc) {
          self.loginWithInit = NO;
          if (fail) {
              fail(code, desc);
          }
          [NSNotificationCenter.defaultCenter postNotificationName:TUILoginFailNotification object:nil];
        }];
}

- (void)getSelfUserInfo {
    if (self.userID == nil) {
        return;
    }
    __weak typeof(self) weakSelf = self;
    [[V2TIMManager sharedInstance] getUsersInfo:@[ self.userID ]
                                           succ:^(NSArray<V2TIMUserFullInfo *> *infoList) {
                                             V2TIMUserFullInfo *info = infoList.firstObject;
                                             weakSelf.nickName = info.nickName;
                                             weakSelf.faceUrl = info.faceURL;
                                           }
                                           fail:nil];
}

- (void)logout:(TSucc)succ fail:(TFail)fail {
    self.userID = @"";
    self.userSig = @"";
    self.currentBusinessScene = None;
    [[V2TIMManager sharedInstance]
        logout:^{
          if (succ) {
              succ();
          }
          if (self.loginWithInit) {
              // 使用的是新接口登录，退出时需要反初始化，并移除监听
              // The new interface is currently used to log in. When logging out, you need to deinitialize and remove the listener.
              [V2TIMManager.sharedInstance removeIMSDKListener:self];
              [V2TIMManager.sharedInstance unInitSDK];
              self.sdkAppID = 0;
          }
          [NSNotificationCenter.defaultCenter postNotificationName:TUILogoutSuccessNotification object:nil];
        }
        fail:^(int code, NSString *desc) {
          if (fail) {
              fail(code, desc);
          }
          [NSNotificationCenter.defaultCenter postNotificationName:TUILogoutFailNotification object:nil];
        }];
}

- (void)addLoginListener:(id<TUILoginListener>)listener {
    if (listener == nil) {
        return;
    }

    @synchronized(self) {
        if (![_loginListenerSet.allObjects containsObject:listener]) {
            [_loginListenerSet addObject:listener];
        }
    }
}

- (void)removeLoginListener:(id<TUILoginListener>)listener {
    if (listener == nil) {
        return;
    }

    @synchronized(self) {
        if ([_loginListenerSet.allObjects containsObject:listener]) {
            [_loginListenerSet removeObject:listener];
        }
    }
}

- (int)getSdkAppID {
    return self.sdkAppID;
}

- (NSString *)getUserID {
    return self.userID;
}

- (NSString *)getUserSig {
    return self.userSig;
}

- (NSString *)getNickName {
    return self.nickName;
}

- (NSString *)getFaceUrl {
    return self.faceUrl;
}

- (void)doInMainThread:(dispatch_block_t)callback {
    if ([NSThread isMainThread]) {
        if (callback) {
            callback();
        }
        return;
    }
    dispatch_async(dispatch_get_main_queue(), callback);
}

#pragma mark - V2TIMSDKListener
- (void)onConnecting {
    __weak typeof(self) weakSelf = self;
    [self doInMainThread:^{
      for (id<TUILoginListener> listener in weakSelf.loginListenerSet) {
          if ([listener respondsToSelector:@selector(onConnecting)]) {
              [listener onConnecting];
          }
      }
      [TUICore notifyEvent:TUICore_NetworkConnection_EVENT_CONNECTION_STATE_CHANGED
                    subKey:TUICore_NetworkConnection_EVENT_SUB_KEY_CONNECTING
                    object:nil
                     param:nil];
    }];
}

- (void)onConnectSuccess {
    __weak typeof(self) weakSelf = self;
    [self doInMainThread:^{
      for (id<TUILoginListener> listener in weakSelf.loginListenerSet) {
          if ([listener respondsToSelector:@selector(onConnectSuccess)]) {
              [listener onConnectSuccess];
          }
      }
      [TUICore notifyEvent:TUICore_NetworkConnection_EVENT_CONNECTION_STATE_CHANGED
                    subKey:TUICore_NetworkConnection_EVENT_SUB_KEY_CONNECT_SUCCESS
                    object:nil
                     param:nil];
    }];
}

- (void)onConnectFailed:(int)code err:(NSString *)err {
    __weak typeof(self) weakSelf = self;
    [self doInMainThread:^{
      for (id<TUILoginListener> listener in weakSelf.loginListenerSet) {
          if ([listener respondsToSelector:@selector(onConnectFailed:err:)]) {
              [listener onConnectFailed:code err:err];
          }
      }
      [TUICore notifyEvent:TUICore_NetworkConnection_EVENT_CONNECTION_STATE_CHANGED
                    subKey:TUICore_NetworkConnection_EVENT_SUB_KEY_CONNECT_FAILED
                    object:nil
                     param:nil];
    }];
}

- (void)onKickedOffline {
    self.currentBusinessScene = None;
    __weak typeof(self) weakSelf = self;
    [self doInMainThread:^{
      for (id<TUILoginListener> listener in weakSelf.loginListenerSet) {
          if ([listener respondsToSelector:@selector(onKickedOffline)]) {
              [listener onKickedOffline];
          }
      }
    }];
}

- (void)onUserSigExpired {
    self.currentBusinessScene = None;

    __weak typeof(self) weakSelf = self;
    [self doInMainThread:^{
      for (id<TUILoginListener> listener in weakSelf.loginListenerSet) {
          if ([listener respondsToSelector:@selector(onUserSigExpired)]) {
              [listener onUserSigExpired];
          }
      }
    }];
}

- (void)onSelfInfoUpdated:(V2TIMUserFullInfo *)info {
    if (self.userID && self.userID.length > 0 && [self.userID isEqualToString:info.userID]) {
        self.nickName = info.nickName;
        self.faceUrl = info.faceURL;
    }
}

@end
