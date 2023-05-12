//
//  InviteeAvatarListViewModel.swift
//  TUICallKit
//
//  Created by vincepzhang on 2023/3/7.
//

import Foundation

class InviteeAvatarListViewModel {

    let remoteUserListObserver = Observer()
    let selfUserObserver = Observer()

    let remoteUserList: Observable<[User]> = Observable(Array())
    let selfUser = Observable(User())
    
    init() {
        remoteUserList.value = TUICallState.instance.remoteUserList.value
        selfUser.value = TUICallState.instance.selfUser.value
        
        registerObserve()
    }
    
    deinit {
        TUICallState.instance.remoteUserList.removeObserver(remoteUserListObserver)
    }
    
    func registerObserve() {
        TUICallState.instance.remoteUserList.addObserver(remoteUserListObserver, closure: { [weak self] newValue, _ in
            guard let self = self else { return }
            self.remoteUserList.value = newValue
        })
    }

}
