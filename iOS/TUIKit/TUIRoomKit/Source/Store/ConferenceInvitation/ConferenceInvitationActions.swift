//
//  ConferenceInvitationActions.swift
//  TUIRoomKit
//
//  Created by jeremiawang on 2024/8/12.
//

import Foundation
import RTCRoomEngine

enum ConferenceInvitationActions {
    static let key = "action.conferenceInvitation"

    static let inviteUsers = ActionTemplate(id: key.appending(".inviteUsers"),
                                            payloadType: (String, [String]).self)
    static let accept = ActionTemplate(id: key.appending(".accept"), payloadType: String.self)
    static let reject = ActionTemplate(id: key.appending(".reject"), payloadType: (String, TUIInvitationRejectedReason).self)
    static let getInvitationList = ActionTemplate(id: key.appending(".getInvitationList"), payloadType: (String, String, [TUIInvitation]).self)
    static let fetchAttendees = ActionTemplate(id: key.appending(".fetchAttendees"), payloadType: (String, String, [UserInfo]).self)
    static let clearInvitationList = ActionTemplate(id: key.appending(".fetchAttendees"))
    
    // MARK: callback
    static let updateInvitationList = ActionTemplate(id: key.appending(".setInvitationList"), payloadType: [TUIInvitation].self)
    static let addInvitation = ActionTemplate(id: key.appending(".addInvitation"), payloadType: TUIInvitation.self)
    static let removeInvitation = ActionTemplate(id: key.appending(".addInvitation"), payloadType: String.self)
    static let changeInvitationStatus = ActionTemplate(id: key.appending(".addInvitation"), payloadType: TUIInvitation.self)
    static let onInviteSuccess = ActionTemplate(id: key.appending("onInviteSuccess"))
    static let onAcceptSuccess = ActionTemplate(id: key.appending("onAcceptSuccess"), payloadType: String.self)
    static let onRejectSuccess = ActionTemplate(id: key.appending("onRejectSuccess"))
    static let onReceiveInvitation = ActionTemplate(id: key.appending("onAcceptSuccess"), payloadType: (TUIRoomInfo, TUIInvitation).self)
    static let onGetInvitationSuccess = ActionTemplate(id: key.appending("onGetInvitationSuccess"), payloadType: (String, [TUIInvitation]).self)
    static let onFetchAttendeesSuccess = ActionTemplate(id: key.appending("onFetchAttendeesSuccess"), payloadType: [UserInfo].self)
}
