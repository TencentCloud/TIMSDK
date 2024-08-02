//
//  UserActions.swift
//  TUIRoomKit
//
//  Created by CY zhao on 2024/6/5.
//

import RTCRoomEngine

enum UserActions {
    static let key = "action.user"
    static let getSelfInfo = ActionTemplate(id: key.appending(".getSelfInfo"))
    static let updateSelfInfo = ActionTemplate(id: key.appending(".updateSelfInfo"), payloadType: UserInfo.self)
    static let fetchUserInfo = ActionTemplate(id: key.appending(".fetchUserInfo"), payloadType: String.self)
}
