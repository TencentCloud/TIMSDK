//
//  RoomSetListItemData.swift
//  TUIRoomKit
//
//  Created by janejntang on 2023/6/27.
//

import Foundation

class RoomSetListItemData {
    var titleText: String = ""
    var isSwitchOn: Bool = false
    var action: ((Any)->Void)?
}
