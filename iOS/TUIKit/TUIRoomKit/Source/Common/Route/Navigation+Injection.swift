//
//  Navigation+Injection.swift
//  TUIRoomKit
//
//  Created by aby on 2024/6/20.
//
import Factory

extension Container {
    var navigation: Factory<Route> {
        Factory(self) {
            ConferenceRouter()
        }
        .shared
    }
}
