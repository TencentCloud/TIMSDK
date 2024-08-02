//
//  ConferenceStoreResolverRegister.swift
//  TUIRoomKit
//
//  Created by CY zhao on 2024/6/12.
//

import Foundation
import Factory

extension Container {
    var conferenceStore: Factory<ConferenceStore> {
        Factory(self) {
            ConferenceStoreProvider()
        }
        .shared
    }
}
