//
//  TLocalStorage.m
//  TXIMSDK_TUIKit_iOS
//
//  Created by annidyfeng on 2019/5/10.
//

#import "TLocalStorage.h"
#define TOP_CONV_KEY @"TUIKIT_TOP_CONV_KEY"
NSString *kTopConversationListChangedNotification = @"kTopConversationListChangedNotification";

@implementation TLocalStorage

+ (instancetype)sharedInstance
{
    static TLocalStorage *instance;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [TLocalStorage new];
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

@end
