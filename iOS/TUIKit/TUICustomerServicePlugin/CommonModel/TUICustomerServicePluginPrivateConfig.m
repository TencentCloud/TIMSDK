//
//  TUICustomerServicePluginPrivateConfig.m
//  TUICustomerServicePlugin
//
//  Created by xia on 2023/7/5.
//

#import "TUICustomerServicePluginPrivateConfig.h"
#import <TUIChat/TUIChatConfig.h>

static BOOL gEnableVideo;
static BOOL gEnableAudio;
static BOOL gEnableWelcome;
static const long long kTUICustomerServiceCommercialAbility = 1LL << 40;
static BOOL gEnableCustomerService = NO;
static NSString *gOnlineShopping = @"@im_agent#online_shopping_mall";
static NSString *gOnlineDoctor = @"@im_agent#online_doctor";

@implementation TUICustomerServicePluginPrivateConfig

+ (TUICustomerServicePluginPrivateConfig *)sharedInstance {
    static dispatch_once_t onceToken;
    static TUICustomerServicePluginPrivateConfig * g_sharedInstance = nil;
    dispatch_once(&onceToken, ^{
        g_sharedInstance = [[TUICustomerServicePluginPrivateConfig alloc] init];
        [self checkCommercialAbility];
    });
    return g_sharedInstance;
}

#pragma mark - Public
- (BOOL)isCustomerServiceAccount:(NSString *)userID {
    if (userID.length == 0) {
        return NO;
    }
    return [self.customerServiceAccounts containsObject:userID];
}

- (BOOL)isOnlineShopping:(NSString *)userID {
    return [userID isEqualToString:gOnlineShopping];
}

+ (BOOL)isCustomerServiceSupported {
    return gEnableCustomerService;
}

+ (void)enableVideoAndAudioCall:(BOOL)enable {
    [TUIChatConfig defaultConfig].enableVideoCall = enable;
    [TUIChatConfig defaultConfig].enableAudioCall = enable;
    [TUIChatConfig defaultConfig].enableWelcomeCustomMessage = enable;
}

+ (void)cacheVideoAndAudioCall {
    gEnableVideo = [TUIChatConfig defaultConfig].enableVideoCall;
    gEnableAudio = [TUIChatConfig defaultConfig].enableAudioCall;
    gEnableWelcome = [TUIChatConfig defaultConfig].enableWelcomeCustomMessage;
}

+ (void)restoreVideoAndAudioCall {
    [TUIChatConfig defaultConfig].enableVideoCall = gEnableVideo;
    [TUIChatConfig defaultConfig].enableAudioCall = gEnableAudio;
    [TUIChatConfig defaultConfig].enableWelcomeCustomMessage = gEnableWelcome;
}

#pragma mark - Private
+ (void)checkCommercialAbility {
    [TUITool checkCommercialAbility:kTUICustomerServiceCommercialAbility
                               succ:^(BOOL enabled) {
        gEnableCustomerService = enabled;
    }
                               fail:^(int code, NSString *desc) {
        gEnableCustomerService = NO;
    }];
}

#pragma mark - Getter
// Developer can modify these userIDs by their account configs on console.
- (NSArray *)customerServiceAccounts {
    return @[gOnlineShopping, gOnlineDoctor]; // default
}

@end
