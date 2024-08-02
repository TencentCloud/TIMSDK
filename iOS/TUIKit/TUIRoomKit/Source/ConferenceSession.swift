//
//  ConferenceSession.swift
//  TUIRoomKit
//
//  Created by janejntang on 2024/3/6.
//

import RTCRoomEngine

class ConferenceSession {
    let conferenceId: String
    var conferenceParams: ConferenceParams = ConferenceParams()
    
    init(conferenceId: String) {
        self.conferenceId = conferenceId
    }
    
    func quickStart(onSuccess: @escaping TUISuccessBlock, onError: @escaping TUIErrorBlock) {
        let roomInfo = createRoomInfo(conferenceParams: conferenceParams)
        quickStartConference(roomInfo: roomInfo, enableAudio: !conferenceParams.isMuteMicrophone, enableVideo:
                                conferenceParams.isOpenCamera, isSoundOnSpeaker: conferenceParams.isSoundOnSpeaker, onSuccess: onSuccess, onError: onError)
    }
    
    private func quickStartConference(roomInfo: TUIRoomInfo, enableAudio: Bool, enableVideo: Bool, isSoundOnSpeaker: Bool, onSuccess: @escaping TUISuccessBlock, onError: @escaping TUIErrorBlock) {
        EngineManager.shared.createRoom(roomInfo: roomInfo) {
            EngineManager.shared.enterRoom(roomId: roomInfo.roomId, enableAudio: enableAudio, enableVideo: enableVideo,
                                                     isSoundOnSpeaker: isSoundOnSpeaker) {
                onSuccess()
            } onError: { code, message in
                onError(code, message)
            }
        } onError: { code, message in
            onError(code, message)
        }
        
    }
    
    func join(onSuccess: @escaping TUISuccessBlock, onError: @escaping TUIErrorBlock) {
        EngineManager.shared.enterRoom(roomId: conferenceId, enableAudio: !conferenceParams.isMuteMicrophone, enableVideo: conferenceParams.isOpenCamera, isSoundOnSpeaker: conferenceParams.isSoundOnSpeaker) {
            onSuccess()
        } onError: { code, message in
            onError(code, message)
        }
    }
    
    private func createRoomInfo(conferenceParams: ConferenceParams) -> TUIRoomInfo {
        let roomInfo = TUIRoomInfo()
        roomInfo.roomId = conferenceId
        roomInfo.isMicrophoneDisableForAllUser = !conferenceParams.enableMicrophoneForAllUser
        roomInfo.isCameraDisableForAllUser = !conferenceParams.enableCameraForAllUser
        roomInfo.isMessageDisableForAllUser = !conferenceParams.enableMessageForAllUser
        roomInfo.isSeatEnabled = conferenceParams.enableSeatControl
        roomInfo.name = conferenceParams.name ?? ""
        roomInfo.seatMode = .applyToTake
        return roomInfo
    }
    
    deinit {
        debugPrint("deinit \(self)")
    }
}
