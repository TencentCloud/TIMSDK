//
//  ErrorService.swift
//  TUIRoomKit
//
//  Created by CY zhao on 2024/6/13.
//

import Foundation
import RTCRoomEngine

struct RoomError: Error {
    let error: TUIError
    let message: String
    var actions: [Action] = []
    
    init(error: TUIError, message: String = "", showToast: Bool = true) {
        self.error = error
        self.message = message
        if showToast {
            actions.append(ViewActions.showToast(payload: ToastInfo(message: message)))
        }
    }
}
