//
//  LocalAudioViewModel.swift
//  TUIRoomKit
//
//  Created by janejntang on 2024/1/5.
//

import Foundation
import RTCRoomEngine

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
        //If all hosts are muted, room members cannot turn on their microphones
        if self.roomInfo.isMicrophoneDisableForAllUser && self.currentUser.userId != roomInfo.ownerId {
            viewResponder?.makeToast(text: .muteAudioRoomReasonText)
            return
        }
        //If you are speaking in a room with your hand raised and you are not on the microphone, you cannot turn on the microphone.
        if roomInfo.isSeatEnabled, !currentUser.isOnSeat {
            viewResponder?.makeToast(text: .muteSeatReasonText)
            return
        }
        engineManager.unmuteLocalAudio()
        guard !engineManager.store.audioSetting.isMicOpened else { return }
        engineManager.openLocalMicrophone()
    }
    
    func checkMuteAudioHiddenState() -> Bool {
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
        localized("All on mute audio, unable to turn on microphone")
    }
    static var muteSeatReasonText: String {
        localized("Can be turned on after taking the stage")
    }
}

