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
