//
//  TUICustomerServicePluginPrivateConfig.m
//  TUICustomerServicePlugin
//
//  Created by xia on 2023/7/5.
//

#import "TUICustomerServicePluginPrivateConfig.h"
#import <TUIChat/TUIChatConfig.h>

static const long long kTUICustomerServiceCommercialAbility = 1LL << 40;
static BOOL gEnableCustomerService = NO;
static NSString *gDefaultCustomerServiceAccount = @"@default_customer_service_account";

@implementation TUICustomerServicePluginPrivateConfig

+ (TUICustomerServicePluginPrivateConfig *)sharedInstance {
    static dispatch_once_t onceToken;
    static TUICustomerServicePluginPrivateConfig * g_sharedInstance = nil;
    dispatch_once(&onceToken, ^{
        g_sharedInstance = [[TUICustomerServicePluginPrivateConfig alloc] init];
        g_sharedInstance.customerServiceAccounts = @[gDefaultCustomerServiceAccount];
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
    return [userID tui_containsString:@"#online_shopping_mall"];
}

+ (BOOL)isCustomerServiceSupported {
    return gEnableCustomerService;
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

@end
