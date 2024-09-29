//
//  RoomSelector.swift
//  TUIRoomKit
//
//  Created by jeremiawang on 2024/8/19.
//

import Foundation

enum RoomSelectors {
    static let getRoomState = Selector(keyPath: \OperationState.roomState)
    
    static let getRoomId = Selector.with(getRoomState, keyPath:\RoomInfo.roomId)
    static let getIsEnteredRoom = Selector.with(getRoomState, keyPath:\RoomInfo.isEnteredRoom)
}
