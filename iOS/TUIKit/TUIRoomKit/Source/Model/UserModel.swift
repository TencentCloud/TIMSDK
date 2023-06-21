//
//  UserModel.swift
//  TUIRoomKit
//
//  Created by WesleyLei on 2022/9/26.
//  Copyright © 2022 Tencent. All rights reserved.
//

import Foundation
import TUIRoomEngine

class UserModel {
    private var userInfo: TUIUserInfo
    var isOnSeat: Bool //是否上麦
    var isMuteMessage: Bool //是否禁言
    var hasVideoStream: Bool {
        set {
            userInfo.hasVideoStream = newValue
        }
        get {
            return userInfo.hasVideoStream
        }
    }
    var hasAudioStream: Bool {
        set {
            userInfo.hasAudioStream = newValue
        }
        get {
            return userInfo.hasAudioStream
        }
    }
    var userId: String {
        set {
            userInfo.userId = newValue
        }
        get {
            return userInfo.userId
        }
    }
    var userName: String {
        set {
            userInfo.userName = newValue
        }
        get {
            return userInfo.userName
        }
    }
    var avatarUrl: String {
        set {
            userInfo.avatarUrl = newValue
        }
        get {
            return userInfo.avatarUrl
        }
    }
    var userRole: TUIRole {
        set {
            userInfo.userRole = newValue
        }
        get {
            return userInfo.userRole
        }
    }
    var hasScreenStream: Bool {
        set {
            userInfo.hasScreenStream = newValue
        }
        get {
            return userInfo.hasScreenStream
        }
    }
    
    init() {
        isOnSeat = false
        isMuteMessage = false
        userInfo = TUIUserInfo()
    }
    
    func update(userInfo: TUIUserInfo) {
        self.userInfo = userInfo
    }
    
    func updateLoginUserInfo(userInfo: TUILoginUserInfo) {
        userId = userInfo.userId
        userName = userInfo.userName
        avatarUrl = userInfo.avatarUrl
    }
    
    func getUserInfo() -> TUIUserInfo {
        return userInfo
    }
    
    deinit {
        debugPrint("deinit \(self)")
    }
}
