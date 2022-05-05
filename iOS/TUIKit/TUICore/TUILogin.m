
#import "TUILogin.h"
#import "TUICore.h"

@import ImSDK_Plus;

@interface TUILogin () <V2TIMSDKListener>

@property (nonatomic, strong) NSHashTable *loginListenerSet;

@property (nonatomic, assign) int sdkAppID;
@property (nonatomic, copy) NSString *userID;
@property (nonatomic, copy) NSString *userSig;
@property (nonatomic, copy) NSString *nickName;
@property (nonatomic, copy) NSString *faceUrl;
@property (nonatomic, assign) BOOL loginWithInit;

@end

@implementation TUILogin

#pragma mark - 对外 API
+ (void)initWithSdkAppID:(int)sdkAppID {
    [TUILogin.shareInstance initWithSdkAppID:sdkAppID];
}

+ (void)login:(NSString *)userID userSig:(NSString *)userSig succ:(TSucc)succ fail:(TFail)fail {
    [TUILogin.shareInstance login:userID userSig:userSig succ:succ fail:fail];
}

+ (void)login:(int)sdkAppID userID:(NSString *)userID userSig:(NSString *)userSig succ:(TSucc)succ fail:(TFail)fail {
    [TUILogin.shareInstance login:sdkAppID userID:userID userSig:userSig succ:succ fail:fail];
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


#pragma mark - 内部方法

+ (instancetype)shareInstance {
    static id _instance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _instance = [[self alloc] init];
    });
    return _instance;
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
    }
    return self;
}

- (void)initWithSdkAppID:(int)sdkAppID {
    // sdkappid 如果发生了变化要先 unInitSDK，否则 initSDK 会失败
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
    if ([[[V2TIMManager sharedInstance] getLoginUser] isEqualToString:userID]) {
        succ();
    } else {
        __weak __typeof(self) weakSelf = self;
        [[V2TIMManager sharedInstance] login:userID userSig:userSig succ:^{
            __strong __typeof(weakSelf) strongSelf = weakSelf;
            [strongSelf getSelfUserInfo];
            if (succ) {
                succ();
            }
        } fail:^(int code, NSString *desc) {
            if (fail) {
                fail(code, desc);
            }
        }];
    }
}

- (void)login:(int)sdkAppID
       userID:(NSString *)userID
      userSig:(NSString *)userSig
         succ:(TSucc)succ
         fail:(TFail)fail {
    // 1. 初始化 SDK
    self.loginWithInit = YES;
    // sdkappid 如果发生了变化要先 unInitSDK，否则 initSDK 会失败
    if (0 != self.sdkAppID && sdkAppID != self.sdkAppID) {
        [self logout:nil fail:nil];
        [[V2TIMManager sharedInstance] unInitSDK];
    }
    self.sdkAppID = sdkAppID;
    V2TIMSDKConfig *config = [[V2TIMSDKConfig alloc] init];
    config.logLevel = V2TIM_LOG_INFO;
    [[V2TIMManager sharedInstance] initSDK:sdkAppID config:config];
    
    // 2. 添加监听
    [V2TIMManager.sharedInstance addIMSDKListener:self];
    
    // 3. 登录
    self.userID = userID;
    self.userSig = userSig;
    if ([[[V2TIMManager sharedInstance] getLoginUser] isEqualToString:userID]) {
        if (succ) {
            succ();
        }
        return;
    }
    __weak __typeof(self) weakSelf = self;
    [[V2TIMManager sharedInstance] login:userID userSig:userSig succ:^{
        __strong __typeof(weakSelf) strongSelf = weakSelf;
        [strongSelf getSelfUserInfo];
        if (succ) {
            succ();
        }
    } fail:^(int code, NSString *desc) {
        self.loginWithInit = NO;
        if (fail) {
            fail(code, desc);
        }
    }];
}

- (void)getSelfUserInfo {
    if (self.userID == nil) {
        return;
    }
    __weak typeof(self) weakSelf = self;
    [[V2TIMManager sharedInstance] getUsersInfo:@[self.userID] succ:^(NSArray<V2TIMUserFullInfo *> *infoList) {
        V2TIMUserFullInfo *info = infoList.firstObject;
        weakSelf.nickName = info.nickName;
        weakSelf.faceUrl = info.faceURL;
    } fail:nil];
}

- (void)logout:(TSucc)succ fail:(TFail)fail {
    self.userID = @"";
    self.userSig = @"";
    [[V2TIMManager sharedInstance] logout:^{
        if (succ) {
            succ();
        }
        if (self.loginWithInit) {
            // 使用的是新接口登录，退出时需要反初始化，并移除监听
            [V2TIMManager.sharedInstance removeIMSDKListener:self];
            [V2TIMManager.sharedInstance unInitSDK];
            self.sdkAppID = 0;
        }
    } fail:^(int code, NSString *desc) {
        if (fail) {
            fail(code, desc);
        }
    }];
}

- (void)addLoginListener:(id<TUILoginListener>)listener {
    if (listener == nil) {
        return;
    }
    
    @synchronized (self) {
        if (![_loginListenerSet.allObjects containsObject:listener]) {
            [_loginListenerSet addObject:listener];
        }
    }
}

- (void)removeLoginListener:(id<TUILoginListener>)listener {
    if (listener == nil) {
        return;
    }
    
    @synchronized (self) {
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

- (void)doInMainThread:(dispatch_block_t)callback
{
    if ([NSThread isMainThread]) {
        if (callback) {
            callback();
        }
        return;
    }
    dispatch_async(dispatch_get_main_queue(), callback);
}

#pragma mark - V2TIMSDKListener
/// The SDK is connecting to the CVM instance
- (void)onConnecting {
    __weak typeof(self) weakSelf = self;
    [self doInMainThread:^{
        for (id<TUILoginListener> listener in weakSelf.loginListenerSet) {
            if ([listener respondsToSelector:@selector(onConnecting)]) {
                [listener onConnecting];
            }
        }
    }];
}

/// The SDK is successfully connected to the CVM instance
- (void)onConnectSuccess {
    __weak typeof(self) weakSelf = self;
    [self doInMainThread:^{
        for (id<TUILoginListener> listener in weakSelf.loginListenerSet) {
            if ([listener respondsToSelector:@selector(onConnectSuccess)]) {
                [listener onConnectSuccess];
            }
        }
    }];
}

/// The SDK failed to connect to the CVM instance
- (void)onConnectFailed:(int)code err:(NSString*)err {
    __weak typeof(self) weakSelf = self;
    [self doInMainThread:^{
        for (id<TUILoginListener> listener in weakSelf.loginListenerSet) {
            if ([listener respondsToSelector:@selector(onConnectFailed:err:)]) {
                [listener onConnectFailed:code err:err];
            }
        }
    }];
}

/// The current user is kicked offline: the SDK notifies the user on the UI, and the user can choose to call the login() function of V2TIMManager to log in again.
- (void)onKickedOffline {
    __weak typeof(self) weakSelf = self;
    [self doInMainThread:^{
        for (id<TUILoginListener> listener in weakSelf.loginListenerSet) {
            if ([listener respondsToSelector:@selector(onKickedOffline)]) {
                [listener onKickedOffline];
            }
        }
    }];
}

/// The ticket expires when the user is online: the user needs to generate a new userSig and call the login() function of V2TIMManager to log in again.
- (void)onUserSigExpired {
    __weak typeof(self) weakSelf = self;
    [self doInMainThread:^{
        for (id<TUILoginListener> listener in weakSelf.loginListenerSet) {
            if ([listener respondsToSelector:@selector(onUserSigExpired)]) {
                [listener onUserSigExpired];
            }
        }
    }];
}

/// The profile of the current user was updated
- (void)onSelfInfoUpdated:(V2TIMUserFullInfo *)Info {
    // 暂时不暴露
}

@end
