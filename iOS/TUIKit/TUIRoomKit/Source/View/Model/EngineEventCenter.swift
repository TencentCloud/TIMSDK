//
//  EngineEventCenter.swift
//  TUIRoomKit
//
//  Created by aby on 2023/1/8.
//  Copyright © 2023 Tencent. All rights reserved.
//

import Foundation
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

class EngineEventCenter: NSObject {
    
    // Weak Ref
    typealias WeakArray<T> = [() -> T?]
    static let shared = EngineEventCenter()
    private var engineObserverMap: [RoomEngineEvent: WeakArray<RoomEngineEventResponder>] = [:]
    private var uiEventObserverMap: [RoomUIEvent: [TUINotificationAdapter]] = [:]
    
    private override init() {
        super.init()
    }
    
    enum RoomEngineEvent: String {
        case onKickedOffLine
        case onRoomDismissed
        case onKickedOutOfRoom
        case onUserVideoStateChanged
        case onUserAudioStateChanged
        case onUserVoiceVolumeChanged
        case onUserScreenCaptureStopped
        case onRequestReceived
        case onSendMessageForUserDisableChanged
        case onRemoteUserEnterRoom
        case onRemoteUserLeaveRoom
        case onUserRoleChanged
        case onSeatListChanged
        case onAllUserCameraDisableChanged
        case onAllUserMicrophoneDisableChanged
        case onKickedOffSeat
        case onStatistics
        case onDeletedTakeSeatRequest
        case onExitedRoom
        case onDestroyedRoom
        case onStartedRoom
        case onJoinedRoom
        case onConferenceInfoChanged
        case onInitialSelfUserInfo
        case onInitialRoomInfo
        case onGetUserListFinished
    }
    
    enum RoomUIEvent: String {
        case TUIRoomKitService
        case TUIRoomKitService_RenewUserList
        case TUIRoomKitService_SomeoneSharing
        case TUIRoomKitService_RenewSeatList
        case TUIRoomKitService_UserOnSeatChanged
        case TUIRoomKitService_ShowRoomMainView
        case TUIRoomKitService_ShowRoomVideoFloatView
        case TUIRoomKitService_CurrentUserHasAudioStream
        case TUIRoomKitService_CurrentUserHasVideoStream
        case TUIRoomKitService_CurrentUserRoleChanged
        case TUIRoomKitService_CurrentUserMuteMessage
        case TUIRoomKitService_RoomOwnerChanged
        case TUIRoomKitService_ChangeToolBarHiddenState
        case TUIRoomKitService_SetToolBarDelayHidden
        case TUIRoomKitService_HiddenChatWindow
        case TUIRoomKitService_ShowExitRoomView
        case TUIRoomKitService_RenewVideoSeatView
        case TUIRoomKitService_DismissConferenceViewController
        case TUIRoomKitService_ShowFloatChatView
    }
    
    func subscribeUIEvent(key: RoomUIEvent, responder: RoomKitUIEventResponder) {
        let observer = TUINotificationAdapter(responder: responder)
        if var observerArray = uiEventObserverMap[key] {
            observerArray.append(observer)
            uiEventObserverMap[key] = observerArray
        } else {
            uiEventObserverMap[key] = [observer]
        }
        DispatchQueue.main.async {
            TUICore.registerEvent(RoomUIEvent.TUIRoomKitService.rawValue, subKey: key.rawValue, object: observer)
        }
    }
    
    func unsubscribeUIEvent(key: RoomUIEvent, responder: RoomKitUIEventResponder) {
        guard var observerArray = uiEventObserverMap[key] else { return }
        observerArray = observerArray.filter({ observer in
            guard let responderValue = observer.responder else {
                DispatchQueue.main.async {
                    TUICore.unRegisterEvent(RoomUIEvent.TUIRoomKitService.rawValue, subKey: key.rawValue, object: observer)
                }
                return false
            }
            if responderValue.isEqual(responder) {
                DispatchQueue.main.async {
                    TUICore.unRegisterEvent(RoomUIEvent.TUIRoomKitService.rawValue, subKey: key.rawValue, object: observer)
                }
                return false
            } else {
                return true
            }
        })
        if observerArray.count == 0 {
            uiEventObserverMap.removeValue(forKey: key)
        } else {
            uiEventObserverMap[key] = observerArray
        }
    }
    
    func notifyUIEvent(key: RoomUIEvent, param: [AnyHashable : Any]) {
        DispatchQueue.main.async {
            TUICore.notifyEvent(RoomUIEvent.TUIRoomKitService.rawValue, subKey: key.rawValue, object: nil, param: param)
        }
    }
    
    func subscribeEngine(event: RoomEngineEvent, observer: RoomEngineEventResponder) {
        let weakObserver = { [weak observer] in return observer }
        if var observerArray = engineObserverMap[event] {
            let listenerObject = observerArray.first { weakObject in
                guard let object = weakObject() else { return false }
                return object.isEqual(observer)
            }
            guard listenerObject == nil else { return }
            observerArray.append(weakObserver)
            engineObserverMap[event] = observerArray
        } else {
            engineObserverMap[event] = [weakObserver]
        }
    }

    func unsubscribeEngine(event: RoomEngineEvent, observer: RoomEngineEventResponder) {
        guard var observerArray = engineObserverMap[event] else { return }
        observerArray.removeAll { weakObject in
            guard let object = weakObject() else { return true }
            return object.isEqual(observer)
        }
        if observerArray.count == 0 {
            engineObserverMap.removeValue(forKey: event)
        } else {
            engineObserverMap[event] = observerArray
        }
    }
    
    func notifyEngineEvent(event: RoomEngineEvent, param: [String : Any]) {
        guard let observers = engineObserverMap[event] else { return }
        observers.forEach { responder in
            responder()?.onEngineEvent(name: event, param: param)
        }
    }
    
    deinit {
        debugPrint("deinit \(self)")
    }
}
