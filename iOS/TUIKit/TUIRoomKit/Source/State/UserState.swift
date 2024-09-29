//
//  UserState.swift
//  TUIRoomKit
//
//  Created by CY zhao on 2024/6/5.
//

import Foundation
import RTCRoomEngine

struct UserState {
    var selfInfo: UserInfo = UserInfo()
    var allUsers: [UserInfo] = []
    
    var hasAudioStreamUsers = Set<String>()
    var hasCameraStreamUsers = Set<String>()
    var hasScreenStreamUsers = Set<String>()
    var disableMessageUsers = Set<String>()
}

struct UserInfo: Codable {
    var userId: String = ""
    var userName: String = ""
    var avatarUrl: String = ""
    var userRole: TUIRole? = .generalUser
    
    init() {}
    
    init(loginUserInfo: TUILoginUserInfo) {
        self.userId = loginUserInfo.userId
        self.userName = loginUserInfo.userName
        self.avatarUrl = loginUserInfo.avatarUrl
    }
    
    init(userInfo: TUIUserInfo) {
        self.userId = userInfo.userId
        self.userName = userInfo.userName
        self.avatarUrl = userInfo.avatarUrl
        self.userRole = userInfo.userRole
    }
    
    init(userEntity: UserEntity) {
        self.userId = userEntity.userId
        self.userName = userEntity.userName
        self.avatarUrl = userEntity.avatarUrl
        self.userRole = userEntity.userRole
    }
}

enum UserListType {
    case allUsers
    case onStageUsers
    case offStageUsers
    case notInRoomUsers
}

extension UserInfo: Hashable {
    static func == (lhs: UserInfo, rhs: UserInfo) -> Bool {
        return  lhs.userId == rhs.userId && lhs.userName == rhs.userName && lhs.avatarUrl == rhs.avatarUrl
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(userId)
        hasher.combine(userName)
        hasher.combine(avatarUrl)
        hasher.combine(userRole)
    }
}

extension UserInfo {
    func convertToUser() -> User {
        return User(self)
    }
}

extension TUIRole: Codable {
    public init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        let rawValue = try container.decode(UInt.self)
        self = TUIRole(rawValue: rawValue) ?? .generalUser
    }
    
    public func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        try container.encode(self.rawValue)
    }
}

@objc public class User: NSObject, Codable {
    private(set) var userInfo: UserInfo
    
    @objc public var userId: String {
        get { return userInfo.userId}
    }
    @objc public var userName: String {
        get { return userInfo.userName}
    }
    @objc public var avatarUrl: String {
        get { return userInfo.avatarUrl}
    }
    
    @objc public init(userId: String, userName: String, avatarUrl: String) {
        var info = UserInfo()
        info.userId = userId
        info.userName = userName
        info.avatarUrl = avatarUrl
        self.userInfo = info
        super.init()
    }
    
    init(_ userInfo: UserInfo) {
        self.userInfo = userInfo
        super.init()
    }
    
    public required init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        self.userInfo = try container.decode(UserInfo.self)
    }
    
    public func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        try container.encode(userInfo)
    }
    
    @objc public func setUserId(_ userId: String) {
        userInfo.userId = userId
    }
    @objc public func setUserName(_ userName: String) {
        userInfo.userName = userName
    }
    @objc public func setAvatarUrl(_ avatarUrl: String) {
        userInfo.avatarUrl = avatarUrl
    }

}

@objc public class ConferenceParticipants: NSObject {
    @objc public var selectedList: [User] = []
    @objc public var unSelectableList : [User] = []
    
    @objc public init(selectedList: [User] = [], unSelectableList: [User] = []) {
        self.selectedList = selectedList
        self.unSelectableList = unSelectableList
        super.init()
    }
}
