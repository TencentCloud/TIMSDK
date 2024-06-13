//
//  TUIRoomMessageExtensionObserver.swift
//  TUIRoomKit
//
//  Created by janejntang on 2023/5/8.
//  Copyright © 2023 Tencent. All rights reserved.
//

import Foundation
import TUICore

extension NSObject {
    @objc class func tuiRoomKitExtensionLoad() {
        TUICore.registerExtension(TUICore_TUIChatExtension_InputViewMoreItem_ClassicExtensionID, object: RoomMessageExtensionObserver.shared)
        TUICore.registerService(TUICore_TUIRoomImAccessService, object: TUIRoomImAccessService.shared)
        TUICore.registerObjectFactory(TUICore_TUIRoomImAccessFactory, objectFactory: TUIRoomImAccessFactory.shared)
        TUICore.registerExtension(TUICore_TUIContactExtension_MeSettingMenu_ClassicExtensionID, object: RoomMessageExtensionObserver.shared)
    }
}
