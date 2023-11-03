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
    
    let callTime: Observable<Int> = Observable(0)
    let mediaType: Observable<TUICallMediaType> = Observable(.unknown)
    let selfCallStatus: Observable<TUICallStatus> = Observable(.none)
    let remoteUserList: Observable<[User]> = Observable(Array())
    let selfUser: Observable<User> = Observable(User())
    let scene: Observable<TUICallScene> = Observable(TUICallScene.single)
    
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
    }
    
    func registerObserve() {
        TUICallState.instance.selfUser.value.callStatus.addObserver(callStatusObserver, closure: { [weak self] newValue, _ in
            guard let self = self else { return }
            self.selfCallStatus.value = newValue
        })
        
        TUICallState.instance.mediaType.addObserver(mediaTypeObserver, closure: { [weak self] newValue, _ in
            guard let self = self else { return }
            self.mediaType.value = newValue
        })
        
        TUICallState.instance.remoteUserList.addObserver(remoteUserListObserver, closure: { [weak self] newValue, _ in
            guard let self = self else { return }
            self.remoteUserList.value = newValue
        })
        
        TUICallState.instance.timeCount.addObserver(timeCountObserver, closure: { [weak self] newValue, _ in
            guard let self = self else { return }
            self.callTime.value = newValue
        })
        
        TUICallState.instance.scene.addObserver(sceneObserver) { [weak self] newValue, _ in
            guard let self = self else { return }
            self.scene.value = newValue
        }
    }
    
    func getCallTimeString() -> String {
        return GCDTimer.secondToHMSString(second: callTime.value)
    }
    
    func startRemoteView(user: User, videoView: TUIVideoView){
        CallEngineManager.instance.startRemoteView(user: user, videoView: videoView)
    }
    
}
