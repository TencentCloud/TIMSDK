//
//  TUICallKitOfflinePushInfoConfig.m
//  TUICallKit
//
//  Created by noah on 2022/9/15.
//  Copyright © 2021 Tencent. All rights reserved.
//

#import "TUICallKitOfflinePushInfoConfig.h"
#import "TUICallEngineHeader.h"
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
    // VIVO message type: 0-push message, 1-System message(have a higher delivery rate)
    pushInfo.AndroidVIVOClassification = 1;
    // HuaWei message type: https://developer.huawei.com/consumer/cn/doc/development/HMSCore-Guides/message-classification-0000001149358835
    pushInfo.AndroidHuaWeiCategory = @"IM";
    return pushInfo;
}

@end
