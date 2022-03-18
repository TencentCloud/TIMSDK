//
//  CallingLocalized.swift
//  TRTCScene
//
//  Created by adams on 2021/5/20.
//

import Foundation

let CallingLocalizeTableName = "CallingLocalized"

func CallingLocalize(_ key: String) -> String {
    return localizeFromTable(key: key, table: CallingLocalizeTableName)
}
