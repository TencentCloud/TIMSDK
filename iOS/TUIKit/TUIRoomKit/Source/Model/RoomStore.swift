//
//  RoomStore.swift
//  TUIRoomKit
//
//  Created by aby on 2022/12/28.
//  Copyright © 2022 Tencent. All rights reserved.
//

import Foundation
import TUICore
import RTCRoomEngine

let roomHashNumber: Int = 0x3B9AC9FF

class RoomStore: NSObject {
    var currentUser: UserEntity = UserEntity()
    var roomInfo: TUIRoomInfo = TUIRoomInfo()
    var videoSetting: VideoModel = VideoModel()
    var audioSetting: AudioModel = AudioModel()
    var attendeeList: [UserEntity] = []        // User list
    var seatList: [UserEntity] = []            // List of users who have taken the stage
    var offSeatList: [UserEntity] = []         // List of users who not on stage
    var inviteSeatList: [RequestEntity] = []   // List of users who apply to be on stage
    var isEnteredRoom: Bool = false
    var timeStampOnEnterRoom: Int = 0          // Timestamp of entering the meeting
    var isImAccess: Bool = false               // Whether TUIRoomKit is entered by IM
    var selfTakeSeatRequestId: String?         // Self ID for applying on stage
    var shouldShowFloatChatView = true
    private let openCameraKey = "isOpenCamera"
    private let openMicrophoneKey = "isOpenMicrophone"
    private let shownRaiseHandNoticeKey = "isShownRaiseHandNotice"
    weak var conferenceObserver: ConferenceObserver?
    
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
        currentUser.userId = TUILogin.getUserID() ?? ""
        currentUser.userName = TUILogin.getNickName() ?? ""
        EngineManager.createInstance().getUserInfo(currentUser.userId) { [weak self] userInfo in
            guard let self = self else { return }
            guard let userInfo = userInfo else { return }
            self.currentUser.update(userInfo: userInfo)
        } onError: { code, message in
            debugPrint("getUserInfo,code:\(code),message:\(message)")
        }
    }
    
    func initialSeatList(seatList: [TUISeatInfo]) {
        var localSeatList = [UserEntity]()
        for seatInfo in seatList {
            guard let userId = seatInfo.userId, userId != "" else { continue }
            guard let userModel = getUserItem(userId) else { continue }
            userModel.isOnSeat = true
            localSeatList.append(userModel)
        }
        self.seatList = localSeatList
        if seatList.contains(where: { $0.userId == currentUser.userId }) {
            updateSelfOnSeatState(isOnSeat: true)
        }
        EngineEventCenter.shared.notifyUIEvent(key: .TUIRoomKitService_RenewSeatList, param: [:])
        EngineEventCenter.shared.notifyUIEvent(key: .TUIRoomKitService_RenewVideoSeatView, param: [:])
    }
    
    func initialOffSeatList() {
        offSeatList = attendeeList.filter({ !$0.isOnSeat })
    }
    
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
    
    func deleteTakeSeatRequest(requestId: String) {
        let requestUserId = inviteSeatList.first(where: { $0.requestId == requestId })?.userId
        inviteSeatList = inviteSeatList.filter { requestItem in
            requestItem.requestId != requestId
        }
        EngineEventCenter.shared.notifyEngineEvent(event: .onDeletedTakeSeatRequest, param: ["userId": requestUserId ?? ""])
        EngineEventCenter.shared.notifyUIEvent(key: .TUIRoomKitService_RenewSeatList, param: [:])
    }
    
    func deleteInviteSeatUser(_ userId: String) {
        inviteSeatList = inviteSeatList.filter { requestItem in
            requestItem.userId != userId
        }
        EngineEventCenter.shared.notifyUIEvent(key: .TUIRoomKitService_RenewSeatList, param: [:])
    }
    
    func addInviteSeatUser(request: TUIRequest) {
        guard !inviteSeatList.contains(where: { $0.userId == request.userId }) else { return }
        let requestEntity = RequestEntity(requestId: request.requestId, userId: request.userId)
        inviteSeatList.append(requestEntity)
        EngineEventCenter.shared.notifyUIEvent(key: .TUIRoomKitService_RenewSeatList, param: [:])
    }
    
    func setCameraOpened(_ isCameraOpened: Bool) {
        videoSetting.isCameraOpened = isCameraOpened
    }
    
    func setSoundOnSpeaker(_ isSoundOnSpeaker: Bool) {
        audioSetting.isSoundOnSpeaker = isSoundOnSpeaker
    }
    
    func setConferenceObserver(_ observer: ConferenceObserver?) {
        conferenceObserver = observer
    }
    
    func setInviteSeatList(list: [TUIRequest]) {
        inviteSeatList = []
        for request in list {
            let requestEntity = RequestEntity(requestId: request.requestId, userId: request.userId)
            inviteSeatList.append(requestEntity)
        }
        EngineEventCenter.shared.notifyUIEvent(key: .TUIRoomKitService_RenewSeatList, param: [:])
    }
    
    func updateLeftSeatList(leftList: [TUISeatInfo]) {
        guard leftList.count > 0 else { return }
        if leftList.contains(where: { $0.userId == currentUser.userId }) {
            currentUser.isOnSeat = false
            audioSetting.isMicOpened = false
            EngineEventCenter.shared.notifyUIEvent(key: .TUIRoomKitService_UserOnSeatChanged,
                                                   param: ["isOnSeat":false])
        }
        for seatInfo: TUISeatInfo in leftList {
            guard let userId = seatInfo.userId else { continue }
            if let userItem = attendeeList.first(where: { $0.userId == userId }) {
                userItem.isOnSeat = false
                addOffSeatItem(userItem)
            }
            deleteOnSeatItem(userId)
        }
        EngineEventCenter.shared.notifyUIEvent(key: .TUIRoomKitService_RenewSeatList, param: [:])
    }
    
    func updateSeatedList(seatList: [TUISeatInfo]) {
        guard seatList.count > 0 else { return }
        if seatList.contains(where: { $0.userId == currentUser.userId }) {
            currentUser.isOnSeat = true
            EngineEventCenter.shared.notifyUIEvent(key: .TUIRoomKitService_UserOnSeatChanged,
                                                   param: ["isOnSeat":true])
        }
        for seatInfo: TUISeatInfo in seatList {
            guard let userId = seatInfo.userId else { continue }
            guard let userInfo = attendeeList.first(where: { $0.userId == userId }) else { continue }
            userInfo.isOnSeat = true
            addOnSeatItem(userInfo)
            deleteOffSeatItem(userId)
        }
        EngineEventCenter.shared.notifyUIEvent(key: .TUIRoomKitService_RenewSeatList, param: [:])
    }
    
    func remoteUserEnterRoom(userInfo: TUIUserInfo) {
        let userItem = UserEntity()
        userItem.update(userInfo: userInfo)
        addUserItem(userItem)
        if roomInfo.isSeatEnabled, !userItem.isOnSeat {
            addOffSeatItem(userItem)
        }
        EngineEventCenter.shared.notifyUIEvent(key: .TUIRoomKitService_RenewUserList, param: [:])
    }
    
    func remoteUserLeaveRoom(userInfo: TUIUserInfo) {
        deleteUserItem(userInfo.userId)
        deleteOffSeatItem(userInfo.userId)
        EngineEventCenter.shared.notifyUIEvent(key: .TUIRoomKitService_RenewUserList, param: [:])
    }
    
    func updateFloatChatShowState(shouldShow: Bool) {
        shouldShowFloatChatView = shouldShow
        EngineEventCenter.shared.notifyUIEvent(key: .TUIRoomKitService_ShowFloatChatView, param: ["shouldShow": shouldShow])
    }
    
    deinit {
        debugPrint("self:\(self),deinit")
    }
}

extension RoomStore {
    private func getUserItem(_ userId: String) -> UserEntity? {
        return attendeeList.first(where: {$0.userId == userId})
    }
    
    private func addUserItem(_ userItem: UserEntity) {
        guard getUserItem(userItem.userId) == nil else { return }
        if userItem.userName.isEmpty {
            userItem.userName = userItem.userId
        }
        attendeeList.append(userItem)
    }
    
    private func deleteUserItem(_ userId: String) {
        attendeeList.removeAll(where: { $0.userId == userId })
    }
    
    private func addOnSeatItem(_ userItem: UserEntity) {
        guard !seatList.contains(where: { $0.userId == userItem.userId }) else { return }
        seatList.append(userItem)
    }
    
    private func deleteOnSeatItem(_ userId: String) {
        seatList.removeAll(where: { $0.userId == userId })
    }
    
    private func addOffSeatItem(_ userItem: UserEntity) {
        guard !offSeatList.contains(where: { $0.userId == userItem.userId }) else { return }
        offSeatList.append(userItem)
    }
    
    private func deleteOffSeatItem(_ userId: String) {
        offSeatList.removeAll(where: { $0.userId == userId })
    }
}
