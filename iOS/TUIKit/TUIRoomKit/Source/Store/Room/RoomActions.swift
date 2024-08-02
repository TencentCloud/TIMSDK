//
//  RoomActions.swift
//  TUIRoomKit
//
//  Created by CY zhao on 2024/7/2.
//

import Foundation
import RTCRoomEngine

enum RoomActions {
    static let key = "action.room"
    
    static let joinConference = ActionTemplate(id: key.appending(".joinConference"), payloadType: (String).self)
    
    static let onJoinSuccess = ActionTemplate(id: key.appending(".onJoinSuccess"))
}
