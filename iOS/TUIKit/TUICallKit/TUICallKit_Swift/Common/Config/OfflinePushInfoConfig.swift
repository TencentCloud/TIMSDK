//
//  OfflinePushInfoConfig.swift
//  TUICallKit
//
//  Created by vincepzhang on 2023/1/6.
//

import Foundation
import RTCRoomEngine

@objc
public class OfflinePushInfoConfig: NSObject {
    @objc
    public static func createOfflinePushInfo() -> TUIOfflinePushInfo {
        let pushInfo: TUIOfflinePushInfo = TUIOfflinePushInfo()
        pushInfo.title = ""
        pushInfo.desc = TUICallKitLocalize(key: "TUICallKit.have.new.invitation") ?? ""
        // iOS push type: if you want user VoIP, please modify type to TUICallIOSOfflinePushTypeVoIP
        pushInfo.iOSPushType = .apns
        pushInfo.ignoreIOSBadge = false
        pushInfo.iOSSound = "phone_ringing.mp3"
        pushInfo.androidSound = "phone_ringing"
        // VIVO message type: 0-push message, 1-System message(have a higher delivery rate)
        pushInfo.androidVIVOClassification = 1
        // HuaWei message type: https://developer.huawei.com/consumer/cn/doc/development/HMSCore-Guides/message-classification-0000001149358835
        pushInfo.androidHuaWeiCategory = "IM"
        return pushInfo
    }
}
