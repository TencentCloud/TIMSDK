//
//  TUIVideoSeat.swift
//  TUIVideoSeat
//
//  Created by WesleyLei on 2022/9/13.
//

import UIKit
import TUIRoomEngine
import TUICore


public let gVideoSeatViewKey = NSObject.getVideoSeatViewKey()

@objc class TUIVideoSeat:NSObject {
    static let shared = TUIVideoSeat()
    private override init() {}
}

// MARK: - TUIExtensionProtocol

extension TUIVideoSeat: TUIExtensionProtocol {
    
    func onGetExtension(_ key: String, param: [AnyHashable : Any]?) -> [TUIExtensionInfo] {
        
        guard let param = param else {
            return []
        }
        
        guard let roomEngine = param["roomEngine"] as? TUIRoomEngine else {
            return []
        }
        
        guard let roomId = param["roomId"] as? String else {
            return []
        }
        
        if key == gVideoSeatViewKey {
            let view = TUIVideoSeatView(frame: UIScreen.main.bounds, roomEngine: roomEngine, roomId: roomId)
            var resultExtensionInfoList: [TUIExtensionInfo] = []
            let resultExtensionInfo = TUIExtensionInfo()
            resultExtensionInfo.data = [key:view]
            resultExtensionInfoList.append(resultExtensionInfo)
            return resultExtensionInfoList
        } else {
            return []
        }
    }
}
