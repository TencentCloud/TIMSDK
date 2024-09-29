//
//  ConferenceMainViewStoreRegister.swift
//  TUIRoomKit
//
//  Created by janejntang on 2024/9/3.
//

import Factory

extension Container {
    var conferenceMainViewStore: Factory<ConferenceMainViewStore> {
        Factory(self) {
            ConferenceMainViewStoreProvider()
        }
        .shared
    }
}
