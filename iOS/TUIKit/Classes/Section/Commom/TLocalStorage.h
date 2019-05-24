//
//  TLocalStorage.h
//  TXIMSDK_TUIKit_iOS
//
//  Created by annidyfeng on 2019/5/10.
//

#import <Foundation/Foundation.h>

extern NSString *kTopConversationListChangedNotification;

NS_ASSUME_NONNULL_BEGIN

@interface TLocalStorage : NSObject

+ (instancetype)sharedInstance;

- (NSArray *)topConversationList;
- (void)addTopConversation:(NSString *)conv;
- (void)removeTopConversation:(NSString *)conv;

@end

NS_ASSUME_NONNULL_END
