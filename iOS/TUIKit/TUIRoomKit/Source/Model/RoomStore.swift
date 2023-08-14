//
//  RoomStore.swift
//  TUIRoomKit
//
//  Created by aby on 2022/12/28.
//  Copyright © 2022 Tencent. All rights reserved.
//

import Foundation
import TUICore
import TUIRoomEngine

let roomHashNumber: Int = 0x3B9AC9FF

class RoomStore: NSObject {
    var currentUser: UserModel = UserModel()
    var roomInfo: RoomInfo = RoomInfo()
    var videoSetting: VideoModel = VideoModel()
    var audioSetting: AudioModel = AudioModel()
    var attendeeList: [UserModel] = []//用户列表
    var inviteSeatList: [UserModel] = []//申请上麦的用户列表（针对举手发言房间）
    var inviteSeatMap: [String:String] = [:]
    var isChatAccessRoom: Bool = false //是否是由TUIChat跳转进来的
    var isEnteredRoom: Bool = false //是否已经进入房间
    var timeStampOnEnterRoom: Int = 0 //进入会议的时间戳
    var isShowRoomMainViewAutomatically: Bool = true //true 调用createRoom或者enterRoom会自动进入主界面; false 需要调用 showRoomMainView 才能进入主界面。
    var isOpenMicrophone: Bool {
        didSet {
            UserDefaults.standard.set(isOpenMicrophone, forKey: "isOpenMicrophone")
            UserDefaults.standard.synchronize()
        }
    }
    var isOpenCamera: Bool {
        didSet {
            UserDefaults.standard.set(isOpenCamera, forKey: "isOpenCamera")
            UserDefaults.standard.synchronize()
        }
    }
    
    override init() {
        if let isOpenMicrophoneValue = UserDefaults.standard.object(forKey: "isOpenMicrophone") as? Bool {
            isOpenMicrophone = isOpenMicrophoneValue
        } else {
            isOpenMicrophone = true
        }
        if let isOpenCameraValue = UserDefaults.standard.object(forKey: "isOpenCamera") as? Bool {
            isOpenCamera = isOpenCameraValue
        } else {
            isOpenCamera = true
        }
    }
    
    func initialRoomCurrentUser() {
        EngineManager.createInstance().roomEngine.getUserInfo(currentUser.userId) { [weak self] userInfo in
            guard let self = self else { return }
            guard let userInfo = userInfo else { return }
            self.currentUser.update(userInfo: userInfo)
            if self.currentUser.userId == self.roomInfo.ownerId {
                self.currentUser.userRole = .roomOwner
            } else {
                self.currentUser.userRole = .generalUser
            }
        } onError: { code, message in
            debugPrint("getUserInfo,code:\(code),message:\(message)")
        }
    }
}

@objcMembers public class RoomInfo: NSObject {
    public var roomId: String {
        set {
            roomInfo.roomId = newValue
        }
        get {
            return roomInfo.roomId
        }
    }
    
    public var name: String {
        set {
            roomInfo.name = newValue
        }
        get {
            return roomInfo.name
        }
    }
    
    public var isOpenMicrophone: Bool = true
    public var isOpenCamera: Bool = true
    public var isUseSpeaker: Bool = true
    
    public var speechMode: TUISpeechMode {
        set {
            roomInfo.speechMode = newValue
        }
        get {
            return roomInfo.speechMode
        }
    }
    
    public var isCameraDisableForAllUser: Bool {
        set {
            roomInfo.isCameraDisableForAllUser = newValue
        }
        get {
            return roomInfo.isCameraDisableForAllUser
        }
    }
    
    public var isMicrophoneDisableForAllUser: Bool {
        set {
            roomInfo.isMicrophoneDisableForAllUser = newValue
        }
        get {
            return roomInfo.isMicrophoneDisableForAllUser
        }
    }
    
    public var isMessageDisableForAllUser: Bool {
        set {
            roomInfo.isMessageDisableForAllUser = newValue
        }
        get {
            return roomInfo.isMessageDisableForAllUser
        }
    }
    
    public var roomType: TUIRoomType {
        set {
            roomInfo.roomType = newValue
        }
        get {
            return roomInfo.roomType
        }
    }
    
    public var ownerId: String = ""
    
    private var roomInfo: TUIRoomInfo = TUIRoomInfo()
    
    public func update(engineRoomInfo: TUIRoomInfo) {
        roomInfo = engineRoomInfo
        switch engineRoomInfo.speechMode {
        case .freeToSpeak, .applyToSpeak, .applySpeakAfterTakingSeat:
            roomInfo.speechMode = engineRoomInfo.speechMode
        default:
            roomInfo.speechMode = .freeToSpeak
        }
        ownerId = engineRoomInfo.ownerId
    }
    
    public func getEngineRoomInfo() -> TUIRoomInfo {
        return roomInfo
    }
    
    deinit {
        debugPrint("deinit \(self)")
    }
}
