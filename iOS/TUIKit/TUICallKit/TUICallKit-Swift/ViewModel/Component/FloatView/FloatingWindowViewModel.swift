//
//  FloatWindowViewModel.swift
//  TUICallKit
//
//  Created by vincepzhang on 2023/2/27.
//

import Foundation
import TUICallEngine

class FloatingWindowViewModel {
    
    let callStatusObserver = Observer()
    let mediaTypeObserver = Observer()
    let remoteUserListObserver = Observer()
    let timeCountObserver = Observer()
    let sceneObserver = Observer()
    let selfPlayoutVolumeObserver = Observer()
    let remotePlayoutVolumeObserver = Observer()
    
    let callTime: Observable<Int> = Observable(0)
    let mediaType: Observable<TUICallMediaType> = Observable(.unknown)
    let selfCallStatus: Observable<TUICallStatus> = Observable(.none)
    let remoteUserList: Observable<[User]> = Observable(Array())
    let selfUser: Observable<User> = Observable(User())
    let scene: Observable<TUICallScene> = Observable(TUICallScene.single)
    let currentSpeakUser: Observable<User> = Observable(User())
    
    init() {
        callTime.value = TUICallState.instance.timeCount.value
        selfCallStatus.value = TUICallState.instance.selfUser.value.callStatus.value
        mediaType.value = TUICallState.instance.mediaType.value
        remoteUserList.value = TUICallState.instance.remoteUserList.value
        selfUser.value = TUICallState.instance.selfUser.value
        scene.value = TUICallState.instance.scene.value
        
        registerObserve()
    }
    
    deinit {
        TUICallState.instance.selfUser.value.callStatus.removeObserver(callStatusObserver)
        TUICallState.instance.mediaType.removeObserver(mediaTypeObserver)
        TUICallState.instance.remoteUserList.removeObserver(remoteUserListObserver)
        TUICallState.instance.timeCount.removeObserver(timeCountObserver)
        TUICallState.instance.scene.removeObserver(sceneObserver)
        TUICallState.instance.selfUser.value.playoutVolume.removeObserver(selfPlayoutVolumeObserver)
        
        for index in 0..<TUICallState.instance.remoteUserList.value.count {
            guard index < TUICallState.instance.remoteUserList.value.count else {
                break
            }
            TUICallState.instance.remoteUserList.value[index].playoutVolume.removeObserver(remotePlayoutVolumeObserver)
        }
    }
    
    func registerObserve() {
        registerCallStatusObserver()
        registerMediaTypeObserver()
        registerRemoteUserListObserver()
        registerTimeCountObserver()
        registerSceneObserver()
        registerVolumeObserver()
    }
    
    func registerCallStatusObserver() {
        TUICallState.instance.selfUser.value.callStatus.addObserver(callStatusObserver, closure: { [weak self] newValue, _ in
            guard let self = self else { return }
            self.selfCallStatus.value = newValue
        })
    }
    
    func registerMediaTypeObserver() {
        TUICallState.instance.mediaType.addObserver(mediaTypeObserver, closure: { [weak self] newValue, _ in
            guard let self = self else { return }
            self.mediaType.value = newValue
        })
    }
    
    func registerRemoteUserListObserver() {
        TUICallState.instance.remoteUserList.addObserver(remoteUserListObserver, closure: { [weak self] newValue, _ in
            guard let self = self else { return }
            self.remoteUserList.value = newValue
            
            if !newValue.contains(where: { $0.id.value == self.currentSpeakUser.value.id.value }) {
                self.updateCurrentSpeakUser(user: TUICallState.instance.selfUser.value)
            }
        })
    }
    
    func registerTimeCountObserver() {
        TUICallState.instance.timeCount.addObserver(timeCountObserver, closure: { [weak self] newValue, _ in
            guard let self = self else { return }
            self.callTime.value = newValue
        })
    }
    
    func registerSceneObserver() {
        TUICallState.instance.scene.addObserver(sceneObserver) { [weak self] newValue, _ in
            guard let self = self else { return }
            self.scene.value = newValue
        }
    }
    
    func registerVolumeObserver() {
        TUICallState.instance.selfUser.value.playoutVolume.addObserver(selfPlayoutVolumeObserver) { [weak self] newValue, _ in
            guard let self = self else { return }
            if newValue > 30 {
                self.updateCurrentSpeakUser(user: TUICallState.instance.selfUser.value)
            }
        }
        
        for index in 0..<TUICallState.instance.remoteUserList.value.count {
            guard index < TUICallState.instance.remoteUserList.value.count else {
                break
            }
            let user = TUICallState.instance.remoteUserList.value[index]
            TUICallState.instance.remoteUserList.value[index].playoutVolume.addObserver(remotePlayoutVolumeObserver) { [weak self] newValue, _ in
                guard let self = self else { return }
                if newValue > 30 {
                    self.updateCurrentSpeakUser(user: user)
                }
            }
        }
    }
    
    func updateCurrentSpeakUser(user: User) {
        if user.id.value.count > 0 && currentSpeakUser.value.id.value != user.id.value {
            self.currentSpeakUser.value = user
        }
    }
    
    func getCallTimeString() -> String {
        return GCDTimer.secondToHMSString(second: callTime.value)
    }
    
    func startRemoteView(user: User, videoView: TUIVideoView){
        CallEngineManager.instance.startRemoteView(user: user, videoView: videoView)
    }
    
}
