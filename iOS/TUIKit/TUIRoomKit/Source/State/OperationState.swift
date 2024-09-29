//
//  OperationState.swift
//  TUIRoomKit
//
//  Created by CY zhao on 2024/6/12.
//

import Foundation

struct OperationState {
    var roomState = RoomInfo()
    var userState = UserState()
    var conferenceListState = ConferenceListState()
    var conferenceInvitationState = ConferenceInvitationState()
}
