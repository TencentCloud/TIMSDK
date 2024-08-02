//
//  ConferenceParams.swift
//  TUIRoomKit
//
//  Created by janejntang on 2024/3/14.
//

import Foundation

@objcMembers public class ConferenceParams : NSObject {
    public var isMuteMicrophone = false
    public var isOpenCamera = false
    public var isSoundOnSpeaker = true
    
    public var name: String?
    public var enableMicrophoneForAllUser = true
    public var enableCameraForAllUser = true
    public var enableMessageForAllUser = true
    public var enableSeatControl = false
    
    deinit {
        debugPrint("deinit \(self)")
    }
}
