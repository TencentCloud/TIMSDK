//
//  TUICallEvent.swift
//  TUICallKit
//
//  Created by vincepzhang on 2023/4/3.
//

let EVENT_KEY_USER_ID = "userId"
let EVENT_KEY_CODE = "code"
let EVENT_KEY_MESSAGE = "message"

public class TUICallEvent {
    enum EventType {
        case ERROR
        case TIP
        case UNKNOWN
    }

    enum Event {
        case USER_REJECT
        case USER_NO_RESPONSE
        case USER_LINE_BUSY
        case USER_LEAVE
        case USER_EXCEED_LIMIT
        
        case ERROR_COMMON
        case UNKNOWN
    }
    
    var eventType: EventType
    var event: Event
    var param: [String: Any]

    init(eventType: EventType, event: Event, param: [String: Any]) {
        self.eventType = eventType
        self.event = event
        self.param = param
    }
}
