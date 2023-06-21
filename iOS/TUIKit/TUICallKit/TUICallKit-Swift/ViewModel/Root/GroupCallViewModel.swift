//
//  GroupCallViewModel.swift
//  TUICallKit
//
//  Created by vincepzhang on 2023/1/6.
//

import Foundation
import TUICallEngine

class GroupCallViewModel {
    let callStatusObserver = Observer()
    let mediaTypeObserver = Observer()
    let remoteUserListObserver = Observer()
    let selfCallRoleObserver = Observer()

    let selfUser: Observable<User> = Observable(User())
    let selfCallStatus: Observable<TUICallStatus> = Observable(.none)
    let selfCallRole: Observable<TUICallRole> = Observable(.none)
    let mediaType: Observable<TUICallMediaType> = Observable(.unknown)
    let remoteUserList: Observable<[User]> = Observable(Array())
    
    let enableFloatWindow = TUICallState.instance.enableFloatWindow
    
    init() {
        selfUser.value = TUICallState.instance.selfUser.value
        selfCallStatus.value = TUICallState.instance.selfUser.value.callStatus.value
        selfCallRole.value = TUICallState.instance.selfUser.value.callRole.value
        mediaType.value = TUICallState.instance.mediaType.value
        remoteUserList.value = TUICallState.instance.remoteUserList.value
        
        registerObserve()
    }
    
    deinit {
        TUICallState.instance.selfUser.value.callRole.removeObserver(selfCallRoleObserver)
        TUICallState.instance.selfUser.value.callStatus.removeObserver(callStatusObserver)
        TUICallState.instance.mediaType.removeObserver(mediaTypeObserver)
        TUICallState.instance.remoteUserList.removeObserver(remoteUserListObserver)
    }
    
    func registerObserve() {
                        
        TUICallState.instance.selfUser.value.callRole.addObserver(selfCallRoleObserver, closure: { [weak self] newValue, _ in
            guard let self = self else { return }
            self.selfCallRole.value = newValue
        })
        
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
    }

}
