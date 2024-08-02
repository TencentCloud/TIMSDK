//
//  TimeZone+Extension.swift
//  TUIRoomKit
//
//  Created by janejntang on 2024/6/24.
//

import Foundation

extension TimeZone {
    func getTimeZoneName() -> String {
        //todo:
        let genericName = self.localizedName(for: .generic, locale: .current)
        let shortStandardName = self.localizedName(for: .shortStandard, locale: .current)
        let name = "(" + (shortStandardName ?? "") + ")" + (genericName ?? "")
        return name
    }
}
