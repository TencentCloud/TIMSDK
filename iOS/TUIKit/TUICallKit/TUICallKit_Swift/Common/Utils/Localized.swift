//
//  Localized.swift
//  TUICallKit
//
//  Created by vincepzhang on 2023/2/13.
//

import Foundation
import TUICore

// MARK: Base
func TUICallKitLocalizedBundle() -> Bundle? {
    var bundle: Bundle?
    let onceToken = DispatchSemaphore(value: 1)
    onceToken.wait()
    defer {
        onceToken.signal()
    }
    if bundle == nil {
        if let bundleUrl = Bundle.main.url(forResource: "TUICallKitBundle", withExtension: "bundle") {
            bundle = Bundle(url: bundleUrl)
        } else {
            var bundleUrl = Bundle.main.url(forResource: "Frameworks", withExtension: nil)
            bundleUrl = bundleUrl?.appendingPathComponent("TUICallKit")
            bundleUrl = bundleUrl?.appendingPathExtension("framework")
            guard let url = bundleUrl else { return nil }
            guard let associateBundle = Bundle(url: url) else { return nil }
            guard let bundleUrl = associateBundle.url(forResource: "TUICallKitBundle", withExtension: "bundle") else { return nil }
            bundle = Bundle(url: bundleUrl)
        }
    }
    return bundle
}

func TUICallKitLocalizeFromTable(key: String, table: String) -> String? {
    guard let bundlePath = TUICallKitLocalizedBundle()?.path(forResource: TUIGlobalization.getPreferredLanguage() ?? "",
                                                    ofType: "lproj") else { return nil}
    let bundle = Bundle(path: bundlePath)
    return bundle?.localizedString(forKey: key, value: "", table: table)
}

func TUICallKitLocalizerFromTableAndCommon(key: String, common: String, table: String) -> String? {
    return TUICallKitLocalizeFromTable(key: key, table: table)
}

// MARK: CallKit
let TUICallKit_Localize_TableName = "Localized"
func TUICallKitLocalize(key: String) -> String? {
    return TUICallKitLocalizeFromTable(key: key, table: TUICallKit_Localize_TableName)
}
