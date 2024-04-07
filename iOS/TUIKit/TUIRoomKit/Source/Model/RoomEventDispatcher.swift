//
//  RoomEventDispatcher.swift
//  TUIRoomKit
//
//  Created by 唐佳宁 on 2023/8/14.
//

import Foundation
import TUIRoomEngine

class RoomEventDispatcher: NSObject {
    var engineManager: EngineManager {
        EngineManager.createInstance()
    }
    var store: RoomStore {
        engineManager.store
    }
    var roomInfo: TUIRoomInfo {
        store.roomInfo
    }
    var currentUser: UserEntity {
        store.currentUser
    }
    
    deinit {
        debugPrint("deinit")
    }
}

extension RoomEventDispatcher: TUIRoomObserver {
    // MARK: - 房间内事件回调
    func onAllUserMicrophoneDisableChanged(roomId: String, isDisable: Bool) {
        roomInfo.isMicrophoneDisableForAllUser = isDisable
        let param = [
            "roomId" : roomId,
            "isDisable" : isDisable,
        ] as [String : Any]
        EngineEventCenter.shared.notifyEngineEvent(event: .onAllUserMicrophoneDisableChanged, param: param)
    }
    
    func onAllUserCameraDisableChanged(roomId: String, isDisable: Bool) {
        roomInfo.isCameraDisableForAllUser = isDisable
        let param = [
            "roomId" : roomId,
            "isDisable" : isDisable,
        ] as [String : Any]
        EngineEventCenter.shared.notifyEngineEvent(event: .onAllUserCameraDisableChanged, param: param)
    }
    
    func onSendMessageForAllUserDisableChanged(roomId: String, isDisable: Bool) {
        roomInfo.isMessageDisableForAllUser = isDisable
    }
    
    func onRoomDismissed(roomId: String) {
        EngineEventCenter.shared.notifyEngineEvent(event: .onRoomDismissed, param: ["roomId" : roomId,])
    }
    
    func onKickedOutOfRoom(roomId: String, reason: TUIKickedOutOfRoomReason, message: String) {
        let param = [
            "roomId" : roomId,
            "reason" : reason,
            "message" : message,
        ] as [String : Any]
        EngineEventCenter.shared.notifyEngineEvent(event: .onKickedOutOfRoom, param: param)
    }
    
    func onRoomNameChanged(roomId: String, roomName: String) {
        roomInfo.name = roomName
    }
    
    // MARK: - 房间内用户事件回调
    func onRemoteUserEnterRoom(roomId: String, userInfo: TUIUserInfo) {
        remoteUserEnterRoom(roomId: roomId, userInfo: userInfo)
        let param = [
            "roomId" : roomId,
            "userInfo" : userInfo,
        ] as [String : Any]
        EngineEventCenter.shared.notifyEngineEvent(event: .onRemoteUserEnterRoom, param: param)
    }
    
    func onRemoteUserLeaveRoom(roomId: String, userInfo: TUIUserInfo) {
        remoteUserLeaveRoom(roomId: roomId, userInfo: userInfo)
        let param = [
            "roomId" : roomId,
            "userInfo" : userInfo,
        ] as [String : Any]
        EngineEventCenter.shared.notifyEngineEvent(event: .onRemoteUserLeaveRoom, param: param)
    }
    
    func onUserRoleChanged(userId: String, userRole: TUIRole) {
        userRoleChanged(userId: userId, userRole: userRole)
        let param = [
            "userId" : userId,
            "userRole" : userRole,
        ] as [String : Any]
        EngineEventCenter.shared.notifyEngineEvent(event: .onUserRoleChanged, param: param)
    }
    
    func onUserVideoStateChanged(userId: String, streamType: TUIVideoStreamType, hasVideo: Bool, reason: TUIChangeReason) {
        userVideoStateChanged(userId: userId, streamType: streamType, hasVideo: hasVideo, reason: reason)
        let param = [
            "userId" : userId,
            "streamType" : streamType,
            "hasVideo" : hasVideo,
            "reason" : reason,
        ] as [String : Any]
        EngineEventCenter.shared.notifyEngineEvent(event: .onUserVideoStateChanged, param: param)
    }
    
    func onUserAudioStateChanged(userId: String, hasAudio: Bool, reason: TUIChangeReason) {
        userAudioStateChanged(userId: userId, hasAudio: hasAudio, reason: reason)
        let param = [
            "userId" : userId,
            "hasAudio" : hasAudio,
            "reason" : reason,
        ] as [String : Any]
        EngineEventCenter.shared.notifyEngineEvent(event: .onUserAudioStateChanged, param: param)
    }
    
    func onUserVoiceVolumeChanged(volumeMap: [String : NSNumber]) {
        userVoiceVolumeChanged(volumeMap: volumeMap)
        EngineEventCenter.shared.notifyEngineEvent(event: .onUserVoiceVolumeChanged, param: volumeMap)
    }
    
    func onUserScreenCaptureStopped(reason: Int) {
        userScreenCaptureStopped()
        EngineEventCenter.shared.notifyUIEvent(key: .TUIRoomKitService_SomeoneSharing, param: ["userId":currentUser.userId, "hasVideo": false])
    }
    
    func onSeatListChanged(seatList: [TUISeatInfo], seated seatedList: [TUISeatInfo], left leftList: [TUISeatInfo]) {
        seatListChanged(seatList: seatList,seated: seatedList, left: leftList)
        let param = [
            "seatList": seatList,
            "seated": seatedList,
            "left": leftList,
        ] as [String : Any]
        EngineEventCenter.shared.notifyEngineEvent(event: .onSeatListChanged, param: param)
    }
    
    func OnSendMessageForUserDisableChanged(roomId: String, userId: String, isDisable muted: Bool) {
        store.updateUserDisableSendingMessage(userId: userId, isDisable: muted)
        let param = [
            "roomId": roomId,
            "userId": userId,
            "muted": muted,
        ] as [String : Any]
        EngineEventCenter.shared.notifyEngineEvent(event: .onSendMessageForUserDisableChanged, param: param)
    }
    
    // MARK: - 信令请求相关回调
    func onRequestReceived(request: TUIRequest) {
        requestReceived(request: request)
        EngineEventCenter.shared.notifyEngineEvent(event: .onRequestReceived, param: ["request": request,])
    }
    
    func onRequestCancelled(requestId: String, userId: String) {
        store.deleteTakeSeatRequest(requestId: requestId, userId: userId)
    }
    
    func onRequestProcessed(requestId: String, userId: String) {
        store.deleteTakeSeatRequest(requestId: requestId, userId: userId)
    }
    
    func onKickedOffSeat(userId: String) {
        let param = [
            "userId": userId,
        ] as [String : Any]
        EngineEventCenter.shared.notifyEngineEvent(event: .onKickedOffSeat, param: param)
    }
}

//收到事件回调后的处理逻辑
extension RoomEventDispatcher {
    private func remoteUserEnterRoom(roomId: String, userInfo: TUIUserInfo) {
        let userItem = UserEntity()
        userItem.update(userInfo: userInfo)
        engineManager.addUserItem(userItem)
        EngineEventCenter.shared.notifyUIEvent(key: .TUIRoomKitService_RenewUserList, param: [:])
    }
    
    private func remoteUserLeaveRoom(roomId: String, userInfo: TUIUserInfo) {
        engineManager.deleteUserItem(userInfo.userId)
        EngineEventCenter.shared.notifyUIEvent(key: .TUIRoomKitService_RenewUserList, param: [:])
        if roomInfo.isSeatEnabled {
            engineManager.deleteSeatItem(userInfo.userId)
            engineManager.deleteInviteSeatUser(userInfo.userId)
            EngineEventCenter.shared.notifyUIEvent(key: .TUIRoomKitService_RenewSeatList, param: [:])
        }
    }
    
    private func seatListChanged(seatList: [TUISeatInfo], seated: [TUISeatInfo], left leftList: [TUISeatInfo]) {
        //判断自己是否下麦
        if leftList.first(where: { $0.userId == currentUser.userId }) != nil {
            currentUser.isOnSeat = false
            store.audioSetting.isMicOpened = false
            if currentUser.hasScreenStream { //如果正在进行屏幕共享，要把屏幕共享关闭。
                engineManager.stopScreenCapture()
            }
            EngineEventCenter.shared.notifyUIEvent(key: .TUIRoomKitService_UserOnSeatChanged,
                                                   param: ["isOnSeat":false])
        }
        updateLeftList(leftList: leftList)
        //判断自己是否新上麦
        if seated.first(where: { $0.userId == currentUser.userId }) != nil {
            currentUser.isOnSeat = true
            EngineEventCenter.shared.notifyUIEvent(key: .TUIRoomKitService_UserOnSeatChanged,
                                                   param: ["isOnSeat":true])
        }
        updateSeatList(seatList: seatList)
    }
    
    //更新在麦上的用户列表
    private func updateSeatList(seatList: [TUISeatInfo]) {
        guard seatList.count > 0 else { return }
        for seatInfo: TUISeatInfo in seatList {
            guard let userId = seatInfo.userId else { continue }
            guard let userInfo = store.attendeeList.first(where: { $0.userId == userId }) else { continue }
            userInfo.isOnSeat = true
            engineManager.deleteInviteSeatUser(userId)
            engineManager.addSeatItem(userInfo)
        }
        EngineEventCenter.shared.notifyUIEvent(key: .TUIRoomKitService_RenewSeatList, param: [:])
    }
    //更新下台的用户
    private func updateLeftList(leftList: [TUISeatInfo]) {
        guard leftList.count > 0 else { return }
        for seatInfo: TUISeatInfo in leftList {
            guard let userId = seatInfo.userId else {
                continue
            }
            if let userItem = store.attendeeList.first(where: { $0.userId == userId }) {
                userItem.isOnSeat = false
            }
            engineManager.deleteInviteSeatUser(userId)
            engineManager.deleteSeatItem(userId)
        }
        EngineEventCenter.shared.notifyUIEvent(key: .TUIRoomKitService_RenewSeatList, param: [:])
    }
    
    private func getUserItem(_ userId: String) -> UserEntity? {
        return store.attendeeList.first(where: {$0.userId == userId})
    }
    
    private func userAudioStateChanged(userId: String, hasAudio: Bool, reason: TUIChangeReason) {
        if userId == currentUser.userId {
            EngineEventCenter.shared.notifyUIEvent(key: .TUIRoomKitService_CurrentUserHasAudioStream, param: ["hasAudio": hasAudio, "reason": reason])
            currentUser.hasAudioStream = hasAudio
        }
        guard let userModel = store.attendeeList.first(where: { $0.userId == userId }) else { return }
        userModel.hasAudioStream = hasAudio
        EngineEventCenter.shared.notifyUIEvent(key: .TUIRoomKitService_RenewUserList, param: [:])
    }
    
    private func userVideoStateChanged(userId: String, streamType: TUIVideoStreamType, hasVideo: Bool, reason: TUIChangeReason) {
        switch streamType {
        case .screenStream:
            if userId == currentUser.userId {
                currentUser.hasScreenStream = hasVideo
            }
            guard let userModel = store.attendeeList.first(where: { $0.userId == userId }) else { return }
            userModel.hasScreenStream = hasVideo
            EngineEventCenter.shared.notifyUIEvent(key: .TUIRoomKitService_SomeoneSharing, param: ["userId": userId, "hasVideo": hasVideo])
        case .cameraStream:
            if userId == currentUser.userId {
                EngineEventCenter.shared.notifyUIEvent(key: .TUIRoomKitService_CurrentUserHasVideoStream,
                                                       param: ["hasVideo": hasVideo, "reason": reason])
                currentUser.hasVideoStream = hasVideo
                store.videoSetting.isCameraOpened = hasVideo
            }
            guard let userModel = store.attendeeList.first(where: { $0.userId == userId }) else { return }
            userModel.hasVideoStream = hasVideo
            EngineEventCenter.shared.notifyUIEvent(key: .TUIRoomKitService_RenewUserList, param: [:])
        default: break
        }
    }
    
    private func userRoleChanged(userId: String, userRole: TUIRole) {
        let isSelfRoleChanged = userId == currentUser.userId
        let isRoomOwnerChanged = userRole == .roomOwner
        if let userInfo = store.attendeeList.first(where: { $0.userId == userId }) {
            userInfo.userRole = userRole
            EngineEventCenter.shared.notifyUIEvent(key: .TUIRoomKitService_RenewUserList, param: ["userRole": userRole])
        }
        if isSelfRoleChanged {
            store.currentUser.userRole = userRole
            EngineEventCenter.shared.notifyUIEvent(key: .TUIRoomKitService_CurrentUserRoleChanged, param: ["userRole": userRole])
        }
        if isRoomOwnerChanged {
            EngineManager.createInstance().fetchRoomInfo() {
                EngineEventCenter.shared.notifyUIEvent(key: .TUIRoomKitService_RoomOwnerChanged, param: ["owner": userId])
            }
        }
        if checkAutoTakeSeatForOwner(userId: userId, userRole: userRole) {
           let _ = engineManager.takeSeat()
        }
        if checkAutoSendingMessageForOwner(userId: userId, userRole: userRole) {
            engineManager.disableSendingMessageByAdmin(userId: userId, isDisable: false)
        }
    }
    
    private func checkAutoTakeSeatForOwner(userId: String, userRole: TUIRole) -> Bool {
        let isSelfRoleChanged = userId == currentUser.userId
        let isRoomOwnerChanged = userRole == .roomOwner
        return isSelfRoleChanged && isRoomOwnerChanged && roomInfo.isSeatEnabled && !currentUser.isOnSeat
    }
    
    private func checkAutoSendingMessageForOwner(userId: String, userRole: TUIRole) -> Bool {
        let isSelfRoleChanged = userId == currentUser.userId
        let isRoomOwnerChanged = userRole == .roomOwner
        return isSelfRoleChanged && isRoomOwnerChanged && currentUser.disableSendingMessage
    }
    
    private func requestReceived(request: TUIRequest) {
        switch request.requestAction {
        case .takeSeat:
            if roomInfo.isSeatEnabled {
                guard let userModel = store.attendeeList.first(where: {$0.userId == request.userId}) else { return }
                guard store.inviteSeatMap[request.userId] == nil else { return }
                engineManager.addInviteSeatUser(userItem: userModel, request: request)
                EngineEventCenter.shared.notifyUIEvent(key: .TUIRoomKitService_RenewSeatList, param: [:])
            }
        default: break
        }
    }
    
    private func userVoiceVolumeChanged(volumeMap: [String : NSNumber]) {
        for (userId, volume) in volumeMap {
            guard let userModel = store.attendeeList.first(where: { $0.userId == userId}) else { continue }
            userModel.userVoiceVolume = volume.intValue
        }
    }
    
    private func userScreenCaptureStopped() {
        currentUser.hasScreenStream = false
        guard let userModel = store.attendeeList.first(where: { $0.userId == currentUser.userId }) else { return }
        userModel.hasScreenStream = false
    }
}
