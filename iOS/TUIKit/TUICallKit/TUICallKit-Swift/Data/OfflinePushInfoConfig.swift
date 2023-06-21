//
//  OfflinePushInfoConfig.swift
//  TUICallKit
//
//  Created by vincepzhang on 2023/1/6.
//

import Foundation
import TUICallEngine

class OfflinePushInfoConfig {
    
    static func createOfflinePushInfo() -> TUIOfflinePushInfo {
        let pushInfo: TUIOfflinePushInfo = TUIOfflinePushInfo()
        pushInfo.title = ""
        pushInfo.desc = TUICallKitLocalize(key: "TUICallKit.have.new.invitation") ?? ""
        // iOS push type: if you want user VoIP, please modify type to TUICallIOSOfflinePushTypeVoIP
        pushInfo.iOSPushType = .apns
        pushInfo.ignoreIOSBadge = false
        pushInfo.iOSSound = "phone_ringing.mp3"
        pushInfo.androidSound = "phone_ringing"
        // OPPO必须设置ChannelID才可以收到推送消息，这个channelID需要和控制台一致
        // OPPO must set a ChannelID to receive push messages. This channelID needs to be the same as the console.
        pushInfo.androidOPPOChannelID = "tuikit"
        // FCM channel ID, you need change PrivateConstants.java and set "fcmPushChannelId"
        pushInfo.androidFCMChannelID = "fcm_push_channel"
        // VIVO message type: 0-push message, 1-System message(have a higher delivery rate)
        pushInfo.androidVIVOClassification = 1
        // HuaWei message type: https://developer.huawei.com/consumer/cn/doc/development/HMSCore-Guides/message-classification-0000001149358835
        pushInfo.androidHuaWeiCategory = "IM"
        return pushInfo
    }
}
