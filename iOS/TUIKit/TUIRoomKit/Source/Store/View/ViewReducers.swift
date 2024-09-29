//
//  ViewReducers.swift
//  TUIRoomKit
//
//  Created by CY zhao on 2024/7/15.
//

import Foundation

let scheduleViewReducer = Reducer<ScheduleViewState>(
    ReduceOn(ScheduleViewActions.refreshConferenceList, reduce: { state, action in
        state.shouldRefreshList = true
    }),
    ReduceOn(ScheduleViewActions.stopRefreshList, reduce: { state, action in
        state.shouldRefreshList = false
    }),
    ReduceOn(ScheduleViewActions.popDetailView, reduce: { state, action in
        state.detailViewPopFlag = true
    }),
    ReduceOn(ScheduleViewActions.resetPopDetailFlag, reduce: { state, action in
        state.detailViewPopFlag = false
    })
)

let invitationViewReducer = Reducer<InvitationViewState> (
    ReduceOn(InvitationViewActions.dismissInvitationView, reduce: { state, action in
        state.invitationViewDismissFlag = true
    }),
    ReduceOn(InvitationViewActions.resetInvitationFlag, reduce: { state, action in
        state.invitationViewDismissFlag = false
    }),
    ReduceOn(InvitationViewActions.showInvitationPopupView, reduce: { state, action in
        state.showInvitationPopupView = true
    }),
    ReduceOn(InvitationViewActions.resetPopupViewFlag, reduce: { state, action in
        state.showInvitationPopupView = false
    })
)
