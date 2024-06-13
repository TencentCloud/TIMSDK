//
//  ConferenceObserver.swift
//  TUIRoomKit
//
//  Created by janejntang on 2024/3/15.
//

import Foundation

@objc public protocol ConferenceObserver {
    @objc optional func onConferenceStarted(conferenceId: String, error: ConferenceError)
    @objc optional func onConferenceJoined(conferenceId: String, error: ConferenceError)
    @objc optional func onConferenceFinished(conferenceId: String)
    @objc optional func onConferenceExited(conferenceId: String)
}
