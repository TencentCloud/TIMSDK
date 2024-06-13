//
//  VideoSeatItem.swift
//  TUIVideoSeat
//
//  Created by jack on 2023/3/6.
//  Copyright © 2023 Tencent. All rights reserved.

import Foundation
import RTCRoomEngine

class VideoSeatItem: Equatable {
    static func == (lhs: VideoSeatItem, rhs: VideoSeatItem) -> Bool {
        let lhsType = lhs.videoStreamType == .screenStream
        let rhsType = rhs.videoStreamType == .screenStream
        return (lhs.userId == rhs.userId) && (lhsType == rhsType)
    }
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
    var isHasVideoStream: Bool {
        return hasVideoStream || videoStreamType == .screenStream
    }
    func update(userInfo: UserEntity) {
        userId = userInfo.userId
        userName = userInfo.userName
        avatarUrl = userInfo.avatarUrl
        userRole = userInfo.userRole
        hasAudioStream = userInfo.hasAudioStream
        hasVideoStream = userInfo.hasVideoStream
    }
}
