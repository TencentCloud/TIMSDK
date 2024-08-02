//
//  ConferenceListActions.swift
//  TUIRoomKit
//
//  Created by CY zhao on 2024/6/12.
//

import Foundation
import RTCRoomEngine

enum ConferenceListActions {
    static let key = "action.conferenceList"
    
    static let fetchConferenceList = ActionTemplate(id: key.appending(".fetchConferenceList"),
                                                    payloadType: (String, Int).self)
    static let scheduleConference = ActionTemplate(id: key.appending(".scheduleConference"), 
                                                   payloadType: TUIConferenceInfo.self)
    static let cancelConference = ActionTemplate(id: key.appending(".cancelConference"), 
                                                 payloadType: String.self)
    static let updateConferenceInfo = ActionTemplate(id: key.appending(".updateConferenceInfo"),
                                                     payloadType: (TUIConferenceInfo, TUIConferenceModifyFlag).self)
    static let addAttendeesByAdmin = ActionTemplate(id: key.appending(".addAttendeesByAdmin"),
                                                    payloadType: (String, [String]).self)
    static let removeAttendeesByAdmin = ActionTemplate(id: key.appending(".removeAttendeesByAdmin"),
                                                       payloadType: (String, [String]).self)
    
    static let resetConferenceList = ActionTemplate(id: key.appending(".resetConferenceList"))
        
    // MARK: callback
    static let updateConferenceList = ActionTemplate(id: key.appending(".updateConferenceList"), payloadType: ([ConferenceInfo], String).self)
    static let insertConference = ActionTemplate(id: key.appending(".insertConference"), payloadType: ConferenceInfo.self)
    static let removeConference = ActionTemplate(id: key.appending(".removeConference"), payloadType: String.self)
    static let onConferenceUpdated = ActionTemplate(id: key.appending(".onConferenceUpdated"), payloadType: ConferenceInfo.self)
    static let onScheduleSuccess = ActionTemplate(id: key.appending("onScheduleSuccess"), payloadType: String.self)
    static let onCancelSuccess = ActionTemplate(id: key.appending("onCancelSuccess"))
    
    static let onUpdateInfoSuccess = ActionTemplate(id: key.appending("onUpdateInfoSuccess"))
    static let onAddAttendeesSuccess = ActionTemplate(id: key.appending("onAddAttendeesSuccess"))
    static let onRemoveAttendeesSuccess = ActionTemplate(id: key.appending("onRemoveAttendeesSuccess"))
}

// MARK: - Subject action, only event, no reduce.
enum ScheduleResponseActions {
    static let key = "action.schedule.response"
    static let onScheduleSuccess = ActionTemplate(id: key.appending("onScheduleSuccess"), payloadType: String.self)
    static let onCancelSuccess = ActionTemplate(id: key.appending("onScheduleSuccess"))
    static let onUpdateInfoSuccess = ActionTemplate(id: key.appending("onUpdateInfoSuccess"))
}
