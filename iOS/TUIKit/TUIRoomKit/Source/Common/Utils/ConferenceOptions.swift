//
//  ConferenceSession.swift
//  TUIRoomKit
//
//  Created by janejntang on 2024/3/6.
//

import RTCRoomEngine

class ConferenceOptions {
    
    static func quickStart(startConferenceParams: StartConferenceParams,
                           onSuccess: TUIRoomInfoBlock? = nil,
                           onError: TUIErrorBlock? = nil) {
        let roomInfo = createRoomInfo(startConferenceParams: startConferenceParams)
        quickStartConference(roomInfo: roomInfo,
                             enableAudio: startConferenceParams.isOpenMicrophone,
                             enableVideo: startConferenceParams.isOpenCamera,
                             isSoundOnSpeaker: startConferenceParams.isOpenSpeaker,
                             onSuccess: onSuccess,
                             onError: onError)
    }
    
    private static func quickStartConference(roomInfo: TUIRoomInfo, 
                                             enableAudio: Bool,
                                             enableVideo: Bool,
                                             isSoundOnSpeaker: Bool,
                                             onSuccess: TUIRoomInfoBlock?,
                                             onError: TUIErrorBlock?) {
        EngineManager.shared.createRoom(roomInfo: roomInfo) {
            EngineManager.shared.enterRoom(roomId: roomInfo.roomId, 
                                           enableAudio: enableAudio,
                                           enableVideo: enableVideo,
                                           isSoundOnSpeaker: isSoundOnSpeaker) { roomInfo in
                onSuccess?(roomInfo)
            } onError: { code, message in
                onError?(code, message)
            }
        } onError: { code, message in
            onError?(code, message)
        }
        
    }
    
    static func join(joinConferenParams: JoinConferenceParams,
                     onSuccess: TUIRoomInfoBlock? = nil,
                     onError: TUIErrorBlock? = nil) {
        var options:TUIEnterRoomOptions?
        if let password = joinConferenParams.password, password.count > 0 {
            options = TUIEnterRoomOptions()
            options?.password = password
        }
        EngineManager.shared.enterRoom(roomId: joinConferenParams.roomId,
                                       options: options,
                                       enableAudio: joinConferenParams.isOpenMicrophone,
                                       enableVideo: joinConferenParams.isOpenCamera,
                                       isSoundOnSpeaker: joinConferenParams.isOpenSpeaker) { roomInfo in
            onSuccess?(roomInfo)
        } onError: { code, message in
            onError?(code, message)
        }
    }
    
    private static func createRoomInfo(startConferenceParams: StartConferenceParams) -> TUIRoomInfo {
        let roomInfo = TUIRoomInfo()
        roomInfo.roomId = startConferenceParams.roomId
        roomInfo.isMicrophoneDisableForAllUser = !startConferenceParams.isOpenMicrophone
        roomInfo.isCameraDisableForAllUser = !startConferenceParams.isOpenCamera
        roomInfo.isSeatEnabled = startConferenceParams.isSeatEnabled
        roomInfo.name = startConferenceParams.name ?? ""
        roomInfo.seatMode = .applyToTake
        return roomInfo
    }
    
    deinit {
        debugPrint("deinit \(self)")
    }
}
