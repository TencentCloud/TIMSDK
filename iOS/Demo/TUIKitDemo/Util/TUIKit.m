#import "TUIKit.h"
#import "TUILogin.h"
#import "TUICore.h"

@implementation TUIKit
{
    UInt32    _sdkAppid;
    NSString  *_userID;
    NSString  *_userSig;
    NSString  *_nickName;
    NSString  *_faceUrl;
}

+ (instancetype)sharedInstance
{
    static TUIKit *instance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [[TUIKit alloc] init];
    });
    return instance;
}

- (instancetype)init
{
    self = [super init];
    if (self) {
        _config = [TUIConfig defaultConfig];
    }
    return self;
}

- (void)setupWithAppId:(UInt32)sdkAppId
{
    _sdkAppid = sdkAppId;
    [TUILogin initWithSdkAppID:sdkAppId];
}

- (void)login:(NSString *)userID userSig:(NSString *)sig succ:(TSucc)succ fail:(TFail)fail
{
    _userID = userID;
    _userSig = sig;
    
    int sdkAppId = self.sdkAppId;
    NSString *loginUserId = userID.copy;
    NSString *loginSig = sig.copy;
    [TUILogin login:_userID userSig:_userSig succ:^{
        Class liveClass = NSClassFromString(@"TUIKitLive");
        if (liveClass) {
            /// TUIKitLive obeject
            SEL shareSel = NSSelectorFromString(@"shareInstance");
            NSMethodSignature *shareMethod = [liveClass methodSignatureForSelector:shareSel];
            NSInvocation *shareInvocation = [NSInvocation invocationWithMethodSignature:shareMethod];
            shareInvocation.target = liveClass;
            shareInvocation.selector = shareSel;
            [shareInvocation invoke];
            __autoreleasing NSObject *tuikitObj = nil;
            [shareInvocation getReturnValue:&tuikitObj];
            if (tuikitObj && [NSStringFromClass(tuikitObj.class) isEqualToString:@"TUIKitLive"]) {
                /// 调用[[TUIKitLive shareInstance] setIsAttachedTUIKit:YES]
                SEL isAttachedSel = NSSelectorFromString(@"setIsAttachedTUIKit:");
                NSMethodSignature *isAttachedMehtod = [liveClass instanceMethodSignatureForSelector:isAttachedSel];
                NSInvocation *isAttachedInvocation = [NSInvocation invocationWithMethodSignature:isAttachedMehtod];
                isAttachedInvocation.target = tuikitObj;
                isAttachedInvocation.selector = isAttachedSel;
                BOOL isAttachedTUIKit = YES;
                [isAttachedInvocation setArgument:&isAttachedTUIKit atIndex:2];
                [isAttachedInvocation invoke];
                /// 登录TUIKitLive
                SEL loginSel = NSSelectorFromString(@"login:userID:userSig:callback:");
                NSMethodSignature *loginMethodSig = [liveClass instanceMethodSignatureForSelector:loginSel];
                NSInvocation *loginInvocation = [NSInvocation invocationWithMethodSignature:loginMethodSig];
                loginInvocation.target = tuikitObj;
                loginInvocation.selector = loginSel;
                [loginInvocation setArgument:&sdkAppId atIndex:2];
                [loginInvocation setArgument:(void *)&loginUserId atIndex:3];
                [loginInvocation setArgument:(void *)&loginSig atIndex:4];
                void(^loginCallBack)(int code, NSString * _Nullable message) = ^(int code, NSString * _Nullable message) {
                    NSLog(@"登录结果：%d，%@", code, message);
                };
                [loginInvocation setArgument:&(loginCallBack) atIndex:5];
                [loginInvocation invoke];
            }
        }
        succ();
    } fail:^(int code, NSString *msg) {
        fail(code,msg);
    }];
}

- (void)logout:(TSucc)succ fail:(TFail)fail {
    // 退出
    [[V2TIMManager sharedInstance] logout:^{
        
        Class liveClass = NSClassFromString(@"TUIKitLive");
        if (liveClass) {
            /// TUIKitLive obeject
            SEL shareSel = NSSelectorFromString(@"shareInstance");
            NSMethodSignature *shareMethod = [liveClass methodSignatureForSelector:shareSel];
            NSInvocation *shareInvocation = [NSInvocation invocationWithMethodSignature:shareMethod];
            shareInvocation.target = liveClass;
            shareInvocation.selector = shareSel;
            [shareInvocation invoke];
            __autoreleasing NSObject *tuikitObj = nil;
            [shareInvocation getReturnValue:&tuikitObj];
            if (tuikitObj && [NSStringFromClass(tuikitObj.class) isEqualToString:@"TUIKitLive"]) {
                /// 调用[[TUIKitLive shareInstance] logout:nil]

                SEL loginSel = NSSelectorFromString(@"logout:");
                NSMethodSignature *logoutMethodSig = [liveClass instanceMethodSignatureForSelector:loginSel];
                NSInvocation *logoutInvocation = [NSInvocation invocationWithMethodSignature:logoutMethodSig];
                logoutInvocation.target = tuikitObj;
                logoutInvocation.selector = loginSel;
                [logoutInvocation invoke];
            }
        }
        
        succ();
        
        NSLog(@"登出成功！");
    } fail:fail];
}

- (void)onReceiveGroupCallAPNs:(V2TIMSignalingInfo *)signalingInfo {
    NSDictionary *param = @{
        TUICore_TUICallingService_ShowCallingViewMethod_SignalingInfo : signalingInfo,
    };
    [TUICore callService:TUICore_TUICallingService
                  method:TUICore_TUICallingService_ReceivePushCallingMethod
                   param:param];
}

- (UInt32)sdkAppId {
    return _sdkAppid;
}

- (NSString *)userID {
    return _userID;
}

- (NSString *)userSig {
    return _userSig;
}

- (NSString *)faceUrl {
    return [TUILogin getFaceUrl];
}

- (NSString *)nickName {
    return [TUILogin getNickName];
}
@end
