//
//  TUIChatBotPluginDataProvider.h
//  TUIChatBotPlugin
//
//  Created by lynx on 2023/10/30.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface TUIChatBotPluginDataProvider : NSObject

+ (void)sendTextMessage:(NSString *)text;

+ (void)sendCustomMessage:(NSData *)data;
+ (void)sendCustomMessageWithoutUpdateUI:(NSData *)data;

@end

NS_ASSUME_NONNULL_END
