//
//  SingleLayoutViewModel.swift
//  TUICallKit
//
//  Created by vincepzhang on 2023/2/21.
//

import Foundation
import TUICallEngine

class SingleCallVideoLayoutModel {
    
    let callStatusObserver = Observer()
    let mediaTypeObserver = Observer()
    let remoteUserListObserver = Observer()
    let isCameraOpenObserver = Observer()
    
    let selfUser: Observable<User> = Observable(User())
    let mediaType: Observable<TUICallMediaType> = Observable(.unknown)
    let selfCallStatus: Observable<TUICallStatus> = Observable(.none)
    let remoteUserList: Observable<[User]> = Observable(Array())
    let isCameraOpen: Observable<Bool> = Observable(false)

    init() {
        selfUser.value = TUICallState.instance.selfUser.value
        mediaType.value = TUICallState.instance.mediaType.value
        selfCallStatus.value = TUICallState.instance.selfUser.value.callStatus.value
        remoteUserList.value = TUICallState.instance.remoteUserList.value
        isCameraOpen.value = TUICallState.instance.isCameraOpen.value

        registerObserve()
    }
    
    deinit {
        TUICallState.instance.selfUser.value.callStatus.removeObserver(callStatusObserver)
        TUICallState.instance.mediaType.removeObserver(mediaTypeObserver)
        TUICallState.instance.remoteUserList.removeObserver(remoteUserListObserver)
        TUICallState.instance.isCameraOpen.removeObserver(isCameraOpenObserver)
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
        
        TUICallState.instance.isCameraOpen.addObserver(isCameraOpenObserver) { [weak self] newValue, _ in
            guard let self = self else { return }
            self.isCameraOpen.value = newValue
        }
    }

    //MARK: CallEngine Method
    func openCamera(videoView: TUIVideoView) {
        CallEngineManager.instance.openCamera(videoView: videoView)
    }
    
    func closeCamera() {
        CallEngineManager.instance.closeCamera()
    }
    
    func startRemoteView(user: User, videoView: TUIVideoView){
        CallEngineManager.instance.startRemoteView(user: user, videoView: videoView)
    }
    
    func stopRemoteView(user: User) {
        CallEngineManager.instance.stopRemoteView(user: user)
    }
}
