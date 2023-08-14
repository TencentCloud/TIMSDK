//
//  TUIRoomKit.swift
//  TUIRoomKit
//
//  Created by WesleyLei on 2022/9/13.
//  Copyright © 2022 Tencent. All rights reserved.
//

import Foundation
import TUIRoomEngine

@objcMembers public class TUIRoomKit: NSObject {
    typealias Weak<T> = () -> T?
    private static var _shared: TUIRoomKit?
    public class func createInstance() -> TUIRoomKit {
        guard let instance = _shared else {
            let roomKit = TUIRoomKit()
            _shared = roomKit
            return roomKit
        }
        return instance
    }
    
    public class func destroyInstance() {
        TUIRoomKit._shared = nil
    }
    
    private override init() {
        super.init()
    }
    
    public func setSelfInfo(userName: String, avatarURL: String, onSuccess: @escaping TUISuccessBlock, onError: @escaping TUIErrorBlock) {
        EngineManager.createInstance().setSelfInfo(userName: userName, avatarURL: avatarURL, onSuccess: onSuccess, onError: onError)
    }
    
    public func createRoom(roomInfo: RoomInfo, onSuccess: @escaping TUISuccessBlock, onError: @escaping TUIErrorBlock) {
        EngineManager.createInstance().createRoom(roomInfo: roomInfo, onSuccess: onSuccess, onError: onError)
    }
    
    public func enterRoom(roomInfo: RoomInfo, onSuccess: @escaping TUISuccessBlock, onError: @escaping TUIErrorBlock) {
        EngineManager.createInstance().enterRoom(roomInfo: roomInfo, onSuccess: onSuccess, onError: onError)
    }
    
    deinit {
        debugPrint("deinit \(self)")
    }
}
