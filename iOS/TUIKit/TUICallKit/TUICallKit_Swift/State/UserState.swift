//
//  UserState.swift
//  Pods
//
//  Created by vincepzhang on 2025/2/6.
//

import Foundation
import ImSDK_Plus
import RTCRoomEngine
import RTCCommon
import TUICore

class User {
    let id: Observable<String> = Observable("")
    let nickname: Observable<String> = Observable("")
    let avatar: Observable<String> = Observable("")
    let remark: Observable<String> = Observable("")
    
    let callRole: Observable<TUICallRole> = Observable(.none)
    let callStatus: Observable<TUICallStatus> = Observable(.none)
    
    let audioAvailable: Observable<Bool> = Observable(false)
    let videoAvailable: Observable<Bool> = Observable(false)
    let playoutVolume: Observable<Float> = Observable(0)
    let networkQualityReminder: Observable<Bool> = Observable(false)
    
    var multiCallCellViewIndex: Int = -1
            
    func reset() {
        callRole.value = .none
        callStatus.value = .none
        audioAvailable.value = false
        videoAvailable.value = false
        playoutVolume.value = 0
        networkQualityReminder.value = false
        multiCallCellViewIndex = -1
    }
}

class UserState: NSObject {
    let selfUser: User = User()
    let remoteUserList: Observable<[User]> = Observable(Array())
        
    func reset() {
        remoteUserList.value = Array()
        selfUser.reset()
    }
}
