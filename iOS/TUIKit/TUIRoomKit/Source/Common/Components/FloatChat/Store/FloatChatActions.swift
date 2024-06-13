//
//  FloatChatAction.swift
//  TUIRoomKit
//
//  Created by CY zhao on 2024/5/10.
//  Copyright © 2024 Tencent. All rights reserved.
//

import Foundation

enum FloatChatActions {
    static let key = "FloatChat.chat"
    static let sendMessage = ActionTemplate(id: key.appending(".sendMessage"), payloadType: String.self)
    static let onMessageSended = ActionTemplate(id: key.appending(".messageSended"), payloadType: String.self)
    static let onMessageReceived = ActionTemplate(id: key.appending(".messageReceived"), payloadType: FloatChatMessage.self)
    static let setRoomId = ActionTemplate(id: key.appending(".setRoomId"), payloadType: String.self)
}

enum FloatViewActions {
    static let key = "FloatChat.view"
    static let showFloatInputView = ActionTemplate(id: key.appending(".show"), payloadType: Bool.self)
}
