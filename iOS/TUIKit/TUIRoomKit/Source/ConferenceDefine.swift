//
//  ConferenceError.swift
//  TUIRoomKit
//
//  Created by janejntang on 2024/3/14.
//

import Foundation
import RTCRoomEngine

@objcMembers public class StartConferenceParams: NSObject {
    public var roomId = ""
    
    public var isOpenMicrophone = true
    public var isOpenCamera = false
    public var isOpenSpeaker = true
    
    public var isMicrophoneDisableForAllUser = false
    public var isCameraDisableForAllUser = false
    
    public var isSeatEnabled = false
    public var name: String?
    
    public init(roomId: String,
                isOpenMicrophone: Bool = true,
                isOpenCamera: Bool = false,
                isOpenSpeaker: Bool = true,
                isMicrophoneDisableForAllUser: Bool = false,
                isCameraDisableForAllUser: Bool = false,
                isSeatEnabled: Bool = false,
                name: String? = nil) {
        self.roomId = roomId
        self.isOpenMicrophone = isOpenMicrophone
        self.isOpenCamera = isOpenCamera
        self.isOpenSpeaker = isOpenSpeaker
        self.isMicrophoneDisableForAllUser = isMicrophoneDisableForAllUser
        self.isCameraDisableForAllUser = isCameraDisableForAllUser
        self.isSeatEnabled = isSeatEnabled
        self.name = name
        super.init()
    }
}

@objcMembers public class JoinConferenceParams: NSObject {
    public var roomId = ""
    
    public var isOpenMicrophone = true
    public var isOpenCamera = false
    public var isOpenSpeaker = true
    
    public var password: String?
    
    public init(roomId: String,
                isOpenMicrophone: Bool = true,
                isOpenCamera: Bool = false,
                isOpenSpeaker: Bool = true) {
        self.roomId = roomId
        self.isOpenMicrophone = isOpenMicrophone
        self.isOpenCamera = isOpenCamera
        self.isOpenSpeaker = isOpenSpeaker
        super.init()
    }
}

@objc public protocol ConferenceObserver {
    @objc optional func onConferenceStarted(roomInfo: TUIRoomInfo, error: TUIError, message: String)
    @objc optional func onConferenceJoined(roomInfo: TUIRoomInfo, error: TUIError, message: String)
    @objc optional func onConferenceFinished(roomId: String)
    @objc optional func onConferenceExited(roomId: String)
}
