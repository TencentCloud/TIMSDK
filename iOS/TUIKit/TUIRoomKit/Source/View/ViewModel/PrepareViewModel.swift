//
//  PrePareViewModel.swift
//  TUIRoomKit
//
//  Created by aby on 2022/12/26.
//  Copyright © 2022 Tencent. All rights reserved.
//

import Foundation
import TUICore
#if TXLiteAVSDK_TRTC
import TXLiteAVSDK_TRTC
#elseif TXLiteAVSDK_Professional
import TXLiteAVSDK_Professional
#endif
 
protocol PrePareViewEventProtocol: AnyObject {
    func updateButtonState()
    func changeLanguage()
}

class PrePareViewModel {
    weak var viewResponder: PrePareViewEventProtocol?
    var enablePrePareView: Bool = true
    var engineManager: EngineManager {
        EngineManager.shared
    }
    var currentUser: UserModel {
        engineManager.store.currentLoginUser
    }
    var roomInfo: RoomInfo {
        engineManager.store.roomInfo
    }
    var languageID: String {
        TUIGlobalization.tk_localizableLanguageKey()
    }
    
    func initialState(view: UIView) {
        let roomEngine = engineManager.roomEngine
        roomEngine.setLocalVideoView(streamType: .cameraStream, view: view)
        if roomInfo.isOpenCamera {
            roomEngine.openLocalCamera(isFront: engineManager.store.videoSetting.isFrontCamera, quality:
                                        engineManager.store.videoSetting.videoQuality) {
                debugPrint("")
            } onError: { code, message in
                debugPrint("---openLocalCamera,code:\(code),message:\(message)")
            }
        } else {
            roomEngine.closeLocalCamera()
        }
        if roomInfo.isOpenMicrophone {
            roomEngine.openLocalMicrophone(engineManager.store.audioSetting.audioQuality) {
                debugPrint("")
            } onError: { code, message in
                debugPrint("---openLocalMicrophone,code:\(code), message:\(message)")
            }
        } else {
            roomEngine.closeLocalMicrophone()
        }
        viewResponder?.updateButtonState()
    }
    
    func closeLocalCamera() {
        engineManager.roomEngine.closeLocalCamera()
    }
    
    func closeLocalMicrophone() {
        engineManager.roomEngine.closeLocalMicrophone()
    }
    
    func backAction() {
        RoomRouter.shared.pop()
    }
    
    func joinRoom() {
        RoomRouter.shared.pushJoinRoomViewController()
    }
    
    func createRoom() {
        RoomRouter.shared.pushCreateRoomViewController()
    }
    
    func switchLanguageAction() {
        if languageID == "zh-Hans" {
            TUIGlobalization.setPreferredLanguage("en")
        } else if languageID == "en" {
            TUIGlobalization.setPreferredLanguage("zh-Hans")
        }
        viewResponder?.changeLanguage()
    }
    
    func openCameraAction(sender: UIButton, placeholderImage: UIView) {
        sender.isSelected = !sender.isSelected
        let roomEngine = engineManager.roomEngine
        if sender.isSelected {
            roomInfo.isOpenCamera = false
            roomEngine.closeLocalCamera()
            roomEngine.stopPushLocalVideo()
            placeholderImage.isHidden = false
        } else {
            roomInfo.isOpenCamera = true
            placeholderImage.isHidden = true
            roomEngine.openLocalCamera(isFront: engineManager.store.videoSetting.isFrontCamera, quality:
                                        engineManager.store.videoSetting.videoQuality) { [weak self] in
                guard let self = self else { return }
                self.engineManager.roomEngine.startPushLocalVideo()
            } onError: { code, message in
                debugPrint("openLocalCamera,code:\(code),message:\(message)")
            }
        }
    }
    
    func openMicrophoneAction(sender: UIButton) {
        sender.isSelected = !sender.isSelected
        let roomEngine = engineManager.roomEngine
        if sender.isSelected {
            roomInfo.isOpenMicrophone = false
            roomEngine.closeLocalMicrophone()
            roomEngine.stopPushLocalAudio()
        } else {
            roomInfo.isOpenMicrophone = true
            roomEngine.openLocalMicrophone(engineManager.store.audioSetting.audioQuality) { [weak self] in
                guard let self = self else { return }
                self.engineManager.roomEngine.startPushLocalAudio()
            } onError: { code, message in
                debugPrint("openLocalMicrophone,code:\(code), message:\(message)")
            }
        }
    }
    
    func switchCameraAction(sender: UIButton) {
        engineManager.store.videoSetting.isFrontCamera = !engineManager.store.videoSetting.isFrontCamera
        engineManager.roomEngine.getDeviceManager().switchCamera(engineManager.store.videoSetting.isFrontCamera)
    }
    
    func switchMirrorAction(sender: UIButton) {
        engineManager.store.videoSetting.isMirror = !engineManager.store.videoSetting.isMirror
        let params = TRTCRenderParams()
        params.fillMode = .fill
        params.rotation = ._0
        if engineManager.store.videoSetting.isMirror {
            params.mirrorType = .enable
        } else {
            params.mirrorType = .disable
        }
        engineManager.roomEngine.getTRTCCloud().setLocalRenderParams(params)
    }
    
    deinit {
        TRTCCloud.destroySharedIntance()
        debugPrint("deinit \(self)")
    }
}
