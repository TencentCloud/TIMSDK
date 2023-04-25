//
//  TUICallKitOfflinePushInfoConfig.m
//  TUICallKit
//
//  Created by noah on 2022/9/15.
//  Copyright © 2021 Tencent. All rights reserved.
//

#import "TUICallKitOfflinePushInfoConfig.h"
#import "TUICallDefine.h"
#import "TUILogin.h"
#import "CallingLocalized.h"

@implementation TUICallKitOfflinePushInfoConfig

+ (TUIOfflinePushInfo *)createOfflinePushInfo {
    TUIOfflinePushInfo *pushInfo = [TUIOfflinePushInfo new];
    pushInfo.title = @"";
    pushInfo.desc = TUICallingLocalize(@"TUICallKit.have.new.invitation");
    // iOS push type: if you want user VoIP, please modify type to TUICallIOSOfflinePushTypeVoIP
    pushInfo.iOSPushType = TUICallIOSOfflinePushTypeAPNs;
    pushInfo.ignoreIOSBadge = NO;
    pushInfo.iOSSound = @"phone_ringing.mp3";
    pushInfo.AndroidSound = @"phone_ringing";
    // OPPO必须设置ChannelID才可以收到推送消息，这个channelID需要和控制台一致
    // OPPO must set a ChannelID to receive push messages. This channelID needs to be the same as the console.
    pushInfo.AndroidOPPOChannelID = @"tuikit";
    // FCM channel ID, you need change PrivateConstants.java and set "fcmPushChannelId"
    pushInfo.AndroidFCMChannelID = @"fcm_push_channel";
    // VIVO message type: 0-push message, 1-System message(have a higher delivery rate)
    pushInfo.AndroidVIVOClassification = 1;
    // HuaWei message type: https://developer.huawei.com/consumer/cn/doc/development/HMSCore-Guides/message-classification-0000001149358835
    pushInfo.AndroidHuaWeiCategory = @"IM";
    return pushInfo;
}

@end
