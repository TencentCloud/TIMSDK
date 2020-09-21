//
//  TLocalStorage.m
//  TXIMSDK_TUIKit_iOS
//
//  Created by annidyfeng on 2019/5/10.
//

#import "TUILocalStorage.h"
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
    NSArray *list = [[NSUserDefaults standardUserDefaults] objectForKey:TOP_CONV_KEY];
    if ([list isKindOfClass:[NSArray class]]) {
        return list;
    }
    return @[];
}

- (void)addTopConversation:(NSString *)conv
{
    NSMutableArray *list = [self topConversationList].mutableCopy;
    if ([list containsObject:conv]) {
        [list removeObject:conv];
    }
    [list insertObject:conv atIndex:0];
    [[NSUserDefaults standardUserDefaults] setValue:list forKey:TOP_CONV_KEY];
    [[NSNotificationCenter defaultCenter] postNotificationName:kTopConversationListChangedNotification object:nil];
}

- (void)removeTopConversation:(NSString *)conv
{
    NSMutableArray *list = [self topConversationList].mutableCopy;
    if ([list containsObject:conv]) {
        [list removeObject:conv];
        [[NSUserDefaults standardUserDefaults] setValue:list forKey:TOP_CONV_KEY];
        [[NSNotificationCenter defaultCenter] postNotificationName:kTopConversationListChangedNotification object:nil];
    }
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
