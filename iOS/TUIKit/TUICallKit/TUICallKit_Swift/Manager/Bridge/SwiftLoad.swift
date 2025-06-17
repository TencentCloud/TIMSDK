//
//  SwiftLoad.swift
//  TUICallKit
//
//  Created by WesleyLei on 2022/9/23.
//  Copyright © 2022 Tencent. All rights reserved.
//

import Foundation
import TUICore

extension NSObject {
    @objc class func swiftLoad() {
        NotificationCenter.default.addObserver(self, selector: #selector(initSdkSuccess(_:)),
                                               name: Notification.Name.TUIInitSdkSuccess,
                                               object: nil)
        
        TUICore.registerService(TUICore_TUICallingService, object: TUICallKitService.instance)
        
        TUICore.registerService(TUICore_TUIAudioMessageRecordService, object: TUIAudioMessageRecordService.instance)
        
        TUICore.registerExtension(TUICore_TUIChatExtension_NavigationMoreItem_MinimalistExtensionID,
                                  object: TUICallKitExtension.instance)
        TUICore.registerExtension(TUICore_TUIChatExtension_InputViewMoreItem_ClassicExtensionID,
                                  object: TUICallKitExtension.instance)
        TUICore.registerExtension(TUICore_TUIContactExtension_FriendProfileActionMenu_ClassicExtensionID,
                                  object: TUICallKitExtension.instance)
        TUICore.registerExtension(TUICore_TUIContactExtension_FriendProfileActionMenu_MinimalistExtensionID,
                                  object: TUICallKitExtension.instance)
        TUICore.registerExtension(TUICore_TUIContactExtension_GroupInfoCardActionMenu_MinimalistExtensionID,
                                  object: TUICallKitExtension.instance)
        
        TUICore.registerExtension(TUICore_TUIChatExtension_ChatViewTopArea_ClassicExtensionID,
                                  object: TUICallKitExtension.instance)
        TUICore.registerExtension(TUICore_TUIChatExtension_ChatViewTopArea_MinimalistExtensionID,
                                  object: TUICallKitExtension.instance)
        
        TUICore.registerObjectFactory(TUICore_TUICallingObjectFactory, objectFactory: TUICallKitObjectFactory.instance)
        
        TUIThemeManager.share().registerThemeResourcePath(TUICoreDefineConvert.getTUICallKitThemePath(), for: .calling)
    }
    
    @objc func initSdkSuccess(_ notification: Notification) {
        if FrameworkConstants.framework != FrameworkConstants.callFrameworkNative {
            let _ = CallManager.shared
            return
        }
        
        let _ = TUICallKit.createInstance()
    }
}
