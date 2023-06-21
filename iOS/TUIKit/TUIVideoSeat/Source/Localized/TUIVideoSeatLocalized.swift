//
//  TUIVideoSeat.swift
//  TUIVideoSeat
//
//  Created by WesleyLei on 2022/9/13.
//  Copyright © 2022 Tencent. All rights reserved.
//

import UIKit
import TUICore

func tuiVideoSeatLocalize(_ key: String) -> String {
    if let bundlePath = tuiVideoSeatBundle().path(forResource: TUIGlobalization.tk_localizableLanguageKey() ?? "", ofType: "lproj"),
       let bundle = Bundle(path: bundlePath) {
        return bundle.localizedString(forKey: key, value: "", table: "TUIVideoSeatLocalized")
    }
    return TUIVideoSeatLocalized.sharedBundle.localizedString(forKey: key, value: "", table: "TUIVideoSeatLocalized")
}

func tuiVideoSeatBundle() -> Bundle {
    return TUIVideoSeatLocalized.sharedBundle
}

private class TUIVideoSeatLocalized {
    class var sharedBundle: Bundle {
        struct Static {
            static let bundel: Bundle? = tuiVideoSeatBundle()
        }
        guard let bunddel = Static.bundel else {
            return Bundle()
        }
        return bunddel
    }
}

private func tuiVideoSeatBundle() -> Bundle? {
    var url: NSURL? = Bundle.main.url(forResource: "TUIVideoSeatKitBundle", withExtension: "bundle") as NSURL?
    if let associateBundleURL = url {
        return Bundle(url: associateBundleURL as URL)
    }
    url = Bundle.main.url(forResource: "Frameworks", withExtension: nil) as NSURL?
    url = url?.appendingPathComponent("TUIVideoSeat") as NSURL?
    url = url?.appendingPathComponent("framework") as NSURL?
    if let associateBundleURL = url {
        let bundle = Bundle(url: associateBundleURL as URL)
        url = bundle?.url(forResource: "TUIVideoSeatKitBundle", withExtension: "bundle") as NSURL?
        if let associateBundleURL = url {
            return Bundle(url: associateBundleURL as URL)
        }
    }
    return nil
}
