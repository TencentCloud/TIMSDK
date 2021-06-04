//
//  TLocalStorage.h
//  TXIMSDK_TUIKit_iOS
//
//  Created by annidyfeng on 2019/5/10.
//

#import <Foundation/Foundation.h>

extern NSString *kTopConversationListChangedNotification;

NS_ASSUME_NONNULL_BEGIN

typedef void (^loginBlock) (NSString *user, NSUInteger appId, NSString *userSig);

@interface TUILocalStorage : NSObject

+ (instancetype)sharedInstance;

- (NSArray *)topConversationList;
- (void)addTopConversation:(NSString *)conv callback:(void(^ __nullable)(BOOL success, NSString * __nullable errorMessage))callback;
- (void)removeTopConversation:(NSString *)conv callback:(void(^ __nullable)(BOOL success, NSString * __nullable errorMessage))callback;

- (void)logout;
- (void)login:(loginBlock)callback;
- (void)saveLogin:(NSString *)user
        withAppId:(NSUInteger)appId
      withUserSig:(NSString *)sig;
@end

NS_ASSUME_NONNULL_END
