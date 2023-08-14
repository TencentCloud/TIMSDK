//
//  EngineManager.swift
//  TUIRoomKit
//
//  Created by WesleyLei on 2022/9/22.
//  Copyright © 2022 Tencent. All rights reserved.
//

import Foundation
import TUICore
import TUIRoomEngine
#if TXLiteAVSDK_TRTC
import TXLiteAVSDK_TRTC
#elseif TXLiteAVSDK_Professional
import TXLiteAVSDK_Professional
#endif

class EngineManager: NSObject {
    private static var _shared: EngineManager?
    class func createInstance() -> EngineManager {
        guard let instance = _shared else {
            let engineManager = EngineManager()
            _shared = engineManager
            return engineManager
        }
        return instance
    }
    private(set) lazy var store: RoomStore = {
        let store = RoomStore()
        return store
    }()
    private(set) lazy var roomEngine: TUIRoomEngine = {
        let roomEngine = TUIRoomEngine()
        roomEngine.addObserver(EngineEventCenter.shared)
        return roomEngine
    }()
    let timeOutNumber: Double = 30
    let rootRouter: RoomRouter = RoomRouter.shared
    var isLoginEngine: Bool = false
    
    override private init() {}
    
    private func login(sdkAppId: Int, userId: String, userSig: String, onSuccess: @escaping TUISuccessBlock, onError: @escaping TUIErrorBlock) {
        V2TIMManager.sharedInstance().initSDK(Int32(sdkAppId), config: V2TIMSDKConfig())
        store.currentUser.userId = userId
        TUIRoomEngine.login(sdkAppId: sdkAppId, userId: userId, userSig: userSig) { [weak self] in
            guard let self = self else { return }
            self.isLoginEngine = true
           onSuccess()
        } onError: { code, message in
           onError(code, message)
        }
    }
    
    func setSelfInfo(userName: String, avatarURL: String, onSuccess: @escaping TUISuccessBlock, onError: @escaping TUIErrorBlock) {
        store.currentUser.userName = userName
        store.currentUser.avatarUrl = avatarURL
        TUIRoomEngine.setSelfInfo(userName: userName, avatarUrl: avatarURL) {
            onSuccess()
        } onError: { code, message in
            onError(code, message)
            debugPrint("---setSelfInfo,code:\(code),message:\(message)")
        }
    }
    
    func logout(onSuccess: @escaping TUISuccessBlock, onError: @escaping TUIErrorBlock) {
        let logoutBlock = { [weak self] in
            guard let self = self else { return }
            TUIRoomEngine.logout { [weak self] in
                guard let self = self else { return }
                self.isLoginEngine = false
            } onError: { code, message in
                debugPrint("---logout,code:\(code),message:\(message)")
            }
        }
        if store.isEnteredRoom {
            if store.currentUser.userRole == .roomOwner {
                destroyRoom {
                    logoutBlock()
                } onError: { code, message in
                    onError(code, message)
                }

            } else {
                exitRoom {
                    logoutBlock()
                } onError: { code, message in
                    onError(code, message)
                }
            }
        } else {
            logoutBlock()
        }
    }
    
    func createRoom(roomInfo: RoomInfo, onSuccess: @escaping TUISuccessBlock, onError: @escaping TUIErrorBlock) {
        store.roomInfo = roomInfo
        let createRoomBlock = { [weak self] in
            guard let self = self else { return }
            self.roomEngine.createRoom(roomInfo.getEngineRoomInfo()) {
                onSuccess()
            } onError: { code, message in
                onError(code, message)
            }
        }
        if !isLoginEngine {
            self.login(sdkAppId: Int(TUILogin.getSdkAppID()), userId: TUILogin.getUserID() ?? "", userSig: TUILogin.getUserSig() ?? "")
            { [weak self] in
                guard let self = self else { return }
                self.isLoginEngine = true
                createRoomBlock()
            } onError: { code, message in
                onError(code, message)
            }
        } else {
            createRoomBlock()
        }
    }
    
    func enterRoom(roomInfo: RoomInfo, onSuccess: @escaping TUISuccessBlock, onError: @escaping TUIErrorBlock) {
        store.roomInfo = roomInfo
        setFramework()
        let enterRoomBlock = { [weak self] in
            guard let self = self else { return }
            self.roomEngine.enterRoom(roomInfo.roomId) { [weak self] roomInfo in
                guard let self = self else { return }
                guard let roomInfo = roomInfo else { return }
                //更新store存储的进房数据
                self.store.roomInfo.update(engineRoomInfo: roomInfo)
                self.store.initialRoomCurrentUser()
                self.store.isEnteredRoom = true
                self.store.timeStampOnEnterRoom = Int(Date().timeIntervalSince1970)
                //判断用户是否需要上麦进行申请
                self.operateLocalMicrophone { [weak self] in
                    guard let self = self else { return }
                    onSuccess()
                    if self.store.isShowRoomMainViewAutomatically {
                        self.showRoomViewController(roomId: roomInfo.roomId)
                    }
                } onError: { code, message in
                    onError(code, message)
                }
            } onError: { code, message in
                onError(code, message)
            }
            
        }
        if !isLoginEngine {
            self.login(sdkAppId: Int(TUILogin.getSdkAppID()), userId: TUILogin.getUserID() ?? "", userSig: TUILogin.getUserSig() ?? "")
            { [weak self] in
                guard let self = self else { return }
                self.isLoginEngine = true
                enterRoomBlock()
            } onError: { code, message in
                onError(code, message)
            }
        } else {
            enterRoomBlock()
        }
        
    }
    
    func exitRoom(onSuccess: TUISuccessBlock?, onError: TUIErrorBlock?) {
        roomEngine.getTRTCCloud().stopAllRemoteView()
        RoomFloatView.dismiss()
        roomEngine.exitRoom(syncWaiting: false) { [weak self] in
            guard let self = self else { return }
            self.destroyEngineManager()
            EngineEventCenter.shared.notifyUIEvent(key: .TUIRoomKitService_ExitedRoom, param: ["isExited":true])
            guard let onSuccess = onSuccess else { return }
            onSuccess()
        } onError: { [weak self] code, message in
            guard let self = self else { return }
            self.destroyEngineManager()
            EngineEventCenter.shared.notifyUIEvent(key: .TUIRoomKitService_ExitedRoom, param: ["isExited":false])
            guard let onError = onError else { return }
            onError(code, message)
        }
        TRTCCloud.destroySharedIntance()
    }
    
    func destroyRoom(onSuccess: TUISuccessBlock?, onError: TUIErrorBlock?) {
        roomEngine.getTRTCCloud().stopAllRemoteView()
        RoomFloatView.dismiss()
        roomEngine.destroyRoom { [weak self] in
            guard let self = self else { return }
            self.destroyEngineManager()
            EngineEventCenter.shared.notifyUIEvent(key: .TUIRoomKitService_DestroyedRoom, param: ["isDestroyed":true])
            guard let onSuccess = onSuccess else { return }
            onSuccess()
        } onError: { [weak self] code, message in
            guard let self = self else { return }
            self.destroyEngineManager()
            EngineEventCenter.shared.notifyUIEvent(key: .TUIRoomKitService_DestroyedRoom, param: ["isDestroyed":false])
            guard let onError = onError else { return }
            onError(code, message)
        }
        TRTCCloud.destroySharedIntance()
    }
    
    func destroyEngineManager() {
        EngineManager._shared = nil
    }
    
    //关闭本地麦克风
    func closeLocalMicrophone() {
        store.roomInfo.isOpenMicrophone = false
        roomEngine.closeLocalMicrophone()
    }
    
    //打开本地麦克风
    func openLocalMicrophone() {
        let actionBlock = { [weak self] in
            guard let self = self else { return }
            self.store.roomInfo.isOpenMicrophone = true
            self.roomEngine.openLocalMicrophone(self.store.audioSetting.audioQuality) {
            } onError: { code, message in
                debugPrint("openLocalMicrophone,code:\(code), message:\(message)")
            }
        }
        if RoomCommon.checkAuthorMicStatusIsDenied() {
            actionBlock()
        } else {
            RoomCommon.micStateActionWithPopCompletion {
                if RoomCommon.checkAuthorMicStatusIsDenied() {
                    actionBlock()
                }
            }
        }
    }
    
    //关闭本地摄像头
    func closeLocalCamera() {
        store.roomInfo.isOpenCamera = false
        roomEngine.closeLocalCamera()
    }
    
    //打开本地摄像头
    func openLocalCamera() {
        let actionBlock = { [weak self] in
            guard let self = self else { return }
            self.store.roomInfo.isOpenCamera = true
            self.roomEngine.openLocalCamera(isFront: self.store.videoSetting.isFrontCamera, quality:
                                                            self.store.videoSetting.videoQuality) {
            } onError: { code, message in
                debugPrint("openLocalCamera,code:\(code),message:\(message)")
            }
        }
        if RoomCommon.checkAuthorCamaraStatusIsDenied() {
           actionBlock()
        } else {
            RoomCommon.cameraStateActionWithPopCompletion {
                if RoomCommon.checkAuthorCamaraStatusIsDenied() {
                    actionBlock()
                }
            }
        }
    }
    
    //申请打开本地设备（当roomType是applyToSpeak时使用）
    func applyToAdminToOpenLocalDevice(device: TUIMediaDevice, timeout: Double) {
        roomEngine.applyToAdminToOpenLocalDevice(device: device, timeout: timeout) {  [weak self] _, _ in
            guard let self = self else { return }
            switch device {
            case .camera:
                self.openLocalCamera()
            case .microphone:
                self.openLocalMicrophone()
            default:
                break
            }
        } onRejected: { _, _, _ in
            //todo
        } onCancelled: { _, _ in
            //todo
        } onTimeout: { _, _ in
            //todo
        }
    }
    
    func switchCamera() {
        store.videoSetting.isFrontCamera = !store.videoSetting.isFrontCamera
        roomEngine.getDeviceManager().switchCamera(store.videoSetting.isFrontCamera)
    }
    
    func switchMirror() {
        store.videoSetting.isMirror = !store.videoSetting.isMirror
        let params = TRTCRenderParams()
        params.fillMode = .fill
        params.rotation = ._0
        if store.videoSetting.isMirror {
            params.mirrorType = .enable
        } else {
            params.mirrorType = .disable
        }
        roomEngine.getTRTCCloud().setLocalRenderParams(params)
    }
    
    func muteAllAudioAction(isMute: Bool, onSuccess: @escaping TUISuccessBlock, onError: @escaping TUIErrorBlock) {
        store.roomInfo.isMicrophoneDisableForAllUser = isMute
        roomEngine.disableDeviceForAllUserByAdmin(device: .microphone, isDisable:
                store.roomInfo.isMicrophoneDisableForAllUser) {
            onSuccess()
        } onError: { code, message in
            onError(code, message)
        }
    }
    
    func muteAllVideoAction(isMute: Bool, onSuccess: @escaping TUISuccessBlock, onError: @escaping TUIErrorBlock) {
        store.roomInfo.isCameraDisableForAllUser = isMute
        roomEngine.disableDeviceForAllUserByAdmin(device: .camera, isDisable:
                                                                        store.roomInfo.isCameraDisableForAllUser) {
            onSuccess()
        } onError: { code, message in
            onError(code, message)
        }
    }
    
    //主持人/管理员 邀请用户上麦
    func takeUserOnSeatByAdmin(userId: String, timeout: Double) {
        roomEngine.takeUserOnSeatByAdmin(-1, userId: userId, timeout: timeout) { _, _ in
            //todo
        } onRejected: { _, _, _ in
            //todo
        } onCancelled: { _, _ in
            //todo
        } onTimeout: { _, _ in
            //todo
        } onError: { _, _, _, _ in
            //todo
        }
    }
    
    func setAudioRoute(route: TRTCAudioRoute) {
        roomEngine.getTRTCCloud().setAudioRoute(route)
    }
    
    deinit {
        debugPrint("deinit \(self)")
    }
}

// MARK: - Private
extension EngineManager {
    private func showRoomViewController(roomId: String) {
        self.rootRouter.pushMainViewController(roomId: roomId)
    }
    
    private func operateLocalMicrophone(onSuccess: @escaping TUISuccessBlock, onError: @escaping TUIErrorBlock) {
        switch self.store.roomInfo.speechMode {
        case .freeToSpeak:
            if self.store.roomInfo.isOpenMicrophone && (!self.store.roomInfo.isMicrophoneDisableForAllUser
                                                        || self.store.currentUser.userId == self.store.roomInfo.ownerId) {
                self.openMicrophone()
            }
            onSuccess()
        case .applyToSpeak:
            if self.store.currentUser.userId == self.store.roomInfo.ownerId, self.store.roomInfo.isOpenMicrophone {
                self.openMicrophone()
            }
            onSuccess()
        case .applySpeakAfterTakingSeat:
            //如果用户是房主，直接上麦
            if self.store.currentUser.userId == self.store.roomInfo.ownerId {
                self.takeSeat {
                    if self.store.roomInfo.isOpenMicrophone {
                        self.openMicrophone()
                    }
                    onSuccess()
                } onError: { [weak self] code, message in
                    guard let self = self else { return }
                    self.destroyRoom(onSuccess: nil, onError: nil)
                    self.rootRouter.dismissAllRoomPopupViewController()
                    self.rootRouter.popToRoomEntranceViewController()
                    onError(code, message)
                }
            } else { //如果是观众，进入举手发言房间不上麦
                onSuccess()
            }
        default:
            if self.store.currentUser.userId == self.store.roomInfo.ownerId {
                self.destroyRoom(onSuccess: nil, onError: nil)
            } else {
                self.exitRoom(onSuccess: nil, onError: nil)
            }
            self.rootRouter.dismissAllRoomPopupViewController()
            self.rootRouter.popToRoomEntranceViewController()
            onError(.failed, "speechMode is wrong")
        }
    }
    
    private func openMicrophone() {
        let openLocalMicrophoneBlock = { [weak self] in
            guard let self = self else { return }
            self.roomEngine.openLocalMicrophone(self.store.audioSetting.audioQuality) {
            } onError: { code, message in
                debugPrint("openLocalMicrophone:code:\(code),message:\(message)")
            }
        }
        if RoomCommon.checkAuthorMicStatusIsDenied() {
            openLocalMicrophoneBlock()
        } else {
            RoomCommon.micStateActionWithPopCompletion {
                if RoomCommon.checkAuthorMicStatusIsDenied() {
                    openLocalMicrophoneBlock()
                }
            }
        }
    }
    
    private func takeSeat(onSuccess: @escaping TUISuccessBlock, onError: @escaping TUIErrorBlock) {
        self.roomEngine.takeSeat(-1, timeout: self.timeOutNumber) { [weak self] _, _ in
            guard let self = self else { return }
            self.store.currentUser.isOnSeat = true
            onSuccess()
        } onRejected: { _, _, _ in
            onError(.failed, "rejected")
        } onCancelled: { _, _ in
            onError(.failed, "onCancelled")
        } onTimeout: { _, _ in
            onError(.failed, "timeout")
        } onError: { _, _, code, message in
            onError(code, message)
        }
    }
}
// MARK: - TUIExtensionProtocol

extension EngineManager: TUIExtensionProtocol {
    func getExtensionInfo(_ key: String, param: [AnyHashable: Any]?) -> [AnyHashable: Any] {
        guard let param = param else {
            return [:]
        }
        
        guard let roomId: String = param["roomId"] as? String else {
            return [:]
        }
        
        if key == gRoomEngineKey {
            return [key: roomEngine]
        } else if key == gRoomInfoKey {
            return [key: store.roomInfo]
        } else if key == gLocalUserInfoKey {
            return [key: store.currentUser]
        } else {
            return [:]
        }
    }
}


// MARK: - setFramework
extension EngineManager {
    fileprivate static let TUIRoomKitFrameworkValue = 1
    fileprivate static let TUIRoomKitComponentValue = 18
    fileprivate static let TUIRoomKitLanguageValue = 3
    private func setFramework() {
        let jsonStr = """
            {
                "api":"setFramework",
                "params":{
                    "framework":\(EngineManager.TUIRoomKitFrameworkValue),
                    "component":\(EngineManager.TUIRoomKitComponentValue),
                    "language":\(EngineManager.TUIRoomKitLanguageValue)
                }
            }
        """
        roomEngine.callExperimentalAPI(jsonStr: jsonStr)
    }
}
