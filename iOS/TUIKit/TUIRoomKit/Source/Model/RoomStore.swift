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

class RoomStore: NSObject {
    var currentLoginUser: UserModel = UserModel()
    var currentUser: UserModel = UserModel()
    private(set) var roomInfo: RoomInfo = RoomInfo()
    var videoSetting: VideoModel = VideoModel()
    var audioSetting: AudioModel = AudioModel()
    var roomScene: RoomScene = .meeting
    var attendeeList: [UserModel] = []//用户列表
    var inviteSeatList: [UserModel] = []//申请上麦的用户列表（针对举手发言房间）
    var inviteSeatMap: [String:String] = [:]
    var isSomeoneSharing: Bool = false
    var roomSpeechMode: TUISpeechMode
    var isBanAutoRaise: Bool = false //是否禁止跳转页面
    var isChatAccessRoom: Bool = false //是否是由TUIChat跳转进来的
    var engineManager: EngineManager {
        EngineManager.shared
    }
    override init() {
        roomSpeechMode = roomInfo.speechMode
    }
    func update(roomInfo: RoomInfo) {
        self.roomInfo = roomInfo
    }
    
    func initialRoomCurrentUser() {
        currentUser.userId = currentLoginUser.userId
        engineManager.roomEngine.getUserInfo(currentLoginUser.userId) { [weak self] userInfo in
            guard let self = self else { return }
            guard let userInfo = userInfo else { return }
            self.currentUser.update(userInfo: userInfo)
        } onError: { code, message in
            debugPrint("getUserInfo,code:\(code),message:\(message)")
        }
    }
    
    func refreshStore() {
        isChatAccessRoom = false
        videoSetting = VideoModel()
        audioSetting = AudioModel()
        roomScene = .meeting
        attendeeList = []
        inviteSeatList = []
        isSomeoneSharing = false
        currentUser = UserModel()
        roomInfo = RoomInfo()
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
    
    public var isOpenMicrophone: Bool
    public var isOpenCamera: Bool
    public var isUseSpeaker: Bool
    
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
    
    var roomType: TUIRoomType {
        set {
            roomInfo.roomType = newValue
        }
        get {
            return roomInfo.roomType
        }
    }
    
    public var ownerId: String = ""
    
    private var roomInfo: TUIRoomInfo
    public override init() {
        isOpenMicrophone = true
        isOpenCamera = true
        isUseSpeaker = false
        roomInfo = TUIRoomInfo()
        super.init()
    }
    
    convenience init(roomInfo: TUIRoomInfo) {
        self.init()
        self.roomInfo = roomInfo
        self.ownerId = roomInfo.ownerId
    }
    
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
