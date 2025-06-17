//
//  TUICoreDefineConvert.swift
//  TUICallKit
//
//  Created by vincepzhang on 2023/8/14.
//

import Foundation
import TUICore


class TUICoreDefineConvert {
    
    static func getTUIKitLocalizableString(key: String) -> String {
        return TUIGlobalization.getLocalizedString(forKey: key, bundle: TUIKitLocalizableBundle)
    }
    
    static func getTIMCommonLocalizableString(key: String) -> String? {
        return TUIGlobalization.getLocalizedString(forKey: key, bundle: TIMCommonLocalizableBundle)
    }
    
    static func getTUICoreBundleThemeImage(imageKey: String, defaultImageName: String) -> UIImage? {
        let tuiCoreCommonBundleImage = UIImage(contentsOfFile: getTUIGetBundlePath(TUICoreBundle, TUICoreBundle_Key_Class) + "/" + defaultImageName)
        return TUITheme.dynamicImage(imageKey, module: TUIThemeModule.core, defaultImage: tuiCoreCommonBundleImage ?? UIImage())
    }
    
    static func getTUIDynamicImage(imageKey: String, module: TUIThemeModule, defaultImage: UIImage) -> UIImage? {
        return TUITheme.dynamicImage(imageKey, module: module, defaultImage: defaultImage)
    }
    
    static func getTUIContactImagePathMinimalist(imageName: String) -> String {
        return getTUIGetBundlePath(TUIContactBundle_Minimalist, TUIContactBundle_Key_Class) + "/" + imageName
    }
    
    static func getTUICallKitDynamicColor(colorKey: String, defaultHex: String) -> UIColor? {
        return TUITheme.dynamicColor(colorKey, module: TUIThemeModule.calling, defaultColor: defaultHex)
    }
    
    static func getTUICoreDynamicColor(colorKey: String, defaultHex: String) -> UIColor? {
        return TUITheme.dynamicColor(colorKey, module: TUIThemeModule.core, defaultColor: defaultHex)
    }
        
    static func getDefaultAvatarImage() -> UIImage {
        return TUIConfig.default().defaultAvatarImage
    }
    
    static func getDefaultGroupAvatarImage() -> UIImage {
        return TUIConfig.default().defaultAvatarImage
    }
    
    static func getIsRTL() -> Bool {
        return TUIGlobalization.getRTLOption()
    }
    
    static func getTUICallKitThemePath() -> String {
        return getTUIGetBundlePath("TUICallKitTheme", "TUICallingService")
    }
}
