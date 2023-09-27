//
//  RoomKitLocalized.swift
//  TUIRoomKit
//
//  Created by WesleyLei on 2022/9/13.
//  Copyright © 2022 Tencent. All rights reserved.
//

import UIKit
import TUICore

func localized(_ key: String) -> String {
    if let bundlePath = tuiRoomKitBundle().path(forResource: TUIGlobalization.tk_localizableLanguageKey() ?? "", ofType: "lproj"),
       let bundle = Bundle(path: bundlePath) {
        return bundle.localizedString(forKey: key, value: "", table: "TUIRoomKitLocalized")
    }
    return TUIRoomKitLocalized.sharedBundle.localizedString(forKey: key, value: "", table: "TUIRoomKitLocalized")
}

func localizedReplace(_ origin: String, replace: String) -> String {
    return origin.replacingOccurrences(of: "xx", with: replace)
}

func tuiRoomKitBundle() -> Bundle {
    return TUIRoomKitLocalized.sharedBundle
}

private class TUIRoomKitLocalized {
    class var sharedBundle: Bundle {
        struct Static {
            static let bundle: Bundle? = tuiRoomKitBundle()
        }
        guard let bundle = Static.bundle else {
            return Bundle()
        }
        return bundle
    }
}

private func tuiRoomKitBundle() -> Bundle? {
    var url: NSURL? = Bundle.main.url(forResource: "TUIRoomKitBundle", withExtension: "bundle") as NSURL?
    if let associateBundleURL = url {
        return Bundle(url: associateBundleURL as URL)
    }
    url = Bundle.main.url(forResource: "Frameworks", withExtension: nil) as NSURL?
    url = url?.appendingPathComponent("TUIRoomKit") as NSURL?
    url = url?.appendingPathComponent("framework") as NSURL?
    if let associateBundleURL = url {
        let bundle = Bundle(url: associateBundleURL as URL)
        url = bundle?.url(forResource: "TUIRoomKitBundle", withExtension: "bundle") as NSURL?
        if let associateBundleURL = url {
            return Bundle(url: associateBundleURL as URL)
        }
    }
    return nil
}
