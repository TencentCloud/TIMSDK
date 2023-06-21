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
        
        var userModels: [User] = Array()
        V2TIMManager.sharedInstance().getUsersInfo(userIDs) { imUserInfos in
            var userModel = User()
            guard let userInfos = imUserInfos else { return }
            for info in userInfos {
                userModel = convertUser(user: info)
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
}
