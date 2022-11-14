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
    pushInfo.ignoreIOSBadge = NO;
    pushInfo.iOSSound = @"phone_ringing.mp3";
    // OPPO必须设置ChannelID才可以收到推送消息，这个channelID需要和控制台一致
    // OPPO must set a ChannelID to receive push messages. This channelID needs to be the same as the console.
    pushInfo.AndroidOPPOChannelID = @"tuikit";
    return pushInfo;
}

@end
