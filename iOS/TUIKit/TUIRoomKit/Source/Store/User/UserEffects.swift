//
//  UserEffects.swift
//  TUIRoomKit
//
//  Created by CY zhao on 2024/6/5.
//

import Foundation
import Combine
import ImSDK_Plus
import RTCRoomEngine

class UserEffects: Effects {
    typealias Environment = ServiceCenter
    
    let getSelfInfo = Effect<Environment>.dispatchingOne { actions, environment in
        actions
            .wasCreated(from: UserActions.getSelfInfo)
            .flatMap { action -> AnyPublisher<Action, Never> in
                let selfId = environment.store?.selectCurrent(UserSelectors.getSelfId) ?? ""
                return environment.userService.fetchUserInfo(selfId)
                    .map { userInfo in
                        return UserActions.updateSelfInfo(payload: userInfo)
                    }
                    .catch { error -> Just<Action> in
                       return Just(ErrorActions.throwError(payload: error))
                    }
                    .eraseToAnyPublisher()
            }
            .eraseToAnyPublisher()
    }
}
