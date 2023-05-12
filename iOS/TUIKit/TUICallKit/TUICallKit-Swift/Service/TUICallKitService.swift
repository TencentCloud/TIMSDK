//
//  File.swift
//  TUICallKit
//
//  Created by vincepzhang on 2023/4/20.
//

import Foundation
import TUICore

class TUICallKitService: NSObject, TUIServiceProtocol {
    static let instance = TUICallKitService()

    override init() {
        let _ = TUICallKit.createInstance()
    }
}
