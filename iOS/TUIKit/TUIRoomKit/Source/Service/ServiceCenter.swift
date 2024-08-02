//
//  ServiceCenter.swift
//  TUIRoomKit
//
//  Created by CY zhao on 2024/6/12.
//

import Foundation
import Factory
import RTCRoomEngine
import Combine

class ServiceCenter: NSObject {
    @WeakLazyInjected(\.conferenceStore) var store: ConferenceStore?
    @WeakLazyInjected(\.navigation) var navigator: Route?
    
    let userService = UserService()
    let conferenceListService = ConferenceListService()
    let roomService = RoomService()
}

