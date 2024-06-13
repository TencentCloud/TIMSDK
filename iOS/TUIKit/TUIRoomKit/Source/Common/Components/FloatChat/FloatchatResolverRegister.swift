//
//  FloatchatResolverRegister.swift
//  TUIRoomKit
//
//  Created by CY zhao on 2024/5/16.
//

extension Resolver {
    public static func registerFloatChatervice() {
        register { FloatChatStore() }
        .implements(FloatChatStoreProvider.self)
        .scope(.shared)
    }
}
