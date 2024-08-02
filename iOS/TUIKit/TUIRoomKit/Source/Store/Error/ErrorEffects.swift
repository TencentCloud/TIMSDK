//
//  ErrorEffects.swift
//  TUIRoomKit
//
//  Created by CY zhao on 2024/7/8.
//

import Foundation

class ErrorEffects: Effects {
    typealias Environment = ServiceCenter
    
    let throwError = Effect<Environment>.nonDispatching { actions, environment in
        actions
            .wasCreated(from: ErrorActions.throwError)
            .sink { action in
                environment.store?.errorSubject.send(action.payload)
            }
    }
}
