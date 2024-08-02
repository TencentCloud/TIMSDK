//
//  ScheduleConference+Injection.swift
//  TUIRoomKit
//
//  Created by aby on 2024/6/27.
//

import Factory

extension Container {
    var scheduleStore: Factory<ScheduleConferenceStore> {
        self {
            ScheduleConferenceStoreProvider()
        }
        .shared
    }
    var modifyScheduleStore: Factory<ScheduleConferenceStore> {
        self {
            ScheduleConferenceStoreProvider()
        }
        .shared
    }
}
