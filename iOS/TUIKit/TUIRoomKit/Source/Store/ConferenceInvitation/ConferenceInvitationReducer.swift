//
//  ConferenceInvitationReducer.swift
//  TUIRoomKit
//
//  Created by jeremiawang on 2024/8/19.
//

import Foundation
import RTCRoomEngine

let ConferenceInvitationReducer = Reducer<ConferenceInvitationState>(
    ReduceOn(ConferenceInvitationActions.updateInvitationList, reduce: { state, action in
        let newInvitations: [TUIInvitation] = action.payload
        let previousInvitations = state.invitationList
        var existingIds = Set(previousInvitations.map { $0.invitee.userId })
        var combinedInvitations = previousInvitations
        for invitation in newInvitations {
            if !existingIds.contains(invitation.invitee.userId) {
                combinedInvitations.append(invitation)
                existingIds.insert(invitation.invitee.userId)
            }
        }
        state.invitationList = combinedInvitations
    }),
    ReduceOn(ConferenceInvitationActions.addInvitation, reduce: { state, action in
        let userIdToAdd = action.payload.invitee.userId
        if let index = state.invitationList.firstIndex(where: { $0.invitee.userId == userIdToAdd }) {
            state.invitationList[index] = action.payload
        } else {
            state.invitationList.insert(action.payload, at: 0)
        }
    }),
    ReduceOn(ConferenceInvitationActions.removeInvitation, reduce: { state, action in
        let userIdToRemove = action.payload
        if let index = state.invitationList.firstIndex(where: { $0.invitee.userId == userIdToRemove }) {
            state.invitationList.remove(at: index)
        }
    }),
    ReduceOn(ConferenceInvitationActions.changeInvitationStatus, reduce: { state, action in
        let userIdToChange = action.payload.invitee.userId
        if let index = state.invitationList.firstIndex(where: { $0.invitee.userId == userIdToChange }) {
            state.invitationList[index] = action.payload
        }
    }),
    ReduceOn(ConferenceInvitationActions.clearInvitationList, reduce: { state, action in
        state.invitationList.removeAll()
    })
)
