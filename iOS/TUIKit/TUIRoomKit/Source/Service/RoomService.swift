//
//  RoomService.swift
//  TUIRoomKit
//
//  Created by CY zhao on 2024/7/2.
//

import Foundation
import RTCRoomEngine
import ImSDK_Plus
import Combine

class RoomService {
    private let engineManager = EngineManager.shared
    
    func enterRoom(roomId: String,
                   options: TUIEnterRoomOptions? = nil,
                   enableAudio: Bool,
                   enableVideo: Bool,
                   isSoundOnSpeaker: Bool) -> AnyPublisher<Void, RoomError> {
        return Future<Void, RoomError> { [weak self] promise in
            guard let self = self else { return }
            //TODO: use RTCRoomEngine directly
            self.engineManager.enterRoom(roomId: roomId,
                                         options: options,
                                         enableAudio: enableAudio,
                                         enableVideo: enableVideo,
                                         isSoundOnSpeaker: isSoundOnSpeaker) { roomInfo in
                promise(.success(()))
            } onError: { error, message in
                let error = RoomError(error: error, message: message)
                promise(.failure(error))
            }
        }
        .eraseToAnyPublisher()
    }
}
