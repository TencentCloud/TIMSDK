//
//  User.swift
//  TUICallKit
//
//  Created by vincepzhang on 2023/1/6.
//

import Foundation
import ImSDK_Plus
import TUICallEngine
import TUICore

class User {

    let id: Observable<String> = Observable("")
    let nickname: Observable<String> = Observable("")
    let avatar: Observable<String> = Observable("")
    let remark: Observable<String> = Observable("")
    
    let callRole: Observable<TUICallRole> = Observable(.none)
    let callStatus: Observable<TUICallStatus> = Observable(.none)
    
    let audioAvailable: Observable<Bool> = Observable(false)
    let videoAvailable: Observable<Bool> = Observable(false)
    let playoutVolume: Observable<Float> = Observable(0)
    
    static func convertUserFromImFullInfo(user: V2TIMGroupMemberFullInfo) -> User {
        var dstUser = User()
        dstUser.nickname.value = user.nickName ?? ""
        dstUser.avatar.value = user.faceURL ?? ""
        dstUser.id.value = user.userID ?? ""
        return dstUser
    }
    
    static func convertUser(user: V2TIMUserInfo) -> User {
        return self.convertUser(user: user, volume: 0)
    }
    
    static func convertUser(user: V2TIMUserInfo, volume: Float) -> User {
        var dstUser = User()
        dstUser.nickname.value = user.nickName ?? ""
        dstUser.avatar.value = user.faceURL ?? ""
        dstUser.id.value = user.userID ?? ""
        dstUser.playoutVolume.value = volume
        return dstUser
    }
    
    static func getUserInfosFromIM(userIDs: [String], response: @escaping ([User]) -> Void ) {
        
        V2TIMManager.sharedInstance().getFriendsInfo(userIDs) { imFrientInfosOptional in
            guard let imFrientInfos = imFrientInfosOptional else { return }
            var userModels: [User] = Array()
            for imFriendInfo in imFrientInfos {
                let userModel = convertUser(user: imFriendInfo.friendInfo.userFullInfo)
                userModel.remark.value = imFriendInfo.friendInfo.friendRemark ?? ""
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
        User.getUserInfosFromIM(userIDs: [selfId]) { users in
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
