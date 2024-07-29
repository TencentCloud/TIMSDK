//
//  NotificationService.m
//  pushservice
//
//  Created by harvy on 2020/10/21.
//  Copyright © 2020 Tencent. All rights reserved.
//

#import "NotificationService.h"
#import "TCConstants.h"
#if __has_include(<TIMPush/TIMPushManager.h>)
    #import <TIMPush/TIMPushManager.h>
#elif __has_include(<TPush/TIMPushManager.h>)
    #import <TPush/TIMPushManager.h>
#endif
@interface NotificationService ()

@property (nonatomic, strong) void (^contentHandler)(UNNotificationContent *contentToDeliver);
@property (nonatomic, strong) UNMutableNotificationContent *bestAttemptContent;

@end

@implementation NotificationService

- (void)didReceiveNotificationRequest:(UNNotificationRequest *)request withContentHandler:(void (^)(UNNotificationContent * _Nonnull))contentHandler {
    self.contentHandler = contentHandler;

    //appGroup 标识当前主 APP 和 Extension 之间共享的 APP Group，需要在主 APP 的 Capability 中配置 App Groups 能力。
    //格式为group + [主bundleID]+ key
    //如group.com.tencent.im.pushkey
    NSString * appGroupID = kTIMPushAppGorupKey;
    
    __weak typeof(self) weakSelf = self;
    [TIMPushManager onReceiveNotificationRequest:request inAppGroupID:appGroupID callback:^(UNNotificationContent *content) {
        weakSelf.bestAttemptContent = [content mutableCopy];
        // Modify the notification content here...
        // self.bestAttemptContent.title = [NSString stringWithFormat:@"%@ [modified]", self.bestAttemptContent.title];
        weakSelf.contentHandler(weakSelf.bestAttemptContent);
    }];
}

- (void)serviceExtensionTimeWillExpire {
    // Called just before the extension will be terminated by the system.
    // Use this as an opportunity to deliver your "best attempt" at modified content, otherwise the original push payload will be used.
    self.contentHandler(self.bestAttemptContent);
}

@end
