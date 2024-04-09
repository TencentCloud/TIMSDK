//
//  TUICustomerServicePluginPrivateConfig.h
//  TUICustomerServicePlugin
//
//  Created by xia on 2023/7/5.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface TUICustomerServicePluginPrivateConfig : NSObject

+ (TUICustomerServicePluginPrivateConfig *)sharedInstance;

@property (nonatomic, assign) BOOL canEvaluate;
@property (nonatomic, copy) NSArray *customerServiceAccounts;

- (BOOL)isCustomerServiceAccount:(NSString *)userID;
- (BOOL)isOnlineShopping:(NSString *)userID;

+ (BOOL)isCustomerServiceSupported;
+ (void)checkCommercialAbility;

@end

NS_ASSUME_NONNULL_END
