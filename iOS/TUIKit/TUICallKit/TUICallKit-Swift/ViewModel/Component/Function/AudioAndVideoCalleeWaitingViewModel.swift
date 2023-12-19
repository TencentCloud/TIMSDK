//
//  AudioAndVideoCalleeWaitingViewModel.swift
//  TUICallKit
//
//  Created by vincepzhang on 2022/12/30.
//

import Foundation
import TUICallEngine

class AudioAndVideoCalleeWaitingViewModel {
    
    let mediaTypeObserver = Observer()
    let isCameraOpenObserver = Observer()
    let isMicMuteObserver = Observer()
    let audioDeviceObserver = Observer()
    
    let isCameraOpen: Observable<Bool> = Observable(false)
    let isMicMute: Observable<Bool> = Observable(false)
    let audioDevice: Observable<TUIAudioPlaybackDevice> = Observable(.speakerphone)
    let selfUser: Observable<User> = Observable(User())
    let mediaType: Observable<TUICallMediaType> = Observable(.unknown)
    
    init() {
        isCameraOpen.value = TUICallState.instance.isCameraOpen.value
        isMicMute.value = TUICallState.instance.isMicMute.value
        audioDevice.value = TUICallState.instance.audioDevice.value
        selfUser.value = TUICallState.instance.selfUser.value
        mediaType.value = TUICallState.instance.mediaType.value

        registerObserve()
    }
    
    deinit {
        TUICallState.instance.isCameraOpen.removeObserver(isCameraOpenObserver)
        TUICallState.instance.isMicMute.removeObserver(isMicMuteObserver)
        TUICallState.instance.audioDevice.removeObserver(audioDeviceObserver)
    }
    
    func registerObserve() {
        
        TUICallState.instance.isCameraOpen.addObserver(isCameraOpenObserver, closure: { [weak self] newValue, _ in
            guard let self = self else { return }
            self.isCameraOpen.value = newValue
        })
        
        TUICallState.instance.isMicMute.addObserver(isMicMuteObserver, closure: { [weak self] newValue, _ in
            guard let self = self else { return }
            self.isMicMute.value = newValue

        })
        
        TUICallState.instance.audioDevice.addObserver(audioDeviceObserver, closure: { [weak self] newValue, _ in
            guard let self = self else { return }
            self.audioDevice.value = newValue
        })
        
        TUICallState.instance.mediaType.addObserver(mediaType) { [weak self] newValue, _ in
            guard let self = self else { return }
            self.mediaType.value = newValue
        }
    }

    // MARK: CallEngine Method
    func accept() {
        CallEngineManager.instance.accept()
    }
    
    func reject() {
        CallEngineManager.instance.reject()
    }
}
