//
//  FloatchatResolverRegister.swift
//  TUIRoomKit
//
//  Created by CY zhao on 2024/5/16.
//
import Factory

extension Container {
    var floatChatService: Factory<FloatChatStoreProvider> {
        self { FloatChatStore() }.shared
    }
}
