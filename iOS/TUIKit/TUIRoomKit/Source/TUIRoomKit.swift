//
//  TUIRoomKit.swift
//  TUIRoomKit
//
//  Created by WesleyLei on 2022/9/13.
//  Copyright © 2022 Tencent. All rights reserved.
//

import Foundation
import TUIRoomEngine

@objc public enum RoomScene: Int {
    case meeting = 1
    case live = 2
}

@objc public protocol TUIRoomKitListener {
    @objc optional func onLogin(code: Int, message: String) -> Void
    @objc optional func onRoomCreate(code: Int, message: String) -> Void
    @objc optional func onDestroyRoom() -> Void
    @objc optional func onRoomEnter(code: Int, message: String) -> Void
    @objc optional func onExitRoom() -> Void
}

@objcMembers public class TUIRoomKit: NSObject {
    weak var listener: TUIRoomKitListener?
    @objc public static let sharedInstance = TUIRoomKit()
    
    private override init() {
        super.init()
    }
    
    public func login(sdkAppId: Int, userId: String, userSig: String) {
        EngineManager.shared.login(sdkAppId: sdkAppId, userId: userId, userSig: userSig)
        EngineManager.shared.addListener(listener: self)
    }
    
    public func logout() {
        EngineManager.shared.logout()
    }
    
    public func setSelfInfo(userName: String, avatarURL: String) {
        EngineManager.shared.setSelfInfo(userName: userName, avatarURL: avatarURL)
    }
    
    public func enterPrepareView(enablePreview: Bool) {
        RoomRouter.shared.pushPrePareViewController(enablePrePareView: enablePreview)
    }
    
    public func createRoom(roomInfo: RoomInfo, type: RoomScene) {
        EngineManager.shared.store.update(roomInfo: roomInfo)
        EngineManager.shared.store.roomScene = type
        EngineManager.shared.createRoom()
    }
    
    public func enterRoom(roomInfo: RoomInfo) {
        EngineManager.shared.store.update(roomInfo: roomInfo)
        EngineManager.shared.enterRoom(roomId: roomInfo.roomId)
    }
    
    public func addListener(listener: TUIRoomKitListener) {
        self.listener = listener
    }
    
    func removeListener() {
        self.listener = nil
    }
    
    func banAutoRaiseUiOnce(isBan: Bool) {
        EngineManager.shared.store.isBanAutoRaise = isBan
    }
    
    func raiseUi() {
        RoomRouter.shared.pushMainViewController(roomId: EngineManager.shared.store.roomInfo.roomId)
    }
    
    func setChatAccessRoom(isChatAccessRoom: Bool) {
        EngineManager.shared.store.isChatAccessRoom = isChatAccessRoom
    }
    
    deinit {
        debugPrint("deinit \(self)")
    }
}

extension TUIRoomKit: EngineManagerListener {
    public func onLogin(code: Int, message: String) {
        self.listener?.onLogin?(code: code, message: message)
    }
    
    public func onCreateEngineRoom(code: Int, message: String) {
        self.listener?.onRoomCreate?(code: code, message: message)
    }
    
    public func onDestroyEngineRoom() {
        self.listener?.onDestroyRoom?()
    }
    
    public func onEnterEngineRoom(code: Int, message: String) {
        self.listener?.onRoomEnter?(code: code, message: message)
    }
    
    public func onExitEngineRoom() {
        self.listener?.onExitRoom?()
    }
}
