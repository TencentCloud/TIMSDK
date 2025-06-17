//
//  UserManager.swift
//  Pods
//
//  Created by vincepzhang on 2025/2/25.
//

import TUICore

class UserManager: NSObject {
    static let shared = UserManager()
    private override init() {}
    
    func setUserViewIndex(user: User, index: Int) {
        user.multiCallCellViewIndex = index
    }
    
    static func convertUserFromImFullInfo(user: V2TIMGroupMemberFullInfo) -> User {
        let dstUser = User()
        dstUser.nickname.value = user.nickName ?? ""
        dstUser.avatar.value = user.faceURL ?? ""
        dstUser.id.value = user.userID ?? ""
        return dstUser
    }
    
    static func convertUser(user: V2TIMUserInfo) -> User {
        return self.convertUser(user: user, volume: 0)
    }
    
    static func convertUser(user: V2TIMUserInfo, volume: Float) -> User {
        let dstUser = User()
        dstUser.nickname.value = user.nickName ?? ""
        dstUser.avatar.value = user.faceURL ?? ""
        dstUser.id.value = user.userID ?? ""
        dstUser.playoutVolume.value = volume
        return dstUser
    }
    
    static func getUserInfosFromIM(userIDs: [String], response: @escaping ([User]) -> Void ) {
        V2TIMManager.sharedInstance().getFriendsInfo(userIDs) { friendInfosOptional in
            guard let friendInfos = friendInfosOptional else { return }
            var userModels: [User] = Array()
            for friendInfo in friendInfos {
                let userModel = convertUser(user: friendInfo.friendInfo.userFullInfo)
                userModel.remark.value = friendInfo.friendInfo.friendRemark ?? ""
                userModels.append(userModel)
            }
            response(userModels)
        } fail: { code, message in
            print("getUsersInfo file code:\(code) message:\(message ?? "")  ")
        }
    }
    
    static func getSelfUserInfo(response: @escaping (User) -> Void ){
        guard let selfId = TUILogin.getUserID() else { return }
        var selfInfo = User()
        UserManager.getUserInfosFromIM(userIDs: [selfId]) { users in
            if let user = users.first {
                selfInfo = user
                response(selfInfo)
            }
        }
    }
    
    static func getUserDisplayName(user: User) -> String {
        if !user.remark.value.isEmpty {
            return user.remark.value
        }
        
        if !user.nickname.value.isEmpty {
            return user.nickname.value
        }
        return user.id.value
    }
}
