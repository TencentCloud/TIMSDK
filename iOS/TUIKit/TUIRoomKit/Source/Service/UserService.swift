//
//  UserService.swift
//  TUIRoomKit
//
//  Created by CY zhao on 2024/6/13.
//

import Foundation
import RTCRoomEngine
import ImSDK_Plus
import Combine

class UserService {
    private let engine = TUIRoomEngine.sharedInstance()
    private let imManager = V2TIMManager.sharedInstance()
    
    func fetchUserInfo(_ userId: String) -> AnyPublisher<UserInfo, RoomError> {
        return Future<UserInfo, RoomError> { [weak self] promise in
            guard let self = self else { return }
            self.engine.getUserInfo(userId) { userInfo in
                if let user = userInfo {
                    promise(.success(UserInfo(userInfo: user)))
                } else {
                    let error = RoomError(error: TUIError.userNotExist)
                    promise(.failure(error))
                }
            } onError: { err, message in
                let error = RoomError(error: err, message: message, showToast: false)
                promise(.failure(error))
            }
        }
        .eraseToAnyPublisher()
    }
}
