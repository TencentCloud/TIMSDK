//
//  MediaState.swift
//  Pods
//
//  Created by vincepzhang on 2025/2/6.
//

import RTCCommon
import RTCRoomEngine

class MediaState: NSObject {
    
    let isCameraOpened: Observable<Bool> = Observable(false)
    
    let isFrontCamera: Observable<Bool> = Observable(true)

    let isMicrophoneMuted: Observable<Bool> = Observable(false)
    
    let audioPlayoutDevice: Observable<TUIAudioPlaybackDevice> = Observable(TUIAudioPlaybackDevice.earpiece)
    
    func reset() {
        isCameraOpened.value = false
        isFrontCamera.value = true
        isMicrophoneMuted.value = false
        audioPlayoutDevice.value = .earpiece
    }
}
