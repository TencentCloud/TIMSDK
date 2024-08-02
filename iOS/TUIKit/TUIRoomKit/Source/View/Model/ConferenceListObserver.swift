//
//  ConferenceListManagerObserver.swift
//  TUIRoomKit
//
//  Created by janejntang on 2024/7/23.
//

import Foundation
import RTCRoomEngine

class ConferenceListObserver: NSObject, TUIConferenceListManagerObserver {
    private var roomInfo: TUIRoomInfo {
        EngineManager.shared.store.roomInfo
    }
    
    func onConferenceInfoChanged(conferenceInfo: TUIConferenceInfo, modifyFlag: TUIConferenceModifyFlag) {
        guard conferenceInfo.basicRoomInfo.roomId == roomInfo.roomId else { return }
        roomInfo.name = conferenceInfo.basicRoomInfo.name
        EngineEventCenter.shared.notifyEngineEvent(event: .onConferenceInfoChanged, param: ["conferenceInfo": conferenceInfo, "modifyFlag": modifyFlag])
    }
    
    func onConferenceScheduled(conferenceInfo: TUIConferenceInfo) {
        
    }
    
    func onConferenceWillStart(conferenceInfo: TUIConferenceInfo) {
        
    }
    
    func onConferenceCancelled(roomId: String, reason: TUIConferenceCancelReason, operateUser: TUIUserInfo) {
        
    }
    
    func onScheduleAttendeesChanged(roomId: String, leftUsers: [TUIUserInfo], joinedUsers: [TUIUserInfo]) {
        
    }
    
    func onConferenceStatusChanged(roomId: String, status: TUIConferenceStatus) {
        
    }
}
