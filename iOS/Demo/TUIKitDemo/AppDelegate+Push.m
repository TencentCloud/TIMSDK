//
//  AppDelegate+Push.m
//  TUIKitDemo
//
//  Created by harvy on 2021/12/22.
//  Copyright © 2021 Tencent. All rights reserved.
//

#import "AppDelegate+Push.h"

#import "ConversationController.h"
#import "TCUtil.h"
#import "Aspects.h"

@implementation AppDelegate (Push)

+ (void)load
{
    // 未读数相关的处理
    // 1. hook AppDelegate 进入前后台的事件，从而设置 APP 的角标
    // 2. hook AppDelegate 中监听的 onTotalUnreadMessageCountChanged: 事件，从而设置设置 APP 角标并更新 _unReadCount
    id appDidEnterBackGroundBlock = ^(id<AspectInfo> aspectInfo, UIApplication *application){
        AppDelegate *app = (AppDelegate *)application.delegate;
        application.applicationIconBadgeNumber = app.unReadCount;
        NSLog(@"[PUSH] applicationDidEnterBackground, unReadCount:%zd", app.unReadCount);
    };
    [AppDelegate aspect_hookSelector:@selector(applicationDidEnterBackground:)
                         withOptions:AspectPositionAfter
                          usingBlock:appDidEnterBackGroundBlock
                               error:nil];
    
    id appWillEnterForegroupBlock = ^(id<AspectInfo> aspectInfo, UIApplication *application){
        AppDelegate *app = (AppDelegate *)application.delegate;
        application.applicationIconBadgeNumber = app.unReadCount;
        NSLog(@"[PUSH] applicationWillEnterForeground, unReadCount:%zd", app.unReadCount);
    };
    [AppDelegate aspect_hookSelector:@selector(applicationWillEnterForeground:)
                         withOptions:AspectPositionAfter
                          usingBlock:appWillEnterForegroupBlock
                               error:nil];
    
    id onTotalUnreadMessageChangedBlock = ^(id<AspectInfo> aspectInfo, UInt64 totalUnreadCount){
        AppDelegate *app = (AppDelegate *)UIApplication.sharedApplication.delegate;
        [app onTotalUnreadCountChanged:totalUnreadCount];
        NSLog(@"[PUSH] onTotalUnreadMessageCountChanged, unReadCount:%zd", app.unReadCount);
    };
    [AppDelegate aspect_hookSelector:@selector(onTotalUnreadMessageCountChanged:)
                         withOptions:AspectPositionAfter
                          usingBlock:onTotalUnreadMessageChangedBlock
                               error:nil];
    
}

- (void)push_registerIfLogined:(NSString *)userID
{
    NSLog(@"[PUSH] %s, %@", __func__, userID);
    BOOL supportTPNS = NO;
    if ([self respondsToSelector:@selector(supportTPNS:)]) {
        supportTPNS = [self supportTPNS:userID];
    }
    
    if (self.deviceToken) {
        V2TIMAPNSConfig *confg = [[V2TIMAPNSConfig alloc] init];
        /* 用户自己到苹果注册开发者证书，在开发者帐号中下载并生成证书(p12 文件)，将生成的 p12 文件传到腾讯证书管理控制台，控制台会自动生成一个证书 ID，将证书 ID 传入一下 busiId 参数中。*/
        //企业证书 ID
        confg.businessID = sdkBusiId;
        confg.token = self.deviceToken;
        confg.isTPNSToken = supportTPNS;
        [[V2TIMManager sharedInstance] setAPNS:confg succ:^{
             NSLog(@"%s, succ, %@", __func__, supportTPNS ? @"TPNS": @"APNS");
        } fail:^(int code, NSString *msg) {
             NSLog(@"%s, fail, %d, %@", __func__, code, msg);
        }];
    }
    
    [self onReceiveNormalMessageOfflinePush];
    [self setupTotalUnreadCount];
}

- (void)onReceiveOfflinePushEntity:(NSDictionary *)entity
{
    NSLog(@"[PUSH] %s, %@", __func__, entity);
    if (entity == nil ||
        ![entity.allKeys containsObject:@"action"] ||
        ![entity.allKeys containsObject:@"chatType"]) {
        return;
    }
    // 业务，   action : 1 普通文本推送；2 音视频通话推送
    // 聊天类型，chatType : 1 单聊；2 群聊
    NSString *action = entity[@"action"];
    NSString *chatType = entity[@"chatType"];
    if (action == nil || chatType == nil) {
        return;
    }

    // action : 1 普通消息推送
    if ([action intValue] == APNs_Business_NormalMsg) {
        if ([chatType intValue] == 1) {   //C2C
            self.userID = entity[@"sender"];
        } else if ([chatType intValue] == 2) { //Group
            self.groupID = entity[@"sender"];
        }
        if ([[V2TIMManager sharedInstance] getLoginStatus] == V2TIM_STATUS_LOGINED) {
            [self onReceiveNormalMessageOfflinePush];
        }
    }
    // action : 2 音视频通话推送
    else if ([action intValue] == APNs_Business_Call) {
        // 如果是音视频通话，无需单独处理，TUIKit (TUICalling 内部会自动处理音视频通话)
    }
}

- (void)onReceiveNormalMessageOfflinePush
{
    NSLog(@"[PUSH] %s, groupId:%@, userId:%@", __func__, self.groupID, self.userID);
    // 异步处理，防止出现时序问题, 特别是当前正在登录操作中
    __weak typeof(self) weakSelf = self;
    dispatch_async(dispatch_get_main_queue(), ^{
        if (weakSelf.groupID.length > 0 || weakSelf.userID.length > 0) {
            UITabBarController *tab = [self getMainController];
            if (![tab isKindOfClass: UITabBarController.class]) {
                // 正在登录中
                return;
            }
            if (tab.selectedIndex != 0) {
                [tab setSelectedIndex:0];
            }
            weakSelf.window.rootViewController = tab;
            UINavigationController *nav = (UINavigationController *)tab.selectedViewController;
            if (![nav isKindOfClass:UINavigationController.class]) {
                return;
            }
            ConversationController *vc = (ConversationController *)nav.viewControllers.firstObject;
            if (![vc isKindOfClass:ConversationController.class]) {
                return;
            }
            [vc pushToChatViewController:weakSelf.groupID userID:weakSelf.userID];
            weakSelf.groupID = nil;
            weakSelf.userID = nil;
        }
    });
}

#pragma mark - 未读数相关
- (void)setupTotalUnreadCount
{
    NSLog(@"[PUSH] %s", __func__);
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
    NSLog(@"[PUSH] %s, %llu", __func__, totalUnreadCount);
    NSUInteger total = totalUnreadCount;
    TUITabBarController *tab = (TUITabBarController *)UIApplication.sharedApplication.keyWindow.rootViewController;
    if (![tab isKindOfClass:TUITabBarController.class]) {
        return;
    }
    TUITabBarItem *item = tab.tabBarItems.firstObject;
    item.badgeView.title = total ? [NSString stringWithFormat:@"%@", total > 99 ? @"99+" : @(total)] : nil;
    self.unReadCount = total;
}

- (void)push_clearUnreadMessage
{
    NSLog(@"[PUSH] %s", __func__);
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
    NSLog(@"[PUSH] %s, %zd", __func__, applicationCount);
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
