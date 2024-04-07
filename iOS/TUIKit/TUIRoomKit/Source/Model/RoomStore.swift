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
    var currentUser: UserEntity = UserEntity()
    var roomInfo: TUIRoomInfo = TUIRoomInfo()
    var videoSetting: VideoModel = VideoModel()
    var audioSetting: AudioModel = AudioModel()
    var attendeeList: [UserEntity] = []//用户列表
    var seatList: [UserEntity] = []// 已经上麦的用户列表
    var inviteSeatList: [UserEntity] = []//申请上麦的用户列表（针对举手发言房间）
    var inviteSeatMap: [String:String] = [:]
    var isEnteredRoom: Bool = false //是否已经进入房间
    var timeStampOnEnterRoom: Int = 0 //进入会议的时间戳
    var isShowRoomMainViewAutomatically: Bool = true //true 调用createRoom或者enterRoom会自动进入主界面; false 需要调用 showRoomMainView 才能进入主界面。
    var isImAccess: Bool = false //是否由IM进入的TUIRoomKit
    var selfTakeSeatRequestId: String? //自己进行上台申请的id
    private let openCameraKey = "isOpenCamera"
    private let openMicrophoneKey = "isOpenMicrophone"
    private let shownRaiseHandNoticeKey = "isShownRaiseHandNotice"
    var isOpenMicrophone: Bool {
        didSet {
            UserDefaults.standard.set(isOpenMicrophone, forKey: openMicrophoneKey)
            UserDefaults.standard.synchronize()
        }
    }
    var isOpenCamera: Bool {
        didSet {
            UserDefaults.standard.set(isOpenCamera, forKey: openCameraKey)
            UserDefaults.standard.synchronize()
        }
    }
    var isShownRaiseHandNotice: Bool {
        didSet {
            UserDefaults.standard.set(isShownRaiseHandNotice, forKey: shownRaiseHandNoticeKey)
            UserDefaults.standard.synchronize()
        }
    }
    
    override init() {
        if let isOpenMicrophoneValue = UserDefaults.standard.object(forKey: openMicrophoneKey) as? Bool {
            isOpenMicrophone = isOpenMicrophoneValue
        } else {
            isOpenMicrophone = true
        }
        if let isOpenCameraValue = UserDefaults.standard.object(forKey: openCameraKey) as? Bool {
            isOpenCamera = isOpenCameraValue
        } else {
            isOpenCamera = true
        }
        if let isShownRaiseHandNoticeValue = UserDefaults.standard.object(forKey: shownRaiseHandNoticeKey) as? Bool {
            isShownRaiseHandNotice = isShownRaiseHandNoticeValue
        } else {
            isShownRaiseHandNotice = true
        }
    }
    
    func initalEnterRoomMessage() {
        isEnteredRoom = true
        timeStampOnEnterRoom = Int(Date().timeIntervalSince1970)
    }
    
    func initialRoomCurrentUser() {
        EngineManager.createInstance().getUserInfo(TUILogin.getUserID() ?? "") { [weak self] userInfo in
            guard let self = self else { return }
            guard let userInfo = userInfo else { return }
            self.currentUser.update(userInfo: userInfo)
        } onError: { code, message in
            debugPrint("getUserInfo,code:\(code),message:\(message)")
        }
    }
    
    //初始化麦上用户列表
    func initialSeatList(seatList: [TUISeatInfo]) {
        var localSeatList = [UserEntity]()
        for seatInfo in seatList {
            guard let userId = seatInfo.userId, userId != "" else { continue }
            guard let userModel = getUserItem(userId) else { continue }
            userModel.isOnSeat = true
            localSeatList.append(userModel)
        }
        self.seatList = localSeatList
        if getSeatItem(currentUser.userId) != nil {
            updateSelfOnSeatState(isOnSeat: true)
        }
        EngineEventCenter.shared.notifyUIEvent(key: .TUIRoomKitService_RenewSeatList, param: [:])
        EngineEventCenter.shared.notifyUIEvent(key: .TUIRoomKitService_RenewVideoSeatView, param: [:])
    }
    
    //更新自己的上麦状态
    func updateSelfOnSeatState(isOnSeat: Bool) {
        currentUser.isOnSeat = isOnSeat
        EngineEventCenter.shared.notifyUIEvent(key: .TUIRoomKitService_UserOnSeatChanged, param: ["isOnSeat": isOnSeat])
    }
    
    func updateUserDisableSendingMessage(userId: String, isDisable: Bool) {
        if userId == currentUser.userId {
            currentUser.disableSendingMessage = isDisable
        }
        guard let userItem = getUserItem(userId) else { return }
        userItem.disableSendingMessage = isDisable
    }
    
    func deleteTakeSeatRequest(requestId: String, userId: String) {
        var userId = userId
        inviteSeatMap.forEach { (key, value) in
            if value == requestId {
                userId = key
            }
        }
        deleteInviteSeatItem(userId: userId)
        EngineEventCenter.shared.notifyUIEvent(key: .TUIRoomKitService_RenewSeatList, param: [:])
    }
    
    func deleteInviteSeatItem(userId: String) {
        inviteSeatList = inviteSeatList.filter { userModel in
            userModel.userId != userId
        }
        inviteSeatMap.removeValue(forKey: userId)
    }
    
    private func getUserItem(_ userId: String) -> UserEntity? {
        return attendeeList.first(where: {$0.userId == userId})
    }
    
    private func getSeatItem(_ userId: String) -> UserEntity? {
        return seatList.first(where: { $0.userId == userId })
    }
    
    deinit {
        debugPrint("self:\(self),deinit")
    }
}
