//
//  AppDelegate+Injection.swift
//  TUIRoomKit
//
//  Created by CY zhao on 2024/5/16.
//

import Foundation

extension Resolver: ResolverRegistering {
    public static func registerAllServices() {
        registerFloatChatervice()
    }
}
