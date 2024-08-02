//
//  ViewActions.swift
//  TUIRoomKit
//
//  Created by CY zhao on 2024/7/9.
//

import Foundation

enum ViewActions {
    static let key = "action.view"
    static let toastActionKey = key + ".showToast"
    
    static let showToast = ActionTemplate(id: toastActionKey, payloadType: ToastInfo.self)
}

enum ScheduleViewActions {
    static let key = ViewActions.key + ".scheduleView"
    
    static let refreshConferenceList = ActionTemplate(id: key.appending(".refreshConferenceList"))
    static let stopRefreshList = ActionTemplate(id: key.appending(".stopRefreshList"))
    
    static let popDetailView = ActionTemplate(id: key.appending(".popDetailView"))
    static let resetPopDetailFlag = ActionTemplate(id: key.appending(".resetPopDetailFlag"))
}

struct ToastInfo: Identifiable {
    enum Position {
        case center
        case bottom
    }
    let id: UUID
    let duration: TimeInterval
    let position: Position
    let message: String
    
    init(message: String, position: Position = .center, duration: TimeInterval = 1.5) {
        id = UUID()
        self.message = message
        self.position = position
        self.duration = duration
    }
}

extension ToastInfo: Equatable {
    static func ==(lhs: ToastInfo, rhs: ToastInfo) -> Bool{
        return lhs.id == rhs.id || lhs.message == rhs.message
    }
}
