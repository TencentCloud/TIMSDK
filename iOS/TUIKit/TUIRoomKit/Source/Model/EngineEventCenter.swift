//
//  EngineEventCenter.swift
//  TUIRoomKit
//
//  Created by aby on 2023/1/8.
//  Copyright © 2023 Tencent. All rights reserved.
//

import Foundation
import TUIRoomEngine
import TUICore

protocol RoomKitUIEventResponder: NSObject {
    func onNotifyUIEvent(key: EngineEventCenter.RoomUIEvent, Object: Any?, info: [AnyHashable: Any]?)
}

protocol RoomEngineEventResponder: NSObject {
    func onEngineEvent(name: EngineEventCenter.RoomEngineEvent, param: [String: Any]?)
}

class TUINotificationAdapter:NSObject ,TUINotificationProtocol {
    
    weak var responder: RoomKitUIEventResponder?
    
    init(responder: RoomKitUIEventResponder? = nil) {
        self.responder = responder
    }
    
    func onNotifyEvent(_ key: String, subKey: String, object anObject: Any?, param: [AnyHashable : Any]?) {
        guard let eventKey = EngineEventCenter.RoomUIEvent(rawValue: subKey) else { return }
        responder?.onNotifyUIEvent(key: eventKey, Object: anObject, info: param)
    }
    
    deinit {
        debugPrint("deinit \(self)")
    }
}

/// 负责RoomEngine回调事件分发与通知
class EngineEventCenter: NSObject {
    
    // Weak Ref
    typealias WeakArray<T> = [() -> T?]
    
    static let shared = EngineEventCenter()
    private var engineObserverMap: [RoomEngineEvent: WeakArray<RoomEngineEventResponder>] = [:]
    private var uiEventObserverMap: [RoomUIEvent: [TUINotificationAdapter]] = [:]
    var engineManager: EngineManager {
        EngineManager.shared
    }
    var roomInfo: RoomInfo {
        engineManager.store.roomInfo
    }
    var currentUser: UserModel {
        engineManager.store.currentUser
    }
    
    private override init() {
        super.init()
    }
    
    enum RoomEngineEvent: String {
        case onError
        case onKickedOffLine
        case onUserSigExpired
        case onAllUserMicrophoneDisableChanged
        case onAllUserCameraDisableChanged
        case onSendMessageForAllUserDisableChanged
        case onRoomDismissed
        case onKickedOutOfRoom
        case onRemoteUserEnterRoom
        case onRemoteUserLeaveRoom
        case onUserRoleChanged
        case onUserVideoStateChanged
        case onUserAudioStateChanged
        case onUserVoiceVolumeChanged
        case onUserNetworkQualityChanged
        case onUserScreenCaptureStopped
        case onSeatListChanged
        case onRequestReceived
        case onRequestCancelled
        case onReceiveTextMessage
        case onReceiveCustomMessage
        case onRoomNameChanged
        case onRoomSpeechModeChanged
        case onSendMessageForUserDisableChanged
    }
    
    enum RoomUIEvent: String {
        case TUIRoomKitService
        case TUIRoomKitService_RenewUserList
        case TUIRoomKitService_SomeoneSharing
        case TUIRoomKitService_RenewSeatList
        case TUIRoomKitService_UserOnSeatChanged
        case TUIRoomKitService_ResignFirstResponder
        case TUIRoomKitService_ShowBeautyView
    }
    
    /// 注册UI响应相关监听事件
    /// - Parameter key: UI响应对应Key
    func subscribeUIEvent(key: RoomUIEvent, responder: RoomKitUIEventResponder) {
        let observer = TUINotificationAdapter(responder: responder)
        if var observerArray = uiEventObserverMap[key] {
            observerArray.append(observer)
            uiEventObserverMap[key] = observerArray
        } else {
            uiEventObserverMap[key] = [observer]
        }
        TUICore.registerEvent(RoomUIEvent.TUIRoomKitService.rawValue, subKey: key.rawValue, object: observer)
    }
    
    
    /// 移除UI响应相关事件监听
    /// - Parameter key: UI响应对应Key
    func unsubscribeUIEvent(key: RoomUIEvent, responder: RoomKitUIEventResponder?) {
        guard var observerArray = uiEventObserverMap[key] else { return }
        if let responder = responder {
            observerArray = observerArray.filter({ observer in
                guard let responderValue = observer.responder else { return false }
                if responderValue == responder {
                    TUICore.unRegisterEvent(RoomUIEvent.TUIRoomKitService.rawValue, subKey: key.rawValue, object: observer)
                }
                return responderValue == responder
            })
            uiEventObserverMap[key] = observerArray
            if observerArray.count == 0 {
                uiEventObserverMap.removeValue(forKey: key)
            }
        } else {
            observerArray.forEach { observer in
                TUICore.unRegisterEvent(RoomUIEvent.TUIRoomKitService.rawValue, subKey: key.rawValue, object: observer)
            }
            uiEventObserverMap.removeValue(forKey: key)
        }
    }
    
    func notifyUIEvent(key: RoomUIEvent, param: [AnyHashable : Any]) {
        TUICore.notifyEvent(RoomUIEvent.TUIRoomKitService.rawValue, subKey: key.rawValue, object: nil, param: param)
    }
    
    func subscribeEngine(event: RoomEngineEvent, observer: RoomEngineEventResponder) {
        let weakObserver = { [weak observer] in return observer }
        if var observerArray = engineObserverMap[event] {
            observerArray.append(weakObserver)
            engineObserverMap[event] = observerArray
        } else {
            engineObserverMap[event] = [weakObserver]
        }
    }
    
    func unsubscribeEngine(event: RoomEngineEvent, observer: RoomEngineEventResponder) {
        guard var observerArray = engineObserverMap[event] else { return }
        observerArray.removeAll(where: {$0() === observer})
        if observerArray.count == 0 {
            engineObserverMap.removeValue(forKey: event)
        }
    }
    
    func receiveEngineEvent(event: RoomEngineEvent, param: [String: Any]?) {
        guard let observers = engineObserverMap[event] else { return }
        observers.forEach { responder in
            responder()?.onEngineEvent(name: event, param: param)
        }
    }
    
    deinit {
        EngineManager.shared.roomEngine.removeObserver(self)
        debugPrint("deinit \(self)")
    }
}

//收到事件回调后的处理逻辑
extension EngineEventCenter {
    private func remoteUserEnterRoom(roomId: String, userInfo: TUIUserInfo) {
        if roomId == engineManager.store.roomInfo.roomId {
            addUserList(userInfo: userInfo)
        }
    }
    private func remoteUserLeaveRoom(roomId: String, userInfo: TUIUserInfo) {
        if roomId == engineManager.store.roomInfo.roomId {
            removeUserList(userId: userInfo.userId)
            removeSeatList(userId: userInfo.userId)
        }
    }
    private func seatListChanged(seatList: [TUISeatInfo], seated: [TUISeatInfo], left leftList: [TUISeatInfo]) {
        if leftList.count > 0 {
            //判断自己是否下麦
            if leftList.first(where: { $0.userId == currentUser.userId }) != nil {
                currentUser.isOnSeat = false
                notifyUIEvent(key: .TUIRoomKitService_UserOnSeatChanged,
                                                       param: ["isOnSeat":false])
            }
            //更新麦上用户列表
            for seatInfo: TUISeatInfo in leftList {
                guard let userId = seatInfo.userId else {
                    continue
                }
                if let userItem = getUserItem(userId) {
                    userItem.isOnSeat = false
                }
                removeSeatList(userId: userId)
            }
        }
        //如果新上麦的人员有自己，要更改自己的上麦状态和摄像头麦克风状态
        if seated.first(where: { $0.userId == currentUser.userId }) != nil {
            currentUser.isOnSeat = true
            notifyUIEvent(key: .TUIRoomKitService_UserOnSeatChanged,
                                                   param: ["isOnSeat":true])
        }
        //更新所有在麦上的观众
        for seatInfo: TUISeatInfo in seatList {
            guard let userId = seatInfo.userId else { continue }
            guard let userInfo = engineManager.store.attendeeList.first(where: { $0.userId == userId }) else { continue }
            switch roomInfo.speechMode {
            case .applySpeakAfterTakingSeat:
                userInfo.isOnSeat = true
            default: break
            }
            engineManager.store.inviteSeatList = engineManager.store.inviteSeatList.filter({ userModel in
                userModel.userId != userId
            })
            engineManager.store.inviteSeatMap.removeValue(forKey: userId)
        }
        notifyUIEvent(key: .TUIRoomKitService_RenewSeatList, param: [:])
    }
    private func allUserMicrophoneDisableChanged(roomId: String, isDisable: Bool) {
        roomInfo.isMicrophoneDisableForAllUser = isDisable
        if currentUser.userRole == .roomOwner {
            return
        }
        if isDisable {
            RoomRouter.makeToast(toast: .allMuteAudioText)
        } else {
            RoomRouter.makeToast(toast: .allUnMuteAudioText)
        }
    }
    private func allUserCameraDisableChanged(roomId: String, isDisable: Bool) {
        roomInfo.isCameraDisableForAllUser = isDisable
        if currentUser.userRole == .roomOwner {
            return
        }
        if isDisable {
            RoomRouter.makeToast(toast: .allMuteVideoText)
        } else {
            RoomRouter.makeToast(toast: .allUnMuteVideoText)
        }
    }
    private func addUserList(userInfo: TUIUserInfo) {
        if let userItem = getUserItem(userInfo.userId) {
            userItem.update(userInfo: userInfo)
        } else {
            if userInfo.userId == roomInfo.ownerId {
                userInfo.userRole = .roomOwner
            }
            if userInfo.userName.isEmpty {
                userInfo.userName = userInfo.userId
            }
            let userItem = UserModel()
            userItem.update(userInfo: userInfo)
            engineManager.store.attendeeList.append(userItem)
            notifyUIEvent(key: .TUIRoomKitService_RenewUserList, param: [:])
        }
    }
    
    private func getUserItem(_ userId: String) -> UserModel? {
        return engineManager.store.attendeeList.first(where: {$0.userId == userId})
    }
    
    private func removeUserList(userId: String, type: TUIVideoStreamType = .cameraStream) {
        if type == .cameraStream {
            engineManager.store.attendeeList = engineManager.store.attendeeList.filter { model -> Bool in
                model.userId != userId
            }
            notifyUIEvent(key: .TUIRoomKitService_RenewUserList, param: [:])
        }
    }
    
    private func removeSeatList(userId: String) {
        engineManager.store.inviteSeatList = engineManager.store.inviteSeatList.filter { model -> Bool in
            model.userId != userId
        }
        engineManager.store.inviteSeatMap.removeValue(forKey: userId)
        notifyUIEvent(key: .TUIRoomKitService_RenewSeatList, param: [:])
    }
    private func userAudioStateChanged(userId: String, hasAudio: Bool) {
        if userId == currentUser.userId {
            currentUser.hasAudioStream = hasAudio
        }
        guard let userModel = engineManager.store.attendeeList.first(where: { $0.userId == userId }) else { return }
        userModel.hasAudioStream = hasAudio
        notifyUIEvent(key: .TUIRoomKitService_RenewUserList, param: [:])
    }
    private func userVideoStateChanged(userId: String, streamType: TUIVideoStreamType, hasVideo: Bool) {
        switch streamType {
        case .screenStream:
            engineManager.store.isSomeoneSharing = hasVideo
            notifyUIEvent(key: .TUIRoomKitService_SomeoneSharing, param: [:])
        case .cameraStream:
            guard let userModel = engineManager.store.attendeeList.first(where: { $0.userId == userId }) else { return }
            userModel.hasVideoStream = hasVideo
            notifyUIEvent(key: .TUIRoomKitService_RenewUserList, param: [:])
        default: break
        }
    }
}

extension EngineEventCenter: TUIRoomObserver {
    // MARK: - Engine错误事件回调
    func onError(error errorCode: TUIError, message: String) {
        guard let observers = engineObserverMap[.onError] else { return }
        let param = [
            "errorCode" : errorCode,
            "message" : message,
        ] as [String : Any]
        observers.forEach { responder in
            responder()?.onEngineEvent(name: .onError, param: param)
        }
    }
    
    // MARK: - Engine 登录状态时间回调
    func onKickedOffLine(message: String) {
        guard let observers = engineObserverMap[.onKickedOffLine] else { return }
        let param = [
            "message" : message,
        ] as [String : Any]
        observers.forEach { responder in
            responder()?.onEngineEvent(name: .onKickedOffLine, param: param)
        }
    }
    
    func onUserSigExpired() {
        guard let observers = engineObserverMap[.onUserSigExpired] else { return }
        let param: [String: Any] = [:]
        observers.forEach { responder in
            responder()?.onEngineEvent(name: .onUserSigExpired, param: param)
        }
    }
    
    // MARK: - 房间内事件回调
    func onAllUserMicrophoneDisableChanged(roomId: String, isDisable: Bool) {
        allUserMicrophoneDisableChanged(roomId: roomId, isDisable: isDisable)
        guard let observers = engineObserverMap[.onAllUserMicrophoneDisableChanged] else { return }
        let param = [
            "roomId" : roomId,
            "isDisable" : isDisable,
        ] as [String:Any]
        observers.forEach { responder in
            responder()?.onEngineEvent(name: .onAllUserMicrophoneDisableChanged, param: param)
        }
    }
    
    func onAllUserCameraDisableChanged(roomId: String, isDisable: Bool) {
        allUserCameraDisableChanged(roomId: roomId, isDisable: isDisable)
        guard let observers = engineObserverMap[.onAllUserCameraDisableChanged] else { return }
        let param = [
            "roomId" : roomId,
            "isDisable" : isDisable,
        ] as [String:Any]
        observers.forEach { responder in
            responder()?.onEngineEvent(name: .onAllUserCameraDisableChanged, param: param)
        }
    }
    
    func onSendMessageForAllUserDisableChanged(roomId: String, isDisable: Bool) {
        roomInfo.isMessageDisableForAllUser = isDisable
        guard let observers = engineObserverMap[.onSendMessageForAllUserDisableChanged] else { return }
        let param = [
            "roomId" : roomId,
            "isDisable" : isDisable,
        ] as [String:Any]
        observers.forEach { responder in
            responder()?.onEngineEvent(name: .onSendMessageForAllUserDisableChanged, param: param)
        }
    }
    
    func onRoomDismissed(roomId: String) {
        guard let observers = engineObserverMap[.onRoomDismissed] else { return }
        let param = [
            "roomId" : roomId,
        ] as [String : Any]
        observers.forEach { responder in
            responder()?.onEngineEvent(name: .onRoomDismissed, param: param)
        }
    }
    
    func onKickedOutOfRoom(roomId: String, message: String) {
        guard let observers = engineObserverMap[.onKickedOutOfRoom] else { return }
        let param = [
            "roomId" : roomId,
            "message" : message,
        ] as [String : Any]
        observers.forEach { responder in
            responder()?.onEngineEvent(name: .onKickedOutOfRoom, param: param)
        }
    }
    
    func onRoomNameChanged(roomId: String, roomName: String) {
        roomInfo.name = roomName
        guard let observers = engineObserverMap[.onRoomNameChanged] else { return }
        let param = [
            "roomId" : roomId,
            "roomName" : roomName,
        ] as [String : Any]
        observers.forEach { responder in
            responder()?.onEngineEvent(name: .onRoomNameChanged, param: param)
        }
    }
    
    func onRoomSpeechModeChanged(roomId: String, speechMode mode: TUISpeechMode) {
        roomInfo.speechMode = mode
        guard let observers = engineObserverMap[.onRoomSpeechModeChanged] else { return }
        let param = [
            "roomId" : roomId,
            "mode" : mode,
        ] as [String : Any]
        observers.forEach { responder in
            responder()?.onEngineEvent(name: .onRoomSpeechModeChanged, param: param)
        }
    }
    
    // MARK: - 房间内用户事件回调
    func onRemoteUserEnterRoom(roomId: String, userInfo: TUIUserInfo) {
        remoteUserEnterRoom(roomId: roomId, userInfo: userInfo)
        guard let observers = engineObserverMap[.onRemoteUserEnterRoom] else { return }
        let param = [
            "roomId": roomId,
            "userInfo": userInfo,
        ] as [String : Any]
        observers.forEach { responder in
            responder()?.onEngineEvent(name: .onRemoteUserEnterRoom, param: param)
        }
    }
    
    func onRemoteUserLeaveRoom(roomId: String, userInfo: TUIUserInfo) {
        remoteUserLeaveRoom(roomId: roomId, userInfo: userInfo)
        guard let observers = engineObserverMap[.onRemoteUserLeaveRoom] else { return }
        let param = [
            "roomId": roomId,
            "userInfo": userInfo,
        ] as [String : Any]
        observers.forEach { responder in
            responder()?.onEngineEvent(name: .onRemoteUserLeaveRoom, param: param)
        }
    }
    
    func onUserRoleChanged(userId: String, userRole: TUIRole) {
        guard let observers = engineObserverMap[.onUserRoleChanged] else { return }
        let param = [
            "userId" : userId,
            "userRole" : userRole,
        ] as [String : Any]
        observers.forEach { responder in
            responder()?.onEngineEvent(name: .onUserRoleChanged, param: param)
        }
    }
    
    func onUserVideoStateChanged(userId: String, streamType: TUIVideoStreamType, hasVideo: Bool, reason: TUIChangeReason) {
        userVideoStateChanged(userId: userId, streamType: streamType, hasVideo: hasVideo)
        guard let observers = engineObserverMap[.onUserVideoStateChanged] else { return }
        let param = [
            "userId" : userId,
            "streamType" : streamType,
            "hasVideo" : hasVideo,
            "reason" : reason,
        ] as [String : Any]
        observers.forEach { responder in
            responder()?.onEngineEvent(name: .onUserVideoStateChanged, param: param)
        }
    }
    
    func onUserAudioStateChanged(userId: String, hasAudio: Bool, reason: TUIChangeReason) {
        userAudioStateChanged(userId: userId, hasAudio: hasAudio)
        guard let observers = engineObserverMap[.onUserAudioStateChanged] else { return }
        let param = [
            "userId" : userId,
            "hasAudio" : hasAudio,
            "reason" : reason,
        ] as [String : Any]
        observers.forEach { responder in
            responder()?.onEngineEvent(name: .onUserAudioStateChanged, param: param)
        }
    }
    
    func onUserVoiceVolumeChanged(volumeMap: [String : NSNumber]) {
        guard let observers = engineObserverMap[.onUserVoiceVolumeChanged] else { return }
        observers.forEach { responder in
            responder()?.onEngineEvent(name: .onKickedOutOfRoom, param: volumeMap)
        }
    }
    
    func onUserNetworkQualityChanged(networkList: [TUINetworkInfo]) {
        guard let observers = engineObserverMap[.onUserNetworkQualityChanged] else { return }
        let param = [
            "networkList" : networkList,
        ] as [String : Any]
        observers.forEach { responder in
            responder()?.onEngineEvent(name: .onUserNetworkQualityChanged, param: param)
        }
    }
    
    func onUserScreenCaptureStopped(reason: Int) {
        guard let observers = engineObserverMap[.onUserScreenCaptureStopped] else { return }
        let param = [
            "reason" : reason,
        ] as [String : Any]
        observers.forEach { responder in
            responder()?.onEngineEvent(name: .onUserScreenCaptureStopped, param: param)
        }
    }
    
    func onSeatListChanged(seatList: [TUISeatInfo], seated seatedList: [TUISeatInfo], left leftList: [TUISeatInfo]) {
        seatListChanged(seatList: seatList,seated: seatedList, left: leftList)
        guard let observers = engineObserverMap[.onSeatListChanged] else { return }
        let param = [
            "seatList": seatList,
            "seated": seatedList,
            "left": leftList,
        ] as [String : Any]
        observers.forEach { responder in
            responder()?.onEngineEvent(name: .onSeatListChanged, param: param)
        }
    }
    
    func OnSendMessageForUserDisableChanged(roomId: String, userId: String, isDisable muted: Bool) {
        guard let observers = engineObserverMap[.onSendMessageForUserDisableChanged] else { return }
        let param = [
            "roomId": roomId,
            "userId": userId,
            "muted": muted,
        ] as [String : Any]
        observers.forEach { responder in
            responder()?.onEngineEvent(name: .onSendMessageForUserDisableChanged, param: param)
        }
    }
    
    // MARK: - 信令请求相关回调
    func onRequestReceived(request: TUIRequest) {
        guard let observers = engineObserverMap[.onRequestReceived] else { return }
        let param = [
            "request": request,
        ] as [String : Any]
        observers.forEach { responder in
            responder()?.onEngineEvent(name: .onRequestReceived, param: param)
        }
    }
    
    func onRequestCancelled(requestId: String, userId: String) {
        guard let observers = engineObserverMap[.onRequestCancelled] else { return }
        let param = [
            "requestId": requestId,
            "userId": userId,
        ] as [String : Any]
        observers.forEach { responder in
            responder()?.onEngineEvent(name: .onRequestCancelled, param: param)
        }
    }
    
    // MARK: - 房间内消息事件回调
    func onReceiveTextMessage(roomId: String, message: TUIMessage) {
        guard let observers = engineObserverMap[.onReceiveTextMessage] else { return }
        let param = [
            "roomId": roomId,
            "message": message,
        ] as [String : Any]
        observers.forEach { responder in
            responder()?.onEngineEvent(name: .onReceiveTextMessage, param: param)
        }
    }
    
    func onReceiveCustomMessage(roomId: String, message: TUIMessage) {
        guard let observers = engineObserverMap[.onReceiveCustomMessage] else { return }
        let param = [
            "roomId": roomId,
            "message": message,
        ] as [String : Any]
        observers.forEach { responder in
            responder()?.onEngineEvent(name: .onReceiveCustomMessage, param: param)
        }
    }
}

private extension String {
    static var allMuteAudioText: String {
        localized("TUIRoom.all.mute.audio.prompt")
    }
    static var allMuteVideoText: String {
        localized("TUIRoom.all.mute.video.prompt")
    }
    static var allUnMuteAudioText: String {
        localized("TUIRoom.all.unmute.audio.prompt")
    }
    static var allUnMuteVideoText: String {
        localized("TUIRoom.all.unmute.video.prompt")
    }
}
