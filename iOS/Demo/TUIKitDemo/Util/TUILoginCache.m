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

#define Key_UserInfo_Phone @"Key_UserInfo_Phone"
#define Key_UserInfo_Token @"Key_UserInfo_Token"

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
- (void)saveExt:(NSDictionary *)dic {
    if ([dic isKindOfClass:[NSDictionary class]]) {
        NSString *phone = dic[@"phone"] ?dic[@"phone"]:@"";
        NSString *token = dic[@"token"] ?dic[@"token"]:@"";

        if (phone.length>0) {
            [[NSUserDefaults standardUserDefaults] setObject:phone forKey:Key_UserInfo_Phone];
        }
        if (token.length>0) {
            [[NSUserDefaults standardUserDefaults] setObject:token forKey:Key_UserInfo_Token];
        }
        [[NSUserDefaults standardUserDefaults] synchronize];
        
    }
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
