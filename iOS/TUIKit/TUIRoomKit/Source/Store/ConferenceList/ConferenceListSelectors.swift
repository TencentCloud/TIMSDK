//
//  ConferenceListSelectors.swift
//  TUIRoomKit
//
//  Created by CY zhao on 2024/6/12.
//

import Foundation

enum ConferenceListSelectors {
    static let getConferenceListState = Selector(keyPath: \OperationState.conferenceListState)
    
    static let getConferenceList = Selector.with(getConferenceListState, keyPath:\ConferenceListState.scheduledConferences)
    static let getConferenceListCursor = Selector.with(getConferenceListState, keyPath:\ConferenceListState.fetchScheduledConferencesCursor)
}
