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

@implementation AppDelegate (Push)

-(void)application:(UIApplication *)app didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken
{
    self.deviceToken = deviceToken;
}

- (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo fetchCompletionHandler:(void (^)(UIBackgroundFetchResult result))completionHandler
{
    // 收到推送普通信息推送（普通消息推送设置代码请参考 TUIMessageController -> sendMessage）
    //普通消息推送格式（C2C）：
    //@"ext" :
    //@"{\"entity\":{\"action\":1,\"chatType\":1,\"content\":\"Hhh\",\"sendTime\":0,\"sender\":\"2019\",\"version\":1}}"
    //普通消息推送格式（Group）：
    //@"ext"
    //@"{\"entity\":{\"action\":1,\"chatType\":2,\"content\":\"Hhh\",\"sendTime\":0,\"sender\":\"@TGS#1PWYXLTGA\",\"version\":1}}"
    
    // 收到推送音视频推送（音视频推送设置代码请参考 TUICall+Signal -> sendAPNsForCall）
    //音视频通话推送格式（C2C）：
    //@"ext" :
    //@"{\"entity\":{\"action\":2,\"chatType\":1,\"content\":\"{\\\"action\\\":1,\\\"call_id\\\":\\\"144115224193193423-1595225880-515228569\\\",\\\"call_type\\\":1,\\\"code\\\":0,\\\"duration\\\":0,\\\"invited_list\\\":[\\\"10457\\\"],\\\"room_id\\\":1688911421,\\\"timeout\\\":30,\\\"timestamp\\\":0,\\\"version\\\":4}\",\"sendTime\":1595225881,\"sender\":\"2019\",\"version\":1}}"
    //音视频通话推送格式（Group）：
    //@"ext"
    //@"{\"entity\":{\"action\":2,\"chatType\":2,\"content\":\"{\\\"action\\\":1,\\\"call_id\\\":\\\"144115212826565047-1595506130-2098177837\\\",\\\"call_type\\\":2,\\\"code\\\":0,\\\"duration\\\":0,\\\"group_id\\\":\\\"@TGS#1BUBQNTGS\\\",\\\"invited_list\\\":[\\\"10457\\\"],\\\"room_id\\\":1658793276,\\\"timeout\\\":30,\\\"timestamp\\\":0,\\\"version\\\":4}\",\"sendTime\":1595506130,\"sender\":\"vinson1\",\"version\":1}}"
    NSLog(@"didReceiveRemoteNotification, %@", userInfo);
    NSDictionary *extParam = [TCUtil jsonSring2Dictionary:userInfo[@"ext"]];
    NSDictionary *entity = extParam[@"entity"];
    if (!entity) {
        return;
    }
    // 业务，action : 1 普通文本推送；2 音视频通话推送
    NSString *action = entity[@"action"];
    if (!action) {
        return;
    }
    // 聊天类型，chatType : 1 单聊；2 群聊
    NSString *chatType = entity[@"chatType"];
    if (!chatType) {
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
            [self onReceiveNomalMsgAPNs];
        }
    }
    // action : 2 音视频通话推送
    else if ([action intValue] == APNs_Business_Call) {
        // 单聊中的音视频邀请推送不需处理，APP 启动后，TUIkit 会自动处理
        if ([chatType intValue] == 1) {   //C2C
            return;
        }
        // 内容
        NSDictionary *content = [TCUtil jsonSring2Dictionary:entity[@"content"]];
        if (!content) {
            return;
        }
        UInt64 sendTime = [entity[@"sendTime"] integerValue];
        uint32_t timeout = [content[@"timeout"] intValue];
        UInt64 curTime = [[V2TIMManager sharedInstance] getServerTime];
        if (curTime - sendTime > timeout) {
            [TUITool makeToast:@"通话接收超时"];
            return;
        }
        self.signalingInfo = [[V2TIMSignalingInfo alloc] init];
        self.signalingInfo.actionType = (SignalingActionType)[content[@"action"] intValue];
        self.signalingInfo.inviteID = content[@"call_id"];
        self.signalingInfo.inviter = entity[@"sender"];
        self.signalingInfo.inviteeList = content[@"invited_list"];
        self.signalingInfo.groupID = content[@"group_id"];
        self.signalingInfo.timeout = timeout;
//        self.signalingInfo.data = [TCUtil dictionary2JsonStr:@{SIGNALING_EXTRA_KEY_ROOM_ID : content[@"room_id"], SIGNALING_EXTRA_KEY_VERSION : content[@"version"], SIGNALING_EXTRA_KEY_CALL_TYPE : content[@"call_type"]}];
        if ([[V2TIMManager sharedInstance] getLoginStatus] == V2TIM_STATUS_LOGINED) {
            [self onReceiveGroupCallAPNs];
        }
    }
}

- (void)push_onLoginSucc
{
    if (self.deviceToken) {
        V2TIMAPNSConfig *confg = [[V2TIMAPNSConfig alloc] init];
        /* 用户自己到苹果注册开发者证书，在开发者帐号中下载并生成证书(p12 文件)，将生成的 p12 文件传到腾讯证书管理控制台，控制台会自动生成一个证书 ID，将证书 ID 传入一下 busiId 参数中。*/
        //企业证书 ID
        confg.businessID = sdkBusiId;
        confg.token = self.deviceToken;
        [[V2TIMManager sharedInstance] setAPNS:confg succ:^{
             NSLog(@"-----> 设置 APNS 成功");
        } fail:^(int code, NSString *msg) {
             NSLog(@"-----> 设置 APNS 失败, code:%d msg:%@",code, msg);
        }];
    }
    
    [self onReceiveNomalMsgAPNs];
    [self onReceiveGroupCallAPNs];
    [self setupTotalUnreadCount];
}

- (void)push_applicationDidEnterBackground:(UIApplication *)application
{
    UIApplication.sharedApplication.applicationIconBadgeNumber = self.unReadCount;
}

- (void)push_applicationWillEnterForeground:(UIApplication *)application
{
    UIApplication.sharedApplication.applicationIconBadgeNumber = self.unReadCount;
}

- (void)push_registNotification
{
    if ([[TUITool deviceVersion] floatValue] >= 8.0)
    {
        [[UIApplication sharedApplication] registerUserNotificationSettings:[UIUserNotificationSettings settingsForTypes:(UIUserNotificationTypeSound | UIUserNotificationTypeAlert | UIUserNotificationTypeBadge) categories:nil]];
        [[UIApplication sharedApplication] registerForRemoteNotifications];
    }
    else
    {
        [[UIApplication sharedApplication] registerForRemoteNotificationTypes: (UIUserNotificationTypeBadge | UIUserNotificationTypeSound | UIUserNotificationTypeAlert)];
    }
}

- (void)onReceiveNomalMsgAPNs
{
    NSLog(@"---> receive normal msg apns, groupId:%@, userId:%@", self.groupID, self.userID);
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

- (void)onReceiveGroupCallAPNs
{
    NSLog(@"---> receive group call apns, signalingInfo:%@", self.signalingInfo);
    if (self.signalingInfo) {
        [[TUIKit sharedInstance] onReceiveGroupCallAPNs:self.signalingInfo];
        self.signalingInfo = nil;
    }
}

#pragma mark - 未读数相关
- (void)setupTotalUnreadCount
{
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
    NSUInteger total = totalUnreadCount;
    TUITabBarController *tab = (TUITabBarController *)UIApplication.sharedApplication.keyWindow.rootViewController;
    if (![tab isKindOfClass:TUITabBarController.class]) {
        return;
    }
    TUITabBarItem *item = tab.tabBarItems.firstObject;
    item.badgeView.title = total ? [NSString stringWithFormat:@"%@", total > 99 ? @"99+" : @(total)] : nil;
    self.unReadCount = total;
}

- (void)clearUnreadMessage
{
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
