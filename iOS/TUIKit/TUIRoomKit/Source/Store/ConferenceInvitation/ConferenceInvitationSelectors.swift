//
//  ConferenceInvitationSelector.swift
//  TUIRoomKit
//
//  Created by jeremiawang on 2024/8/19.
//

import Foundation

enum ConferenceInvitationSelectors {
    static let getConferenceInvitationState = Selector(keyPath: \OperationState.conferenceInvitationState)
    
    static let getInvitationList = Selector.with(getConferenceInvitationState, keyPath:\ConferenceInvitationState.invitationList)
}
