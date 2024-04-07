//
//  ConferenceSession.swift
//  TUIRoomKit
//
//  Created by 唐佳宁 on 2024/3/4.
//

import Foundation
import TUIRoomEngine

@objcMembers public class ConferenceSession: NSObject {
    public func quickStartConference(roomInfo: TUIRoomInfo, enableAudio: Bool, enableVideo: Bool, isSoundOnSpeaker: Bool, 
                                     onSuccess: @escaping TUISuccessBlock, onError: @escaping TUIErrorBlock) {
        EngineManager.createInstance().createRoom(roomInfo: roomInfo) {
            EngineManager.createInstance().enterRoom(roomId: roomInfo.roomId, enableAudio: enableAudio, enableVideo: enableVideo,
                                                     isSoundOnSpeaker: isSoundOnSpeaker) {
                onSuccess()
            } onError: { code, message in
                onError(code, message)
            }
        } onError: { code, message in
            onError(code, message)
        }
    }
    
    public func joinConference(roomId: String, enableAudio: Bool, enableVideo: Bool, isSoundOnSpeaker: Bool,
                               onSuccess: @escaping TUISuccessBlock, onError: @escaping TUIErrorBlock) {
        EngineManager.createInstance().enterRoom(roomId: roomId, enableAudio: enableAudio, enableVideo: enableVideo,
                                                 isSoundOnSpeaker: isSoundOnSpeaker, onSuccess: onSuccess, onError: onError)
    }
    
    deinit {
        debugPrint("deinit \(self)")
    }
}
