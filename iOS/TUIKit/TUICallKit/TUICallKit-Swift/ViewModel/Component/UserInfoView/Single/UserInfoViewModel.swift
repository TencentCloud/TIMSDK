//
//  UserInfoViewModel.swift
//  TUICallKit
//
//  Created by vincepzhang on 2023/2/21.
//

import Foundation
import TUICallEngine

class UserInfoViewModel {
    let callStatusObserver = Observer()
    let remoteUserListObserver = Observer()
    
    let remoteUserList: Observable<[User]> = Observable(Array())
    let selfCallStatus: Observable<TUICallStatus> = Observable(.none)
    
    init() {
        remoteUserList.value = TUICallState.instance.remoteUserList.value
        selfCallStatus.value = TUICallState.instance.selfUser.value.callStatus.value
        
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
    }
    
    func getCurrentWaitingText() -> String {
        var waitingText = String()
        switch TUICallState.instance.mediaType.value {
        case .audio:
            if TUICallState.instance.selfUser.value.callRole.value == .call {
                waitingText = TUICallKitLocalize(key: "Demo.TRTC.Calling.waitaccept") ?? ""
            } else {
                waitingText = TUICallKitLocalize(key: "Demo.TRTC.calling.invitetoaudiocall") ?? ""
            }
        case .video:
            if TUICallState.instance.selfUser.value.callRole.value == .call {
                waitingText = TUICallKitLocalize(key: "Demo.TRTC.Calling.waitaccept") ?? ""
            } else {
                waitingText = TUICallKitLocalize(key: "Demo.TRTC.calling.invitetovideocall") ?? ""
            }
        case .unknown:
            break
        default:
            break
        }
        return waitingText
    }
    
}
