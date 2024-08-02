//
//  ConferenceError.swift
//  TUIRoomKit
//
//  Created by janejntang on 2024/3/14.
//

import Foundation

@objc public enum ConferenceError: Int {
    case success = 0
    case failed = -1
    case conferenceIdNotExist = -2100
    case conferenceIdInvalid = -2105
    case conferenceIdOccupied = -2106
    case conferenceNameInvalid = -2107
}

@objc public protocol ConferenceObserver {
    @objc optional func onConferenceStarted(conferenceId: String, error: ConferenceError)
    @objc optional func onConferenceJoined(conferenceId: String, error: ConferenceError)
    @objc optional func onConferenceFinished(conferenceId: String)
    @objc optional func onConferenceExited(conferenceId: String)
}
