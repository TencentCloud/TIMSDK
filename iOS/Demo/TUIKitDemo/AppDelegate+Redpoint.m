//
//  AppDelegate+Redpoint.m
//  TUIKitDemo
//
//  Created by harvy on 2022/5/5.
//  Copyright © 2022 Tencent. All rights reserved.
//

#import "AppDelegate+Redpoint.h"
#import "Aspects.h"
#import <objc/runtime.h>
#import "TUIDefine.h"

NSInteger _markUnreadCount = 0 ;
NSInteger _markHideUnreadCount = 0;

@interface AppDelegate (Redpoint)
@property (nonatomic, strong) NSMutableDictionary * markUnreadMap;
@end

@implementation AppDelegate (Redpoint)

+ (void)load
{
    /**
     * The Processing of unread count
     * - 1. Hooking the callback of entering foregroud and background in AppDelegate to set the application's badge number.
     * - 2. Hooking the event of onTotalUnreadMessageCountChanged: in AppDelegate to set the application's badge number and update the _unReadCount parameter.
     */
    id appDidEnterBackGroundBlock = ^(id<AspectInfo> aspectInfo, UIApplication *application){
        AppDelegate *app = (AppDelegate *)application.delegate;
        application.applicationIconBadgeNumber = app.unReadCount;
        NSLog(@"[Redpoint] applicationDidEnterBackground, unReadCount:%zd", app.unReadCount);
    };
    [AppDelegate aspect_hookSelector:@selector(applicationDidEnterBackground:)
                         withOptions:AspectPositionAfter
                          usingBlock:appDidEnterBackGroundBlock
                               error:nil];
    
    id appWillEnterForegroupBlock = ^(id<AspectInfo> aspectInfo, UIApplication *application){
        AppDelegate *app = (AppDelegate *)application.delegate;
        application.applicationIconBadgeNumber = app.unReadCount;
        NSLog(@"[Redpoint] applicationWillEnterForeground, unReadCount:%zd", app.unReadCount);
    };
    [AppDelegate aspect_hookSelector:@selector(applicationWillEnterForeground:)
                         withOptions:AspectPositionAfter
                          usingBlock:appWillEnterForegroupBlock
                               error:nil];
    
    id onTotalUnreadMessageChangedBlock = ^(id<AspectInfo> aspectInfo, UInt64 totalUnreadCount){
        AppDelegate *app = (AppDelegate *)UIApplication.sharedApplication.delegate;
        NSInteger unreadCalculationResults = [self.class caculateRealResultAboutSDKTotalCount:totalUnreadCount markUnreadCount:_markUnreadCount markHideUnreadCount:_markHideUnreadCount];
        [app onTotalUnreadCountChanged:unreadCalculationResults];
        NSLog(@"[Redpoint] onTotalUnreadMessageCountChanged, unReadCount:%zd", app.unReadCount);
    };
    [AppDelegate aspect_hookSelector:@selector(onTotalUnreadMessageCountChanged:)
                         withOptions:AspectPositionAfter
                          usingBlock:onTotalUnreadMessageChangedBlock
                               error:nil];
    
    //Listen for unread clearing notifications
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(redpoint_clearUnreadMessage) name:@"redpoint_clearUnreadMessage" object:nil];
    
}

- (void)redpoint_setupTotalUnreadCount
{
    NSLog(@"[Redpoint] %s", __func__);
    // Getting total unread count
    __weak typeof(self) weakSelf = self;
    [V2TIMManager.sharedInstance getTotalUnreadMessageCount:^(UInt64 totalCount) {
        [weakSelf onTotalUnreadCountChanged:totalCount];
    } fail:^(int code, NSString *desc) {
        
    }];
    
    // Getting the count of friends application
    @weakify(self)
    [RACObserve(self.contactDataProvider, pendencyCnt) subscribeNext:^(NSNumber *x) {
        @strongify(self)
        [self onFriendApplicationCountChanged:[x integerValue]];
    }];
    [self.contactDataProvider loadFriendApplication];
}

- (void)onTotalUnreadCountChanged:(UInt64)totalUnreadCount
{
    NSLog(@"[Redpoint] %s, %llu", __func__, totalUnreadCount);
    
    NSUInteger total = totalUnreadCount;
    
    TUITabBarController *tab = (TUITabBarController *)UIApplication.sharedApplication.keyWindow.rootViewController;
    if (![tab isKindOfClass:TUITabBarController.class]) {
        return;
    }
    TUITabBarItem *item = tab.tabBarItems.firstObject;
    item.badgeView.title = total ? [NSString stringWithFormat:@"%@", total > 99 ? @"99+" : @(total)] : nil;
    self.unReadCount = total;
}

- (void)redpoint_clearUnreadMessage
{
    NSLog(@"[Redpoint] %s", __func__);
    @weakify(self)
    [V2TIMManager.sharedInstance cleanConversationUnreadMessageCount:@"" cleanTimestamp:0 cleanSequence:0 succ:^{
        @strongify(self)
        [TUITool makeToast:NSLocalizedString(@"MarkAllMessageAsReadSucc", nil)];
        [self onTotalUnreadCountChanged:0];
    } fail:^(int code, NSString *desc) {
        @strongify(self)
        [TUITool makeToast:[NSString stringWithFormat:NSLocalizedString(@"MarkAllMessageAsReadErrFormat", nil), code, desc]];
        [self onTotalUnreadCountChanged:self.unReadCount];

    }];
        
    NSArray *conversations = [self.markUnreadMap allKeys];
    if (conversations.count) {
        [V2TIMManager.sharedInstance markConversation:conversations markType:@(V2TIM_CONVERSATION_MARK_TYPE_UNREAD) enableMark:NO succ:nil fail:nil];
    }
    
}

- (void)onFriendApplicationCountChanged:(NSInteger)applicationCount
{
    NSLog(@"[Redpoint] %s, %zd", __func__, applicationCount);
    TUITabBarController *tab = (TUITabBarController *)UIApplication.sharedApplication.keyWindow.rootViewController;
    if (![tab isKindOfClass:TUITabBarController.class]) {
        return;
    }
    if (tab.tabBarItems.count < 2) {
        return;
    }
    TUITabBarItem *contactItem = nil;
    for (TUITabBarItem *item in tab.tabBarItems) {
        if ([item.identity isEqualToString:@"contactItem"]) {
            contactItem = item;
            break;
        }
    }
    contactItem.badgeView.title = applicationCount == 0 ? @"" : [NSString stringWithFormat:@"%zd", applicationCount];
}


- (void)setMarkUnreadMap:(NSMutableDictionary *)markUnreadMap {
    objc_setAssociatedObject(self, @selector(markUnreadMap), markUnreadMap, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (NSMutableDictionary *)markUnreadMap {
    return objc_getAssociatedObject(self, _cmd);
}
#pragma mark - NSNotification
- (void)updateMarkUnreadCount:(NSNotification *) note {
    
    NSDictionary *userInfo = note.userInfo;
    NSInteger markUnreadCount = [[userInfo objectForKey:TUIKitNotification_onConversationMarkUnreadCountChanged_MarkUnreadCount] integerValue];
    NSInteger markHideUnreadCount = [[userInfo objectForKey:TUIKitNotification_onConversationMarkUnreadCountChanged_MarkHideUnreadCount] integerValue];
    _markUnreadCount = markUnreadCount;
    _markHideUnreadCount = markHideUnreadCount;
    if ([userInfo objectForKey:TUIKitNotification_onConversationMarkUnreadCountChanged_MarkUnreadMap]) {
        self.markUnreadMap = [NSMutableDictionary dictionaryWithDictionary:[userInfo objectForKey:TUIKitNotification_onConversationMarkUnreadCountChanged_MarkUnreadMap]];
    }
    @weakify(self)
    [V2TIMManager.sharedInstance getTotalUnreadMessageCount:^(UInt64 totalCount) {
        @strongify(self)
        NSInteger unreadCalculationResults = [self.class caculateRealResultAboutSDKTotalCount:totalCount markUnreadCount:markUnreadCount markHideUnreadCount:markHideUnreadCount];
        [self onTotalUnreadCountChanged:unreadCalculationResults];
    } fail:^(int code, NSString *desc) {
    }];
}

+ (NSInteger)caculateRealResultAboutSDKTotalCount:(UInt64) totalCount
                                  markUnreadCount:(NSInteger)markUnreadCount
                              markHideUnreadCount:(NSInteger)markHideUnreadCount {
    NSInteger unreadCalculationResults = totalCount + markUnreadCount - markHideUnreadCount;
    if (unreadCalculationResults < 0) {
        //error protect
        unreadCalculationResults = 0;
    }
    return unreadCalculationResults;
}

- (uint32_t)onSetAPPUnreadCount
{
    return (uint32_t)self.unReadCount; // test
}

@end
