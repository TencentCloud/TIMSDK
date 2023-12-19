//
//  SelectGroupMemberViewModel.swift
//  TUICallKit
//
//  Created by vincepzhang on 2023/5/15.
//

import Foundation
import ImSDK_Plus

class SelectGroupMemberViewModel {
    var selfUser: Observable<User> = Observable(User())
    var groupMemberList: Observable<[User]> = Observable([])
    var groupMemberState: [String: Bool] = [:]
    var groupMemberStateOrigin: [String: Bool] = [:]
    
    init() {
        updateUserState()
    }
    
    func updateUserState() {
        selfUser.value = TUICallState.instance.selfUser.value
        V2TIMManager.sharedInstance().getGroupMemberList(TUICallState.instance.groupId.value,
                                                         filter: .max,
                                                         nextSeq: 0) { [weak self] nextSeq, imUserInfoList in
            guard let self = self else { return }
            guard let imUserInfoList = imUserInfoList else { return }
            
            for imUserInfo in imUserInfoList {
                if imUserInfo.userID == self.selfUser.value.id.value {
                    continue
                }
                let user = User.convertUserFromImFullInfo(user: imUserInfo)
                self.groupMemberList.value.append(user)
                self.groupMemberState[user.id.value] = false
                self.groupMemberStateOrigin[user.id.value] = false
            }
            
            for user in TUICallState.instance.remoteUserList.value {
                self.groupMemberState[user.id.value] = true
                self.groupMemberStateOrigin[user.id.value] = true
            }
            
        } fail: { code, message in
            
        }
    }
}
