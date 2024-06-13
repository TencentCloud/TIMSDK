//
//  FloatChatState.swift
//  TUIRoomKit
//
//  Created by aby on 2024/5/17.
//

import Foundation
import RTCRoomEngine
import ImSDK_Plus

struct FloatChatState: Codable {
    var isFloatInputViewShow = false
    var roomId: String = ""
    var messageList = [FloatChatMessage]()
}

struct FloatChatMessage: Codable, Equatable {
    var user = FloatChatUser()
    var content: String = ""
    var extInfo: [String: AnyCodable] = [:]
    
    init() {}
    
    init(with message: TUIMessage) {
        self.user = FloatChatUser(userId: message.userId, userName: message.userName, avatarUrl: message.avatarURL)
        self.content = message.message
    }
    
    init(user: FloatChatUser, content: String) {
        self.user = user
        self.content = content
    }
}

struct FloatChatUser: Codable, Equatable {
    var userId: String = ""
    var userName: String = ""
    var avatarUrl: String?
    
    init() {}
    
    init(loginInfo: TUILoginUserInfo) {
        self.userId = loginInfo.userId
        self.userName = loginInfo.userName
        self.avatarUrl = loginInfo.avatarUrl
    }
    
    init(userId: String, userName: String, avatarUrl: String?) {
        self.userId = userId
        self.userName = userName
        self.avatarUrl = avatarUrl
    }
    
    init(memberInfo: V2TIMGroupMemberInfo) {
        self.userId = memberInfo.userID ?? ""
        self.userName = memberInfo.nickName ?? userId
        self.avatarUrl = memberInfo.faceURL
    }
}
