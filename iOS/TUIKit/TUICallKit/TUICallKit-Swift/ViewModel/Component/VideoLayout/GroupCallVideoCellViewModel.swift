//
//  CallingGroupCellViewModel.swift
//  TUICallKit
//
//  Created by vincepzhang on 2023/3/6.
//

import Foundation
import TUICallEngine

class GroupCallVideoCellViewModel {
    
    let selfCallStatusObserver = Observer()
    let selfVideoAvailableObserver = Observer()
    let remoteUserStatusObserver = Observer()
    let remoteUserVideoAvailableObserver = Observer()
    let isCameraOpenAvailableObserver = Observer()
    let remotePlayoutVolumeObserver = Observer()
    let selfPlayoutVolumeObserver = Observer()
    
    var isSelf: Bool = false
    
    let selfUser: Observable<User> = Observable(User())
    let selfUserStatus: Observable<TUICallStatus> = Observable(.none)
    let selfUserVideoAvailable: Observable<Bool> = Observable(false)
    let selfPlayoutVolume: Observable<Float> = Observable(0)
    
    var remoteUser = User()
    let remoteUserStatus: Observable<TUICallStatus> = Observable(.none)
    let remoteUserVideoAvailable: Observable<Bool> = Observable(false)
    let remoteUserVolume: Observable<Float> = Observable(0)
    
    let mediaType: Observable<TUICallMediaType> = Observable(.unknown)
    let isCameraOpen: Observable<Bool> = Observable(false)
    
    init(remote: User) {
        remoteUser = remote
        selfUser.value = TUICallState.instance.selfUser.value
        selfUserStatus.value = TUICallState.instance.selfUser.value.callStatus.value
        selfUserVideoAvailable.value = TUICallState.instance.selfUser.value.videoAvailable.value
        selfPlayoutVolume.value = TUICallState.instance.selfUser.value.playoutVolume.value
        mediaType.value = TUICallState.instance.mediaType.value
        isSelf = selfUser.value.id.value == remote.id.value ? true : false
        isCameraOpen.value = TUICallState.instance.isCameraOpen.value
        registerObserve()
    }
    
    deinit {
        TUICallState.instance.selfUser.value.callStatus.removeObserver(selfCallStatusObserver)
        TUICallState.instance.selfUser.value.videoAvailable.removeObserver(selfVideoAvailableObserver)
        TUICallState.instance.selfUser.value.playoutVolume.removeObserver(selfPlayoutVolumeObserver)
    }
    
    func registerObserve() {
        TUICallState.instance.selfUser.value.callStatus.addObserver(selfCallStatusObserver, closure: { [weak self] newValue, _ in
            guard let self = self else { return }
            self.selfUserStatus.value = newValue
        })
        
        TUICallState.instance.selfUser.value.videoAvailable.addObserver(selfVideoAvailableObserver, closure: { [weak self] newValue, _ in
            guard let self = self else { return }
            self.selfUserVideoAvailable.value = newValue
        })
        
        TUICallState.instance.isCameraOpen.addObserver(isCameraOpenAvailableObserver, closure: {  [weak self] newValue, _ in
            guard let self = self else { return }
            self.isCameraOpen.value = newValue
        })
        
        TUICallState.instance.selfUser.value.playoutVolume.addObserver(selfPlayoutVolumeObserver) { [weak self] newValue, _ in
            guard let self = self else { return }
            self.selfPlayoutVolume.value = newValue
        }
        
        for index in 0..<TUICallState.instance.remoteUserList.value.count {
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
                
                TUICallState.instance.remoteUserList.value[index].playoutVolume.addObserver(remotePlayoutVolumeObserver)
                { [weak self] newValue, _ in
                    guard let self = self else { return }
                    self.remoteUserVolume.value = newValue
                }
            } else {
                
            }
        }
    }
    
    //MARK: CallEngine Method
    func openCamera(videoView: TUIVideoView) {
        CallEngineManager.instance.openCamera(videoView: videoView)
    }
    
    func closeCamera() {
        CallEngineManager.instance.closeCamera()
    }
    
    func startRemoteView(user: User, videoView: TUIVideoView) {
        CallEngineManager.instance.startRemoteView(user: user, videoView: videoView)
    }
}
