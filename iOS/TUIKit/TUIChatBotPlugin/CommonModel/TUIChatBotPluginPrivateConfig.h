//
//  TUIChatBotPluginPrivateConfig.h
//  TUIChatBotPlugin
//
//  Created by lynx on 2023/10/30.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface TUIChatBotPluginPrivateConfig : NSObject

+ (TUIChatBotPluginPrivateConfig *)sharedInstance;

@property (nonatomic, copy, readonly) NSArray *chatBotAccounts;

- (BOOL)isChatBotAccount:(NSString *)userID;

+ (BOOL)isChatBotSupported;
+ (void)checkCommercialAbility;

@end

NS_ASSUME_NONNULL_END
