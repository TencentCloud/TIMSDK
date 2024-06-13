//
//  FloatChatSelectors.swift
//  TUIRoomKit
//
//  Created by CY zhao on 2024/5/10.
//  Copyright © 2024 Tencent. All rights reserved.
//

import Foundation

enum FloatChatSelectors {
    static let getMessageList = Selector(keyPath: \FloatChatState.messageList)
    static let getMessageCount = Selector.with(getMessageList) { $0.count }
    static let getShowFloatInputView = Selector(keyPath: \FloatChatState.isFloatInputViewShow)
    static let getRoomId = Selector(keyPath: \FloatChatState.roomId)
}
