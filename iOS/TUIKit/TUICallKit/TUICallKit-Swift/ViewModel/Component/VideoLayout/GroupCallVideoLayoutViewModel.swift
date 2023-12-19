//
//  GroupCallVideoLayoutViewModel.swift
//  TUICallKit
//
//  Created by vincepzhang on 2023/3/7.
//

import Foundation
import TUICallEngine

class GroupCallVideoLayoutViewModel {
    
    let callStatusObserver = Observer()
    let mediaTypeObserver = Observer()
    let remoteUserListObserver = Observer()
    let callRoleCountObserver = Observer()
    let isCameraOpenObserver = Observer()
    
    let selfUser: Observable<User> = Observable(User())
    let selfCallStatus: Observable<TUICallStatus> = Observable(.none)
    let selfCallRole: Observable<TUICallRole> = Observable(.none)
    let mediaType: Observable<TUICallMediaType> = Observable(.unknown)
    let remoteUserList: Observable<[User]> = Observable(Array())
    let isCameraOpen: Observable<Bool> = Observable(false)
    
    var allUserList = [User]()
    
    init() {
        selfUser.value = TUICallState.instance.selfUser.value
        selfCallStatus.value = TUICallState.instance.selfUser.value.callStatus.value
        selfCallRole.value = TUICallState.instance.selfUser.value.callRole.value
        mediaType.value = TUICallState.instance.mediaType.value
        remoteUserList.value = TUICallState.instance.remoteUserList.value
        isCameraOpen.value = TUICallState.instance.isCameraOpen.value
        processUserList(remoteUserList: remoteUserList.value)
        registerObserver()
    }
    
    deinit {
        TUICallState.instance.selfUser.value.callRole.removeObserver(callRoleCountObserver)
        TUICallState.instance.selfUser.value.callStatus.removeObserver(callStatusObserver)
        TUICallState.instance.mediaType.removeObserver(mediaTypeObserver)
        TUICallState.instance.remoteUserList.removeObserver(remoteUserListObserver)
        TUICallState.instance.isCameraOpen.removeObserver(isCameraOpenObserver)
    }
    
    func registerObserver() {
        TUICallState.instance.selfUser.value.callRole.addObserver(callRoleCountObserver, closure: { [weak self] newValue, _ in
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
            self.processUserList(remoteUserList: newValue)
            self.remoteUserList.value = newValue
        })
        
        TUICallState.instance.isCameraOpen.addObserver(isCameraOpenObserver, closure: { [weak self] newValue, _ in
            guard let self = self else { return }
            self.isCameraOpen.value = newValue
        })
    }
    
    func processUserList(remoteUserList: [User]) {
        allUserList.removeAll()
        selfUser.value.index = 0
        allUserList.append(selfUser.value)
        
        for (index, value) in remoteUserList.enumerated() {
            value.index = index + 1
            allUserList.append(value)
        }
    }
    
    // MARK: Set TUICallState showLargeViewUserId
    func setShowLargeViewUserId(userId: String) {
        TUICallState.instance.showLargeViewUserId.value = userId
    }
    
}
