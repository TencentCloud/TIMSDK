//
//  LocalAudioViewModel.swift
//  TUIRoomKit
//
//  Created by 唐佳宁 on 2024/1/5.
//

import Foundation
import TUIRoomEngine

protocol LocalAudioViewModelResponder: AnyObject {
    func updateMuteAudioButton(isSelected: Bool)
    func makeToast(text: String)
    func show()
    func hide()
}

class LocalAudioViewModel: NSObject {
    weak var viewResponder: LocalAudioViewModelResponder?
    var engineManager: EngineManager {
        EngineManager.createInstance()
    }
    var roomInfo: TUIRoomInfo {
        engineManager.store.roomInfo
    }
    var currentUser: UserEntity {
        engineManager.store.currentUser
    }
    var ableDisplay: Bool = false
    
    override init() {
        super.init()
        subscribeUIEvent()
    }
    
    deinit {
        unsubscribeUIEvent()
    }
    
    private func subscribeUIEvent() {
        EngineEventCenter.shared.subscribeUIEvent(key: .TUIRoomKitService_CurrentUserHasAudioStream, responder: self)
        EngineEventCenter.shared.subscribeUIEvent(key: .TUIRoomKitService_CurrentUserRoleChanged, responder: self)
        EngineEventCenter.shared.subscribeUIEvent(key: .TUIRoomKitService_UserOnSeatChanged, responder: self)
    }
    
    private func unsubscribeUIEvent() {
        EngineEventCenter.shared.unsubscribeUIEvent(key: .TUIRoomKitService_CurrentUserHasAudioStream, responder: self)
        EngineEventCenter.shared.unsubscribeUIEvent(key: .TUIRoomKitService_CurrentUserRoleChanged, responder: self)
        EngineEventCenter.shared.unsubscribeUIEvent(key: .TUIRoomKitService_UserOnSeatChanged, responder: self)
    }
    
    func showLocalAudioView() {
        ableDisplay = true
        guard !checkMuteAudioHiddenState() else { return }
        viewResponder?.show()
    }
    
    func hideLocalAudioView() {
        ableDisplay = false
        viewResponder?.hide()
    }
    
    func muteAudioAction() {
        if currentUser.hasAudioStream {
            engineManager.muteLocalAudio()
            return
        }
        //如果房主全体静音，房间成员不可打开麦克风
        if self.roomInfo.isMicrophoneDisableForAllUser && self.currentUser.userId != roomInfo.ownerId {
            viewResponder?.makeToast(text: .muteAudioRoomReasonText)
            return
        }
        //如果是举手发言房间，并且没有上麦，不可打开麦克风
        if roomInfo.isSeatEnabled, !currentUser.isOnSeat {
            viewResponder?.makeToast(text: .muteSeatReasonText)
            return
        }
        engineManager.unmuteLocalAudio()
        guard !engineManager.store.audioSetting.isMicOpened else { return }
        engineManager.openLocalMicrophone()
    }
    
    func checkMuteAudioHiddenState() -> Bool {
        //举手发言房间，没有上麦的普通观众不显示麦克风
        return roomInfo.isSeatEnabled && currentUser.userRole == .generalUser &&
        !currentUser.isOnSeat
    }
    
    func checkMuteAudioSelectedState() -> Bool {
        return !currentUser.hasAudioStream
    }
}

extension LocalAudioViewModel: RoomKitUIEventResponder {
    func onNotifyUIEvent(key: EngineEventCenter.RoomUIEvent, Object: Any?, info: [AnyHashable : Any]?) {
        switch key {
        case .TUIRoomKitService_CurrentUserHasAudioStream:
            viewResponder?.updateMuteAudioButton(isSelected: checkMuteAudioSelectedState())
        case .TUIRoomKitService_CurrentUserRoleChanged, .TUIRoomKitService_UserOnSeatChanged:
            if ableDisplay, !checkMuteAudioHiddenState() {
                viewResponder?.show()
            } else {
                viewResponder?.hide()
            }
        default: break
        }
    }
}

private extension String {
    static var muteAudioRoomReasonText: String {
        localized("TUIRoom.mute.audio.room.reason")
    }
    static var muteSeatReasonText: String {
        localized("TUIRoom.mute.seat.reason")
    }
}

