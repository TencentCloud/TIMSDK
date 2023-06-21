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
    static let shared = EngineManager()
    private weak var listener: EngineManagerListener?
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
    
    override private init() {}
    
    func refreshRoomEngine() {
        roomEngine.removeObserver(EngineEventCenter.shared)
        roomEngine = TUIRoomEngine()
        roomEngine.addObserver(EngineEventCenter.shared)
    }
    
    func login(sdkAppId: Int, userId: String, userSig: String) {
        TUIRoomEngine.login(sdkAppId: sdkAppId, userId: userId, userSig: userSig) { [weak self] in
            guard let self = self else { return }
            self.store.currentLoginUser.userId = userId
            self.listener?.onLogin?(code: 0, message: "success")
        } onError: { [weak self] code, message in
            guard let self = self else { return }
            self.listener?.onLogin?(code: code.rawValue, message: message)
        }
    }
    
    func setSelfInfo(userName: String, avatarURL: String) {
        store.currentLoginUser.userName = userName
        store.currentLoginUser.avatarUrl = avatarURL
        TUIRoomEngine.setSelfInfo(userName: userName, avatarUrl: avatarURL) {
        } onError: { code, message in
            debugPrint("---setSelfInfo,code:\(code),message:\(message)")
        }
    }
    
    func logout() {
        store = RoomStore()
        TUIRoomEngine.logout {
        } onError: { code, message in
            debugPrint("---logout,code:\(code),message:\(message)")
        }
    }
    
    func createRoom() {
        let roomInfo = store.roomInfo
        if store.roomScene == .meeting {
            roomInfo.roomType = .conference
        } else {
            roomInfo.roomType = .livingRoom
        }
        roomEngine.createRoom(roomInfo.getEngineRoomInfo()) { [weak self] in
            guard let self = self else { return }
            self.listener?.onCreateEngineRoom?(code: 0, message: "success")
            self.enterEngineRoom(roomId: roomInfo.roomId) { [weak self] in
                guard let self = self else { return }
                self.store.currentUser.userRole = .roomOwner
                self.listener?.onEnterEngineRoom?(code: 0, message: "success")
                if !self.store.isBanAutoRaise {
                    self.showRoomViewController(roomId: roomInfo.roomId)
                }
            } onError: { [weak self] code, message in
                guard let self = self else { return }
                self.listener?.onEnterEngineRoom?(code: code.rawValue, message: message)
                RoomRouter.makeToast(toast: message)
            }
        } onError: { [weak self] code, message in
            guard let self = self else { return }
            self.listener?.onCreateEngineRoom?(code: code.rawValue, message: message)
            RoomRouter.makeToast(toast: message)
        }
    }
    
    func enterRoom(roomId: String) {
        enterEngineRoom(roomId: roomId) { [weak self] in
            guard let self = self else { return }
            self.store.currentUser.userRole = .generalUser
            self.listener?.onEnterEngineRoom?(code: 0, message: "success")
            self.showRoomViewController(roomId: roomId)
        } onError: { [weak self] code, message in
            guard let self = self else { return }
            self.listener?.onEnterEngineRoom?(code: code.rawValue, message: message)
            RoomRouter.makeToast(toast: message)
        }
    }
    
    func enterEngineRoom(roomId:String, onSuccess: @escaping TUISuccessBlock, onError: @escaping TUIErrorBlock) {
        roomEngine.enterRoom(roomId) { [weak self] roomInfo in
            guard let self = self else { return }
            guard let roomInfo = roomInfo else {return }
            self.store.roomInfo.update(engineRoomInfo: roomInfo)
            self.store.initialRoomCurrentUser()
            //判断用户是否需要上麦进行申请
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
                    } onError: { [weak self] code, message in
                        guard let self = self else { return }
                        self.destroyRoom()
                        self.rootRouter.dismissAllRoomPopupViewController()
                        self.rootRouter.popToRoomEntranceViewController()
                    }
                } else { //如果是观众，进入举手发言房间不上麦
                    onSuccess()
                }
            default:
                if self.store.currentUser.userId == self.store.roomInfo.ownerId {
                    self.destroyRoom()
                } else {
                    self.exitRoom()
                }
                self.rootRouter.dismissAllRoomPopupViewController()
                self.rootRouter.popToRoomEntranceViewController()
            }
        } onError: { code, message in
            onError(code, message)
        }
    }
    
    func exitRoom() {
        roomEngine.exitRoom(syncWaiting: false) { [weak self] in
            guard let self = self else { return }
            self.refreshRoomEngine()
            self.listener?.onExitEngineRoom?()
            self.store.refreshStore()
        } onError: { [weak self] code, message in
            guard let self = self else { return }
            self.refreshRoomEngine()
            self.listener?.onExitEngineRoom?()
            self.store.refreshStore()
        }
        TRTCCloud.destroySharedIntance()
    }
    
    func destroyRoom() {
        roomEngine.destroyRoom { [weak self] in
            guard let self = self else { return }
            self.refreshRoomEngine()
            self.listener?.onDestroyEngineRoom?()
            self.store.refreshStore()
        } onError: { [weak self] code, message in
            guard let self = self else { return }
            self.refreshRoomEngine()
            self.listener?.onDestroyEngineRoom?()
            self.store.refreshStore()
        }
        TRTCCloud.destroySharedIntance()
    }
    
    func addListener(listener: EngineManagerListener?) {
        guard let listener = listener else { return }
        self.listener = listener
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
    private func openMicrophone() {
        roomEngine.openLocalMicrophone(store.audioSetting.audioQuality) { [weak self] in
            guard let self = self else { return }
            self.roomEngine.startPushLocalAudio()
        } onError: { code, message in
            debugPrint("openLocalMicrophone:code:\(code),message:\(message)")
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

@objc public protocol EngineManagerListener {
    @objc optional func onLogin(code: Int, message: String) -> Void
    @objc optional func onCreateEngineRoom(code: Int, message: String) -> Void
    @objc optional func onDestroyEngineRoom() -> Void
    @objc optional func onEnterEngineRoom(code: Int, message: String) -> Void
    @objc optional func onExitEngineRoom() -> Void
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
