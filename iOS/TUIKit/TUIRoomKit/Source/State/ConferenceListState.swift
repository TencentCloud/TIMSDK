//
//  ListState.swift
//  TUIRoomKit
//
//  Created by CY zhao on 2024/6/6.
//

import Foundation
import RTCRoomEngine

struct ConferenceListState {
    var scheduledConferences: [ConferenceInfo] = []
    var fetchScheduledConferencesCursor = ""
}

struct ConferenceInfo {
    var scheduleStartTime: UInt = 0
    var scheduleEndTime: UInt = 0
    var status: TUIConferenceStatus = []
    var timeZone: TimeZone = .current
    var attendeeListResult = AttendeeListResult()
    var durationTime: UInt = 0
    var isEncrypted: Bool = false
    // MARK: basic info
    var basicInfo = RoomInfo()
    
    init() {}
    
    init(with conferenceInfo: TUIConferenceInfo) {
        self.scheduleStartTime = conferenceInfo.scheduleStartTime
        self.scheduleEndTime = conferenceInfo.scheduleEndTime
        self.durationTime = self.scheduleEndTime - self.scheduleStartTime
        self.status = conferenceInfo.status
        self.basicInfo = RoomInfo(with: conferenceInfo.basicRoomInfo)
    }
}

extension ConferenceInfo: Hashable {
    static func ==(lhs: ConferenceInfo, rhs: ConferenceInfo) -> Bool {
        return lhs.basicInfo.roomId == rhs.basicInfo.roomId &&
        lhs.basicInfo.name == rhs.basicInfo.name &&
        lhs.scheduleStartTime == rhs.scheduleStartTime &&
        lhs.scheduleEndTime == rhs.scheduleEndTime &&
        lhs.status == rhs.status
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(basicInfo.roomId)
        hasher.combine(basicInfo.name)
        hasher.combine(scheduleStartTime)
        hasher.combine(scheduleEndTime)
        hasher.combine(status)
    }
}

struct AttendeeListResult: Hashable {
    var attendeeList: [UserInfo] = []
    var fetchCursor: String = ""
    var totalCount: UInt = 0
}

extension TUIConferenceInfo {
    convenience init(conferenceInfo: ConferenceInfo) {
        self.init()
        self.scheduleStartTime = UInt(conferenceInfo.scheduleStartTime)
        self.scheduleEndTime = self.scheduleStartTime + conferenceInfo.durationTime
        self.scheduleAttendees = conferenceInfo.attendeeListResult.attendeeList.map { $0.userId }
        self.basicRoomInfo =  TUIRoomInfo(roomInfo: conferenceInfo.basicInfo)
    }
}

extension TUIConferenceStatus: Hashable {
    public func hash(into hasher: inout Hasher) {
         hasher.combine(self.rawValue)
     }
}
