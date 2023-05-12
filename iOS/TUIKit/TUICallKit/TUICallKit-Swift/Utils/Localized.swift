//
//  Localized.swift
//  TUICallKit
//
//  Created by vincepzhang on 2023/2/13.
//

import Foundation

//MARK: Base
func TUICallKitBundle() -> Bundle? {
    guard let url = Bundle.main.url(forResource: "TUICallingKitBundle", withExtension: "bundle") else { return nil }
    return Bundle(url: url)
}

func TUICallKitLocalizeFromTable(key: String, table: String) -> String? {
    return TUICallKitBundle()?.localizedString(forKey: key, value: "", table: table)
}

func TUICallKitLocalizerFromTableAndCommon(key: String, common: String, table: String) -> String? {
    return TUICallKitLocalizeFromTable(key: key, table: table)
}

//MARK: Replace String



// MARK: CallKit
let TUICallKit_Localize_TableName = "CallingLocalized"
func TUICallKitLocalize(key: String) -> String? {
    return TUICallKitLocalizeFromTable(key: key, table: TUICallKit_Localize_TableName)
}
