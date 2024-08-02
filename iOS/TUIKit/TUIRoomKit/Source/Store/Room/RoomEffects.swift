//
//  RoomEffects.swift
//  TUIRoomKit
//
//  Created by CY zhao on 2024/7/2.
//

import Combine
import Foundation
import RTCRoomEngine

class RoomEffects: Effects {
    typealias Environment = ServiceCenter

    let joinConference = Effect<Environment>.dispatchingOne { actions, environment in
        actions
            .wasCreated(from: RoomActions.joinConference)
            .flatMap { action in
                environment.roomService.enterRoom(roomId: action.payload,
                                             enableAudio: true,
                                             enableVideo: false,
                                             isSoundOnSpeaker: true)
                .map { _ in
                    environment.navigator?.pushTo(route: .main)
                    environment.store?.dispatch(action: ScheduleViewActions.popDetailView())
                    return RoomActions.onJoinSuccess()
                }
                .catch { error -> Just<Action> in
                    environment.store?.dispatch(action: ScheduleViewActions.popDetailView())
                    if error.error == TUIError.roomIdNotExist {
                        environment.store?.dispatch(action: ScheduleViewActions.refreshConferenceList())
                    }
                    return Just(ErrorActions.throwError(payload: error))
                }
            }
            .eraseToAnyPublisher()
    }
}
