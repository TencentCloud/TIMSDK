//
//  TLocalStorage.m
//  TXIMSDK_TUIKit_iOS
//
//  Created by annidyfeng on 2019/5/10.
//

#import "TUILocalStorage.h"

#import "THeader.h"

#define TOP_CONV_KEY @"TUIKIT_TOP_CONV_KEY"
#define Key_UserInfo_Appid @"Key_UserInfo_Appid"
#define Key_UserInfo_User  @"Key_UserInfo_User"
#define Key_UserInfo_Pwd   @"Key_UserInfo_Pwd"
#define Key_UserInfo_Sig   @"Key_UserInfo_Sig"

NSString *kTopConversationListChangedNotification = @"kTopConversationListChangedNotification";

@implementation TUILocalStorage

+ (instancetype)sharedInstance
{
    static TUILocalStorage *instance;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [TUILocalStorage new];
    });
    return instance;
}

- (NSArray *)topConversationList
{
#ifndef SDKPlaceTop
#define SDKPlaceTop
#endif
#ifdef SDKPlaceTop
    return @[];
#else
    NSArray *list = [[NSUserDefaults standardUserDefaults] objectForKey:TOP_CONV_KEY];
    if ([list isKindOfClass:[NSArray class]]) {
        return list;
    }
    return @[];
#endif
}

- (void)addTopConversation:(NSString *)conv callback:(void(^)(BOOL success, NSString *errorMessage))callback
{
#ifndef SDKPlaceTop
#define SDKPlaceTop
#endif
#ifdef SDKPlaceTop
    [V2TIMManager.sharedInstance pinConversation:conv isPinned:YES succ:^{
        if (callback) {
            callback(YES, nil);
        }
    } fail:^(int code, NSString *desc) {
        if (callback) {
            callback(NO, desc);
        }
    }];
#else
    NSMutableArray *list = [self topConversationList].mutableCopy;
    if ([list containsObject:conv]) {
        [list removeObject:conv];
    }
    [list insertObject:conv atIndex:0];
    [[NSUserDefaults standardUserDefaults] setValue:list forKey:TOP_CONV_KEY];
    [[NSNotificationCenter defaultCenter] postNotificationName:kTopConversationListChangedNotification object:nil];
    if (callback) {
        callback(YES, nil);
    }
#endif
}

- (void)removeTopConversation:(NSString *)conv callback:(void(^)(BOOL success, NSString *errorMessage))callback
{
#ifndef SDKPlaceTop
#define SDKPlaceTop
#endif
#ifdef SDKPlaceTop
    [V2TIMManager.sharedInstance pinConversation:conv isPinned:NO succ:^{
        if (callback) {
            callback(YES, nil);
        }
    } fail:^(int code, NSString *desc) {
        if (callback) {
            callback(NO, desc);
        }
    }];
#else
    NSMutableArray *list = [self topConversationList].mutableCopy;
    if ([list containsObject:conv]) {
        [list removeObject:conv];
        [[NSUserDefaults standardUserDefaults] setValue:list forKey:TOP_CONV_KEY];
        [[NSNotificationCenter defaultCenter] postNotificationName:kTopConversationListChangedNotification object:nil];
    }
    if (callback) {
        callback(YES, nil);
    }
#endif
}

- (void)saveLogin:(NSString *)user withAppId:(NSUInteger)appId withUserSig:(NSString *)sig
{
    [[NSUserDefaults standardUserDefaults] setObject:@(appId) forKey:Key_UserInfo_Appid];
    [[NSUserDefaults standardUserDefaults] setObject:user forKey:Key_UserInfo_User];
    [[NSUserDefaults standardUserDefaults] setObject:sig forKey:Key_UserInfo_Sig];
}

- (void)logout
{
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:Key_UserInfo_Sig];
}

- (void)login:(loginBlock)callback
{
    if (callback) {
        NSString *user = [[NSUserDefaults standardUserDefaults] objectForKey:Key_UserInfo_User];
        NSUInteger appId = [[[NSUserDefaults standardUserDefaults] objectForKey:Key_UserInfo_Appid] longLongValue];
        NSString *sig = [[NSUserDefaults standardUserDefaults] objectForKey:Key_UserInfo_Sig];

        callback(user,appId, sig);
    }
}
@end
