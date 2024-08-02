//
//  Conference.swift
//  TUIRoomKit
//
//  Created by CY zhao on 2024/6/12.
//

import Foundation

let ConferenceListReducer = Reducer<ConferenceListState>(
    ReduceOn(ConferenceListActions.updateConferenceList, reduce: { state, action in
        let incomingConferences = action.payload.0
        let previousConferences = state.scheduledConferences
        let combinedSet = Set(incomingConferences + previousConferences)
        state.scheduledConferences = Array(combinedSet)
        state.fetchScheduledConferencesCursor = action.payload.1
    }),
    ReduceOn(ConferenceListActions.insertConference, reduce: { state, action in
        if !state.scheduledConferences.contains(action.payload) {
            state.scheduledConferences.append(action.payload)
        }
    }),
    ReduceOn(ConferenceListActions.removeConference, reduce: { state, action in
        let conferenceToRemove = action.payload
        let conferences = state.scheduledConferences.map { $0.basicInfo.roomId }
        if let index = conferences.firstIndex(of: conferenceToRemove) {
            state.scheduledConferences.remove(at: index)
        }
    }),
    ReduceOn(ConferenceListActions.onConferenceUpdated, reduce: { state, action in
        let conference = action.payload
        if let index = state.scheduledConferences.firstIndex(where: { $0.basicInfo.roomId == conference.basicInfo.roomId }) {
            state.scheduledConferences[index] = conference
        }
    }),
    ReduceOn(ConferenceListActions.resetConferenceList, reduce: { state, action in
        state.scheduledConferences.removeAll()
    })
)
