//
//  ErrorActions.swift
//  TUIRoomKit
//
//  Created by CY zhao on 2024/6/13.
//

import Foundation

enum ErrorActions {
    static let key = "action.error"
    static let throwError = ActionTemplate(id: key.appending(".throwError"), payloadType: RoomError.self)
}
