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
    
    [self setupConfig];
    [TUILogin initWithSdkAppID:sdkAppId];
}

- (void)setupConfig
{
    self.config.avatarType = TAvatarTypeRadiusCorner;
    self.config.avatarCornerRadius = 5;
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
