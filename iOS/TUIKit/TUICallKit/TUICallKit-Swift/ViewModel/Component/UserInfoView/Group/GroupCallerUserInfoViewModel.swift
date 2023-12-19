//
//  GroupCallerUserInfoViewModel.swift
//  TUICallKit
//
//  Created by vincepzhang on 2023/3/7.
//

import Foundation
import TUICallEngine

class GroupCallerUserInfoViewModel {
    
    let callStatusObserver = Observer()
    let remoteUserListObserver = Observer()
    let mediaTypeObserver = Observer()
    
    let remoteUserList: Observable<[User]> = Observable(Array())
    let selfCallStatus: Observable<TUICallStatus> = Observable(.none)
    let mediaType: Observable<TUICallMediaType> = Observable(.unknown)
    
    init() {
        remoteUserList.value = TUICallState.instance.remoteUserList.value
        selfCallStatus.value = TUICallState.instance.selfUser.value.callStatus.value
        mediaType.value = TUICallState.instance.mediaType.value
        
        registerObserve()
    }
    
    deinit {
        TUICallState.instance.selfUser.value.callStatus.removeObserver(callStatusObserver)
        TUICallState.instance.remoteUserList.removeObserver(remoteUserListObserver)
    }
    
    func registerObserve() {
        TUICallState.instance.selfUser.value.callStatus.addObserver(callStatusObserver, closure: { [weak self] newValue, _ in
            guard let self = self else { return }
            self.selfCallStatus.value = newValue
        })
        
        TUICallState.instance.remoteUserList.addObserver(remoteUserListObserver, closure: { [weak self] newValue, _ in
            guard let self = self else { return }
            self.remoteUserList.value = newValue
        })
        
        TUICallState.instance.mediaType.addObserver(mediaTypeObserver) { [weak self] newValue, _ in
            guard let self = self else { return }
            self.mediaType.value = newValue
        }
    }
    
}
