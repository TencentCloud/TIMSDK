//
//  TLocalStorage.m
//  TXIMSDK_TUIKit_iOS
//
//  Created by annidyfeng on 2019/5/10.
//

#import "TUILoginCache.h"

#define Key_UserInfo_Appid @"Key_UserInfo_Appid"
#define Key_UserInfo_User  @"Key_UserInfo_User"
#define Key_UserInfo_Pwd   @"Key_UserInfo_Pwd"
#define Key_UserInfo_Sig   @"Key_UserInfo_Sig"

@implementation TUILoginCache

+ (instancetype)sharedInstance
{
    static TUILoginCache *instance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [[TUILoginCache alloc] init];
    });
    return instance;
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
