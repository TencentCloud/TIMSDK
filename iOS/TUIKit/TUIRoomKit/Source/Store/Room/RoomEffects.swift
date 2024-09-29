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

    let joinConference = Effect<Environment>.nonDispatching { actions, environment in
        actions.wasCreated(from: RoomActions.joinConference)
            .sink { action in
                let joinParams = JoinConferenceParams(roomId: action.payload)
                joinParams.isOpenMicrophone = true
                joinParams.isOpenCamera = false
                joinParams.isOpenSpeaker = true
                environment.navigator?.pushTo(route: .main(conferenceParams: ConferenceParamType(joinParams: joinParams)))
            }
    }

}
