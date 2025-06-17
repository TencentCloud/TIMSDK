//
//  CallState.swift
//  Pods
//
//  Created by vincepzhang on 2025/2/6.
//

import RTCCommon
import RTCRoomEngine

enum NetworkQualityHint {
    case None
    case Local
    case Remote
}

class CallState: NSObject {
    var roomId: TUIRoomId? = nil
    var chatGroupId:Observable<String> = Observable("")
    var scene: TUICallScene = TUICallScene.single
    let mediaType: Observable<TUICallMediaType> = Observable(TUICallMediaType.unknown)
    let callDurationCount: Observable<Int> = Observable(0)
    let networkQualityReminder: Observable<NetworkQualityHint> = Observable(NetworkQualityHint.None)
        
    func reset() {
        roomId = nil
        chatGroupId.value = ""
        scene = .single
        mediaType.value = .unknown
        callDurationCount.value = 0
        networkQualityReminder.value = .None
    }
}
