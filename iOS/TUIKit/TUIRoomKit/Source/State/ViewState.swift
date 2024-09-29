//
//  ViewState.swift
//  TUIRoomKit
//
//  Created by CY zhao on 2024/7/15.
//

import Foundation

struct ViewState {
    var scheduleViewState = ScheduleViewState()
    var invitationViewState = InvitationViewState()
}

struct ScheduleViewState {
    var shouldRefreshList = false
    var detailViewPopFlag = false
}

struct InvitationViewState {
    var invitationViewDismissFlag = true
    var showInvitationPopupView = false
}
