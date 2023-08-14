//
//  CoreExtension.swift
//  TUIRoomKit
//
//  Created by WesleyLei on 2022/9/23.
//  Copyright © 2022 Tencent. All rights reserved.
//

import Foundation
import TUICore

let gRoomEngineKey = NSObject.getRoomEngineKey()
// {roomId:roomId}
let gRoomInfoKey = NSObject.getRoomInfoKey()
// {roomId:roomId}
let gLocalUserInfoKey = NSObject.getLocalUserInfoKey()
// {roomId:roomId}
let gTopViewKey = NSObject.getTopViewKey()
// {roomId:roomId}
let gBottomViewKey = NSObject.getBottomViewKey()
// {roomId:roomId}
let gUserListControllerKey = NSObject.getUserListControllerKey()
// {roomEngine:roomEngineObj,currentUserInfo:currentUserInfoObj}
let gExtensionControllerKey = NSObject.getExtensionControllerKey()
// {roomEngine:roomEngineObj,currentUserInfo:currentUserInfoObj}

extension NSObject {
    @objc class func tuiRoomKitSwiftLoad() {
//        TUICore.registerExtension(gRoomInfoKey, object: EngineManager.shared())
//        TUICore.registerExtension(gRoomEngineKey, object: EngineManager.shared())
//        TUICore.registerExtension(gLocalUserInfoKey, object: EngineManager.shared())
    }
}
