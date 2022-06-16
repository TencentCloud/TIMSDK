//
//  AppDelegate+Redpoint.m
//  TUIKitDemo
//
//  Created by harvy on 2022/5/5.
//  Copyright © 2022 Tencent. All rights reserved.
//

#import "AppDelegate+Redpoint.h"
#import "Aspects.h"

@implementation AppDelegate (Redpoint)

+ (void)load
{
    // 未读数相关的处理
    // 1. hook AppDelegate 进入前后台的事件，从而设置 APP 的角标
    // 2. hook AppDelegate 中监听的 onTotalUnreadMessageCountChanged: 事件，从而设置设置 APP 角标并更新 _unReadCount
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
        [app onTotalUnreadCountChanged:totalUnreadCount];
        NSLog(@"[Redpoint] onTotalUnreadMessageCountChanged, unReadCount:%zd", app.unReadCount);
    };
    [AppDelegate aspect_hookSelector:@selector(onTotalUnreadMessageCountChanged:)
                         withOptions:AspectPositionAfter
                          usingBlock:onTotalUnreadMessageChangedBlock
                               error:nil];
    
}

#pragma mark - 未读数相关
- (void)redpoint_setupTotalUnreadCount
{
    NSLog(@"[Redpoint] %s", __func__);
    // 查询总的消息未读数
    __weak typeof(self) weakSelf = self;
    [V2TIMManager.sharedInstance getTotalUnreadMessageCount:^(UInt64 totalCount) {
        [weakSelf onTotalUnreadCountChanged:totalCount];
    } fail:^(int code, NSString *desc) {
        
    }];
    
    // 查询当前的好友申请
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
    [V2TIMManager.sharedInstance markAllMessageAsRead:^{
        @strongify(self)
        [TUITool makeToast:NSLocalizedString(@"MarkAllMessageAsReadSucc", nil)];
        [self onTotalUnreadCountChanged:0];
    } fail:^(int code, NSString *desc) {
        @strongify(self)
        [TUITool makeToast:[NSString stringWithFormat:NSLocalizedString(@"MarkAllMessageAsReadErrFormat", nil), code, desc]];
        [self onTotalUnreadCountChanged:self.unReadCount];
    }];
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
    NSLog(@"---> %zd", applicationCount);
    TUITabBarItem *item = tab.tabBarItems[1];
    item.badgeView.title = applicationCount == 0 ? @"" : [NSString stringWithFormat:@"%zd", applicationCount];
}

@end
