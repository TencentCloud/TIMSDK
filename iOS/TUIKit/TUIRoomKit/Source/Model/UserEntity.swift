//
//  UserEntity.swift
//  TUIRoomKit
//
//  Created by WesleyLei on 2022/9/26.
//  Copyright © 2022 Tencent. All rights reserved.
//

import Foundation
import TUIRoomEngine

class UserEntity {
    var userId: String = ""
    var userName: String = ""
    var avatarUrl: String = ""
    var userRole: TUIRole = .generalUser
    var userVoiceVolume: Int = 0
    var hasAudioStream: Bool = false
    var hasVideoStream: Bool = false
    var videoStreamType: TUIVideoStreamType = .cameraStream
    var isOnSeat: Bool = false
    var disableSendingMessage: Bool = false
    var hasScreenStream: Bool = false
    func update(userInfo: TUIUserInfo) {
        userId = userInfo.userId
        userName = userInfo.userName
        avatarUrl = userInfo.avatarUrl
        userRole = userInfo.userRole
        hasAudioStream = userInfo.hasAudioStream
        hasVideoStream = userInfo.hasVideoStream
        hasScreenStream = userInfo.hasScreenStream
    }
    
    deinit {
        debugPrint("deinit \(self)")
    }
}
