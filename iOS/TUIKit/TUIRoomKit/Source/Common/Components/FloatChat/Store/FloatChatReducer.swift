//
//  FloatChatReducer.swift
//  TUIRoomKit
//
//  Created by CY zhao on 2024/5/10.
//  Copyright © 2024 Tencent. All rights reserved.
//

import Foundation
import RTCRoomEngine

let floatChatReducer = Reducer<FloatChatState>(
    ReduceOn(FloatChatActions.onMessageSended) { state, action in
        let selfInfo = TUIRoomEngine.getSelfInfo()
        let user = FloatChatUser(loginInfo: selfInfo)
        let floatMessage = FloatChatMessage(user: user, content: action.payload)
        state.latestMessage = floatMessage
    },
    ReduceOn(FloatChatActions.onMessageReceived) { state, action in
        state.latestMessage = action.payload
    },
    ReduceOn(FloatViewActions.showFloatInputView) { state, action in
        state.isFloatInputViewShow = action.payload
    },
    ReduceOn(FloatChatActions.setRoomId) { state, action in
        state.roomId = action.payload
    }
)
