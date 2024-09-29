//
//  ConferenceInvitationState.swift
//  TUIRoomKit
//
//  Created by jeremiawang on 2024/8/19.
//

import RTCRoomEngine

struct ConferenceInvitationState {
    var invitationList: [TUIInvitation] = []
}

extension TUIInvitation {
    convenience init(userInfo: UserInfo) {
        self.init()
        self.invitee = TUIUserInfo()
        self.invitee.userId = userInfo.userId
        self.invitee.userName = userInfo.userName
        self.invitee.avatarUrl = userInfo.avatarUrl
    }
    
    static func ==(lhs: TUIInvitation, rhs: TUIInvitation) -> Bool {
        return lhs.status == rhs.status &&
        lhs.invitee.userId == rhs.invitee.userId &&
        lhs.invitee.userName == rhs.invitee.userName &&
        lhs.invitee.avatarUrl == rhs.invitee.avatarUrl
    }
}
