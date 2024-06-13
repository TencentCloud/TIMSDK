//
//  Collection+Extension.swift
//  TUIRoomKit
//
//  Created by janejntang on 2023/3/21.
//  Copyright © 2023 Tencent. All rights reserved.
//

import Foundation

extension Collection {
    subscript (safe index: Index) -> Element? {
        return indices.contains(index) ? self[index] : nil
    }
}
