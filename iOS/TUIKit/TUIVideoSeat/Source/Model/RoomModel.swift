//
//  RoomModel.swift
//  TUIVideoSeat
//
//  Created by jack on 2023/3/4.
//

import Foundation
import TUIRoomEngine

public class RoomInfo {
    public var roomId: String {
        return roomInfo.roomId
    }
    
    public var name: String {
        return roomInfo.name
    }
    
    public var speechMode: TUISpeechMode {
        return roomInfo.speechMode
    }
    
    public var isCameraDisableForAllUser: Bool {
        return roomInfo.isCameraDisableForAllUser
    }
    
    public var isMicrophoneDisableForAllUser: Bool {
        return roomInfo.isMicrophoneDisableForAllUser
    }
    
    public var isMessageDisableForAllUser: Bool {
        return roomInfo.isMessageDisableForAllUser
    }
    
    var roomType: TUIRoomType {
        return roomInfo.roomType
    }

    public var ownerId: String {
        return roomInfo.ownerId
    }
    
    private var roomInfo: TUIRoomInfo
    
    init(roomInfo: TUIRoomInfo) {
        self.roomInfo = roomInfo
    }
    
    public func update(engineRoomInfo: TUIRoomInfo) {
        roomInfo = engineRoomInfo
    }

    deinit {
        debugPrint("deinit \(self)")
    }
}
