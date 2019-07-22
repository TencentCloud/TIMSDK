#import "TUILocalStorage.h"
#define TOP_CONV_KEY @"TUIKIT_TOP_CONV_KEY"
#define Key_UserInfo_Appid @"Key_UserInfo_Appid"
#define Key_UserInfo_User  @"Key_UserInfo_User"
#define Key_UserInfo_Pwd   @"Key_UserInfo_Pwd"
#define Key_UserInfo_Sig   @"Key_UserInfo_Sig"
#define Key_Pendency_Read_Time @"Key_Pendency_Read_Time"

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

- (NSInteger)pendencyReadTimestamp
{
    NSNumber *time = [[NSUserDefaults standardUserDefaults] objectForKey:Key_Pendency_Read_Time];
    if ([time isKindOfClass:[NSNumber class]])
        return [time integerValue];
    return 0;
}

- (void)setPendencyReadTimestamp:(NSInteger)pendencyReadTimestamp
{
    [[NSUserDefaults standardUserDefaults] setValue:@(pendencyReadTimestamp) forKey:Key_Pendency_Read_Time];
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

- (void)saveLogin:(NSString *)user withPwd:(NSString *)pwd withAppId:(NSUInteger)appId withUserSig:(NSString *)sig
{
    [[NSUserDefaults standardUserDefaults] setObject:@(appId) forKey:Key_UserInfo_Appid];
    [[NSUserDefaults standardUserDefaults] setObject:user forKey:Key_UserInfo_User];
    [[NSUserDefaults standardUserDefaults] setObject:pwd
                                              forKey:Key_UserInfo_Pwd];
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
        NSString *pwd = [[NSUserDefaults standardUserDefaults] objectForKey:Key_UserInfo_Pwd];
        NSString *sig = [[NSUserDefaults standardUserDefaults] objectForKey:Key_UserInfo_Sig];
        
        callback(user, pwd, appId, sig);
    }
}
@end
