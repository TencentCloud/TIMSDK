//
//  TUICoreThemeConvert.swift
//  TUIRoomKit
//
//  Created by 唐佳宁 on 2024/1/29.
//

import Foundation
import TUICore

class TUICoreThemeConvert {
    
    static func initThemeResource() {
        TUIThemeManager.share().registerThemeResourcePath(getTUIRoomKitThemePath(), for: .roomKit)
    }
    
    static func getTUIRoomKitThemePath() -> String {
        return getTUIGetBundlePath("TUIRoomKitTheme", TUICore_TUIRoomImAccessService)
    }
    
    static func getTUIDynamicImage(imageKey: String, defaultImage: UIImage) -> UIImage? {
        return TUITheme.dynamicImage(imageKey, module: .roomKit, defaultImage: defaultImage)
    }
    
}
