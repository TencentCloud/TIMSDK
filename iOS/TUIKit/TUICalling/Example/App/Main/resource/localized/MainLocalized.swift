//
//  MainLocalized.strings
//  TUICallingApp
//
//  Created by noah on 2021/12/27.
//

import Foundation

let MainLocalizeTableName = "MainLocalized"

func MainLocalize(_ key: String) -> String {
    return localizeFromTable(key: key, table: MainLocalizeTableName)
}
