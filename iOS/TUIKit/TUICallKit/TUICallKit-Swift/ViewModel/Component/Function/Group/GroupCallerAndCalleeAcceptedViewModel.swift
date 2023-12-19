//
//  GroupCallerAndCalleeAcceptedViewModel.swift
//  TUICallKit
//
//  Created by noah on 2023/11/10.
//

import Foundation
import TUICallEngine

class GroupCallerAndCalleeAcceptedViewModel {
    
    let mediaTypeObserver = Observer()
    let isCameraOpenObserver = Observer()
    let isMicMuteObserver = Observer()
    let audioDeviceObserver = Observer()
    let showLargeViewUserIdObserver = Observer()
    
    let isCameraOpen: Observable<Bool> = Observable(false)
    let isMicMute: Observable<Bool> = Observable(false)
    let audioDevice: Observable<TUIAudioPlaybackDevice> = Observable(.speakerphone)
    let selfUser: Observable<User> = Observable(User())
    let mediaType: Observable<TUICallMediaType> = Observable(.unknown)
    let showLargeViewUserId: Observable<String> = Observable("")
    
    init() {
        mediaType.value = TUICallState.instance.mediaType.value
        audioDevice.value = TUICallState.instance.audioDevice.value
        selfUser.value = TUICallState.instance.selfUser.value
        audioDevice.value = TUICallState.instance.audioDevice.value
        isCameraOpen.value = TUICallState.instance.isCameraOpen.value
        isMicMute.value = TUICallState.instance.isMicMute.value
        showLargeViewUserId.value = TUICallState.instance.showLargeViewUserId.value
        
        registerObserve()
    }
    
    deinit {
        TUICallState.instance.isCameraOpen.removeObserver(isCameraOpenObserver)
        TUICallState.instance.isMicMute.removeObserver(isMicMuteObserver)
        TUICallState.instance.audioDevice.removeObserver(audioDeviceObserver)
        TUICallState.instance.showLargeViewUserId.removeObserver(showLargeViewUserIdObserver)
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
        
        TUICallState.instance.showLargeViewUserId.addObserver(showLargeViewUserIdObserver, closure: { [weak self] newValue, _ in
            guard let self = self else { return }
            self.showLargeViewUserId.value = newValue
        })
    }
    
    // MARK: CallEngine Method
    func hangup() {
        CallEngineManager.instance.hangup()
    }
    
    func muteMic() {
        CallEngineManager.instance.muteMic()
    }
    
    func changeSpeaker() {
        CallEngineManager.instance.changeSpeaker()
    }
    
    func switchCamera() {
        CallEngineManager.instance.switchCamera()
    }
    
    func closeCamera() {
        CallEngineManager.instance.closeCamera()
    }
    
    func openCamera(videoView: TUIVideoView) {
        CallEngineManager.instance.openCamera(videoView: videoView)
    }
}
