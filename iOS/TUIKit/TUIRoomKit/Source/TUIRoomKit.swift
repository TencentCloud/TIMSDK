//
//  TUIRoomKit.swift
//  TUIRoomKit
//
//  Created by WesleyLei on 2022/9/13.
//  Copyright © 2022 Tencent. All rights reserved.
//

import Foundation
import RTCRoomEngine

@available(*, deprecated, message: "Use ConferenceMainViewController instead.")
@objcMembers public class TUIRoomKit: NSObject {
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
        EngineManager.shared.setSelfInfo(userName: userName, avatarURL: avatarURL, onSuccess: onSuccess, onError: onError)
    }
    
    public func createRoom(roomInfo: TUIRoomInfo, onSuccess: @escaping TUISuccessBlock, onError: @escaping TUIErrorBlock) {
        EngineManager.shared.createRoom(roomInfo: roomInfo, onSuccess: onSuccess, onError: onError)
    }
    
    public func enterRoom(roomId: String, enableAudio: Bool, enableVideo: Bool, isSoundOnSpeaker: Bool,
                          onSuccess: @escaping TUISuccessBlock, onError: @escaping TUIErrorBlock) {
        EngineManager.shared.enterRoom(roomId: roomId, enableAudio: enableAudio, enableVideo: enableVideo,
                                                 isSoundOnSpeaker: isSoundOnSpeaker) {
            RoomRouter.shared.pushMainViewController()
        } onError: { code, message in
            onError(code, message)
        }
    }
    
    deinit {
        debugPrint("deinit \(self)")
    }
}
