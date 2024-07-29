//
//  GroupCallVideoCellViewModel.swift
//  TUICallKit
//
//  Created by vincepzhang on 2023/3/6.
//

import Foundation
import TUICallEngine

class GroupCallVideoCellViewModel {
    
    let showLargeViewUserIdObserver = Observer()
    let remoteUserStatusObserver = Observer()
    let remoteUserVideoAvailableObserver = Observer()
    let remotePlayoutVolumeObserver = Observer()
    let remoteNetworkQualityObserver = Observer()
    
    var remoteUser = User()
    let isShowLargeViewUserId: Observable<Bool> = Observable(false)
    let remoteUserStatus: Observable<TUICallStatus> = Observable(.none)
    let remoteUserVideoAvailable: Observable<Bool> = Observable(false)
    let remoteUserVolume: Observable<Float> = Observable(0)
    let remoteIsShowLowNetworkQuality: Observable<Bool> = Observable(false)
    
    init(remote: User) {
        remoteUser = remote
        isShowLargeViewUserId.value = (TUICallState.instance.showLargeViewUserId.value == remote.id.value) && (remote.id.value.count > 0)
        registerObserve()
    }
    
    deinit {
        TUICallState.instance.showLargeViewUserId.removeObserver(showLargeViewUserIdObserver)
        
        for index in 0..<TUICallState.instance.remoteUserList.value.count {
            guard index < TUICallState.instance.remoteUserList.value.count else {
                break
            }
            if TUICallState.instance.remoteUserList.value[index].id.value == remoteUser.id.value {
                TUICallState.instance.remoteUserList.value[index].callStatus.removeObserver(remoteUserStatusObserver)
                TUICallState.instance.remoteUserList.value[index].videoAvailable.removeObserver(remoteUserVideoAvailableObserver)
                TUICallState.instance.remoteUserList.value[index].networkQualityReminder.removeObserver(remoteNetworkQualityObserver)
                TUICallState.instance.remoteUserList.value[index].playoutVolume.removeObserver(remotePlayoutVolumeObserver)
            }
        }
    }
    
    func registerObserve() {
        TUICallState.instance.showLargeViewUserId.addObserver(showLargeViewUserIdObserver, closure: {  [weak self] newValue, _ in
            guard let self = self else { return }
            self.isShowLargeViewUserId.value = (newValue == self.remoteUser.id.value)
        })
        
        for index in 0..<TUICallState.instance.remoteUserList.value.count {
            guard index < TUICallState.instance.remoteUserList.value.count else {
                break
            }
            
            if TUICallState.instance.remoteUserList.value[index].id.value == remoteUser.id.value {
                
                remoteUserStatus.value = TUICallState.instance.remoteUserList.value[index].callStatus.value
                remoteUserVideoAvailable.value = TUICallState.instance.remoteUserList.value[index].videoAvailable.value
                
                TUICallState.instance.remoteUserList.value[index].callStatus.addObserver(remoteUserStatusObserver,
                                                                                         closure: { [weak self] newValue, _ in
                    guard let self = self else { return }
                    self.remoteUserStatus.value = newValue
                })
                
                TUICallState.instance.remoteUserList.value[index].videoAvailable.addObserver(remoteUserVideoAvailableObserver,
                                                                                             closure: { [weak self] newValue, _ in
                    guard let self = self else { return }
                    self.remoteUserVideoAvailable.value = newValue
                })
                
                TUICallState.instance.remoteUserList.value[index].networkQualityReminder.addObserver(remoteNetworkQualityObserver)
                { [weak self] newValue, _ in
                    guard let self = self else { return }
                    self.remoteIsShowLowNetworkQuality.value = newValue
                }
                
                TUICallState.instance.remoteUserList.value[index].playoutVolume.addObserver(remotePlayoutVolumeObserver)
                { [weak self] newValue, _ in
                    guard let self = self else { return }
                    self.remoteUserVolume.value = newValue
                }
            }
        }
    }
    
}
